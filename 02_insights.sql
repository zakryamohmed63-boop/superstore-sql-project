-- =====================================================
-- Superstore Project - Simple Business Questions
-- =====================================================
USE superstore_db;

-- Q1. What is the total sales?
SELECT ROUND(SUM(sales), 2) AS total_sales
FROM order_items;

-- Q2. How many orders, customers and products do we have?
SELECT (SELECT COUNT(*) FROM orders)    AS total_orders,
       (SELECT COUNT(*) FROM customers) AS total_customers,
       (SELECT COUNT(*) FROM products)  AS total_products;

-- Q3. What are the total sales for each year?
SELECT YEAR(o.order_date) AS year, ROUND(SUM(oi.sales), 2) AS total_sales
FROM orders o
JOIN order_items oi ON oi.order_id = o.order_id
GROUP BY YEAR(o.order_date)
ORDER BY year;

-- Q4. What are the total sales for each category?
SELECT p.category, ROUND(SUM(oi.sales), 2) AS total_sales
FROM order_items oi
JOIN products p ON p.product_key = oi.product_key
GROUP BY p.category
ORDER BY total_sales DESC;

-- Q5. What are the top 5 sub-categories by sales?
SELECT p.sub_category, ROUND(SUM(oi.sales), 2) AS total_sales
FROM order_items oi
JOIN products p ON p.product_key = oi.product_key
GROUP BY p.sub_category
ORDER BY total_sales DESC
LIMIT 5;

-- Q6. What are the top 10 products by sales?
SELECT p.product_name, ROUND(SUM(oi.sales), 2) AS total_sales
FROM order_items oi
JOIN products p ON p.product_key = oi.product_key
GROUP BY p.product_key, p.product_name
ORDER BY total_sales DESC
LIMIT 10;

-- Q7. What are the total sales for each region?
SELECT l.region, ROUND(SUM(oi.sales), 2) AS total_sales
FROM order_items oi
JOIN orders o    ON o.order_id = oi.order_id
JOIN locations l ON l.location_id = o.location_id
GROUP BY l.region
ORDER BY total_sales DESC;

-- Q8. What are the top 5 states by sales?
SELECT l.state, ROUND(SUM(oi.sales), 2) AS total_sales
FROM order_items oi
JOIN orders o    ON o.order_id = oi.order_id
JOIN locations l ON l.location_id = o.location_id
GROUP BY l.state
ORDER BY total_sales DESC
LIMIT 5;

-- Q9. Who are the top 10 customers by sales?
SELECT c.customer_name, ROUND(SUM(oi.sales), 2) AS total_spent
FROM order_items oi
JOIN orders o    ON o.order_id = oi.order_id
JOIN customers c ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.customer_name
ORDER BY total_spent DESC
LIMIT 10;

-- Q10. How many customers and how much sales for each segment?
SELECT c.segment, COUNT(DISTINCT c.customer_id) AS customers, ROUND(SUM(oi.sales), 2) AS total_sales
FROM order_items oi
JOIN orders o    ON o.order_id = oi.order_id
JOIN customers c ON c.customer_id = o.customer_id
GROUP BY c.segment
ORDER BY total_sales DESC;

-- Q11. How many orders use each shipping mode?
SELECT ship_mode, COUNT(*) AS total_orders
FROM orders
GROUP BY ship_mode
ORDER BY total_orders DESC;

-- Q12. What is the average shipping time (in days) for each shipping mode?
SELECT ship_mode, ROUND(AVG(DATEDIFF(ship_date, order_date)), 1) AS avg_days_to_ship
FROM orders
GROUP BY ship_mode
ORDER BY avg_days_to_ship;

-- Q13. Which months have the highest sales?
SELECT MONTHNAME(o.order_date) AS month_name, ROUND(SUM(oi.sales), 2) AS total_sales
FROM orders o
JOIN order_items oi ON oi.order_id = o.order_id
GROUP BY MONTH(o.order_date), MONTHNAME(o.order_date)
ORDER BY total_sales DESC
LIMIT 3;

-- Q14. What is the average order value?
SELECT ROUND(SUM(sales) / COUNT(DISTINCT order_id), 2) AS avg_order_value
FROM order_items;
