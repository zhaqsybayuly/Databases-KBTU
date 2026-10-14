-- Lab Work 5: Database Constraints
-- Student name: Kamal Zhanserik
-- Student ID: 25B031305
-- PostgreSQL

-- drop everything first so the file can be run again
DROP SCHEMA IF EXISTS ecommerce CASCADE;
DROP TABLE IF EXISTS employees, products_catalog, bookings, customers, inventory, users,
    course_enrollments, employees_dept, departments, student_courses, books, authors,
    publishers, order_items, products_fk, categories, orders CASCADE;


-- ==================== PART 1: CHECK ====================

-- Task 1.1
-- age must be from 18 to 65, salary must be positive
CREATE TABLE employees (
    employee_id integer,
    first_name  text,
    last_name   text,
    age         integer CHECK (age BETWEEN 18 AND 65),
    salary      numeric CHECK (salary > 0)
);

-- Task 1.2
-- one named constraint for all three price rules
CREATE TABLE products_catalog (
    product_id     integer,
    product_name   text,
    regular_price  numeric,
    discount_price numeric,
    CONSTRAINT valid_discount CHECK (
        regular_price > 0
        AND discount_price > 0
        AND discount_price < regular_price
    )
);

-- Task 1.3
-- second check uses two columns, so it is written as a table constraint
CREATE TABLE bookings (
    booking_id     integer,
    check_in_date  date,
    check_out_date date,
    num_guests     integer CHECK (num_guests BETWEEN 1 AND 10),
    CHECK (check_out_date > check_in_date)
);

-- Task 1.4
-- valid rows
INSERT INTO employees VALUES (1, 'Aidos', 'Serikov', 25, 350000);
INSERT INTO employees VALUES (2, 'Dana', 'Nurlanova', 41, 520000);

INSERT INTO products_catalog VALUES (1, 'Laptop', 450000, 399000);
INSERT INTO products_catalog VALUES (2, 'Headphones', 25000, 19990);

INSERT INTO bookings VALUES (1, '2026-11-01', '2026-11-05', 2);
INSERT INTO bookings VALUES (2, '2026-12-20', '2026-12-27', 4);

-- invalid rows (commented out because they fail)

-- age is less than 18
-- INSERT INTO employees VALUES (3, 'Arman', 'Bekov', 16, 200000);
-- ERROR: new row for relation "employees" violates check constraint "employees_age_check"

-- age is more than 65
-- INSERT INTO employees VALUES (4, 'Saule', 'Omarova', 70, 300000);
-- ERROR: new row for relation "employees" violates check constraint "employees_age_check"

-- negative salary
-- INSERT INTO employees VALUES (5, 'Timur', 'Ali', 30, -1000);
-- ERROR: new row for relation "employees" violates check constraint "employees_salary_check"

-- regular_price = 0
-- INSERT INTO products_catalog VALUES (3, 'Mouse', 0, 5000);
-- ERROR: new row for relation "products_catalog" violates check constraint "valid_discount"

-- discount price is bigger than regular price
-- INSERT INTO products_catalog VALUES (4, 'Keyboard', 15000, 18000);
-- ERROR: new row for relation "products_catalog" violates check constraint "valid_discount"

-- discount price is negative
-- INSERT INTO products_catalog VALUES (5, 'Monitor', 90000, -100);
-- ERROR: new row for relation "products_catalog" violates check constraint "valid_discount"

-- 0 guests
-- INSERT INTO bookings VALUES (3, '2026-11-10', '2026-11-12', 0);
-- ERROR: new row for relation "bookings" violates check constraint "bookings_num_guests_check"

-- 15 guests (max is 10)
-- INSERT INTO bookings VALUES (4, '2026-11-10', '2026-11-12', 15);
-- ERROR: new row for relation "bookings" violates check constraint "bookings_num_guests_check"

-- check out is before check in
-- INSERT INTO bookings VALUES (5, '2026-11-10', '2026-11-08', 3);
-- ERROR: new row for relation "bookings" violates check constraint "bookings_check"

-- note: for valid_discount postgres says only the constraint name, not which of the 3 rules failed


-- ==================== PART 2: NOT NULL ====================

-- Task 2.1
-- phone is optional, others are required
CREATE TABLE customers (
    customer_id       integer NOT NULL,
    email             text NOT NULL,
    phone             text,
    registration_date date NOT NULL
);

-- Task 2.2
-- NOT NULL + CHECK together
CREATE TABLE inventory (
    item_id      integer NOT NULL,
    item_name    text NOT NULL,
    quantity     integer NOT NULL CHECK (quantity >= 0),
    unit_price   numeric NOT NULL CHECK (unit_price > 0),
    last_updated timestamp NOT NULL
);

-- Task 2.3
-- 1) complete records
INSERT INTO customers VALUES (1, 'aidos@mail.kz', '+77011234567', '2026-09-01');
INSERT INTO inventory VALUES (1, 'Notebook', 120, 450, '2026-10-01 10:00:00');
INSERT INTO inventory VALUES (2, 'Pen', 500, 150, NOW());

-- 2) NULL in NOT NULL columns
-- INSERT INTO customers VALUES (2, NULL, '+77021112233', '2026-09-05');
-- ERROR: null value in column "email" of relation "customers" violates not-null constraint

-- INSERT INTO customers VALUES (3, 'dana@mail.kz', '+77051234567', NULL);
-- ERROR: null value in column "registration_date" of relation "customers" violates not-null constraint

-- INSERT INTO inventory VALUES (3, NULL, 10, 1000, NOW());
-- ERROR: null value in column "item_name" of relation "inventory" violates not-null constraint

-- INSERT INTO inventory VALUES (4, 'Marker', NULL, 300, NOW());
-- ERROR: null value in column "quantity" of relation "inventory" violates not-null constraint
-- (CHECK quantity >= 0 does not stop NULL, NOT NULL does)

-- 3) NULL in nullable column - works
INSERT INTO customers VALUES (4, 'arman@mail.kz', NULL, '2026-10-02');


-- ==================== PART 3: UNIQUE ====================

-- Task 3.1
CREATE TABLE users (
    user_id    integer,
    username   text UNIQUE,
    email      text UNIQUE,
    created_at timestamp
);

-- Task 3.2
-- the combination must be unique, not each column alone
CREATE TABLE course_enrollments (
    enrollment_id integer,
    student_id    integer,
    course_code   text,
    semester      text,
    UNIQUE (student_id, course_code, semester)
);

INSERT INTO course_enrollments VALUES (1, 101, 'CSE201', 'Fall 2026');
INSERT INTO course_enrollments VALUES (2, 101, 'CSE202', 'Fall 2026');   -- other course, ok
INSERT INTO course_enrollments VALUES (3, 101, 'CSE201', 'Spring 2027'); -- other semester, ok

-- same student, same course, same semester
-- INSERT INTO course_enrollments VALUES (4, 101, 'CSE201', 'Fall 2026');
-- ERROR: duplicate key value violates unique constraint "course_enrollments_student_id_course_code_semester_key"

-- Task 3.3
-- postgres already gave auto names (users_username_key, users_email_key),
-- so I drop them and add my own named ones
ALTER TABLE users DROP CONSTRAINT users_username_key;
ALTER TABLE users DROP CONSTRAINT users_email_key;
ALTER TABLE users ADD CONSTRAINT unique_username UNIQUE (username);
ALTER TABLE users ADD CONSTRAINT unique_email UNIQUE (email);

INSERT INTO users VALUES (1, 'zhanserik', 'zhanserik@kbtu.kz', NOW());
INSERT INTO users VALUES (2, 'aidos_s', 'aidos@kbtu.kz', NOW());

-- duplicate username
-- INSERT INTO users VALUES (3, 'zhanserik', 'other@kbtu.kz', NOW());
-- ERROR: duplicate key value violates unique constraint "unique_username"

-- duplicate email
-- INSERT INTO users VALUES (4, 'dana_n', 'aidos@kbtu.kz', NOW());
-- ERROR: duplicate key value violates unique constraint "unique_email"


-- ==================== PART 4: PRIMARY KEY ====================

-- Task 4.1
CREATE TABLE departments (
    dept_id   integer PRIMARY KEY,
    dept_name text NOT NULL,
    location  text
);

INSERT INTO departments VALUES (1, 'IT', 'Almaty');
INSERT INTO departments VALUES (2, 'HR', 'Astana');
INSERT INTO departments VALUES (3, 'Sales', 'Shymkent');

-- duplicate dept_id
-- INSERT INTO departments VALUES (1, 'Finance', 'Almaty');
-- ERROR: duplicate key value violates unique constraint "departments_pkey"

-- NULL dept_id
-- INSERT INTO departments VALUES (NULL, 'Marketing', 'Almaty');
-- ERROR: null value in column "dept_id" of relation "departments" violates not-null constraint
-- (primary key is automatically NOT NULL)

-- Task 4.2
-- one student can take many courses, one course has many students,
-- but the pair (student, course) is only once
CREATE TABLE student_courses (
    student_id      integer,
    course_id       integer,
    enrollment_date date,
    grade           text,
    PRIMARY KEY (student_id, course_id)
);

INSERT INTO student_courses VALUES (101, 1, '2026-09-01', 'A');
INSERT INTO student_courses VALUES (101, 2, '2026-09-01', 'B+');
INSERT INTO student_courses VALUES (102, 1, '2026-09-02', 'A-');

-- INSERT INTO student_courses VALUES (101, 1, '2026-09-03', 'C');
-- ERROR: duplicate key value violates unique constraint "student_courses_pkey"

-- Task 4.3
/*
1) UNIQUE vs PRIMARY KEY
   Both don't allow duplicate values. Differences:
   - PRIMARY KEY can not be NULL. UNIQUE column can have NULL
     (and in postgres even several NULLs, because NULL is not equal to NULL).
   - PRIMARY KEY is the main identifier of a row, other tables
     usually reference it with foreign keys.
   - table can have only one PRIMARY KEY, but many UNIQUE.

2) single column vs composite PK
   - single column: when there is one column that identifies the row,
     for example dept_id or an auto id (serial). Most tables.
   - composite: when only a combination is unique, usually in
     "connection" tables for many-to-many, like student_courses
     (student_id + course_id). One column alone repeats there.

3) why only one PK but many UNIQUE
   PK is THE identifier of the row, the table is "organized" by it and
   foreign keys point to it, so it makes sense to have only one.
   But a table can have several other things that also must not repeat
   (email, username, phone...), for them we use UNIQUE.
*/


-- ==================== PART 5: FOREIGN KEY ====================

-- Task 5.1
-- dept_id must exist in departments
CREATE TABLE employees_dept (
    emp_id    integer PRIMARY KEY,
    emp_name  text NOT NULL,
    dept_id   integer REFERENCES departments,
    hire_date date
);

INSERT INTO employees_dept VALUES (1, 'Aidos Serikov', 1, '2024-02-01');
INSERT INTO employees_dept VALUES (2, 'Dana Nurlanova', 2, '2023-08-15');
INSERT INTO employees_dept VALUES (3, 'Arman Bekov', 3, '2025-01-10');

-- department 99 does not exist
-- INSERT INTO employees_dept VALUES (4, 'Saule Omarova', 99, '2025-03-01');
-- ERROR: insert or update on table "employees_dept" violates foreign key constraint "employees_dept_dept_id_fkey"
-- DETAIL: Key (dept_id)=(99) is not present in table "departments".

-- Task 5.2
-- library: books references authors and publishers
CREATE TABLE authors (
    author_id   integer PRIMARY KEY,
    author_name text NOT NULL,
    country     text
);

CREATE TABLE publishers (
    publisher_id   integer PRIMARY KEY,
    publisher_name text NOT NULL,
    city           text
);

CREATE TABLE books (
    book_id          integer PRIMARY KEY,
    title            text NOT NULL,
    author_id        integer REFERENCES authors,
    publisher_id     integer REFERENCES publishers,
    publication_year integer,
    isbn             text UNIQUE
);

INSERT INTO authors VALUES
    (1, 'Abai Kunanbayev', 'Kazakhstan'),
    (2, 'Mukhtar Auezov', 'Kazakhstan'),
    (3, 'George Orwell', 'UK');

INSERT INTO publishers VALUES
    (1, 'Atamura', 'Almaty'),
    (2, 'Penguin Books', 'London');

INSERT INTO books VALUES
    (1, 'Book of Words', 1, 1, 1918, '978-601-01-0001-1'),
    (2, 'The Path of Abai', 2, 1, 1942, '978-601-01-0002-8'),
    (3, '1984', 3, 2, 1949, '978-0-452-28423-4'),
    (4, 'Animal Farm', 3, 2, 1945, '978-0-452-28424-1');

-- Task 5.3
-- RESTRICT: can't delete category while products use it
-- CASCADE: deleting order deletes its items too
CREATE TABLE categories (
    category_id   integer PRIMARY KEY,
    category_name text NOT NULL
);

CREATE TABLE products_fk (
    product_id   integer PRIMARY KEY,
    product_name text NOT NULL,
    category_id  integer REFERENCES categories ON DELETE RESTRICT
);

CREATE TABLE orders (
    order_id   integer PRIMARY KEY,
    order_date date NOT NULL
);

CREATE TABLE order_items (
    item_id    integer PRIMARY KEY,
    order_id   integer REFERENCES orders ON DELETE CASCADE,
    product_id integer REFERENCES products_fk,
    quantity   integer CHECK (quantity > 0)
);

INSERT INTO categories VALUES (1, 'Electronics'), (2, 'Books');
INSERT INTO products_fk VALUES (1, 'Laptop', 1), (2, 'Phone', 1), (3, 'SQL Basics', 2);
INSERT INTO orders VALUES (1, '2026-10-01'), (2, '2026-10-05');
INSERT INTO order_items VALUES (1, 1, 1, 1), (2, 1, 3, 2), (3, 2, 2, 1);

-- scenario 1: delete category that has products
-- DELETE FROM categories WHERE category_id = 1;
-- ERROR: update or delete on table "categories" violates foreign key constraint
--        "products_fk_category_id_fkey" on table "products_fk"
-- DETAIL: Key (category_id)=(1) is still referenced from table "products_fk".
-- result: nothing deleted, RESTRICT blocked it. first need to delete/move the products.

-- scenario 2: delete an order
SELECT * FROM order_items;            -- before: 3 rows (items 1,2 belong to order 1)
DELETE FROM orders WHERE order_id = 1;
SELECT * FROM order_items;            -- after: only item 3 is left
-- result: DELETE worked without error and items 1 and 2 were deleted automatically (CASCADE)


-- ==================== PART 6: E-COMMERCE ====================

-- separate schema, because customers/products/orders names are already used above
CREATE SCHEMA ecommerce;
SET search_path TO ecommerce, public;

-- Task 6.1

CREATE TABLE customers (
    customer_id       serial PRIMARY KEY,
    name              text NOT NULL,
    email             text NOT NULL UNIQUE,   -- one account per email
    phone             text,                   -- optional
    registration_date date NOT NULL DEFAULT CURRENT_DATE
);

CREATE TABLE products (
    product_id     serial PRIMARY KEY,
    name           text NOT NULL,
    description    text,
    price          numeric(10,2) NOT NULL CHECK (price >= 0),
    stock_quantity integer NOT NULL DEFAULT 0 CHECK (stock_quantity >= 0)
);

-- RESTRICT on customer: don't lose order history if someone tries to delete a customer
CREATE TABLE orders (
    order_id     serial PRIMARY KEY,
    customer_id  integer NOT NULL REFERENCES customers ON DELETE RESTRICT,
    order_date   date NOT NULL DEFAULT CURRENT_DATE,
    total_amount numeric(10,2) NOT NULL CHECK (total_amount >= 0),
    status       text NOT NULL DEFAULT 'pending'
        CHECK (status IN ('pending', 'processing', 'shipped', 'delivered', 'cancelled'))
);

-- CASCADE on order: details don't make sense without the order
-- RESTRICT on product: can't delete a product that was already sold
CREATE TABLE order_details (
    order_detail_id serial PRIMARY KEY,
    order_id        integer NOT NULL REFERENCES orders ON DELETE CASCADE,
    product_id      integer NOT NULL REFERENCES products ON DELETE RESTRICT,
    quantity        integer NOT NULL CHECK (quantity > 0),
    unit_price      numeric(10,2) NOT NULL CHECK (unit_price >= 0)
);

-- sample data
INSERT INTO customers (name, email, phone, registration_date) VALUES
    ('Aidos Serikov',  'aidos@mail.kz', '+77011234567', '2026-01-15'),
    ('Dana Nurlanova', 'dana@mail.kz',  '+77021112233', '2026-02-20'),
    ('Arman Bekov',    'arman@mail.kz', NULL,           '2026-03-05'),
    ('Saule Omarova',  'saule@mail.kz', '+77051234567', '2026-05-11'),
    ('Timur Ali',      'timur@mail.kz', '+77071234567', '2026-08-30');

INSERT INTO products (name, description, price, stock_quantity) VALUES
    ('Laptop Lenovo',   '15.6 inch, 16GB RAM', 389990, 10),
    ('Mouse Logitech',  'Wireless mouse',       12990, 50),
    ('Keyboard',        'Mechanical keyboard',  34990, 25),
    ('Monitor Samsung', '27 inch IPS',          99990, 8),
    ('USB Cable',       'Type-C, 1m',            2490, 200);

INSERT INTO orders (customer_id, order_date, total_amount, status) VALUES
    (1, '2026-09-01', 402980, 'delivered'),
    (2, '2026-09-10',  34990, 'shipped'),
    (3, '2026-09-25',   4980, 'processing'),
    (1, '2026-10-02',  99990, 'pending'),
    (4, '2026-10-05',  12990, 'cancelled'),
    (5, '2026-10-08',   4980, 'pending');

INSERT INTO order_details (order_id, product_id, quantity, unit_price) VALUES
    (1, 1, 1, 389990),
    (1, 2, 1,  12990),
    (2, 3, 1,  34990),
    (3, 5, 2,   2490),
    (4, 4, 1,  99990),
    (5, 2, 1,  12990),
    (6, 5, 2,   2490);

-- tests (failing ones commented out)

-- negative price
-- INSERT INTO products (name, price, stock_quantity) VALUES ('Broken item', -500, 5);
-- ERROR: new row for relation "products" violates check constraint "products_price_check"

-- negative stock
-- INSERT INTO products (name, price, stock_quantity) VALUES ('Headset', 15000, -3);
-- ERROR: new row for relation "products" violates check constraint "products_stock_quantity_check"

-- status not in the list
-- INSERT INTO orders (customer_id, total_amount, status) VALUES (2, 5000, 'paid');
-- ERROR: new row for relation "orders" violates check constraint "orders_status_check"

-- quantity 0
-- INSERT INTO order_details (order_id, product_id, quantity, unit_price) VALUES (2, 1, 0, 389990);
-- ERROR: new row for relation "order_details" violates check constraint "order_details_quantity_check"

-- same email twice
-- INSERT INTO customers (name, email) VALUES ('Another Aidos', 'aidos@mail.kz');
-- ERROR: duplicate key value violates unique constraint "customers_email_key"

-- email is NULL
-- INSERT INTO customers (name, email) VALUES ('No Email', NULL);
-- ERROR: null value in column "email" of relation "customers" violates not-null constraint

-- customer 100 does not exist
-- INSERT INTO orders (customer_id, total_amount) VALUES (100, 1000);
-- ERROR: insert or update on table "orders" violates foreign key constraint "orders_customer_id_fkey"

-- delete customer who has orders (RESTRICT)
-- DELETE FROM customers WHERE customer_id = 1;
-- ERROR: update or delete on table "customers" violates foreign key constraint
--        "orders_customer_id_fkey" on table "orders"

-- delete product that is in order_details (RESTRICT)
-- DELETE FROM products WHERE product_id = 1;
-- ERROR: update or delete on table "products" violates foreign key constraint
--        "order_details_product_id_fkey" on table "order_details"

-- delete order -> its details are deleted too (CASCADE)
SELECT count(*) FROM order_details WHERE order_id = 6;   -- 1
DELETE FROM orders WHERE order_id = 6;
SELECT count(*) FROM order_details WHERE order_id = 6;   -- 0

-- check final data
SELECT * FROM customers;
SELECT * FROM products;
SELECT * FROM orders;
SELECT * FROM order_details;

SET search_path TO public;
