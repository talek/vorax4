module Vorax

  module Parser

    # A generic declared item. Usually it's about an element in the
    # declare part of a code region.
    class DeclareItem

      # @return the absolute position where the item declaration begins
      attr_accessor :declared_at

      attr_accessor :global_in

      # Create a new declared item.
      #
      # @param declared_at [Integer] the absolute position where the
      #   item is declared
      def initialize(declared_at, global_in = nil)
        @declared_at = declared_at
        @global_in = nil
      end

      def to_s
        "#{item_type}: #{to_hash.inspect}"
      end

      # @return [Hash] the hash representation of this object
      def to_hash
        {:item_type => item_type, 
         :declared_at => declared_at,
         :global_in => global_in
        }
      end

      # @return [String] the item type which consists of the
      #   name of the class (without the leading module)
      def item_type
        self.class.name.split(/::/).last || ''
      end

      def ==(obj)
        self.declared_at == obj.declared_at
      end

    end

    # A variable item.
    class VariableItem < DeclareItem

      # @return the name of the variable
      attr_reader :name

      # @return the type of the variable
      attr_reader :vartype

      # Creates a new variable items.
      #
      # @param declared_at [Integer] the absolute position where the variable is declared
      # @param name [String] the name of the variable
      # @param type [String] the type of the variable
      def initialize(declared_at, name, type)
        super(declared_at)
        @name = name
        @vartype = type
      end

      def ==(obj)
        super && self.name == obj.name && self.vartype == obj.vartype
      end

      def to_hash
        super.tap do |h| 
          h[:name] = name
          h[:vartype] = vartype
        end
      end

    end

    # A constant declared item.
    class ConstantItem < VariableItem
    end

    # An exception declared item.
    class ExceptionItem < DeclareItem

      # @return the name of the exception
      attr_reader :name

      # Creates a new exception item.
      #
      # @param declared_at [Integer] the absolute position where the variable is declared
      # @param name [String] the name of the exception
      def initialize(declared_at, name)
        super(declared_at)
        @name = name
      end

      def ==(obj)
        super && self.name == obj.name
      end

      def to_hash
        super.tap do |h| 
          h[:name] = name
        end
      end

    end

    # A type declared item.
    class TypeItem < DeclareItem

      # @return [String] the name of the type
      attr_reader :name

      # @return [String] the type declaration as text
      attr_reader :text

      # @return [String] the underlying base type of the type (e.g. object, record etc.)
      attr_accessor :is_a

      # Creates a new type item.
      #
      # @param declared_at [Integer] the absolute position where the variable is declared
      # @param name [String] the name of the type
      # @param is_a [String] the underlying base type
      # @param text [String] the declare part as text
      def initialize(declared_at, name, is_a, text)
        super(declared_at)
        @name =name
        @is_a = is_a
        @text = text
      end

      def to_hash
        super.tap do |h| 
          h[:name] = name
          h[:is_a] = is_a
          h[:text] = text
        end
      end

      def ==(obj)
        super && self.name == obj.name && self.is_a == obj.is_a
      end
      
    end

    # A subtype item.
    class SubtypeItem < TypeItem
    end

    # A cursor definition.
    class CursorItem < DeclareItem

      # @return [String] the name of the cursor
      attr_reader :name

      # @return [String] the definition of the cursor as text
      attr_reader :text
      
      # @return [String] the query behind the cursor
      attr_reader :query

      # Creates a new cursor item.
      #
      # @param declared_at [Integer] the absolute position where the variable is declared
      # @param name [String] the name of the type
      # @param text [String] the definition of the cursor as text
      def initialize(declared_at, name, text)
        super(declared_at)
        @name = name
        @text = text
        @query = /\bis\b(.*)\z/mi.match(@text)[1]
      end

      def ==(obj)
        super && self.name == obj.name && self.text == obj.text
      end

      def to_hash
        super.tap do |h| 
          h[:name] = name
          h[:text] = text
          h[:query] = query
        end
      end

    end

    # A subprogram definition item.
    class SubprogItem < DeclareItem

      # @return [Array<ArgumentItem>] a list of arguments defined for this subprogram
      attr_reader :args

      # @return [String] the name of the subprogram
      attr_accessor :name
      
      # @return [String] the kind of the subprogram: "procedure" or "function"
      attr_reader :kind
      
      # @return [String] the returned type of the subprogram in case of functions
      # @return nil when there's no return type defined (e.g. procedures)
      attr_reader :return_type
      
      # @return [String] the declare part as text
      attr_reader :text

      attr_reader :declare_start_pos

      # Creates a new subprogram item.
      #
      # @param declared_at [Integer] the absolute position where the variable is declared
      # @param text [String] the definition of the subprogram as text
      def initialize(declared_at, text, describe=true)
        super(declared_at)
        @text = text
        @args = []
        if describe
          SubprogItem.describe(text).tap do |m|
            @name = m[:name]
            @kind = m[:kind]
            @args = m[:args]
            @return_type = m[:return_type]
            @declare_start_pos = m[:declare_start_pos]
          end
        end
      end

      def to_hash
        super.tap do |h| 
          h[:args] = args.map { |a| a.to_hash }
          h[:name] = name
          h[:kind] = kind
          h[:return_type] = return_type
          h[:text] = text
          h[:declare_start_pos] = declare_start_pos
        end
      end

      def ==(obj)
        self.name.to_s == obj.name.to_s #&& self.args == obj.args &&
          #self.kind.to_s == obj.kind.to_s && self.declare_start_pos == obj.declare_start_pos
      end

    end

    # A function declared item.
    class FunctionItem < SubprogItem
    end

    # A procedure declared item.
    class ProcedureItem < SubprogItem
    end

    # An argument item.
    class ArgumentItem < DeclareItem

      # @return [Symbol] the direction of the parameter: :in, :out, :inout
      attr_accessor :direction

      # @return [Boolean] whenever or not the argument has a default value
      attr_accessor :has_default
      
      # @return [String] the type of the parameter
      attr_accessor :data_type
      
      # @return [String] the name of the parameter
      attr_accessor :name

      # Creates a new argument item.
      #
      # @param declared_at [Integer] the absolute position where the variable is declared
      # @param name [String] the name of the argument
      # @param params [Hash] additional parameters. The valid attributes are: :direction,
      #   :has_default and :data_type
      def initialize(declared_at, name, params={})
        super(declared_at)
        @name = name
        opts = {
          :direction => :in,
          :has_default => false,
          :data_type => nil
        }.merge(params)
        @direction = opts[:direction]
        @has_default = opts[:has_default]
        @data_type = opts[:data_type]
      end

      def to_hash
        super.tap do |h| 
          h[:name] = name
          h[:direction] = direction
          h[:has_default] = has_default
          h[:data_type] = data_type
        end
      end

      def ==(obj)
        super && self.name == obj.name && self.direction == obj.direction &&
          self.has_default == obj.has_default && self.data_type.to_s == obj.data_type.to_s
      end

    end

  end

end
