-- 23. How much of its segment each customer carries
-- For the fifteen biggest customers, show their net revenue and what share of their own segment's revenue that is.
-- Columns: `customer_id`, `full_name`, `segment`, `revenue`, `pct_of_segment` (2 decimals)
-- Order: `revenue` descending, then `customer_id`, limit 15
-- Write your query below this line.

WITH rev AS(    
    SELECT
        c.customer_id, c.full_name, c.segment,
        SUM(i.quantity * i.unit_price - i.discount) AS revenue
    FROM orders AS o
    INNER JOIN order_items AS i
    ON o.order_id = i.order_id
    INNER JOIN customers AS c
    ON o.customer_id = c.customer_id
    WHERE status NOT IN ('cancelled','returned')
    GROUP BY c.customer_id),
segment_rev AS (
    SELECT customer_id,full_name,segment, revenue,
        SUM(revenue) OVER(PARTITION BY segment) AS segment_revenue
    FROM rev)

SELECT 
    customer_id,full_name,segment,revenue,
    ROUND(100*revenue/segment_revenue,2) AS pct_of_segment
FROM segment_rev
ORDER BY revenue DESC, customer_id
LIMIT 15;