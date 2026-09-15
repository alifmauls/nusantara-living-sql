-- 28. The top customer file
-- Twenty biggest customers by net revenue: how many orders, first and last order date, revenue, margin percent, days since the last order counted from 30 June 2026, and their rank inside their own segment.
-- Columns: `customer_id`, `full_name`, `segment`, `orders`, `first_order`, `last_order`, `revenue`, `margin_pct` (1 decimal), `days_since_last_order`, `rank_in_segment`
-- Order: `revenue` descending, then `customer_id`, limit 20

WITH per_order AS (
    SELECT c.customer_id, c.full_name, c.segment,
           o.order_id, o.order_date,
           SUM(i.quantity * i.unit_price - i.discount) AS revenue,
           SUM(i.quantity * p.cost_price) AS cost
    FROM customers AS c
    INNER JOIN orders AS o
    ON o.customer_id = c.customer_id
    INNER JOIN order_items AS i
    ON i.order_id = o.order_id
    INNER JOIN products AS p
    ON p.product_id = i.product_id
    WHERE o.status NOT IN ('cancelled', 'returned')
    GROUP BY c.customer_id, c.full_name, c.segment, o.order_id, o.order_date
),
per_customer AS (
    SELECT customer_id, full_name, segment,
           COUNT(*) AS orders,
           MIN(order_date) AS first_order,
           MAX(order_date) AS last_order,
           SUM(revenue) AS revenue,
           SUM(revenue - cost) AS gross_margin
    FROM per_order
    GROUP BY customer_id, full_name, segment
)
SELECT customer_id, full_name, segment, orders, first_order, last_order, revenue,
       ROUND(100.0 * gross_margin / revenue, 1) AS margin_pct,
       DATE '2026-06-30' - last_order AS days_since_last_order,
       RANK() OVER (PARTITION BY segment ORDER BY revenue DESC) AS rank_in_segment
FROM per_customer
ORDER BY revenue DESC, customer_id
LIMIT 20;
