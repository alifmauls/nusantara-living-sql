-- 15. Customers who bought lighting
-- Which customers have ever bought a product from the Lighting category?
-- Columns: `customer_id`, `full_name`, `city`
-- Order: `customer_id`, limit 20
-- Write your query below this line.

WITH ordern AS (SELECT
            o.order_id, customer_id, product_id,status
        FROM orders AS o
        INNER JOIN order_items AS i
        ON o.order_id = i.order_id
)

SELECT
    c.customer_id, c.full_name, c.city
FROM ordern AS o
INNER JOIN customers AS c
ON o.customer_id = c.customer_id
WHERE product_id IN (
    SELECT product_id
    FROM products
    WHERE category = 'Lighting')
    AND status NOT IN ('cancelled','returned')
GROUP BY c.customer_id
ORDER BY customer_id
LIMIT 20;