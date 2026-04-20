-- library management system

create database sql_project2;

create table Branch( 
branch_id varchar(10) Primary key,
manager_id varchar(10),
branch_address varchar(55),
contact_no varchar(10)
);

alter table branch
modify column contact_no varchar(20);

create table employees(
emp_id varchar(10) primary key,
emp_name varchar(25),
position varchar(15),
salary int,
branch_id varchar(25)
);

Alter table employees
modify column emp_name varchar(50);

drop table employees;

create table book(
isbn varchar(20) Primary key,
book_title varchar(75),
category varchar(10),
rental_price float,
status varchar(115),
author varchar(35),
publisher varchar(55)
);

alter table book
modify column category varchar(20);

create table members(
member_id varchar(10) primary key,
member_name	varchar(25),
member_address varchar(75),
reg_date date
);

create table issued_status(
issued_id varchar(10) Primary key,
issued_member_id varchar(10),   
issued_book_name varchar(75),
issued_date	date,
issued_book_isbn varchar(25),  
issued_emp_id varchar(10)      
);

Alter table issued_status
modify column issued_book_name varchar(150);

Alter table issued_status
modify column issued_book_isbn varchar(35);

drop table issued_status;

create table return_status(
return_id varchar(10) Primary key,	
issued_id varchar(10),
return_book_name varchar(75),
return_date date,
return_book_isbn varchar(20)
);

-- foreign key we shd add in issued_status

create table issued_status(
issued_id varchar(10) Primary key,
issued_member_id varchar(10),   -- FK
issued_book_name varchar(75),
issued_date	date,
issued_book_isbn varchar(25),  -- FK
issued_emp_id varchar(10)      -- FK
);

alter table issued_status
add constraint fk_members
foreign key (issued_member_id)
references members(member_id);

alter table issued_status
add constraint fk_books
foreign key (issued_book_isbn)
references book(isbn);

alter table issued_status
add constraint fk_employees
foreign key (issued_emp_id)
references employees(emp_id);

alter table employees
add constraint fk_branch
foreign key (branch_id)
references branch(branch_id);

alter table return_status
add constraint fk_issued_status
foreign key (issued_id)
references issued_status(issued_id);











