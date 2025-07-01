# Human Resource management system database

### Task 6 ###
use hrms;

#query within query
select manager_name,salary,(select avg(salary) from manager) as average_salary from manager;

select first_name, salary from employees where salary > (select avg(salary) from employees);

select max(salary) from employees where salary <> (select max(salary) from employees); 

select location from leave_request where emp_id = (select * from leave_request where location="mumbai");

select manager_id, manager_name,salary from manager where salary = (select max(salary) from manager);

select emp.first_name,emp.salary,(select avg(salary) from employees) AS avg_company_salary from employees emp;

select emp.first_name,emp.salary,(select avg(salary) from employees) AS avg_company_salary from employees emp;

select mgr.manager_name,mgr.salary,(select avg(salary) from manager where location = mgr.location) as avg_company_salary from manager mgr;

select manager_name,salary,(select avg(salary) from manager) as average_salary from manager where salary < (select avg(salary) from manager);

select location from department where dept_id = (select dept_name from department where dept_name="rose" or dept_name="gold");

#exists

select manager_name from manager where exists (select location from manager where location="mumbai");

select * from leave_request where exists (select * from leave_request where location="mumbai");


#From

select mgr.manager_id,mgr.location from(select  manager_id, location from manager) as mgr where mgr.location='delhi';

select lr.emp_id,lr.dept_id,lr.location,lr.status from(select emp_id,dept_id,location,status from leave_request) as lr where status="Approve";

#IN

select dept_id, dept_name,location from department where dept_name in (select dept_name from department where location in ('delhi','mumbai'));

select manager_name,location from manager where manager_id in (select manager_id from manager where location = 'Mumbai');


