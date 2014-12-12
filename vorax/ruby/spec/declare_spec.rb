# encoding: UTF-8

include Vorax
include Parser

describe 'declare' do

  it 'should parse a simple declare section' do
    text = <<STRING
      type Employees is record (
        first_name varchar2(100),
        /* this is a nice attribute muhahah; */
        last_name varchar2(100)
      );
      emp Employees;
STRING
    parser = Vorax::Parser::Declare.new(text)
    expect(parser.items).to include(TypeItem.new(12, "Employees", "record", "type Employees is record (\n\t\t    first_name varchar2(100),\n\t\t    last_name varchar2(100)\n\t\t  );"))
    expect(parser.items).to include(VariableItem.new(163, "emp", "Employees"))
  end

end
