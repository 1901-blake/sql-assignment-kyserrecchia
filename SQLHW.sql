------------------------------------------------------------------------------------------------------------
--SQL Lab
--POSTGRESQL HW 
--Author: Kyle Serrecchia
--Date: Jan 2019

------------------------------------------------------------------------------------------------------------
--1.0	Setting up Postgres Chinook

--In this section you will begin the process of working with the Oracle Chinook database
--Task – Open the Chinook_PostgreSql.sql file and execute the scripts within.

------------------------------------------------------------------------------------------------------------
--2.0 SQL Queries

--In this section you will be performing various queries against the Postgres Chinook database.

------------------------------------------------------------------------------------------------------------
--2.1 SELECT

--Task – Select all records from the Employee table.
select * from employee;

--Task – Select all records from the Employee table where last name is King.
select * from employee 
where lastname='King';

--Task – Select all records from the Employee table where first name is Andrew and REPORTSTO is NULL.
select * from employee 
where firstname='Andrew' and reportsto is null;

------------------------------------------------------------------------------------------------------------
--2.2 ORDER BY

--Task – Select all albums in Album table and sort result set in descending order by title.
select * from album 
order by title desc;

--Task – Select first name from Customer and sort result set in ascending order by city
select firstname from customer 
order by city asc;

------------------------------------------------------------------------------------------------------------
--2.3 INSERT INTO

--Task – Insert two new records into Genre table
	--next two lines for testing
	select * from genre;
	delete from genre where name='Post Punk' or name='Dubstep';

insert into genre(genreid, name) values((select count(*) from genre) + 1, 'Post Punk');
insert into genre(genreid, name) values((select count(*) from genre) + 1, 'Dubstep');

--Task – Insert two new records into Employee table
	--next two lines for testing
	select * from employee;
	delete from employee where firstname='Kyle' or firstname='Bella';

insert into employee(employeeid, lastname, firstname, title, 
						reportsto, birthdate, hiredate, 
						address, city, state, country, 
						postalcode, phone, fax, email)
			values((select count(*) from employee) + 1, 'Serrecchia', 'Kyle', 'CEO', 
						1, Timestamp '1990-07-14', Timestamp '2001-01-01', 
						'12702 Bruce B. Downs Blvd', 'Tampa', 'FL', 'USA',
						'33612', '+1 (661) 678-3532', '+1 (661) 678-3532', 'kyserrecchia@gmail.com');

insert into employee(employeeid, lastname, firstname, title, 
						reportsto, birthdate, hiredate, 
						address, city, state, country, 
						postalcode, phone, fax, email)
			values((select count(*) from employee) + 1, 'Jones-Serrecchia', 'Bella', 'Designated Pupper', 
						9, Timestamp '2016-11-14', Timestamp '2018-02-14', 
						'28550 Bud Court', 'Santa Clarita', 'CA', 'USA',
						'91350', '+1 (661) 678-3532', '+1 (661) 678-3532', null);
					
--Task – Insert two new records into Customer table
--next two lines for testing
	select * from customer;
	delete from customer where firstname='Kyle';

insert into customer(customerid, firstname, lastname, company,
						address, city, state, country, 
						postalcode, phone, fax, email, supportrepid)
			values((select count(*) from customer) + 1, 'Kyle', 'Serrecchia', null,
						'12702 Bruce B. Downs Blvd', 'Tampa', 'FL', 'USA',
						'33612', '+1 (661) 678-3532', null, 'kyserrecchia@gmail.com', 2);

insert into customer(customerid, firstname, lastname, company,
						address, city, state, country, 
						postalcode, phone, fax, email, supportrepid)
			values((select count(*) from customer) + 1, 'Bella', 'Jones-Serrecchia', null,
						'28550 Bud Court', 'Santa Clarita', 'CA', 'USA',
						'91350', '+1 (661) 678-3532', null, 'bjones-serrecchia@gmail.com', 4);

------------------------------------------------------------------------------------------------------------
--2.4 UPDATE

--Task – Update Aaron Mitchell in Customer table to Robert Walter
--next line for testing
select * from customer order by firstname;

update customer set firstname='Robert', lastname='Walter' 
where firstname='Aaron';
					
--Task – Update name of artist in the Artist table “Creedence Clearwater Revival” to “CCR”
--next line for testing
select * from artist order by name;

update artist set name='CCR'
where name='Creedence Clearwater Revival';
					
------------------------------------------------------------------------------------------------------------
--2.5 LIKE

--Task – Select all invoices with a billing address like “T%”
--next line for testing
select * from invoice;

SELECT * FROM invoice
WHERE billingaddress LIKE 'T%';

------------------------------------------------------------------------------------------------------------
--2.6 BETWEEN

--Task – Select all invoices that have a total between 15 and 50
select * from invoice
where total between 15 and 50;
					
--Task – Select all employees hired between 1st of June 2003 and 1st of March 2004
select * from employee 
where hiredate between Timestamp '2003-06-01' and Timestamp '2004-03-01';

------------------------------------------------------------------------------------------------------------
--2.7 DELETE

--Task – Delete a record in Customer table where the name is Robert Walter 
--(There may be constraints that rely on this, find out how to resolve them).

--tried to keep constraints but set all to cascade
alter table invoice 
drop constraint fk_invoicecustomerid;

ALTER TABLE invoice
add CONSTRAINT fk_invoicecustomerid
FOREIGN KEY (customerid) REFERENCES customer (customerid)
on delete cascade;

alter table invoice 
drop constraint invoice_customerid_fkey;

alter table invoice 
add constraint invoice_customerid_fkey
foreign key (customerid) references customer (customerid)
on delete cascade;

alter table invoiceline 
drop constraint fk_invoicelineinvoiceid;

alter table invoiceline
add constraint fk_invoicelineinvoiceid
foreign key (invoiceid) references invoice (invoiceid)
on delete cascade;


delete from customer 
where firstname='Robert' and lastname='Walter';

--next line for testing
--select * from customer order by firstname desc;
  

------------------------------------------------------------------------------------------------------------
--3.0	SQL Functions

--In this section you will be using the Oracle system functions, 
--as well as your own functions, to perform various actions against the database
				
------------------------------------------------------------------------------------------------------------
--3.1 System Defined Functions
--Task – Create a function that returns the current time.
create or replace function getCurrentTime()
returns Timestamp as $$
begin
    return (select now());
end;
$$ language plpgsql;

--test
select getCurrentTime();
					
--Task – create a function that returns the length of a mediatype from the mediatype table
create or replace function getMediaTypeLength()
returns integer as $$
begin	
	return (select count(*) from mediatype);
end;
$$ language plpgsql;

--test
select getMediaTypeLength();

					
------------------------------------------------------------------------------------------------------------

--3.2 System Defined Aggregate Functions

--Task – Create a function that returns the average total of all invoices
create or replace function averageInvoiceTotal()
returns integer as $$
begin	
	return (select avg(total) from invoice);
end;
$$ language plpgsql;

--test
select averageInvoiceTotal();

--Task – Create a function that returns the most expensive track
--have to make single most expensive song first!
insert into track(trackid, name, albumid, mediatypeid, genreid, 
					composer, milliseconds, bytes, unitprice)
			values((select count(*) from track)+1, 'Random Expensive Song', 2, 2, 2, 
					'AC/DC', 23232, 10000000, 30);
					
create or replace function mostExpensiveTrack()
returns varchar as $$
begin	
	return (select name from track where unitprice=(select max(unitprice) from track));
end;
$$ language plpgsql;

--test
select mostExpensiveTrack();

--these lines for testing
select max(unitprice) from track;
select name from track where unitprice=(select max(unitprice) from track);
select * from track;
DROP FUNCTION mostexpensivetrack();

------------------------------------------------------------------------------------------------------------
--3.3 User Defined Scalar Functions

--Task – Create a function that returns the average price of invoiceline items in the invoiceline table
create or replace function averageUnitPrice()
returns integer as $$
begin	
	return (select avg(unitprice) from invoiceline);
end;
$$ language plpgsql;

--test
select averageUnitPrice();
select unitprice from invoiceline;

------------------------------------------------------------------------------------------------------------
--3.4 User Defined Table Valued Functions

--Task – Create a function that returns all employees who are born after 1968.
create or replace function employeesBornAfter68()
returns table(empfirstname varchar, emplastname varchar) as $$
begin	
	return query (select firstname, lastname  from employee where birthdate > '1968-01-01'::date);
end;
$$ language plpgsql;

--test
select * from employeesBornAfter68();
DROP FUNCTION employeesbornafter68();

------------------------------------------------------------------------------------------------------------
--4.0 Stored Procedures

--In this section you will be creating and executing stored procedures. 
--You will be creating various types of stored procedures that take input and output parameters.

 
------------------------------------------------------------------------------------------------------------
--4.1 Basic Stored Procedure

--Task – Create a stored procedure that selects the first and last names of all the employees.
create or replace function empFirstAndLast()
returns table(empfirstname varchar, emplastname varchar) as $$
begin	
	return query (select firstname, lastname  from employee);
end;
$$ language plpgsql;

--test
select * from empFirstAndLast();

------------------------------------------------------------------------------------------------------------
--4.2 Stored Procedure Input Parameters

--Task – Create a stored procedure that updates the personal information of an employee.
create or replace function updateEmpInfo(empid integer, fname varchar, lname varchar, title varchar, reportsto integer, 
											birthdate timestamp, hiredate timestamp,
											address varchar, city varchar, state varchar, country text, 
											postalcode varchar, phone varchar, fax varchar, email varchar) 
returns void as $$ 
begin
	update employee set firstname=$2, lastname=$3, title=$4, reportsto=$5, 
							birthdate=$6, hiredate=$7, address=$8, city=$9, 
							state=$10, country=$11, postalcode=$12, phone=$13, fax=$14, email=$15
	where employeeid = empid;
end;
$$ language plpgsql;

--test
select * from employee;

insert into employee(employeeid, lastname, firstname, title, reportsto, birthdate, 
						hiredate, address, city, state, country, postalcode, 
						phone, fax, email)
			values((select count(*) from employee)+1, 'Serrecchia', 'Dante', 'Top dog', 1, Timestamp '1990-07-14', 
						Timestamp '2018-01-03', '28550 Bud Court', 'Santa Clarita', 'CA', 'USA', '91350', 
						'+1 (661) 678-3532', '+1 (661) 678-3532', 'kyserrecchia@gmail.com');
					
select updateEmpInfo(9, 'Kyle', 'Serrecchia', 'Assistant', 1, '1962-02-18', '2002-08-14', '12702 Bruce B. Downs Blvd', 'Tampa', 
				'FL', 'USA', '33612', '+1 (661) 678-3532', '+1 (661) 678-3532', 'kyserrecchia@gmail.com');
			
delete from employee where employeeid=9;
	
			
--Task – Create a stored procedure that returns the managers of an employee.
create or replace function empManager(empid integer)
returns integer as $$
begin	
	return (select reportsto  from employee where empid = employeeid);
end;
$$ language plpgsql;

--test
select empManager(6);



------------------------------------------------------------------------------------------------------------
--4.3 Stored Procedure Output Parameters

--Task – Create a stored procedure that returns the name and company of a customer.
create or replace function getCustNameAndComp(custid integer)
returns table(fname varchar, lname varchar, companyname varchar) as $$
begin	
	return query (select firstname, lastname, company from customer where customerid = custid);
end;
$$ language plpgsql;

drop function getCustNameAndComp;

--test
select * from customer;
select * from getCustNameAndComp(5);


------------------------------------------------------------------------------------------------------------
--5.0 Transactions

--In this section you will be working with transactions. Transactions are usually nested within a stored procedure.

------------------------------------------------------------------------------------------------------------
--Task – Create a transaction that given a invoiceId will delete that invoice 
--(There may be constraints that rely on this, find out how to resolve them).


--Task – Create a transaction nested within a stored procedure that inserts a new record in the Customer table


------------------------------------------------------------------------------------------------------------
--6.0 Triggers

--In this section you will create various kinds of triggers that work when certain DML statements are executed on a table.


------------------------------------------------------------------------------------------------------------
--6.1 AFTER/FOR
--Task - Create an after insert trigger on the employee table fired after a new record is inserted into the table.
create sequence employee_id_seq start 10;
select nextval('employee_id_seq');

create or replace function insertTrig()
returns trigger as $$
begin
	if(TG_OP = 'INSERT') then
	new.employeeid=(select nextval('employee_id_seq'));
	end if;
	return new;
end
$$ language plpgsql;

create trigger after_insert
		after insert on employee
		for each row
execute procedure insertTrig();

--test
select * from employee;
drop sequence employee_id_seq;
insert into employee(employeeid, lastname, firstname, title, 
						reportsto, birthdate, hiredate, 
						address, city, state, country, 
						postalcode, phone, fax, email)
			values((select count(*) from employee) + 1, 'Jones-Serrecchia', 'Bella', 'Designated Pupper', 
						9, Timestamp '2016-11-14', Timestamp '2018-02-14', 
						'28550 Bud Court', 'Santa Clarita', 'CA', 'USA',
						'91350', '+1 (661) 678-3532', '+1 (661) 678-3532', null);
					
--Task – Create an after update trigger on the album table that fires after a row is inserted in the table


--Task – Create an after delete trigger on the customer table that fires after a row is deleted from the table.


------------------------------------------------------------------------------------------------------------
--7.0 JOINS

--In this section you will be working with combing various tables through the use of joins. 

--You will work with outer, inner, right, left, cross, and self joins.

------------------------------------------------------------------------------------------------------------
--7.1 INNER

--Task – Create an inner join that joins customers and orders and specifies the name of the customer and the invoiceId.
select customer.firstname, customer.lastname, invoice.invoiceid
from customer
inner join invoice on invoice.customerid = customer.customerid;

------------------------------------------------------------------------------------------------------------
--7.2 OUTER

--Task – Create an outer join that joins the customer and invoice table, 
--specifying the CustomerId, firstname, lastname, invoiceId, and total.
select customer.customerid, customer.firstname, customer.lastname, invoice.invoiceid, invoice.total
from customer
full outer join invoice on invoice.customerid = customer.customerid;

------------------------------------------------------------------------------------------------------------
--7.3 RIGHT

--Task – Create a right join that joins album and artist specifying artist name and title.
select artist.name, album.title
from album
right join artist on artist.artistid = album.artistid;

------------------------------------------------------------------------------------------------------------
--7.4 CROSS

--Task – Create a cross join that joins album and artist and sorts by artist name in ascending order.
select artist.name, album.title
from album
cross join artist order by artist.name desc;

------------------------------------------------------------------------------------------------------------
--7.5 SELF

--Task – Perform a self-join on the employee table, joining on the reportsto column.
select e.employeeid, e.firstname, e.lastname, e.reportsto, m.firstname, m.lastname 
from employee e inner join employee m on e.reportsto = m.employeeid;
