# encoding: UTF-8

module Vorax
  
  module Output

    # A convertor used to compress every HTML TABLE from the
    # sqlplus output.
    class TablezipConvertor < ZipConvertor

      # see ZipConvertor.should_spit?
      def should_spit?(current_tag)
        current_tag == "table"
      end

    end

  end

end


