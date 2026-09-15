-- 04. Ten best selling products
-- Which ten products brought in the most net revenue over the whole period?
-- Columns: `product_id`, `product_name`, `category`, `units_sold`, `revenue`
-- Order: `revenue` descending, then `product_id`, limit 10

SELECT p.product_id, p.product_name, p.category,
       SUM(i.quantity) AS units_sold,
       SUM(i.quantity * i.unit_price - i.discount) AS revenue
FROM order_items AS i
INNER JOIN orders AS o
ON o.order_id = i.order_id
INNER JOIN products AS p
ON p.product_id = i.product_id
WHERE o.status NOT IN ('cancelled', 'returned')
GROUP BY p.product_id, p.product_name, p.category
ORDER BY revenue DESC, p.product_id
LIMIT 10;
