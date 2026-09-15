-- 21. Top three products in every category
-- Merchandising wants the three best selling products of each category by net revenue.
-- Columns: `category`, `rank_in_category`, `product_name`, `revenue`
-- Order: `category`, `rank_in_category`, `product_name`
-- Write your query below this line.

WITH rev AS 
    (SELECT
        p.product_name,
        p.category,
        SUM(i.quantity * i.unit_price - i.discount) AS revenue,
        RANK() OVER(PARTITION BY category ORDER BY SUM(i.quantity * i.unit_price - i.discount) DESC) AS rank_in_category
    FROM order_items AS i
    INNER JOIN products AS p
    ON i.product_id = p.product_id
    INNER JOIN orders AS o
    ON i.order_id = o.order_id
    WHERE o.status NOT IN ('cancelled','returned')
    GROUP BY p.product_name,p.category)

SELECT
    category,
    rank_in_category,
    product_name,
    revenue
FROM rev
WHERE rank_in_category IN (1,2,3)
ORDER BY category, rank_in_category,product_name;