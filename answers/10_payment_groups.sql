-- 10. Group the payment methods
-- Treasury thinks in three buckets: Instant (va,wallet), Delayed (transfer, paylater) and On delivery (cod). Show orders and net revenue per bucket.
-- Columns: `payment_group`, `orders`, `revenue`
-- Order: `revenue` descending
-- Write your query below this line.

SELECT (CASE WHEN method = 'va' OR method = 'ewallet' THEN 'Instant'
        WHEN method = 'transfer' OR method = 'paylater' THEN 'Delayed'
        ELSE 'On delivery' END) AS payment_group,
        COUNT(DISTINCT o.order_id) AS orders,
        SUM(i.unit_price * i.quantity - i.discount) AS revenue
FROM payments AS pay
INNER JOIN orders AS o
ON pay.order_id = o.order_id
INNER JOIN order_items AS i
ON o.order_id = i.order_id
WHERE o.status NOT IN ('cancelled','returned')
GROUP BY payment_group
ORDER BY revenue DESC;