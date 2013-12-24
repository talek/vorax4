-- ORACLE NAME RESOLVER
--
-- Resolves the name provided as parameter to the corresponding
-- object. Vorax uses this resolver in order to get the underlying
-- database object referenced, especially, via a SYNONYM. The output
-- is a HTML table with one row and four columns:
--   1st column: oracle schema
--   2nd column: object name
--   3rd column: object type
--   4th column: the object ID
--   5th column: extra name (e.g. the function within a package)
--
-- LIMITATIONS: 
--   *) does not work for objects referenced through db links
--   *) the 10g resolving rules are applied. Vorax doesn't support
--      Oracle versions lower than 10g anyway.
--
-- Note 1: If the name to be resolved is simply an Oracle schema, then 
-- the 1st column will contain the schema name and the 3rd will have
-- 'SCHEMA' as type. All the other columns will be left empty.
--
-- Note 2: What a pitty DBMS_UTILITY.NAME_RESOLVE does not work for 
-- tables and it's so damn stupid documented. Its behaviour is
-- not consistent accross Oracle database versions therefore we
-- stay away from it!

set serveroutput on
set define off
set echo off
set define '&'
set verify off

declare
  type object_table is table of char(1) index by varchar2(200);
  l_objects     object_table;
  l_name        varchar2(500) := '&1';
  l_result      varchar2(32767);
  l_extra       varchar2(300);
  l_part1       varchar2(100);
  l_part2       varchar2(100);
  l_part3       varchar2(100);
  l_db_link     varchar2(120);
  l_next_pos    pls_integer;
  l_object_id   all_objects.object_id%type;
  ex_object_id_missing exception;
  pragma exception_init(ex_object_id_missing, -00904);

  function resolve(object_in in varchar2,
                   owner_in  in varchar2,
                   first_in  in boolean) return varchar2
  is
    l_owner         all_objects.owner%type;
    l_object        all_objects.object_name%type;
    l_object_type   all_objects.object_type%type;
    l_temp          varchar2(32767);
    l_dummy         integer;
    l_schema_exists boolean;
  begin
    if l_objects.exists('"' || owner_in || '"."' || object_in || '"') then
      -- circular loop, give up...
      l_temp := null;
    else
      l_objects('"' || owner_in || '"."' || object_in || '"') := null;

      begin
        -- what type of object are we looking at?
        select object_id, object_type
          into l_object_id, l_object_type
          from all_objects
         where object_name = object_in 
           and owner = owner_in
           and object_type in ('CLUSTER', 'FUNCTION', 'MATERIALIZED VIEW', 
                               'PACKAGE', 'PROCEDURE', 'SYNONYM', 'TABLE', 
                               'SEQUENCE', 'TYPE', 'VIEW')
           and rownum <= 1;

        l_temp := '<td>' || owner_in || '</td><td>' || object_in || '</td>';

        if l_object_type = 'SYNONYM' then
          select table_owner, table_name
            into l_owner, l_object
            from all_synonyms
           where synonym_name = object_in 
             and owner = owner_in 
             and db_link is null
             and rownum <= 1;

          l_temp := resolve(l_object, l_owner, false);
        else
          l_temp := l_temp || '<td>' || l_object_type || '</td>'
            || '<td>' || l_object_id || '</td>';
        end if;
      exception
        when no_data_found then
          if (not first_in) then
            for l_rec in (select 1 from all_users where username = owner_in) loop
              l_schema_exists := true;
            end loop;
          end if;

          if first_in or l_schema_exists then
            l_temp := resolve(object_in, 'PUBLIC', false);
          end if;
      end;
    end if;

    return l_temp;
  end;

begin
  dbms_utility.name_tokenize(l_name, l_part1, l_part2, l_part3, l_db_link, l_next_pos);
  -- check the first part of the identifier
  l_result := resolve(l_part1, user, true);
  l_extra := l_part2;
  if l_result is null then
    if l_part2 is not null then
      -- check the second part
      l_result := resolve(l_part2, l_part1, true);
      l_extra := l_part3;
    else
      -- maybe l_part1 is a schema
      for l_rec in (select 1 from all_users where username = l_part1) loop
        l_result := '<td>' || l_part1 || '</td><td></td><td>SCHEMA</td><td></td>';
      end loop;
      if l_result is null then
        -- maybe it's a standard function
        -- object_id in all_procedures is not available in
        -- 10gR1 or lower
        begin
          execute immediate 'select object_id ' ||
                            '  from all_procedures ' ||
                            '  where owner = ''SYS''' ||
                            '  and object_name = ''STANDARD''' ||
                            '  and procedure_name = :1' 
                  into l_object_id using l_part1;
          l_result := '<td>SYS</td><td>STANDARD</td><td>PACKAGE</td><td>' 
            || l_object_id || '</td>';
          l_extra := l_part1;
        exception
          when ex_object_id_missing then
            null;
        end;
      end if;
    end if;
  end if;
  if l_result is not null then
    dbms_output.put_line('<table><tr>' || l_result || '<td>' || l_extra || '</td>' ||  '</tr></table>');
  end if;
end;
/

undefine 1
undefine 2
undefine 3
undefine 4
undefine 5
