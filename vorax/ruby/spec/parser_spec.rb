# encoding: UTF-8

include Vorax

describe 'Parser' do

  it 'should detect identifiers' do# {{{
    text = 'muci buci 23 "owner"."object".function(abc)'
    Parser.identifier_at(text, 3).should == "muci"
    Parser.identifier_at(text, 13).should == '"owner"."object".function'
  end# }}}

  it 'should parse a basic record type' do# {{{
    text = <<-STRING
      type Employee is record (
        Name varchar2(100),
        Salary number(10,2),
        Gender varchar2(1)
      );
    STRING
    Parser.describe_record(text).should eq([{:name=>"Name", :type=>"varchar2"}, 
                                            {:name=>"Salary", :type=>"number"}, 
                                            {:name=>"Gender", :type=>"varchar2"}])
  end# }}}

  it 'should parse a record type with default clauses' do# {{{
    text = <<-STRING
      type Muci is record (
        typ varchar2(10) := my_func(sysdate, systimestamp),
        abc date default to_date('10.10.2010', 'dd.mm.yyyy'),
        xyz boolean default (my_func(sysdate))
      );
    STRING
    Parser.describe_record(text).should eq([{:name=>"typ", :type=>"varchar2"}, 
                                            {:name=>"abc", :type=>"date"}, 
                                            {:name=>"xyz", :type=>"boolean"}])
  end# }}}

  it 'should work with balanced paren' do# {{{
    Parser.walk_balanced_paren('(a(b)c)').should eq("(a(b)c)")
    Parser.walk_balanced_paren('(a(b)(xyz)c)').should eq("(a(b)(xyz)c)")
    Parser.walk_balanced_paren("(a')'(b)c)bla bla bla").should eq("(a')'(b)c)")
    Parser.walk_balanced_paren('(a")"(b)c)bla bla bla').should eq('(a")"(b)c)')
    Parser.walk_balanced_paren("(a/*)*/(b)c)bla bla bla").should eq("(a/*)*/(b)c)")
    Parser.walk_balanced_paren("(a--)\n(b)c)bla bla bla").should eq("(a--)\n(b)c)")
    Parser.walk_balanced_paren("(aq[')]'(b)c)bla bla bla").should eq("(aq[')]'(b)c)")
  end# }}}

  it 'should add the proper end delimitator' do# {{{
    text = "select * from cat"
    Parser.prepare_exec(text).should eq("select * from cat;")

    text = <<TEXT
begin
  null;
end;
TEXT
    Parser.prepare_exec(text).should eq("begin\n  null;\nend;\n/\n")

    text = "set serveroutput on"
    Parser.prepare_exec(text).should eq("set serveroutput on")

    text = "select * from dual;"
    Parser.prepare_exec(text).should eq("select * from dual;")
  end# }}}

  describe 'Comments parsing' do# {{{

  it 'should be smart enough to leave quotes unchanged' do# {{{
    stmt = <<STR
select '/*muci*/' from/*abc*/dual;
STR
    Parser.remove_all_comments(stmt).should eq("select '/*muci*/' from dual;\n")
  end# }}}

  it 'should remove all comments' do# {{{
    stmt = <<STR
select /* muci */ * from --muhah
--bla
dual
/* muha
ha*/
;
STR
    Parser.remove_all_comments(stmt).should eq("select   * from   dual\n \n;\n")
  end# }}}

  it 'should remove all comments from incomplete statements' do# {{{
    Parser.remove_all_comments('select /* bla').should eq('select /* bla')
  end# }}}

  it 'should remove trailing comments' do# {{{
    text = <<TEXT
select * from cat --comment
-- alt comment
-- si inca un comment
TEXT
    Parser.remove_trailing_comments(text).should eq("select * from cat ")

    text = <<TEXT
select * from cat
/* multi
line comment */
/* inca
unul */
TEXT
    Parser.remove_trailing_comments(text).should eq("select * from cat\n")

    text = <<TEXT
select * from cat
/* multi
line comment */
-- single line comment
/* inca
unul */
-- muhaha
TEXT
    Parser.remove_trailing_comments(text).should eq("select * from cat\n")
  end# }}}

  end# }}}

  describe 'Arguments parsing' do# {{{

  it 'should detect basic argument owner' do# {{{
    text = 'select col1, 1+2, func(a, b, my_f(x, y), c, \'a\'\'bc\', "xxx".y, d,'
    Parser.argument_belongs_to(text, 65).should eq('func')
    Parser.argument_belongs_to(text, 37).should eq('my_f')
  end# }}}

  it 'should handle whitespaces between function name and open paran' do# {{{
    Parser.argument_belongs_to('exec dbms_stats.gather_schema_stats   (owname => user, ').should eq('dbms_stats.gather_schema_stats')
    Parser.argument_belongs_to("begin dbms_stats.gather_schema_stats   \n\t  (owname => user, ").should eq('dbms_stats.gather_schema_stats')
  end# }}}

  it 'should handle quoted identifiers' do# {{{
    Parser.argument_belongs_to('exec "My user"   . "bla@hei.la" @ dblink.hop.hu(owname => user, ').should eq("\"My user\".\"bla@hei.la\"@dblink.hop.hu")
    Parser.argument_belongs_to('exec "ABC!"."bla"(owname => user, ').should eq("\"ABC!\".\"bla\"")
    Parser.argument_belongs_to('exec owner."pkg"."my func"(owname => user, ').should eq("owner.\"pkg\".\"my func\"")
  end# }}}

  it 'should ignore comments' do# {{{
    Parser.argument_belongs_to('exec dbms_stats./*muci*/gather_schema_stats/*abc*/   (owname => user, ').should eq('dbms_stats.gather_schema_stats')
  end# }}}

  it 'should handle plsql quoting' do# {{{
    text = "exec pkg.my_proc(q'[Isn't the \"(\" character sweet?]', "
    Parser.argument_belongs_to(text).should eq('pkg.my_proc')
    text = "exec pkg.my_proc(q'{Isn't the \"(\" character sweet?}', "
    Parser.argument_belongs_to(text).should eq('pkg.my_proc')
    text = "exec pkg.my_proc(q'<Isn't the \"(\" character sweet?>', "
    Parser.argument_belongs_to(text).should eq('pkg.my_proc')
  end# }}}

  it 'should fallback to simple quoting' do# {{{
    text = "exec pkg.my_proc('<Isn''t the \"(\" character sweet?>', "
    Parser.argument_belongs_to(text).should eq('pkg.my_proc')
  end# }}}

  end# }}}

  describe 'Statement type' do# {{{

    it 'should detect an anonymous block' do# {{{
      Parser.statement_type("begin dbms_output.put_line('xx');").should eq("ANONYMOUS")
      Parser.statement_type("declare l_test varchar2(10);").should eq("ANONYMOUS")
      Parser.statement_type("bbegin dbms_output.put_line('xx');").should be_nil
      Parser.statement_type("ddeclare dbms_output.put_line('xx');").should be_nil
      Parser.statement_type("select 1 from dual;").should be_nil
    end# }}}

    it 'should detect a function' do# {{{
      Parser.statement_type("create or\nreplace function muci as").should eq("FUNCTION")
      Parser.statement_type("create orreplace function muci as").should be_nil
    end# }}}

    it 'should detect a procedure' do# {{{
      Parser.statement_type("create or replace\n procedure muci as").should eq("PROCEDURE")
      Parser.statement_type("create or replace proceduremuci as").should be_nil
    end# }}}

    it 'should detect a trigger' do# {{{
      Parser.statement_type("create or replace\n trigger muci as").should eq("TRIGGER")
      Parser.statement_type("createor replace trigger as").should be_nil
    end# }}}

    it 'should detect a package spec' do# {{{
      Parser.statement_type("create or replace\n package muci as").should eq("PACKAGE")
      Parser.statement_type("createor replace package as").should be_nil
    end# }}}

    it 'should detect a package body' do# {{{
      Parser.statement_type("create or replace\n package body muci as").should eq("PACKAGE BODY")
      Parser.statement_type("create or replace packagebody as").should be_nil
      Parser.statement_type("create or replace package bodyas").should_not eq("PACKAGE BODY")
    end# }}}

    it 'should detect a type spec' do# {{{
      Parser.statement_type("create or replace\n type muci as").should eq("TYPE")
      Parser.statement_type("createor replace type as").should be_nil
    end# }}}

    it 'should detect a type body' do# {{{
      Parser.statement_type("create or replace\n type body muci as").should eq("TYPE BODY")
      Parser.statement_type("create or replace typebody as").should be_nil
      Parser.statement_type("create or replace type bodyas").should_not eq("TYPE BODY")
    end# }}}

    it 'should detect java source' do# {{{
      Parser.statement_type("create or replace java muci as").should eq("JAVA")
      Parser.statement_type("create java muci as").should eq("JAVA")
      Parser.statement_type("create or replace and compile java muci as").should eq("JAVA")
      Parser.statement_type("create or replace and resolve noforce java muci as").should eq("JAVA")
      Parser.statement_type("create or replace and resolvenoforce java muci as").should_not eq("JAVA")
    end# }}}

    it 'should detect sqlplus command' do# {{{
      Parser.statement_type("accept muci").should eq("SQLPLUS")
      Parser.statement_type("acc muci").should eq("SQLPLUS")
      Parser.statement_type("acce muci").should eq("SQLPLUS")
      Parser.statement_type("@muci.sql").should eq("SQLPLUS")
      Parser.statement_type("@@muci.sql").should eq("SQLPLUS")
      Parser.statement_type("/").should eq("SQLPLUS")
      Parser.statement_type("archive log list").should eq("SQLPLUS")
      Parser.statement_type("attribute muci").should eq("SQLPLUS")
      Parser.statement_type("break on whatever").should eq("SQLPLUS")
      Parser.statement_type("btitle abc").should eq("SQLPLUS")
      Parser.statement_type("btit abc").should eq("SQLPLUS")
      Parser.statement_type("cle").should eq("SQLPLUS")
      Parser.statement_type("colu abc format a15").should eq("SQLPLUS")
      Parser.statement_type("compute on bla bla bla").should eq("SQLPLUS")
      Parser.statement_type("connect muci/buci@db").should eq("SQLPLUS")
      Parser.statement_type("copy").should eq("SQLPLUS")
      Parser.statement_type("def var").should eq("SQLPLUS")
      Parser.statement_type("desc my_table").should eq("SQLPLUS")
      Parser.statement_type("discon").should eq("SQLPLUS")
      Parser.statement_type("execu dbms_output.put_line('abc');").should eq("SQLPLUS")
      Parser.statement_type("exit").should eq("SQLPLUS")
      Parser.statement_type("quit").should eq("SQLPLUS")
      Parser.statement_type("help").should eq("SQLPLUS")
      Parser.statement_type("host ls -al").should eq("SQLPLUS")
      Parser.statement_type("!ls -al").should eq("SQLPLUS")
      Parser.statement_type("passw").should eq("SQLPLUS")
      Parser.statement_type("password user").should eq("SQLPLUS")
      Parser.statement_type("pause press any key").should eq("SQLPLUS")
      Parser.statement_type("print curs").should eq("SQLPLUS")
      Parser.statement_type("prom var").should eq("SQLPLUS")
      Parser.statement_type("recover database").should eq("SQLPLUS")
      Parser.statement_type("rem comment").should eq("SQLPLUS")
      Parser.statement_type("repf on").should eq("SQLPLUS")
      Parser.statement_type("rephe off").should eq("SQLPLUS")
      Parser.statement_type("sav muci.sql").should eq("SQLPLUS")
      Parser.statement_type("set pagesize 100").should eq("SQLPLUS")
      Parser.statement_type("set transaction name muci;").should be_nil
      Parser.statement_type("show pagesize").should eq("SQLPLUS")
      Parser.statement_type("shutdown").should eq("SQLPLUS")
      Parser.statement_type("spool muci.log").should eq("SQLPLUS")
      Parser.statement_type("start muci.sql").should eq("SQLPLUS")
      Parser.statement_type("startup").should eq("SQLPLUS")
      Parser.statement_type("store set options.sql").should eq("SQLPLUS")
      Parser.statement_type("timing stop").should eq("SQLPLUS")
      Parser.statement_type("title abc").should eq("SQLPLUS")
      Parser.statement_type("undef var").should eq("SQLPLUS")
      Parser.statement_type("var muci").should eq("SQLPLUS")
      Parser.statement_type("whenever oserror exit").should eq("SQLPLUS")
      Parser.statement_type("xquery bla bla bla").should eq("SQLPLUS")
      Parser.statement_type("\n-- APEX RMS DB UPDATES FILE\n").should be_nil
    end# }}}

  end# }}}

  it 'should get the current statement' do# {{{
    text = <<STRING
select /* comment: ; */ 'muci;buci''s yea' from dual; -- interesting ha;ha?
select * from cat;
STRING
    Parser.current_statement(text, 10)[:statement].should eq("select /* comment: ; */ 'muci;buci''s yea' from dual;")
    Parser.current_statement(text, 85)[:statement].should eq(" -- interesting ha;ha?\nselect * from cat;")

    text = <<STRING
set serveroutput on
column c1 format a10
select 1 from dual;
begin
  null;
end;
/
select c2 from t1
/
update t set x=1;
STRING
    Parser.current_statement(text, 10, :sqlplus_commands => false, :plsql_blocks => false)[:statement].should eq("set serveroutput on\ncolumn c1 format a10\nselect 1 from dual;")
    Parser.current_statement(text, 10, :sqlplus_commands => true, :plsql_blocks => false)[:statement].should eq("set serveroutput on")
    Parser.current_statement(text, 71, :sqlplus_commands => true, :plsql_blocks => false)[:statement].should eq("\nbegin\n  null;")
    Parser.current_statement(text, 71, :sqlplus_commands => true, :plsql_blocks => true)[:statement].should eq("\nbegin\n  null;\nend;\n/\n")
    Parser.current_statement(text, 88, :sqlplus_commands => true, :plsql_blocks => true)[:statement].should eq("select c2 from t1\n/\n")

    text = <<STRING
select * from all_objects where rownum <= 1000;

set serveroutput on
begin
  dbms_output.put_line('Hello Vorax!');
end;
/

with
  x as (select * 
          from (select file_id, file_name from dba_data_files) t,
               (select * from (select 'abc' col1, 'xyz' col2 from dual) x)
       )
select *
  from x;
STRING
    Parser.current_statement(text, 90, :sqlplus_commands => true, :plsql_blocks => true).
      should eq({:statement=>"begin\n  dbms_output.put_line('Hello Vorax!');\nend;\n/\n", :range=>69...122})

    text = "exec dbms_crypto.encrypt("
    Parser.current_statement(text, 10, :plslq_blocks => true, :sqlplus_commands => true).
      should eq({:statement=>"exec dbms_crypto.encrypt(", :range=>0...25})
  end# }}}

  it 'should get the next param position' do# {{{
    text = "p1 varcha2(100) := myf('A', 1, f(y)), p2 DATE);"
    Parser.next_argument(text).should == 37
    text = "p1 varchar2(100) := myf('A', 1, f(y)));"
    Parser.next_argument(text).should == 38
    text = "p1 varchar2(100));"
    Parser.next_argument(text).should == 17
    text = "p1 varchar2(100)"
    Parser.next_argument(text).should == 0 
  end# }}}

  it 'should split statements' do# {{{
    text = <<STRING
select /* comment: ; */ 'muci;buci''s yea' from dual; -- interesting ha;ha?
set serveroutput on
begin
dbms_output.put_line('xxx');
end;
/
select * from cat;
select * from dual
STRING
    Parser.statements(text).should ==
      ["select /* comment: ; */ 'muci;buci''s yea' from dual;",
        " -- interesting ha;ha?\nset serveroutput on\n",
        "begin\ndbms_output.put_line('xxx');\nend;\n/\n",
        "select * from cat;",
        "\nselect * from dual\n"]
  end# }}}

end
