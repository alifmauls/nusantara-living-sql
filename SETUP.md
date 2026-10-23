# Setup

How to load the Nusantara Living database and run the queries yourself. There are two ways; pick one.

## Option A: Docker

The compose file starts PostgreSQL 16 on port 5433 and loads the schema and the data on first start. Port 5433 keeps it clear of a local PostgreSQL, which uses 5432.

```powershell
cd path\to\nusantara-living-sql
docker compose up -d
docker compose logs -f db        # wait for "database system is ready to accept connections", then Ctrl+C
```

Connection details: host `localhost`, port `5433`, database `nusantara`, user `nusantara`, password `nusantara`.

Open a SQL prompt inside the container:

```powershell
docker exec -it nusantara-db psql -U nusantara -d nusantara
```

Stop it with `docker compose stop` and start it again with `docker compose start`. `docker compose down -v` wipes the data, which then reloads from scratch on the next start.

## Option B: a local PostgreSQL 16

`psql` lives in `C:\Program Files\PostgreSQL\16\bin`. Add that folder to PATH once, or use the full path as below.

```powershell
cd path\to\nusantara-living-sql
$env:PGPASSWORD = "your-postgres-password"
& "C:\Program Files\PostgreSQL\16\bin\createdb.exe" -U postgres nusantara
& "C:\Program Files\PostgreSQL\16\bin\psql.exe" -U postgres -d nusantara -f sql\01_schema.sql
& "C:\Program Files\PostgreSQL\16\bin\psql.exe" -U postgres -d nusantara -f sql\02_seed.sql
```

Loading takes a few seconds. Check that it worked; the expected row counts are listed at the top of the file:

```powershell
& "C:\Program Files\PostgreSQL\16\bin\psql.exe" -U postgres -d nusantara -f sql\03_sanity_check.sql
```

With this option the connection string is `postgres://postgres:your-postgres-password@localhost:5432/nusantara`. Pass it to the scripts with `-Db`.

## Running the queries

Any PostgreSQL client works. In VS Code, the SQLTools extension with the SQLTools PostgreSQL/Cockroach Driver runs the open file with Ctrl+E Ctrl+E. pgAdmin ships with the PostgreSQL installer and connects to either option.

## Checking the answers

```powershell
# Docker database
.\scripts\check.ps1

# local PostgreSQL
.\scripts\check.ps1 -Db "postgres://postgres:your-postgres-password@localhost:5432/nusantara"
```

Each task prints PASS, DIFF, TODO or ERROR. DIFF means the query ran but its rows differ from `expected/`. The full output is saved in `.out\<task number>.csv`, so the two files can be compared side by side. On Linux or macOS, `bash scripts/check.sh answers` does the same, with the connection string in `DATABASE_URL`.

## Rebuilding RESULTS.md

```powershell
.\scripts\build_results.ps1
```

This runs every file in `answers/` and rewrites RESULTS.md with the question, the query and the table it returns.