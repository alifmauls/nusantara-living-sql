-- 08. Vouchers that disappeared in 2026
-- Which voucher codes were used in 2025 but never in 2026?
-- Columns: `voucher_code`
-- Order: `voucher_code`
-- Write your query below this line.

SELECT DISTINCT voucher_code
FROM orders
WHERE EXTRACT(YEAR FROM order_date) = '2025'
EXCEPT
SELECT DISTINCT voucher_code
FROM orders
WHERE EXTRACT(YEAR FROM order_date) = '2026'