<#
    Run every SQL file in a folder and compare its output with expected/.

    Examples:
      .\scripts\check.ps1                      # checks answers/ against the Docker database
      .\scripts\check.ps1 -Folder solutions    # checks the reference answers
      .\scripts\check.ps1 -Db "postgres://postgres:secret@localhost:5432/nusantara"
#>
param(
    [string]$Folder = "answers",
    [string]$Db = $env:DATABASE_URL,
    [string]$Psql = ""
)

if ([string]::IsNullOrWhiteSpace($Db)) {
    $Db = "postgres://nusantara:nusantara@localhost:5433/nusantara"
}

if ([string]::IsNullOrWhiteSpace($Psql)) {
    $found = Get-Command psql -ErrorAction SilentlyContinue
    if ($found) {
        $Psql = $found.Source
    } else {
        $candidate = Get-ChildItem "C:\Program Files\PostgreSQL\*\bin\psql.exe" -ErrorAction SilentlyContinue |
                     Sort-Object FullName -Descending | Select-Object -First 1
        if ($candidate) {
            $Psql = $candidate.FullName
        } else {
            Write-Host "psql not found. Install PostgreSQL or pass -Psql with the full path." -ForegroundColor Red
            exit 1
        }
    }
}

New-Item -ItemType Directory -Force -Path ".out" | Out-Null
$pass = 0; $fail = 0; $todo = 0

foreach ($expected in Get-ChildItem "expected\*.csv" | Sort-Object Name) {
    $num = $expected.BaseName
    $file = Get-ChildItem "$Folder\$($num)_*.sql" -ErrorAction SilentlyContinue | Select-Object -First 1

    if (-not $file) {
        Write-Host ("MISSING  {0}  no file in {1}\" -f $num, $Folder) -ForegroundColor Yellow
        $fail++
        continue
    }

    $body = Get-Content $file.FullName | Where-Object { $_.Trim() -ne "" -and -not $_.Trim().StartsWith("--") }
    if (-not $body) {
        Write-Host ("TODO     {0}  {1}" -f $num, $file.Name) -ForegroundColor DarkGray
        $todo++
        continue
    }

    $outFile = ".out\$num.csv"
    $errFile = ".out\$num.err"
    & $Psql $Db -v ON_ERROR_STOP=1 -q --csv -f $file.FullName 1> $outFile 2> $errFile
    if ($LASTEXITCODE -ne 0) {
        $message = (Get-Content $errFile -TotalCount 2) -join " "
        Write-Host ("ERROR    {0}  {1}" -f $num, $message) -ForegroundColor Red
        $fail++
        continue
    }

    $want = Get-Content $expected.FullName
    $got = Get-Content $outFile
    if ($null -eq (Compare-Object $want $got -SyncWindow 0)) {
        Write-Host ("PASS     {0}  {1}" -f $num, $file.Name) -ForegroundColor Green
        $pass++
    } else {
        Write-Host ("DIFF     {0}  {1}" -f $num, $file.Name) -ForegroundColor Red
        Compare-Object $want $got -SyncWindow 0 |
            Select-Object -First 6 |
            ForEach-Object {
                $side = if ($_.SideIndicator -eq "<=") { "expected" } else { "yours   " }
                Write-Host ("         {0} {1}" -f $side, $_.InputObject)
            }
        $fail++
    }
}

Write-Host ""
Write-Host ("passed {0}, wrong {1}, not started {2}" -f $pass, $fail, $todo)
if ($fail -gt 0) { exit 1 }
