set verify off
set feedback off

prompt Create Address_typ type
create or replace type address_typ as object (
	street varchar2(100),
	city varchar2(50)
);
/

prompt Create Person_typ type
create or replace type person_typ as object (
	name varchar2(100),
	address address_typ
);
/


prompt Create DEPARTMENTS_ID sequence
create sequence departments_id;

prompt Create DEPARTMENTS table
create table departments (
  id integer,
  name varchar2(50),
  description varchar2(4000)
);

alter table departments add constraint pk_departments primary key (id);

comment on table departments is 'All departments.';
comment on column departments.id is 'The department id.';
comment on column departments.name is 'The department name.';
comment on column departments.description is 'The description of this department.';

insert into departments (id, name, description) 
     values (departments_id.nextval, 'Bookkeeping', 'This department is responsible for:' ||
                                                    chr(10) || '- financial reporting' ||
                                                    chr(10) || '- analysis' ||
                                                    chr(10) || '- other boring tasks');
insert into departments (id, name)
     values (departments_id.nextval, 'Marketing');
insert into departments (id, name)
     values (departments_id.nextval, 'Deliveries');
insert into departments (id, name)
     values (departments_id.nextval, 'CRM');
insert into departments (id, name)
     values (departments_id.nextval, 'Legal Stuff');
insert into departments (id, name, description)
     values (departments_id.nextval, 'Management', 'The bad guys department');
insert into departments (id, name)
     values (departments_id.nextval, 'Cooking');
insert into departments (id, name)
     values (departments_id.nextval, 'Public Relations');
insert into departments (id, name)
     values (departments_id.nextval, 'Aquisitions');
insert into departments (id, name)
     values (departments_id.nextval, 'Cleaning');
commit;

prompt Create EMPLOYEES_ID sequence
create sequence employees_id;

prompt Create EMPLOYEES table
create table EMPLOYEES (
  id integer,
  name nvarchar2(100),
  salary number,
  department_id integer);

alter table employees add constraint pk_employees primary key (id);
alter table employees add constraint fk_employees_departments foreign key (department_id) references departments(id);

comment on table employees is 'All employees baby.';
comment on column employees.id is 'The employee identifier.';
comment on column employees.name is 'The name of the employee.';
comment on column employees.salary is 'The employee salary.';
comment on column employees.department_id is 'The department identifier to which the employee is registered.';

insert into employees (id, name, salary, department_id) values (employees_id.nextval, 'Tic' || unistr('\0103') || ' ' || unistr('\0218') || 'erban', 570, 1);
commit;

prompt Done.
quit
