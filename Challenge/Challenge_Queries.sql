-- Creating tables for PH-EmployeeDB
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

-- Create table to find job title names.
SELECT COUNT(e.emp_no),
	t.title
INTO number_of_titles
FROM employees as e
	INNER JOIN titles as t
		ON e.emp_no = t.emp_no
GROUP BY t.title;
SELECT * FROM number_of_titles;

-- Create a table containing the number of employees about to retire grouped by job title.
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
SELECT emp_no, first_name, last_name, title, from_date, salary
INTO future_retirees_by_title
FROM 
(SELECT emp_no, first_name, last_name, title, from_date, to_date, salary, 
 ROW_NUMBER() OVER
 (PARTITION BY (emp_no)
 ORDER BY to_date DESC) rn
 FROM retire_by_title) tmp 
 WHERE rn = 1
ORDER BY title;
-- Query the table.
SELECT * FROM future_retirees_by_title;

-- Show total number of employees retiring by title.
SELECT COUNT(frbt.emp_no),
	frbt.title
INTO num_future_retirees_by_title
FROM future_retirees_by_title as frbt
GROUP BY frbt.title;
-- Query the table.
SELECT * FROM num_future_retirees_by_title;

-- Create table showing mentorship eligibility.
SELECT e.emp_no,
	e.first_name,
	e.last_name,
	t.title,
	t.from_date,
	t.to_date
INTO mentor_eligibility 
FROM employees as e
	INNER JOIN titles AS t
		ON (e.emp_no = t.emp_no)
WHERE (e.birth_date BETWEEN '1965-01-01' AND '1965-12-31');
SELECT * FROM mentor_eligibility;

-- Partition the data to show only most recent title per employee.
SELECT emp_no, first_name, last_name, title, from_date, to_date
INTO mentorship_eligibility
FROM 
(SELECT emp_no, first_name, last_name, title, from_date, to_date,  
 ROW_NUMBER() OVER
 (PARTITION BY (emp_no)
 ORDER BY to_date DESC) rn
 FROM mentor_eligibility) tmp 
 WHERE rn = 1
ORDER BY emp_no;
SELECT * FROM mentorship_eligibility;

-- Show total number of employees available for mentoring role.
SELECT COUNT(*)
INTO num_mentorship_eligibility
FROM mentorship_eligibility;
-- Query the table.
SELECT * FROM num_mentorship_eligibility;

