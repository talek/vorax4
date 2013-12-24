# encoding: UTF-8

include Vorax

describe 'pagezip layout' do

  before(:each) do# {{{
    @sp = Sqlplus.new('sqlplus')
    @sp.default_convertor = :pagezip
    @prep = [VORAX_CSTR, 
             "set tab off", 
             "set linesize 10000", 
             "set markup html on", 
             "set echo off",
             "set pause off",
             "set define &",
             "set termout on",
             "set verify off",
             "set pagesize 5"].join("\n")
    @result = ""
  end# }}}

  it 'should work with multi line records' do# {{{
    @sp.exec("select * from departments where id in (1, 2, 6);", :prep => @prep)
    @result << @sp.read_output(32767) while @sp.busy?
    expected = <<OUTPUT

SQL> 

ID NAME        DESCRIPTION
-- ----------- -----------------------------------
 1 Bookkeeping This department is responsible for:
               - financial reporting
               - analysis
               - other boring tasks
 2 Marketing    
 6 Management  The bad guys department

SQL> 
SQL> 
OUTPUT
    @result.should eq(expected)
  end# }}}

  it 'should work with a single line record' do# {{{
    @sp.exec("select * from departments where id=2;", :prep => @prep)
    @result << @sp.read_output(32767) while @sp.busy?
    expected = <<OUTPUT

SQL> 

ID NAME      DESCRIPTION
-- --------- -----------
 2 Marketing  

SQL> 
SQL> 
OUTPUT
    @result.should eq(expected)
  end# }}}

  it 'should work without headers' do# {{{
    @sp.exec("select * from departments where id<=4;", :prep => "#@prep\nset pagesize 0")
    @result << @sp.read_output(32767) while @sp.busy?
    expected = <<OUTPUT

SQL> 

1 Bookkeeping This department is responsible for:
              - financial reporting
              - analysis
              - other boring tasks
2 Marketing    
3 Deliveries   
4 CRM          

SQL> 
SQL> 
OUTPUT
    @result.should eq(expected)
  end# }}}

  it 'should work with special unicode chars' do# {{{
    @sp.exec("select * from employees where id=1;", :prep => @prep)
    @result << @sp.read_output(32767) while @sp.busy?
    expected = <<OUTPUT

SQL> 

ID NAME        SALARY DEPARTMENT_ID
-- ----------- ------ -------------
 1 Tică Șerban    570             1

SQL> 
SQL> 
OUTPUT
    @result.should eq(expected)
  end# }}}

  it 'should work with multiple pages' do# {{{
    @sp.exec("select * from departments where id<=10;", :prep => "#@prep\nset pagesize 4")
    @result << @sp.read_output(32767) while @sp.busy?
    expected = <<OUTPUT

SQL> 

ID NAME        DESCRIPTION
-- ----------- -----------------------------------
 1 Bookkeeping This department is responsible for:
               - financial reporting
               - analysis
               - other boring tasks
 2 Marketing    
 3 Deliveries   
 4 CRM          

ID NAME             DESCRIPTION
-- ---------------- -----------------------
 5 Legal Stuff       
 6 Management       The bad guys department
 7 Cooking           
 8 Public Relations  

ID NAME        DESCRIPTION
-- ----------- -----------
 9 Aquisitions  
10 Cleaning     

10 rows selected.

SQL> 
SQL> 
OUTPUT
    #puts @result
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


