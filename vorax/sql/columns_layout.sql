-- COLUMNS LAYOUT
-- 
-- This script is used to get the size of a every column
-- from the provided query. It is used to enforce the
-- heading of the columns.
--
-- Note: this is a wrapper script. It is not supposed to
--       work like it is. Vorax will substitute the
--       "l_stmt initialize" marker with the actual
--       statement to be parsed.
--

set define off
set echo off
set define '&'
set verify off
set pagesize 0
set linesize 1000
set serveroutput on

declare
  l_c number;
  l_col_cnt number;
  l_rec_tab DBMS_SQL.DESC_TAB;
  l_col_metadata DBMS_SQL.DESC_REC;
  l_col_num number;
  l_stmt dbms_sql.varchar2s;
begin
  -- l_stmt initialize
  l_c := dbms_sql.open_cursor;
  dbms_sql.parse(l_c, l_stmt, 1, l_stmt.count, true, DBMS_SQL.NATIVE);
  DBMS_SQL.DESCRIBE_COLUMNS(l_c, l_col_cnt, l_rec_tab);
  dbms_output.put_line('<html><body><table>');
  dbms_output.put_line(' <tr>');
  dbms_output.put_line('  <th>name</th>');
  dbms_output.put_line('  <th>headsize</th>');
  dbms_output.put_line('  <th>maxsize</th>');
  dbms_output.put_line(' </tr>');
  for colidx in l_rec_tab.first .. l_rec_tab.last loop
    l_col_metadata := l_rec_tab(colidx);
    if l_col_metadata.col_type in (1, 96) and
      l_col_metadata.col_name_len > l_col_metadata.col_max_len then
      dbms_output.put_line(' <tr>');
      dbms_output.put_line('  <td>' || l_col_metadata.col_name || '</td>');
      dbms_output.put_line('  <td>' || l_col_metadata.col_name_len || '</td>');
      dbms_output.put_line('  <td>' || l_col_metadata.col_max_len || '</td>');
      dbms_output.put_line(' </tr>');
    end if;
  end loop;
  dbms_output.put_line('</table></body></html>');
  DBMS_SQL.CLOSE_CURSOR(l_c);
end;  
/
