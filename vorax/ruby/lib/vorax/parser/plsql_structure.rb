# encoding: utf-8

require 'tree'

module Vorax

  module Parser

    # This class is used to determine the structure of the provided PLSQL
    # code, which implies that a tree of the coresponding code regions is built
    # up. If the PLSQL code is not valid, the computed structure might
    # look funny, but because this class is assumed to work with incomplete
    # or invalid code no error will be raised. This class may be used to
    # implement PLSQL code folding or to infer decisions as far as the
    # code completion logic is concerned.
    #
    # @note: The main limitation of this class is that it cannot detect the
    # defined interesting points if they have a leading/trailing comment right 
    # before/after the keyword (e.g function/*stupid comment*/my_func). I hope 
    # they are too unlikely to worth a much more complex implementation of 
    # this class.
    #
    # == Examples
    # 
    # Compute the structure of a PLSQL package:
    #
    #   text = File.open('test.pkg', 'rb') { |file| file.read }
    #   structure = Parser::PlsqlStructure.new(text)
    #   structure.regions.print_tree
    #   
    class PlsqlStructure

      PLSQL_CONTAINER = /(?:\bpackage\b|\btype\b)/i unless defined?(PLSQL_CONTAINER)
      SUBPROG = /(?:\boverriding\b|\bconstructor\b|\bmember\b|\bmap\b|\bstatic\b|\border\b|\bfunction\b|\bprocedure\b)/i unless defined?(SUBPROG)
      BEGIN_MARKER = /(?:\bbegin\b|\bcase\b)/i unless defined?(BEGIN_MARKER)
      END_MARKER = /(?:\bend\b)/i unless defined?(END_MARKER)
      FOR_STMT = /(?:\bfor\b)/i unless defined?(FOR_STMT)
      LOOP_STMT = /(?:\bloop\b)/i unless defined?(LOOP_STMT)
      IF_STMT = /(?:\bif\b)/i unless defined?(IF_STMT)
      DECLARE_BLOCK = /(?:\bdeclare\b)/i unless defined?(DECLARE_BLOCK)

      # @return [String] the PLSQL code on which the structure was computed
      attr_reader :code

      # Creates a new structure object for the provided PLSQL code.
      # 
      # @param code [String] the PLSQL code to be parsed
      def initialize(code)
        @code = code
        @root = Tree::TreeNode.new("root", nil)
        @walker = PlsqlWalker.new(@code)
        @level = 0
        @current_parent = @root
        @begin_level = 0
        register_spots()
        @walker.walk
      rescue Exception => e
        # be prepare for any nasting parse error.
        # Failing here is kind of usual, having in mind
        # that we often parse incomplete code.
        Vorax.debug(e.to_s)
        Vorax.debug(e.backtrace)
      end

      # Get the computed regions in a hierachical structure.
      # @return [Tree::TreeNode] the uppermost computed region along
      #   with its child regions
      def regions
        @root
      end

      # Dumps the structure of the plsql code for debug purposes.
      def dump
        dump_text = ''
        regions.each do |child|
          dump_text << '  '*child.level << "[Level: #{child.level}] " << child.content.to_s << "\n"
        end
        dump_text
      end

      # Get the region on the provided position.
      #
      # @param pos [Integer] the absolute position within the PLSQL code boundaries
      # @param kind [Parser::Region] consider only the region of this type
      #
      # @return [Parser::Region] the region corresponding to the provided position
      # @return nil if no region was detected on the provided position
      def region_at(pos, kind=nil)
        target_region = nil
        regions.breadth_each do |node|
          region = node.content
          if region
            if (region.start_pos..region.end_pos).include?(pos)
              if kind && region.kind_of?(kind)
                target_region = region
              elsif kind.nil?
                target_region = region
              end
            end
          end
        end
        return target_region
      end

    private

      def register_spots
        register_plsql_spec_spot()
        register_slash_terminator_spot()
        register_subprog_spot()
        register_declare_spot()
        register_begin_spot()
        register_for_spot()
        register_loop_spot()
        register_if_spot()
        register_end_spot()
      end

      def register_plsql_spec_spot
        @walker.register_spot(PLSQL_CONTAINER) do |scanner|
          if @level == 0
            text_code = "#{scanner.matched}#{scanner.rest}"
            probe_data = CompositeRegion.probe(text_code)
            if probe_data[:kind]
              if probe_data[:pointer]
                signature_end = scanner.pos - scanner.matched.length + probe_data[:pointer] + 1
              end
              start_pos = scanner.pos - scanner.matched.length + 1
              name_pos = start_pos + probe_data[:name_pos]
              if probe_data[:kind] == :package_spec
                region = PackageSpecRegion.new(self, 
                                            :name => probe_data[:name], 
                                            :start_pos => start_pos,
                                            :name_pos => name_pos,
                                            :signature_end_pos => signature_end)
              elsif probe_data[:kind] == :type_spec
                region = TypeSpecRegion.new(self, 
                                            :name => probe_data[:name], 
                                            :start_pos => start_pos,
                                            :name_pos => name_pos)
              elsif probe_data[:kind] == :package_body
                region = PackageBodyRegion.new(self, 
                                               :name => probe_data[:name], 
                                               :start_pos => start_pos,
                                               :name_pos => name_pos,
                                               :signature_end_pos => signature_end)
              elsif probe_data[:kind] == :type_body
                region = TypeBodyRegion.new(self, 
                                            :name => probe_data[:name], 
                                            :start_pos => start_pos,
                                            :name_pos => name_pos,
                                            :signature_end_pos => signature_end)
              end
            end
            if region
              assign_parent(@current_parent << Tree::TreeNode.new(region.id, region))
              @level += 1
            end
          end
        end
      end

      def register_slash_terminator_spot
        @walker.register_spot(Parser::SLASH_TERMINATOR) do |scanner|
          # this should apply to the last top level node
          if @root.has_children?
            if @root.children.last.content
              @root.children.last.content.end_pos = scanner.pos
            end
            assign_parent(@root)
            @level = 0
          end
        end
      end

      def register_subprog_spot
        @walker.register_spot(SUBPROG) do |scanner|
          if not on_spec?
            text_code = "#{scanner.matched}#{scanner.rest}"
            probe_data = SubprogRegion.probe(text_code)
            if probe_data[:name]
              start_pos = scanner.pos - scanner.matched.length + 1
              name_pos = start_pos + probe_data[:name_pos]
              region = SubprogRegion.new(self, 
                                         :name => probe_data[:name], 
                                         :name_pos => name_pos,
                                         :start_pos => start_pos)
              node = Tree::TreeNode.new(region.id, region)
              @current_parent << node
              @level += 1
              assign_parent(node)
              scanner.pos += probe_data[:name_pos]
            end
          end
        end
      end

      def register_declare_spot
        @walker.register_spot(DECLARE_BLOCK) do |scanner|
          region = DeclareRegion.new(self, :start_pos => scanner.pos - scanner.matched.length + 1)
          assign_parent(@current_parent << Tree::TreeNode.new(region.id, region))
        end
      end

      def register_begin_spot
        @walker.register_spot(BEGIN_MARKER) do |scanner|
          @begin_level += 1
          if @begin_level > 1 || (@current_parent && @current_parent.content.nil?)
            # start a new region
            region = AnonymousRegion.new(self, :start_pos => scanner.pos - scanner.matched.length + 1)
            @level += 1
            assign_parent(@current_parent << Tree::TreeNode.new(region.id, region))
          else
            if @current_parent && 
                @current_parent.content && has_begin_block?
              @current_parent.content.body_start_pos = scanner.pos - scanner.matched.length + 1
            end
          end
        end
      end

      def register_for_spot
        @walker.register_spot(FOR_STMT) do |scanner|
          text_code = "#{scanner.matched}#{scanner.rest}"
          probe_data = ForRegion.probe(text_code)
          if probe_data[:pointer]
            start_pos = scanner.pos - scanner.matched.length + 1
            region = ForRegion.new(self, 
                                   :start_pos => start_pos,
                                   :variable => probe_data[:variable],
                                   :variable_position => start_pos + probe_data[:variable_position],
                                   :domain => probe_data[:domain],
                                   :domain_type => probe_data[:domain_type])
            assign_parent(@current_parent << Tree::TreeNode.new(region.id, region))
            scanner.pos = start_pos + probe_data[:pointer]
            @level += 1
          end
        end
      end

      def register_loop_spot
        @walker.register_spot(LOOP_STMT) do |scanner|
          stmt = "#{scanner.matched}#{scanner.rest}"
          region = LoopRegion.new(self, :start_pos => scanner.pos - scanner.matched.length + 1)
          assign_parent(@current_parent << Tree::TreeNode.new(region.id, region))
          @level += 1
        end
      end

      def register_if_spot
        @walker.register_spot(IF_STMT) do |scanner|
          stmt = "#{scanner.matched}#{scanner.rest}"
          region = IfRegion.new(self, :start_pos => scanner.pos - scanner.matched.length + 1)
          assign_parent(@current_parent << Tree::TreeNode.new(region.id, region))
          @level += 1
        end
      end

      def register_end_spot
        @walker.register_spot(END_MARKER) do |scanner|
          # we have an "end" match. first of all check if it's not part
          # of an conditional compiling "$end" definition
          char_behind = scanner.string[scanner.pos - scanner.matched.length - 1, 1]
          if char_behind != '$'
            # not part of a conditional compiling syntax
            text_code = "#{scanner.matched}#{scanner.rest}"
            probe_data = Region.probe_end(text_code)
            if probe_data[:pointer]
              @level -= 1 if @level > 0
              end_declare = scanner.pos - 1
              end_pos = end_declare + (probe_data[:pointer] - 1)
              if probe_data[:kind] == :end
                @begin_level -= 1 if @begin_level > 0
                if @current_parent.content
                  @current_parent.content.end_pos = end_pos
                  @current_parent.content.declare_end_pos = end_declare - scanner.matched.length if on_composite?
                end
                assign_parent(@current_parent.parent)
              elsif probe_data[:kind] == :end_loop
                if on_loop? || on_for?
                  @current_parent.content.end_pos = end_pos
                  scanner.pos = @current_parent.content.end_pos
                  assign_parent(@current_parent.parent)
                else
                  # something's fishy
                  scanner.terminate
                end
              elsif probe_data[:kind] == :end_if
                if on_if?
                  @current_parent.content.end_pos = end_pos
                  scanner.pos = @current_parent.content.end_pos
                  assign_parent(@current_parent.parent)
                else
                  # something's fishy
                  scanner.terminate
                end
              end
            end
          end
        end
      end

      def current_region
        if @current_parent && @current_parent.content
          @current_parent.content
        end
      end

      def on_spec?
        current_region && current_region.kind_of?(SpecRegion)
      end

      def on_composite?
        current_region && current_region.kind_of?(CompositeRegion)
      end

      def on_subprog?
        current_region && current_region.kind_of?(SubprogRegion)
      end

      def on_for?
        current_region && current_region.kind_of?(ForRegion)
      end

      def on_loop?
        current_region && current_region.kind_of?(LoopRegion)
      end

      def on_if?
        current_region && current_region.kind_of?(IfRegion)
      end

      def on_anonymous?
        current_region && current_region.kind_of?(AnonymousRegion)
      end

      def has_begin_block?
        @current_parent.content.kind_of?(SubprogRegion) || 
          @current_parent.content.kind_of?(DeclareRegion)
      end

      def assign_parent(node)
        @current_parent = node
      end

    end

  end

end
