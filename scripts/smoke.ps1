$ErrorActionPreference = 'Stop'
$base = 'http://localhost:8080'
$health = Invoke-RestMethod "$base/health"
if ($health.database -ne 'connected') { throw 'DB chưa sẵn sàng' }
$stamp = [DateTimeOffset]::UtcNow.ToUnixTimeMilliseconds()
$p = Invoke-RestMethod "$base/api/projects" -Method Post -ContentType 'application/json' -Body (@{name="Smoke $stamp"; description='API validation'} | ConvertTo-Json)
$m = Invoke-RestMethod "$base/api/members" -Method Post -ContentType 'application/json' -Body (@{name='Smoke member'; email="smoke$stamp@example.com"} | ConvertTo-Json)
$t = Invoke-RestMethod "$base/api/tasks" -Method Post -ContentType 'application/json' -Body (@{title='Smoke task'; project_id=$p.id; member_id=$m.id} | ConvertTo-Json)
$updated = Invoke-RestMethod "$base/api/tasks/$($t.id)" -Method Patch -ContentType 'application/json' -Body '{"status":"done"}'
if ($updated.status -ne 'done') { throw 'Cập nhật task thất bại' }
$data = Invoke-RestMethod "$base/api/data"
if (-not ($data.tasks | Where-Object { $_.id -eq $t.id -and $_.status -eq 'done' })) { throw 'Dữ liệu chưa được lưu' }
$response = Invoke-WebRequest $base -UseBasicParsing
foreach ($header in @('X-Content-Type-Options','X-Frame-Options','Content-Security-Policy')) { if (-not $response.Headers[$header]) { throw "Thiếu $header" } }
Write-Host 'PASS: DB, tạo dự án/thành viên/task, cập nhật, đọc lại và security headers. Dữ liệu Smoke được giữ lại để kiểm tra trong pgAdmin.'
