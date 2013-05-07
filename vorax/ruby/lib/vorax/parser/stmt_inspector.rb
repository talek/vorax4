# encoding: utf-8

module Vorax

  module Parser

    # A class used to gather metadata information for an SQL statement. This is needed
    # especially for implementing VoraX code completion.
    class StmtInspector

      # Creates a new statement inspector.
      #
      # @param statement [String] the statement to be inspected
      def initialize(statement)
        @statement = statement
      end

      # Get the type of the statement
      #
      # (see Parser.statement_type)
      def type
        @type ||= Parser.statement_type(statement)
      end

      # Get all tableref/exprref for this statement, taking into account
      # the current position within that statement.
      #
      # @param position [int] the current position.
      # @return an array of TableRef/ExprRef objects
      def data_source(position=0)
        recursive_data_source(descriptor.refs, position)
      end

      # If it's a query, the corresponding columns are returned.
      #
      # @return an array of columns
      def query_fields
        @query_fields ||= Column.new.walk(descriptor.query_fields)
      end

      # Find the provided alias for the statement, taking into account the
      # current position.
      #
      # @param name [String] the alias name
      # @param position [int] the current position
      def find_alias(name, position=0)
        data_source(position).find { |r| r.pointer && r.pointer.upcase == name.upcase }
      end

      private

      def descriptor
        unless @desc
          @desc = Parser::Alias.new
          @desc.walk(@statement)
        end
        @desc
      end

      def recursive_data_source(refs, position, collect = [])
        inner = refs.find { |r| r.respond_to?(:range) && r.range.include?(position) }
        collect.unshift(refs).flatten!
        if inner
          desc = Parser::Alias.new
          desc.walk(inner.base)
          recursive_data_source(desc.refs, position - inner.range.first, collect)
        else
          return collect
        end
      end
      
    end

  end
  
end

