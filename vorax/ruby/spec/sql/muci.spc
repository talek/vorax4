create or replace package muci as
  
  MY_CONSTANT1 constant varchar2(100) := 'abc';
  MY_CONSTANT2 constant integer := 10;

  ex_no_data_found exception;
  pragma exception_init(ex_no_data_found, -20000);

  ex_custom exception;
  pragma exception_init(ex_custom, -20001);

  cursor my_cursor is
    select * from user_tables;

  type population_type is table of varchar2(100);

  g_var1 integer;
  g_var2 varchar2(100) := 'xyz';
  g_var3 dual.dummy%type;
  g_var4 all_objects%rowtype;

  procedure my_proc(p1 integer);
  function my_func(param1 varchar2, param2 boolean := true) return boolean;

  subtype id is varchar2(10);
end;
/
