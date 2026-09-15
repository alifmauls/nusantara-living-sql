-- 02. Revenue by month in 2025
-- Build the monthly sales line for 2025: how many orders and how much net revenue each month.
-- Columns: `month` (text like 2025-01), `orders`, `revenue`
-- Order: `month`
-- Write your query below this line.

SELECT
    TO_CHAR(order_date, 'YYYY-MM') AS month,
    COUNT(DISTINCT o1.order_id) AS orders,
    SUM(o2.quantity * o2.unit_price - o2.discount) AS revenue
FROM orders AS o1
INNER JOIN order_items AS o2
ON o1.order_id = o2.order_id
WHERE EXTRACT(YEAR FROM o1.order_date) = '2025'
    AND o1.status NOT IN ('cancelled','returned')
GROUP BY month
ORDER BY month;