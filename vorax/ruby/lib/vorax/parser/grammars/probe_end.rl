%%{

machine probe_end;

include common "common.rl";

subprog_name = identifier - (K_IF | K_LOOP);
end_def = (K_END ws* ';' | K_END ws+ subprog_name ws* ';') @{@kind = :end; @pointer = p};
end_loop = (K_END ws* K_LOOP ws* ';') @{@kind = :end_loop; @pointer = p};
end_if = (K_END ws* K_IF ws* ';') @{@kind = :end_if; @pointer = p};

main := end_loop | end_if | end_def;

}%%

module Vorax

  module Parser

    class Region

      # Tries to figure out the type of the end marker.
      # @param data [String] the PLSQL code to be checked
      # @return [Hash] with the following keys: :kind => :end, :end_loop, :end_if
      #   :pointer => where the "end" definition ends.
      # @example
      #   text = 'end if;'
      #   p Parser::Region.probe_end(text)
			def self.probe_end(data)
				@kind, @pointer = nil
				if data
					eof = data.length
					%% write data;
					%% write init;
					%% write exec;
				end
				{:kind => @kind, :pointer => @pointer}
			end

    end

  end

end
