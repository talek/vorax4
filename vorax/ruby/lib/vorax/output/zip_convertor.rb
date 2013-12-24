# encoding: UTF-8

module Vorax

  module Output

    # A special type of HTML convertor used for compressing HTML tables. This is an
    # abstract class and every convertor which needs compressing utilities must
    # inherit from this class.
    class ZipConvertor < HTMLConvertor

      attr_reader :rows, :last_close_tag, :last_open_tag

      # Create a new ZipConvertor.
      def initialize()
        super()
        reset_props()
      end

      # @see HTMLConvertor.start_hook
      def start_hook name, attrs = []
        @io << "\n" if name == 'table' && @nl
        @last_open_tag[:name] = name
        @last_open_tag[:attrs] = attrs
      end

      # @see HTMLConvertor.end_hook
      def end_hook name
        # @nl logic: whenever or not a new table
        # will add an new line at the beginning. If a
        # br or p is already issued before, then NO! This
        # is needed when sqlplus adds extra <br>s before
        # a <table>.
        if ['br', 'p'].include?(name)
          @io << "\n" 
          @nl = false
        elsif name == "s"
          # simply ignore, it'a ping
        else
          @nl = true
        end
        @record << {:text => text.strip, 
                    :is_column => ("th" == name), 
                    :align => get_align(@last_open_tag)} if ["td", "th"].include?(name)
        if "tr" == name
          @rows << @record.dup
          @record.clear
        end
        if should_spit?(name)
          spit
          @rows.clear
        end
        #io << text if name == 'b'
        text.clear unless HTMLConvertor.ping_tag == name
        @last_close_tag.clear
        @last_close_tag << name
        reset_props() if "table" == name
      end

      # A method which tells if the accumulated compressed text should
      # be spit or not. This is the only method which must be implemented
      # into subclasses.
      #
      # @param name [String] the end HTML tag
      def should_spit?(name)
        raise RuntimeError.new "Implement me"
      end

      private

      def columns_layout
        layout = []
        (0..@rows.first.size-1).each do |i|
          width = @rows.inject(0) do |result, element| 
            [result, HTMLConvertor.ml_width(element[i][:text])].max
          end
          first_data_row = @rows.detect { |row| row[i][:is_column] == false }
          align = first_data_row[i][:align] if first_data_row
          layout << {:width => width, :align => (align && align == "right" ? "rjust" : "ljust")}
        end
        layout
      end

      def separator(layout)
        # spit separator
        layout.each_with_index do |column, i|
          @io << "-" * column[:width]
          @io << (i == layout.size - 1 ? "\n" : " ")
        end
      end

      def spit
        layout = columns_layout
        # spit records
        @rows.each do |record|
          max_height = record.inject(0) { |result, element| [result, HTMLConvertor.ml_count(element[:text])].max }
          (0..max_height).each do |j|
            layout.length.times do |i|
              @io << "\n" if record[i][:is_column] && i == 0 && @first_spit == false
              @first_spit = false
              col_value = HTMLConvertor.ml_segment(record[i][:text], j).send(layout[i][:align], layout[i][:width])
              col_value.rstrip! if i == layout.length - 1
              @io << col_value
              @io << (i == layout.size - 1 ? "\n" : " ")
              separator(layout) if i == layout.size - 1 && record[i][:is_column]
            end
          end
        end
      end

      def get_align(tag)
        attrs = tag[:attrs]
        if attrs
          align_pair = attrs.find { |pair| pair[0] == "align" }
          return align_pair[1] if align_pair
        end
      end

      def reset_props
        @record = []
        @rows = []
        @last_open_tag = {:name => '', :attrs => []}
        @last_close_tag = ''
        @first_spit = true
        @nl = true
      end

    end

  end

end


