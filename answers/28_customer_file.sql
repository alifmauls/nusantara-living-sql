-- 28. The top customer file
-- Twenty biggest customers by net revenue: how many orders, first and last order date, revenue, margin percent, days since the last order counted from 30 June 2026, and their rank inside their own segment.
-- Columns: `customer_id`, `full_name`, `segment`, `orders`, `first_order`, `last_order`, `revenue`, `margin_pct` (1 decimal), `days_since_last_order`, `rank_in_segment`
-- Order: `revenue` descending, then `customer_id`, limit 20
-- Write your query below this line.

WITH rev_gross AS(
    SELECT
        order_id,
        SUM(i.quantity * i.unit_price - i.discount) AS revenue,
        SUM(i.quantity * i.unit_price - i.discount) - SUM(p.cost_price * i.quantity) AS gross_profit
    FROM order_items AS i
    INNER JOIN products AS p
    ON i.product_id = p.product_id
    GROUP BY i.order_id),

cte2 AS(
SELECT
    customer_id,
    COUNT(o.order_id) AS orders,
    MIN(order_date) AS first_order,
    MAX(order_date) AS last_order,
    SUM(revenue) AS revenue,
    ROUND(100.0 * SUM(gross_profit) / SUM(revenue) ,1) AS margin_pct,
    DATE '2026-06-30' - MAX(order_date) AS days_since_last_order
FROM orders AS o
INNER JOIN rev_gross AS r
ON o.order_id = r.order_id
WHERE o.status NOT IN ('cancelled','returned')
GROUP BY customer_id)

SELECT
    cte2.customer_id,
    full_name,
    segment,
    orders,
    first_order,
    last_order,
    revenue,
    margin_pct,
    days_since_last_order,
    RANK() OVER(PARTITION BY segment ORDER BY revenue DESC) AS rank_in_segment
FROM cte2
INNER JOIN customers AS c
ON cte2.customer_id = c.customer_id
ORDER BY revenue DESC, cte2.customer_id
LIMIT 20;