%%{

machine column;

action expr_start {
  expr = Parser.walk_balanced_paren(data[(p..-1)])
  p += expr.length
  te = p
}

include common "common.rl";

# a bracket expression
expression = '(' >expr_start;

# means of a column
star = '*';
plain_column = identifier | star;
column_with_ref = identifier '.' plain_column;
column_with_owner = identifier '.' identifier '.' plain_column;
column_spot = (column_with_owner | column_with_ref | plain_column) ws* ',';

main := |*
  squoted_string;
  dquoted_string;
  comment;
  expression;
  column_spot => { @columns << data[(ts..te)].gsub(/\s*,\s*$/, '') };
  any => {};
*|;

}%%

module Vorax

  module Parser

    # An abstraction for SQL columns.
    class Column

      # Given a statement, it walks it in search for a column list. If the statement
      # contains more than one query, the first defined list is returned.
      #
      # @param data the statement to be walked
      # @return the string with the column list
      def walk(data)
        @columns = []
        if data
          data << ","
          eof = data.length
          %% write data;
          %% write init;
          %% write exec;
          data.chop!
        end
        return @columns
      end

    end

  end

end

