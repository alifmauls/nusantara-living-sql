-- Quick check that the data loaded. Expected:
--   customers 320, products 59, orders 2405, order_items 5959, payments 2405, monthly_targets 72
--   first order 2025-01-01, last order 2026-06-30
SELECT 'customers' AS table_name, COUNT(*) AS rows FROM customers
UNION ALL SELECT 'products', COUNT(*) FROM products
UNION ALL SELECT 'orders', COUNT(*) FROM orders
UNION ALL SELECT 'order_items', COUNT(*) FROM order_items
UNION ALL SELECT 'payments', COUNT(*) FROM payments
UNION ALL SELECT 'monthly_targets', COUNT(*) FROM monthly_targets
ORDER BY table_name;

SELECT MIN(order_date) AS first_order,
       MAX(order_date) AS last_order,
       SUM(i.quantity * i.unit_price - i.discount) AS net_revenue
FROM orders AS o
INNER JOIN order_items AS i
ON i.order_id = o.order_id
WHERE o.status NOT IN ('cancelled', 'returned');
