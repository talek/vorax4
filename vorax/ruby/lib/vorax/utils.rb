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

  end

end
