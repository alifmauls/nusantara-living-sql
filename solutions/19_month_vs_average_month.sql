-- 19. Each 2025 month against the average month
-- For 2025, show monthly net revenue next to the average monthly revenue of that year, and the difference.
-- Columns: `month`, `revenue`, `avg_month_revenue` (rounded), `diff`
-- Order: `month`

SELECT TO_CHAR(o.order_date, 'YYYY-MM') AS month,
       SUM(i.quantity * i.unit_price - i.discount) AS revenue,
       (SELECT ROUND(AVG(m.revenue))
        FROM (SELECT TO_CHAR(o2.order_date, 'YYYY-MM') AS month,
                     SUM(i2.quantity * i2.unit_price - i2.discount) AS revenue
              FROM orders AS o2
              INNER JOIN order_items AS i2
              ON i2.order_id = o2.order_id
              WHERE o2.status NOT IN ('cancelled', 'returned')
                AND o2.order_date < '2026-01-01'
              GROUP BY month) AS m) AS avg_month_revenue,
       SUM(i.quantity * i.unit_price - i.discount) -
       (SELECT ROUND(AVG(m.revenue))
        FROM (SELECT TO_CHAR(o2.order_date, 'YYYY-MM') AS month,
                     SUM(i2.quantity * i2.unit_price - i2.discount) AS revenue
              FROM orders AS o2
              INNER JOIN order_items AS i2
              ON i2.order_id = o2.order_id
              WHERE o2.status NOT IN ('cancelled', 'returned')
                AND o2.order_date < '2026-01-01'
              GROUP BY month) AS m) AS diff
FROM orders AS o
INNER JOIN order_items AS i
ON i.order_id = o.order_id
WHERE o.status NOT IN ('cancelled', 'returned')
  AND o.order_date < '2026-01-01'
GROUP BY month
ORDER BY month;
