%%{

machine alias;

action tableref_start {
  @t_start = p
}

action tableref_end {
  @table_ref = data[(@t_start..p-1)]
}

action alias_start {
  @a_start = p
  @alias_value = nil
}

action alias_end {
  text = data[(@a_start..p-1)]
  @alias_value = text unless @not_alias.include?(text.upcase)
}

action subquery_start {
  @subquery_text = Parser.walk_balanced_paren(data[(p..-1)]).gsub(/^\(|\)$/, '')
  p += 1
  @subquery_range = (p..p+@subquery_text.length-1)
  p += @subquery_text.length
  te = p
}

action before_with {
  @alias_value = nil
  @subquery_range = nil
  @subquery_text = nil
}

action after_with {
  @refs << ExprRef.new(@subquery_text, @subquery_range, @alias_value)
  @alias_value = nil
  @subquery_range = nil
  @subquery_text = nil
}

action before_tref {
  add_tableref
}

include common "common.rl";

# interesting spots
plain_table_ref = ((identifier '.')? identifier ('@' identifier)?) >tableref_start %tableref_end;
alias = identifier >alias_start %alias_end;
extract = K_EXTRACT ws* '(' ws* (K_SECOND | 
                                 K_MINUTE | 
                                 K_HOUR |
                                 K_YEAR |
                                 K_MONTH |
                                 K_DAY |
                                 K_TIMEZONE_HOUR |
                                 K_TIMEZONE_MINUTE |
                                 K_TIMEZONE_REGION |
                                 K_TIMEZONE_ABBR) ws+ K_FROM ws+;

sub_query = '(' >subquery_start;
table_reference = ((plain_table_ref | sub_query) (ws+ alias)?) >before_tref;
from_spot = ws+ K_FROM ws+ table_reference (ws* ',' ws* table_reference)*;
with_reference = (alias ws+ K_AS ws* sub_query) >before_with %after_with;
with_spot = K_WITH ws+ with_reference (ws* ',' ws* with_reference)*;
join_spot = ws+ K_JOIN ws+ table_reference;
start_select = K_SELECT ws+;

main := |*
  squoted_string;
  dquoted_string;
  comment;
  start_select => { @start_columns = te };
  extract;
  from_spot => { @columns = data[(@start_columns..ts)] unless @columns };
  with_spot;
  join_spot;
  any => {};
*|;

}%%

module Vorax

  module Parser

    # An abstraction for an alias within a SQL statement.
    class Alias

      def initialize        
        @not_alias = ['ON', 'WHERE', 'FROM', 'CONNECT', 'START', 
                      'GROUP', 'HAVING', 'MODEL']
      end

      # Walks the provided statement searching for alias references.
      #
      # @param data the statement
      def walk(data)
        @refs = [];
        @start_columns = 0
        @columns = nil;
        data << "\n"
        eof = data.length
        %% write data;
        %% write init;
        %% write exec;
        data.chop!

        # needed to finalize the last pending tableref
        add_tableref
      end

      # Get all identified tableref/exprref references. This method
      # should be called after walk.
      #
      # @return an array of references
      def refs
        @refs
      end

      # A string containing the column list, if there's any.
      #
      # @return a string with all defined columns
      def query_fields
        @columns
      end

      private 
      
      def add_tableref
        if (not @table_ref.nil?)
          @refs << TableRef.new(@table_ref, @alias_value)
        elsif (not @subquery_text.nil?)
          @refs << ExprRef.new(@subquery_text, 
                               @subquery_range, 
                               @alias_value)
        end
        @alias_value = nil
        @table_ref = nil
      end

    end

  end

end

