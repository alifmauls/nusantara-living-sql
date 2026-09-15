-- 09. Label every order by size
-- Tag the June 2026 orders as Small (under 1,000,000), Medium (1,000,000 up to 5,000,000) or Large (5,000,000 and above), based on net order value.
-- Columns: `order_id`, `order_value`, `size_label`
-- Order: `order_value` descending, then `order_id`, limit 20

SELECT o.order_id,
       SUM(i.quantity * i.unit_price - i.discount) AS order_value,
       CASE WHEN SUM(i.quantity * i.unit_price - i.discount) >= 5000000 THEN 'Large'
            WHEN SUM(i.quantity * i.unit_price - i.discount) >= 1000000 THEN 'Medium'
            ELSE 'Small' END AS size_label
FROM orders AS o
INNER JOIN order_items AS i
ON i.order_id = o.order_id
WHERE o.order_date BETWEEN '2026-06-01' AND '2026-06-30'
  AND o.status NOT IN ('cancelled', 'returned')
GROUP BY o.order_id
ORDER BY order_value DESC, o.order_id
LIMIT 20;
