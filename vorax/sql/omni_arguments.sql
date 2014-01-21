-- OMNI ARGUMENTS FETCHER
-- 
-- This script is used to fetch the arguments needed for OMNI completion.
-- You may change it, but it is important to keep the order of the
-- columns defined below.
--
-- This script expects the following parameters:
--   1st parameter = the schema name
--   2nd parameter = the package/type name. '' if it's a standalone func or proc
--   3nd parameter = the name of the sub-module (second level: eg. function of a package)
--                   or the name of the standalone func or proc
-- 
-- Remarks:
-- Identifying by the object id is not a valid approach in 12c
-- because of those METADATA LINK objects.
--

set define off
set echo off
set define '&'
set verify off
set pause off
set null ''
set markup html on
set pagesize 0

column def_arg new_value is_default
set termout off
select case when to_number(substr('&_O_RELEASE', 1, 2)) < 11 then
         '''N''' 
       else
        'defaulted'
       end def_arg from dual;
set termout on

select argument_name || ' => '  word, 
       decode(is_default, 'Y', '[' || argument_name || ']', argument_name) abbr,
       in_out || ' ' || data_type kind, 
       decode(overload, null, ' ' ,'o' || OVERLOAD) menu
  from (select argument_name, 
               object_name,
               package_name,
               owner,
               in_out, 
               data_type, 
               data_level,
               overload, 
               position,
               &is_default. is_default
          from all_arguments)
 where owner = '&1'
   and nvl(package_name, '"') = nvl('&2', '"')
   and object_name = '&3'
   and argument_name is not null
   and data_level = 0
order by overload, position;

undefine 1
undefine 2
undefine 3
