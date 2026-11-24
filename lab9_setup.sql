-- ============================================================
-- Laboratory Work 9: Stored Procedures and User-Defined Functions
-- Part 1: Database Setup  (CityBike rental network)
-- ============================================================

DROP TABLE IF EXISTS rentals, bikes, members, stations CASCADE;

-- Create table: stations
CREATE TABLE stations (
    station_id   INT PRIMARY KEY,
    station_name VARCHAR(50) NOT NULL,
    city         VARCHAR(40) NOT NULL,
    capacity     INT NOT NULL
);

-- Create table: bikes
CREATE TABLE bikes (
    bike_id    INT PRIMARY KEY,
    model      VARCHAR(50) NOT NULL,
    station_id INT REFERENCES stations(station_id),
    daily_rate NUMERIC(8,2) NOT NULL
);

-- Create table: members
CREATE TABLE members (
    member_id INT PRIMARY KEY,
    full_name VARCHAR(60) NOT NULL,
    city      VARCHAR(40) NOT NULL,
    joined_on DATE NOT NULL
);

-- Create table: rentals
CREATE TABLE rentals (
    rental_id  INT PRIMARY KEY,
    member_id  INT REFERENCES members(member_id),
    bike_id    INT REFERENCES bikes(bike_id),
    start_date DATE NOT NULL,
    end_date   DATE,
    fee        NUMERIC(8,2)
);

INSERT INTO stations VALUES
 (10, 'Central Park', 'Almaty',   4),
 (20, 'Riverside',    'Almaty',   3),
 (30, 'Expo Gate',    'Astana',   5),
 (40, 'Old Town',     'Shymkent', 2),
 (50, 'Depot',        'Astana',   0);

INSERT INTO bikes VALUES
 (101, 'City Cruiser', 10,  4.50),
 (102, 'City Cruiser', 10,  4.50),
 (103, 'Mountain X',   20,  7.00),
 (104, 'Mountain X',   30,  7.00),
 (105, 'Road Sprint',  30,  9.25),
 (106, 'Folding Mini', 40,  3.75),
 (107, 'Cargo Hauler', 20, 12.00),
 (108, 'Road Sprint',  10,  9.25);

INSERT INTO members VALUES
 (1, 'Aisha Nurlanova', 'Almaty',   DATE '2023-03-14'),
 (2, 'Daniyar Serik',   'Almaty',   DATE '2023-07-02'),
 (3, 'Marta Kowalski',  'Astana',   DATE '2024-01-20'),
 (4, 'Chen Wei',        'Astana',   DATE '2024-05-11'),
 (5, 'Omar Haddad',     'Shymkent', DATE '2024-09-30'),
 (6, 'Elena Petrova',   'Almaty',   DATE '2025-02-05');

INSERT INTO rentals VALUES
 ( 1, 1, 101, DATE '2024-04-05', DATE '2024-04-08', 13.50),
 ( 2, 1, 103, DATE '2024-06-11', DATE '2024-06-16', 35.00),
 ( 3, 1, 108, DATE '2025-02-02', DATE '2025-02-04', 18.50),
 ( 4, 1, 102, DATE '2025-05-20', DATE '2025-05-27', 31.50),
 ( 5, 2, 101, DATE '2024-05-01', DATE '2024-05-02',  4.50),
 ( 6, 2, 107, DATE '2024-11-15', DATE '2024-11-19', 48.00),
 ( 7, 2, 107, DATE '2025-03-08', DATE '2025-03-14', 72.00),
 ( 8, 3, 104, DATE '2024-02-14', DATE '2024-02-18', 28.00),
 ( 9, 3, 105, DATE '2024-08-03', DATE '2024-08-06', 27.75),
 (10, 3, 104, DATE '2025-01-09', DATE '2025-01-10',  7.00),
 (11, 3, 105, DATE '2025-06-01', DATE '2025-06-09', 74.00),
 (12, 4, 104, DATE '2024-07-19', DATE '2024-07-21', 14.00),
 (13, 4, 105, DATE '2025-04-12', DATE '2025-04-15', 27.75),
 (14, 4, 103, DATE '2025-07-23', DATE '2025-07-29', 42.00),
 (15, 5, 106, DATE '2024-10-05', DATE '2024-10-12', 26.25),
 (16, 5, 106, DATE '2025-01-18', DATE '2025-01-20',  7.50),
 (17, 5, 106, DATE '2025-08-14', DATE '2025-08-21', 26.25),
 (18, 2, 102, DATE '2025-09-02', DATE '2025-09-05', 13.50),
 (19, 1, 101, DATE '2025-10-10', NULL,              NULL),
 (20, 4, 108, DATE '2024-12-28', DATE '2025-01-03', 55.50),
 (21, 3, 103, DATE '2025-02-26', DATE '2025-03-02', 28.00),
 (22, 5, 104, DATE '2025-05-05', DATE '2025-05-08', 21.00);

SELECT
    (SELECT COUNT(*) FROM stations) AS stations,
    (SELECT COUNT(*) FROM bikes) AS bikes,
    (SELECT COUNT(*) FROM members) AS members,
    (SELECT COUNT(*) FROM rentals) AS rentals;

-- Part 2
-- Worked example
CREATE OR REPLACE FUNCTION inc(val INTEGER)
RETURNS INTEGER AS $$
DECLARE
    result INTEGER;
BEGIN
    result := val + 1;
    RETURN result;
END;
$$ LANGUAGE plpgsql;

SELECT inc(10);

-- Exercise 2.1
CREATE OR REPLACE FUNCTION rental_days(p_rental_id INT)
RETURNS INT AS $$
DECLARE
    v_days INT;
BEGIN
    SELECT r.end_date - r.start_date
    INTO v_days
    FROM rentals AS r
    WHERE r.rental_id = p_rental_id;

    RETURN v_days;
END;
$$ LANGUAGE plpgsql;

SELECT rental_days(2);
SELECT rental_days(11);
SELECT rental_days(19);
SELECT rental_days(999);

-- Question 2.1:
-- Rental 19 returns NULL because end_date is NULL (the rental is open).
-- Rental 999 returns NULL because SELECT INTO finds no row and leaves
-- the target variable NULL. The result is the same, but the reasons differ.

-- Exercise 2.2
CREATE OR REPLACE FUNCTION member_rental_count(p_member_id INT)
RETURNS INT AS $$
DECLARE
    v_count INT;
BEGIN
    SELECT COUNT(*)
    INTO v_count
    FROM rentals AS r
    WHERE r.member_id = p_member_id;

    RETURN v_count;
END;
$$ LANGUAGE plpgsql;

SELECT member_rental_count(1); -- expected: 5
SELECT member_rental_count(5); -- expected: 3
SELECT member_rental_count(6); -- expected: 0
SELECT member_rental_count(99); -- expected: 0

-- Question 2.2:
-- COUNT(*) is an aggregate that returns one row even when no records match.
-- In that case it returns 0, not NULL. Therefore member 6 and nonexistent
-- member 99 both produce 0; COUNT does not tell us whether the member exists.

-- Exercise 2.3
CREATE OR REPLACE FUNCTION station_city(p_station_id INT)
RETURNS VARCHAR AS $$
DECLARE
    v_city VARCHAR(40);
BEGIN
    SELECT s.city
    INTO v_city
    FROM stations AS s
    WHERE s.station_id = p_station_id;

    RETURN v_city;
END;
$$ LANGUAGE plpgsql;

SELECT station_city(30); -- expected: Astana
SELECT station_city(77); -- expected: NULL

-- Exercise 2.4
SELECT
    r.rental_id,
    r.member_id,
    rental_days(r.rental_id) AS duration_days
FROM rentals AS r
WHERE rental_days(r.rental_id) > 4
ORDER BY duration_days DESC;

-- Part 3

-- Exercise 3.1
CREATE OR REPLACE FUNCTION fee_with_discount(
    p_fee NUMERIC,
    p_percent NUMERIC
)
RETURNS NUMERIC AS $$
BEGIN
    RETURN ROUND(p_fee * (1 - p_percent / 100), 2);
END;
$$ LANGUAGE plpgsql;

SELECT fee_with_discount(74.00, 15); -- expected: 62.90

-- Exercise 3.2
CREATE OR REPLACE FUNCTION member_stats(
    p_member_id INT,
    OUT rental_cnt INT,
    OUT total_fee NUMERIC,
    OUT last_start DATE
) AS $$
BEGIN
    SELECT
        COUNT(*)::INT,
        COALESCE(SUM(r.fee), 0),
        MAX(r.start_date)
    INTO rental_cnt, total_fee, last_start
    FROM rentals AS r
    WHERE r.member_id = p_member_id;
END;
$$ LANGUAGE plpgsql;

SELECT member_stats(3);
SELECT * FROM member_stats(3);
SELECT * FROM member_stats(6);

-- Question 3.2:
-- SELECT member_stats(3) displays the composite result as one column.
-- SELECT * FROM member_stats(3) expands the OUT values into separate columns.
-- The second form is usually more convenient in a larger query because each
-- returned value has its own column. Member 6 returns 0, 0 and NULL:
-- no rentals, no fees, and no latest start date.

-- Exercise 3.3
CREATE OR REPLACE FUNCTION apply_late_fee(INOUT p_fee NUMERIC)
AS $$
BEGIN
    p_fee := p_fee + 5.00;
END;
$$ LANGUAGE plpgsql;

SELECT apply_late_fee(fee)
FROM rentals
WHERE rental_id = 1; -- expected: 18.50

-- Question 3.3:
-- INOUT is both input and output. PostgreSQL returns the final value of the
-- INOUT parameter automatically, so a separate RETURNS clause and RETURN
-- statement are not required.

-- Exercise 3.4
CREATE OR REPLACE FUNCTION fee_summary(
    VARIADIC p_fees NUMERIC[],
    OUT total NUMERIC,
    OUT average NUMERIC,
    OUT largest NUMERIC
) AS $$
BEGIN
    SELECT
        COALESCE(SUM(p_fees[g.i]), 0),
        ROUND(AVG(p_fees[g.i]), 2),
        MAX(p_fees[g.i])
    INTO total, average, largest
    FROM generate_subscripts(p_fees, 1) AS g(i);
END;
$$ LANGUAGE plpgsql;

SELECT * FROM fee_summary(13.50, 35.00, 18.50, 31.50);
SELECT * FROM fee_summary();

-- Question 3.4:
-- With no arguments, the variadic array is empty. The function returns
-- total = 0, average = NULL and largest = NULL because AVG and MAX over
-- an empty set are NULL. VARIADIC must be last because it consumes all
-- remaining positional arguments; parameters after it would have no
-- unambiguous way to receive their values.

-- Exercise 3.5
-- (a) Row id to look up: IN, because the function only reads the id.
-- (b) Running balance updated by the function: INOUT, because the caller
--     supplies the initial balance and receives the modified balance.
-- (c) Unknown-length list of station ids: VARIADIC, because it collects
--     a variable number of values of the same type into an array.
-- (d) Two statistics returned together: OUT parameters, because multiple
--     output values can be returned from one function call.

-- Part 4
-- Exercise 4.1
CREATE OR REPLACE FUNCTION total_fees(p_member_id INT)
RETURNS NUMERIC AS $$
DECLARE
    v_total NUMERIC;
BEGIN
    SELECT COALESCE(SUM(r.fee), 0)
    INTO v_total
    FROM rentals AS r
    WHERE r.member_id = p_member_id;

    RETURN v_total;
END;
$$ LANGUAGE plpgsql;

SELECT total_fees(1);
SELECT total_fees(6); -- expected: 0

-- Exercise 4.2
CREATE OR REPLACE FUNCTION total_fees(
    p_member_id INT,
    p_from_date DATE
)
RETURNS NUMERIC AS $$
DECLARE
    v_total NUMERIC;
BEGIN
    SELECT COALESCE(SUM(r.fee), 0)
    INTO v_total
    FROM rentals AS r
    WHERE r.member_id = p_member_id
      AND r.start_date >= p_from_date;

    RETURN v_total;
END;
$$ LANGUAGE plpgsql;

SELECT total_fees(1, DATE '2024-01-01');
SELECT total_fees(1, DATE '2025-01-01');

-- In psql, inspect both signatures with:
-- \df total_fees
-- Or query PostgreSQL's catalog:
SELECT
    p.proname AS function_name,
    pg_get_function_identity_arguments(p.oid) AS argument_types
FROM pg_proc AS p
JOIN pg_namespace AS n ON n.oid = p.pronamespace
WHERE n.nspname = current_schema()
  AND p.proname = 'total_fees'
ORDER BY argument_types;

-- Exercise 4.3
-- Run the following CREATE OR REPLACE separately:
-- CREATE OR REPLACE FUNCTION total_fees(
--     p_member_id INT,
--     p_from_date DATE DEFAULT DATE '2025-01-01'
-- )
-- RETURNS NUMERIC AS $$
-- DECLARE
--     v_total NUMERIC;
-- BEGIN
--     SELECT COALESCE(SUM(r.fee), 0)
--     INTO v_total
--     FROM rentals AS r
--     WHERE r.member_id = p_member_id
--       AND r.start_date >= p_from_date;
--     RETURN v_total;
-- END;
-- $$ LANGUAGE plpgsql;
--
-- Then run SELECT total_fees(1); separately. It is ambiguous because
-- both total_fees(INT) and total_fees(INT, DATE DEFAULT ...) can accept
-- a call with one argument. Copy the exact ERROR and HINT from your
-- PostgreSQL client into your report; wording can vary by PostgreSQL version.

-- Exercise 4.4
DROP FUNCTION total_fees(INT);

SELECT total_fees(1); -- now calls the two-argument version using its default date

-- Question 4.4:
-- The remaining two-argument function answers the one-argument call.
-- It uses DATE '2025-01-01' as the default. Dropping the two-argument
-- version instead would leave the original one-argument function, which
-- would calculate the sum over all rentals; the result would differ.

-- Exercise 4.5
CREATE OR REPLACE FUNCTION total_fees(p_member_name VARCHAR)
RETURNS NUMERIC AS $$
DECLARE
    v_total NUMERIC;
BEGIN
    SELECT COALESCE(SUM(r.fee), 0)
    INTO v_total
    FROM members AS m
    LEFT JOIN rentals AS r ON r.member_id = m.member_id
    WHERE m.full_name = p_member_name;

    RETURN v_total;
END;
$$ LANGUAGE plpgsql;

SELECT total_fees('Aisha Nurlanova'::VARCHAR);
SELECT total_fees(1);

-- Question 4.5:
-- The VARCHAR call reaches total_fees(VARCHAR), which looks up the member
-- by full name and sums all recorded fees. The integer call reaches
-- total_fees(INT, DATE) because the one-argument INT overload was dropped;
-- it uses the default cutoff date 2025-01-01. Therefore the two values differ.
-- Adding the VARCHAR overload does not make the integer call ambiguous
-- because VARCHAR and INT are different argument types.


-- Part 5

-- Exercise 5.1
CREATE OR REPLACE FUNCTION find_bikes(p_pattern VARCHAR)
RETURNS TABLE (
    found_id INT,
    found_model VARCHAR,
    found_rate NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        b.bike_id,
        b.model::VARCHAR,
        b.daily_rate
    FROM bikes AS b
    WHERE b.model ILIKE p_pattern
    ORDER BY b.bike_id;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM find_bikes('%road%');
SELECT * FROM find_bikes('%Mini');

-- Question 5.1:
-- SELECT * FROM find_bikes(...) expands the returned rows into columns.
-- SELECT find_bikes(...) without FROM displays each returned composite row
-- as one value in a single column, rather than as three separate columns.

-- Exercise 5.2
CREATE OR REPLACE FUNCTION member_history(p_member_id INT)
RETURNS TABLE (
    rental_id INT,
    bike_model VARCHAR,
    station_name VARCHAR,
    duration_days INT,
    rental_fee NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        r.rental_id,
        b.model::VARCHAR,
        s.station_name::VARCHAR,
        (r.end_date - r.start_date)::INT,
        r.fee
    FROM rentals AS r
    JOIN bikes AS b ON b.bike_id = r.bike_id
    LEFT JOIN stations AS s ON s.station_id = b.station_id
    WHERE r.member_id = p_member_id
    ORDER BY r.start_date;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM member_history(3);

-- Exercise 5.3:
CREATE OR REPLACE FUNCTION bike_list(p_station_id INT)
RETURNS TABLE (found_bike_id INT, found_model VARCHAR) AS $$
BEGIN
    RETURN QUERY
    SELECT b.bike_id, b.model::VARCHAR
    FROM bikes AS b
    WHERE b.station_id = p_station_id;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM bike_list(10);

DROP FUNCTION bike_list(INT);

CREATE FUNCTION bike_list(p_station_id INT)
RETURNS TABLE (bike_id INT, model VARCHAR) AS $$
BEGIN
    RETURN QUERY
    SELECT b.bike_id, b.model::VARCHAR
    FROM bikes AS b
    WHERE b.station_id = p_station_id;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM bike_list(10);

-- Question 5.3:
-- The first fix removes the name collision by changing output-column names.
-- The second fix preserves the output names and removes ambiguity by using
-- the table alias b for every selected table column.

-- Exercise 5.4
CREATE OR REPLACE FUNCTION station_board(p_city VARCHAR)
RETURNS TABLE (
    s_name VARCHAR,
    s_bikes INT,
    s_free INT
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        s.station_name::VARCHAR,
        COUNT(b.bike_id)::INT,
        (s.capacity - COUNT(b.bike_id))::INT
    FROM stations AS s
    LEFT JOIN bikes AS b ON b.station_id = s.station_id
    WHERE s.city = p_city
    GROUP BY s.station_id, s.station_name, s.capacity
    ORDER BY s.station_id;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM station_board('Almaty');
SELECT * FROM station_board('Astana');


-- Part 6

-- Exercise 6.1
DO $$
<<rental_report>>
DECLARE
    total_rentals INTEGER := 0;
BEGIN
    SELECT COUNT(*)::INT
    INTO total_rentals
    FROM rentals;

    RAISE NOTICE 'The rentals table holds % rows.', total_rentals;
END rental_report;
$$;

-- Question 6.1:
-- If the label after END does not match the opening label, PostgreSQL
-- reports a syntax/label mismatch and the DO block does not execute.

-- Exercise 6.2
DO $$
<<rental_report>>
DECLARE
    fee_total NUMERIC;
BEGIN
    SELECT COALESCE(SUM(fee), 0)
    INTO fee_total
    FROM rentals;

    RAISE NOTICE '1. Outer total before subblock: %', fee_total;

    <<fee_subblock>>
    DECLARE
        fee_total NUMERIC;
    BEGIN
        SELECT COALESCE(SUM(r.fee), 0)
        INTO fee_total
        FROM rentals AS r
        WHERE r.start_date >= DATE '2025-01-01';

        RAISE NOTICE '2. Subblock total: %', fee_total;
        RAISE NOTICE '3. Outer total from subblock: %', rental_report.fee_total;
    END fee_subblock;

    RAISE NOTICE '4. Outer total after subblock: %', fee_total;
END rental_report;
$$;

-- Question 6.2:
-- The subblock declaration hides (shadows) the outer fee_total variable.
-- Assigning the inner variable does not change the outer variable.
-- rental_report.fee_total explicitly accesses the outer variable.
-- Expected values from the supplied data:
-- 1. Outer total before subblock = 621.50
-- 2. Subblock total (start_date >= 2025-01-01) = 369.00
-- 3. Outer total from subblock = 621.50
-- 4. Outer total after subblock = 621.50

-- Exercise 6.3
DO $$
DECLARE
    shared_value INT := 10;
BEGIN
    <<first_subblock>>
    BEGIN
        RAISE NOTICE 'First subblock sees: %', shared_value;
    END first_subblock;

    <<second_subblock>>
    BEGIN
        RAISE NOTICE 'Second subblock sees: %', shared_value;
    END second_subblock;
END;
$$;

-- Exercise 6.4
CREATE OR REPLACE FUNCTION fee_split(
    p_from_date DATE,
    OUT before_total NUMERIC,
    OUT after_total NUMERIC
) AS $$
BEGIN
    SELECT COALESCE(SUM(r.fee), 0)
    INTO before_total
    FROM rentals AS r
    WHERE r.start_date < p_from_date;

    SELECT COALESCE(SUM(r.fee), 0)
    INTO after_total
    FROM rentals AS r
    WHERE r.start_date >= p_from_date;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM fee_split(DATE '2025-01-01');

SELECT
    before_total,
    after_total,
    before_total + after_total AS split_total,
    (SELECT COALESCE(SUM(fee), 0) FROM rentals) AS whole_table_total
FROM fee_split(DATE '2025-01-01');


-- Part 7
-- Exercise 7.1
CREATE OR REPLACE FUNCTION station_load(
    p_station_id INT,
    OUT bikes_parked INT,
    OUT capacity_pct NUMERIC
) AS $$
DECLARE
    v_capacity INT;
BEGIN
    SELECT s.capacity
    INTO v_capacity
    FROM stations AS s
    WHERE s.station_id = p_station_id;

    SELECT COUNT(b.bike_id)::INT
    INTO bikes_parked
    FROM bikes AS b
    WHERE b.station_id = p_station_id;

    IF v_capacity IS NULL THEN
        capacity_pct := NULL;
    ELSIF v_capacity = 0 THEN
        capacity_pct := 0.0;
    ELSE
        capacity_pct := ROUND((bikes_parked::NUMERIC / v_capacity) * 100, 1);
    END IF;
END;
$$ LANGUAGE plpgsql;

SELECT s.station_id, s.station_name, l.*
FROM stations AS s
CROSS JOIN LATERAL station_load(s.station_id) AS l
ORDER BY s.station_id;

-- Question 7.1:
-- For a station with capacity 0, the percentage is defined as 0.0.
-- Division by zero is undefined, so the function handles this case
-- explicitly instead of performing the division.

-- Exercise 7.2
CREATE OR REPLACE FUNCTION top_members(p_limit INT DEFAULT 3)
RETURNS TABLE (
    member_name VARCHAR,
    rental_count BIGINT,
    amount_spent NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        m.full_name::VARCHAR,
        COUNT(r.rental_id),
        COALESCE(SUM(r.fee), 0)::NUMERIC
    FROM members AS m
    LEFT JOIN rentals AS r ON r.member_id = m.member_id
    GROUP BY m.member_id, m.full_name
    ORDER BY COALESCE(SUM(r.fee), 0) DESC, m.member_id
    LIMIT p_limit;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM top_members();
SELECT * FROM top_members(6);

-- Question 7.2:
-- Aisha Nurlanova has 5 rentals but is ranked below Chen Wei and Daniyar
-- Serik, who each have 4 rentals. The ranking is by total amount spent,
-- not by rental count. Aisha's total recorded fees are lower, so this is
-- expected and is not a bug.

-- Exercise 7.3
CREATE OR REPLACE FUNCTION rental_invoice(p_rental_id INT)
RETURNS TABLE (
    member_name VARCHAR,
    bike_model VARCHAR,
    duration_days INT,
    amount_owed NUMERIC,
    rental_status VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        m.full_name::VARCHAR,
        b.model::VARCHAR,
        (COALESCE(r.end_date, CURRENT_DATE) - r.start_date)::INT,
        ROUND(
            (COALESCE(r.end_date, CURRENT_DATE) - r.start_date)::NUMERIC
            * b.daily_rate,
            2
        ),
        CASE
            WHEN r.end_date IS NULL THEN 'OPEN'::VARCHAR
            ELSE 'CLOSED'::VARCHAR
        END
    FROM rentals AS r
    JOIN members AS m ON m.member_id = r.member_id
    JOIN bikes AS b ON b.bike_id = r.bike_id
    WHERE r.rental_id = p_rental_id;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM rental_invoice(11);
SELECT * FROM rental_invoice(19);

-- Question 7.3:
-- Rental 11 has 8 days (2025-06-01 to 2025-06-09) at 9.25 per day,
-- so the calculated amount is 74.00, equal to the stored fee.
-- Rental 19 is open; its duration is calculated through CURRENT_DATE,
-- so the amount increases as the current date advances. A function
-- depending on CURRENT_DATE must not be declared IMMUTABLE because its
-- result can change without its arguments changing. The default volatility
-- category (VOLATILE) is appropriate for this function.

-- Exercise 7.4
CREATE OR REPLACE FUNCTION city_report(p_city VARCHAR)
RETURNS TABLE (
    member_count BIGINT,
    rental_count BIGINT,
    total_revenue NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        COUNT(DISTINCT m.member_id),
        COUNT(r.rental_id),
        COALESCE(SUM(r.fee), 0)::NUMERIC
    FROM members AS m
    LEFT JOIN rentals AS r ON r.member_id = m.member_id
    WHERE m.city = p_city;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION city_report(
    p_city VARCHAR,
    p_from_date DATE
)
RETURNS TABLE (
    member_count BIGINT,
    rental_count BIGINT,
    total_revenue NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        COUNT(DISTINCT m.member_id),
        COUNT(r.rental_id),
        COALESCE(SUM(r.fee), 0)::NUMERIC
    FROM members AS m
    LEFT JOIN rentals AS r
        ON r.member_id = m.member_id
       AND r.start_date >= p_from_date
    WHERE m.city = p_city;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM city_report('Almaty');
SELECT * FROM city_report('Almaty', DATE '2025-01-01');

-- Compare with the incorrect WHERE-condition approach:
SELECT
    COUNT(DISTINCT m.member_id) AS member_count,
    COUNT(r.rental_id) AS rental_count,
    COALESCE(SUM(r.fee), 0) AS total_revenue
FROM members AS m
LEFT JOIN rentals AS r ON r.member_id = m.member_id
WHERE m.city = 'Almaty'
  AND r.start_date >= DATE '2025-01-01';

-- Question 7.4:
-- The date condition belongs in the LEFT JOIN ... ON clause. This keeps
-- city members who have no rentals after the cutoff date. For Almaty,
-- the correct ON version counts 3 members; putting the date condition
-- in WHERE removes the member with no qualifying rental and counts 2.
-- The WHERE condition effectively turns the relevant LEFT JOIN behavior
-- into an inner filter for rows with a matching rental.


