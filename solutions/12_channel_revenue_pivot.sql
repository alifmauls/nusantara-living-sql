-- 12. Revenue per channel as columns
-- For the first half of 2026, show monthly net revenue split into three columns, one per channel.
-- Columns: `month`, `web_revenue`, `app_revenue`, `marketplace_revenue`
-- Order: `month`

SELECT TO_CHAR(o.order_date, 'YYYY-MM') AS month,
       SUM(CASE WHEN o.channel = 'web'
                THEN i.quantity * i.unit_price - i.discount ELSE 0 END) AS web_revenue,
       SUM(CASE WHEN o.channel = 'app'
                THEN i.quantity * i.unit_price - i.discount ELSE 0 END) AS app_revenue,
       SUM(CASE WHEN o.channel = 'marketplace'
                THEN i.quantity * i.unit_price - i.discount ELSE 0 END) AS marketplace_revenue
FROM orders AS o
INNER JOIN order_items AS i
ON i.order_id = o.order_id
WHERE o.status NOT IN ('cancelled', 'returned')
  AND o.order_date >= '2026-01-01'
GROUP BY month
ORDER BY month;
