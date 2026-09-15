-- 07. Products that never sold
-- Inventory wants the products that have never appeared in any order, active or not.
-- Columns: `product_id`, `product_name`, `category`, `list_price`
-- Order: `product_id`

SELECT p.product_id, p.product_name, p.category, p.list_price
FROM products AS p
WHERE p.product_id NOT IN (SELECT i.product_id FROM order_items AS i)
ORDER BY p.product_id;
