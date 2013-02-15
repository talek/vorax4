-- OMNI SCHEMA FETCHER
-- 
-- This script is used to fetch all schema objects matching the provided prefix when
-- the Vorax omni-completion requests it. 
--
-- This script expects the following parameters:
--   1st parameter = the schema name
--   2nd parameter = the object prefix
--   3rd parameter = the maximum number of items to be returned
--
-- Note: One might think the implementation is stupid. Well, this is the price for
-- performance. Querying ALL_OBJECTS is famous for its bad performance. Here we try
-- to get all objects for a provided schema taking into account just some relevant
-- object types and if the number of rows exceeds the 3rd parameter then we must
-- stop. I tried many stand-alone SQL implementations and, unfortunately, I always
-- ended up scanning the whole view. So, we use the workaround below.

set define off
set echo off
set define '&'
set verify off
set pause off
set null ''
set pagesize 0
set serveroutput on

declare
  l_index pls_integer := 0;
  l_first boolean := true;
begin
  for l_rec in (
    select object_name word,
          object_name abbr,
          object_type kind,
          '' menu
      from all_objects
    where owner = '&1'
      and object_name like replace(replace('&2', '_', '"_'), '%', '"%') || '%' escape '"') 
  loop
    exit when l_index = &3;
    if l_rec.kind = 'CLUSTER' or l_rec.kind = 'FUNCTION' or l_rec.kind = 'MATERIALIZED VIEW' or
      l_rec.kind = 'PACKAGE' or l_rec.kind = 'PROCEDURE' or l_rec.kind = 'SEQUENCE' or
      l_rec.kind = 'TABLE' or l_rec.kind = 'TYPE' or l_rec.kind = 'VIEW' 
    then
      if l_first then
        dbms_output.put_line('<table>');
        l_first := false;
      end if;
      dbms_output.put_line('<tr><td>' || l_rec.word || '</td>' || 
                               '<td>' || l_rec.abbr || '</td>' ||
                               '<td>' || l_rec.kind || '</td>' ||
                               '<td>' || l_rec.menu || '</td></tr>');
      l_index := l_index + 1;
    end if;
  end loop;
  if not l_first then
    dbms_output.put_line('</table>');
  end if;
end;
/
