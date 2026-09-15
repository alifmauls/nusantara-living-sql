-- 08. Vouchers that disappeared in 2026
-- Which voucher codes were used in 2025 but never in 2026?
-- Columns: `voucher_code`
-- Order: `voucher_code`

SELECT voucher_code
FROM orders
WHERE voucher_code IS NOT NULL
  AND order_date < '2026-01-01'
EXCEPT
SELECT voucher_code
FROM orders
WHERE voucher_code IS NOT NULL
  AND order_date >= '2026-01-01'
ORDER BY voucher_code;
