%%{

machine probe_forloop;

include common "common.rl";

action expr_start {
  @expr = Parser.walk_balanced_paren(data[(p..-1)])
  p += @expr.length - 1
}

# a bracket expression
expression = '(' >expr_start;
id = (identifier - (K_IN | K_FOR | K_LOOP | K_REVERSE)) >{@start = p; @var_pos = p} %{@end = p - 1};

cursor_var = qualified_identifier - K_REVERSE;

for_stmt_range = ws+ (K_REVERSE ws+)? digit+ ws* '..' ws* digit+ ws+;
for_stmt_query = ws* expression ws*;
for_stmt_cursor = ws+ cursor_var >{@start = p} %{@cursor_var = data[@start..p-1]} ws+;
for_stmt := (K_FOR ws+ id %{@variable = data[@start..@end]} ws+ K_IN (for_stmt_range | for_stmt_query | for_stmt_cursor) K_LOOP ws+) @{@pointer = p};

}%%

module Vorax

  module Parser

		class ForRegion < Region

			def self.probe(data)
				@pointer, @variable, @cursor_var,  @expr, @variable = nil
				if data
					eof = data.length
					%% write data;
					%% write init;
					%% write exec;
				end
				if @pointer
					return {:variable => @variable,
					        :variable_position => @var_pos,
									:domain_type => (@expr ? :expr : (@cursor_var ? :cursor_var : :counter)),
									:domain => (@expr ? @expr : (@cursor_var ? @cursor_var : nil)),
									:pointer => @pointer}
			  else
					return {:variable => nil, :domain_type => nil, :domain => nil, :pointer => nil, :variable_position => nil}
			 	end
			end

		end

  end

end
