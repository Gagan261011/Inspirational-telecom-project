# ============================================================================
# TelecomPro - Start All Services
# ============================================================================
# This script starts all microservices for the TelecomPro platform
# Services: Backend (9080), BFF-User (8081), BFF-Order (8082), Frontend (5173)
# ============================================================================

param(
    [switch]$Dev = $true,
    [switch]$Verbose
)

$ErrorActionPreference = "Continue"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

# Colors for output
function Write-ColorOutput($ForegroundColor) {
    $fc = $host.UI.RawUI.ForegroundColor
    $host.UI.RawUI.ForegroundColor = $ForegroundColor
    if ($args) {
        Write-Output $args
    }
    $host.UI.RawUI.ForegroundColor = $fc
}

function Write-Header {
    Write-Host ""
    Write-Host "╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║            TelecomPro - Enterprise Platform Starter          ║" -ForegroundColor Cyan
    Write-Host "║                Starting All Microservices                    ║" -ForegroundColor Cyan
    Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""
}

function Write-ServiceStatus($ServiceName, $Port, $Status) {
    $statusColor = if ($Status -eq "Starting") { "Yellow" } elseif ($Status -eq "Running") { "Green" } else { "Red" }
    Write-Host "  [$Status] " -ForegroundColor $statusColor -NoNewline
    Write-Host "$ServiceName " -ForegroundColor White -NoNewline
    Write-Host "(Port: $Port)" -ForegroundColor Gray
}

Write-Header

# Check if Maven is available
$mavenAvailable = Get-Command mvn -ErrorAction SilentlyContinue
if (-not $mavenAvailable) {
    Write-Host "ERROR: Maven (mvn) is not installed or not in PATH" -ForegroundColor Red
    Write-Host "Please install Maven and try again." -ForegroundColor Yellow
    exit 1
}

# Check if Node.js is available
$nodeAvailable = Get-Command node -ErrorAction SilentlyContinue
if (-not $nodeAvailable) {
    Write-Host "ERROR: Node.js is not installed or not in PATH" -ForegroundColor Red
    Write-Host "Please install Node.js and try again." -ForegroundColor Yellow
    exit 1
}

Write-Host "Starting services in development mode..." -ForegroundColor Cyan
Write-Host ""

# Create a file to store process IDs
$pidFile = Join-Path $ScriptDir ".service-pids"

# Start Backend Service
Write-ServiceStatus "Backend Service" "9080" "Starting"
$backendPath = Join-Path $ScriptDir "backend"
$backendProcess = Start-Process -FilePath "cmd.exe" -ArgumentList "/c cd /d `"$backendPath`" && mvn spring-boot:run -Dspring-boot.run.profiles=dev" -WindowStyle Minimized -PassThru
$backendPid = $backendProcess.Id
Write-Host "    Backend PID: $backendPid" -ForegroundColor DarkGray

# Wait a bit for backend to start
Start-Sleep -Seconds 5

# Start BFF-User Service
Write-ServiceStatus "BFF-User Service" "8081" "Starting"
$bffUserPath = Join-Path $ScriptDir "bff-user"
$bffUserProcess = Start-Process -FilePath "cmd.exe" -ArgumentList "/c cd /d `"$bffUserPath`" && mvn spring-boot:run -Dspring-boot.run.profiles=dev" -WindowStyle Minimized -PassThru
$bffUserPid = $bffUserProcess.Id
Write-Host "    BFF-User PID: $bffUserPid" -ForegroundColor DarkGray

# Start BFF-Order Service
Write-ServiceStatus "BFF-Order Service" "8082" "Starting"
$bffOrderPath = Join-Path $ScriptDir "bff-order"
$bffOrderProcess = Start-Process -FilePath "cmd.exe" -ArgumentList "/c cd /d `"$bffOrderPath`" && mvn spring-boot:run -Dspring-boot.run.profiles=dev" -WindowStyle Minimized -PassThru
$bffOrderPid = $bffOrderProcess.Id
Write-Host "    BFF-Order PID: $bffOrderPid" -ForegroundColor DarkGray

# Wait a bit for backend services
Start-Sleep -Seconds 3

# Start Frontend
Write-ServiceStatus "Frontend (React)" "5173" "Starting"
$frontendPath = Join-Path $ScriptDir "frontend"
$frontendProcess = Start-Process -FilePath "cmd.exe" -ArgumentList "/c cd /d `"$frontendPath`" && npm run dev" -WindowStyle Minimized -PassThru
$frontendPid = $frontendProcess.Id
Write-Host "    Frontend PID: $frontendPid" -ForegroundColor DarkGray

# Save PIDs to file
@"
backend=$backendPid
bffuser=$bffUserPid
bfforder=$bffOrderPid
frontend=$frontendPid
"@ | Out-File -FilePath $pidFile -Encoding UTF8

Write-Host ""
Write-Host "════════════════════════════════════════════════════════════════" -ForegroundColor Green
Write-Host "  All services are starting!" -ForegroundColor Green
Write-Host "════════════════════════════════════════════════════════════════" -ForegroundColor Green
Write-Host ""
Write-Host "  Services will be available at:" -ForegroundColor White
Write-Host "    • Frontend:      http://localhost:5173" -ForegroundColor Cyan
Write-Host "    • Backend API:   http://localhost:9080" -ForegroundColor Cyan
Write-Host "    • BFF-User API:  http://localhost:8081" -ForegroundColor Cyan
Write-Host "    • BFF-Order API: http://localhost:8082" -ForegroundColor Cyan
Write-Host ""
Write-Host "  Additional endpoints:" -ForegroundColor White
Write-Host "    • Swagger UI:    http://localhost:9080/swagger-ui.html" -ForegroundColor Gray
Write-Host "    • GraphQL:       http://localhost:9080/graphiql" -ForegroundColor Gray
Write-Host "    • H2 Console:    http://localhost:9080/h2-console" -ForegroundColor Gray
Write-Host ""
Write-Host "  Demo credentials:" -ForegroundColor White
Write-Host "    • demo@telecom.com / demo123" -ForegroundColor Yellow
Write-Host "    • admin@telecom.com / admin123" -ForegroundColor Yellow
Write-Host ""
Write-Host "  To stop all services, run: .\stop-all.ps1" -ForegroundColor Magenta
Write-Host ""

# Wait for services to be ready
Write-Host "Waiting for services to be ready..." -ForegroundColor Yellow
Start-Sleep -Seconds 10

# Check if services are responding
Write-Host ""
Write-Host "Checking service health..." -ForegroundColor Cyan

try {
    $backendHealth = Invoke-WebRequest -Uri "http://localhost:9080/actuator/health" -TimeoutSec 5 -ErrorAction SilentlyContinue
    if ($backendHealth.StatusCode -eq 200) {
        Write-Host "  ✓ Backend is healthy" -ForegroundColor Green
    }
} catch {
    Write-Host "  ⏳ Backend is still starting..." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Services started! Check individual windows for logs." -ForegroundColor Green
Write-Host "Press any key to exit this script (services will continue running)..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
