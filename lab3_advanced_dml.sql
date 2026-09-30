-- PartA
CREATE DATABASE advanced_lab;

CREATE TABLE employees (
    emp_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    department VARCHAR(50),
    salary INTEGER,
    hire_date DATE,
    status VARCHAR(20) DEFAULT 'Active'
);

CREATE TABLE departments (
    dept_id SERIAL PRIMARY KEY,
    dept_name VARCHAR(50),
    budget INTEGER,
    manager_id INTEGER
);

CREATE TABLE projects (
    project_id SERIAL PRIMARY KEY,
    project_name VARCHAR(50),
    dept_id INTEGER,
    start_date DATE,
    end_date DATE,
    budget INTEGER
);

--PartB
INSERT INTO employees (emp_id, first_name, last_name, department)
VALUES
    (1, 'Aizere', 'Kalmakanova', 'IT'),
    (2, 'Aisha', 'Malik', 'HR'),
    (3, 'Madi', 'Bolatov', 'Marketing');


ALTER TABLE employees
ALTER COLUMN salary SET DEFAULT 0;

INSERT INTO employees (emp_id, first_name, last_name, department, salary, status)
VALUES (4, 'Ali', 'Marat', 'Finance', DEFAULT, DEFAULT);

INSERT INTO departments (dept_id, dept_name, budget, manager_id)
VALUES
    (1, 'IT', 200000, 101),
    (2, 'HR', 120000, 102),
    (3, 'Marketing', 150000, 103);

INSERT INTO employees (emp_id, first_name, last_name, department, salary, hire_date)
VALUES
    (5, 'Sabina', 'Turar', 'IT', '50000*1.1', CURRENT_DATE);

CREATE TEMPORARY TABLE temp_employees (LIKE employees);

INSERT INTO temp_employees
SELECT * FROM employees WHERE department = 'IT';

--PartC
UPDATE employees
SET salary = salary * 1.10;

UPDATE employees
SET status = 'Senior' WHERE salary > 60000 AND hire_date < '2020-01-01';

UPDATE employees
SET department = CASE
    WHEN salary > 80000 THEN 'Management'
    WHEN salary BETWEEN 50000 AND 80000 THEN 'Senior'
    ELSE 'Junior'
END;


ALTER TABLE employees
ALTER COLUMN department SET DEFAULT 'General';

UPDATE employees
SET department = DEFAULT
WHERE status = 'Inactive';


UPDATE departments d
SET budget = (
    SELECT AVG(e.salary) * 1.20
    FROM employees e
    WHERE e.department = d.dept_name
    );

UPDATE employees
SET salary = salary * 1.15,
    status = 'Promoted'
WHERE department = 'Sales';


--PartD
DELETE FROM employees
WHERE status = 'Terminated';

DELETE FROM employees
WHERE salary < 40000 AND hire_date > '2023-01-01' AND department IS NULL;

DELETE FROM departments
WHERE dept_id NOT IN(
    SELECT DISTINCT d.dept_id
    FROM departments d
    JOIN employees e
        ON e.department = d.dept_name
    WHERE e.department IS NOT NULL
    );

DELETE FROM projects
WHERE end_date < '2023-01-01'
RETURNING *;

--PartE
INSERT INTO employees (emp_id, first_name, last_name, department, salary, hire_date, status)
VALUES (6, 'Zhuldyz', 'Eskermes', NUll, NULL, '2026-01-01');

UPDATE employees
SET department = 'Unassigned'
WHERE department is NULL;

DELETE * FROM employees
WHERE salary is NULL OR department is NULL;

--PartF

INSERT INTO employees( first_name, last_name, department, salary, hire_date)
VALUES( 'Zhuldyz', 'Bakytzhankyzy', 'IT',  1000000, CURRENT_DATE)
RETURNING emp_id, first_name || ' ' || last_name AS full_name;

WITH old_data AS (
    SELECT emp_id, salary
    FROM employees
    WHERE department = 'IT'
)
UPDATE employees e
SET salary = e.salary + 5000
FROM old_data o
WHERE e.emp_id = o.emp_id
RETURNING e.emp_id,
    o.salary AS old_salary,
    e.salary AS new_salary;

DELETE FROM employees
WHERE hire_date < '2020-01-01'
RETURNING *;

--PartG
INSERT INTO employees (first_name, last_name, department, salary, hire_date, status)
SELECT
    'Kamila',
    'Kabden',
    'IT',
    700000,
    CURRENT_DATE,
    'Active'
WHERE NOT EXISTS(
    SELECT 1
    FROM employees
    WHERE first_name = 'Kamila' AND last_name = 'Kabden'
);

UPDATE employees e
SET salary = salary * CASE
    WHEN (
        SELECT d.budget FROM departments d
        WHERE d.dept_name = e.department
        ) > 100000
        THEN 1.10
        ELSE 1.05
END;

INSERT INTO employees (first_name, last_name, department, salary, hire_date, status)
VALUES ('Aidos', 'Berikov', 'Finance', 500000, CURRENT_DATE, 'Active'),
       ('Daniyar', 'Toktarov', 'Marketing', 400000, CURRENT_DATE, 'Active'),
       ('Lyazzat', 'Satybaldina', 'IT', 600000, CURRENT_DATE, 'Active'),
       ('Madina', 'Sapar', 'Sales', 800000, CURRENT_DATE, 'Active'),
       ('Aigul', 'Muratova', 'HR', 800000, CURRENT_DATE, 'Active');

UPDATE employees
SET salary = salary * 1.10
WHERE (first_name, last_name) IN (
    ('Aidos', 'Berikov'),
    ('Daniyar', 'Toktarov'),
    ('Lyazzat', 'Satybaldina'),
    ('Madina', 'Sapar'),
    ('Aigul', 'Muratova')
    );

CREATE TABLE employee_archive
(LIKE employees);
INSERT INTO employee_archive
SELECT *
FROM employees
WHERE status = 'Inactive';

DELETE FROM employees
WHERE status = 'Inactive';

UPDATE projects p
SET end_date = end_date + INTERVAL '30 days'
WHERE p.budget > 50000
    AND (
        SELECT COUNT(*)
        FROM employees e
        JOIN departments d
            ON e.department = d.dept_name
        WHERE d.dept_id = p.dept_id
    ) > 3;




