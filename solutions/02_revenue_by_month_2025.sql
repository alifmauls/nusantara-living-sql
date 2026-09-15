-- 02. Revenue by month in 2025
-- Build the monthly sales line for 2025: how many orders and how much net revenue each month.
-- Columns: `month` (text like 2025-01), `orders`, `revenue`
-- Order: `month`

SELECT TO_CHAR(o.order_date, 'YYYY-MM') AS month,
       COUNT(DISTINCT o.order_id) AS orders,
       SUM(i.quantity * i.unit_price - i.discount) AS revenue
FROM orders AS o
INNER JOIN order_items AS i
ON i.order_id = o.order_id
WHERE o.status NOT IN ('cancelled', 'returned')
  AND o.order_date BETWEEN '2025-01-01' AND '2025-12-31'
GROUP BY month
ORDER BY month;
