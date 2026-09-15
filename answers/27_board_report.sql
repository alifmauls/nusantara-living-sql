-- 27. The monthly board report
-- One query, one table, the whole period: orders, net revenue, gross margin and margin percent, cancelled orders and cancellation rate, running revenue and month over month growth. Gross margin is revenue minus quantity times cost_price. Cancelled and returned orders count in the order total but bring no revenue.
-- Columns: `month`, `orders`, `revenue`, `gross_margin`, `margin_pct` (1 decimal), `cancelled_orders`, `cancel_rate_pct` (1 decimal), `running_revenue`, `mom_growth_pct` (1 decimal)
-- Order: `month`
-- Write your query below this line.

SELECT
    month,
    orders,
    revenue,
    gross_margin,
    margin_pct,
    cancelled_orders,
    cancel_rate_pct,
    SUM(revenue) OVER(ORDER BY month ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_revenue,
    ROUND(100.0 * (revenue - LAG(revenue) OVER(ORDER BY month)) / LAG(revenue) OVER(ORDER BY month),1) AS mom_growth_pct
FROM (SELECT
        TO_CHAR(o.order_date, 'YYYY-MM') AS month,
        COUNT(DISTINCT o.order_id) AS orders,
        SUM(CASE WHEN o.status NOT IN ('cancelled','returned')
            THEN i.quantity * i.unit_price - i.discount ELSE 0 END) AS revenue,
        SUM(CASE WHEN o.status NOT IN ('cancelled','returned')
            THEN (i.quantity * i.unit_price - i.discount) - (i.quantity * p.cost_price) ELSE 0 END) AS gross_margin,
        ROUND(100.00 * SUM(CASE WHEN o.status NOT IN ('cancelled','returned')
            THEN (i.quantity * i.unit_price - i.discount) - (i.quantity * p.cost_price) ELSE 0 END) / 
            SUM(CASE WHEN o.status NOT IN ('cancelled','returned')
            THEN i.quantity * i.unit_price - i.discount ELSE 0 END),1) AS margin_pct,
        COUNT( DISTINCT CASE WHEN o.status = 'cancelled' THEN o.order_id END) as cancelled_orders,
        ROUND(100.00 * COUNT(DISTINCT CASE WHEN o.status = 'cancelled' THEN o.order_id END) / COUNT(DISTINCT o.order_id),1) AS cancel_rate_pct
    FROM orders AS o
    INNER JOIN order_items AS i
    ON o.order_id = i.order_id
    INNER JOIN products AS p
    ON i.product_id = p.product_id
    GROUP BY TO_CHAR(o.order_date, 'YYYY-MM'))
ORDER BY month;
