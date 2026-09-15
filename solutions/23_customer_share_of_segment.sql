-- 23. How much of its segment each customer carries
-- For the fifteen biggest customers, show their net revenue and what share of their own segment's revenue that is.
-- Columns: `customer_id`, `full_name`, `segment`, `revenue`, `pct_of_segment` (2 decimals)
-- Order: `revenue` descending, then `customer_id`, limit 15

WITH customer_revenue AS (
    SELECT c.customer_id, c.full_name, c.segment,
           SUM(i.quantity * i.unit_price - i.discount) AS revenue
    FROM customers AS c
    INNER JOIN orders AS o
    ON o.customer_id = c.customer_id
    INNER JOIN order_items AS i
    ON i.order_id = o.order_id
    WHERE o.status NOT IN ('cancelled', 'returned')
    GROUP BY c.customer_id, c.full_name, c.segment
)
SELECT customer_id, full_name, segment, revenue,
       ROUND(100.0 * revenue / SUM(revenue) OVER (PARTITION BY segment), 2) AS pct_of_segment
FROM customer_revenue
ORDER BY revenue DESC, customer_id
LIMIT 15;
