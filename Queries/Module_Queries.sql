-- Creating tables for PH-EmployeeDB
DROP TABLE departments;
DROP TABLE employees;
DROP TABLE dept_manager CASCADE;
DROP TABLE salaries CASCADE;
DROP TABLE dept_emp CASCADE;
DROP TABLE titles CASCADE;

CREATE TABLE departments (
	dept_no VARCHAR(4) NOT NULL,
	dept_name VARCHAR(40) NOT NULL,
	PRIMARY KEY (dept_no),
	UNIQUE (dept_name)
);
SELECT * FROM departments;

CREATE TABLE employees (
	emp_no INT NOT NULL,
	birth_date DATE NOT NULL,
	first_name VARCHAR NOT NULL,
	last_name VARCHAR NOT NULL,
	gender VARCHAR NOT NULL,
	hire_date DATE NOT NULL,
	PRIMARY KEY (emp_no)
);
SELECT * FROM employees;

CREATE TABLE dept_manager (
	dept_no VARCHAR NOT NULL,
	emp_no INT NOT NULL,
	from_date DATE NOT NULL,
	to_date DATE NOT NULL,
	FOREIGN KEY (emp_no) REFERENCES employees (emp_no),
	FOREIGN KEY (dept_no) REFERENCES departments (dept_no),
	PRIMARY KEY (emp_no, dept_no)
);
SELECT * FROM dept_manager;

CREATE TABLE salaries (
	emp_no INT NOT NULL,
	salary INT NOT NULL,
	from_date DATE NOT NULL,
	to_date DATE NOT NULL,
	FOREIGN KEY (emp_no) REFERENCES employees (emp_no),
	PRIMARY KEY (emp_no)
);
SELECT * FROM salaries;

CREATE TABLE dept_emp (
	emp_no INT NOT NULL,
	dept_no VARCHAR NOT NULL,
	from_date DATE NOT NULL,
	to_date DATE NOT NULL,
	FOREIGN KEY (emp_no) REFERENCES employees (emp_no),
	FOREIGN KEY (dept_no) REFERENCES departments (dept_no),
	PRIMARY KEY (emp_no, dept_no)
);
SELECT * FROM dept_emp;

CREATE TABLE titles (
	emp_no INT NOT NULL,
	title VARCHAR NOT NULL,
	from_date DATE NOT NULL,
	to_date DATE NOT NULL,
	FOREIGN KEY (emp_no) REFERENCES employees (emp_no),
	PRIMARY KEY (emp_no, title, from_date)
);
SELECT * FROM titles;

-- Retirement eligibility
SELECT first_name, last_name
INTO retirement_info
FROM employees
WHERE (birth_date BETWEEN '1952-01-01' AND '1955-12-31')
AND (hire_date BETWEEN '1985-01-01' AND '1988-12-31');

SELECT * FROM retirement_info;

SELECT first_name, last_name
FROM employees
WHERE birth_date BETWEEN '1952-01-01' AND '1952-12-31';

SELECT first_name, last_name
FROM employees
WHERE birth_date BETWEEN '1953-01-01' AND '1953-12-31';

SELECT first_name, last_name
FROM employees
WHERE birth_date BETWEEN '1954-01-01' AND '1954-12-31';

SELECT first_name, last_name
FROM employees
WHERE birth_date BETWEEN '1955-01-01' AND '1955-12-31';

-- Number of employees retiring
SELECT COUNT(first_name)
FROM employees
WHERE (birth_date BETWEEN '1952-01-01' AND '1955-12-31')
AND (hire_date BETWEEN '1985-01-01' AND '1988-12-31');

DROP TABLE retirement_info;

-- Create new table for retiring employees
SELECT emp_no, first_name, last_name
INTO retirement_info
FROM employees
WHERE (birth_date BETWEEN '1952-01-01' AND '1955-12-31')
AND (hire_date BETWEEN '1985-01-01' AND '1988-12-31');
-- Check the table
SELECT * FROM retirement_info;

-- Joining departments and dept_manager tables
SELECT departments.dept_name,
	dept_manager.emp_no,
	dept_manager.from_date,
	dept_manager.to_date
FROM departments
	INNER JOIN dept_manager
		ON departments.dept_no = dept_manager.dept_no;
-- Shorten above code
SELECT d.dept_name,
	dm.emp_no,
	dm.from_date,
	dm.to_date
FROM departments as d
	INNER JOIN dept_manager as dm
		ON d.dept_no = dm.dept_no;

-- Joining retirement_info and dept_emp tables
SELECT retirement_info.emp_no,
	retirement_info.first_name,
	retirement_info.last_name,
	dept_emp.to_date
FROM retirement_info
	LEFT JOIN dept_emp
		ON retirement_info.emp_no = dept_emp.emp_no;

DROP TABLE current_emp;
-- Shorten above code
SELECT ri.emp_no,
	ri.first_name,
	ri.last_name,
	de.to_date
INTO current_emp
FROM retirement_info as ri
	LEFT JOIN dept_emp as de
		ON ri.emp_no = de.emp_no
WHERE de.to_date = ('9999-01-01');
-- Check the table
SELECT * FROM retirement_info;

DROP TABLE retire_by_dept;
-- Employee count by department number
SELECT COUNT(ce.emp_no),
	de.dept_no
INTO retire_by_dept
FROM current_emp as ce
	LEFT JOIN dept_emp as de
		ON ce.emp_no = de.emp_no
GROUP BY de.dept_no
ORDER BY de.dept_no;
-- Check the table
SELECT * FROM retire_by_dept;

-- Module 7.3.5
SELECT * FROM salaries
ORDER BY to_date DESC;

DROP TABLE emp_info;
SELECT e.emp_no,
	e.first_name,
	e.last_name,
	e.gender,
	s.salary,
	de.to_date
INTO emp_info
FROM employees as e
	INNER JOIN salaries as s
		ON (e.emp_no = s.emp_no)
	INNER JOIN dept_emp as de
		ON (e.emp_no = de.emp_no)
WHERE (e.birth_date BETWEEN '1952-01-01' AND '1955-12-31')
AND (e.hire_date BETWEEN '1985-01-01' AND '1988-12-31')
AND (de.to_date = '9999-01-01');
	
-- List of managers per department
SELECT  dm.dept_no,
        d.dept_name,
        dm.emp_no,
        ce.last_name,
        ce.first_name,
        dm.from_date,
        dm.to_date
INTO manager_info
FROM dept_manager AS dm
    INNER JOIN departments AS d
        ON (dm.dept_no = d.dept_no)
    INNER JOIN current_emp AS ce
        ON (dm.emp_no = ce.emp_no);	
		
-- Department Retirees
SELECT ce.emp_no,
	ce.first_name,
	ce.last_name,
	d.dept_name	
INTO dept_info
FROM current_emp as ce
	INNER JOIN dept_emp AS de
		ON (ce.emp_no = de.emp_no)
	INNER JOIN departments AS d
		ON (de.dept_no = d.dept_no);
		
-- Module 7.3.6
-- Create a query that will return only the information relevant to the Sales team. 
-- The requested list includes:
-- Employee numbers
-- Employee first name
-- Employee last name
-- Employee department name
SELECT ce.emp_no,
	ce.first_name,
	ce.last_name,
	d.dept_name	
INTO sales_team_info 
FROM current_emp as ce
	INNER JOIN dept_emp AS de
		ON (ce.emp_no = de.emp_no)
	INNER JOIN departments AS d
		ON (de.dept_no = d.dept_no)
WHERE (d.dept_no = 'd007');
SELECT * FROM sales_team_info;

-- Create another query that will return the following information for the Sales and Development teams:
-- Employee numbers
-- Employee first name
-- Employee last name
-- Employee department name
SELECT ce.emp_no,
	ce.first_name,
	ce.last_name,
	d.dept_name	
INTO sales_and_dev_team_info 
FROM current_emp as ce
	INNER JOIN dept_emp AS de
		ON (ce.emp_no = de.emp_no)
	INNER JOIN departments AS d
		ON (de.dept_no = d.dept_no)
WHERE d.dept_no IN ('d007', 'd005');
SELECT * FROM sales_and_dev_team_info;



-- Challenge
-- Create table to find job title names.
SELECT COUNT(e.emp_no),
	t.title
INTO number_of_titles
FROM employees as e
	INNER JOIN titles as t
		ON e.emp_no = t.emp_no
GROUP BY t.title;


-- Create a table containing the number of employees about to retire grouped by job title.
DROP TABLE retire_by_title;
SELECT e.emp_no,
	e.first_name,
	e.last_name,
	t.title,
	t.from_date,
	t.to_date,
	s.salary
INTO retire_by_title 
FROM employees as e
	INNER JOIN titles AS t
		ON (e.emp_no = t.emp_no)
	INNER JOIN salaries AS s
		ON (e.emp_no = s.emp_no)
WHERE (e.birth_date BETWEEN '1952-01-01' AND '1955-12-31')
AND t.title IN ('Assistant Engineer', 'Engineer', 'Manager', 'Senior Engineer', 'Senior Staff', 'Staff', 'Technique Leader')
ORDER BY emp_no;
-- Query the table.
SELECT * FROM retire_by_title;

-- Partition the data to show only most recent title per employee.
DROP TABLE future_retirees_by_title;
SELECT emp_no, first_name, last_name, title, from_date, salary
-- INTO future_retirees_by_title
FROM 
(SELECT emp_no, first_name, last_name, title, from_date, to_date, salary, 
 ROW_NUMBER() OVER
 (PARTITION BY (emp_no)
 ORDER BY to_date DESC) rn
 FROM retire_by_title) tmp 
 WHERE rn = 1
ORDER BY emp_no;
-- Query the table.
SELECT * FROM future_retirees_by_title;

