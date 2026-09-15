# Questions

Twenty eight tasks on the Nusantara Living database. Write your query in the matching file under `answers/`, then run the checker (see the README).

Rules used everywhere unless a task says otherwise:

- **Net revenue of a line** is `quantity * unit_price - discount`.
- **Revenue counts only orders that were not cancelled and not returned**, so `WHERE o.status NOT IN ('cancelled', 'returned')`.
- **Cost of a line** is `quantity * cost_price` from `products`. Gross margin is revenue minus cost.
- `shipping_fee` is not part of revenue.
- Column names and their order have to match the task, because the checker compares text.

## Part A. Warm up

*SELECT, WHERE, GROUP BY, HAVING, ORDER BY*

### 01. Catalogue size per category

Finance wants to know how wide the active catalogue is. For products that are still active, show one row per category with the number of products and the average list price.

- **Columns:** `category`, `products`, `avg_list_price` (rounded to whole rupiah)
- **Order:** `products` descending, then `category`
- **Hint:** GROUP BY with COUNT and ROUND(AVG(...)).
- **File:** `answers/01_active_products_per_category.sql`

### 02. Revenue by month in 2025

Build the monthly sales line for 2025: how many orders and how much net revenue each month.

- **Columns:** `month` (text like 2025-01), `orders`, `revenue`
- **Order:** `month`
- **Hint:** `TO_CHAR(o.order_date, 'YYYY-MM')` turns a date into 2025-01. Count orders with COUNT(DISTINCT o.order_id), because joining order_items repeats the order row.
- **File:** `answers/02_revenue_by_month_2025.sql`

### 03. Reseller and corporate customers in two cities

Marketing asks for the customers in Jakarta or Surabaya, segment reseller or corporate, who signed up during 2025.

- **Columns:** `customer_id`, `full_name`, `city`, `segment`, `signup_date`
- **Order:** `signup_date`, then `customer_id`
- **Hint:** Two IN lists and a BETWEEN on the date.
- **File:** `answers/03_reseller_customers_2025.sql`

### 04. Ten best selling products

Which ten products brought in the most net revenue over the whole period?

- **Columns:** `product_id`, `product_name`, `category`, `units_sold`, `revenue`
- **Order:** `revenue` descending, then `product_id`, limit 10
- **Hint:** Join order_items to orders and products, then GROUP BY the product.
- **File:** `answers/04_top_products.sql`

## Part B. Joining tables

*INNER and LEFT JOIN, anti join, EXCEPT*

### 05. June 2026 orders with the customer behind them

List the fifteen biggest June 2026 orders with the customer name, city and channel.

- **Columns:** `order_id`, `order_date`, `full_name`, `city`, `channel`, `order_value`
- **Order:** `order_value` descending, then `order_id`, limit 15
- **Hint:** Join orders to customers and order_items, then group by the order.
- **File:** `answers/05_june_orders_with_customer.sql`

### 06. Customers who never ordered

Which registered customers have never placed a single order? The team wants to re-target them.

- **Columns:** `customer_id`, `full_name`, `city`, `signup_date`
- **Order:** `customer_id`
- **Hint:** LEFT JOIN orders and keep the rows where the order side is NULL, or use NOT EXISTS.
- **File:** `answers/06_customers_without_orders.sql`

### 07. Products that never sold

Inventory wants the products that have never appeared in any order, active or not.

- **Columns:** `product_id`, `product_name`, `category`, `list_price`
- **Order:** `product_id`
- **Hint:** An anti join. NOT IN is safe here because order_items.product_id can never be NULL.
- **File:** `answers/07_products_never_ordered.sql`

### 08. Vouchers that disappeared in 2026

Which voucher codes were used in 2025 but never in 2026?

- **Columns:** `voucher_code`
- **Order:** `voucher_code`
- **Hint:** EXCEPT between the 2025 list and the 2026 list. Drop the NULL rows first.
- **File:** `answers/08_vouchers_dropped_in_2026.sql`

## Part C. CASE

*labels, pivots, and CASE inside COUNT, SUM and AVG*

### 09. Label every order by size

Tag the June 2026 orders as Small (under 1,000,000), Medium (1,000,000 up to 5,000,000) or Large (5,000,000 and above), based on net order value.

- **Columns:** `order_id`, `order_value`, `size_label`
- **Order:** `order_value` descending, then `order_id`, limit 20
- **Hint:** The CASE sits on top of the SUM, so write the same SUM inside the CASE. Put the narrowest condition first.
- **File:** `answers/09_order_size_label.sql`

### 10. Group the payment methods

Treasury thinks in three buckets: Instant (va, ewallet), Delayed (transfer, paylater) and On delivery (cod). Show orders and net revenue per bucket.

- **Columns:** `payment_group`, `orders`, `revenue`
- **Order:** `revenue` descending
- **Hint:** The CASE goes in SELECT and in GROUP BY. PostgreSQL lets you write GROUP BY payment_group.
- **File:** `answers/10_payment_groups.sql`

### 11. Order status as columns, month by month

For 2026, turn the order status into columns: delivered, cancelled, returned and in progress (paid or shipped), one row per month.

- **Columns:** `month`, `delivered`, `cancelled`, `returned`, `in_progress`
- **Order:** `month`
- **Hint:** COUNT(CASE WHEN ... THEN 1 END). Rows that match nothing become NULL and COUNT skips them.
- **File:** `answers/11_status_pivot_2026.sql`

### 12. Revenue per channel as columns

For the first half of 2026, show monthly net revenue split into three columns, one per channel.

- **Columns:** `month`, `web_revenue`, `app_revenue`, `marketplace_revenue`
- **Order:** `month`
- **Hint:** SUM(CASE WHEN channel = 'web' THEN ... ELSE 0 END). ELSE 0 keeps the total at 0 instead of NULL.
- **File:** `answers/12_channel_revenue_pivot.sql`

### 13. Cancellation and return rate per warehouse

Operations wants the cancellation rate per warehouse, and the return rate measured only against the orders that were not cancelled, since a cancelled order can never be returned.

- **Columns:** `warehouse`, `orders`, `pct_cancelled`, `pct_returned_of_shipped` (both rounded to 2 decimals)
- **Order:** `pct_cancelled` descending, then `warehouse`
- **Hint:** AVG(CASE WHEN ... THEN 1 ELSE 0 END) * 100 is a percentage. For the second column, return NULL for cancelled orders so AVG leaves them out of the denominator.
- **File:** `answers/13_cancel_and_return_rate.sql`

## Part D. Subqueries

*in WHERE, in FROM, in SELECT, correlated and nested*

### 14. Orders above the average order value

In the first half of 2026, which orders are worth more than the average order in that period?

- **Columns:** `order_id`, `order_date`, `warehouse`, `order_value`
- **Order:** `order_value` descending, then `order_id`, limit 15
- **Hint:** The comparison is against an average of order totals, so the inner query has to group by order first. The filter goes in HAVING, because it compares a SUM.
- **File:** `answers/14_orders_above_average.sql`

### 15. Customers who bought lighting

Which customers have ever bought a product from the Lighting category?

- **Columns:** `customer_id`, `full_name`, `city`
- **Order:** `customer_id`, limit 20
- **Hint:** A semi join: WHERE customer_id IN (subquery that returns customer ids).
- **File:** `answers/15_lighting_buyers.sql`

### 16. Best month of each warehouse

For every warehouse, which month brought the most net revenue, and how much?

- **Columns:** `warehouse`, `month`, `revenue`
- **Order:** `warehouse`
- **Hint:** Build monthly revenue per warehouse in a subquery in FROM, then keep the row whose revenue equals the MAX for that same warehouse. The inner MAX depends on the row being checked, so it is a correlated subquery.
- **File:** `answers/16_best_month_per_warehouse.sql`

### 17. Each warehouse against the average warehouse

Show total net revenue per warehouse, the average revenue across the four warehouses, and the gap between the two.

- **Columns:** `warehouse`, `revenue`, `avg_warehouse_revenue`, `diff`
- **Order:** `revenue` descending
- **Hint:** The average is one number for the whole company, so it belongs in a subquery in SELECT. You will write that subquery twice here. Part E shows how a CTE removes the repetition.
- **File:** `answers/17_warehouse_vs_average.sql`

### 18. Products priced above their own category

Which products carry a list price above the average list price of their own category?

- **Columns:** `product_id`, `product_name`, `category`, `list_price`, `category_avg` (rounded)
- **Order:** `category`, then `list_price` descending, then `product_id`
- **Hint:** A correlated subquery: the inner query filters on p2.category = p.category, so it runs again for every product.
- **File:** `answers/18_products_above_category_average.sql`

### 19. Each 2025 month against the average month

For 2025, show monthly net revenue next to the average monthly revenue of that year, and the difference.

- **Columns:** `month`, `revenue`, `avg_month_revenue` (rounded), `diff`
- **Order:** `month`
- **Hint:** Nested subquery: the inner one builds monthly totals, the outer one averages them. Read it from the inside out.
- **File:** `answers/19_month_vs_average_month.sql`

## Part E. CTEs and window functions

*WITH, running totals, RANK, PARTITION BY, moving averages*

### 20. Monthly revenue with a running total

Show every month of the dataset with its net revenue and the running total from the first month up to that month.

- **Columns:** `month`, `revenue`, `running_total`
- **Order:** `month`
- **Hint:** Build the monthly table in a CTE, then SUM(...) OVER (ORDER BY month ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW).
- **File:** `answers/20_running_revenue.sql`

### 21. Top three products in every category

Merchandising wants the three best selling products of each category by net revenue.

- **Columns:** `category`, `rank_in_category`, `product_name`, `revenue`
- **Order:** `category`, `rank_in_category`, `product_name`
- **Hint:** One CTE for revenue per product, a second one adding RANK() OVER (PARTITION BY category ORDER BY revenue DESC), then filter the rank in the main query.
- **File:** `answers/21_top3_per_category.sql`

### 22. Three month moving average

Smooth the monthly revenue line with a three month moving average, so the promo spikes stop hiding the trend.

- **Columns:** `month`, `revenue`, `moving_avg_3m` (rounded)
- **Order:** `month`
- **Hint:** AVG(revenue) OVER (ORDER BY month ROWS BETWEEN 2 PRECEDING AND CURRENT ROW).
- **File:** `answers/22_moving_average.sql`

### 23. How much of its segment each customer carries

For the fifteen biggest customers, show their net revenue and what share of their own segment's revenue that is.

- **Columns:** `customer_id`, `full_name`, `segment`, `revenue`, `pct_of_segment` (2 decimals)
- **Order:** `revenue` descending, then `customer_id`, limit 15
- **Hint:** SUM(revenue) OVER (PARTITION BY segment) gives the segment total on every row, so you can divide without a second query.
- **File:** `answers/23_customer_share_of_segment.sql`

### 24. Month over month growth

Add the previous month's revenue next to each month and the growth in percent.

- **Columns:** `month`, `revenue`, `prev_month_revenue`, `growth_pct` (2 decimals)
- **Order:** `month`
- **Hint:** LAG(revenue) OVER (ORDER BY month) reads the row before the current one. It is not in the three courses, but it is the standard way finance teams write month over month. The first month has no previous month, so its growth is NULL.
- **File:** `answers/24_month_over_month_growth.sql`

### 25. First orders against repeat orders

For the first half of 2026, how many orders each month were a customer's very first order, and how many were repeat orders?

- **Columns:** `month`, `first_orders`, `repeat_orders`
- **Order:** `month`
- **Hint:** ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date, order_id) numbers each customer's orders. Number 1 is the first order. Then count with CASE.
- **File:** `answers/25_first_vs_repeat_orders.sql`

### 26. Warehouse against target

For the first half of 2026, compare each warehouse's monthly net revenue with its target: the achievement in percent and whether it was a Hit or a Miss.

- **Columns:** `warehouse`, `month`, `revenue`, `revenue_target`, `achievement_pct` (1 decimal), `target_status`
- **Order:** `warehouse`, then `month`
- **Hint:** monthly_targets stores the first day of the month, so group the orders with DATE_TRUNC('month', o.order_date)::date and join on that. CASE gives the Hit or Miss label.
- **File:** `answers/26_target_vs_actual.sql`

## Part F. Put it together

*two reports a finance analyst actually sends*

### 27. The monthly board report

One query, one table, the whole period: orders, net revenue, gross margin and margin percent, cancelled orders and cancellation rate, running revenue and month over month growth. Gross margin is revenue minus quantity times cost_price. Cancelled and returned orders count in the order total but bring no revenue.

- **Columns:** `month`, `orders`, `revenue`, `gross_margin`, `margin_pct` (1 decimal), `cancelled_orders`, `cancel_rate_pct` (1 decimal), `running_revenue`, `mom_growth_pct` (1 decimal)
- **Order:** `month`
- **Hint:** Build it in two CTEs: one row per order first, then one row per month. Window functions come last, in the final SELECT.
- **File:** `answers/27_board_report.sql`

### 28. The top customer file

Twenty biggest customers by net revenue: how many orders, first and last order date, revenue, margin percent, days since the last order counted from 30 June 2026, and their rank inside their own segment.

- **Columns:** `customer_id`, `full_name`, `segment`, `orders`, `first_order`, `last_order`, `revenue`, `margin_pct` (1 decimal), `days_since_last_order`, `rank_in_segment`
- **Order:** `revenue` descending, then `customer_id`, limit 20
- **Hint:** Two CTEs again: one row per order, then one row per customer. DATE '2026-06-30' - last_order gives the number of days.
- **File:** `answers/28_customer_file.sql`
