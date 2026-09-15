-- 15. Customers who bought lighting
-- Which customers have ever bought a product from the Lighting category?
-- Columns: `customer_id`, `full_name`, `city`
-- Order: `customer_id`, limit 20

SELECT c.customer_id, c.full_name, c.city
FROM customers AS c
WHERE c.customer_id IN
      (SELECT o.customer_id
       FROM orders AS o
       INNER JOIN order_items AS i
       ON i.order_id = o.order_id
       INNER JOIN products AS p
       ON p.product_id = i.product_id
       WHERE p.category = 'Lighting'
         AND o.status NOT IN ('cancelled', 'returned'))
ORDER BY c.customer_id
LIMIT 20;
