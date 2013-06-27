-- OBJECTS SUPPORTING DESC
-- 
-- This script is used to fetch all object names matching the provided type and
-- prefix. This script is used for providing completion within the Vorax DESC
-- feature
--
-- This script expects the following parameters:
--   1st parameter = owner
--   2nd parameter = the prefix

set echo off
set define '&'
set verify off
set pause off
set null ''
set markup html on
set pagesize 0

select decode('&1', '', '', '&1..') || object_name word
  from all_objects
 where object_type in ('TABLE', 'VIEW', 'SYNONYM', 'PACKAGE', 'TYPE', 'FUNCTION', 'PROCEDURE')
   and owner = nvl('&1', user)
   and object_name like replace(replace('&2', '_', '"_'), '%', '"%') || '%' escape '"'
/

undefine 1
undefine 2
