set verify off
set feedback off

prompt Create VORAX_TEST user

grant create session, 
      create table, 
      create view,
      create sequence,
      create procedure,
      create type,
      create synonym,
      unlimited tablespace
   to vorax_test identified by xxx;

grant select on v_$sesstat to vorax_test;
grant select on v_$statname to vorax_test;
grant select on v_$mystat to vorax_test;

prompt Done.

quit
