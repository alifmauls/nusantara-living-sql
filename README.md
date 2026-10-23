# Nusantara Living: a finance analytics case study in PostgreSQL

Nusantara Living is a made-up online home and living retailer in Indonesia. The dataset is synthetic: 18 months of orders (January 2025 to June 2026) shipped from four warehouses, with a monthly revenue target for each warehouse. I answered 28 finance questions about it in PostgreSQL, from simple aggregation up to a monthly board report in a single query. Every answer is checked against its expected output on each push.

## What the queries show

- **Growth below target.** Net revenue in the first half of 2026 was Rp6.20 billion, 43% more than in the first half of 2025, yet only 94.8% of target. The four warehouses hit their monthly target in 6 of 24 warehouse-months, and in only 3 of 20 after January. (tasks 20 and 26)
- **Margin dips.** Gross margin stayed between 27.8% and 29.7% in 15 of the 18 months. It fell to 25.1% in March 2025, 24.6% in December 2025 and 22.3% in March 2026, the month with the most orders (195). (task 27)
- **Makassar.** Makassar cancels 11.5% of its orders, against 5.3% in Jakarta, and 7.8% of its non-cancelled orders are returned, the highest return rate of the four warehouses. (task 13)
- **Repeat buyers.** In the first half of 2026, 767 of the 836 orders that were not cancelled or returned came from customers who had ordered before. First orders from new customers ran at 8 to 15 a month. (task 25)

## Where to look

- [RESULTS.md](RESULTS.md): each question, my query and the table it returns
- [answers/27_board_report.sql](answers/27_board_report.sql): orders, net revenue, gross margin, cancellation rate, running revenue and month-over-month growth for every month, in one query
- [answers/26_target_vs_actual.sql](answers/26_target_vs_actual.sql): each warehouse's monthly revenue against its target, with achievement percentage and Hit or Miss
- [answers/28_customer_file.sql](answers/28_customer_file.sql): the 20 biggest customers with order count, margin, days since last order and rank within their segment
- [CASE.md](CASE.md): the business, the tables and the questions finance asks every month

## What the tasks cover

| Part | Tasks | SQL |
|---|---|---|
| A. Warm up | 01 to 04 | SELECT, WHERE, GROUP BY, HAVING, ORDER BY, LIMIT |
| B. Joining tables | 05 to 08 | INNER JOIN, LEFT JOIN, anti join, EXCEPT |
| C. CASE | 09 to 13 | labels, pivots with COUNT and SUM, rates with AVG, NULL as an exclusion |
| D. Subqueries | 14 to 19 | in WHERE, in FROM, in SELECT, correlated, nested |
| E. CTEs and window functions | 20 to 26 | WITH, running totals, RANK, PARTITION BY, moving average, LAG, ROW_NUMBER |
| F. Put it together | 27 and 28 | a monthly board report and a top customer file |

## How the answers are checked

Each task has an expected result in `expected/`. `scripts/check.sh` (or `scripts/check.ps1` on Windows) runs every file in `answers/` against the database and compares its output with the expected CSV as text, so column names, column order, row order and rounding all have to match. GitHub Actions runs the same check against a fresh PostgreSQL 16 database on every push. RESULTS.md is generated from `answers/` by `scripts/build_results.ps1`.

## Run it yourself

Docker or a local PostgreSQL 16 both work. The steps are in [SETUP.md](SETUP.md).

## Folder map

```
sql/         schema, seed data and a load check
questions/   the 28 tasks and the rules they share
answers/     my queries, one file per task
expected/    the expected output of each task, as CSV
scripts/     the checker and the RESULTS.md builder, in PowerShell and Bash
tools/       the Python script that generated the synthetic data
```

## About the data

The data is synthetic and generated with a fixed seed, so the expected results stay valid. Some patterns are built into the generator on purpose; they are listed at the top of [tools/generate_seed.py](tools/generate_seed.py). Nusantara Living is not a real company.
