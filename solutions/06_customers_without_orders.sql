-- 06. Customers who never ordered
-- Which registered customers have never placed a single order? The team wants to re-target them.
-- Columns: `customer_id`, `full_name`, `city`, `signup_date`
-- Order: `customer_id`

SELECT c.customer_id, c.full_name, c.city, c.signup_date
FROM customers AS c
LEFT JOIN orders AS o
ON o.customer_id = c.customer_id
WHERE o.order_id IS NULL
ORDER BY c.customer_id;
