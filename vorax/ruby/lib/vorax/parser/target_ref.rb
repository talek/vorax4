# encoding: UTF-8

module Vorax

  module Parser

    # An abstraction for a table reference within an SQL statement. This class is used
    # by the StmtInspector to model the FROM clause of a query or the target table of
    # an INSERT or UPDATE.
    class TableRef

      attr_reader :base, :pointer

      # Creates a new TableRef object.
      #
      # @param base [String] is the actual table/view name from the SQL statement.
      # @param pointer [String] is the alias of the table, if there's any
      def initialize(base, pointer = nil)
        @base = base
        @pointer = pointer
      end

      # Return the columns of this table ref.
      #
      # @return the columns of the table, in an unexpanded form (e.g. tbl.*)
      def columns
        ["#{@base}.*"]
      end

      # Compare too table ref objects.
      #
      # param obj [TableRef] the other tableref used for comparison.
      def ==(obj)
        self.base == obj.base && self.pointer == obj.pointer
      end

    end

    # This class is used to model a reference within a SQL statement, given as an
    # expression (e.g. "select * from (select * from dual);")
    class ExprRef

      attr_reader :base, :range, :pointer

      # Creates a new ExprRef object.
      #
      # @param base [String] the actual expresion
      # @param range [Range] the bounderies of this expression within the parent statement
      # @param pointer [String] the alias of the expresion, if there is any
      def initialize(base, range, pointer = nil)
        @base = base
        @range = range
        @pointer = pointer
      end

      # Get all columns for this expression.
      #
      # @return all columns of the query expression
      def columns
        collect = []
        recursive_columns(@base, collect)
      end
      
      # Compare too table ref objects.
      #
      # param obj [TableRef] the other tableref used for comparison.
      def ==(obj)
        self.base == obj.base && self.range == obj.range && self.pointer == obj.pointer
      end

      private

      def recursive_columns(statement, collect)
        inspector = StmtInspector.new(statement)
        columns_data = inspector.query_fields
        columns_data.each do |column|
          if column =~ /([a-z0-9#$\_]+\.)?\*/i
            #might be an alias
            alias_name = column[/[a-z0-9#$\_]+/i]
            ds = []
            if alias_name
              src = inspector.data_source.find do |r| 
                (r.pointer && r.pointer.upcase == alias_name.upcase) || (r.base.upcase == alias_name.upcase)
              end
              ds << src if src
            elsif column == '*'
              ds = inspector.data_source
            end
            if ds.size > 0
              ds.each do |source|
                if source.respond_to?(:range)
                  recursive_columns(source.base, collect)
                else
                  collect << "#{source.base}.*"
                end
              end
            end
          else
            collect << column
          end
        end
        return collect
      end

    end

  end

end

