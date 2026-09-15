-- 04. Ten best selling products
-- Which ten products brought in the most net revenue over the whole period?
-- Columns: `product_id`, `product_name`, `category`, `units_sold`, `revenue`
-- Order: `revenue` descending, then `product_id`, limit 10
-- Write your query below this line.

SELECT p.product_id, p.product_name, p.category,
        SUM(quantity) AS units_sold,
        SUM(i.unit_price * i.quantity - i.discount) AS revenue
FROM order_items AS i
INNER JOIN products AS p
ON i.product_id = p.product_id
INNER JOIN orders AS O
ON i.order_id = o.order_id
WHERE o.status NOT IN ('cancelled','returned')
GROUP BY p.product_id
ORDER BY revenue DESC
LIMIT 10;