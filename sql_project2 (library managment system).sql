select * from book;
select * from branch;
select * from employees;
select * from issued_status;
select * from members;
select * from return_status;

-- PROJECT TASK

-- CRUD Operations (create,read,update,delete)

-- 1. Create a New Book Record
-- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"

insert into book(isbn, book_title, category, rental_price, status, author, publisher)
values  
('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');

-- 2. Update an Existing Member's Address

update members
set member_address = '125 Main st'
where member_id = 'C101';

-- 3. Delete a Record from the Issued Status Table 
-- Objective: Delete the record with issued_id = 'IS121' from the issued_status table.

delete from issued_status
where issued_id = 'IS121';

-- 4. Retrieve All Books Issued by a Specific Employee 
-- Objective: Select all books issued by the employee with emp_id = 'E101'.

select * from issued_status
where issued_emp_id = 'E101';

-- 5. List Members Who Have Issued More Than One Book 
-- Objective: Use GROUP BY to find members who have issued more than one book.

select issued_emp_id,count(issued_id) as total_book_issued 
from issued_status
group by issued_emp_id
having count(issued_id) >1;

-- CTAS (Create Table As Select)

--  6. Create Summary Tables: Used CTAS 
-- to generate new tables based on query results - each book and total book_issued_cnt**

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

-- Data Analysis & Findings
-- The following SQL queries were used to address specific questions:

-- 7. Retrieve All Books in a Specific Category.

select * from book
where category = 'classic';

-- 8. Find Total Rental Income by Category.

select 
     b.category,
     sum(b.rental_price),
     count(*)
from book as b
join
issued_status as ist
ON ist.issued_book_isbn = b.isbn
group by 1;

-- 9. List Members Who Registered in the Last 180 Days:

select * from members
where reg_date >= current_date - interval 180 day;

insert into members(member_id, member_name, member_address, reg_date)
values
('C120','SAMUEL','145 Main St', '2026-06-01'),
('C121','JO','133 Main St', '2026-05-01');

-- 10. List Employees with Their Branch Manager's Name and their branch details:

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

-- 11. Create a Table of Books with Rental Price Above a Certain Threshold 7USD.

create table books_greater_than_seven
as
select * from book
where rental_price > 7.00;

select * from books_greater_than_seven;

-- 12. Retrieve the List of Books Not Yet Returned

select
    distinct ist.issued_book_name
from issued_status as ist
left join
return_status as rs
ON ist.issued_id = rs.issued_id
where rs.return_id IS NULL;

-- Advanced SQL Operations

-- 13. Identify Members with Overdue Books
-- Write a query to identify members who have overdue books (assume a 30-day return period). 
-- Display the member's_id, member's name, book title, issue date, and days overdue.

-- logic 
-- issued_status == members == book == return_status
-- filter books which is return
-- overdue > 30 days

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

-- 14.  Update Book Status on Return
-- Write a query to update the status of books in the book table to "Yes" when they are returned (based on entries in the return_status table).

-- manually
select * from issued_status
where issued_book_isbn = '978-0-451-52994-2';

select * from book
where isbn = '978-0-451-52994-2';

update book
set status = 'no'
where isbn = '978-0-451-52994-2';

select * from return_status
where issued_id = 'IS130';

insert into return_status(return_id, issued_id, return_date)
values
('RS125', 'IS130', current_date);

select * from return_status
where issued_id = 'is130';

update book
set status = 'yes'
where isbn = '978-0-451-52994-2';

-- solve by using stored procedure
delimiter //

create procedure add_return_records()
BEGIN
-- all logic and code
END //

delimiter ;

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

CALL add_return_records('RS148', 'IS140');

-- 15: Branch Performance Report
-- Create a query that generates a performance report for each branch, 
-- showing the number of books issued, 
-- the number of books returned and 
-- the total revenue generated from book rentals.

select * from branch;

select * from issued_status;

select * from employees;

select * from book;

select * from return_status;

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

-- 16. CTAS: Create a Table of Active Members
-- Use the CREATE TABLE AS (CTAS) statement 
-- to create a new table active_members containing members who have issued at least one book in the last 4 years.

create table active_members
AS
select * from members
where member_id IN (select
                     distinct issued_member_id
					 from issued_status
					 where 
                     issued_date >= current_date - interval 4 year) ;

Drop table Active_members;

select * from active_members;

-- 17. Find Employees with the Most Book Issues Processed
-- Write a query to find the top 3 employees who have processed the most book issues. 
-- Display the employee name, number of books processed, and their branch.

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

-- 18: Stored Procedure 
-- Objective: Create a stored procedure to manage the status of books in a library system. 
-- Description: Write a stored procedure that updates the status of a book in the library based on its issuance. 
-- The procedure should function as follows: 
-- The stored procedure should take the book_id as an input parameter. 
-- The procedure should first check if the book is available (status = 'yes'). 
-- If the book is available, it should be issued, and the status in the books table should be updated to 'no'. 
-- If the book is not available (status = 'no'), the procedure should return an error message indicating that the book is currently not available.

select * from book;

select * from issued_status;

delimiter //

create procedure issue_book()
BEGIN
-- all logic and code
END //

delimiter ;

DROP PROCEDURE IF EXISTS issue_book;

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














