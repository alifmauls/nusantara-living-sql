-- 10. Group the payment methods
-- Treasury thinks in three buckets: Instant (va, ewallet), Delayed (transfer, paylater) and On delivery (cod). Show orders and net revenue per bucket.
-- Columns: `payment_group`, `orders`, `revenue`
-- Order: `revenue` descending

SELECT CASE WHEN o.payment_method IN ('va', 'ewallet') THEN 'Instant'
            WHEN o.payment_method IN ('transfer', 'paylater') THEN 'Delayed'
            ELSE 'On delivery' END AS payment_group,
       COUNT(DISTINCT o.order_id) AS orders,
       SUM(i.quantity * i.unit_price - i.discount) AS revenue
FROM orders AS o
INNER JOIN order_items AS i
ON i.order_id = o.order_id
WHERE o.status NOT IN ('cancelled', 'returned')
GROUP BY payment_group
ORDER BY revenue DESC;
