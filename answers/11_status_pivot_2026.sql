-- 11. Order status as columns, month by month
-- For 2026, turn the order status into columns: delivered, cancelled, returned and in progress (paid or shipped), one row per month.
-- Columns: `month`, `delivered`, `cancelled`, `returned`, `in_progress`
-- Order: `month`
-- Write your query below this line.

SELECT
    TO_CHAR(order_date, 'YYYY-MM') as month,
    COUNT(CASE WHEN status = 'delivered' THEN 1 END) AS delivered,
    COUNT(CASE WHEN status = 'cancelled' THEN 1 END) AS cancelled,
    COUNT(CASE WHEN status = 'returned' THEN 1 END) AS returned,
    COUNT(CASE WHEN status IN ('paid','shipped') THEN 1 END) AS in_progress
FROM orders
WHERE EXTRACT(YEAR FROM order_date) = '2026'
GROUP BY TO_CHAR(order_date, 'YYYY-MM')
ORDER BY month;