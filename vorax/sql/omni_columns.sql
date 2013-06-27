-- OMNI COLUMNS FETCHER
-- 
-- This script is used to fetch columns matching the provided prefix when
-- the Vorax omni-completion requests it. 
-- The following completion types must be addressed:
--   *) columns for a table
--   *) columns for a view
--
-- You may change the query below, but it is important to keep the order of the
-- defined columns.
--
-- This script expects the following parameters:
--   1st parameter = the schema name
--   2nd parameter = the table or view name

set define off
set echo off
set define '&'
set verify off
set pause off
set null ''
set markup html on
set pagesize 0

select column_name word,
       column_name abbr,
       data_type kind,
       '' menu
  from all_tab_columns
 where owner = '&1'
   and table_name = '&2'
 order by column_id;

undefine 1
undefine 2
