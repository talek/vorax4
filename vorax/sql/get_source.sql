-- SOURCE FETCHER
-- 
-- This script is used to fetch the source of a PL/SQL module.
--
-- This script expects the following parameters:
--   1st parameter = the owner
--   2nd parameter = the object name
--   3rd parameter = the object type

set define off
set echo off
set define '&'
set verify off
set pause off
set null ''
set markup html on
set pagesize 0
set linesize 10000

column vorax_line_$$ format a4000

select text vorax_line_$$
  from all_source
 where owner = '&1'
   and name = '&2'
   and type = '&3'
order by line;

column vorax_line_$$ clear

