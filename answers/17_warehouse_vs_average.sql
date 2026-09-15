-- 17. Each warehouse against the average warehouse
-- Show total net revenue per warehouse, the average revenue across the four warehouses, and the gap between the two.
-- Columns: `warehouse`, `revenue`, `avg_warehouse_revenue`, `diff`
-- Order: `revenue` descending
-- Write your query below this line.

SELECT
    warehouse, revenue,
    ROUND(AVG(revenue) OVER()) AS avg_warehouse_revenue,
    ROUND(revenue - AVG(revenue) OVER()) AS diff
FROM(    
    SELECT
        warehouse,
        SUM(i.unit_price * i.quantity - i.discount) AS revenue
    FROM orders AS o
    INNER JOIN order_items AS i
    ON o.order_id = i.order_id
    WHERE status NOT IN ('cancelled','returned')
    GROUP BY warehouse) AS warehouse_revenue
ORDER BY revenue DESC;