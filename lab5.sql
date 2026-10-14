-- Task 1.1
CREATE TABLE employees (
    employee_id INTEGER,
    first_name TEXT,
    last_name TEXT,
    age INTEGER CHECK (age BETWEEN 18 AND 65),
    salary NUMERIC CHECK (salary > 0)
);

-- Task 1.2
CREATE TABLE products_catalog (
    product_id INTEGER,
    product_name TEXT,
    regular_price NUMERIC,
    discount_price NUMERIC,

    CONSTRAINT valid_discount
    CHECK (
        regular_price > 0
        AND discount_price > 0
        AND discount_price < regular_price
        )
);

-- Task 1.3
CREATE TABLE bookings (
    booking_id INTEGER,
    check_in_date DATE,
    check_out_date DATE,
    num_guests INTEGER CHECK (num_guests BETWEEN 1 AND 10),
    CHECK (check_out_date > check_in_date)
);

-- Task 1.4
INSERT INTO employees
VALUES (1, 'Mereili', 'Qalmaqanova', 28, 1500000);

INSERT INTO employees
VALUES (2, 'Aizere', 'Kalmakanova', 18, 2000000);

INSERT INTO employees
VALUES (3, 'Diana', 'Bolat', 70, 1000000);

INSERT INTO employees
VALUES (4, 'Aruzhan', 'Aruzhanova', 25, -500);

-- Task 2.1
CREATE TABLE customers (
    customer_id INTEGER NOT NULL,
    email TEXT NOT NULL,
    phone TEXT,
    registration_date DATE NOT NULL
);

CREATE TABLE inventory (
    item_id INTEGER NOT NULL,
    item_name TEXT NOT NULL,
    quantity INTEGER NOT NULL CHECK (quantity >= 0),
    unit_price NUMERIC NOT NULL CHECK (unit_price > 0),
    last_updated TIMESTAMP NOT NULL
);


INSERT INTO customers
VALUES (1, 'mereili@gmail.com', '+77775656767', '2026-01-01');

INSERT INTO customers
VALUES (NULL, 'aizere@gmail.com', '+77775555555', '2026-01-01');


INSERT INTO customers
VALUES (3, NULL, '+77778389090', '2023-03-11');

INSERT INTO customers
VALUES (4, 'aruzhanova@gmail.com', NULL, '2025-05-07');

-- Task 3.1
CREATE TABLE users (
    user_id INTEGER,
    username TEXT UNIQUE,
    email TEXT UNIQUE,
    created_at TIMESTAMP
);

CREATE TABLE course_enrollments (
    enrollment_id INTEGER,
    student_id INTEGER,
    course_code TEXT,
    semester TEXT,

    UNIQUE (student_id, course_code, semester)
);

-- Task 3.3
ALTER TABLE users
ADD CONSTRAINT unique_username UNIQUE (username);

ALTER TABLE users
ADD CONSTRAINT unique_email UNIQUE (email);

INSERT INTO users
VALUES (1, 'mereilii', 'mereili@gmail.com', CURRENT_TIMESTAMP);

INSERT INTO users
VALUES (2, 'aizeresmen', 'aizere@gmail.com', CURRENT_TIMESTAMP);

INSERT INTO users
VALUES (3, 'dianaa', 'aizere@gmail.com', CURRENT_TIMESTAMP);


CREATE TABLE departments (
    dept_id INTEGER PRIMARY KEY,
    dept_name TEXT NOT NULL,
    location TEXT
);

INSERT INTO departments
VALUES (1, 'Sales', 'Almaty');

INSERT INTO departments
VALUES (2, 'IT', 'Almaty');

INSERT INTO departments
VALUES (3, 'Marketing', 'Astana');

INSERT INTO departments
VALUES (1, 'Marketing', 'Shymkent');

INSERT INTO departments
VALUES (NULL, 'Sales', 'Aktobe');

-- Task 4.2
CREATE TABLE student_courses (
    student_id INTEGER,
    course_id INTEGER,
    enrollment_date DATE,
    grade TEXT,
    PRIMARY KEY (student_id, course_id)
);

-- Task 4.3
-- Task 4.3: Comparison Exercise

-- 1. Difference between UNIQUE and PRIMARY KEY:
-- PRIMARY KEY uniquely identifies each row in a table.
-- A table can have only one PRIMARY KEY.
-- PRIMARY KEY values cannot be NULL.
-- UNIQUE constraint ensures that values in a column or a combination
-- of columns are not duplicated.
-- A table can have multiple UNIQUE constraints.

-- 2. Single-column vs. composite PRIMARY KEY:
-- A single-column PRIMARY KEY is used when one column is enough
-- to uniquely identify each row.
-- A composite PRIMARY KEY is used when two or more columns together
-- are needed to uniquely identify a row.
-- Example: student_courses uses (student_id, course_id) as a
-- composite PRIMARY KEY because the combination identifies
-- a student's course enrollment.

-- 3. Why one PRIMARY KEY but multiple UNIQUE constraints:
-- A table has only one PRIMARY KEY because it defines the main
-- identifier for each row.
-- Multiple UNIQUE constraints are allowed because a table may need
-- to enforce uniqueness for several different columns or combinations
-- of columns.

-- Task 5.1
CREATE TABLE employees_dept (
    emp_id INTEGER PRIMARY KEY,
    emp_name TEXT NOT NULL,
    dept_id INTEGER REFERENCES departments,
    hire_date DATE
);

INSERT INTO employees_dept
VALUES (1, 'Mereili', 1, '2026-06-15');

INSERT INTO employees_dept
VALUES (2, 'Aizere', 2, '2026-01-01');

INSERT INTO employees_dept
VALUES (3, 'Diana', 99, '2023-01-01');

-- Task 5.2
CREATE TABLE authors (
    author_id INTEGER PRIMARY KEY,
    author_name TEXT NOT NULL,
    country TEXT
);

CREATE TABLE publishers (
    publisher_id INTEGER PRIMARY KEY,
    publisher_name TEXT NOT NULL,
    city TEXT
);

CREATE TABLE books (
    book_id INTEGER PRIMARY KEY,
    title TEXT NOT NULL,
    author_id INTEGER REFERENCES authors,
    publisher_id INTEGER REFERENCES publishers,
    publication_year INTEGER,
    isbn TEXT UNIQUE
);

INSERT INTO authors
VALUES (1, 'Haruki Murakami', 'Japan');

INSERT INTO authors
VALUES (2, 'George Orwell', 'United Kingdom');

INSERT INTO authors
VALUES (3, 'J.K. Rowling', 'United Kingdom');

INSERT INTO publishers
VALUES (1, 'Vintage', 'London');

INSERT INTO publishers
VALUES (2, 'Penguin Books', 'London');

INSERT INTO publishers
VALUES (3, 'Bloomsbury', 'London');

INSERT INTO books
VALUES (1, 'Norwegian Wood', 1, 1, 1987, '9780375704024');

INSERT INTO books
VALUES (2, '1984', 2, 2, 1949, '9780451524935');

INSERT INTO books
VALUES (3, 'Harry Potter and the Philosopher''s Stone', 3, 3, 1997, '9780747532743');


-- Task 5.3
CREATE TABLE categories (
    category_id INTEGER PRIMARY KEY,
    category_name TEXT NOT NULL
);

CREATE TABLE products_fk (
    product_id INTEGER PRIMARY KEY,
    product_name TEXT NOT NULL,
    category_id INTEGER REFERENCES categories ON DELETE RESTRICT
);

CREATE TABLE orders (
    order_id INTEGER PRIMARY KEY,
    order_date DATE NOT NULL
);

CREATE TABLE order_items (
    item_id INTEGER PRIMARY KEY,
    order_id INTEGER REFERENCES orders ON DELETE CASCADE,
    product_id INTEGER REFERENCES products_fk,
    quantity INTEGER CHECK (quantity > 0)
);

INSERT INTO categories
VALUES (1, 'Electronics');

INSERT INTO categories
VALUES (2, 'Books');

INSERT INTO products_fk
VALUES (1, 'Laptop', 1);

INSERT INTO products_fk
VALUES (2, 'SQL Book', 2);

INSERT INTO orders
VALUES (1, '2026-10-14');

INSERT INTO orders
VALUES (2, '2026-10-15');

INSERT INTO order_items
VALUES (1, 1, 1, 2);

INSERT INTO order_items
VALUES (2, 1, 2, 1);

INSERT INTO order_items
VALUES (3, 2, 1, 3);

DELETE FROM categories
WHERE category_id = 1;

-- Test 1: ON DELETE RESTRICT
-- This DELETE fails because category_id = 1
-- is referenced by a product.
-- The category cannot be deleted while related products exist.

-- DELETE FROM categories
-- WHERE category_id = 1;

SELECT * FROM order_items
WHERE order_id = 1;

-- Test 2: ON DELETE CASCADE
-- Deleting order_id = 1 automatically deletes
-- all related order_items.
-- This happens because ON DELETE CASCADE is used.

DELETE FROM orders
WHERE order_id = 1;

SELECT * FROM order_items
WHERE order_id = 1;

-- Task 6.1
CREATE TABLE customers (
    customer_id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    email TEXT NOT NULL UNIQUE,
    phone TEXT,
    registration_date DATE NOT NULL
);

CREATE TABLE products (
    product_id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT,
    price NUMERIC NOT NULL CHECK (price >= 0),
    stock_quantity INTEGER NOT NULL CHECK (stock_quantity >= 0)
);

CREATE TABLE orders (
    order_id INTEGER PRIMARY KEY,
    customer_id INTEGER NOT NULL REFERENCES customers(customer_id),
    order_date DATE NOT NULL,
    total_amount NUMERIC NOT NULL CHECK (total_amount >= 0),
    status TEXT NOT NULL CHECK (
        status IN ('pending', 'processing', 'shipped', 'delivered', 'cancelled')
    )
);

CREATE TABLE order_details (
    order_detail_id INTEGER PRIMARY KEY,
    order_id INTEGER NOT NULL REFERENCES orders(order_id) ON DELETE CASCADE,
    product_id INTEGER NOT NULL REFERENCES products(product_id),
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    unit_price NUMERIC NOT NULL CHECK (unit_price >= 0)
);







