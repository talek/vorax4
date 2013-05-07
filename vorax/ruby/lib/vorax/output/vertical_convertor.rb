# encoding: UTF-8
module Vorax
  module Output

    class VerticalConvertor < HTMLConvertor

      def initialize()
        super()
        reset_props()
      end

      def end_element name
        super(name)
        @io << "\n" if ['br', 'p'].include?(name)
        if "th" == name and @collect_columns
          column = @text.strip
          @columns << column
          @th_length = [column.length, @th_length].max
        end
        @values << @text.strip if "td" == name
        if "tr" == name && (not @values.empty?)
          @columns = Array.new(@values.size, "") if @columns.empty?
          @columns.each_with_index do |column, i|
            value = HTMLConvertor.ml_indent(@values[i], @th_length + 3)
            @io.print("#{column.ljust(@th_length)} : #{value}\n")
          end
          @values.clear
          @collect_columns = false
          print_row_separator
        end
        @text.clear unless HTMLConvertor.ping_tag == name
        reset_props() if name == "table"
      end

      def print_row_separator
        @separator ||= '-' * 60
        @io.print("#{'-' * 60}\n")
      end

      private

      def reset_props
        @columns = []
        @values = []
        @th_length = 0
        @text = ""
        @collect_columns = true
      end

    end

  end
end
