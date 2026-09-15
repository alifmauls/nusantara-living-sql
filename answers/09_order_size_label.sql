-- 09. Label every order by size
-- Tag the June 2026 orders as Small (under 1,000,000), Medium (1,000,000 up to 5,000,000) or Large (5,000,000 and above), based on net order value.
-- Columns: `order_id`, `order_value`, `size_label`
-- Order: `order_value` descending, then `order_id`, limit 20
-- Write your query below this line.

SELECT
    o.order_id,
    SUM(i.quantity*i.unit_price-i.discount) AS order_value,
    (CASE 
        WHEN SUM(i.quantity*i.unit_price-i.discount) < 1000000 THEN 'Small'
        WHEN SUM(i.quantity*i.unit_price-i.discount) BETWEEN 1000000 AND 5000000 THEN 'Medium'
        WHEN SUM(i.quantity*i.unit_price-i.discount) > 5000000 THEN 'Large'
        END) AS size_label
FROM orders AS o
INNER JOIN order_items AS i
ON o.order_id = i.order_id
WHERE o.status NOT IN ('cancelled','returned')
        AND o.order_date BETWEEN '2026-06-01' AND '2026-06-30'
GROUP BY o.order_id
ORDER BY order_value DESC, order_id
LIMIT 20;