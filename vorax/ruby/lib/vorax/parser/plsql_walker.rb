# encoding: utf-8

require 'strscan'

module Vorax

  module Parser

    # A PLSQL string scanner which is looking for interesting patterns within
    # the provided source code. The idea is to walk through the provided PLSQL
    # code and to respond to some registered interesting spots, provided as 
    # simple regular expressions.
    #
    # This approach is used instead of a fully fledged parser especially for 
    # speed considerations.
    #
    # == Examples
    # 
    # Find the position of the first semicolon which is not part of a comment
    # or a literal:
    #
    #   walker = PlsqlWalker.new(plsql_code)
    #   walker.register_spot(/;/) do |scanner|
    #     puts "Position: #{scanner.pos}"
    #     scanner.terminate
    #   end
    #   walker.walk
    #
    # Find the position of the first double quote:
    #
    #   walker = PlsqlWalker.new(plsql_code, false)
    #   walker.register_spot(/"/) do |scanner|
    #     puts "Position: #{scanner.pos}"
    #     scanner.terminate
    #   end
    #   walker.walk
    class PlsqlWalker

      BEGIN_ML_COMMENT = /\/\*/ unless defined?(BEGIN_ML_COMMENT)
      END_ML_COMMENT = /\*\// unless defined?(END_ML_COMMENT)
      BEGIN_SL_COMMENT = /--/ unless defined?(BEGIN_SL_COMMENT)
      END_SL_COMMENT = Parser::END_LINE unless defined?(END_SL_COMMENT)
      BEGIN_PLSQL_SPECIAL_QUOTING = /q'[!\[{(<]/ unless defined?(BEGIN_PLSQL_SPECIAL_QUOTING)
      BEGIN_DOUBLE_QUOTING = /[\"]/ unless defined?(BEGIN_DOUBLE_QUOTING)
      BEGIN_SINGLE_QUOTING = /[']/ unless defined?(BEGIN_SINGLE_QUOTING)

      # Create a new PLSQL scan walker.
      #
      # @param text [String] the text to be walked/parsed
      # @param create_default_spots [Boolean] whenever or not to create default 
      #  detection spots. These spots are: comments and literals.
      def initialize(text, create_default_spots=true)
        @text = text
        @matchers = []
        @ss = StringScanner.new(text)
        create_default_spots() if create_default_spots
      end

      # Returns the string scanner used for walking the string.
      #
      # @return [StringScanner] the string scanner
      def scanner
        @ss
      end

      # Register a new detection spot.
      #
      # @param pattern [Regexp] the regular expression defining the interesting spot
      # @param callback [Procedure] what to do when this spot is detected. The registered
      #   block is always called with the string scanner object. Please do not use "return"
      #   to exit from the defined block.
      # @yield the scanner
      def register_spot(pattern, &callback)
        @matchers << {:pattern => pattern, :callback => callback}
      end

      # Walk the plsql code and trigger the registered callbacks.
      def walk
        global_matcher = Regexp.new(@matchers.map { |e| e[:pattern].to_s }.join('|'), 
                                    Regexp::IGNORECASE)
        while !@ss.eos?
          if match = @ss.scan_until(global_matcher)
            current_pos = @ss.pos
            @matchers.each do |matcher|
              if @ss.matched =~ matcher[:pattern]
                matcher[:callback].call(@ss)
              end
            end
          else
            @ss.terminate
          end
        end
      end

      # Register a spot to walk a multiline comment.
      def register_default_ml_comment_spot
        register_spot(BEGIN_ML_COMMENT) do |scanner|
          scanner.scan_until(END_ML_COMMENT)
        end
      end

      # Register a spot to walk a single line comment.
      def register_default_sl_comment_spot
        register_spot(BEGIN_SL_COMMENT) do |scanner|
          scanner.scan_until(END_SL_COMMENT)
        end
      end

      # Register a spot to walk a plsql special quoting liternal.
      def register_default_plsql_quoting_spot
        register_spot(BEGIN_PLSQL_SPECIAL_QUOTING) do |scanner|
          scanner.scan_until(END_SL_COMMENT)
          if scanner.matched =~ /q'\[/
            scanner.scan_until(/\]'/) 
          elsif scanner.matched =~ /q'[{]/
            scanner.scan_until(/[}]'/) 
          elsif scanner.matched =~ /q'[(]/
            scanner.scan_until(/[)]'/) 
          elsif scanner.matched =~ /q'[<]/
            scanner.scan_until(/[>]'/) 
          end
        end
      end

      # Register a spot to walk a double quoted literal.
      def register_default_double_quoting_spot
        register_spot(BEGIN_DOUBLE_QUOTING) do |scanner|
          scanner.scan_until(/"/)
        end
      end

      # Register a spot to walk a single quoted literal.
      def register_default_single_quoting_spot
        register_spot(BEGIN_SINGLE_QUOTING) do |scanner|
          begin
            scanner.scan_until(/\'+/) 
          end while (!scanner.matched.nil? && scanner.matched != "'" && !scanner.eos?)
        end
      end


    private

      def create_default_spots
        # define a multiline comment spot
        register_default_ml_comment_spot()

        # define a single line comment spot
        register_default_sl_comment_spot()

        # define special PLSQL quotes spot
        register_default_plsql_quoting_spot()

        # register a double quoted string spot
        register_default_double_quoting_spot()
        
        # register a single quoted string spot
        register_default_single_quoting_spot()
      end

    end

  end

end
