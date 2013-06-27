-- This script is invoked by VoraX to get only the explain plan for
-- a provided statement. Feel free to change it according to your
-- needs.
--
-- The &1 parameter is the sql script which contains the statement
-- to be explained. All current sqlplus options are saved before
-- and restore after, therefore you may set whatever sqlplus
-- option you want.

set termout on
set linesize 10000
set define '&'
set timing off
set verify off
set autotrace traceonly explain
@&1

undefine 1
