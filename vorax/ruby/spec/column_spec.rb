# encoding: UTF-8

include Vorax

describe 'column' do

  it 'should work with multiple columns' do
    Parser::Column.new.walk('col1, col2, f(a, b, c) x, 3+5, t.*, owner.tab.col y').should eq(["col1", "col2", "x", "t.*", "y"])
  end

  it 'should work with one column' do
    Parser::Column.new.walk('col1').should eq(["col1"])
  end

  it 'should work with one column with alias' do
    Parser::Column.new.walk('col1 as x').should eq(["x"])
    Parser::Column.new.walk('col1 y').should eq(["y"])
  end

  it 'should work with referenced columns' do
    Parser::Column.new.walk('tab.col1').should eq(["tab.col1"])
    Parser::Column.new.walk('owner.tab.col2').should eq(["owner.tab.col2"])
    Parser::Column.new.walk('"owner"."tab wow".col2').should eq(['"owner"."tab wow".col2'])
  end

  it 'should work with expressions' do
    Parser::Column.new.walk('(select 1 from dual) x, 3+2').should eq(["x"])
  end

  it 'should ignore functions without alias' do
    Parser::Column.new.walk('f(1, 2, 3), my_func(col)').should eq([])
  end

  it 'should work with nested expressions' do
    Parser::Column.new.walk('f(1, g(2), x(3, 2, f(10))), my_func(col)').should eq([])
  end

  it 'should work with unbalanced expressions' do
    Parser::Column.new.walk("owner, job_name, to_number(extract(second ").should eq(["owner", "job_name", "second"])
  end

end


