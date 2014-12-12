# encoding: UTF-8

include Vorax

describe 'tablezip layout' do

  before(:each) do# {{{
    @sp = Sqlplus.new('sqlplus')
    @sp.default_convertor = :tablezip
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

  it 'should work with multiple statements' do# {{{
    @sp.exec("select dummy d from dual;\nselect * from departments where id <= 2;", :prep => @prep)
    @result << @sp.read_output(32767) while @sp.busy?
    expected = <<OUTPUT

SQL> 

D
-
X

SQL> 

ID NAME        DESCRIPTION
-- ----------- -----------------------------------
 1 Bookkeeping This department is responsible for:
               - financial reporting
               - analysis
               - other boring tasks
 2 Marketing    

SQL> 
SQL> 
OUTPUT
    #puts @result
    @result.should eq(expected)
  end# }}}

  it 'should work with multi line records' do# {{{
    @sp.exec("select * from departments where id <= 10;", :prep => @prep)
    @result << @sp.read_output(32767) while @sp.busy?
    expected = <<OUTPUT

SQL> 

ID NAME             DESCRIPTION
-- ---------------- -----------------------------------
 1 Bookkeeping      This department is responsible for:
                    - financial reporting
                    - analysis
                    - other boring tasks
 2 Marketing         
 3 Deliveries        
 4 CRM               

ID NAME             DESCRIPTION
-- ---------------- -----------------------------------
 5 Legal Stuff       
 6 Management       The bad guys department
 7 Cooking           
 8 Public Relations  

ID NAME             DESCRIPTION
-- ---------------- -----------------------------------
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

it 'should work with <pre> tags' do# {{{
    @sp.exec("set autotrace traceonly explain\nselect * from dual;", :prep => @prep)
    @result << @sp.read_output(32767) while @sp.busy?
    @result.should match(/SELECT STATEMENT/)
end# }}}

  after(:each) do# {{{
    @sp.terminate
  end# }}}

end

