-- EXTRACT DEFINITION
--
-- Extract the definition of the provided oracle object. The
-- following parameters are expected
--   1st parameter = the owner of the object
--   2nd parameter = the object name
--   3nd parameter = the object type
--
-- Note: Apparently, displaying a CLOB in sqlplus is not a 
-- trivial task. The following options are relevant:
--   set long
--   set longc
--   set linesize
-- For reference see: 
--   http://laurentschneider.com/wordpress/2008/07/set-longchunksize.html
-- 
-- Note: There is another twist: if you get the clob and set long and longc
-- options to the length of that clob, but the "markup html" is "on", you may
-- end up in troubles because the escaped clob size is grater than the
-- unescaped one. Apparently, the spit content counts for long and longc,
-- which makes even harder to figure out the size of the clob content to
-- be shown. The workaround was to get rid of the "markup html on" and
-- to fake the HTML table.

set define off
set echo off
set define '&'
set verify off
set pagesize 0
set linesize 1000
set heading off
set feedback off
set timing off
set time off

var ddl_def clob
var ddl_length number

declare
  
  function get_source(owner varchar2, obj_name varchar2, obj_type varchar2) return clob as
    h number;
    th number;
    doc clob;
  begin
    h := dbms_metadata.open(obj_type);

    if owner is not null then
      dbms_metadata.set_filter(h, 'SCHEMA', owner);
    end if;
    dbms_metadata.set_filter(h, 'NAME', obj_name);

    th := dbms_metadata.add_transform(h, 'MODIFY');

    if owner = user then
      -- don't include owner if matches the current connected user
      dbms_metadata.set_remap_param(th, 'REMAP_SCHEMA', user, '');
    end if;

    th := dbms_metadata.add_transform(h, 'DDL');
    if obj_type = 'TABLE' then
      dbms_metadata.set_transform_param(th, 'SEGMENT_ATTRIBUTES', false);
      dbms_metadata.set_transform_param(th, 'STORAGE', false);
    end if;
    dbms_metadata.set_transform_param(th, 'SQLTERMINATOR', true);
    dbms_metadata.set_transform_param(th, 'PRETTY', true);

    doc := dbms_metadata.fetch_clob(h);

    dbms_metadata.close(h);
    return doc;
  end;

  function get_metadata_item(item in varchar2, orauser in varchar2) return clob as
  begin
    return dbms_metadata.get_granted_ddl(item, orauser);
  exception
    when others then
      dbms_output.put_line(SQLERRM || ': '|| dbms_utility.format_error_backtrace);
      return null;
  end;

  function get_metadata_dependencies(obj_type in varchar2, item in varchar2, orauser in varchar2) return clob as
  begin
    return dbms_metadata.get_dependent_ddl(obj_type, item, orauser);
  exception
    when others then
      dbms_output.put_line(SQLERRM || ': '|| dbms_utility.format_error_backtrace);
      return null;
  end;

begin
  dbms_lob.createtemporary (lob_loc => :ddl_def, cache => TRUE);
  :ddl_def := ''; -- just init

  dbms_metadata.set_transform_param(dbms_metadata.session_transform, 'SEGMENT_ATTRIBUTES', FALSE);
  dbms_metadata.set_transform_param(dbms_metadata.session_transform, 'STORAGE', FALSE);
  dbms_metadata.set_transform_param(dbms_metadata.session_transform, 'SQLTERMINATOR', TRUE);
  dbms_metadata.set_transform_param(dbms_metadata.session_transform, 'PRETTY', TRUE);

  -- get and escape the DDL definition. 
  :ddl_def := get_source('&1', '&2', '&3');
  -- get grants
  if '&3' = 'USER' then
    -- get tablespace quotas
    :ddl_def := :ddl_def || chr(10) || get_metadata_item('TABLESPACE_QUOTA', '&2');
    -- get the default role
    :ddl_def := :ddl_def || chr(10) || get_metadata_item('DEFAULT_ROLE', '&2');
    -- get role grants
    :ddl_def := :ddl_def || chr(10) || get_metadata_item('ROLE_GRANT', '&2');
    -- get system grants
    :ddl_def := :ddl_def || chr(10) || get_metadata_item('SYSTEM_GRANT', '&2');
    -- get object grants
    :ddl_def := :ddl_def || chr(10) || get_metadata_item('OBJECT_GRANT', '&2');
  elsif '&3'= 'TABLE' then
    -- indexes not covered by PK and unique constraints
    for l_rec in (select owner, index_name 
                    from all_indexes i 
                    where i.table_owner = '&1' 
                      and i.table_name = '&2' 
                      and index_name not in (
                        select constraint_name 
                          from all_constraints a 
                        where a.owner = '&1'
                          and a.table_name = '&2')) loop
      :ddl_def := :ddl_def || chr(10) 
        || dbms_metadata.get_ddl('INDEX', l_rec.index_name, l_rec.owner);
    end loop;
  end if;
  if '&3' = 'TABLE' or '&3' = 'VIEW' or '&3' = 'SEQUENCE' then
    -- grants
    :ddl_def := :ddl_def || chr(10) || get_metadata_dependencies('OBJECT_GRANT', '&2', '&1');
  end if;
  :ddl_def := dbms_xmlgen.convert(:ddl_def);
  -- don't bother to get the exact size in bytes. Get the length in chars and
  -- multiply by 4, which is the maximum size for a char in AL32UTF8.
  :ddl_length := length(:ddl_def) * 4;
end;
/

-- we need the size of the clob and set it as a longchunksize in order
-- to avoid splitting the content.
column clob_len new_value clob_len
select :ddl_length clob_len from dual;
set longc &clob_len
set long &clob_len

prompt <table><tr><td>
select case when nvl(:ddl_length, 0) = 0 then to_clob('')
       else :ddl_def end from dual;
prompt </td></tr></table>

undefine clob_len
undefine 1
undefine 2
undefine 3
column clob_len clear
