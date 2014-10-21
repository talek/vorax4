module Vorax

  module Utils

    def self.transform_hash(original, options={}, &block)
      original.inject({}) {|result, (key,value)|
        if options[:deep] 
          if value.is_a?(Hash) 
            value = transform_hash(value, options, &block)
          elsif value.is_a?(Array)
            value = value.map { |e| transform_hash(e, options, &block) }
          end
        else 
          value
        end
        block.call(result,key,value)
        result
      }
    end

    def self.strip_xml(text)
      ret = ""
      text.each_char do |char|
        c = char.ord
        if ((c == 0x9) ||
            (c == 0xA) ||
            (c == 0xD) ||
            ((c >= 0x20) && (c <= 0xD7FF)) ||
            ((c >= 0xE000) && (c <= 0xFFFD)) ||
            ((c >= 0x10000) && (c <= 0x10FFFF)))
          ret << char
        else
          ret << 191.ord
        end
      end
      ret
    end

  end

end
