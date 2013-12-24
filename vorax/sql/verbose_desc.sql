-- SIMPLE DESC
-- It describes the provided name.
--
-- Parameters:
--   1st => the schema name
--   2nd => the table name to be described
set serveroutput on format wrapped
set define '&'
set verify off
set pause off
set feedback off
set timing off

prompt
declare
  l_owner varchar2(30) := '&1';
  l_table varchar2(30) := '&2';
  l_idx   integer;
  l_pk    varchar2(32767) := '';
  l_head  boolean := false;
begin
  dbms_output.put_line(l_owner || '.' || l_table);
  dbms_output.put_line(rpad('-', 60, '-'));
  for l_item in (select a.COMMENTS
                   from all_tab_comments a
                  where a.OWNER = l_owner
                    and a.TABLE_NAME = l_table)
  loop
    dbms_output.put_line('   ' || l_item.comments);
  end loop;
  for l_item in (select a.TABLESPACE_NAME,
                        a.NUM_ROWS,
                        a.CHAIN_CNT,
                        a.AVG_ROW_LEN,
                        a.LAST_ANALYZED,
                        a.COMPRESSION
                   from all_tables a
                  where a.OWNER = l_owner
                    and a.TABLE_NAME = l_table)
  loop
    dbms_output.put_line('   Last analyzed: ' || l_item.last_analyzed ||
                         '; Aprox. Number of Rows: ' || l_item.num_rows ||
                         '; Tablespace: ' || l_item.tablespace_name ||
                         '; Chain rows: ' || l_item.chain_cnt ||
                         '; Compression: ' || l_item.compression);
  end loop;
  dbms_output.put_line('');
  dbms_output.put_line('   ' || rpad('Column Name', 31) ||
                       rpad('Data Type', 31) || rpad('Null?', 6) ||
                       rpad('Default', 11) || 'Comments');
  dbms_output.put_line('   ' || rpad('-', 30, '-') || ' ' ||
                       rpad('-', 30, '-') || ' ' || rpad('-', 5, '-') || ' ' ||
                       rpad('-', 10, '-') || ' ' || rpad('-', 30, '-'));
  for l_item in (select COLS.COLUMN_NAME,
                        DATA_TYPE DT,
                        NULLABLE,
                        DATA_DEFAULT,
                        replace(COMMENTS, chr(10), ' ') comments,
                        case
                          when DATA_TYPE in ('VARCHAR2', 'VARCHAR', 'CHAR') then
                           data_type || '(' || data_length || ')'
                          when DATA_TYPE in ('NUMBER') and DATA_SCALE is null and
                               DATA_PRECISION is null then
                           data_type
                          when DATA_TYPE in ('NUMBER') and DATA_SCALE = 0 and
                               DATA_PRECISION is null then
                           'INTEGER'
                          when DATA_TYPE in ('NUMBER') and DATA_SCALE = 0 and
                               DATA_PRECISION is not null then
                           data_type || '(' || data_precision || ')'
                          when DATA_TYPE in ('NUMBER') and DATA_SCALE != 0 and
                               DATA_PRECISION is not null then
                           data_type || '(' || data_precision || ', ' ||
                           data_scale || ')'
                          else
                           DATA_TYPE
                        end DATA_TYPE
                   from ALL_TAB_COLUMNS COLS, ALL_COL_COMMENTS CMTS
                  where COLS.TABLE_NAME = l_table
                    and COLS.OWNER = l_owner
                    and cols.TABLE_NAME = cmts.table_name
                    and cols.OWNER = cmts.owner
                    and cols.COLUMN_NAME = cmts.column_name
                  order by cols.column_id)
  loop
    dbms_output.put_line('   ' || rpad(l_item.column_name, 31) ||
                         rpad(l_item.data_type, 31) ||
                         rpad(l_item.nullable, 6) ||
                         rpad(nvl(substr(l_item.data_default, 1, 10), ' '),
                              11) || l_item.comments);
  end loop;
  dbms_output.put_line('');
  dbms_output.put_line('Primary Key:');
  dbms_output.put_line('-------------------');
  l_idx := 1;
  for l_item in (select constraint_name, column_name
                   from all_cons_columns cols
                  where constraint_name in
                        (select constraint_name
                           from all_constraints cons
                          where cons.owner = cols.owner
                            and cons.table_name = cols.table_name
                            and owner = l_owner
                            and table_name = l_table
                            and constraint_type = 'P')
                  order by position)
  loop
    if l_idx = 1
    then
      l_pk := '   ' || l_item.constraint_name || ' (' || l_item.column_name;
    else
      l_pk := l_pk || ', ' || l_item.column_name;
    end if;
    l_idx := l_idx + 1;
  end loop;
  if l_pk is not null
  then
    l_pk := l_pk || ')';
  else
    l_pk := '   ' || 'No primary key defined.';
  end if;
  dbms_output.put_line(l_pk);
  -- check constraints
  l_idx := 1;
  for l_item in (select constraint_name, c.search_condition
                   from all_constraints c
                  where table_name = l_table
                    and owner = l_owner
                    and constraint_type = 'C')
  loop
    if l_idx = 1
    then
      dbms_output.put_line('');
      dbms_output.put_line('Check Constraints:');
      dbms_output.put_line('-------------------');
    end if;
    dbms_output.put_line('   ' || rpad(l_item.constraint_name, 31) ||
                         l_item.search_condition);
    l_idx := l_idx + 1;
  end loop;
  -- unique constraints
  l_idx := 1;
  for l_item in (select constraint_name,
                        decode(c.INDEX_OWNER, '', '', c.index_owner || '.') ||
                        c.INDEX_NAME index_name
                   from all_constraints c
                  where table_name = l_table
                    and owner = l_owner
                    and constraint_type = 'U')
  loop
    if l_idx = 1
    then
      dbms_output.put_line('');
      dbms_output.put_line('Unique Constraints:');
      dbms_output.put_line('-------------------');
    end if;
    dbms_output.put_line('   ' || rpad(l_item.constraint_name, 31) ||
                         'Index: ' || l_item.index_name);
    l_idx := l_idx + 1;
  end loop;
  -- indexes
  l_idx := 1;
  for l_item in (select index_name,
                        max(index_type) index_type,
                        TRANSLATE(LTRIM(max(text), '/'), '/', ',') text
                   from (select piece,
                                level lvl,
                                index_name,
                                index_type,
                                sys_connect_by_path(column_name, '/') text
                           from (select row_number() over(partition by t1.index_name order by t2.column_position) piece,
                                        t1.index_name,
                                        t1.index_type,
                                        t2.column_name
                                   from all_indexes t1, all_ind_columns t2
                                  where t1.owner = t2.index_owner
                                    and t1.index_name = t2.index_name
                                    and t1.table_owner = l_owner
                                    and t1.table_name = l_table)
                         connect by piece - 1 = prior piece
                                and index_name = prior index_name
                          start with piece - 1 = 0)
                  group by index_name
                  order by index_name)
  loop
    if l_idx = 1
    then
      dbms_output.put_line('');
      dbms_output.put_line('Indexes:');
      dbms_output.put_line('-------------------');
    end if;
    dbms_output.put_line('   ' || rpad(l_item.index_name, 31) || ' ' ||
                         rpad(l_item.index_type, 15) || ' Columns: ' ||
                         l_item.text);
    l_idx := l_idx + 1;
  end loop;

  -- triggers
  for r in (  select rpad( trigger_name, 32)||' => '||triggering_event||' '||trigger_type output, rownum rownum#
          from all_triggers a
          where a.owner = l_owner
            and a.table_name = l_table)
  loop
  if r.rownum# = 1 then
      dbms_output.put_line('');
      dbms_output.put_line('Triggers');
      dbms_output.put_line('-------------------');
  end if;
    dbms_output.put_line('   ' || r.output);
  end loop;

  -- relations
  l_idx := 1;
  for l_item in (select child.table_name as TABL_NAME_2,
                        parent.owner || '.' || parent.table_name as TABL_NAME_1,
                        UCC.column_name as COL_NAME,
                        parent.constraint_name as CONSTRNT_NAME
                   from all_constraints  parent,
                        all_constraints  child,
                        all_cons_columns UCC
                  where parent.r_constraint_name = child.constraint_name
                    and parent.r_owner = child.owner
                    and child.table_name = l_table
                    and child.owner = l_owner
                    and child.constraint_name = ucc.constraint_name
                    and child.owner = ucc.owner
                  order by 2, 3)
  loop
    if l_idx = 1
    then
      dbms_output.put_line('');
      dbms_output.put_line('Relation-ships');
      dbms_output.put_line('-------------------');
      l_head := true;
      dbms_output.put_line('   ' || l_table || ' is parent of:');
      dbms_output.put_line('      ' || rpad('Table Name', 60) || ' ' ||
                           rpad('Column', 30) || ' ' || 'Constraint Name');
      dbms_output.put_line('      ' || rpad('-', 60, '-') || ' ' ||
                           rpad('-', 30, '-') || ' ' || rpad('-', 30, '-'));
    end if;
    dbms_output.put_line('      ' || rpad(l_item.tabl_name_1, 61) ||
                         rpad(l_item.col_name, 31) || l_item.CONSTRNT_NAME);
    l_idx := l_idx + 1;
  end loop;
  l_idx := 1;
  for l_item in (select child.table_name as TABL_NAME_2,
                        parent.owner || '.' || parent.table_name as TABL_NAME_1,
                        ucc.column_name as COL_NAME,
                        child.constraint_name as CONSTRNT_NAME
                   from all_constraints  child,
                        all_constraints  parent,
                        all_cons_columns ucc
                  where child.r_constraint_name = parent.constraint_name
                    and child.r_owner = parent.owner
                    and child.owner = l_owner
                    and child.table_name = l_table
                    and child.constraint_name = ucc.constraint_name
                    and child.owner = ucc.owner
                  order by 2, 3)
  loop
    if l_idx = 1
    then
      dbms_output.put_line('');
      if not l_head
      then
        dbms_output.put_line('Relation-ships');
        dbms_output.put_line('-------------------');
      end if;
      dbms_output.put_line('   ' || l_table || ' is child for:');
      dbms_output.put_line('      ' || rpad('Table Name', 60) || ' ' ||
                           rpad('Column', 30) || ' ' || 'Constraint Name');
      dbms_output.put_line('      ' || rpad('-', 60, '-') || ' ' ||
                           rpad('-', 30, '-') || ' ' || rpad('-', 30, '-'));
    end if;
    dbms_output.put_line('      ' || rpad(l_item.tabl_name_1, 61) ||
                         rpad(l_item.col_name, 31) || l_item.CONSTRNT_NAME);
    l_idx := l_idx + 1;
  end loop;

end;
/
prompt

undefine 1
undefine 2
