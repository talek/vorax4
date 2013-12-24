# encoding: UTF-8

include Vorax

describe 'Subprog' do

  it 'should work with a simple function' do
    arg1 = Parser::ArgumentItem.new(15, 'p1')
    arg1.data_type='varchar2'
    arg1.has_default=true
    arg2 = Parser::ArgumentItem.new(36, 'p2')
    arg2.data_type='boolean'
    subprog = Parser::SubprogItem.new(0, 'procedure test(p1 varchar2 := null, p2 boolean)')
    subprog.name.should == "test"
    subprog.kind.should == "procedure"
    subprog.args.should == [arg1, arg2]
    subprog.return_type.should be_nil

    subprog = Parser::SubprogItem.new(0, 'function my_func(param1 varchar2, param2 boolean := true) return boolean pipelined deterministic as begin null; end;')
    arg1 = Parser::ArgumentItem.new(17, 'param1')
    arg1.data_type='varchar2'
    arg2 = Parser::ArgumentItem.new(34, 'param2')
    arg2.data_type='boolean'
    arg2.has_default = true
    subprog.name.should == "my_func"
    subprog.kind.should == "function"
    subprog.args.should == [arg1, arg2]
    subprog.return_type.should == 'boolean'
  end

  it 'should work for a procedure with direction params' do
    arg1 = Parser::ArgumentItem.new(15, 'p1')
    arg1.data_type='varchar2'
    arg1.has_default=true
    arg2 = Parser::ArgumentItem.new(39, 'p2')
    arg2.direction = :out
    arg2.data_type='boolean'
    arg3 = Parser::ArgumentItem.new(62, 'p3')
    arg3.direction = :inout
    arg3.data_type='date'
    subprog = Parser::SubprogItem.new(0, 'procedure test(p1 in varchar2 := null, p2 out nocopy boolean, p3 in out date)')
    subprog.name.should == "test"
    subprog.kind.should == "procedure"
    subprog.args.should == [arg1, arg2, arg3]
    subprog.return_type.should be_nil
  end

  it 'should work for a procedure with direction params' do
    arg1 = Parser::ArgumentItem.new(14, 'p1')
    arg1.data_type='varchar2'
    arg1.has_default=true
    subprog = Parser::SubprogItem.new(0, 'function test(p1 in varchar2 := null) return boolean')
    subprog.name.should == "test"
    subprog.kind.should == "function"
    subprog.args.should == [arg1]
    subprog.return_type.should == "boolean"
  end

  it 'should work with a subprog without params' do
    subprog = Parser::SubprogItem.new(0, 'procedure muci')
    subprog.name.should == "muci"
    subprog.kind.should == "procedure"
    subprog.args.should == []
    subprog.return_type.should be_nil

    subprog = Parser::SubprogItem.new(0, 'function muci return owner.table%rowtype')
    subprog.name.should == "muci"
    subprog.kind.should == "function"
    subprog.args.should == []
    subprog.return_type.should == 'owner.table%rowtype'
  end

end
