# Nusantara Living, a SQL case study

A finance analytics case on a made-up Indonesian home and living retailer: 18 months of orders,
four warehouses, monthly targets, and 28 questions that go from `SELECT` to a full board report.

The repository holds the database, the questions, my answers, and a script that checks each answer
against the expected result.

- The business and the tables: [CASE.md](CASE.md)
- The 28 tasks: [questions/QUESTIONS.md](questions/QUESTIONS.md)
- My answers: [`answers/`](answers)
- Query output, question by question: [RESULTS.md](RESULTS.md)

## What the tasks cover

| Part | Tasks | SQL |
|---|---|---|
| A. Warm up | 01 to 04 | SELECT, WHERE, GROUP BY, HAVING, ORDER BY, LIMIT |
| B. Joining tables | 05 to 08 | INNER JOIN, LEFT JOIN, anti join, EXCEPT |
| C. CASE | 09 to 13 | labels, pivots with COUNT and SUM, rates with AVG, NULL as an exclusion |
| D. Subqueries | 14 to 19 | in WHERE, in FROM, in SELECT, correlated, nested |
| E. CTEs and window functions | 20 to 26 | WITH, running totals, RANK, PARTITION BY, moving average, LAG, ROW_NUMBER |
| F. Put it together | 27 and 28 | a monthly board report and a top customer file |

## Setting up the database

Two ways. Pick one.

### Option A, Docker

The compose file starts PostgreSQL 16 on **port 5433** and loads the schema and the data on first
start. Port 5433 is used on purpose, so it never collides with a PostgreSQL installed on the
laptop, which uses 5432.

```powershell
cd path\to\nusantara-living-sql
docker compose up -d
docker compose logs -f db        # wait for "database system is ready to accept connections", then Ctrl+C
```

Connection details: host `localhost`, port `5433`, database `nusantara`, user `nusantara`,
password `nusantara`.

Open a SQL prompt inside the container:

```powershell
docker exec -it nusantara-db psql -U nusantara -d nusantara
```

Stop it later with `docker compose stop`, start it again with `docker compose start`. Use
`docker compose down -v` only if you want to wipe the data and reload it from scratch.

### Option B, the PostgreSQL you installed yourself

`psql` lives in `C:\Program Files\PostgreSQL\16\bin`. Either add that folder to PATH once, or use
the full path in the commands below.

```powershell
cd path\to\nusantara-living-sql
$env:PGPASSWORD = "your-postgres-password"
& "C:\Program Files\PostgreSQL\16\bin\createdb.exe" -U postgres nusantara
& "C:\Program Files\PostgreSQL\16\bin\psql.exe" -U postgres -d nusantara -f sql\01_schema.sql
& "C:\Program Files\PostgreSQL\16\bin\psql.exe" -U postgres -d nusantara -f sql\02_seed.sql
```

Loading the data takes a few seconds. Check that it worked:

```powershell
& "C:\Program Files\PostgreSQL\16\bin\psql.exe" -U postgres -d nusantara -f sql\03_sanity_check.sql
```

With this option the connection string is
`postgres://postgres:your-postgres-password@localhost:5432/nusantara`, and every command below
needs `-Db` with that string.

## Working on the tasks in VS Code

1. Install the extensions **SQLTools** and **SQLTools PostgreSQL/Cockroach Driver**.
2. In the SQLTools sidebar, **Add New Connection**, choose PostgreSQL, and fill in the host, port,
   database, user and password from the option you picked above.
3. Open a file from `answers/`, write the query, and run it with **Ctrl+E Ctrl+E**. The result
   opens in a tab next to the editor.

Prefer a GUI? pgAdmin ships with the PostgreSQL installer and connects to either option.

## Checking your answers

Each task has an expected result in `expected/`. The checker runs your file and compares the two.

```powershell
# Docker database
.\scripts\check.ps1

# database you installed yourself
.\scripts\check.ps1 -Db "postgres://postgres:your-postgres-password@localhost:5432/nusantara"

# check one part only by moving the others out of the way, or check the reference answers
.\scripts\check.ps1 -Folder solutions
```

Output looks like this:

```
PASS     01  01_active_products_per_category.sql
DIFF     02  02_revenue_by_month_2025.sql
         expected 2025-01,88,476545000
         yours    2025-01,95,476545000
TODO     03  03_reseller_customers_2025.sql

passed 1, wrong 1, not started 1
```

`DIFF` means the query ran but the rows are not the same. The full output of your query is saved in
`.out\02.csv`, so you can open both files side by side. The comparison is text, so the column names,
the column order, the row order and the rounding all have to match what the task asks for.

`solutions/` holds a reference answer for every task. Open it after you have tried, not before.

## Publishing the results

`scripts/build_results.ps1` runs every answer and writes **RESULTS.md**, with the question, the
query and the table it returns. That file is the part a recruiter will actually read.

```powershell
.\scripts\build_results.ps1
```

Then push the repository:

```powershell
git init
git add .
git commit -m "SQL case study: Nusantara Living"
git branch -M main
git remote add origin https://github.com/YOUR-USERNAME/nusantara-living-sql.git
git push -u origin main
```

`.github/workflows/check.yml` runs the reference solutions against a fresh PostgreSQL on every
push, so the repository carries a green check. Delete that folder if you do not want it.

## Folder map

```
sql/            schema, data, and a sanity check query
questions/      the 28 tasks
answers/        one empty file per task, this is where you write
solutions/      reference answers, for after you have tried
expected/       the expected output of each task, as CSV
scripts/        check.ps1 and build_results.ps1 for Windows, .sh versions for CI
tools/          the generator that produced the synthetic data
```

The data is synthetic and generated with a fixed seed. Nusantara Living is not a real company.
