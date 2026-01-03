# Import the module to test
Import-Module ./Start-ForegroundProcess/Start-ForegroundProcess.psm1 -Force

Write-Host "=== TEST 1: Output Capture ===" -ForegroundColor Cyan
$cmd = "cmd"
$args = "/c echo HELLO_FROM_PROCESS"

# 1. Start-Process (Default)
Write-Host "1. Testing Start-Process..." -NoNewline
$p1 = Start-Process $cmd -ArgumentList $args -PassThru -Wait -NoNewWindow
if ($p1.StandardOutput) { Write-Host " [Captured]" -ForegroundColor Green } 
else { Write-Host " [Failed to capture directly]" -ForegroundColor Red }

# 2. Start-Job
Write-Host "2. Testing Start-Job..." -NoNewline
$job = Start-Job -ScriptBlock { cmd /c echo HELLO_FROM_JOB }
$null = Wait-Job $job
$jobOutput = Receive-Job $job
if ($jobOutput -match "HELLO_FROM_JOB") { Write-Host " [Captured: '$jobOutput']" -ForegroundColor Green }
else { Write-Host " [Failed]" -ForegroundColor Red }

# 3. Start-ForegroundProcess
Write-Host "3. Testing Start-ForegroundProcess..."
Write-Host "   (Output should appear below)" -ForegroundColor DarkGray
Start-ForegroundProcess -FilePath $cmd -ArgumentList $args -Wait

Write-Host "`n=== TEST 2: Window Focus (Visual Check) ===" -ForegroundColor Cyan
Write-Host "I will now launch Notepad twice."
Write-Host "1. Using Start-Process (Might be in background or behind other windows)"
Start-Process notepad
Start-Sleep -Seconds 2

Write-Host "2. Using Start-ForegroundProcess (Should FORCE to top)"
Start-ForegroundProcess -FilePath notepad

Write-Host "`nTest Complete. Please check which Notepad window is on top." -ForegroundColor Yellow
