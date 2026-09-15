-- 16. Best month of each warehouse
-- For every warehouse, which month brought the most net revenue, and how much?
-- Columns: `warehouse`, `month`, `revenue`
-- Order: `warehouse`
-- Write your query below this line.

WITH monthly_rev AS (
    SELECT warehouse,  TO_CHAR(order_date, 'YYYY-MM') AS month, SUM(i.unit_price * i.quantity - i.discount) AS revenue
    FROM orders AS o
    INNER JOIN order_items AS i
    ON o.order_id = i.order_id
    WHERE status NOT IN ('cancelled','returned')
    GROUP BY o.warehouse, TO_CHAR(order_date, 'YYYY-MM')),
ranked AS (
    SELECT warehouse, month, revenue, RANK() OVER(
        PARTITION BY warehouse
        ORDER BY revenue DESC
    ) AS ranking
    FROM monthly_rev
)

SELECT
    warehouse, month, revenue
FROM ranked
WHERE ranking = 1
ORDER BY warehouse;