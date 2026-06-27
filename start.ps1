Write-Host "========================================"
Write-Host "  FlowSmith - Start"
Write-Host "========================================"
Write-Host ""

$root = Split-Path -Parent $MyInvocation.MyCommand.Path

# Backend
Write-Host "[1/2] Starting backend (port 8084) ..."
Start-Process powershell -ArgumentList "-NoExit", "-File", "$root\backend\start-backend.ps1"

Start-Sleep -Seconds 3

# Frontend
Write-Host "[2/2] Starting frontend (port 5173) ..."
Start-Process powershell -ArgumentList "-NoExit", "-File", "$root\frontend\start-frontend.ps1"

Write-Host ""
Write-Host "Services started in separate windows:"
Write-Host "  Backend  http://localhost:8084"
Write-Host "  Frontend http://localhost:5173"
Write-Host ""
Write-Host "Press any key to exit ..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
