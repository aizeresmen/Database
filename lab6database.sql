-- Part 1
-- Exercise 1.1
CREATE TABLE employees (
    emp_id INT PRIMARY KEY,
    emp_name VARCHAR(50),
    dept_id INT,
    salary DECIMAL(10, 2)
);

CREATE TABLE departments (
    dept_id INT PRIMARY KEY,
    dept_name VARCHAR(50),
    location VARCHAR(50)
);

CREATE TABLE projects (
    project_id INT PRIMARY KEY,
    project_name VARCHAR(50),
    dept_id INT,
    budget DECIMAL(10, 2)
);

-- Exercise 1.2
INSERT INTO employees (emp_id, emp_name, dept_id, salary)
VALUES
(1, 'John Smith', 101, 50000),
(2, 'Jane Doe', 102, 60000),
(3, 'Mike Johnson', 101, 55000),
(4, 'Sarah Williams', 103, 65000),
(5, 'Tom Brown', NULL, 45000);

INSERT INTO departments (dept_id, dept_name, location)
VALUES
(101, 'IT', 'Building A'),
(102, 'HR', 'Building B'),
(103, 'Finance', 'Building C'),
(104, 'Marketing', 'Building D');

INSERT INTO projects (project_id, project_name, dept_id, budget)
VALUES
(1, 'Website Redesign', 101, 100000),
(2, 'Employee Training', 102, 50000),
(3, 'Budget Analysis', 103, 75000),
(4, 'Cloud Migration', 101, 150000),
(5, 'AI Research', NULL, 200000);

-- Part 2
-- Exercise 2.1
SELECT e.emp_name, d.dept_name
FROM employees e
CROSS JOIN departments d;

-- Exercise 2.2
SELECT e.emp_name, d.dept_name
FROM employees e, departments d;

SELECT e.emp_name, d.dept_name
FROM employees e
INNER JOIN departments d ON TRUE;

-- Exercise 2.3
SELECT
    e.emp_name,
    p.project_name
FROM employees e
CROSS JOIN projects p
ORDER BY e.emp_name, p.project_name;

-- Part 3
-- Exercise 3.1
SELECT
    e.emp_name,
    d.dept_name,
    d.location
FROM employees e
INNER JOIN departments d
    ON e.dept_id = d.dept_id;

-- Exercise 3.2
SELECT
    emp_name,
    dept_name,
    location
FROM employees
INNER JOIN departments
USING (dept_id);

-- Exercise 3.3
SELECT
    emp_name,
    dept_name,
    location
FROM employees
NATURAL INNER JOIN departments;

-- Exercise 3.4
SELECT
    e.emp_name,
    d.dept_name,
    p.project_name
FROM employees e
INNER JOIN departments d
    ON e.dept_id = d.dept_id
INNER JOIN projects p
    ON d.dept_id = p.dept_id;

-- Part 4
-- Exercise 4.1
SELECT
    e.emp_name,
    e.dept_id AS emp_dept,
    d.dept_id AS dept_dept,
    d.dept_name
FROM employees e
LEFT JOIN departments d
    ON e.dept_id = d.dept_id;

-- Exercise 4.2
SELECT
    emp_name,
    dept_id,
    dept_name
FROM employees
LEFT JOIN departments
USING (dept_id);

-- Exercise 4.3
SELECT
    e.emp_name,
    e.dept_id
FROM employees e
LEFT JOIN departments d
    ON e.dept_id = d.dept_id
WHERE d.dept_id IS NULL;

-- Exercise 4.4
SELECT
    d.dept_name,
    COUNT(e.emp_id) AS employee_count
FROM departments d
LEFT JOIN employees e
    ON d.dept_id = e.dept_id
GROUP BY d.dept_id, d.dept_name
ORDER BY employee_count DESC;

-- Part 5
-- Exercise 5.1
SELECT
    e.emp_name,
    d.dept_name
FROM employees e
RIGHT JOIN departments d
    ON e.dept_id = d.dept_id;

-- Exercise 5.2
SELECT
    e.emp_name,
    d.dept_name
FROM departments d
LEFT JOIN employees e
    ON e.dept_id = d.dept_id;

-- Exercise 5.3
SELECT
    d.dept_name,
    d.location
FROM employees e
RIGHT JOIN departments d
    ON e.dept_id = d.dept_id
WHERE e.emp_id IS NULL;

-- Part 6
-- Exercise 6.1
SELECT
    e.emp_name,
    e.dept_id AS emp_dept,
    d.dept_id AS dept_dept,
    d.dept_name
FROM employees e
FULL JOIN departments d
    ON e.dept_id = d.dept_id;

-- Exercise 6.2
SELECT
    d.dept_name,
    p.project_name,
    p.budget
FROM departments d
FULL JOIN projects p
    ON d.dept_id = p.dept_id;

-- Exercise 6.3
SELECT
    CASE
        WHEN e.emp_id IS NULL THEN 'Department without employees'
        WHEN d.dept_id IS NULL THEN 'Employee without department'
        ELSE 'Matched'
    END AS record_status,
    e.emp_name,
    d.dept_name
FROM employees e
FULL JOIN departments d
    ON e.dept_id = d.dept_id
WHERE e.emp_id IS NULL
   OR d.dept_id IS NULL;

-- Part 7
-- Exercise 7.1
SELECT
    e.emp_name,
    d.dept_name,
    e.salary
FROM employees e
LEFT JOIN departments d
    ON e.dept_id = d.dept_id
    AND d.location = 'Building A';

-- Exercise 7.2
SELECT
    e.emp_name,
    d.dept_name,
    e.salary
FROM employees e
LEFT JOIN departments d
    ON e.dept_id = d.dept_id
WHERE d.location = 'Building A';

-- Exercise 7.3
SELECT
    e.emp_name,
    d.dept_name,
    e.salary
FROM employees e
INNER JOIN departments d
    ON e.dept_id = d.dept_id
    AND d.location = 'Building A';

SELECT
    e.emp_name,
    d.dept_name,
    e.salary
FROM employees e
INNER JOIN departments d
    ON e.dept_id = d.dept_id
WHERE d.location = 'Building A';

-- The results are the same. This is because
-- `INNER JOIN` returns only matching rows.
-- Therefore, in this case, placing the filter
-- condition in the `ON` clause or the `WHERE`
-- clause produces the same result.

-- Part 8
-- Exercise 8.1
SELECT
    d.dept_name,
    e.emp_name,
    e.salary,
    p.project_name,
    p.budget
FROM departments d
LEFT JOIN employees e
    ON d.dept_id = e.dept_id
LEFT JOIN projects p
    ON d.dept_id = p.dept_id
ORDER BY d.dept_name, e.emp_name;

-- Exercise 8.2
ALTER TABLE employees
ADD COLUMN manager_id INT;

UPDATE employees
SET manager_id = 3
WHERE emp_id = 1;

UPDATE employees
SET manager_id = 3
WHERE emp_id = 2;

UPDATE employees
SET manager_id = NULL
WHERE emp_id = 3;

UPDATE employees
SET manager_id = 3
WHERE emp_id = 4;

UPDATE employees
SET manager_id = 3
WHERE emp_id = 5;

SELECT
    e.emp_name AS employee,
    m.emp_name AS manager
FROM employees e
LEFT JOIN employees m
    ON e.manager_id = m.emp_id;

-- Exercise 8.3
SELECT
    d.dept_name,
    AVG(e.salary) AS avg_salary
FROM departments d
INNER JOIN employees e
    ON d.dept_id = e.dept_id
GROUP BY d.dept_id, d.dept_name
HAVING AVG(e.salary) > 50000;

-- Lab questions
-- 1. What is the difference between
-- INNER JOIN and LEFT JOIN?

-- INNER JOIN returns only the rows that have
-- matching values in both tables.

-- LEFT JOIN returns all rows from the left table
-- and the matching rows from the right table.
-- If there is no match, the right table columns
-- contain NULL.

-- 2. When would you use CROSS JOIN in a practical scenario?

-- CROSS JOIN is used when we need all possible combinations of rows from two tables.

-- For example, it can be used to create an availability
-- matrix by pairing every employee with every project.

-- 3. Explain why the position of a filter condition (ON vs WHERE) matters for outer joins but not for inner joins.

-- For an outer join, a condition in the ON clause is applied during
-- the join, so unmatched rows from the outer table
-- are preserved.

-- A condition in the WHERE clause is applied after
-- the join and can remove rows with NULL values.

-- For an INNER JOIN, only matching rows are returned,
-- so placing the condition in ON or WHERE usually
-- produces the same result.

-- 4. What is the result of SELECT COUNT(*) FROM table1
-- CROSS JOIN table2 if table1 has 5 rows and table2 has 10 rows?

-- The result is:
-- 5 × 10 = 50
-- Therefore, the query returns 50 rows.

-- 5. How does NATURAL JOIN determine which columns to join on?
-- NATURAL JOIN automatically joins the tables using
-- all columns that have the same names in both tables.

-- 6. What are the potential risks of using NATURAL JOIN?
-- The main risk is that the join condition is implicit.
-- If new columns with the same names are added to the
-- tables, the NATURAL JOIN may automatically use them,
-- which can produce unexpected results.

-- 7. Convert this LEFT JOIN to a RIGHT JOIN:
SELECT *
FROM A
LEFT JOIN B
    ON A.id = B.id;

-- Equivalent RIGHT JOIN:

SELECT *
FROM B
RIGHT JOIN A
ON A.id = B.id;

-- 8. When should you use FULL OUTER JOIN instead of other join types?
-- FULL OUTER JOIN should be used when we need to keep
-- all rows from both tables, including rows that do not have
-- matching records in the other table. Unmatched \
-- columns are returned as NULL.

-- Optional Additional Challenges
-- 1. Simulate FULL OUTER JOIN using UNION
SELECT
    e.emp_name,
    d.dept_name
FROM employees e
LEFT JOIN departments d
    ON e.dept_id = d.dept_id

UNION

SELECT
    e.emp_name,
    d.dept_name
FROM employees e
RIGHT JOIN departments d
    ON e.dept_id = d.dept_id;

-- 2. Employees in departments with more than one project
SELECT DISTINCT
    e.emp_name,
    d.dept_name
FROM employees e
JOIN departments d
    ON e.dept_id = d.dept_id
JOIN projects p
    ON d.dept_id = p.dept_id
GROUP BY
    e.emp_id,
    e.emp_name,
    d.dept_name,
    d.dept_id
HAVING COUNT(p.project_id) > 1;

-- 3. Hierarchical organizational structure
SELECT
    e.emp_name AS employee,
    m.emp_name AS manager,
    mm.emp_name AS manager_manager
FROM employees e
LEFT JOIN employees m
    ON e.manager_id = m.emp_id
LEFT JOIN employees mm
    ON m.manager_id = mm.emp_id;

-- 4. Employees working in the same department
SELECT
    e1.emp_name AS employee1,
    e2.emp_name AS employee2,
    d.dept_name
FROM employees e1
JOIN employees e2
    ON e1.dept_id = e2.dept_id
   AND e1.emp_id < e2.emp_id
JOIN departments d
    ON e1.dept_id = d.dept_id;

