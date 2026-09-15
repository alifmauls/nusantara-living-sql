-- 16. Best month of each warehouse
-- For every warehouse, which month brought the most net revenue, and how much?
-- Columns: `warehouse`, `month`, `revenue`
-- Order: `warehouse`

SELECT s.warehouse, s.month, s.revenue
FROM (SELECT o.warehouse,
             TO_CHAR(o.order_date, 'YYYY-MM') AS month,
             SUM(i.quantity * i.unit_price - i.discount) AS revenue
      FROM orders AS o
      INNER JOIN order_items AS i
      ON i.order_id = o.order_id
      WHERE o.status NOT IN ('cancelled', 'returned')
      GROUP BY o.warehouse, month) AS s
WHERE s.revenue =
      (SELECT MAX(s2.revenue)
       FROM (SELECT o2.warehouse,
                    TO_CHAR(o2.order_date, 'YYYY-MM') AS month,
                    SUM(i2.quantity * i2.unit_price - i2.discount) AS revenue
             FROM orders AS o2
             INNER JOIN order_items AS i2
             ON i2.order_id = o2.order_id
             WHERE o2.status NOT IN ('cancelled', 'returned')
             GROUP BY o2.warehouse, month) AS s2
       WHERE s2.warehouse = s.warehouse)
ORDER BY s.warehouse;
