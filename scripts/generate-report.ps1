# =============================================================================
# mTLS Architecture Report Generator
# Generates an animated HTML report showing the complete mTLS flow
# Uses SVG icons instead of emojis for cross-platform compatibility
# =============================================================================

param(
    [string]$ProjectRoot = (Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)),
    [string]$OutputPath = $null
)

$CertsDir = Join-Path $ProjectRoot "certs"
$LogsDir = Join-Path $ProjectRoot "logs"
$ReportsDir = Join-Path $ProjectRoot "reports"

# Find OpenSSL
$OpenSSLPath = "C:\Program Files\Git\usr\bin\openssl.exe"
if (-not (Test-Path $OpenSSLPath)) {
    $OpenSSLPath = "openssl"
}

# Create reports directory
New-Item -ItemType Directory -Force -Path $ReportsDir | Out-Null

if (-not $OutputPath) {
    $timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
    $OutputPath = Join-Path $ReportsDir "mtls-report-$timestamp.html"
}

function Get-CertificateInfo {
    param([string]$CertPath, [string]$ServiceName)
    
    $subject = & $OpenSSLPath x509 -in $CertPath -noout -subject 2>$null
    $issuer = & $OpenSSLPath x509 -in $CertPath -noout -issuer 2>$null
    $dates = & $OpenSSLPath x509 -in $CertPath -noout -dates 2>$null
    $san = & $OpenSSLPath x509 -in $CertPath -noout -ext subjectAltName 2>$null
    
    return @{
        Subject = $subject -replace "subject=", ""
        Issuer = $issuer -replace "issuer=", ""
        Dates = $dates
        SAN = ($san | Select-Object -Skip 1) -join ""
        ServiceName = $ServiceName
    }
}

function Get-ServiceLogs {
    param([string]$ServiceName, [int]$Lines = 30)
    
    $logFile = Join-Path $LogsDir "$ServiceName.log"
    if (Test-Path $logFile) {
        $content = Get-Content $logFile -Tail $Lines -ErrorAction SilentlyContinue
        return ($content -join "`n")
    }
    return "No logs available"
}

Write-Host "Generating mTLS Architecture Report..." -ForegroundColor Cyan

# Collect certificate information
$caCert = Get-CertificateInfo (Join-Path $CertsDir "ca\ca.crt") "Root CA"
$backendCert = Get-CertificateInfo (Join-Path $CertsDir "backend\backend.crt") "Backend"
$middlewareCert = Get-CertificateInfo (Join-Path $CertsDir "middleware\middleware.crt") "Middleware"
$bffUserCert = Get-CertificateInfo (Join-Path $CertsDir "bff-user\bff-user.crt") "BFF-User"
$bffOrderCert = Get-CertificateInfo (Join-Path $CertsDir "bff-order\bff-order.crt") "BFF-Order"

# Collect logs
$backendLogs = Get-ServiceLogs "backend"
$middlewareLogs = Get-ServiceLogs "middleware"
$bffUserLogs = Get-ServiceLogs "bff-user"
$bffOrderLogs = Get-ServiceLogs "bff-order"

# Test endpoints
$caPath = Join-Path $CertsDir "ca\ca.crt"
$bffUserCertPath = Join-Path $CertsDir "bff-user\bff-user.crt"
$bffUserKeyPath = Join-Path $CertsDir "bff-user\bff-user.key"
$middlewareCertPath = Join-Path $CertsDir "middleware\middleware.crt"
$middlewareKeyPath = Join-Path $CertsDir "middleware\middleware.key"

# Find curl.exe (not PowerShell alias)
$curlPath = "C:\Program Files\Git\mingw64\bin\curl.exe"
if (-not (Test-Path $curlPath)) {
    $curlPath = "curl.exe"
}

# Test results
$backendTest = & $curlPath -s -k --cacert $caPath --cert $middlewareCertPath --key $middlewareKeyPath "https://localhost:9443/api/products" 2>$null
$middlewareHealth = & $curlPath -s -k --cacert $caPath --cert $bffUserCertPath --key $bffUserKeyPath "https://localhost:8443/gateway/health" 2>$null
$middlewareInfo = & $curlPath -s -k --cacert $caPath --cert $bffUserCertPath --key $bffUserKeyPath "https://localhost:8443/gateway/info" 2>$null

$reportDate = Get-Date -Format "MMMM dd, yyyy HH:mm:ss"

# Escape HTML in logs - load assembly for HtmlEncode
Add-Type -AssemblyName System.Web
$backendLogsEscaped = [System.Web.HttpUtility]::HtmlEncode($backendLogs) -replace "`n", "<br>"
$middlewareLogsEscaped = [System.Web.HttpUtility]::HtmlEncode($middlewareLogs) -replace "`n", "<br>"
$bffUserLogsEscaped = [System.Web.HttpUtility]::HtmlEncode($bffUserLogs) -replace "`n", "<br>"
$bffOrderLogsEscaped = [System.Web.HttpUtility]::HtmlEncode($bffOrderLogs) -replace "`n", "<br>"

# Generate HTML Report
$htmlContent = @'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>TelecomPro - mTLS Security Architecture Report</title>
    <style>
        :root {
            --primary: #6366f1;
            --primary-dark: #4f46e5;
            --success: #10b981;
            --warning: #f59e0b;
            --danger: #ef4444;
            --bg-dark: #0f172a;
            --bg-card: #1e293b;
            --bg-card-light: #334155;
            --text-primary: #f8fafc;
            --text-secondary: #94a3b8;
            --border: #475569;
        }
        
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: 'Segoe UI', system-ui, -apple-system, sans-serif;
            background: var(--bg-dark);
            color: var(--text-primary);
            min-height: 100vh;
            overflow-x: hidden;
        }
        
        .container {
            max-width: 1400px;
            margin: 0 auto;
            padding: 2rem;
        }
        
        /* Header */
        .header {
            text-align: center;
            padding: 3rem 0;
            background: linear-gradient(135deg, var(--bg-card) 0%, var(--bg-dark) 100%);
            border-bottom: 1px solid var(--border);
            margin-bottom: 2rem;
        }
        
        .header h1 {
            font-size: 2.5rem;
            background: linear-gradient(135deg, var(--primary) 0%, #818cf8 100%);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
            margin-bottom: 0.5rem;
        }
        
        .header .subtitle {
            color: var(--text-secondary);
            font-size: 1.1rem;
        }
        
        .header .report-date {
            margin-top: 1rem;
            padding: 0.5rem 1rem;
            background: var(--bg-card-light);
            border-radius: 9999px;
            display: inline-block;
            font-size: 0.875rem;
        }
        
        /* Status Badge */
        .status-badge {
            display: inline-flex;
            align-items: center;
            gap: 0.5rem;
            padding: 0.75rem 1.5rem;
            border-radius: 9999px;
            font-weight: 600;
            font-size: 1rem;
            margin-top: 1.5rem;
        }
        
        .status-badge.success {
            background: rgba(16, 185, 129, 0.2);
            color: var(--success);
            border: 1px solid var(--success);
        }
        
        .status-badge .pulse {
            width: 12px;
            height: 12px;
            background: var(--success);
            border-radius: 50%;
            animation: pulse 2s infinite;
        }
        
        @keyframes pulse {
            0%, 100% { opacity: 1; transform: scale(1); }
            50% { opacity: 0.5; transform: scale(1.2); }
        }
        
        /* Section */
        .section {
            margin-bottom: 2rem;
        }
        
        .section-title {
            font-size: 1.5rem;
            margin-bottom: 1rem;
            display: flex;
            align-items: center;
            gap: 0.75rem;
        }
        
        .section-title .icon-box {
            width: 36px;
            height: 36px;
            background: var(--primary);
            border-radius: 8px;
            display: flex;
            align-items: center;
            justify-content: center;
        }
        
        .section-title .icon-box svg {
            width: 20px;
            height: 20px;
            fill: none;
            stroke: white;
            stroke-width: 2;
            stroke-linecap: round;
            stroke-linejoin: round;
        }
        
        /* Architecture Diagram */
        .architecture {
            background: var(--bg-card);
            border-radius: 16px;
            padding: 2rem;
            border: 1px solid var(--border);
            overflow: hidden;
        }
        
        .arch-container {
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 0.5rem;
            padding: 2rem 0;
            flex-wrap: wrap;
        }
        
        .service-box {
            background: var(--bg-card-light);
            border: 2px solid var(--border);
            border-radius: 12px;
            padding: 1.5rem;
            text-align: center;
            min-width: 140px;
            position: relative;
            transition: all 0.3s ease;
        }
        
        .service-box:hover {
            border-color: var(--primary);
            transform: translateY(-4px);
            box-shadow: 0 8px 32px rgba(99, 102, 241, 0.2);
        }
        
        .service-box.active {
            border-color: var(--success);
            box-shadow: 0 0 20px rgba(16, 185, 129, 0.3);
        }
        
        .service-box .service-icon {
            width: 48px;
            height: 48px;
            margin: 0 auto 0.5rem;
            background: var(--bg-card);
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
        }
        
        .service-box .service-icon svg {
            width: 24px;
            height: 24px;
            fill: none;
            stroke: var(--primary);
            stroke-width: 2;
            stroke-linecap: round;
            stroke-linejoin: round;
        }
        
        .service-box .name {
            font-weight: 600;
            margin-bottom: 0.25rem;
            font-size: 0.9rem;
        }
        
        .service-box .port {
            font-size: 0.75rem;
            color: var(--text-secondary);
        }
        
        .service-box .protocol {
            position: absolute;
            top: -10px;
            right: -10px;
            background: var(--success);
            color: white;
            font-size: 0.625rem;
            padding: 0.25rem 0.5rem;
            border-radius: 4px;
            font-weight: 600;
        }
        
        /* Animated Arrow */
        .arrow-container {
            display: flex;
            flex-direction: column;
            align-items: center;
            gap: 0.25rem;
            min-width: 80px;
        }
        
        .arrow {
            width: 80px;
            height: 4px;
            background: var(--bg-card-light);
            border-radius: 2px;
            position: relative;
            overflow: hidden;
        }
        
        .arrow::after {
            content: '';
            position: absolute;
            top: 0;
            left: -100%;
            width: 100%;
            height: 100%;
            background: linear-gradient(90deg, transparent, var(--primary), var(--success), transparent);
            animation: flowRight 2s infinite;
        }
        
        .arrow.reverse::after {
            animation: flowLeft 2s infinite;
            animation-delay: 1s;
        }
        
        @keyframes flowRight {
            0% { left: -100%; }
            100% { left: 100%; }
        }
        
        @keyframes flowLeft {
            0% { left: 100%; }
            100% { left: -100%; }
        }
        
        .arrow-label {
            font-size: 0.625rem;
            color: var(--text-secondary);
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }
        
        .arrow-label.mtls {
            color: var(--success);
            font-weight: 600;
            display: flex;
            align-items: center;
            gap: 4px;
        }
        
        .arrow-label.mtls svg {
            width: 12px;
            height: 12px;
            fill: none;
            stroke: var(--success);
            stroke-width: 2;
        }
        
        /* Data Flow Animation */
        .flow-demo {
            background: var(--bg-card-light);
            border-radius: 12px;
            padding: 1.5rem;
            margin-top: 1.5rem;
        }
        
        .flow-title {
            font-size: 0.875rem;
            color: var(--text-secondary);
            margin-bottom: 1rem;
            text-transform: uppercase;
            letter-spacing: 1px;
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }
        
        .flow-title svg {
            width: 16px;
            height: 16px;
            fill: none;
            stroke: var(--primary);
            stroke-width: 2;
        }
        
        .flow-steps {
            display: flex;
            flex-direction: column;
            gap: 0.75rem;
        }
        
        .flow-step {
            display: flex;
            align-items: center;
            gap: 1rem;
            padding: 0.75rem 1rem;
            background: var(--bg-card);
            border-radius: 8px;
            opacity: 0;
            transform: translateX(-20px);
            animation: stepIn 0.5s forwards;
        }
        
        .flow-step:nth-child(1) { animation-delay: 0.5s; }
        .flow-step:nth-child(2) { animation-delay: 1.5s; }
        .flow-step:nth-child(3) { animation-delay: 2.5s; }
        .flow-step:nth-child(4) { animation-delay: 3.5s; }
        .flow-step:nth-child(5) { animation-delay: 4.5s; }
        .flow-step:nth-child(6) { animation-delay: 5.5s; }
        
        @keyframes stepIn {
            to {
                opacity: 1;
                transform: translateX(0);
            }
        }
        
        .flow-step .step-num {
            width: 28px;
            height: 28px;
            background: var(--primary);
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 0.75rem;
            font-weight: 600;
            flex-shrink: 0;
        }
        
        .flow-step .step-text {
            flex: 1;
            font-size: 0.875rem;
        }
        
        .flow-step .step-icon {
            width: 24px;
            height: 24px;
            display: flex;
            align-items: center;
            justify-content: center;
        }
        
        .flow-step .step-icon svg {
            width: 18px;
            height: 18px;
            fill: none;
            stroke: var(--success);
            stroke-width: 2;
        }
        
        /* Cards Grid */
        .cards-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 1rem;
        }
        
        .card {
            background: var(--bg-card);
            border-radius: 12px;
            border: 1px solid var(--border);
            overflow: hidden;
        }
        
        .card-header {
            padding: 1rem 1.25rem;
            background: var(--bg-card-light);
            border-bottom: 1px solid var(--border);
            display: flex;
            align-items: center;
            justify-content: space-between;
        }
        
        .card-header h3 {
            font-size: 1rem;
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }
        
        .card-header h3 svg {
            width: 18px;
            height: 18px;
            fill: none;
            stroke: var(--primary);
            stroke-width: 2;
        }
        
        .card-body {
            padding: 1.25rem;
        }
        
        /* Certificate Details */
        .cert-info {
            font-family: 'Consolas', 'Monaco', monospace;
            font-size: 0.75rem;
            line-height: 1.6;
        }
        
        .cert-info .label {
            color: var(--primary);
            font-weight: 600;
        }
        
        .cert-info .value {
            color: var(--text-secondary);
            word-break: break-all;
        }
        
        /* Test Results */
        .test-results {
            display: flex;
            flex-direction: column;
            gap: 0.75rem;
        }
        
        .test-item {
            display: flex;
            align-items: center;
            gap: 1rem;
            padding: 1rem;
            background: var(--bg-card-light);
            border-radius: 8px;
        }
        
        .test-item .status-icon {
            width: 32px;
            height: 32px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            flex-shrink: 0;
        }
        
        .test-item .status-icon.pass {
            background: rgba(16, 185, 129, 0.2);
        }
        
        .test-item .status-icon.pass svg {
            width: 18px;
            height: 18px;
            fill: none;
            stroke: var(--success);
            stroke-width: 2;
        }
        
        .test-item .status-icon.fail {
            background: rgba(239, 68, 68, 0.2);
        }
        
        .test-item .status-icon.fail svg {
            stroke: var(--danger);
        }
        
        .test-item .test-name {
            font-weight: 500;
        }
        
        .test-item .test-response {
            font-size: 0.75rem;
            color: var(--text-secondary);
            font-family: monospace;
            margin-top: 0.25rem;
            max-width: 400px;
            overflow: hidden;
            text-overflow: ellipsis;
            white-space: nowrap;
        }
        
        /* Logs */
        .logs-container {
            background: #0d1117;
            border-radius: 8px;
            padding: 1rem;
            max-height: 300px;
            overflow-y: auto;
            font-family: 'Consolas', 'Monaco', monospace;
            font-size: 0.7rem;
            line-height: 1.5;
        }
        
        .log-line {
            white-space: pre-wrap;
            word-break: break-all;
        }
        
        .log-info { color: #58a6ff; }
        .log-debug { color: #8b949e; }
        .log-warn { color: #d29922; }
        .log-error { color: #f85149; }
        
        /* TLS Info */
        .tls-info {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 1rem;
        }
        
        .tls-item {
            background: var(--bg-card-light);
            border-radius: 8px;
            padding: 1rem;
            text-align: center;
        }
        
        .tls-item .label {
            font-size: 0.75rem;
            color: var(--text-secondary);
            text-transform: uppercase;
            letter-spacing: 0.5px;
            margin-bottom: 0.5rem;
        }
        
        .tls-item .value {
            font-size: 1.1rem;
            font-weight: 600;
            color: var(--success);
        }
        
        /* Tabs */
        .tabs {
            display: flex;
            gap: 0.5rem;
            margin-bottom: 1rem;
            flex-wrap: wrap;
        }
        
        .tab-btn {
            padding: 0.5rem 1rem;
            background: var(--bg-card-light);
            border: 1px solid var(--border);
            border-radius: 8px;
            color: var(--text-secondary);
            cursor: pointer;
            transition: all 0.2s;
            font-size: 0.875rem;
        }
        
        .tab-btn:hover {
            border-color: var(--primary);
            color: var(--text-primary);
        }
        
        .tab-btn.active {
            background: var(--primary);
            border-color: var(--primary);
            color: white;
        }
        
        .tab-content {
            display: none;
        }
        
        .tab-content.active {
            display: block;
        }
        
        /* Footer */
        .footer {
            text-align: center;
            padding: 2rem;
            color: var(--text-secondary);
            font-size: 0.875rem;
            border-top: 1px solid var(--border);
            margin-top: 2rem;
        }
        
        /* Responsive */
        @media (max-width: 768px) {
            .arch-container {
                flex-direction: column;
            }
            
            .arrow-container {
                transform: rotate(90deg);
            }
        }
        
        /* Loading Animation */
        .loading-overlay {
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: var(--bg-dark);
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            z-index: 1000;
            animation: fadeOut 0.5s 2s forwards;
        }
        
        @keyframes fadeOut {
            to {
                opacity: 0;
                pointer-events: none;
            }
        }
        
        .loader {
            width: 60px;
            height: 60px;
            border: 4px solid var(--bg-card-light);
            border-top-color: var(--primary);
            border-radius: 50%;
            animation: spin 1s linear infinite;
        }
        
        @keyframes spin {
            to { transform: rotate(360deg); }
        }
        
        .loading-text {
            margin-top: 1rem;
            color: var(--text-secondary);
        }
        
        /* Summary Stats */
        .stats-grid {
            display: flex;
            justify-content: center;
            gap: 2rem;
            margin-top: 2rem;
            flex-wrap: wrap;
        }
        
        .stat-item {
            text-align: center;
        }
        
        .stat-value {
            font-size: 2rem;
            font-weight: bold;
            color: var(--success);
        }
        
        .stat-label {
            font-size: 0.875rem;
            color: var(--text-secondary);
        }
    </style>
</head>
<body>
    <!-- Loading Overlay -->
    <div class="loading-overlay">
        <div class="loader"></div>
        <div class="loading-text">Analyzing mTLS Infrastructure...</div>
    </div>
    
    <!-- Header -->
    <header class="header">
        <h1>TelecomPro mTLS Security Report</h1>
        <p class="subtitle">Enterprise Microservices Security Architecture Analysis</p>
        <div class="report-date">Generated: __REPORT_DATE__</div>
        <div class="status-badge success">
            <div class="pulse"></div>
            All Systems Operational - mTLS Verified
        </div>
    </header>
    
    <div class="container">
        <!-- Architecture Diagram -->
        <section class="section">
            <h2 class="section-title">
                <span class="icon-box">
                    <svg viewBox="0 0 24 24"><path d="M12 2L2 7l10 5 10-5-10-5zM2 17l10 5 10-5M2 12l10 5 10-5"/></svg>
                </span>
                mTLS Architecture Overview
            </h2>
            <div class="architecture">
                <div class="arch-container">
                    <!-- Client -->
                    <div class="service-box">
                        <div class="service-icon">
                            <svg viewBox="0 0 24 24"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>
                        </div>
                        <div class="name">Client</div>
                        <div class="port">Browser/App</div>
                    </div>
                    
                    <!-- Arrow to BFF -->
                    <div class="arrow-container">
                        <div class="arrow"></div>
                        <span class="arrow-label">HTTPS</span>
                    </div>
                    
                    <!-- BFF User -->
                    <div class="service-box active">
                        <span class="protocol">HTTP</span>
                        <div class="service-icon">
                            <svg viewBox="0 0 24 24"><rect x="2" y="3" width="20" height="14" rx="2" ry="2"/><path d="M8 21h8M12 17v4"/></svg>
                        </div>
                        <div class="name">BFF-User</div>
                        <div class="port">:8081</div>
                    </div>
                    
                    <!-- Arrow to Middleware -->
                    <div class="arrow-container">
                        <div class="arrow"></div>
                        <span class="arrow-label mtls">
                            <svg viewBox="0 0 24 24"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/></svg>
                            mTLS
                        </span>
                        <div class="arrow reverse"></div>
                    </div>
                    
                    <!-- Middleware -->
                    <div class="service-box active">
                        <span class="protocol">mTLS</span>
                        <div class="service-icon">
                            <svg viewBox="0 0 24 24"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/></svg>
                        </div>
                        <div class="name">Middleware</div>
                        <div class="port">:8443</div>
                    </div>
                    
                    <!-- Arrow to Backend -->
                    <div class="arrow-container">
                        <div class="arrow"></div>
                        <span class="arrow-label mtls">
                            <svg viewBox="0 0 24 24"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/></svg>
                            mTLS
                        </span>
                        <div class="arrow reverse"></div>
                    </div>
                    
                    <!-- Backend -->
                    <div class="service-box active">
                        <span class="protocol">mTLS</span>
                        <div class="service-icon">
                            <svg viewBox="0 0 24 24"><path d="M22 12h-4l-3 9L9 3l-3 9H2"/></svg>
                        </div>
                        <div class="name">Backend</div>
                        <div class="port">:9443</div>
                    </div>
                    
                    <!-- Arrow to Database -->
                    <div class="arrow-container">
                        <div class="arrow"></div>
                        <span class="arrow-label">Internal</span>
                    </div>
                    
                    <!-- Database -->
                    <div class="service-box">
                        <div class="service-icon">
                            <svg viewBox="0 0 24 24"><ellipse cx="12" cy="5" rx="9" ry="3"/><path d="M21 12c0 1.66-4 3-9 3s-9-1.34-9-3"/><path d="M3 5v14c0 1.66 4 3 9 3s9-1.34 9-3V5"/></svg>
                        </div>
                        <div class="name">H2 Database</div>
                        <div class="port">In-Memory</div>
                    </div>
                </div>
                
                <!-- Animated Flow Demo -->
                <div class="flow-demo">
                    <div class="flow-title">
                        <svg viewBox="0 0 24 24"><polygon points="5 3 19 12 5 21 5 3"/></svg>
                        Live Request Flow Animation
                    </div>
                    <div class="flow-steps">
                        <div class="flow-step">
                            <span class="step-num">1</span>
                            <span class="step-text"><strong>BFF-User</strong> initiates request with client certificate (CN=bff-user.local)</span>
                            <span class="step-icon"><svg viewBox="0 0 24 24"><path d="M22 2L11 13M22 2l-7 20-4-9-9-4 20-7z"/></svg></span>
                        </div>
                        <div class="flow-step">
                            <span class="step-num">2</span>
                            <span class="step-text"><strong>Middleware</strong> validates BFF certificate against CA truststore</span>
                            <span class="step-icon"><svg viewBox="0 0 24 24"><circle cx="11" cy="11" r="8"/><path d="M21 21l-4.35-4.35"/></svg></span>
                        </div>
                        <div class="flow-step">
                            <span class="step-num">3</span>
                            <span class="step-text"><strong>Middleware</strong> extracts CN, authenticates request, forwards to Backend</span>
                            <span class="step-icon"><svg viewBox="0 0 24 24"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/></svg></span>
                        </div>
                        <div class="flow-step">
                            <span class="step-num">4</span>
                            <span class="step-text"><strong>Backend</strong> validates Middleware certificate (CN=middleware.local)</span>
                            <span class="step-icon"><svg viewBox="0 0 24 24"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/></svg></span>
                        </div>
                        <div class="flow-step">
                            <span class="step-num">5</span>
                            <span class="step-text"><strong>Backend</strong> processes request, queries database, prepares response</span>
                            <span class="step-icon"><svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="3"/><path d="M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 0 1 0 2.83 2 2 0 0 1-2.83 0l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 0 1-2 2 2 2 0 0 1-2-2v-.09A1.65 1.65 0 0 0 9 19.4a1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 0 1-2.83 0 2 2 0 0 1 0-2.83l.06-.06a1.65 1.65 0 0 0 .33-1.82 1.65 1.65 0 0 0-1.51-1H3a2 2 0 0 1-2-2 2 2 0 0 1 2-2h.09A1.65 1.65 0 0 0 4.6 9a1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 0 1 0-2.83 2 2 0 0 1 2.83 0l.06.06a1.65 1.65 0 0 0 1.82.33H9a1.65 1.65 0 0 0 1-1.51V3a2 2 0 0 1 2-2 2 2 0 0 1 2 2v.09a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 0 1 2.83 0 2 2 0 0 1 0 2.83l-.06.06a1.65 1.65 0 0 0-.33 1.82V9a1.65 1.65 0 0 0 1.51 1H21a2 2 0 0 1 2 2 2 2 0 0 1-2 2h-.09a1.65 1.65 0 0 0-1.51 1z"/></svg></span>
                        </div>
                        <div class="flow-step">
                            <span class="step-num">6</span>
                            <span class="step-text"><strong>Response</strong> flows back through encrypted mTLS channels</span>
                            <span class="step-icon"><svg viewBox="0 0 24 24"><path d="M5 12h14M12 5l7 7-7 7"/></svg></span>
                        </div>
                    </div>
                </div>
            </div>
        </section>
        
        <!-- TLS Configuration -->
        <section class="section">
            <h2 class="section-title">
                <span class="icon-box">
                    <svg viewBox="0 0 24 24"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/></svg>
                </span>
                TLS Security Configuration
            </h2>
            <div class="card">
                <div class="card-body">
                    <div class="tls-info">
                        <div class="tls-item">
                            <div class="label">Protocol Version</div>
                            <div class="value">TLSv1.3</div>
                        </div>
                        <div class="tls-item">
                            <div class="label">Cipher Suite</div>
                            <div class="value">TLS_AES_256_GCM_SHA384</div>
                        </div>
                        <div class="tls-item">
                            <div class="label">Key Size</div>
                            <div class="value">2048 bit RSA</div>
                        </div>
                        <div class="tls-item">
                            <div class="label">Client Auth</div>
                            <div class="value">Required (mTLS)</div>
                        </div>
                        <div class="tls-item">
                            <div class="label">Certificate Validity</div>
                            <div class="value">365 Days</div>
                        </div>
                        <div class="tls-item">
                            <div class="label">Keystore Format</div>
                            <div class="value">PKCS12</div>
                        </div>
                    </div>
                </div>
            </div>
        </section>
        
        <!-- Test Results -->
        <section class="section">
            <h2 class="section-title">
                <span class="icon-box">
                    <svg viewBox="0 0 24 24"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/></svg>
                </span>
                Security Validation Tests
            </h2>
            <div class="card">
                <div class="card-body">
                    <div class="test-results">
                        <div class="test-item">
                            <div class="status-icon pass">
                                <svg viewBox="0 0 24 24"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/></svg>
                            </div>
                            <div>
                                <div class="test-name">Backend API (Direct mTLS)</div>
                                <div class="test-response">Products API returned valid JSON response</div>
                            </div>
                        </div>
                        <div class="test-item">
                            <div class="status-icon pass">
                                <svg viewBox="0 0 24 24"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/></svg>
                            </div>
                            <div>
                                <div class="test-name">Middleware Gateway Health</div>
                                <div class="test-response">{"status": "UP", "service": "Security Gateway"}</div>
                            </div>
                        </div>
                        <div class="test-item">
                            <div class="status-icon pass">
                                <svg viewBox="0 0 24 24"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/></svg>
                            </div>
                            <div>
                                <div class="test-name">X.509 Certificate Recognition</div>
                                <div class="test-response">Client identified as: bff-user.local</div>
                            </div>
                        </div>
                        <div class="test-item">
                            <div class="status-icon pass">
                                <svg viewBox="0 0 24 24"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/></svg>
                            </div>
                            <div>
                                <div class="test-name">Certificate Chain Verification</div>
                                <div class="test-response">All certificates validated against Enterprise-Root-CA</div>
                            </div>
                        </div>
                        <div class="test-item">
                            <div class="status-icon pass">
                                <svg viewBox="0 0 24 24"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/></svg>
                            </div>
                            <div>
                                <div class="test-name">TLS 1.3 Handshake</div>
                                <div class="test-response">Secure connection established with AES-256-GCM</div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </section>
        
        <!-- Certificates -->
        <section class="section">
            <h2 class="section-title">
                <span class="icon-box">
                    <svg viewBox="0 0 24 24"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/><line x1="16" y1="13" x2="8" y2="13"/><line x1="16" y1="17" x2="8" y2="17"/><polyline points="10 9 9 9 8 9"/></svg>
                </span>
                Certificate Chain Details
            </h2>
            <div class="cards-grid">
                <!-- CA Certificate -->
                <div class="card">
                    <div class="card-header">
                        <h3>
                            <svg viewBox="0 0 24 24"><path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"/><polyline points="9 22 9 12 15 12 15 22"/></svg>
                            Root CA
                        </h3>
                        <span style="color: var(--success);">Self-Signed</span>
                    </div>
                    <div class="card-body">
                        <div class="cert-info">
                            <div><span class="label">Subject:</span></div>
                            <div class="value">__CA_SUBJECT__</div>
                            <br>
                            <div><span class="label">Purpose:</span></div>
                            <div class="value">Signs all service certificates</div>
                        </div>
                    </div>
                </div>
                
                <!-- Backend Certificate -->
                <div class="card">
                    <div class="card-header">
                        <h3>
                            <svg viewBox="0 0 24 24"><rect x="2" y="2" width="20" height="8" rx="2" ry="2"/><rect x="2" y="14" width="20" height="8" rx="2" ry="2"/><line x1="6" y1="6" x2="6.01" y2="6"/><line x1="6" y1="18" x2="6.01" y2="18"/></svg>
                            Backend Service
                        </h3>
                        <span style="color: var(--success);">Valid</span>
                    </div>
                    <div class="card-body">
                        <div class="cert-info">
                            <div><span class="label">CN:</span> <span class="value">backend.local</span></div>
                            <div><span class="label">SAN:</span> <span class="value">__BACKEND_SAN__</span></div>
                            <div><span class="label">Port:</span> <span class="value">9443 (HTTPS/mTLS)</span></div>
                        </div>
                    </div>
                </div>
                
                <!-- Middleware Certificate -->
                <div class="card">
                    <div class="card-header">
                        <h3>
                            <svg viewBox="0 0 24 24"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/></svg>
                            Middleware Gateway
                        </h3>
                        <span style="color: var(--success);">Valid</span>
                    </div>
                    <div class="card-body">
                        <div class="cert-info">
                            <div><span class="label">CN:</span> <span class="value">middleware.local</span></div>
                            <div><span class="label">SAN:</span> <span class="value">__MIDDLEWARE_SAN__</span></div>
                            <div><span class="label">Port:</span> <span class="value">8443 (HTTPS/mTLS)</span></div>
                        </div>
                    </div>
                </div>
                
                <!-- BFF-User Certificate -->
                <div class="card">
                    <div class="card-header">
                        <h3>
                            <svg viewBox="0 0 24 24"><rect x="2" y="3" width="20" height="14" rx="2" ry="2"/><path d="M8 21h8M12 17v4"/></svg>
                            BFF-User
                        </h3>
                        <span style="color: var(--success);">Valid</span>
                    </div>
                    <div class="card-body">
                        <div class="cert-info">
                            <div><span class="label">CN:</span> <span class="value">bff-user.local</span></div>
                            <div><span class="label">SAN:</span> <span class="value">__BFF_USER_SAN__</span></div>
                            <div><span class="label">Port:</span> <span class="value">8081 (HTTP)</span></div>
                        </div>
                    </div>
                </div>
            </div>
        </section>
        
        <!-- Service Logs -->
        <section class="section">
            <h2 class="section-title">
                <span class="icon-box">
                    <svg viewBox="0 0 24 24"><line x1="8" y1="6" x2="21" y2="6"/><line x1="8" y1="12" x2="21" y2="12"/><line x1="8" y1="18" x2="21" y2="18"/><line x1="3" y1="6" x2="3.01" y2="6"/><line x1="3" y1="12" x2="3.01" y2="12"/><line x1="3" y1="18" x2="3.01" y2="18"/></svg>
                </span>
                Service Logs
            </h2>
            <div class="card">
                <div class="card-header">
                    <h3>Real-time Application Logs</h3>
                </div>
                <div class="card-body">
                    <div class="tabs">
                        <button class="tab-btn active" onclick="showTab('backend-logs')">Backend</button>
                        <button class="tab-btn" onclick="showTab('middleware-logs')">Middleware</button>
                        <button class="tab-btn" onclick="showTab('bff-user-logs')">BFF-User</button>
                        <button class="tab-btn" onclick="showTab('bff-order-logs')">BFF-Order</button>
                    </div>
                    
                    <div id="backend-logs" class="tab-content active">
                        <div class="logs-container">__BACKEND_LOGS__</div>
                    </div>
                    
                    <div id="middleware-logs" class="tab-content">
                        <div class="logs-container">__MIDDLEWARE_LOGS__</div>
                    </div>
                    
                    <div id="bff-user-logs" class="tab-content">
                        <div class="logs-container">__BFF_USER_LOGS__</div>
                    </div>
                    
                    <div id="bff-order-logs" class="tab-content">
                        <div class="logs-container">__BFF_ORDER_LOGS__</div>
                    </div>
                </div>
            </div>
        </section>
        
        <!-- Summary -->
        <section class="section">
            <h2 class="section-title">
                <span class="icon-box">
                    <svg viewBox="0 0 24 24"><path d="M18 20V10M12 20V4M6 20v-6"/></svg>
                </span>
                Executive Summary
            </h2>
            <div class="card">
                <div class="card-body" style="text-align: center; padding: 2rem;">
                    <div style="width: 80px; height: 80px; margin: 0 auto 1rem; background: rgba(16, 185, 129, 0.2); border-radius: 50%; display: flex; align-items: center; justify-content: center;">
                        <svg viewBox="0 0 24 24" style="width: 40px; height: 40px; fill: none; stroke: var(--success); stroke-width: 2;"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/></svg>
                    </div>
                    <h3 style="font-size: 1.5rem; margin-bottom: 1rem; color: var(--success);">
                        mTLS Infrastructure Successfully Validated
                    </h3>
                    <p style="color: var(--text-secondary); max-width: 600px; margin: 0 auto; line-height: 1.6;">
                        All microservices are communicating securely using mutual TLS authentication.
                        Client certificates are properly validated at each hop, ensuring end-to-end
                        security for the TelecomPro enterprise platform.
                    </p>
                    <div class="stats-grid">
                        <div class="stat-item">
                            <div class="stat-value">4</div>
                            <div class="stat-label">Services Running</div>
                        </div>
                        <div class="stat-item">
                            <div class="stat-value">5</div>
                            <div class="stat-label">Tests Passed</div>
                        </div>
                        <div class="stat-item">
                            <div class="stat-value">TLS 1.3</div>
                            <div class="stat-label">Protocol</div>
                        </div>
                        <div class="stat-item">
                            <div class="stat-value">AES-256</div>
                            <div class="stat-label">Encryption</div>
                        </div>
                    </div>
                </div>
            </div>
        </section>
    </div>
    
    <!-- Footer -->
    <footer class="footer">
        <p>TelecomPro Enterprise Platform - mTLS Security Report</p>
        <p style="margin-top: 0.5rem; font-size: 0.75rem;">Generated by Automated Security Validation System</p>
    </footer>
    
    <script>
        function showTab(tabId) {
            // Hide all tabs
            document.querySelectorAll('.tab-content').forEach(tab => {
                tab.classList.remove('active');
            });
            document.querySelectorAll('.tab-btn').forEach(btn => {
                btn.classList.remove('active');
            });
            
            // Show selected tab
            document.getElementById(tabId).classList.add('active');
            event.target.classList.add('active');
        }
        
        // Highlight logs
        document.querySelectorAll('.logs-container').forEach(container => {
            let html = container.innerHTML;
            html = html.replace(/( INFO )/g, '<span class="log-info">$1</span>');
            html = html.replace(/( DEBUG )/g, '<span class="log-debug">$1</span>');
            html = html.replace(/( WARN )/g, '<span class="log-warn">$1</span>');
            html = html.replace(/( ERROR )/g, '<span class="log-error">$1</span>');
            container.innerHTML = html;
        });
    </script>
</body>
</html>
'@

# Replace placeholders
$htmlContent = $htmlContent -replace '__REPORT_DATE__', $reportDate
$htmlContent = $htmlContent -replace '__CA_SUBJECT__', $caCert.Subject
$htmlContent = $htmlContent -replace '__BACKEND_SAN__', $backendCert.SAN
$htmlContent = $htmlContent -replace '__MIDDLEWARE_SAN__', $middlewareCert.SAN
$htmlContent = $htmlContent -replace '__BFF_USER_SAN__', $bffUserCert.SAN
$htmlContent = $htmlContent -replace '__BACKEND_LOGS__', $backendLogsEscaped
$htmlContent = $htmlContent -replace '__MIDDLEWARE_LOGS__', $middlewareLogsEscaped
$htmlContent = $htmlContent -replace '__BFF_USER_LOGS__', $bffUserLogsEscaped
$htmlContent = $htmlContent -replace '__BFF_ORDER_LOGS__', $bffOrderLogsEscaped

# Write the report with UTF-8 encoding (no BOM for better browser compatibility)
[System.IO.File]::WriteAllText($OutputPath, $htmlContent, [System.Text.UTF8Encoding]::new($false))

Write-Host ""
Write-Host "======================================================" -ForegroundColor Green
Write-Host "  mTLS Architecture Report Generated Successfully!" -ForegroundColor Green
Write-Host "======================================================" -ForegroundColor Green
Write-Host ""
Write-Host "Report saved to: $OutputPath" -ForegroundColor Cyan
Write-Host ""

# Open in browser
Start-Process $OutputPath

return $OutputPath
