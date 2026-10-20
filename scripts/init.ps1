$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent
$target = Join-Path $root '.env'
if (Test-Path -LiteralPath $target) { throw '.env already exists. Keep existing passwords for initialized database volumes.' }
function New-Password { $b = New-Object byte[] 32; [System.Security.Cryptography.RandomNumberGenerator]::Create().GetBytes($b); return ([BitConverter]::ToString($b)).Replace('-','').ToLower() }
$lines = @(
  ('POSTGRES_PASSWORD='+(New-Password))
  ('APP_DB_PASSWORD='+(New-Password))
  ('MONITOR_DB_PASSWORD='+(New-Password))
  ('PGADMIN_PASSWORD='+(New-Password))
  ('GRAFANA_PASSWORD='+(New-Password))
  'PGADMIN_EMAIL=student@example.com'
)
[IO.File]::WriteAllLines($target,$lines,[Text.UTF8Encoding]::new($false))
Write-Host 'Created .env with random passwords. Do not commit this file.'
