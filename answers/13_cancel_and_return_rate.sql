-- 13. Cancellation and return rate per warehouse
-- Operations wants the cancellation rate per warehouse, and the return rate measured only against the orders that were not cancelled, since a cancelled order can never be returned.
-- Columns: `warehouse`, `orders`, `pct_cancelled`, `pct_returned_of_shipped` (both rounded to 2 decimals)
-- Order: `pct_cancelled` descending, then `warehouse`
-- Write your query below this line.

SELECT
    warehouse,
    COUNT(order_id) AS orders,
    ROUND(COUNT(CASE WHEN status = 'cancelled' THEN 1 END) * 100.00 / COUNT(order_id),2) AS pct_cancelled,
    ROUND(COUNT(CASE WHEN status = 'returned' THEN 1 END) * 100.00 / COUNT(CASE WHEN status != 'cancelled' THEN 1 END),2) AS pct_returned_of_shipped
FROM orders
GROUP BY warehouse
ORDER BY pct_cancelled DESC, warehouse;