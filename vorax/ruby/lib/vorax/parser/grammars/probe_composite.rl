%%{

machine spec_probe;

include common "common.rl";

name = (qualified_identifier 
          - (K_CREATE | 
             K_OR | 
             K_REPLACE | 
             K_PACKAGE | 
             K_BODY | 
             K_TYPE | 
             K_AS | 
             K_IS | 
             K_AUTHID | 
             K_CURRENT_USER | 
             K_DEFINER)
       ) >{@start_id = p; @pos_name_temp = p} %{@name_temp = data[@start_id...p]};

body_start_marker = (K_AS | K_IS) %{@pointer = p; @kind = @kind_temp; @name = @name_temp; @pos_name = @pos_name_temp};

pkg_spec = create_or_replace?
            K_PACKAGE %{ @kind_temp = :package_spec } ws+ 
            name ws+ 
            auth_id? 
            body_start_marker ws+;

pkg_body = create_or_replace?
            K_PACKAGE ws+ K_BODY %{ @kind_temp = :package_body } ws+
            name ws+ 
            body_start_marker ws+;

typ_spec = create_or_replace?
            K_TYPE ws+ 
            name ws+ @{@kind = :type_spec; @name = @name_temp; @pos_name = @pos_name_temp};

typ_body = create_or_replace?
            K_TYPE ws+ K_BODY %{ @kind_temp = :type_body } ws+
            name ws+ 
            body_start_marker ws+;

probe := typ_body | pkg_body | typ_spec | pkg_spec;

}%%

module Vorax

  module Parser

    class CompositeRegion < NamedRegion

      # Tries to figure out the type of the composite region.
      # @param data [String] the PLSQL code to be checked
      # @return [Hash] with the following keys: :name => the name of the plsql object,
      #   :kind => the valid values are: :package_spec, :package_body or :type_body
      #   :pointer => where the package spec definition ends as a relative position to
      #   the string provided as parameter. This is the position right after the AS|IS
      #   mark. If the spec could not be matched the pointer is nil.
      # @example
      #   text = 'create or replace package scott.text as g_var integer; end;'
      #   p Parser::CompositeRegion.probe(text)
      def self.probe(data)
				@pos_name_temp, @pos_name, @kind, @kind_temp, @pointer, @name_temp, @name = nil
				if data
					eof = data.length
					%% write data;
					%% write init;
					%% write exec;
				end
				{:name => @name, :kind => @kind, :pointer => @pointer, :name_pos => @pos_name}
			end

    end

  end

end
