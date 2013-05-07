%%{

machine probe_subprog;

include common "common.rl";

keywords = K_CREATE | K_OR | K_REPLACE | K_PACKAGE | K_BODY | K_TYPE | K_AS | 
						K_IS | K_AUTHID | K_CURRENT_USER | K_PROCEDURE | K_FUNCTION | K_BEGIN |
						K_END | K_DEFINER | K_OVERRIDING;
name = (qualified_identifier - keywords) >{@start_id = p; @temp_name_pos = p} %{@name_temp = data[@start_id...p]};

subprog := create_or_replace? (K_OVERRIDING ws+)?
            ((K_MAP | K_ORDER) ws+)? ((K_MEMBER | K_STATIC) ws+)?
            (K_PROCEDURE %{@kind_temp = :procedure} 
             | 
             (K_FINAL ws+)? (K_INSTANTIABLE ws+)? (K_CONSTRUCTOR ws+)? K_FUNCTION %{@kind_temp = :function})
            ws+ name %{@name = @name_temp; @kind = @kind_temp; @name_pos = @temp_name_pos} (ws+ | '(' | ';');

}%%

module Vorax

  module Parser

    class SubprogRegion < NamedRegion

      # Tries to figure out the type of the composite region.
      # @param data [String] the PLSQL code to be checked
      # @return [Hash] with the following keys: :name => the name of the function or procedure,
      #   :kind => the valid values are: :function, :procedure
      # @example
      #   text = 'function abc return boolean as begin null; end;'
      #   p Parser::SubprogRegion.probe(text)
      def self.probe(data)
				@name_pos, @temp_name_pos, @kind, @kind_temp, @name_temp, @name = nil
				if data
					eof = data.length
					%% write data;
					%% write init;
					%% write exec;
				end
				{:name => @name, :kind => @kind, :name_pos => @name_pos}
			end

    end

  end

end
