-- SIMPLE DESC
-- It describes the provided name.
--
-- Parameters:
--   1st => the name to be described.

set define '&'
set verify off
set pause off
set linesize 80

prompt
prompt [&1.] object description below:
desc &1

undefine 1
