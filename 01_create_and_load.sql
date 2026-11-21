-- =====================================================
-- Superstore Project  (MySQL / MariaDB)
-- Step 1: create database + tables
-- Step 2: load train.csv
-- Step 3: split the data into the tables
-- =====================================================

-- ---------- Step 1: Create database and tables ----------
DROP DATABASE IF EXISTS superstore_db;
CREATE DATABASE superstore_db;
USE superstore_db;

-- Raw copy of the CSV file (temporary table)
CREATE TABLE stg_train (
    row_id        INT,
    order_id      VARCHAR(20),
    order_date    VARCHAR(12),
    ship_date     VARCHAR(12),
    ship_mode     VARCHAR(30),
    customer_id   VARCHAR(15),
    customer_name VARCHAR(100),
    segment       VARCHAR(30),
    country       VARCHAR(50),
    city          VARCHAR(100),
    state         VARCHAR(60),
    postal_code   VARCHAR(10),
    region        VARCHAR(20),
    product_id    VARCHAR(20),
    category      VARCHAR(50),
    sub_category  VARCHAR(50),
    product_name  VARCHAR(255),
    sales         DECIMAL(12,4)
);

-- 1) Customers
CREATE TABLE customers (
    customer_id   VARCHAR(15) PRIMARY KEY,
    customer_name VARCHAR(100),
    segment       VARCHAR(30)
);

-- 2) Products
-- (product_key is our own ID, because some product_ids have 2 different names in the data)
CREATE TABLE products (
    product_key  INT AUTO_INCREMENT PRIMARY KEY,
    product_id   VARCHAR(20),
    product_name VARCHAR(255),
    category     VARCHAR(50),
    sub_category VARCHAR(50)
);

-- 3) Locations
CREATE TABLE locations (
    location_id INT AUTO_INCREMENT PRIMARY KEY,
    country     VARCHAR(50),
    region      VARCHAR(20),
    state       VARCHAR(60),
    city        VARCHAR(100),
    postal_code VARCHAR(10)
);

-- 4) Orders (one row per order)
CREATE TABLE orders (
    order_id    VARCHAR(20) PRIMARY KEY,
    order_date  DATE,
    ship_date   DATE,
    ship_mode   VARCHAR(30),
    customer_id VARCHAR(15),
    location_id INT,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (location_id) REFERENCES locations(location_id)
);

-- 5) Order items (one row per product inside an order)
CREATE TABLE order_items (
    row_id      INT PRIMARY KEY,
    order_id    VARCHAR(20),
    product_key INT,
    sales       DECIMAL(12,4),
    FOREIGN KEY (order_id)    REFERENCES orders(order_id),
    FOREIGN KEY (product_key) REFERENCES products(product_key)
);

-- ---------- Step 2: Load the CSV file ----------
-- Change 'train.csv' to the full path of the file on your computer
-- If you get an error, run first:  SET GLOBAL local_infile = 1;
LOAD DATA LOCAL INFILE 'train.csv'
INTO TABLE stg_train
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(row_id, order_id, order_date, ship_date, ship_mode, customer_id, customer_name,
 segment, country, city, state, @postal, region, product_id, category,
 sub_category, product_name, sales)
SET postal_code = NULLIF(TRIM(REPLACE(@postal, '\r', '')), '');

-- ---------- Step 3: Fill the tables ----------
INSERT INTO customers
SELECT DISTINCT customer_id, customer_name, segment FROM stg_train;

INSERT INTO products (product_id, product_name, category, sub_category)
SELECT DISTINCT product_id, product_name, category, sub_category FROM stg_train;

INSERT INTO locations (country, region, state, city, postal_code)
SELECT DISTINCT country, region, state, city, postal_code FROM stg_train;

INSERT INTO orders
SELECT DISTINCT s.order_id,
       STR_TO_DATE(s.order_date, '%d/%m/%Y'),
       STR_TO_DATE(s.ship_date,  '%d/%m/%Y'),
       s.ship_mode, s.customer_id, l.location_id
FROM stg_train s
JOIN locations l ON l.city = s.city AND l.state = s.state
                AND l.postal_code <=> s.postal_code;   -- <=> also matches empty (NULL) postal codes

INSERT INTO order_items
SELECT s.row_id, s.order_id, p.product_key, s.sales
FROM stg_train s
JOIN products p ON p.product_id = s.product_id AND p.product_name = s.product_name;

-- ---------- Check: both numbers must be equal (9800 rows) ----------
SELECT (SELECT COUNT(*) FROM stg_train)   AS rows_in_csv,
       (SELECT COUNT(*) FROM order_items) AS rows_in_order_items;
