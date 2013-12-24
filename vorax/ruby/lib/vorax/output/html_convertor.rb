# encoding: UTF-8

module Vorax
  module Output

    # An abstraction for converting an XML/HTML to something else. The idea is that
    # sqlplus may be configured to spit HTML output so that we can easily parse
    # it and transform it to something else. The io attribute is the pipe used to
    # push HTML content and fetch the formatted text.
    class HTMLConvertor < Nokogiri::XML::SAX::Document

      attr_reader :io, :text

      # Creates a new convertor.
      def initialize()
        super()
        @io = StringIO.new("")
        @tags_chain = []
        @text = ''
      end

      # This callback must be defined in every subclass. It is
      # invoked as soon as a new tag is detected.
      #
      # @param name [String] the detected tag name
      # @param attrs [Array] an array with all defined attributes for
      #   the detected tag.
      def start_hook name, attrs = []
        # this should be implemented in sub-classes
      end

      # This callback must be defined in every subclass. It is
      # invoked as soon as a end tag definition is detected.
      #
      # @param name [String] the name of the endding tag
      def end_hook name
        # this should be implemented in sub-classes
      end

      # Indent every line from the provided text with the given pad
      # size.
      #
      # @param text [String] the multiline text to be indented
      # @param pad_size [int] the padding size
      #
      # @return the indented text
      def self.ml_indent(text, pad_size)
        text.gsub(/\r?\n/, "\n#{' '*pad_size}")
      end

      # Get the N-th line from the provided multiline text.
      #
      # @param text [String] the multiline text
      # @param lineno [int] the line number
      # @return the N-th line
      def self.ml_segment(text, lineno)
        text.split(/\r?\n/)[lineno] || ""
      end

      # Get the size of the largest line from a multiline text.
      #
      # @param text [String] the multiline text.
      # @return the size of the largest line
      def self.ml_width(text)
        text.split(/\r?\n/).inject(0) { |counter, elem| [elem.length, counter].max }
      end

      # Get the number of lines from a multiline text.
      #
      # @param text [String] the multiline text.
      # @return the number of lines
      def self.ml_count(text)
        text.scan(/\r?\n/).size
      end

      # Get the HTML tag to be used to ping the Nokogiri parser.
      # @return the ping tag
      def self.ping_tag
        "s"
      end

      # Whenever or not the convertor should spit plain text which is directly
      # under <body> tag.
      def should_spit_text?
        @tags_chain.size > 0 && 
          #(not @text.empty?) &&
          ["body", "p", "br", "b", HTMLConvertor.ping_tag].include?(@tags_chain.last[:name])
      end

      # The text accumulated within the current tag. This is automatically
      # called from the Nokogiri engine.
      def characters(str)
        @text << str if str && !str.empty?
      end

      private

      def start_element name, attrs = []
        @tags_chain.push({:name => name.downcase, :attrs => attrs})
        if should_spit_text?
          chunk = @text
          #chunk.strip! unless @tags_chain.last[:name] == 'pre'
          chunk.gsub!(/^(\r\n?|\n)|(\r\n?|\n)$/, '') unless @tags_chain.last[:name] == 'pre'
          @io << chunk unless chunk.empty?
          @text.clear
        end
        start_hook(name, attrs)
      end

      def end_element name
        @io << @text if name == 'pre'
        @io << @text.strip if name == 'b'
        end_hook(name.downcase)
        @tags_chain.pop
      end

    end

  end
end
