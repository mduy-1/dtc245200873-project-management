$ErrorActionPreference = 'Stop'
Set-Location (Split-Path $PSScriptRoot -Parent)
if (-not (Test-Path -LiteralPath '.env')) {
  & "$PSScriptRoot/init.ps1"
}
docker info --format '{{.ServerVersion}}'
if ($LASTEXITCODE -ne 0) { throw 'Docker Engine unavailable. Start or repair Docker Desktop Linux Engine first.' }
docker compose config --quiet
if ($LASTEXITCODE -ne 0) { throw 'Compose configuration invalid.' }
docker compose up -d --build
if ($LASTEXITCODE -ne 0) { throw 'Compose startup failed. Inspect the Docker error above.' }
docker compose ps
Write-Host 'Wait for app health, then run scripts/smoke.ps1. Website: http://localhost:8080'
