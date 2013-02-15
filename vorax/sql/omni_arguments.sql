-- OMNI ARGUMENTS FETCHER
-- 
-- This script is used to fetch the arguments needed for OMNI completion.
-- You may change it, but it is important to keep the order of the
-- columns defined below.
--
-- This script expects the following parameters:
--   1st parameter = the object identifier
--   2nd parameter = the name of the sub-module (second level: eg. function of a package)

set define off
set echo off
set define '&'
set verify off
set pause off
set null ''
set markup html on
set page 0

select argument_name || ' => '  word, 
       decode(defaulted, 'Y', '[' || argument_name || ']', argument_name) abbr,
       in_out || ' ' || data_type kind, 
       decode(overload, null, ' ' ,'o' || OVERLOAD) menu
  from all_arguments
 where object_id = '&1'
   and object_name = '&2'
   and argument_name is not null
   and data_level = 0
order by overload, position;
