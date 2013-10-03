-- OBJECT NAMES FETCHER
-- 
-- This script is used to fetch all object names matching the provided type and
-- prefix. This script is used for providing completion within the Vorax DBExplore
-- feature
--
-- This script expects the following parameters:
--   1st parameter = the object type
--   2nd parameter = owner
--   3nd parameter = the prefix

set define off
set echo off
set define '&'
set verify off
set pause off
set null ''
set markup html on
set pagesize 0

select decode('&2', '', '', '&2..') || object_name word
  from all_objects
 where object_type = '&1'
   and owner = nvl('&2', user)
   and object_name like replace(replace('&3', '_', '"_'), '%', '"%') || '%' escape '"'
union 
select decode('&2', '', '', '&2..') || db_link word
  from all_db_links
 where owner = nvl('&2', user)
   and '&1' = 'DB_LINK'
   and db_link like replace(replace('&3', '_', '"_'), '%', '"%') || '%' escape '"'
union
select username
  from all_users
 where '&1' = 'USER'
   and username like replace(replace('&3', '_', '"_'), '%', '"%') || '%' escape '"'
/

undefine 1
undefine 2
undefine 3
