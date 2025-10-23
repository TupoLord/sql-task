
param(
  [string]$Db = "postgres://postgres:postgres@localhost:5432/testdb"
)

$ErrorActionPreference = "Stop"

$composeFile = Join-Path $PSScriptRoot "docker-compose.yml"
$repoRoot    = Split-Path $PSScriptRoot -Parent

function Ensure-DbContainer {
  $cid = (docker compose -f $composeFile ps -q db).Trim()
  if (-not $cid) {
    Write-Host "[i] starting postgres container..."
    docker compose -f $composeFile up -d | Out-Null
    Start-Sleep -Seconds 2
    $cid = (docker compose -f $composeFile ps -q db).Trim()
  }
  if (-not $cid) { throw "DB container is not running. Start Docker Desktop and try again." }
  return $cid
}

function Exec-InContainer {
  param([string]$cid, [string]$cmd)
  docker exec $cid bash -lc $cmd
}

function ApplySql-InContainer {
  param([string]$cid, [string]$sqlPath, [string]$remoteName)
  $remote = "/tmp/$remoteName"
  docker cp $sqlPath "${cid}:$remote" | Out-Null
  Exec-InContainer $cid "psql -U postgres -d testdb -v ON_ERROR_STOP=1 -f $remote"
}

function RunQuery-ToFile {
  param([string]$cid, [string]$sqlPath, [string]$remoteBase, [string]$outPath)
  $remoteSql = "/tmp/$remoteBase.sql"
  $remoteTxt = "/tmp/$remoteBase.txt"
  docker cp $sqlPath "${cid}:$remoteSql" | Out-Null
  Exec-InContainer $cid "psql -U postgres -d testdb -P pager=off -f $remoteSql -o $remoteTxt"
  docker cp "${cid}:$remoteTxt" $outPath | Out-Null
}

$cid = Ensure-DbContainer

Write-Host "[i] resetting schema..."
Exec-InContainer $cid "psql -U postgres -d testdb -c ""DROP SCHEMA public CASCADE; CREATE SCHEMA public;"""

Write-Host "[i] applying schema..."
ApplySql-InContainer $cid (Join-Path $repoRoot "schema\001_init.sql")  "001.sql"
ApplySql-InContainer $cid (Join-Path $repoRoot "schema\002_sample_data.sql") "002.sql"

Write-Host "[i] running queries..."
RunQuery-ToFile $cid (Join-Path $repoRoot "queries\01_client_sums.sql")       "q1" (Join-Path $repoRoot "q1.txt")
RunQuery-ToFile $cid (Join-Path $repoRoot "queries\02_category_children.sql") "q2" (Join-Path $repoRoot "q2.txt")
RunQuery-ToFile $cid (Join-Path $repoRoot "queries\03_category_path_cte.sql") "q3" (Join-Path $repoRoot "q3.txt")

Write-Host "[ok] done."
Write-Host "Results:"
Write-Host "  $(Join-Path $repoRoot "q1.txt")"
Write-Host "  $(Join-Path $repoRoot "q2.txt")"
Write-Host "  $(Join-Path $repoRoot "q3.txt")"
