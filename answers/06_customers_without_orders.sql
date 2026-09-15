-- 06. Customers who never ordered
-- Which registered customers have never placed a single order? The team wants to re-target them.
-- Columns: `customer_id`, `full_name`, `city`, `signup_date`
-- Order: `customer_id`
-- Write your query below this line.

WITH nbc AS (SELECT customer_id
FROM customers
EXCEPT
SELECT customer_id
FROM orders
ORDER BY customer_id)

SELECT customers.customer_id, full_name, city, signup_date
FROM customers
INNER JOIN nbc
ON customers.customer_id = nbc.customer_id;