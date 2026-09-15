#!/usr/bin/env python3
"""Write questions/, answers/ stubs and solutions/ from one list of tasks."""
import os
import textwrap

REV = "i.quantity * i.unit_price - i.discount"

TASKS = [
    # ---------------------------------------------------------------- Part A
    dict(num=1, part="A", slug="active_products_per_category",
         title="Catalogue size per category",
         ask="Finance wants to know how wide the active catalogue is. For products that are still "
             "active, show one row per category with the number of products and the average list price.",
         columns="`category`, `products`, `avg_list_price` (rounded to whole rupiah)",
         order="`products` descending, then `category`",
         hint="GROUP BY with COUNT and ROUND(AVG(...)).",
         sql="""
            SELECT category,
                   COUNT(*) AS products,
                   ROUND(AVG(list_price)) AS avg_list_price
            FROM products
            WHERE is_active
            GROUP BY category
            ORDER BY products DESC, category;
         """),
    dict(num=2, part="A", slug="revenue_by_month_2025",
         title="Revenue by month in 2025",
         ask="Build the monthly sales line for 2025: how many orders and how much net revenue each month.",
         columns="`month` (text like 2025-01), `orders`, `revenue`",
         order="`month`",
         hint="`TO_CHAR(o.order_date, 'YYYY-MM')` turns a date into 2025-01. Count orders with "
              "COUNT(DISTINCT o.order_id), because joining order_items repeats the order row.",
         sql="""
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
         """),
    dict(num=3, part="A", slug="reseller_customers_2025",
         title="Reseller and corporate customers in two cities",
         ask="Marketing asks for the customers in Jakarta or Surabaya, segment reseller or corporate, "
             "who signed up during 2025.",
         columns="`customer_id`, `full_name`, `city`, `segment`, `signup_date`",
         order="`signup_date`, then `customer_id`",
         hint="Two IN lists and a BETWEEN on the date.",
         sql="""
            SELECT customer_id, full_name, city, segment, signup_date
            FROM customers
            WHERE city IN ('Jakarta', 'Surabaya')
              AND segment IN ('reseller', 'corporate')
              AND signup_date BETWEEN '2025-01-01' AND '2025-12-31'
            ORDER BY signup_date, customer_id;
         """),
    dict(num=4, part="A", slug="top_products",
         title="Ten best selling products",
         ask="Which ten products brought in the most net revenue over the whole period?",
         columns="`product_id`, `product_name`, `category`, `units_sold`, `revenue`",
         order="`revenue` descending, then `product_id`, limit 10",
         hint="Join order_items to orders and products, then GROUP BY the product.",
         sql="""
            SELECT p.product_id, p.product_name, p.category,
                   SUM(i.quantity) AS units_sold,
                   SUM(i.quantity * i.unit_price - i.discount) AS revenue
            FROM order_items AS i
            INNER JOIN orders AS o
            ON o.order_id = i.order_id
            INNER JOIN products AS p
            ON p.product_id = i.product_id
            WHERE o.status NOT IN ('cancelled', 'returned')
            GROUP BY p.product_id, p.product_name, p.category
            ORDER BY revenue DESC, p.product_id
            LIMIT 10;
         """),
    # ---------------------------------------------------------------- Part B
    dict(num=5, part="B", slug="june_orders_with_customer",
         title="June 2026 orders with the customer behind them",
         ask="List the fifteen biggest June 2026 orders with the customer name, city and channel.",
         columns="`order_id`, `order_date`, `full_name`, `city`, `channel`, `order_value`",
         order="`order_value` descending, then `order_id`, limit 15",
         hint="Join orders to customers and order_items, then group by the order.",
         sql="""
            SELECT o.order_id, o.order_date, c.full_name, c.city, o.channel,
                   SUM(i.quantity * i.unit_price - i.discount) AS order_value
            FROM orders AS o
            INNER JOIN customers AS c
            ON c.customer_id = o.customer_id
            INNER JOIN order_items AS i
            ON i.order_id = o.order_id
            WHERE o.order_date BETWEEN '2026-06-01' AND '2026-06-30'
              AND o.status NOT IN ('cancelled', 'returned')
            GROUP BY o.order_id, o.order_date, c.full_name, c.city, o.channel
            ORDER BY order_value DESC, o.order_id
            LIMIT 15;
         """),
    dict(num=6, part="B", slug="customers_without_orders",
         title="Customers who never ordered",
         ask="Which registered customers have never placed a single order? The team wants to re-target them.",
         columns="`customer_id`, `full_name`, `city`, `signup_date`",
         order="`customer_id`",
         hint="LEFT JOIN orders and keep the rows where the order side is NULL, or use NOT EXISTS.",
         sql="""
            SELECT c.customer_id, c.full_name, c.city, c.signup_date
            FROM customers AS c
            LEFT JOIN orders AS o
            ON o.customer_id = c.customer_id
            WHERE o.order_id IS NULL
            ORDER BY c.customer_id;
         """),
    dict(num=7, part="B", slug="products_never_ordered",
         title="Products that never sold",
         ask="Inventory wants the products that have never appeared in any order, active or not.",
         columns="`product_id`, `product_name`, `category`, `list_price`",
         order="`product_id`",
         hint="An anti join. NOT IN is safe here because order_items.product_id can never be NULL.",
         sql="""
            SELECT p.product_id, p.product_name, p.category, p.list_price
            FROM products AS p
            WHERE p.product_id NOT IN (SELECT i.product_id FROM order_items AS i)
            ORDER BY p.product_id;
         """),
    dict(num=8, part="B", slug="vouchers_dropped_in_2026",
         title="Vouchers that disappeared in 2026",
         ask="Which voucher codes were used in 2025 but never in 2026?",
         columns="`voucher_code`",
         order="`voucher_code`",
         hint="EXCEPT between the 2025 list and the 2026 list. Drop the NULL rows first.",
         sql="""
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
         """),
    # ---------------------------------------------------------------- Part C
    dict(num=9, part="C", slug="order_size_label",
         title="Label every order by size",
         ask="Tag the June 2026 orders as Small (under 1,000,000), Medium (1,000,000 up to 5,000,000) "
             "or Large (5,000,000 and above), based on net order value.",
         columns="`order_id`, `order_value`, `size_label`",
         order="`order_value` descending, then `order_id`, limit 20",
         hint="The CASE sits on top of the SUM, so write the same SUM inside the CASE. "
              "Put the narrowest condition first.",
         sql="""
            SELECT o.order_id,
                   SUM(i.quantity * i.unit_price - i.discount) AS order_value,
                   CASE WHEN SUM(i.quantity * i.unit_price - i.discount) >= 5000000 THEN 'Large'
                        WHEN SUM(i.quantity * i.unit_price - i.discount) >= 1000000 THEN 'Medium'
                        ELSE 'Small' END AS size_label
            FROM orders AS o
            INNER JOIN order_items AS i
            ON i.order_id = o.order_id
            WHERE o.order_date BETWEEN '2026-06-01' AND '2026-06-30'
              AND o.status NOT IN ('cancelled', 'returned')
            GROUP BY o.order_id
            ORDER BY order_value DESC, o.order_id
            LIMIT 20;
         """),
    dict(num=10, part="C", slug="payment_groups",
         title="Group the payment methods",
         ask="Treasury thinks in three buckets: Instant (va, ewallet), Delayed (transfer, paylater) "
             "and On delivery (cod). Show orders and net revenue per bucket.",
         columns="`payment_group`, `orders`, `revenue`",
         order="`revenue` descending",
         hint="The CASE goes in SELECT and in GROUP BY. PostgreSQL lets you write GROUP BY payment_group.",
         sql="""
            SELECT CASE WHEN o.payment_method IN ('va', 'ewallet') THEN 'Instant'
                        WHEN o.payment_method IN ('transfer', 'paylater') THEN 'Delayed'
                        ELSE 'On delivery' END AS payment_group,
                   COUNT(DISTINCT o.order_id) AS orders,
                   SUM(i.quantity * i.unit_price - i.discount) AS revenue
            FROM orders AS o
            INNER JOIN order_items AS i
            ON i.order_id = o.order_id
            WHERE o.status NOT IN ('cancelled', 'returned')
            GROUP BY payment_group
            ORDER BY revenue DESC;
         """),
    dict(num=11, part="C", slug="status_pivot_2026",
         title="Order status as columns, month by month",
         ask="For 2026, turn the order status into columns: delivered, cancelled, returned and "
             "in progress (paid or shipped), one row per month.",
         columns="`month`, `delivered`, `cancelled`, `returned`, `in_progress`",
         order="`month`",
         hint="COUNT(CASE WHEN ... THEN 1 END). Rows that match nothing become NULL and COUNT skips them.",
         sql="""
            SELECT TO_CHAR(order_date, 'YYYY-MM') AS month,
                   COUNT(CASE WHEN status = 'delivered' THEN 1 END) AS delivered,
                   COUNT(CASE WHEN status = 'cancelled' THEN 1 END) AS cancelled,
                   COUNT(CASE WHEN status = 'returned' THEN 1 END) AS returned,
                   COUNT(CASE WHEN status IN ('paid', 'shipped') THEN 1 END) AS in_progress
            FROM orders
            WHERE order_date >= '2026-01-01'
            GROUP BY month
            ORDER BY month;
         """),
    dict(num=12, part="C", slug="channel_revenue_pivot",
         title="Revenue per channel as columns",
         ask="For the first half of 2026, show monthly net revenue split into three columns, one per channel.",
         columns="`month`, `web_revenue`, `app_revenue`, `marketplace_revenue`",
         order="`month`",
         hint="SUM(CASE WHEN channel = 'web' THEN ... ELSE 0 END). ELSE 0 keeps the total at 0 instead of NULL.",
         sql="""
            SELECT TO_CHAR(o.order_date, 'YYYY-MM') AS month,
                   SUM(CASE WHEN o.channel = 'web'
                            THEN i.quantity * i.unit_price - i.discount ELSE 0 END) AS web_revenue,
                   SUM(CASE WHEN o.channel = 'app'
                            THEN i.quantity * i.unit_price - i.discount ELSE 0 END) AS app_revenue,
                   SUM(CASE WHEN o.channel = 'marketplace'
                            THEN i.quantity * i.unit_price - i.discount ELSE 0 END) AS marketplace_revenue
            FROM orders AS o
            INNER JOIN order_items AS i
            ON i.order_id = o.order_id
            WHERE o.status NOT IN ('cancelled', 'returned')
              AND o.order_date >= '2026-01-01'
            GROUP BY month
            ORDER BY month;
         """),
    dict(num=13, part="C", slug="cancel_and_return_rate",
         title="Cancellation and return rate per warehouse",
         ask="Operations wants the cancellation rate per warehouse, and the return rate measured only "
             "against the orders that were not cancelled, since a cancelled order can never be returned.",
         columns="`warehouse`, `orders`, `pct_cancelled`, `pct_returned_of_shipped` (both rounded to 2 decimals)",
         order="`pct_cancelled` descending, then `warehouse`",
         hint="AVG(CASE WHEN ... THEN 1 ELSE 0 END) * 100 is a percentage. For the second column, "
              "return NULL for cancelled orders so AVG leaves them out of the denominator.",
         sql="""
            SELECT warehouse,
                   COUNT(*) AS orders,
                   ROUND(AVG(CASE WHEN status = 'cancelled' THEN 1 ELSE 0 END) * 100, 2) AS pct_cancelled,
                   ROUND(AVG(CASE WHEN status = 'cancelled' THEN NULL
                                  WHEN status = 'returned' THEN 1
                                  ELSE 0 END) * 100, 2) AS pct_returned_of_shipped
            FROM orders
            GROUP BY warehouse
            ORDER BY pct_cancelled DESC, warehouse;
         """),
    # ---------------------------------------------------------------- Part D
    dict(num=14, part="D", slug="orders_above_average",
         title="Orders above the average order value",
         ask="In the first half of 2026, which orders are worth more than the average order in that period?",
         columns="`order_id`, `order_date`, `warehouse`, `order_value`",
         order="`order_value` descending, then `order_id`, limit 15",
         hint="The comparison is against an average of order totals, so the inner query has to group by "
              "order first. The filter goes in HAVING, because it compares a SUM.",
         sql="""
            SELECT o.order_id, o.order_date, o.warehouse,
                   SUM(i.quantity * i.unit_price - i.discount) AS order_value
            FROM orders AS o
            INNER JOIN order_items AS i
            ON i.order_id = o.order_id
            WHERE o.status NOT IN ('cancelled', 'returned')
              AND o.order_date >= '2026-01-01'
            GROUP BY o.order_id, o.order_date, o.warehouse
            HAVING SUM(i.quantity * i.unit_price - i.discount) >
                   (SELECT AVG(per_order.order_value)
                    FROM (SELECT SUM(i2.quantity * i2.unit_price - i2.discount) AS order_value
                          FROM orders AS o2
                          INNER JOIN order_items AS i2
                          ON i2.order_id = o2.order_id
                          WHERE o2.status NOT IN ('cancelled', 'returned')
                            AND o2.order_date >= '2026-01-01'
                          GROUP BY o2.order_id) AS per_order)
            ORDER BY order_value DESC, o.order_id
            LIMIT 15;
         """),
    dict(num=15, part="D", slug="lighting_buyers",
         title="Customers who bought lighting",
         ask="Which customers have ever bought a product from the Lighting category?",
         columns="`customer_id`, `full_name`, `city`",
         order="`customer_id`, limit 20",
         hint="A semi join: WHERE customer_id IN (subquery that returns customer ids).",
         sql="""
            SELECT c.customer_id, c.full_name, c.city
            FROM customers AS c
            WHERE c.customer_id IN
                  (SELECT o.customer_id
                   FROM orders AS o
                   INNER JOIN order_items AS i
                   ON i.order_id = o.order_id
                   INNER JOIN products AS p
                   ON p.product_id = i.product_id
                   WHERE p.category = 'Lighting'
                     AND o.status NOT IN ('cancelled', 'returned'))
            ORDER BY c.customer_id
            LIMIT 20;
         """),
    dict(num=16, part="D", slug="best_month_per_warehouse",
         title="Best month of each warehouse",
         ask="For every warehouse, which month brought the most net revenue, and how much?",
         columns="`warehouse`, `month`, `revenue`",
         order="`warehouse`",
         hint="Build monthly revenue per warehouse in a subquery in FROM, then keep the row whose revenue "
              "equals the MAX for that same warehouse. The inner MAX depends on the row being checked, "
              "so it is a correlated subquery.",
         sql="""
            SELECT s.warehouse, s.month, s.revenue
            FROM (SELECT o.warehouse,
                         TO_CHAR(o.order_date, 'YYYY-MM') AS month,
                         SUM(i.quantity * i.unit_price - i.discount) AS revenue
                  FROM orders AS o
                  INNER JOIN order_items AS i
                  ON i.order_id = o.order_id
                  WHERE o.status NOT IN ('cancelled', 'returned')
                  GROUP BY o.warehouse, month) AS s
            WHERE s.revenue =
                  (SELECT MAX(s2.revenue)
                   FROM (SELECT o2.warehouse,
                                TO_CHAR(o2.order_date, 'YYYY-MM') AS month,
                                SUM(i2.quantity * i2.unit_price - i2.discount) AS revenue
                         FROM orders AS o2
                         INNER JOIN order_items AS i2
                         ON i2.order_id = o2.order_id
                         WHERE o2.status NOT IN ('cancelled', 'returned')
                         GROUP BY o2.warehouse, month) AS s2
                   WHERE s2.warehouse = s.warehouse)
            ORDER BY s.warehouse;
         """),
    dict(num=17, part="D", slug="warehouse_vs_average",
         title="Each warehouse against the average warehouse",
         ask="Show total net revenue per warehouse, the average revenue across the four warehouses, "
             "and the gap between the two.",
         columns="`warehouse`, `revenue`, `avg_warehouse_revenue`, `diff`",
         order="`revenue` descending",
         hint="The average is one number for the whole company, so it belongs in a subquery in SELECT. "
              "You will write that subquery twice here. Part E shows how a CTE removes the repetition.",
         sql="""
            SELECT o.warehouse,
                   SUM(i.quantity * i.unit_price - i.discount) AS revenue,
                   (SELECT ROUND(AVG(w.revenue))
                    FROM (SELECT o2.warehouse,
                                 SUM(i2.quantity * i2.unit_price - i2.discount) AS revenue
                          FROM orders AS o2
                          INNER JOIN order_items AS i2
                          ON i2.order_id = o2.order_id
                          WHERE o2.status NOT IN ('cancelled', 'returned')
                          GROUP BY o2.warehouse) AS w) AS avg_warehouse_revenue,
                   SUM(i.quantity * i.unit_price - i.discount) -
                   (SELECT ROUND(AVG(w.revenue))
                    FROM (SELECT o2.warehouse,
                                 SUM(i2.quantity * i2.unit_price - i2.discount) AS revenue
                          FROM orders AS o2
                          INNER JOIN order_items AS i2
                          ON i2.order_id = o2.order_id
                          WHERE o2.status NOT IN ('cancelled', 'returned')
                          GROUP BY o2.warehouse) AS w) AS diff
            FROM orders AS o
            INNER JOIN order_items AS i
            ON i.order_id = o.order_id
            WHERE o.status NOT IN ('cancelled', 'returned')
            GROUP BY o.warehouse
            ORDER BY revenue DESC;
         """),
    dict(num=18, part="D", slug="products_above_category_average",
         title="Products priced above their own category",
         ask="Which products carry a list price above the average list price of their own category?",
         columns="`product_id`, `product_name`, `category`, `list_price`, `category_avg` (rounded)",
         order="`category`, then `list_price` descending, then `product_id`",
         hint="A correlated subquery: the inner query filters on p2.category = p.category, so it runs "
              "again for every product.",
         sql="""
            SELECT p.product_id, p.product_name, p.category, p.list_price,
                   (SELECT ROUND(AVG(p2.list_price))
                    FROM products AS p2
                    WHERE p2.category = p.category) AS category_avg
            FROM products AS p
            WHERE p.list_price >
                  (SELECT AVG(p2.list_price)
                   FROM products AS p2
                   WHERE p2.category = p.category)
            ORDER BY p.category, p.list_price DESC, p.product_id;
         """),
    dict(num=19, part="D", slug="month_vs_average_month",
         title="Each 2025 month against the average month",
         ask="For 2025, show monthly net revenue next to the average monthly revenue of that year, "
             "and the difference.",
         columns="`month`, `revenue`, `avg_month_revenue` (rounded), `diff`",
         order="`month`",
         hint="Nested subquery: the inner one builds monthly totals, the outer one averages them. "
              "Read it from the inside out.",
         sql="""
            SELECT TO_CHAR(o.order_date, 'YYYY-MM') AS month,
                   SUM(i.quantity * i.unit_price - i.discount) AS revenue,
                   (SELECT ROUND(AVG(m.revenue))
                    FROM (SELECT TO_CHAR(o2.order_date, 'YYYY-MM') AS month,
                                 SUM(i2.quantity * i2.unit_price - i2.discount) AS revenue
                          FROM orders AS o2
                          INNER JOIN order_items AS i2
                          ON i2.order_id = o2.order_id
                          WHERE o2.status NOT IN ('cancelled', 'returned')
                            AND o2.order_date < '2026-01-01'
                          GROUP BY month) AS m) AS avg_month_revenue,
                   SUM(i.quantity * i.unit_price - i.discount) -
                   (SELECT ROUND(AVG(m.revenue))
                    FROM (SELECT TO_CHAR(o2.order_date, 'YYYY-MM') AS month,
                                 SUM(i2.quantity * i2.unit_price - i2.discount) AS revenue
                          FROM orders AS o2
                          INNER JOIN order_items AS i2
                          ON i2.order_id = o2.order_id
                          WHERE o2.status NOT IN ('cancelled', 'returned')
                            AND o2.order_date < '2026-01-01'
                          GROUP BY month) AS m) AS diff
            FROM orders AS o
            INNER JOIN order_items AS i
            ON i.order_id = o.order_id
            WHERE o.status NOT IN ('cancelled', 'returned')
              AND o.order_date < '2026-01-01'
            GROUP BY month
            ORDER BY month;
         """),
    # ---------------------------------------------------------------- Part E
    dict(num=20, part="E", slug="running_revenue",
         title="Monthly revenue with a running total",
         ask="Show every month of the dataset with its net revenue and the running total from the "
             "first month up to that month.",
         columns="`month`, `revenue`, `running_total`",
         order="`month`",
         hint="Build the monthly table in a CTE, then SUM(...) OVER (ORDER BY month ROWS BETWEEN "
              "UNBOUNDED PRECEDING AND CURRENT ROW).",
         sql="""
            WITH monthly AS (
                SELECT TO_CHAR(o.order_date, 'YYYY-MM') AS month,
                       SUM(i.quantity * i.unit_price - i.discount) AS revenue
                FROM orders AS o
                INNER JOIN order_items AS i
                ON i.order_id = o.order_id
                WHERE o.status NOT IN ('cancelled', 'returned')
                GROUP BY month
            )
            SELECT month, revenue,
                   SUM(revenue) OVER (ORDER BY month
                                      ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_total
            FROM monthly
            ORDER BY month;
         """),
    dict(num=21, part="E", slug="top3_per_category",
         title="Top three products in every category",
         ask="Merchandising wants the three best selling products of each category by net revenue.",
         columns="`category`, `rank_in_category`, `product_name`, `revenue`",
         order="`category`, `rank_in_category`, `product_name`",
         hint="One CTE for revenue per product, a second one adding RANK() OVER (PARTITION BY category "
              "ORDER BY revenue DESC), then filter the rank in the main query.",
         sql="""
            WITH product_revenue AS (
                SELECT p.category, p.product_id, p.product_name,
                       SUM(i.quantity * i.unit_price - i.discount) AS revenue
                FROM order_items AS i
                INNER JOIN orders AS o
                ON o.order_id = i.order_id
                INNER JOIN products AS p
                ON p.product_id = i.product_id
                WHERE o.status NOT IN ('cancelled', 'returned')
                GROUP BY p.category, p.product_id, p.product_name
            ),
            ranked AS (
                SELECT category, product_name, revenue,
                       RANK() OVER (PARTITION BY category ORDER BY revenue DESC) AS rank_in_category
                FROM product_revenue
            )
            SELECT category, rank_in_category, product_name, revenue
            FROM ranked
            WHERE rank_in_category <= 3
            ORDER BY category, rank_in_category, product_name;
         """),
    dict(num=22, part="E", slug="moving_average",
         title="Three month moving average",
         ask="Smooth the monthly revenue line with a three month moving average, so the promo spikes "
             "stop hiding the trend.",
         columns="`month`, `revenue`, `moving_avg_3m` (rounded)",
         order="`month`",
         hint="AVG(revenue) OVER (ORDER BY month ROWS BETWEEN 2 PRECEDING AND CURRENT ROW).",
         sql="""
            WITH monthly AS (
                SELECT TO_CHAR(o.order_date, 'YYYY-MM') AS month,
                       SUM(i.quantity * i.unit_price - i.discount) AS revenue
                FROM orders AS o
                INNER JOIN order_items AS i
                ON i.order_id = o.order_id
                WHERE o.status NOT IN ('cancelled', 'returned')
                GROUP BY month
            )
            SELECT month, revenue,
                   ROUND(AVG(revenue) OVER (ORDER BY month
                                            ROWS BETWEEN 2 PRECEDING AND CURRENT ROW)) AS moving_avg_3m
            FROM monthly
            ORDER BY month;
         """),
    dict(num=23, part="E", slug="customer_share_of_segment",
         title="How much of its segment each customer carries",
         ask="For the fifteen biggest customers, show their net revenue and what share of their own "
             "segment's revenue that is.",
         columns="`customer_id`, `full_name`, `segment`, `revenue`, `pct_of_segment` (2 decimals)",
         order="`revenue` descending, then `customer_id`, limit 15",
         hint="SUM(revenue) OVER (PARTITION BY segment) gives the segment total on every row, so you can "
              "divide without a second query.",
         sql="""
            WITH customer_revenue AS (
                SELECT c.customer_id, c.full_name, c.segment,
                       SUM(i.quantity * i.unit_price - i.discount) AS revenue
                FROM customers AS c
                INNER JOIN orders AS o
                ON o.customer_id = c.customer_id
                INNER JOIN order_items AS i
                ON i.order_id = o.order_id
                WHERE o.status NOT IN ('cancelled', 'returned')
                GROUP BY c.customer_id, c.full_name, c.segment
            )
            SELECT customer_id, full_name, segment, revenue,
                   ROUND(100.0 * revenue / SUM(revenue) OVER (PARTITION BY segment), 2) AS pct_of_segment
            FROM customer_revenue
            ORDER BY revenue DESC, customer_id
            LIMIT 15;
         """),
    dict(num=24, part="E", slug="month_over_month_growth",
         title="Month over month growth",
         ask="Add the previous month's revenue next to each month and the growth in percent.",
         columns="`month`, `revenue`, `prev_month_revenue`, `growth_pct` (2 decimals)",
         order="`month`",
         hint="LAG(revenue) OVER (ORDER BY month) reads the row before the current one. It is not in the "
              "three courses, but it is the standard way finance teams write month over month. "
              "The first month has no previous month, so its growth is NULL.",
         sql="""
            WITH monthly AS (
                SELECT TO_CHAR(o.order_date, 'YYYY-MM') AS month,
                       SUM(i.quantity * i.unit_price - i.discount) AS revenue
                FROM orders AS o
                INNER JOIN order_items AS i
                ON i.order_id = o.order_id
                WHERE o.status NOT IN ('cancelled', 'returned')
                GROUP BY month
            )
            SELECT month, revenue,
                   LAG(revenue) OVER (ORDER BY month) AS prev_month_revenue,
                   ROUND(100.0 * (revenue - LAG(revenue) OVER (ORDER BY month))
                         / LAG(revenue) OVER (ORDER BY month), 2) AS growth_pct
            FROM monthly
            ORDER BY month;
         """),
    dict(num=25, part="E", slug="first_vs_repeat_orders",
         title="First orders against repeat orders",
         ask="For the first half of 2026, how many orders each month were a customer's very first order, "
             "and how many were repeat orders?",
         columns="`month`, `first_orders`, `repeat_orders`",
         order="`month`",
         hint="ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date, order_id) numbers each "
              "customer's orders. Number 1 is the first order. Then count with CASE.",
         sql="""
            WITH numbered AS (
                SELECT order_id, customer_id, order_date,
                       ROW_NUMBER() OVER (PARTITION BY customer_id
                                          ORDER BY order_date, order_id) AS order_seq
                FROM orders
                WHERE status NOT IN ('cancelled', 'returned')
            )
            SELECT TO_CHAR(order_date, 'YYYY-MM') AS month,
                   COUNT(CASE WHEN order_seq = 1 THEN 1 END) AS first_orders,
                   COUNT(CASE WHEN order_seq > 1 THEN 1 END) AS repeat_orders
            FROM numbered
            WHERE order_date >= '2026-01-01'
            GROUP BY month
            ORDER BY month;
         """),
    dict(num=26, part="E", slug="target_vs_actual",
         title="Warehouse against target",
         ask="For the first half of 2026, compare each warehouse's monthly net revenue with its target: "
             "the achievement in percent and whether it was a Hit or a Miss.",
         columns="`warehouse`, `month`, `revenue`, `revenue_target`, `achievement_pct` (1 decimal), `target_status`",
         order="`warehouse`, then `month`",
         hint="monthly_targets stores the first day of the month, so group the orders with "
              "DATE_TRUNC('month', o.order_date)::date and join on that. CASE gives the Hit or Miss label.",
         sql="""
            WITH monthly AS (
                SELECT o.warehouse,
                       DATE_TRUNC('month', o.order_date)::date AS month_start,
                       SUM(i.quantity * i.unit_price - i.discount) AS revenue
                FROM orders AS o
                INNER JOIN order_items AS i
                ON i.order_id = o.order_id
                WHERE o.status NOT IN ('cancelled', 'returned')
                GROUP BY o.warehouse, month_start
            )
            SELECT m.warehouse,
                   TO_CHAR(m.month_start, 'YYYY-MM') AS month,
                   m.revenue,
                   t.revenue_target,
                   ROUND(100.0 * m.revenue / t.revenue_target, 1) AS achievement_pct,
                   CASE WHEN m.revenue >= t.revenue_target THEN 'Hit' ELSE 'Miss' END AS target_status
            FROM monthly AS m
            INNER JOIN monthly_targets AS t
            ON t.warehouse = m.warehouse
               AND t.target_month = m.month_start
            WHERE m.month_start >= '2026-01-01'
            ORDER BY m.warehouse, month;
         """),
    # ---------------------------------------------------------------- Part F
    dict(num=27, part="F", slug="board_report",
         title="The monthly board report",
         ask="One query, one table, the whole period: orders, net revenue, gross margin and margin "
             "percent, cancelled orders and cancellation rate, running revenue and month over month growth. "
             "Gross margin is revenue minus quantity times cost_price. Cancelled and returned orders "
             "count in the order total but bring no revenue.",
         columns="`month`, `orders`, `revenue`, `gross_margin`, `margin_pct` (1 decimal), `cancelled_orders`, "
                 "`cancel_rate_pct` (1 decimal), `running_revenue`, `mom_growth_pct` (1 decimal)",
         order="`month`",
         hint="Build it in two CTEs: one row per order first, then one row per month. Window functions "
              "come last, in the final SELECT.",
         sql="""
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
         """),
    dict(num=28, part="F", slug="customer_file",
         title="The top customer file",
         ask="Twenty biggest customers by net revenue: how many orders, first and last order date, "
             "revenue, margin percent, days since the last order counted from 30 June 2026, and their "
             "rank inside their own segment.",
         columns="`customer_id`, `full_name`, `segment`, `orders`, `first_order`, `last_order`, `revenue`, "
                 "`margin_pct` (1 decimal), `days_since_last_order`, `rank_in_segment`",
         order="`revenue` descending, then `customer_id`, limit 20",
         hint="Two CTEs again: one row per order, then one row per customer. "
              "DATE '2026-06-30' - last_order gives the number of days.",
         sql="""
            WITH per_order AS (
                SELECT c.customer_id, c.full_name, c.segment,
                       o.order_id, o.order_date,
                       SUM(i.quantity * i.unit_price - i.discount) AS revenue,
                       SUM(i.quantity * p.cost_price) AS cost
                FROM customers AS c
                INNER JOIN orders AS o
                ON o.customer_id = c.customer_id
                INNER JOIN order_items AS i
                ON i.order_id = o.order_id
                INNER JOIN products AS p
                ON p.product_id = i.product_id
                WHERE o.status NOT IN ('cancelled', 'returned')
                GROUP BY c.customer_id, c.full_name, c.segment, o.order_id, o.order_date
            ),
            per_customer AS (
                SELECT customer_id, full_name, segment,
                       COUNT(*) AS orders,
                       MIN(order_date) AS first_order,
                       MAX(order_date) AS last_order,
                       SUM(revenue) AS revenue,
                       SUM(revenue - cost) AS gross_margin
                FROM per_order
                GROUP BY customer_id, full_name, segment
            )
            SELECT customer_id, full_name, segment, orders, first_order, last_order, revenue,
                   ROUND(100.0 * gross_margin / revenue, 1) AS margin_pct,
                   DATE '2026-06-30' - last_order AS days_since_last_order,
                   RANK() OVER (PARTITION BY segment ORDER BY revenue DESC) AS rank_in_segment
            FROM per_customer
            ORDER BY revenue DESC, customer_id
            LIMIT 20;
         """),
]

PARTS = {
    "A": ("Part A. Warm up", "SELECT, WHERE, GROUP BY, HAVING, ORDER BY"),
    "B": ("Part B. Joining tables", "INNER and LEFT JOIN, anti join, EXCEPT"),
    "C": ("Part C. CASE", "labels, pivots, and CASE inside COUNT, SUM and AVG"),
    "D": ("Part D. Subqueries", "in WHERE, in FROM, in SELECT, correlated and nested"),
    "E": ("Part E. CTEs and window functions", "WITH, running totals, RANK, PARTITION BY, moving averages"),
    "F": ("Part F. Put it together", "two reports a finance analyst actually sends"),
}


def dedent(sql):
    return textwrap.dedent(sql).strip() + "\n"


def main():
    root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    os.chdir(root)
    lines = [
        "# Questions",
        "",
        "Twenty eight tasks on the Nusantara Living database. Write your query in the matching file "
        "under `answers/`, then run the checker (see the README).",
        "",
        "Rules used everywhere unless a task says otherwise:",
        "",
        "- **Net revenue of a line** is `quantity * unit_price - discount`.",
        "- **Revenue counts only orders that were not cancelled and not returned**, so "
        "`WHERE o.status NOT IN ('cancelled', 'returned')`.",
        "- **Cost of a line** is `quantity * cost_price` from `products`. Gross margin is revenue minus cost.",
        "- `shipping_fee` is not part of revenue.",
        "- Column names and their order have to match the task, because the checker compares text.",
        "",
    ]
    for part, (heading, blurb) in PARTS.items():
        lines += [f"## {heading}", "", f"*{blurb}*", ""]
        for task in [t for t in TASKS if t["part"] == part]:
            num = f"{task['num']:02d}"
            lines += [
                f"### {num}. {task['title']}",
                "",
                task["ask"],
                "",
                f"- **Columns:** {task['columns']}",
                f"- **Order:** {task['order']}",
                f"- **Hint:** {task['hint']}",
                f"- **File:** `answers/{num}_{task['slug']}.sql`",
                "",
            ]
    with open("questions/QUESTIONS.md", "w") as f:
        f.write("\n".join(lines))

    for task in TASKS:
        num = f"{task['num']:02d}"
        name = f"{num}_{task['slug']}.sql"
        header = (
            f"-- {num}. {task['title']}\n"
            f"-- {task['ask']}\n"
            f"-- Columns: {task['columns']}\n"
            f"-- Order: {task['order']}\n"
        )
        with open(f"answers/{name}", "w") as f:
            f.write(header + "-- Write your query below this line.\n\n")
        with open(f"solutions/{name}", "w") as f:
            f.write(header + "\n" + dedent(task["sql"]))
    print(f"wrote questions/QUESTIONS.md, {len(TASKS)} answer stubs and {len(TASKS)} solutions")


if __name__ == "__main__":
    main()
