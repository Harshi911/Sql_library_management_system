# Library management system using SQL.

Project Overview

Project Title: Library Management System
Level: Intermediate
Database: library_db

This project demonstrates the implementation of a Library Management System using SQL. It includes creating and managing tables, performing CRUD operations, and executing advanced SQL queries. The goal is to showcase skills in database design, manipulation, and querying.

Objectives

1. Set up the Library Management System Database: Create and populate the database with tables for branches, employees, members, books, issued status, and return status.
2. CRUD Operations: Perform Create, Read, Update, and Delete operations on the data.
3. CTAS (Create Table As Select): Utilize CTAS to create new tables based on query results.
4. Advanced SQL Queries: Develop complex queries to analyze and retrieve specific data.

5. Project Structure

6. 1. Database Setup
      Database Creation
      Table Creation : Created tables for branches, employees, members, books, issued status, and         return status. Each table includes relevant columns and relationships.

```sql
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
```

2.  CRUD Operations
Create: Inserted sample records into the books table.
Read: Retrieved and displayed data from various tables.
Update: Updated records in the employees table.
Delete: Removed records from the members table as needed.

Task 1. Create a New Book Record -- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"

```sql
insert into book(isbn, book_title, category, rental_price, status, author, publisher)
values  
('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');
```

Task 2: Update an Existing Member's Address

```sql
update members
set member_address = '125 Main st'
where member_id = 'C101';
```

Task 3: Delete a Record from the Issued Status Table -- Objective: Delete the record with issued_id = 'IS121' from the issued_status table.

```sql
delete from issued_status
where issued_id = 'IS121';
```

Task 4: Retrieve All Books Issued by a Specific Employee -- Objective: Select all books issued by the employee with emp_id = 'E101'.

```sql
select * from issued_status
where issued_emp_id = 'E101';
```

Task 5: List Members Who Have Issued More Than One Book -- Objective: Use GROUP BY to find members who have issued more than one book.

```sql
select issued_emp_id,count(issued_id) as total_book_issued 
from issued_status
group by issued_emp_id
having count(issued_id) >1;
```

3. CTAS (Create Table As Select)
   
Task 6: Create Summary Tables: Used CTAS to generate new tables based on query results - each book and total book_issued_cnt**

```sql
create table book_cnts
as
select 
     b.isbn, 
     b.book_title,
     count(ist.issued_id) as no_issued
from book as b
join
issued_status as ist
ON ist.issued_book_isbn = b.isbn
group by 1,2;

select * from book_cnts;
```

4. Data Analysis & Findings
The following SQL queries were used to address specific questions:

Task 7. Retrieve All Books in a Specific Category:

```sql
select * from book
where category = 'classic';
```

Task 8: Find Total Rental Income by Category:

```sql
select 
     b.category,
     sum(b.rental_price),
     count(*)
from book as b
join
issued_status as ist
ON ist.issued_book_isbn = b.isbn
group by 1;
```

Task 9: List Members Who Registered in the Last 180 Days:

```sql
select * from members
where reg_date >= current_date - interval 180 day;

insert into members(member_id, member_name, member_address, reg_date)
values
('C120','SAMUEL','145 Main St', '2026-06-01'),
('C121','JO','133 Main St', '2026-05-01');
```

Task 10 : List Employees with Their Branch Manager's Name and their branch details:

```sql
select
    e1.*,
    b.manager_id,
    e2.emp_name as manager
from employees as e1
join
branch as b
ON b.branch_id = e1.branch_id
join
employees as e2
ON b.manager_id = e2.emp_id;
```

Task 11 : Create a Table of Books with Rental Price Above a Certain Threshold:

```sql
create table books_greater_than_seven
as
select * from book
where rental_price > 7.00;
```

task 12 : Retrieve the List of Books Not Yet Returned

```sql
select
    distinct ist.issued_book_name
from issued_status as ist
left join
return_status as rs
ON ist.issued_id = rs.issued_id
where rs.return_id IS NULL;
```

Advanced SQL Operations
Task 13: Identify Members with Overdue Books
Write a query to identify members who have overdue books (assume a 30-day return period). Display the member's_id, member's name, book title, issue date, and days overdue.

```sql
select
    ist.issued_member_id,
    m.member_name,
    bk.book_title,
    ist.issued_date,
    rs.return_date,
    current_date - ist.issued_date as over_dues
from issued_status as ist
join
members as m
on m.member_id = ist.issued_member_id
join
book as bk
on bk.isbn = ist.issued_book_isbn
left join
return_status as rs
on rs.issued_id = ist.issued_id
where rs.return_date is null
and
(current_date - ist.issued_date) > 30
order by 1;
```

Task 14: Update Book Status on Return
Write a query to update the status of books in the books table to "Yes" when they are returned (based on entries in the return_status table).

```sql
DELIMITER //

CREATE PROCEDURE add_return_records(
    IN p_return_id VARCHAR(10),
    IN p_issued_id VARCHAR(10)
)
BEGIN

    DECLARE v_isbn VARCHAR(50);
    DECLARE v_book_name VARCHAR(80);

    -- Insert into return_status
    INSERT INTO return_status (return_id, issued_id, return_date)
    VALUES 
          (p_return_id, p_issued_id, CURRENT_DATE);

    -- Get book details
    SELECT issued_book_isbn, issued_book_name
    INTO v_isbn, v_book_name
    FROM issued_status
    WHERE issued_id = p_issued_id;

    -- Update book status
    UPDATE book
    SET status = 'yes'
    WHERE isbn = '978-0-451-52994-2';

    -- Print message
    SELECT CONCAT('Thank you for returning the book: ', v_book_name) AS message;

END //

DELIMITER ;

DROP PROCEDURE IF EXISTS add_return_records;

CALL add_return_records('RS138', 'IS135');
```

Task 15: Branch Performance Report
Create a query that generates a performance report for each branch, showing the number of books issued, the number of books returned, and the total revenue generated from book rentals.

```sql
create table branch_reports
select 
    b.branch_id, 
    b.manager_id,
    count(ist.issued_id) as number_book_issued,
    count(rs.return_id) as number_of_book_return,
    SUM(bk.rental_price) as total_revenue
    from issued_status as ist
join
employees as e
ON e.emp_id = ist.issued_emp_id
join
branch as b
ON e.branch_id = b.branch_id
left join
return_status as rs
ON rs.issued_id = ist.issued_id
join
book as bk
ON ist.issued_book_isbn = bk.isbn;
```

Task 16: CTAS: Create a Table of Active Members
Use the CREATE TABLE AS (CTAS) statement to create a new table active_members containing members who have issued at least one book in the last 4years.

```sql
create table active_members
AS
select * from members
where member_id IN (select
                     distinct issued_member_id
					 from issued_status
					 where 
                     issued_date >= current_date - interval 4 year) ;

select * from active_members;
```

Task 17: Find Employees with the Most Book Issues Processed
Write a query to find the top 3 employees who have processed the most book issues. Display the employee name, number of books processed, and their branch.

select
    e.emp_name,
    b.*,
    count(ist.issued_id) as no_book_issued
from issued_status as ist
join 
employees as e
ON e.emp_id = ist.issued_emp_id
join
branch as b
ON e.branch_id = b.branch_id
group by 1,2;
```

Task 18: Stored Procedure Objective: Create a stored procedure to manage the status of books in a library system. Description: Write a stored procedure that updates the status of a book in the library based on its issuance. The procedure should function as follows: The stored procedure should take the book_id as an input parameter. The procedure should first check if the book is available (status = 'yes'). If the book is available, it should be issued, and the status in the books table should be updated to 'no'. If the book is not available (status = 'no'), the procedure should return an error message indicating that the book is currently not available.

```sql
DELIMITER //

CREATE PROCEDURE issue_book(
    IN p_issued_id VARCHAR(10),
    IN p_issued_member_id VARCHAR(30),
    IN p_issued_book_isbn VARCHAR(30),
    IN p_issued_emp_id VARCHAR(10)
)
BEGIN
    DECLARE v_status VARCHAR(10);

    -- Get book status
    SELECT status
    INTO v_status
    FROM book
    WHERE isbn = p_issued_book_isbn;

    -- Check if book is available 
    IF v_status = 'yes' THEN

        INSERT INTO issued_status(
            issued_id,
            issued_member_id,
            issued_date,
            issued_book_isbn,
            issued_emp_id
        )
        VALUES (
            p_issued_id,
            p_issued_member_id,
            current_date,
            p_issued_book_isbn,
            p_issued_emp_id
        );

        -- Update book status
        UPDATE book
        SET status = 'no'
        WHERE isbn = p_issued_book_isbn;

        -- Success message
        SELECT CONCAT('Book issued successfully. ISBN: ', p_issued_book_isbn) AS message;

    ELSE
        -- Failure message
        SELECT CONCAT('Book unavailable. ISBN: ', p_issued_book_isbn) AS message;
    END IF;

END //

DELIMITER ;

CALL issue_book('IS155', 'C108', '978-0-553-29698-2', 'E104');

CALL issue_book('IS156', 'C108', '978-0-375-41398-8', 'E104');
```

Reports
Database Schema: Detailed table structures and relationships.
Data Analysis: Insights into book categories, employee salaries, member registration trends, and issued books.
Summary Reports: Aggregated data on high-demand books and employee performance.

Conclusion
This project demonstrates the application of SQL skills in creating and managing a library management system. It includes database setup, data manipulation, and advanced querying, providing a solid foundation for data management and analysis.

Author - Harshitha.M.P
This project showcases SQL skills essential for database management and analysis.








































      
