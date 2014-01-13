# encoding: UTF-8

include Vorax
include Parser

describe 'stmt_inspector' do

  it 'should work with delete statements' do
    text = "\n      delete from bskcmptre d where itmidn = d.\n    end loop;"
    inspector = StmtInspector.new(text)
    inspector.find_alias('d', 0).columns.should == ['bskcmptre.*']
  end

  it 'should work with hierarchical queries' do
    text = "select * from (select level as lvl, bskcmptre_tbl.*\n                       from bskcmptre_tbl\n                      start with itmidn = pi_nodidn\n                     connect by prior itmidn = bskprnidn\n                      order by itmidn desc) v_crtrec"
    inspector = StmtInspector.new(text)
    inspector.find_alias('v_crtrec', 0).columns.should == ["lvl", "bskcmptre_tbl.*"]
  end

  it 'should work with a complex query' do# {{{
    text = '
      with 
        tab as (select * from dba_users), 
        t2 as (select * from v$session) 
      select d.*, c.table_name
        from sys.dual  d  inner join
             (select c. from cat c) c on (d.c = c.c) outer join
             dba_tables on (x=y)
      union
      select t.*, x
        from muci t, buci 
      where 1=2;
    '
    #puts text
    inspector = StmtInspector.new(text)
    #pp inspector.data_source
    inspector.data_source.size.should == 7
    inspector.data_source.should include(ExprRef.new("select * from dba_users", (29..51), "tab"))
    inspector.data_source.should include(ExprRef.new("select * from v$session", (71..93), "t2"))
    inspector.data_source.should include(TableRef.new("sys.dual", "d"));
    inspector.data_source.should include(ExprRef.new("select c. from cat c", (179..198), 'c'));
    inspector.data_source.should include(TableRef.new("dba_tables", nil));
    inspector.data_source.should include(TableRef.new("muci", "t"));
    inspector.data_source.should include(TableRef.new("buci", nil));
    inspector.query_fields.should eq(["d.*", "c.table_name"])
  end# }}}

  it 'should get alias on an inner context' do# {{{
    text = '
      with 
        tab as (select * from dba_users), 
        t2 as (select * from v$session) 
      select d.*, c.table_name
        from sys.dual  d  inner join
             (select * from (select * from cat) c) c on (d.c = c.c) outer join
             dba_tables on (x=y)
      union
      select t.*, x
        from muci t, buci 
      where 1=2;
    '
    inspector = StmtInspector.new(text)
    ds = inspector.data_source(186);
    ds.size.should == 8
    ds.should include(ExprRef.new("select * from cat", (15..31), "c"))
    ds.should include(ExprRef.new("select * from dba_users", (29..51), "tab"))
    ds.should include(ExprRef.new("select * from v$session", (71..93), "t2"))
    ds.should include(TableRef.new("sys.dual", "d"));
    ds.should include(ExprRef.new("select * from (select * from cat) c", (179..213), 'c'));
    ds.should include(TableRef.new("dba_tables", nil));
    ds.should include(TableRef.new("muci", "t"));
    ds.should include(TableRef.new("buci", nil));
  end# }}}

  it 'should get columns for the provided alias' do# {{{
    text = '
      with 
        tab as (select * from (select user_id, user_name, password, x.* from dba_users, (select c1, c2, from dual) x)), 
        t2 as (select * from v$session) 
      select d.*, c.table_name
        from sys.dual  d  inner join
             (select * from (select * from cat) c) c on (d.c = c.c) outer join
             dba_tables on (x=y)
      union
      select t.*, x.*
        from muci t, buci x
      where 1=2;
    '
    inspector = StmtInspector.new(text)
    inspector.find_alias('x', 0).columns.should eq(["buci.*"])
    inspector.find_alias('x', 63).columns.should eq(["c1", "c2"])
    inspector.find_alias('tab', 0).columns.should eq(["user_id", "user_name", "password", "c1", "c2"])
  end# }}}

  it 'should get columns for alias with extract from syntax' do
    # 697
    text = 'select j.owner, j.job_name, j.program_owner, j.program_name, j.job_type, j.job_action, j.schedule_name, j.schedule_type, j.start_date, j.repeat_interval, j.job_class, j.restartable, j.last_start_date, j.last_run_duration, j.stop_on_window_close, j.comments, round(avg(durs.seconds), 0) avg_e_time
        from dba_scheduler_jobs j join
        (select owner, job_name, to_number(extract(second from run_duration)) + to_number(extract(minute from run_duration)) * 60 + to_number(extract(hour from run_duration))   * 60 * 60 +
          to_number(extract(day from run_duration))  * 60 * 60* 24 as Seconds,
          extract(timezone_minute from run_duration) minute, 
          extract(timezone_hour from run_duration) hour from dba_scheduler_job_run_details group by owner, job_name) durs
        on j.owner=durs.
         where enabled = \'TRUE\';'
    inspector = StmtInspector.new(text)
    inspector.find_alias('durs', 0).columns.should eq(["owner", "job_name", "Seconds", "minute", "hour"])
  end

end

