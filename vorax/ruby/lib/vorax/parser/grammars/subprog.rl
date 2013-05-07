%%{

machine subprog;

include common "common.rl";

action eat_till_next {
  rest = data[(p..data.length)]
  pos = Parser.next_argument(rest) - 1
	@args.last && @args.last.has_default = true
	p = p + pos - 1 if pos > 0
}

action eat_till_end {
	text = data[p..eof]
	pos = 0
	walker = PlsqlWalker.new(text)
	walker.register_spot(/(\bAS\b)|(\bIS\b)|;/i) do |scanner|
		pos = scanner.pos
		p = p + pos - 1
		@declare_start_pos = p + 1
	  scanner.terminate
	end
	walker.walk
}

data_type = (K_SELF ws+ K_AS ws+ K_RESULT) 
            | 
            (qualified_identifier (K_ROWTYPE | K_VARTYPE)?);

return = K_RETURN ws+ data_type >{@start = p} %{@return_type = data[@start...p]};

arg_direction = ((K_IN ws+ K_OUT) %{ @args.last && @args.last.direction=:inout} 
                 | 
                 K_IN %{@args.last && @args.last.direction = :in} 
                 | 
                 K_OUT %{@args.last && @args.last.direction = :out} 
                ) ws+;

default = (ws+ (K_DEFAULT | ':=')) %eat_till_next;

argument = identifier >{@start = p} %{@args << ArgumentItem.new(@start, data[@start...p])} 
           ws+ arg_direction? (K_NOCOPY ws+)? 
           data_type >{@start = p} %{@args.last && @args.last.data_type = data[@start...p]}
           default?;

arg_list = argument (ws* ',' ws* argument)*;

args = ws* '(' ws* arg_list ws* ')';

name = qualified_identifier >{@start = p} %{@name = data[@start...p]};

optional = (K_OVERRIDING ws+)?
            ((K_MAP | K_ORDER) ws+)? ((K_MEMBER | K_STATIC) ws+)?
             (K_FINAL ws+)? (K_INSTANTIABLE ws+)? (K_CONSTRUCTOR ws+)?;

procedure = optional K_PROCEDURE >{@start = p} %{@kind = data[@start...p]} ws+ name args?;

function = optional K_FUNCTION >{@start = p} %{@kind = data[@start...p]} ws+ name args? ws+ return;

signature := (function | procedure) (';' | ws) %!eat_till_end;

}%%

module Vorax

	module Parser

		class SubprogItem < DeclareItem

			def self.describe(data)
				@args = []
				@name, @kind, @return_type, @declare_start_pos = nil
				if data
				  data << ' '
					eof = data.length
					%% write data;
					%% write init;
					%% write exec;
				  data.chop
				end
				{:name => @name, :kind => @kind, :args => @args, :return_type => @return_type, :declare_start_pos => @declare_start_pos}
			end

		end
	
	end

end
