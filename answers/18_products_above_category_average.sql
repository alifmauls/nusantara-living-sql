-- 18. Products priced above their own category
-- Which products carry a list price above the average list price of their own category?
-- Columns: `product_id`, `product_name`, `category`, `list_price`, `category_avg` (rounded)
-- Order: `category`, then `list_price` descending, then `product_id`
-- Write your query below this line.

WITH average AS (SELECT
                    product_id, product_name, category, list_price,
                    ROUND(AVG(list_price) OVER(PARTITION BY category)) AS category_avg
                FROM products)

SELECT
    product_id, product_name, category, list_price, category_avg
FROM average
WHERE list_price > category_avg
ORDER BY category, list_price DESC, product_id;