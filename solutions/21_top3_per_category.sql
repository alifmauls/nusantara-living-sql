-- 21. Top three products in every category
-- Merchandising wants the three best selling products of each category by net revenue.
-- Columns: `category`, `rank_in_category`, `product_name`, `revenue`
-- Order: `category`, `rank_in_category`, `product_name`

WITH product_revenue AS (
    SELECT p.category, p.product_id, p.product_name,
           SUM(i.quantity * i.unit_price - i.discount) AS revenue
    FROM order_items AS i
    INNER JOIN orders AS o
    ON o.order_id = i.order_id
    INNER JOIN products AS p
    ON p.product_id = i.product_id
    WHERE o.status NOT IN ('cancelled', 'returned')
    GROUP BY p.category, p.product_id, p.product_name
),
ranked AS (
    SELECT category, product_name, revenue,
           RANK() OVER (PARTITION BY category ORDER BY revenue DESC) AS rank_in_category
    FROM product_revenue
)
SELECT category, rank_in_category, product_name, revenue
FROM ranked
WHERE rank_in_category <= 3
ORDER BY category, rank_in_category, product_name;
