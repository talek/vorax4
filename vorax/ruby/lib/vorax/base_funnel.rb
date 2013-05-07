# encoding: UTF-8

require 'nokogiri'

module Vorax

  # A funnel is an abstraction for the idea of formatting text. You
  # write some text into the funnel and then you read it formatted. It's
  # up to every subclass to implement the transformation logic.
  class BaseFunnel

    # Write the text to be converted into the funnel. By default, this
    # method does nothing, since it is intended to be overwritten by
    # subclasses.
    #
    # @param text [String] the text to be formatted.
    def write(text)
      # do nothing: subclass responsability
    end

    # Read the converted text. By default, this method does nothing. It is
    # intended to be overridden in subclasses.
    def read
      # do nothing: subclass responsability
    end

  end

end

