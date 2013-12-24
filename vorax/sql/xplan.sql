-- Display the DBMS_XPLAN plan of the provided statement.
-- Params:
--   1st param: the script containing the statement to be described.
--   2st param: the DBMS_XPLAN format of the DISPLAY_CURSOR procedure.
--
var plan clob
var plan_length number
set define '&'
set pages 0
set serveroutput off
set verify off
set autot trace stat
set timing on

prompt
prompt Executing the statement...
prompt
@&1

set feedback off
set timing off
begin
  dbms_lob.createtemporary (lob_loc => :plan, cache => TRUE);
  :plan := '';
  for l_rec in (SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY_CURSOR(null, null, '&2'))) loop
    :plan := :plan || l_rec.plan_table_output || chr(10);
  end loop;
  -- don't bother to get the exact size in bytes. Get the length in chars and
  -- multiply by 4, which is the maximum size for a char in AL32UTF8.
  :plan_length := length(:plan) * 4;
end;
/
set autot off
set termout off
column clob_len new_value clob_len
select :plan_length clob_len from dual;
set longc &clob_len
set long &clob_len
set termout on

prompt
print :plan
column clob_len clear

undefine 1
undefine 2
undefine clog_len
