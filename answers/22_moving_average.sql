-- 22. Three month moving average
-- Smooth the monthly revenue line with a three month moving average, so the promo spikes stop hiding the trend.
-- Columns: `month`, `revenue`, `moving_avg_3m` (rounded)
-- Order: `month`
-- Write your query below this line.

WITH rev AS (SELECT
        TO_CHAR(order_date, 'YYYY-MM') AS month,
        SUM(i.quantity * i.unit_price - i.discount) AS revenue
    FROM orders AS o
    INNER JOIN order_items AS i
    ON o.order_id = i.order_id
    WHERE o.status NOT IN ('cancelled','returned')
    GROUP BY month)

SELECT
    month, revenue,
    ROUND(AVG(revenue) OVER(ORDER BY month ROWS BETWEEN 2 PRECEDING AND CURRENT ROW)) AS moving_avg_3m
FROM rev
ORDER BY month;