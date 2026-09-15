-- 14. Orders above the average order value
-- In the first half of 2026, which orders are worth more than the average order in that period?
-- Columns: `order_id`, `order_date`, `warehouse`, `order_value`
-- Order: `order_value` descending, then `order_id`, limit 15

SELECT o.order_id, o.order_date, o.warehouse,
       SUM(i.quantity * i.unit_price - i.discount) AS order_value
FROM orders AS o
INNER JOIN order_items AS i
ON i.order_id = o.order_id
WHERE o.status NOT IN ('cancelled', 'returned')
  AND o.order_date >= '2026-01-01'
GROUP BY o.order_id, o.order_date, o.warehouse
HAVING SUM(i.quantity * i.unit_price - i.discount) >
       (SELECT AVG(per_order.order_value)
        FROM (SELECT SUM(i2.quantity * i2.unit_price - i2.discount) AS order_value
              FROM orders AS o2
              INNER JOIN order_items AS i2
              ON i2.order_id = o2.order_id
              WHERE o2.status NOT IN ('cancelled', 'returned')
                AND o2.order_date >= '2026-01-01'
              GROUP BY o2.order_id) AS per_order)
ORDER BY order_value DESC, o.order_id
LIMIT 15;
