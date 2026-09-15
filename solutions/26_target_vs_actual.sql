-- 26. Warehouse against target
-- For the first half of 2026, compare each warehouse's monthly net revenue with its target: the achievement in percent and whether it was a Hit or a Miss.
-- Columns: `warehouse`, `month`, `revenue`, `revenue_target`, `achievement_pct` (1 decimal), `target_status`
-- Order: `warehouse`, then `month`

WITH monthly AS (
    SELECT o.warehouse,
           DATE_TRUNC('month', o.order_date)::date AS month_start,
           SUM(i.quantity * i.unit_price - i.discount) AS revenue
    FROM orders AS o
    INNER JOIN order_items AS i
    ON i.order_id = o.order_id
    WHERE o.status NOT IN ('cancelled', 'returned')
    GROUP BY o.warehouse, month_start
)
SELECT m.warehouse,
       TO_CHAR(m.month_start, 'YYYY-MM') AS month,
       m.revenue,
       t.revenue_target,
       ROUND(100.0 * m.revenue / t.revenue_target, 1) AS achievement_pct,
       CASE WHEN m.revenue >= t.revenue_target THEN 'Hit' ELSE 'Miss' END AS target_status
FROM monthly AS m
INNER JOIN monthly_targets AS t
ON t.warehouse = m.warehouse
   AND t.target_month = m.month_start
WHERE m.month_start >= '2026-01-01'
ORDER BY m.warehouse, month;
