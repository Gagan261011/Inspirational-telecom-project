# ============================================================================
# TelecomPro - Stop All Services
# ============================================================================

$ErrorActionPreference = "Continue"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

Write-Host ""
Write-Host "========================================" -ForegroundColor Red
Write-Host "  TelecomPro - Stopping All Services"    -ForegroundColor Red
Write-Host "========================================" -ForegroundColor Red
Write-Host ""

$pidFile = Join-Path $ScriptDir ".service-pids"

# Method 1: Kill by saved PIDs
if (Test-Path $pidFile) {
    Write-Host "Found saved process IDs, stopping services..." -ForegroundColor Yellow
    
    $pids = Get-Content $pidFile
    foreach ($line in $pids) {
        if ($line -match "(.+)=(\d+)") {
            $serviceName = $matches[1]
            $procId = [int]$matches[2]
            
            $process = Get-Process -Id $procId -ErrorAction SilentlyContinue
            if ($process) {
                Stop-Process -Id $procId -Force -ErrorAction SilentlyContinue
                Write-Host "  Stopped $serviceName (PID: $procId)" -ForegroundColor Green
            }
        }
    }
    
    Remove-Item $pidFile -Force -ErrorAction SilentlyContinue
}

# Method 2: Kill by port
Write-Host ""
Write-Host "Checking for processes on service ports..." -ForegroundColor Yellow

$servicePorts = @(9080, 8081, 8082, 5173, 5174, 5175)

foreach ($port in $servicePorts) {
    $connections = Get-NetTCPConnection -LocalPort $port -ErrorAction SilentlyContinue
    foreach ($conn in $connections) {
        $procId = $conn.OwningProcess
        if ($procId -and $procId -ne 0) {
            Stop-Process -Id $procId -Force -ErrorAction SilentlyContinue
            Write-Host "  Killed process on port $port - PID: $procId" -ForegroundColor Green
        }
    }
}

# Method 3: Kill Java processes
Write-Host ""
Write-Host "Checking for Java processes..." -ForegroundColor Yellow

$javaProcs = Get-Process -Name "java" -ErrorAction SilentlyContinue
foreach ($proc in $javaProcs) {
    $wmi = Get-CimInstance Win32_Process -Filter "ProcessId = $($proc.Id)" -ErrorAction SilentlyContinue
    if ($wmi -and $wmi.CommandLine -match "telecom|backend|bff-user|bff-order|spring-boot") {
        Stop-Process -Id $proc.Id -Force -ErrorAction SilentlyContinue
        Write-Host "  Stopped Java process (PID: $($proc.Id))" -ForegroundColor Green
    }
}

# Method 4: Kill Node processes
Write-Host ""
Write-Host "Checking for Node.js processes..." -ForegroundColor Yellow

$nodeProcs = Get-Process -Name "node" -ErrorAction SilentlyContinue
foreach ($proc in $nodeProcs) {
    $wmi = Get-CimInstance Win32_Process -Filter "ProcessId = $($proc.Id)" -ErrorAction SilentlyContinue
    if ($wmi -and $wmi.CommandLine -match "vite|frontend|telecom") {
        Stop-Process -Id $proc.Id -Force -ErrorAction SilentlyContinue
        Write-Host "  Stopped Node process (PID: $($proc.Id))" -ForegroundColor Green
    }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "  All services have been stopped!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "  To start services again, run: .\start-all.ps1" -ForegroundColor Cyan
Write-Host ""
