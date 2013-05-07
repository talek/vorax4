create or replace package global as

  cursor c1 is
    select * from all_tables;

	type shit_rec is record (
		small_shit varchar2(10),
		medium_shit varchar2(300),
		big_shit varchar2(4000),
		mega_sit clob);

end;
/
