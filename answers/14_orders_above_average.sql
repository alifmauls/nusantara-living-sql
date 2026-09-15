-- 14. Orders above the average order value
-- In the first half of 2026, which orders are worth more than the average order in that period?
-- Columns: `order_id`, `order_date`, `warehouse`, `order_value`
-- Order: `order_value` descending, then `order_id`, limit 15
-- Write your query below this line.

WITH order_values AS(
    SELECT
        o.order_id, o.order_date, o.warehouse,
        SUM(i.unit_price * i.quantity - i.discount) AS order_value
    FROM orders AS o
    INNER JOIN order_items AS i
    ON o.order_id = i.order_id
    WHERE EXTRACT(YEAR FROM o.order_date) = '2026'
        AND order_date < '2026-07-01'
        AND o.status NOT IN ('cancelled','returned')
    GROUP BY o.order_id,order_date,warehouse
)

SELECT
    order_id, order_date, warehouse,order_value
FROM order_values
WHERE order_value > (SELECT AVG(order_value) FROM order_values)
ORDER BY order_value DESC, order_id
LIMIT 15;