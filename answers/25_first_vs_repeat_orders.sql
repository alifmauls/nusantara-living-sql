-- 25. First orders against repeat orders
-- For the first half of 2026, how many orders each month were a customer's very first order, and how many were repeat orders?
-- Columns: `month`, `first_orders`, `repeat_orders`
-- Order: `month`
-- Write your query below this line.

WITH first_repeat_orders AS(    
    SELECT
        TO_CHAR(order_date, 'YYYY-MM') AS month,
        order_date,
        order_id,
        customer_id
    FROM orders
    WHERE status NOT IN ('cancelled','returned')),
repeat_orders AS (
SELECT
    month, order_id, customer_id, order_date,
    ROW_NUMBER() OVER(PARTITION BY customer_id ORDER BY order_date, order_id) AS customer_repeat
FROM first_repeat_orders)

SELECT
    month,
    COUNT(CASE WHEN customer_repeat = 1 THEN 1 END) AS first_orders,
    COUNT(CASE WHEN customer_repeat > 1 THEN 1 END) AS repeat_orders
FROM repeat_orders
WHERE EXTRACT(YEAR FROM order_date) = '2026'
    AND EXTRACT(MONTH FROM order_date) <= 6
GROUP BY month
ORDER BY month
;