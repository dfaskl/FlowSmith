$Host.UI.RawUI.WindowTitle = "FlowSmith Frontend"

Set-Location $PSScriptRoot

Write-Host "========================================"
Write-Host "  FlowSmith Frontend - port 5173"
Write-Host "========================================"
Write-Host ""

& npm run dev
