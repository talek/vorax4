# encoding: UTF-8

include Vorax

describe 'vertical layout' do

  before(:each) do# {{{
    @sp = Sqlplus.new('sqlplus')
    @sp.default_convertor = :vertical
    @prep = [VORAX_CSTR, 
             "set tab off", 
             "set linesize 10000", 
             "set markup html on", 
             "set echo off",
             "set pause off",
             "set define &",
             "set termout on",
             "set verify off",
             "set pagesize 4"].join("\n")
    @result = ""
  end# }}}

  it 'should work with pagesize=0' do# {{{
    @sp.exec("select * from departments where id<=3;", :prep => @prep + "\nset pagesize 0")
    @result << @sp.read_output(32767) while @sp.busy?
    expected = <<OUTPUT

SQL> 

 : 1
 : Bookkeeping
 : This department is responsible for:
   - financial reporting
   - analysis
   - other boring tasks
------------------------------------------------------------
 : 2
 : Marketing
 :  
------------------------------------------------------------
 : 3
 : Deliveries
 :  
------------------------------------------------------------

SQL> 
SQL> 
OUTPUT
    @result.should eq(expected)
  end# }}}

  it 'should work with unicode special chars' do# {{{
    @sp.exec("select * from employees where id=1;", :prep => @prep)
    @result << @sp.read_output(32767) while @sp.busy?
    expected = <<OUTPUT

SQL> 

ID            : 1
NAME          : Tică Șerban
SALARY        : 570
DEPARTMENT_ID : 1
------------------------------------------------------------

SQL> 
SQL> 
OUTPUT
    #puts @result
    @result.should eq(expected)
  end# }}}

  it 'should work with one single line record' do# {{{
    @sp.exec("select * from departments where id=2;", :prep => @prep)
    @result << @sp.read_output(32767) while @sp.busy?
    expected = <<OUTPUT

SQL> 

ID          : 2
NAME        : Marketing
DESCRIPTION :  
------------------------------------------------------------

SQL> 
SQL> 
OUTPUT
    @result.should eq(expected)
  end# }}}

  it 'should work with one multiline record' do# {{{
    @sp.exec("select * from departments where id=1;", :prep => @prep)
    @result << @sp.read_output(32767) while @sp.busy?
    expected = <<OUTPUT

SQL> 

ID          : 1
NAME        : Bookkeeping
DESCRIPTION : This department is responsible for:
              - financial reporting
              - analysis
              - other boring tasks
------------------------------------------------------------

SQL> 
SQL> 
OUTPUT
    @result.should eq(expected)
  end# }}}

  it 'should work with multiple lines' do# {{{
    @sp.exec("select * from departments where id in (1, 2);", :prep => @prep)
    @result << @sp.read_output(32767) while @sp.busy?
    expected = <<OUTPUT

SQL> 

ID          : 1
NAME        : Bookkeeping
DESCRIPTION : This department is responsible for:
              - financial reporting
              - analysis
              - other boring tasks
------------------------------------------------------------
ID          : 2
NAME        : Marketing
DESCRIPTION :  
------------------------------------------------------------

SQL> 
SQL> 
OUTPUT
    @result.should eq(expected)
  end# }}}

it 'should work with accept prompts' do# {{{
  begin
    pack_file = Tempfile.new(['vorax', '.sql'])
    @sp.exec("accept var prompt \"Enter var: \"\nprompt &var", :prep => @prep, :pack_file => pack_file.path)
    Timeout::timeout(10) {
      @result << @sp.read_output(32767) while @result !~ /Enter var: \z/
      @sp.send_text("muci\n")
      @result << @sp.read_output(32767) while @result !~ /muci\n\z/
    }
  ensure
    pack_file.unlink
  end
end# }}}

  after(:each) do# {{{
    @sp.terminate
  end# }}}

end

