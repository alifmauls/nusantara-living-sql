-- 25. First orders against repeat orders
-- For the first half of 2026, how many orders each month were a customer's very first order, and how many were repeat orders?
-- Columns: `month`, `first_orders`, `repeat_orders`
-- Order: `month`

WITH numbered AS (
    SELECT order_id, customer_id, order_date,
           ROW_NUMBER() OVER (PARTITION BY customer_id
                              ORDER BY order_date, order_id) AS order_seq
    FROM orders
    WHERE status NOT IN ('cancelled', 'returned')
)
SELECT TO_CHAR(order_date, 'YYYY-MM') AS month,
       COUNT(CASE WHEN order_seq = 1 THEN 1 END) AS first_orders,
       COUNT(CASE WHEN order_seq > 1 THEN 1 END) AS repeat_orders
FROM numbered
WHERE order_date >= '2026-01-01'
GROUP BY month
ORDER BY month;
