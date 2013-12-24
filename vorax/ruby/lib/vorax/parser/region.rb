require 'securerandom'

module Vorax

  module Parser

    # Abstraction over a code region. A region is the basic component
    # of a PlsqlStructure and it's usually up to the PlsqlStructure
    # object to create these regions.
    #
    # @see Parser::PlsqlStructure
    class Region

      # @return [Integer] The start position of the region
      attr_accessor :start_pos

      # @return [Integer] The end position of the region
      attr_accessor :end_pos

      # @return [String] The unique ID of the region
      attr_reader :id
      
      # @return [Parser::PlsqlStructure] the PLSQL structure this region belongs to
      attr_reader :structure

      # Creates a new code region.
      # @param structure [PlsqlStructure] the code structure
      # @param params [Hash] the attributes describing the region. The valid
      #   attributes are: :name, :start_pos, :end_pos
      #
      # @example
      #   region = Parser::Region.new(structure, :start_pos => 10, :end_pos => 100)
      def initialize(structure, params = {})
        @structure = structure
        opts = {
          :name => '',
          :start_pos => 0,
          :end_pos => @structure.code.length
        }.merge(params)
        @name = opts[:name]
        @start_pos = opts[:start_pos]
        @end_pos = opts[:end_pos]
        @node = nil
        @id = "#{self.class.name.split(/::/).last || ''} - #{SecureRandom.uuid}"
      end

      # @return The text code of the region.
      def text
        @structure.code[(@start_pos-1..@end_pos)]
      end

      def to_s
        "#{self.class.name.split(/::/).last || ''}: #{to_hash.inspect}"
      end

      # @return [Hash] The region representation as a hash.
      def to_hash
        {:start_pos => start_pos, :end_pos => end_pos}
      end

      def ==(obj)
        self.start_pos.to_s == obj.start_pos.to_s &&
          self.end_pos.to_s == obj.end_pos.to_s
      end

      # Get the corresponding Tree::TreeNode which wraps the
      # current region.
      # @return [Tree::TreeNode] the treenode to which this region is
      #   attached to
      def node
        if @node
          @node
        else
          structure.regions.breadth_each do |node|
            @node = node[self.id]
            break if @node
          end
          @node
        end
      end

    end

    class NamedRegion < Region
      
      # @return [String] The name of the region
      attr_reader :name
      
      # @return the position where the name of the composite is found
      attr_accessor :name_pos

      def initialize(structure, params={})
        super(structure, params)
        @name = params[:name] if params[:name]
        @name_pos = params[:name_pos] if params[:name_pos]
      end

      def to_hash
        super.tap do |h| 
          h[:name] = name
          h[:name_pos] = name_pos
        end
      end

      def ==(obj)
        super && self.name.to_s == obj.name.to_s && 
          self.name_pos == obj.name_pos
      end
      
    end

    # A composite PLSQL region which maps to a package spec, package body or
    # a type body.
    class CompositeRegion < NamedRegion

      # @return the position where the signature of the spec region ends. This
      #   is typically the position right after (AS|IS) marker
      attr_accessor :signature_end_pos

      # @return the position where the composite region encounters the END marker.
      #   This info is important in order to extract just the content of the
      #   composite region.
      attr_accessor :declare_end_pos

      # Creates a new SpecRegion which corresponds to a PLSQL package
      # specification.
      #
      # @see Parser::Region
      # @note besides the parameters available for the Region object, in
      #   addition for a SpecRegion you may provide the :signature_end_pos
      #   which corresponds to the absolute position where the signature of
      #   the package spec ends, which is the position right after(AS|IS)
      #   marker. Likewise, the :declare_end_pos may be provided.
      def initialize(structure, params={})
        super(structure, params)
        @signature_end_pos = params[:signature_end_pos] if params[:signature_end_pos]
        @declare_end_pos = params[:declare_end_pos] if params[:declare_end_pos]
        @name_pos = params[:name_pos] if params[:name_pos]
      end

      # @see Parser::Region#to_hash
      def to_hash
        super.tap do |h| 
          h[:signature_end_pos] = signature_end_pos
          h[:declare_end_pos] = declare_end_pos
          h[:name_pos] = name_pos
        end
      end

      def ==(obj)
        super && self.signature_end_pos.to_s == obj.signature_end_pos.to_s && 
          self.declare_end_pos.to_s == obj.declare_end_pos.to_s &&
          self.name_pos.to_s == obj.name_pos.to_s
      end
      
    end

    # A spec region: type or package
    class SpecRegion < CompositeRegion
    end

    # A type spec regio.
    class TypeSpecRegion < SpecRegion
    end


    # A PLSQL spec region. This applies to packages or types specifications.
    class PackageSpecRegion < SpecRegion

      # @return [Array<Parser::DeclareItem>] an array of declared items: global variables, functions, types etc.
      def declared_items
        if @items
          return @items
        else
          if self.signature_end_pos
            self.declare_end_pos = self.end_pos unless self.declare_end_pos
            content = structure.code[(self.signature_end_pos..self.declare_end_pos)]
            @items = Parser::Declare.new(content).items
            @items.each do |i| 
              i.declared_at += signature_end_pos
              i.global_in = self.name
            end
          end
          return @items
        end
      end

    end

    # A PLSQL package body region.
    class PackageBodyRegion < CompositeRegion

      # @return [Array<Parser::DeclareItem>] an array of declared items: global variables, functions, types etc.
      def declared_items
        if @items
          return @items
        else
          @items = []
          content = structure.code
          start_pointer = signature_end_pos
          node.children.each do |child|
            subregion = child.content 
            if subregion && subregion.kind_of?(SubprogRegion)
              if subregion.text =~ /^function/i
                item = FunctionItem.new(subregion.name_pos, subregion.text, false)
                item.name = subregion.name
                @items << item
              elsif subregion.text =~ /^procedure/i
                item = ProcedureItem.new(subregion.name_pos, subregion.text, false)
                item.name = subregion.name
                @items << item
              end
              declare_section = content[start_pointer...subregion.start_pos-1]
              named_items = Parser::Declare.new(declare_section).items
              named_items.each { |i| i.declared_at += start_pointer }
              @items.push(*named_items)
              start_pointer = subregion.end_pos
            end
          end
          stop_position = self.declare_end_pos ? self.declare_end_pos - 1 : content.length
          declare_section = content[start_pointer...stop_position]
          unless declare_section.empty?
            # find the first "begin" keyword
            walker = PlsqlWalker.new(declare_section)
            walker.register_spot(/\bbegin\b/i) do |scanner|
              begin_pos = scanner.pos - scanner.matched.length
              declare_section = declare_section[0...begin_pos]
              scanner.terminate
            end
            walker.walk
            named_items = Parser::Declare.new(declare_section).items
            named_items.each { |i| i.declared_at += start_pointer }
            @items.push(*named_items)
          end
          return @items
        end
      end

    end

    # A PLSQL type body region.
    class TypeBodyRegion < CompositeRegion
    end

    # A PLSQL subprogram region: function or procedure.
    class SubprogRegion < NamedRegion

      # @return [Integer] the absolute position within the entire code where
      #   the body of the subprogram begins
      attr_accessor :body_start_pos
      
      def initialize(structure, params={})
        super(structure, params)
        @metadata = nil
        @body_start_pos = @end_pos
        @body_start_pos = params[:body_start_pos] if params[:body_start_pos]
        @declare_items = nil
      end

      # @return [Parser::SubprogItem] the descriptor of this subprogram region,
      #   describing module name, parameters etc.
      #
      # @see Parser::SubprogItem
      def metadata
        @metadata || @metadata = SubprogItem.new(start_pos, text)
      end

      # @return [Array<Parser::DeclareItem>] an array of declared items: variables, local functions, types etc.
      def declared_items
        if @items
          return @items
        else
          @items = []
          content = structure.code

          # describe current subprog
          metadata = SubprogItem.new(start_pos, text)
          if metadata.declare_start_pos
            start_pointer = start_pos + metadata.declare_start_pos - 1

            node.children.each do |child|
              subregion = child.content 
              if subregion && subregion.kind_of?(SubprogRegion)
                if subregion.text =~ /^function/i
                  item = FunctionItem.new(subregion.name_pos, subregion.text, false)
                  item.name = subregion.name
                  @items << item
                elsif subregion.text =~ /^procedure/i
                  item = ProcedureItem.new(subregion.name_pos, subregion.text, false)
                  item.name = subregion.name
                  @items << item
                end
                declare_section = content[start_pointer...subregion.start_pos-1]
                named_items = Parser::Declare.new(declare_section).items
                named_items.each { |i| i.declared_at += start_pointer }
                @items.push(*named_items)
                start_pointer = subregion.end_pos
              end
            end
            declare_section = content[start_pointer...body_start_pos-1]
            named_items = Parser::Declare.new(declare_section).items
            named_items.each { |i| i.declared_at += start_pointer }
            @items.push(*named_items)

            # adjust the offset of the declared parameters
            args = metadata.args.each { |arg| arg.declared_at += start_pos }
            @items.push(*args)
          end

          return @items
        end
      end

      def declared_items_old
        if @items
          return @items
        else
          content = structure.code
          @items = []

          # describe current subprog
          metadata = SubprogItem.new(start_pos, text)

          # adjust the offset of the declared parameters
          args = metadata.args.each { |arg| arg.declared_at += start_pos }


          # blank the local subprograms
          node.children.each do |child|
            subregion = child.content 
            if subregion && subregion.kind_of?(SubprogRegion)
              probe_data = SubprogRegion.probe(subregion.text)
              if probe_data[:kind] == :function
                @items << FunctionItem.new(subregion.start_pos, subregion.text)
              elsif probe_data[:kind] == :procedure
                @items << ProcedureItem.new(subregion.start_pos, subregion.text)
              end
              region_length = subregion.end_pos - (subregion.start_pos - 1) + 1
              content[subregion.start_pos-1..subregion.end_pos] = ' ' * region_length
            end
          end
          
          # extract the declare section
          if metadata.declare_start_pos
            region_start_declare_pos = start_pos + metadata.declare_start_pos - 1
            declare_text = content[region_start_declare_pos ... body_start_pos-1]

            local_items = Parser::Declare.new(declare_text).items
            local_items.each { |i| i.declared_at += region_start_declare_pos}
            @items.push(*local_items)
          end

          @items.push(*args)

          return @items
        end
      end

      # @see Parser::Region#to_hash
      def to_hash
        super.tap do |h| 
          h[:body_start_pos] = body_start_pos
        end
      end

      def ==(obj)
        super && self.body_start_pos.to_s == obj.body_start_pos.to_s
      end

    end

    # An anonymous block region.
    class AnonymousRegion < Region
    end
    
    # An anonymous block region with a declare section.
    class DeclareRegion < AnonymousRegion
      
      # @return [Integer] the absolute position within the entire code where
      #   the body of the subprogram begins
      attr_accessor :body_start_pos

      def declared_items
        if @items
          return @items
        else
          @items = []
          content = structure.code

          # describe current subprog
          start_pointer = start_pos + 'DECLARE'.length - 1

          add_items_from_section = lambda do
            if body_start_pos
              declare_section = content[start_pointer...body_start_pos-1]
              named_items = Parser::Declare.new(declare_section).items
              named_items.each { |i| i.declared_at += start_pointer }
              @items.push(*named_items)
            end
          end

          node.children.each do |child|
            subregion = child.content 
            if subregion && subregion.kind_of?(SubprogRegion)
              if subregion.text =~ /^function/i
                item = FunctionItem.new(subregion.name_pos, subregion.text, false)
                item.name = subregion.name
                @items << item
              elsif subregion.text =~ /^procedure/i
                item = ProcedureItem.new(subregion.name_pos, subregion.text, false)
                item.name = subregion.name
                @items << item
              end
              declare_section = content[start_pointer...subregion.start_pos-1]
              named_items = Parser::Declare.new(declare_section).items
              named_items.each { |i| i.declared_at += start_pointer }
              @items.push(*named_items)
              start_pointer = subregion.end_pos
            end

            add_items_from_section.call

          end

          add_items_from_section.call

          return @items
        end
      end
      
      # @see Parser::Region#to_hash
      def to_hash
        super.tap do |h| 
          h[:body_start_pos] = body_start_pos
        end
      end

    end

    # A FOR..LOOP block region.
    class ForRegion < Region

      # @return the local variable name of the FOR..LOOP
      attr_accessor :variable

      # @return the absolute position of the FOR variable
      attr_accessor :variable_position

      # @return the domain of the FOR variable
      attr_accessor :domain

      # @return the type of the domain for which the local FOR variable is defined. The
      #   valid values are: :expr, :cursor and :counter
      attr_accessor :domain_type

      def initialize(structure, params={})
        super(structure, params)
        @variable = params[:variable] if params[:variable]
        @domain = params[:domain] if params[:domain]
        @domain_type = params[:domain_type] if params[:domain_type]
        @variable_position = params[:variable_position] if params[:variable_position]
      end

      def ==(obj)
        super && self.variable.to_s == obj.variable.to_s && 
          self.domain.to_s == obj.domain.to_s && 
          self.domain_type == obj.domain_type &&
          self.variable_position.to_s == obj.variable_position.to_s
      end

      # @see Parser::Region#to_hash
      def to_hash
        super.tap do |h| 
          h[:variable] = variable
          h[:domain] = domain
          h[:domain_type] = domain_type
          h[:variable_position] = variable_position
        end
      end
      
    end

    # A LOOP..END LOOP code region.
    class LoopRegion < Region
    end

    # An IF code region.
    class IfRegion < Region
    end

  end

end
