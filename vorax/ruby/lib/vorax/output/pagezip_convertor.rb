# encoding: UTF-8

module Vorax
  module Output

    # A convertor used to compress every page returned by sqlplus when executing
    # a query.
    class PagezipConvertor < ZipConvertor

      # @see ZipConvertor.should_spit?
      def should_spit?(end_tag)
        ("table" == end_tag) ||
          ("th" == end_tag && rows.size > 0)
      end

    end

  end
end

