%%{

machine record_typ;

include common "common.rl";

action expr_start {
  expr = Parser.walk_balanced_paren(data[(p..-1)])
  p += expr.length - 1
  te = p
}

action tail {
	p = p - 1
	te = p
}

# a bracket expression
separator = (ws+ K_IS ws+ K_RECORD ws* '(' ws*) | (',' ws*);
expression = '(' >expr_start;
default_expr = (':=' ws* | (ws+ K_DEFAULT ws+)) qualified_identifier? ws* expression;
attr_spot = separator (identifier) >{ @start_attr = p } %{ @end_attr = p }
              ws* (identifier) >{ @start_typ = p };

main := |*
  squoted_string;
  dquoted_string;
  comment;
  attr_spot => { @attributes << { :name => data[(@start_attr..@end_attr-1)], :type => data[(@start_typ..te-1)] } };
  default_expr;
  any => {};
*|;

}%%

module Vorax

	module Parser

		def Parser.describe_record(data)
		  @attributes = []
		  if data
			  eof = data.length
        %% write data;
        %% write init;
        %% write exec;
		  end
		  return @attributes
		end

	end

end
