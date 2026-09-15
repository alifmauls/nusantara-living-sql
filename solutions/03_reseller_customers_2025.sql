-- 03. Reseller and corporate customers in two cities
-- Marketing asks for the customers in Jakarta or Surabaya, segment reseller or corporate, who signed up during 2025.
-- Columns: `customer_id`, `full_name`, `city`, `segment`, `signup_date`
-- Order: `signup_date`, then `customer_id`

SELECT customer_id, full_name, city, segment, signup_date
FROM customers
WHERE city IN ('Jakarta', 'Surabaya')
  AND segment IN ('reseller', 'corporate')
  AND signup_date BETWEEN '2025-01-01' AND '2025-12-31'
ORDER BY signup_date, customer_id;
