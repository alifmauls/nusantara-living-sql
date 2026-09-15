-- 17. Each warehouse against the average warehouse
-- Show total net revenue per warehouse, the average revenue across the four warehouses, and the gap between the two.
-- Columns: `warehouse`, `revenue`, `avg_warehouse_revenue`, `diff`
-- Order: `revenue` descending

SELECT o.warehouse,
       SUM(i.quantity * i.unit_price - i.discount) AS revenue,
       (SELECT ROUND(AVG(w.revenue))
        FROM (SELECT o2.warehouse,
                     SUM(i2.quantity * i2.unit_price - i2.discount) AS revenue
              FROM orders AS o2
              INNER JOIN order_items AS i2
              ON i2.order_id = o2.order_id
              WHERE o2.status NOT IN ('cancelled', 'returned')
              GROUP BY o2.warehouse) AS w) AS avg_warehouse_revenue,
       SUM(i.quantity * i.unit_price - i.discount) -
       (SELECT ROUND(AVG(w.revenue))
        FROM (SELECT o2.warehouse,
                     SUM(i2.quantity * i2.unit_price - i2.discount) AS revenue
              FROM orders AS o2
              INNER JOIN order_items AS i2
              ON i2.order_id = o2.order_id
              WHERE o2.status NOT IN ('cancelled', 'returned')
              GROUP BY o2.warehouse) AS w) AS diff
FROM orders AS o
INNER JOIN order_items AS i
ON i.order_id = o.order_id
WHERE o.status NOT IN ('cancelled', 'returned')
GROUP BY o.warehouse
ORDER BY revenue DESC;
