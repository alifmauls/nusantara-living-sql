#!/usr/bin/env bash
# Run every SQL file in a folder and compare its output with expected/.
# Usage: bash scripts/check.sh [answers|solutions]
set -u

DIR="${1:-answers}"
DB="${DATABASE_URL:-postgres://nusantara:nusantara@localhost:5433/nusantara}"
OUT=".out"
mkdir -p "$OUT"

pass=0
fail=0
todo=0

for exp in expected/*.csv; do
    num="$(basename "$exp" .csv)"
    file="$(ls "$DIR"/${num}_*.sql 2>/dev/null | head -1)"

    if [ -z "$file" ]; then
        printf 'MISSING  %s  no file in %s/\n' "$num" "$DIR"
        fail=$((fail + 1))
        continue
    fi
    if ! grep -qvE '^[[:space:]]*(--.*)?$' "$file"; then
        printf 'TODO     %s  %s\n' "$num" "$(basename "$file")"
        todo=$((todo + 1))
        continue
    fi
    if ! psql "$DB" -v ON_ERROR_STOP=1 -q --csv -f "$file" > "$OUT/$num.csv" 2> "$OUT/$num.err"; then
        printf 'ERROR    %s  %s\n' "$num" "$(head -2 "$OUT/$num.err" | tr '\n' ' ')"
        fail=$((fail + 1))
        continue
    fi
    if diff -q "$exp" "$OUT/$num.csv" > /dev/null; then
        printf 'PASS     %s  %s\n' "$num" "$(basename "$file")"
        pass=$((pass + 1))
    else
        printf 'DIFF     %s  %s\n' "$num" "$(basename "$file")"
        diff "$exp" "$OUT/$num.csv" | head -6 | sed 's/^/         /'
        fail=$((fail + 1))
    fi
done

printf '\npassed %d, wrong %d, not started %d\n' "$pass" "$fail" "$todo"
[ "$fail" -eq 0 ]
