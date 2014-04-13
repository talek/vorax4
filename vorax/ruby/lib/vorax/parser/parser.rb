# encoding: utf-8

module Vorax

  # Provides parsing utilities.
  module Parser

    END_LINE = /\r\n?|\n/ unless defined?(END_LINE)
    SQLPLUS_TERMINATOR = END_LINE unless defined?(SQLPLUS_TERMINATOR)
    SEMI_COLON_TERMINATOR = /;/ unless defined?(SEMI_COLON_TERMINATOR)
    SLASH_TERMINATOR = Regexp.new('(?:' + END_LINE.to_s + '\s*\/[ \t]*' + END_LINE.to_s + ')') unless defined?(SLASH_TERMINATOR)
    
    # Given an expression with  parenthesis, it is walking it so that to
    # keep track of the open/close paren, in a balanced way.
    #
    # @param text [String] the string to be walked
    # @return [String] the paren expression
    def self.walk_balanced_paren(text)
      walker = PlsqlWalker.new(text)
      level = 0
      start_pos = 0
      end_pos = 0
      walker.register_spot(/[(]/) do |scanner|
        start_pos = scanner.pos - 1 if level == 0
        level += 1
      end
      walker.register_spot(/[)]/) do |scanner|
        level -= 1
        if level <= 0
          end_pos = scanner.pos
          scanner.terminate
        end
      end
      walker.walk
      text[start_pos, end_pos]
    end

    # Given a parameter list <e.g. p1 varchar2 := myf('abc', 1, f(y)), p2 boolean) >
    # it gets the position of the next parameter in the list, which means the next
    # comma not within balanced parens or the last closing bracket of the corresponding
    # function/procedure. Of course a comma in a comment or a literal doesn't count.
    def self.next_argument(text)
      walker = PlsqlWalker.new(text)
      level = 0
      next_pos = 0
      walker.register_spot(/[(]/) do |scanner|
        level += 1
      end
      walker.register_spot(/[)]/) do |scanner|
        level -= 1
        if level < 0
          next_pos = scanner.pos
          scanner.terminate
        end
      end
      walker.register_spot(/[,]/) do |scanner|
        if level == 0
          # end of function
          next_pos = scanner.pos
          scanner.terminate
        end
      end
      walker.walk
      next_pos
    end

    # Remove all comments from the provided statement. Pay attention that every
    # comment is replaced by a blank in order to cover the case where a comment is
    # used as a whitespace (e.g. select * from/*comment*/dual).
    #
    # @param statement [String] the statement to be cleaned up of comments
    # @return [String] the statement without any comment
    def self.remove_all_comments(statement)
      comment_areas = []
      result = statement
      walker = PlsqlWalker.new(statement, false)
      
      callback = lambda do |scanner, end_pattern|
        start_pos = scanner.pos - scanner.matched.length
        text = scanner.scan_until(end_pattern)
        if text
          comment_areas << (start_pos..scanner.pos - 1)
        else
          scanner.terminate
        end
      end

      walker.register_spot(PlsqlWalker::BEGIN_ML_COMMENT) do |scanner|
        callback.call(scanner, PlsqlWalker::END_ML_COMMENT)
      end

      walker.register_spot(PlsqlWalker::BEGIN_SL_COMMENT) do |scanner|
        callback.call(scanner, PlsqlWalker::END_SL_COMMENT)
      end

      walker.register_default_plsql_quoting_spot()
      walker.register_default_double_quoting_spot()
      walker.register_default_single_quoting_spot()
      walker.walk
      offset = 0
      comment_areas.each do |interval| 
        r = (interval.min - offset .. interval.max - offset)
        result[r] = " "
        offset += (interval.max - interval.min)
      end
      result
    end

    # Remove the trailing comments from the provided statement.
    #
    # @param statement [String] the statement to be cleaned up
    # @return the statement without the trailing comments.
    def self.remove_trailing_comments(statement)
      stmt = statement
      begin
        stmt.gsub!(/(?:--[^\n]*\s*\z)|(?:\/\*.*?\*\/\s*\z)/m, '')
      end while !$~.nil?
      stmt
    end

    # Get the function/procedure to which the argument on the
    # provided position belongs.
    #
    # @param statement [String] the statement to be parsed
    # @param position [int] the position index where the 
    #   argument should be given
    def self.argument_belongs_to(statement, position = nil)
      Vorax.debug("statement=#{statement.inspect} positon=#{position}")
      position = statement.length unless position
      stmt = Parser.remove_all_comments(statement[(0...position-1)])
      Vorax.debug("interesting part=#{stmt}")
      stmt.reverse!
      level = 0
      walker = PlsqlWalker.new(stmt, false)
      arg_owner = ""

      squote_fallback = lambda do |scanner|
        scanner.skip_until(PlsqlWalker::BEGIN_SINGLE_QUOTING)
        if scanner.matched == "'"
          begin
            scanner.skip_until(/\'+/)
          end while (scanner.matched != "'" && !scanner.eos?)
        end
      end

      extract_module = lambda do |scanner|
        module_name = ""
        while !scanner.eos?
          # consume leading whitspaces
          scanner.scan(/\s*/)
          if scanner.check(/"/) == '"'
            # we have a quoted identifier
            module_name << scanner.scan(/"/)
            module_name << scanner.scan_until(/"/)
          else
            # unquoted identifier
            module_name << scanner.scan(/\S+/)
          end
          # consume trailing whitespaces
          scanner.scan(/\s*/)

          # might be a dblink
          if scanner.check(/@/) == '@' 
            module_name << scanner.scan(/@/)
            next
          end

          # might be package or a schema
          if scanner.check(/\./) == '.' 
            module_name << scanner.scan(/\./)
            next
          end
          scanner.terminate
        end
        module_name.reverse!
      end
      
      walker.register_spot(/'[\]})>]/) do |scanner|
        # pay attention, it's reveresed
        if scanner.matched =~ /\'\]/
          squote_fallback.call(scanner) unless scanner.skip_until(/\[\'q/) 
        elsif scanner.matched =~ /\'[}]/
          squote_fallback.call(scanner) unless scanner.skip_until(/[{]\'q/) 
        elsif scanner.matched =~ /\'[)]/
          squote_fallback.call(scanner) unless scanner.skip_until(/[(]\'q/) 
        elsif scanner.matched =~ /\'[>]/
          squote_fallback.call(scanner) unless scanner.skip_until(/[<]\'q/) 
        end
      end

      walker.register_spot(/[)]/) do |scanner|
        level += 1
      end

      walker.register_spot(/[(]/) do |scanner|
        if level == 0
          arg_owner = extract_module.call(scanner)
        else
          level -= 1
          scanner.terminate if level < 0 #give up, it's an invalid statement
        end
      end

      walker.walk
      return arg_owner
    end
    
    # Given the html output of a script, it extracts all tables into a nice
    # ruby array. This method returns a hash with the following meaning:
    #   :resultset => an array with resultsets from all queries which
    #                 generated the <html> output. For example, if the
    #                 html parameter contains the output of two valid
    #                 queries, the :resultset will contain:
    #
    #                 [                      # an array with all result sets 
    #                   [                    # the resultset of the first query
    #                     [val11, val12],    
    #                     [val21, val22],    
    #                     ...
    #                     [valn1, valn2]
    #                   ],
    #                   [                    # the result set of the second query
    #                     [v11, v12, v13],
    #                     [v21, v22, v23],
    #                     ...
    #                     [vn1, vn2, vn3]
    #                   ]
    #                 ]
    # If errors are detected into the output they are extracted into the
    # :errors attribute of the returining hash.
    # 
    # @param html [String] the html to be parsed
    # @return a hash with the parsed content
    def self.query_result(html, strip=true)
      nbsp = Nokogiri::HTML("&nbsp;").text
      hash = {:resultset => [], :errors => []}
      doc = Nokogiri::HTML(html)
      hash[:errors] = doc.xpath('/html/body/text()').map{ |n| n.text }.grep(/\nORA-[0-9]+/)
      doc.xpath('//table').each do |table|
        resultset = []
        table.xpath('tr').each do |tr|
          row = []
          # replace nbsp with a plain blank in order to not confuse 
          # the ragel parser, in case it's used
          tr.xpath('td').each do |td| 
            cell_val = td.text
            cell_val.strip! if strip
            row << cell_val.gsub(nbsp, " ")
          end
          resultset << row unless row.empty?
        end
        hash[:resultset] << resultset
      end
      return hash
    end

    # Prepare the provided statement for sqlplus execution. The prepare phase consists in
    # adding the right end separator according to the statement type.
    #
    # @param statement [String] the statement to be prepared
    # @return [String] the statement with the proper end separator appended
    def self.prepare_exec(statement)
      stmt = Parser.remove_trailing_comments(statement)
      type = Parser.statement_type(stmt)
      if type == 'SQLPLUS'
        # do nothing
      elsif !type.nil?
        # a plsql block. We need a trailing /
        stmt = "#{stmt.strip}\n/\n" if stmt !~ /\n\s*\/\s*\z/
      else
        # normal statement. It should have a trailing ;
        stmt = "#{stmt.strip};" if stmt !~ /(\n\s*\/|;)\s*\z/
      end
      return stmt
    end

    # Get the current statement for the provided position.
    #
    # @param script_content [String] the script within which the current statement must
    #   be detected
    # @param position [int] the absolute position within the script content for which
    #   the current statement must be found out
    # @param params [Hash] additional options. The following parameters may be
    #   provided:
    #
    #   :plsql_blocks => whenever or not to consider PL/SQL blocks when the current
    #                    statement is detected. By default is true.
    #   :sqlplus_commands => whenever or not to consider SQLPLUS commands when
    #                        trying to detect the current statement
    #
    # @return [Hash] a hash with the following keys: :statement => the current statement 
    #   which corresponds to the provided position, :range => the statement boundaries
    #   within the whole script
    def self.current_statement(script_content, position=0, params = {})
      opts = {
        :plsql_blocks => true,
        :sqlplus_commands => true
      }.merge(params)
      start_pos = 0
      end_pos = 0

      walker = PlsqlWalker.new(script_content)

      walker.register_spot(Parser::SEMI_COLON_TERMINATOR) do |scanner|
        type = Parser.statement_type(scanner.string[(start_pos..scanner.pos)])
        if type
          if opts[:plsql_blocks] && type != 'SQLPLUS'
            #this is a plsql block, eat till the slash terminator
            unless scanner.scan_until(Parser::SLASH_TERMINATOR)
              #it's an invalid statement
              scanner.terminate
            end
          end
        end
        if (start_pos..scanner.pos).include?(position)
          # include the terminator
          end_pos = scanner.pos
          scanner.terminate
        else
          start_pos = scanner.pos
        end
      end

      walker.register_spot(Parser::SLASH_TERMINATOR) do |scanner|
        if (start_pos..scanner.pos).include?(position)
          # include the terminator
          end_pos = scanner.pos
          scanner.terminate
        else
          start_pos = scanner.pos
        end
      end

      if opts[:sqlplus_commands]
        walker.register_spot(Parser::SQLPLUS_TERMINATOR) do |scanner|
          type = Parser.statement_type(scanner.string[(start_pos..scanner.pos)])
          if type
            if type == 'SQLPLUS'
              if (start_pos..scanner.pos-1).include?(position)
                end_pos = scanner.pos - scanner.matched.length
                scanner.terminate
              else
                start_pos = scanner.pos
              end
            else
              if opts[:plsql_blocks]
                #this is a plsql block, eat till the slash terminator
                if scanner.scan_until(Parser::SLASH_TERMINATOR)
                  if (start_pos..scanner.pos-1).include?(position)
                    end_pos = scanner.pos
                    scanner.terminate
                  else
                    start_pos = scanner.pos
                  end
                else
                  #it's an invalid statement
                  scanner.terminate
                end
              end
            end
          #else
            #start_pos = scanner.pos
          end
        end
      end

      walker.walk
      end_pos = script_content.length if end_pos == 0 #partial statement
      {:statement => script_content[(start_pos...end_pos)], :range => (start_pos...end_pos)}

    end

    def self.statements(script_content, params = {})
      
      statements = []
      opts = {
        :plsql_blocks => true,
        :sqlplus_commands => true
      }.merge(params)
      start_pos = 0

      walker = PlsqlWalker.new(script_content)

      walker.register_spot(Parser::SEMI_COLON_TERMINATOR) do |scanner|
        type = Parser.statement_type(scanner.string[(start_pos..scanner.pos)])
        if type
          if opts[:plsql_blocks] && type != 'SQLPLUS'
            #this is a plsql block, eat till the slash terminator
            unless scanner.scan_until(Parser::SLASH_TERMINATOR)
              #it's an invalid statement
              scanner.terminate
            end
          end
        end
        statements << script_content[(start_pos...scanner.pos)]
        start_pos = scanner.pos
      end

      walker.register_spot(Parser::SLASH_TERMINATOR) do |scanner|
        statements << script_content[(start_pos...scanner.pos)]
        start_pos = scanner.pos
      end

      if opts[:sqlplus_commands]
        walker.register_spot(Parser::SQLPLUS_TERMINATOR) do |scanner|
          type = Parser.statement_type(scanner.string[(start_pos..scanner.pos)])
          if type
            if type == 'SQLPLUS'
              statements << script_content[(start_pos...scanner.pos)]
              start_pos = scanner.pos
            else
              if opts[:plsql_blocks]
                #this is a plsql block, eat till the slash terminator
                if scanner.scan_until(Parser::SLASH_TERMINATOR)
                  statements << script_content[(start_pos...scanner.pos)]
                  start_pos = scanner.pos
                else
                  #it's an invalid statement
                  scanner.terminate
                end
              end
            end
          #else
            #start_pos = scanner.pos
          end
        end
      end

      walker.walk
      if start_pos < script_content.length
        statements << script_content[(start_pos...script_content.length)]
      end
      return statements

    end

  end

end
