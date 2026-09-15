-- 26. Warehouse against target
-- For the first half of 2026, compare each warehouse's monthly net revenue with its target: the achievement in percent and whether it was a Hit or a Miss.
-- Columns: `warehouse`, `month`, `revenue`, `revenue_target`, `achievement_pct` (1 decimal), `target_status`
-- Order: `warehouse`, then `month`
-- Write your query below this line.

WITH monthly_rev AS (SELECT
    o.warehouse,
    TO_CHAR(o.order_date,'YYYY-MM') AS month,
    SUM(i.quantity * i.unit_price - i.discount) AS revenue
FROM orders AS o
INNER JOIN order_items AS i
ON o.order_id = i.order_id
WHERE o.status NOT IN ('cancelled','returned')
    AND EXTRACT(YEAR FROM order_date) = '2026'
    AND o.order_date >= '2026-01-01' AND o.order_date < '2026-07-01'
GROUP BY TO_CHAR(o.order_date,'YYYY-MM'), o.warehouse)

SELECT
    r.warehouse,
    month,
    revenue,
    revenue_target,
    ROUND(100.0 * revenue / revenue_target,1) AS achievement_pct,
    CASE WHEN revenue >= revenue_target THEN 'Hit' ELSE 'Miss' END as target_status
FROM monthly_rev AS r
INNER JOIN monthly_targets AS t
ON r.warehouse = t.warehouse
WHERE month = TO_CHAR(t.target_month,'YYYY-MM')
ORDER BY warehouse, month;