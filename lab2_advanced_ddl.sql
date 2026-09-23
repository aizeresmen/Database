-- Task 1.1
CREATE DATABASE university_main
WITH
    OWNER = postgres
    TEMPLATE = template0
    ENCODING = 'UTF8';

CREATE DATABASE university_archive
WITH
    TEMPLATE = template0
    CONNECTION LIMIT = 50;

CREATE DATABASE university_test
WITH
    TEMPLATE = template0
    CONNECTION LIMIT = 10
    IS_TEMPLATE = true;

-- Task 1.2
CREATE TABLESPACE student_data
    LOCATION '/Users/merejlikalmakanova/postgres_tablespaces/students';

CREATE TABLESPACE course_data
    LOCATION '/Users/merejlikalmakanova/course_data/courses';

CREATE DATABASE university_distributed
WITH
    TEMPLATE = template0
    TABLESPACE = student_data
    ENCODING = 'LATIN9'
    LC_COLLATE = 'C'
    LC_CTYPE = 'C';

-- Task 2.1
CREATE TABLE students (
    student_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    email VARCHAR(100),
    phone CHAR(15),
    date_of_birth DATE,
    enrollment_date DATE,
    gpa DECIMAL(4,2),
    is_active BOOLEAN,
    graduation_year SMALLINT
);

CREATE TABLE professors (
    professor_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    email VARCHAR(100),
    office_number VARCHAR(20),
    hire_date DATE,
    salary DECIMAL(10,2),
    is_tenured BOOLEAN,
    years_experience INTEGER
);

CREATE TABLE courses (
    course_id SERIAL PRIMARY KEY,
    course_code CHAR(8),
    course_title VARCHAR(100),
    description TEXT,
    credits SMALLINT,
    max_enrollment INTEGER,
    course_fee DECIMAL(10,2),
    is_online BOOLEAN,
    created_at TIMESTAMP
);

-- Task 2.2
CREATE TABLE class_schedule (
    schedule_id SERIAL PRIMARY KEY,
    course_id INTEGER,
    professor_id INTEGER,
    classroom VARCHAR(20),
    class_date DATE,
    start_time TIME,
    end_time TIME,
    duration INTERVAL
);

CREATE TABLE student_records (
    record_id SERIAL PRIMARY KEY,
    student_id INTEGER,
    course_id INTEGER,
    semester VARCHAR(20),
    year INTEGER,
    grade CHAR(2),
    attendance_percentage DECIMAL(4,1),
    submission_timestamp TIMESTAMP WITH TIME ZONE,
    last_updated TIMESTAMP WITH TIME ZONE
);

-- Task 3.1
ALTER TABLE students
ADD COLUMN middle_name VARCHAR(30);

ALTER TABLE students
ADD COLUMN student_status VARCHAR(20);

ALTER TABLE students
ALTER COLUMN phone TYPE VARCHAR(20);

ALTER TABLE students
ALTER COLUMN student_status SET DEFAULT 'ACTIVE';

ALTER TABLE students
ALTER COLUMN gpa SET DEFAULT 0.00;

ALTER TABLE professors
ADD column department_code CHAR(5);

ALTER TABLE professors
ADD column research_area TEXT;

ALTER TABLE professors
ALTER column years_experience TYPE SMALLINT;

ALTER TABLE professors
ALTER column is_tenured SET DEFAULT FALSE;

ALTER TABLE professors
ADD column last_promotion_date DATE;

ALTER TABLE courses
ADD column prerequisite_course_id INTEGER;

ALTER TABLE courses
ADD column difficulty_level SMALLINT;

ALTER TABLE courses
ALTER column course_code TYPE VARCHAR(10);

ALTER TABLE courses
ALTER column credits SET DEFAULT 3;

ALTER TABLE courses
ADD column lab_required BOOLEAN DEFAULT FALSE;

-- Task 3.2
ALTER TABLE class_schedule
ADD column room_capacity INTEGER;

ALTER TABLE class_schedule
DROP column duration;

ALTER TABLE class_schedule
ADD column session_type VARCHAR(15);

ALTER TABLE class_schedule
ALTER column classroom TYPE VARCHAR(30);

ALTER TABLE class_schedule
ADD column equipment_needed TEXT;

ALTER TABLE student_records
ADD column extra_credit_points DECIMAL(4,1);

ALTER TABLE student_records
ALTER column grade TYPE VARCHAR(5);

ALTER TABLE student_records
ALTER column extra_credit_points SET DEFAULT 0.0;

ALTER TABLE student_records
ADD column final_exam_date DATE;

ALTER TABLE student_records
DROP column last_updated;

-- Task 4.1
CREATE TABLE departments (
    department_id SERIAL PRIMARY KEY,
    department_name VARCHAR(100),
    department_code CHAR(5),
    building VARCHAR(50),
    phone VARCHAR(15),
    budget DECIMAL(12,2),
    established_year INTEGER
);

CREATE TABLE  library_books (
    book_id SERIAL PRIMARY KEY,
    isbn CHAR(13),
    title VARCHAR(200),
    author VARCHAR(100),
    publisher VARCHAR(100),
    publication_date DATE,
    price DECIMAL(10,2),
    is_available BOOLEAN,
    acquisition_timestamp TIMESTAMP
);

CREATE TABLE student_book_loans (
    loan_id SERIAL PRIMARY KEY,
    student_id INTEGER,
    book_id INTEGER,
    loan_date DATE,
    due_date DATE,
    return_date DATE,
    fine_amount DECIMAL(10,2),
    loan_status VARCHAR(20)
);

-- Task 4.2
ALTER TABLE professors
ADD column department_id INTEGER;

ALTER TABLE students
ADD column advisor_id INTEGER;

ALTER TABLE courses
ADD column department_id INTEGER;

CREATE TABLE grade_scale (
    grade_id SERIAL PRIMARY KEY,
    letter_grade CHAR(2),
    min_percentage DECIMAL(4,1),
    max_percentage DECIMAL(4,1),
    gpa_points DECIMAL(4,2)
);

CREATE TABLE semester_calendar (
    semester_id SERIAL PRIMARY KEY,
    semester_name VARCHAR(20),
    academic_year INTEGER,
    start_date DATE,
    end_date DATE,
    registration_deadline TIMESTAMP WITH TIME ZONE,
    is_current BOOLEAN
);

-- Task 5.1
DROP TABLE IF EXISTS student_book_loans;
DROP TABLE IF EXISTS library_books;
DROP TABLE IF EXISTS grade_scale;

CREATE TABLE grade_scale (
    grade_id SERIAL PRIMARY KEY,
    letter_grade CHAR(2),
    min_percentage DECIMAL(4,1),
    max_percentage DECIMAL(4,1),
    gpa_points DECIMAL(4,2),
    description TEXT
);

DROP TABLE IF EXISTS semester_calendar CASCADE;

CREATE TABLE semester_calendar (
    semester_id SERIAL PRIMARY KEY,
    semester_name VARCHAR(20),
    academic_year INTEGER,
    start_date DATE,
    end_date DATE,
    registration_deadline TIMESTAMP WITH TIME ZONE,
    is_current BOOLEAN
);

-- Task 5.2
ALTER DATABASE university_test
IS_TEMPLATE = FALSE;
DROP DATABASE IF EXISTS university_test;
DROP DATABASE IF EXISTS university_distributed;

CREATE DATABASE university_backup
WITH TEMPLATE university_main;

