# encoding: UTF-8

require 'nokogiri'

module Vorax

  # A namespace for everything related to the sqlplus output processing.
  module Output

    # A special type of funnel to work with HTML convertors.
    class HTMLFunnel < BaseFunnel

      # Creates a new HTML funnel.
      #
      # @param convertor [HTMLConvertor] the convertor to be used
      #   to transform the HTML content.
      def initialize(convertor)
        @tail = ''
        @parser = Nokogiri::HTML::SAX::PushParser.new(convertor)
      end

      # Put the html content into the funnel.
      #
      # @param text [String] a chunk of HTML text
      def write(text)
        if text && !text.empty?
          @parser.write text
          if @parser.document.should_spit_text?
            @tail << text
            # just to be sure we don't have stale text after
            # the last end tag
            ping
          end
        end
      end

      # Get the formatted text from the funnel, as it is transformed
      # by the buddy convertor.
      #
      # @return the formatted text
      def read
        @parser.document.io.rewind
        chunk = @parser.document.io.read
        @parser.document.io.truncate(0)
        @parser.document.io.seek(0)
        return chunk
      end

      private

      # This is a workaround. The Nokogiri pull parser doesn't spit anything
      # if there's no endding tag. For example, if "<p>Text" is given, "Text" will not
      # be spit because the end "</p>" is missing. In sqlplus this is common
      # especially for "prompt" or "accept" commands which spit output without
      # enclosing the text in any tags. The main problem is ACCEPT, where VoraX
      # will wait for users input, but the prompt will not be shown which will 
      # make the poor user confused. The solution is to force a random tag into
      # the HTML input stream so that the parser to move along.
      def ping
        unless @tail.empty?
          # be carefull not to ping into incomplete tags
          last_open_tag_position = (@tail.rindex('<') || -1)
          last_close_tag_position = (@tail.rindex('>') || -1)
          last_open_entity_position = (@tail.rindex('&') || -1)
          last_close_entity_position = (@tail.rindex(';') || -1)
          hwm = [last_close_tag_position, last_close_entity_position].max
          @tail = @tail[hwm + 1 .. -1] if hwm >= 0
          if last_close_tag_position >= last_open_tag_position && 
             last_close_entity_position >= last_open_entity_position
            @parser << "<#{HTMLConvertor.ping_tag}/>" 
          end
        end
      end

    end

  end 

end
