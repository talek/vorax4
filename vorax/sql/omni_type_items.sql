-- OMNI TYPE ITEMS FETCHER
-- 
-- This script is used to fetch the items of an Oracle type matching the provided prefix when
-- the Vorax omni-completion requests it. 
-- The following completion types must be addressed:
--   *) attributes declared into a type
--   *) methods from the type
--
-- You may change the query below, but it is important to keep the order of the
-- defined columns.
--
-- This script expects the following parameters:
--   1st parameter = the type schema
--   2nd parameter = the type name

set define off
set echo off
set define '&'
set verify off
set pause off
set null ''
set markup html on
set pagesize 0

select distinct t.*
from
(
  select attr_name word,
        attr_name abbr,
        attr_type_name kind,
        '' menu
    from all_type_attrs
  where owner = '&1'
    and type_name = '&2'
  union
  select method_name word,
        method_name abbr,
        '' kind,
        '' menu
    from all_type_methods
  where owner = '&1'
    and type_name = '&2'
) t;


undefine 1
undefine 2
