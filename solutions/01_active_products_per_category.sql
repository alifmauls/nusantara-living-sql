-- 01. Catalogue size per category
-- Finance wants to know how wide the active catalogue is. For products that are still active, show one row per category with the number of products and the average list price.
-- Columns: `category`, `products`, `avg_list_price` (rounded to whole rupiah)
-- Order: `products` descending, then `category`

SELECT category,
       COUNT(*) AS products,
       ROUND(AVG(list_price)) AS avg_list_price
FROM products
WHERE is_active
GROUP BY category
ORDER BY products DESC, category;
