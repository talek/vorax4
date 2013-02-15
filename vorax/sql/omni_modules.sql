-- OMNI MODULES FETCHER
-- 
-- This script is used to fetch functions/procedures matching the provided prefix when
-- the Vorax omni-completion requests it. 
-- The following completion types must be addressed:
--   *) modules declared within a package
--   *) modules declared within a type
--
-- You may change the query below, but it is important to keep the order of the
-- defined columns.
--
-- This script expects the following parameters:
--   1st parameter = the object ID of the package or type

set define off
set echo off
set define '&'
set verify off
set pause off
set null ''
set markup html on
set pagesize 0

select distinct procedure_name word,
       procedure_name abbr,
       '' kind,
       '' menu
  from all_procedures
 where object_id = '&1';

