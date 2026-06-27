$Host.UI.RawUI.WindowTitle = "FlowSmith Backend"
$env:JAVA_HOME = "C:\Program Files\Java\jdk-21"
$env:PATH = "$env:JAVA_HOME\bin;$env:PATH"

Set-Location $PSScriptRoot

Write-Host "========================================"
Write-Host "  FlowSmith Backend - port 8084"
Write-Host "  JAVA_HOME = $env:JAVA_HOME"
Write-Host "========================================"
Write-Host ""

& .\mvnw.cmd spring-boot:run
