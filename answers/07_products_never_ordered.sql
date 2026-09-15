-- 07. Products that never sold
-- Inventory wants the products that have never appeared in any order, active or not.
-- Columns: `product_id`, `product_name`, `category`, `list_price`
-- Order: `product_id`
-- Write your query below this line.

WITH nbp AS (
    SELECT product_id
    FROM products
    EXCEPT
    SELECT product_id
    FROM order_items
    )

SELECT products.product_id, products.product_name, products.category, products.list_price
FROM products
INNER JOIN nbp
ON products.product_id = nbp.product_id
ORDER BY product_id;