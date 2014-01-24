-- OMNI WORD FETCHER
-- 
-- This script is used to fetch words matching the provided prefix when
-- the Vorax omni-completion requests it. 
-- The following completion types must be addressed:
--   *) schemas matching the prefix
--   *) database objects matching the prefix: tables, views, synonyms, sequences, packages etc.
--
-- You may change the query below, but it is important to keep the order of the
-- defined columns.
--
-- This script expects the following parameters:
--   1st parameter = the word prefix
--   2nd parameter = the maximum number of items to be returned

set echo off
set define '&'
set verify off
set pause off
set null ''
set markup html on
set pagesize 0

select *
  from (
    select object_name word,
           object_name abbr,
           object_type kind,
           '' menu
      from (
        select object_name,
               object_type,
               owner,
               count(*) over (partition by object_name) group_count
          from all_objects
         where owner in (sys_context('userenv', 'session_user'), 'PUBLIC')
           and object_type in ('CLUSTER', 'FUNCTION', 'MATERIALIZED VIEW', 'PACKAGE', 
                               'PROCEDURE', 'SEQUENCE', 'SYNONYM', 'TABLE', 'TYPE', 'VIEW')
           and object_name like replace(replace('&1', '_', '"_'), '%', '"%') || '%' escape '"'
        ) 
        where group_count = 1 or owner = sys_context('userenv', 'session_user')
    union all
    select username word,
           username abbr,
           'SCHEMA' kind,
           '' menu
      from all_users
     where username like replace(replace('&1', '_', '"_'), '%', '"%') || '%' escape '"'
    union all
    select distinct procedure_name word,
           procedure_name abbr,
           '' kind,
           '' menu
      from all_procedures
     where owner = 'SYS'
       and object_name = 'STANDARD'
       and procedure_name like replace(replace('&1', '_', '"_'), '%', '"%') || '%' escape '"'
  ) 
 where rownum <= &2
order by 1;

undefine 1
undefine 2
