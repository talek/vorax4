%%{

machine declare;

include common "common.rl";

action tail {
	start = p
	text = data[start..eof]
	pos = 0
	walker = PlsqlWalker.new(text)
	walker.register_spot(/;/) do |scanner|
		pos = scanner.pos
	  scanner.terminate
	end
	walker.walk
	if pos > 0
  	p = p + pos
    te = p
  end
}

id = identifier >{@start = p} %{@identifier = data[@start...p]};
keywords = K_CURSOR | K_FUNCTION | K_PROCEDURE | K_SUBTYPE | K_TYPE | K_PRAGMA | K_EXCEPTION | K_BEGIN;
name = (id - keywords) >{@declared_at = p + 1};
variable_type = ((qualified_identifier - keywords) (K_ROWTYPE | K_VARTYPE)?) >{@start = p} @{@type = data[@start..p]};

cursor = K_CURSOR ws+ name ws+ K_IS ws+ %tail;
type = K_TYPE ws+ name ws+ K_IS ws+ variable_type %tail;
subtype = K_SUBTYPE ws+ name ws+ K_IS ws+ variable_type %tail;
function = K_FUNCTION ws+ name %tail;
procedure = K_PROCEDURE ws+ name %tail;
pragma = K_PRAGMA ws+ %tail;
begin = K_BEGIN ws+ %tail;
named_item = name ws+ ((K_EXCEPTION) %{@kind=:exception}
												|
												(K_CONSTANT %{@kind=:constant} ws+ variable_type) 
												|
												variable_type %{@kind=:variable}) %tail;

main := |*
  squoted_string;
  dquoted_string;
  comment;
  pragma => {};
  begin => {};
  cursor => { @items << CursorItem.new(@declared_at, @identifier, data[ts...te]) };
  type => { @items << TypeItem.new(@declared_at, @identifier, @type, data[ts...te]) };
  subtype => { @items << SubtypeItem.new(@declared_at, @identifier, @type, data[ts...te]) };
  function => { @items << FunctionItem.new(@declared_at, data[ts...te]) };
  procedure => { @items << ProcedureItem.new(@declared_at, data[ts...te]) };
  named_item => {
  		if @kind == :exception
  		  @items << ExceptionItem.new(@declared_at, @identifier)
  		elsif @kind == :constant
        @items << ConstantItem.new(@declared_at, @identifier, @type)
  		elsif @kind == :variable
				@items << VariableItem.new(@declared_at, @identifier, @type)
  		end
  	};
  any => {};
*|;

}%%

module Vorax

  module Parser

    # A class used to parse a declare section
    class Declare

      attr_reader :items

			def initialize(declare_code)
			  @code = declare_code
			  walk(@code)
			end

      # Walks the provided spec in order to compute the structure.
      #
      # param data [String] the package spec
      def walk(data)
        @declared_at = nil
        @items = []
        if data
          eof = data.length
          %% write data;
          %% write init;
          %% write exec;
        end
      end

    end

  end

end

