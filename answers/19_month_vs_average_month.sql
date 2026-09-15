-- 19. Each 2025 month against the average month
-- For 2025, show monthly net revenue next to the average monthly revenue of that year, and the difference.
-- Columns: `month`, `revenue`, `avg_month_revenue` (rounded), `diff`
-- Order: `month`
-- Write your query below this line.

WITH revenue AS (SELECT
            TO_CHAR(o.order_date, 'YYYY-MM') AS month,
            SUM(i.quantity * i.unit_price - i.discount) AS revenue
        FROM orders AS o
        INNER JOIN order_items AS i
        ON o.order_id = i.order_id
        WHERE EXTRACT(YEAR FROM o.order_date) = '2025'
            AND o.status NOT IN ('cancelled','returned')
        GROUP BY TO_CHAR(o.order_date, 'YYYY-MM'))

SELECT
    month,
    revenue,
    ROUND(AVG(revenue) OVER()) AS avg_month_revenue,
    revenue - ROUND(AVG(revenue) OVER()) AS diff
FROM revenue
ORDER BY month;