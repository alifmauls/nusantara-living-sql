-- 03. Reseller and corporate customers in two cities
-- Marketing asks for the customers in Jakarta or Surabaya, segment reseller or corporate, who signed up during 2025.
-- Columns: `customer_id`, `full_name`, `city`, `segment`, `signup_date`
-- Order: `signup_date`, then `customer_id`
-- Write your query below this line.

SELECT
    customer_id,
    full_name,
    city,
    segment,
    signup_date
FROM customers
WHERE (segment = 'reseller' OR segment = 'corporate')
    AND signup_date >= DATE '2025-01-01'
    AND signup_date < DATE '2026-01-01'
        AND city IN ('Surabaya', 'Jakarta')
ORDER BY signup_date;