param(
  [string]$Distribution = 'Ubuntu-24.04',
  [string]$ProjectPath = '/home/dtc245200873/project-management'
)
$ErrorActionPreference = 'Stop'
$workspace = Split-Path $PSScriptRoot -Parent
$localDir = Join-Path $workspace '.local'
New-Item -ItemType Directory -Force -Path $localDir | Out-Null
$pidPath = Join-Path $localDir 'wsl-keeper.pid'
$existing = $null
if (Test-Path -LiteralPath $pidPath) {
  $savedPid = [IO.File]::ReadAllText($pidPath).Trim()
  if ($savedPid -match '^\d+$') {
    $existing = Get-CimInstance Win32_Process -Filter "ProcessId=$savedPid" -ErrorAction SilentlyContinue
    if ($existing -and ($existing.Name -ne 'wsl.exe' -or $existing.CommandLine -notlike '*sleep infinity*' -or $existing.CommandLine -notlike "*$Distribution*")) { $existing = $null }
  }
}
if (-not $existing) {
  $keeper = Start-Process -FilePath 'wsl.exe' -ArgumentList @('-d',$Distribution,'-u','dtc245200873','--exec','sleep','infinity') -WindowStyle Hidden -PassThru
  [IO.File]::WriteAllText($pidPath,[string]$keeper.Id)
}
wsl -d $Distribution -u root --exec systemctl start docker
if ($LASTEXITCODE -ne 0) { throw 'Cannot start Docker in Ubuntu.' }
wsl -d $Distribution -u dtc245200873 --cd $ProjectPath --exec docker compose up -d --no-build --pull never
if ($LASTEXITCODE -ne 0) { throw 'Cannot start the existing Ubuntu deployment.' }
wsl -d $Distribution -u dtc245200873 --cd $ProjectPath --exec docker compose ps
Write-Host 'Ubuntu deployment started. Website: http://localhost:8080'
