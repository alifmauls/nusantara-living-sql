-- 05. June 2026 orders with the customer behind them
-- List the fifteen biggest June 2026 orders with the customer name, city and channel.
-- Columns: `order_id`, `order_date`, `full_name`, `city`, `channel`, `order_value`
-- Order: `order_value` descending, then `order_id`, limit 15
-- Write your query below this line.

SELECT
    o.order_id,
    o.order_date,
    c.full_name,
    c.city,
    o.channel,
    SUM(i.quantity * i.unit_price - i.discount) AS order_value
FROM orders AS o
INNER JOIN order_items AS i
ON o.order_id = i.order_id
INNER JOIN customers AS c
ON o.customer_id = c.customer_id
WHERE o.status NOT IN ('cancelled','returned')
    AND o.order_date BETWEEN '2026-06-01' AND '2026-06-30'
GROUP BY
    o.order_id,
    o.order_date,
    c.full_name,
    c.city,
    o.channel
ORDER BY order_value DESC, o.order_id
LIMIT 15;