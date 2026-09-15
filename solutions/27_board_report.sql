-- 27. The monthly board report
-- One query, one table, the whole period: orders, net revenue, gross margin and margin percent, cancelled orders and cancellation rate, running revenue and month over month growth. Gross margin is revenue minus quantity times cost_price. Cancelled and returned orders count in the order total but bring no revenue.
-- Columns: `month`, `orders`, `revenue`, `gross_margin`, `margin_pct` (1 decimal), `cancelled_orders`, `cancel_rate_pct` (1 decimal), `running_revenue`, `mom_growth_pct` (1 decimal)
-- Order: `month`

WITH per_order AS (
    SELECT o.order_id, o.order_date, o.status,
           SUM(i.quantity * i.unit_price - i.discount) AS revenue,
           SUM(i.quantity * p.cost_price) AS cost
    FROM orders AS o
    INNER JOIN order_items AS i
    ON i.order_id = o.order_id
    INNER JOIN products AS p
    ON p.product_id = i.product_id
    GROUP BY o.order_id, o.order_date, o.status
),
monthly AS (
    SELECT TO_CHAR(order_date, 'YYYY-MM') AS month,
           COUNT(*) AS orders,
           SUM(CASE WHEN status NOT IN ('cancelled', 'returned')
                    THEN revenue ELSE 0 END) AS revenue,
           SUM(CASE WHEN status NOT IN ('cancelled', 'returned')
                    THEN revenue - cost ELSE 0 END) AS gross_margin,
           COUNT(CASE WHEN status = 'cancelled' THEN 1 END) AS cancelled_orders
    FROM per_order
    GROUP BY month
)
SELECT month, orders, revenue, gross_margin,
       ROUND(100.0 * gross_margin / revenue, 1) AS margin_pct,
       cancelled_orders,
       ROUND(100.0 * cancelled_orders / orders, 1) AS cancel_rate_pct,
       SUM(revenue) OVER (ORDER BY month
                          ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_revenue,
       ROUND(100.0 * (revenue - LAG(revenue) OVER (ORDER BY month))
             / LAG(revenue) OVER (ORDER BY month), 1) AS mom_growth_pct
FROM monthly
ORDER BY month;
