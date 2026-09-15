-- 12. Revenue per channel as columns
-- For the first half of 2026, show monthly net revenue split into three columns, one per channel.
-- Columns: `month`, `web_revenue`, `app_revenue`, `marketplace_revenue`
-- Order: `month`
-- Write your query below this line.

SELECT
    TO_CHAR(order_date, 'YYYY-MM') AS month,
    SUM(CASE WHEN channel = 'web' THEN i.quantity * i.unit_price - i.discount END) AS web_revenue,
    SUM(CASE WHEN channel = 'app' THEN i.quantity * i.unit_price - i.discount END) AS app_revenue,
    SUM(CASE WHEN channel = 'marketplace' THEN i.quantity * i.unit_price - i.discount END) AS marketplace_revenue
FROM orders AS o
INNER JOIN order_items AS i
ON o.order_id = i.order_id
WHERE order_date BETWEEN '2026-01-01' AND '2026-07-01'
    AND o.status NOT IN ('cancelled','returned')
GROUP BY TO_CHAR(order_date, 'YYYY-MM')
ORDER BY month;