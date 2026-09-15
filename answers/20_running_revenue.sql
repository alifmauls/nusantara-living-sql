-- 20. Monthly revenue with a running total
-- Show every month of the dataset with its net revenue and the running total from the first month up to that month.
-- Columns: `month`, `revenue`, `running_total`
-- Order: `month`
-- Write your query below this line.

SELECT
    month, revenue,
    SUM(revenue) OVER(ORDER BY month
                    ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_total
FROM
    (SELECT
        TO_CHAR(o.order_date,'YYYY-MM') AS month,
        SUM(i.quantity * i.unit_price - i.discount) AS revenue
    FROM orders AS o
    INNER JOIN order_items AS i
    ON o.order_id = i.order_id
    WHERE o.status NOT IN ('cancelled','returned')
    GROUP BY TO_CHAR(o.order_date,'YYYY-MM')
    ORDER BY TO_CHAR(o.order_date,'YYYY-MM'));