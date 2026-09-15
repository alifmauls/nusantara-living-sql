-- 18. Products priced above their own category
-- Which products carry a list price above the average list price of their own category?
-- Columns: `product_id`, `product_name`, `category`, `list_price`, `category_avg` (rounded)
-- Order: `category`, then `list_price` descending, then `product_id`

SELECT p.product_id, p.product_name, p.category, p.list_price,
       (SELECT ROUND(AVG(p2.list_price))
        FROM products AS p2
        WHERE p2.category = p.category) AS category_avg
FROM products AS p
WHERE p.list_price >
      (SELECT AVG(p2.list_price)
       FROM products AS p2
       WHERE p2.category = p.category)
ORDER BY p.category, p.list_price DESC, p.product_id;
