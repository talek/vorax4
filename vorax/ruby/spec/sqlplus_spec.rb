# encoding: UTF-8

include Vorax

describe 'sqlplus' do

  before(:each) do# {{{
    @sp = Sqlplus.new('sqlplus')
    @prep = [VORAX_CSTR, 
             "set tab off", 
             "set linesize 10000", 
             "set echo off",
             "set pause off",
             "set define &",
             "set termout on",
             "set verify off",
             "set pagesize 4"].join("\n")
    @result = ""
  end# }}}

  it 'should work with utf8' do# {{{
    @sp.exec('select name from employees where id=1;', :prep => @prep + "\ncolumn name format a20")
    @result << @sp.read_output(32767) while @sp.busy?
    expected = "
SQL> 
NAME
--------------------
Tică Șerban

SQL> SQL> "
    @result.should eq(expected)
  end# }}}

  it 'should work with substitution variables' do# {{{
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
