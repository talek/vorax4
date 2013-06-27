-- OMNI DBLINKS FETCHER
-- 
-- This script is used to fetch all database links matching the provided prefix when
-- the Vorax omni-completion requests it. 
--
-- This script expects the following parameters:
--   1st parameter = the database link name prefix

set define off
set echo off
set define '&'
set verify off
set pause off
set null ''
set markup html on
set pagesize 0

select db_link,
       db_link,
       'dblink' kind,
       '' menu
  from all_db_links
 where db_link like replace(replace('&1', '_', '"_'), '%', '"%') || '%' escape '"';

undefine 1
