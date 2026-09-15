-- 24. Month over month growth
-- Add the previous month's revenue next to each month and the growth in percent.
-- Columns: `month`, `revenue`, `prev_month_revenue`, `growth_pct` (2 decimals)
-- Order: `month`

WITH monthly AS (
    SELECT TO_CHAR(o.order_date, 'YYYY-MM') AS month,
           SUM(i.quantity * i.unit_price - i.discount) AS revenue
    FROM orders AS o
    INNER JOIN order_items AS i
    ON i.order_id = o.order_id
    WHERE o.status NOT IN ('cancelled', 'returned')
    GROUP BY month
)
SELECT month, revenue,
       LAG(revenue) OVER (ORDER BY month) AS prev_month_revenue,
       ROUND(100.0 * (revenue - LAG(revenue) OVER (ORDER BY month))
             / LAG(revenue) OVER (ORDER BY month), 2) AS growth_pct
FROM monthly
ORDER BY month;
