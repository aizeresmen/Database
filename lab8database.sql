-- Lab 8
-- Part 1
CREATE TABLE departments (
 dept_id INT PRIMARY KEY,
 dept_name VARCHAR(50),
 location VARCHAR(50)
);
CREATE TABLE employees (
 emp_id INT PRIMARY KEY,
 emp_name VARCHAR(100),
 dept_id INT,
 salary DECIMAL(10,2),
 FOREIGN KEY (dept_id) REFERENCES departments(dept_id)
);
CREATE TABLE projects (
 proj_id INT PRIMARY KEY,
 proj_name VARCHAR(100),
 budget DECIMAL(12,2),
 dept_id INT,
 FOREIGN KEY (dept_id) REFERENCES departments(dept_id)
);

INSERT INTO departments VALUES
(101, 'IT', 'Building A'),
(102, 'HR', 'Building B'),
(103, 'Operations', 'Building C');
INSERT INTO employees VALUES
(1, 'John Smith', 101, 50000),
(2, 'Jane Doe', 101, 55000),
(3, 'Mike Johnson', 102, 48000),
(4, 'Sarah Williams', 102, 52000),
(5, 'Tom Brown', 103, 60000);
INSERT INTO projects VALUES
(201, 'Website Redesign', 75000, 101),
(202, 'Database Migration', 120000, 101),
(203, 'HR System Upgrade', 50000, 102);

-- Part 2
-- Exercise 2.1
CREATE INDEX emp_salary_idx ON employees(salary);
SELECT indexname, indexdef
FROM pg_indexes
WHERE tablename = 'employees';

-- Question: How many indexes exist on the employees table?
-- 2, employees_pkey , emp_salary_idx

-- Exercise 2.2
CREATE INDEX emp_dept_idx ON employees(dept_id);

SELECT *
FROM employees
WHERE dept_id = 101;

-- Question: Why is it beneficial to index foreign key columns?
-- Indexing foreign key columns improves JOIN performance and makes
-- it faster to retrieve related records. It also helps PostgreSQL
-- efficiently check references when rows in the parent table are
-- updated or deleted.

-- Exercise 2.3
SELECT
    tablename,
    indexname,
    indexdef
FROM pg_indexes
WHERE schemaname = 'public'
ORDER BY tablename, indexname;

-- Question: List all the indexes you see. Which ones were created automatically?
-- The primary-key indexes departments_pkey, employees_pkey,
-- and projects_pkey were created automatically. Other indexes shown
-- at this stage (emp_salary_idx and emp_dept_idx) were created manually.


-- Part 3
-- Exercise 3.1
CREATE INDEX emp_dept_salary_idx
ON employees(dept_id, salary);

-- Test the multicolumn index
SELECT emp_name, salary
FROM employees
WHERE dept_id = 101 AND salary > 52000;

-- Question: Would this index be useful for a query that only filters
-- by salary (without dept_id)? Why or why not?
-- It is generally not efficient for a query that filters only
-- by salary because dept_id is the leftmost column of the B-tree index.
-- The index is most useful when the leading column is included in
-- the query condition.


-- Exercise 3.2:
CREATE INDEX emp_salary_dept_idx
ON employees(salary, dept_id);

SELECT *
FROM employees
WHERE dept_id = 102 AND salary > 50000;

SELECT *
FROM employees
WHERE salary > 50000 AND dept_id = 102;

-- Question: Does the order of columns in a multicolumn index matter?
-- Yes. The order matters because a B-tree multicolumn index
-- is most effective when conditions use its leftmost column(s).
-- (dept_id, salary) favors queries led by dept_id; (salary, dept_id)
-- favors queries led by salary.


-- Part 4
-- Exercise 4.1

ALTER TABLE employees
ADD COLUMN email VARCHAR(100);

UPDATE employees SET email = 'john.smith@company.com' WHERE emp_id = 1;
UPDATE employees SET email = 'jane.doe@company.com' WHERE emp_id = 2;
UPDATE employees SET email = 'mike.johnson@company.com' WHERE emp_id = 3;
UPDATE employees SET email = 'sarah.williams@company.com' WHERE emp_id = 4;
UPDATE employees SET email = 'tom.brown@company.com' WHERE emp_id = 5;

CREATE UNIQUE INDEX emp_email_unique_idx
ON employees(email);

-- Test uniqueness separately. This INSERT is expected to FAIL.
-- Uncomment and run it separately if you need a screenshot of the error:
-- INSERT INTO employees (emp_id, emp_name, dept_id, salary, email)
-- VALUES (6, 'New Employee', 101, 55000, 'john.smith@company.com');

-- Question: What error message did you receive?
-- PostgreSQL reports a duplicate key / unique violation
-- (SQLSTATE 23505), because john.smith@company.com already exists.


-- Exercise 4.2
ALTER TABLE employees
ADD COLUMN phone VARCHAR(20) UNIQUE;
SELECT indexname, indexdef
FROM pg_indexes
WHERE tablename = 'employees'
  AND indexname LIKE '%phone%';

-- Question: Did PostgreSQL automatically create an index?
-- What type of index?
-- Yes. PostgreSQL automatically creates a unique B-tree
-- index to enforce the UNIQUE constraint on phone.


-- Part 5
-- Exercise 5.1
CREATE INDEX emp_salary_desc_idx
ON employees(salary DESC);

SELECT emp_name, salary
FROM employees
ORDER BY salary DESC;

-- Question: How does this index help with ORDER BY queries?
-- The index stores salary entries in descending order.
-- PostgreSQL may use it to return rows in the requested order and
-- avoid a separate sort operation.


-- Exercise 5.2
CREATE INDEX proj_budget_nulls_first_idx
ON projects(budget NULLS FIRST);

SELECT proj_name, budget
FROM projects
ORDER BY budget NULLS FIRST;


-- Exercise 6.1
CREATE INDEX emp_name_lower_idx
ON employees(LOWER(emp_name));

SELECT *
FROM employees
WHERE LOWER(emp_name) = 'john smith';

-- Question: Without this index, how would PostgreSQL search for
-- names case-insensitively?
-- PostgreSQL would generally perform a sequential scan,
-- calculate LOWER(emp_name) for each row, and compare it with
-- 'john smith'.


-- Exercise 6.2
ALTER TABLE employees
ADD COLUMN hire_date DATE;

UPDATE employees SET hire_date = '2020-01-15' WHERE emp_id = 1;
UPDATE employees SET hire_date = '2019-06-20' WHERE emp_id = 2;
UPDATE employees SET hire_date = '2021-03-10' WHERE emp_id = 3;
UPDATE employees SET hire_date = '2020-11-05' WHERE emp_id = 4;
UPDATE employees SET hire_date = '2018-08-25' WHERE emp_id = 5;

CREATE INDEX emp_hire_year_idx
ON employees(EXTRACT(YEAR FROM hire_date));

SELECT emp_name, hire_date
FROM employees
WHERE EXTRACT(YEAR FROM hire_date) = 2020;

-- Part 7
-- Exercise 7.1
ALTER INDEX emp_salary_idx
RENAME TO employees_salary_index;

SELECT indexname
FROM pg_indexes
WHERE tablename = 'employees';


-- Exercise 7.2
DROP INDEX emp_salary_dept_idx;

-- Question: Why might you want to drop an index?
-- To remove unused or redundant indexes, save disk space,
-- and reduce the overhead of INSERT, UPDATE, and DELETE operations.


-- Exercise 7.3
REINDEX INDEX employees_salary_index;

-- Question: When is REINDEX useful?
-- REINDEX rebuilds an index. It can be useful when an index
-- is bloated, needs rebuilding after significant changes, or is
-- suspected of being corrupted.


-- Part 8
-- Exercise 8.1

-- Index for the WHERE clause
CREATE INDEX emp_salary_filter_idx
ON employees(salary)
WHERE salary > 50000;



SELECT e.emp_name, e.salary, d.dept_name
FROM employees e
JOIN departments d ON e.dept_id = d.dept_id
WHERE e.salary > 50000
ORDER BY e.salary DESC;


-- Exercise 8.2: Partial Index
CREATE INDEX proj_high_budget_idx
ON projects(budget)
WHERE budget > 80000;

SELECT proj_name, budget
FROM projects
WHERE budget > 80000;

-- Question: What's the advantage of a partial index compared to
-- a regular index?
-- A partial index contains entries only for rows matching
-- its WHERE condition. It can use less disk space and reduce
-- maintenance overhead when queries frequently target that subset.


-- Exercise 8.3
SELECT *
FROM employees
WHERE salary > 52000;

-- Question: Does the output show an Index Scan or a Seq Scan?
-- What does this tell you?
-- The plan may show a Seq Scan because this table is very
-- small. Seq Scan means PostgreSQL reads the table rows directly;
-- Index Scan means it accesses rows through an index. The planner
-- chooses the plan it estimates to be cheaper.


-- Part 9
-- Exercise 9.1
CREATE INDEX dept_name_hash_idx
ON departments USING HASH (dept_name);

SELECT *
FROM departments
WHERE dept_name = 'IT';

-- Question: When should you use a HASH index instead of a B-tree?
-- A HASH index is suitable for equality comparisons (=).
-- It does not support range comparisons or ordering. B-tree is
-- the more general-purpose index type.


-- Exercise 9.2
CREATE INDEX proj_name_btree_idx
ON projects(proj_name);

CREATE INDEX proj_name_hash_idx
ON projects USING HASH (proj_name);

SELECT *
FROM projects
WHERE proj_name = 'Website Redesign';

SELECT *
FROM projects
WHERE proj_name > 'Database';


-- Part 10
-- Exercise 10.1
SELECT
    schemaname,
    tablename,
    indexname,
    pg_size_pretty(pg_relation_size(indexname::regclass)) AS index_size
FROM pg_indexes
WHERE schemaname = 'public'
ORDER BY tablename, indexname;

-- Question: Which index is the largest? Why?
-- Determine the largest from the query result. Its size
-- depends on the indexed data, number of entries, indexed columns,
-- and index structure. With these small sample tables, sizes may
-- be similar.


-- Exercise 10.2: Drop Unnecessary Indexes
DROP INDEX IF EXISTS proj_name_hash_idx;

-- Question: Why remove duplicate or rarely used indexes?
-- They consume disk space and add overhead to data changes.
-- Removing unnecessary indexes can improve write performance.


-- Exercise 10.3
CREATE VIEW index_documentation AS
SELECT
    tablename,
    indexname,
    indexdef,
    'Improves salary-based queries' AS purpose
FROM pg_indexes
WHERE schemaname = 'public'
  AND indexname LIKE '%salary%';

SELECT *
FROM index_documentation;


-- Summary Questions
-- 1. What is the default index type in PostgreSQL?
-- B-tree.

-- 2. Name three scenarios where you should create an index.
--    a) Columns frequently used in WHERE clauses.
--    b) Columns used in JOIN conditions.
--    c) Columns used in ORDER BY operations.

-- 3. Name two scenarios where you should NOT create an index.
--    a) On columns that are rarely used in queries.
--    b) On small tables where a sequential scan may be cheaper.

-- 4. What happens to indexes when you INSERT, UPDATE, or DELETE data?
-- PostgreSQL maintains affected indexes automatically.
-- These changes add work and can slow down write operations.

-- 5. How can you check if a query is using an index?
-- Use EXPLAIN or EXPLAIN ANALYZE and inspect the execution plan.

-- Optional Additional Challenges

-- Challenge 1: Index employees by the month of hire_date
CREATE INDEX emp_hire_month_idx
ON employees(EXTRACT(MONTH FROM hire_date));

SELECT emp_name, hire_date
FROM employees
WHERE EXTRACT(MONTH FROM hire_date) = 1;


-- Challenge 2: Composite unique index on dept_id and email
CREATE UNIQUE INDEX emp_dept_email_unique_idx
ON employees(dept_id, email);


-- Challenge 3: Compare performance with EXPLAIN ANALYZE
-- Run this query, then (optionally) drop an index and run it again
-- to compare plans. Small sample data may still produce Seq Scan.
EXPLAIN ANALYZE
SELECT *
FROM employees
WHERE salary > 52000;


-- Challenge 4: Covering index with included columns
CREATE INDEX emp_dept_covering_idx
ON employees(dept_id)
INCLUDE (emp_name, salary);

SELECT emp_name, salary
FROM employees
WHERE dept_id = 101;


