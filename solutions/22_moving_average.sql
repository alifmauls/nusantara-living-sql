-- 22. Three month moving average
-- Smooth the monthly revenue line with a three month moving average, so the promo spikes stop hiding the trend.
-- Columns: `month`, `revenue`, `moving_avg_3m` (rounded)
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
       ROUND(AVG(revenue) OVER (ORDER BY month
                                ROWS BETWEEN 2 PRECEDING AND CURRENT ROW)) AS moving_avg_3m
FROM monthly
ORDER BY month;
