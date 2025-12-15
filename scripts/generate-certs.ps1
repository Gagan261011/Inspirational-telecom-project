# =============================================================================
# Enterprise mTLS Certificate Generator (PowerShell)
# Generates complete PKI infrastructure for secure microservices communication
# =============================================================================

# Don't use Stop - native commands write to stderr for informational messages
$ErrorActionPreference = "Continue"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$CertsDir = Join-Path (Split-Path -Parent $ScriptDir) "certs"
$ValidityDays = 365
$KeySize = 2048

# Find OpenSSL - check common locations
$OpenSSLPath = $null
$PossiblePaths = @(
    "C:\Program Files\Git\usr\bin\openssl.exe",
    "C:\Program Files\OpenSSL-Win64\bin\openssl.exe",
    "C:\Program Files (x86)\OpenSSL\bin\openssl.exe",
    "C:\OpenSSL-Win64\bin\openssl.exe"
)

foreach ($path in $PossiblePaths) {
    if (Test-Path $path) {
        $OpenSSLPath = $path
        break
    }
}

# Also check if openssl is in PATH
if (-not $OpenSSLPath) {
    $inPath = Get-Command openssl -ErrorAction SilentlyContinue
    if ($inPath) {
        $OpenSSLPath = "openssl"
    }
}

# Find keytool - check JAVA_HOME and common locations
$KeytoolPath = $null

# First check JAVA_HOME
if ($env:JAVA_HOME -and (Test-Path (Join-Path $env:JAVA_HOME "bin\keytool.exe"))) {
    $KeytoolPath = Join-Path $env:JAVA_HOME "bin\keytool.exe"
}

# Check common Java installation paths
if (-not $KeytoolPath) {
    $JavaPaths = @(
        "C:\Program Files\Microsoft\jdk-17.0.16.8-hotspot\bin\keytool.exe",
        "C:\Program Files\Eclipse Adoptium\jdk-17*\bin\keytool.exe",
        "C:\Program Files\Java\jdk*\bin\keytool.exe",
        "C:\Program Files\Java\jre*\bin\keytool.exe"
    )
    
    foreach ($pattern in $JavaPaths) {
        $matches = Get-ChildItem -Path $pattern -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($matches) {
            $KeytoolPath = $matches.FullName
            break
        }
    }
}

# Also check if keytool is in PATH
if (-not $KeytoolPath) {
    $inPath = Get-Command keytool -ErrorAction SilentlyContinue
    if ($inPath) {
        $KeytoolPath = "keytool"
    }
}

function Write-Header {
    Write-Host ""
    Write-Host "==================================================================" -ForegroundColor Blue
    Write-Host "          Enterprise mTLS Certificate Generator                   " -ForegroundColor Blue
    Write-Host "              Secure Microservices Infrastructure                 " -ForegroundColor Blue
    Write-Host "==================================================================" -ForegroundColor Blue
    Write-Host ""
}

function Write-Info {
    param([string]$Message)
    Write-Host "[INFO] $Message" -ForegroundColor Green
}

function Write-Warn {
    param([string]$Message)
    Write-Host "[WARN] $Message" -ForegroundColor Yellow
}

function Write-Error {
    param([string]$Message)
    Write-Host "[ERROR] $Message" -ForegroundColor Red
}

function Test-OpenSSL {
    if ($OpenSSLPath) {
        return $true
    }
    return $false
}

function Test-Keytool {
    if ($KeytoolPath) {
        return $true
    }
    return $false
}

function Initialize-Directories {
    Write-Info "Cleaning up existing certificates..."
    
    if (Test-Path $CertsDir) {
        Remove-Item -Recurse -Force $CertsDir
    }
    
    New-Item -ItemType Directory -Force -Path $CertsDir | Out-Null
    New-Item -ItemType Directory -Force -Path (Join-Path $CertsDir "ca") | Out-Null
    New-Item -ItemType Directory -Force -Path (Join-Path $CertsDir "backend") | Out-Null
    New-Item -ItemType Directory -Force -Path (Join-Path $CertsDir "middleware") | Out-Null
    New-Item -ItemType Directory -Force -Path (Join-Path $CertsDir "bff-user") | Out-Null
    New-Item -ItemType Directory -Force -Path (Join-Path $CertsDir "bff-order") | Out-Null
}

function New-RootCA {
    Write-Info "Generating Root Certificate Authority..."
    
    $CaDir = Join-Path $CertsDir "ca"
    $CaKey = Join-Path $CaDir "ca.key"
    $CaCrt = Join-Path $CaDir "ca.crt"
    
    # Generate CA private key (suppress stderr info messages)
    $null = & $OpenSSLPath genrsa -out $CaKey $KeySize 2>&1
    
    # Generate CA certificate
    $null = & $OpenSSLPath req -x509 -new -nodes `
        -key $CaKey `
        -sha256 -days $ValidityDays `
        -out $CaCrt `
        -subj "/C=US/ST=Enterprise/L=Platform/O=TelecomPortal/OU=Security/CN=Enterprise-Root-CA" 2>&1
    
    if (-not (Test-Path $CaCrt)) {
        throw "Failed to generate Root CA certificate"
    }
    
    Write-Info "Root CA generated successfully"
}

function New-ServiceCertificate {
    param(
        [string]$ServiceName,
        [string]$CN,
        [string]$SAN
    )
    
    Write-Info "Generating certificate for $ServiceName..."
    
    $ServiceDir = Join-Path $CertsDir $ServiceName
    $CaDir = Join-Path $CertsDir "ca"
    $CaKey = Join-Path $CaDir "ca.key"
    $CaCrt = Join-Path $CaDir "ca.crt"
    
    $ServiceKey = Join-Path $ServiceDir "$ServiceName.key"
    $ServiceCsr = Join-Path $ServiceDir "$ServiceName.csr"
    $ServiceCrt = Join-Path $ServiceDir "$ServiceName.crt"
    $ServiceCnf = Join-Path $ServiceDir "$ServiceName.cnf"
    $ServiceP12 = Join-Path $ServiceDir "$ServiceName.p12"
    
    # Generate private key
    $null = & $OpenSSLPath genrsa -out $ServiceKey $KeySize 2>&1
    
    # Create CSR config with SAN
    $CnfContent = @"
[req]
default_bits = $KeySize
prompt = no
default_md = sha256
distinguished_name = dn
req_extensions = req_ext

[dn]
C = US
ST = Enterprise
L = Platform
O = TelecomPortal
OU = $ServiceName
CN = $CN

[req_ext]
subjectAltName = $SAN

[v3_ext]
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, keyEncipherment
extendedKeyUsage = serverAuth, clientAuth
subjectAltName = $SAN
"@
    
    Set-Content -Path $ServiceCnf -Value $CnfContent -NoNewline
    
    # Generate CSR
    $null = & $OpenSSLPath req -new `
        -key $ServiceKey `
        -out $ServiceCsr `
        -config $ServiceCnf 2>&1
    
    if (-not (Test-Path $ServiceCsr)) {
        throw "Failed to generate CSR for $ServiceName"
    }
    
    # Sign with CA
    $null = & $OpenSSLPath x509 -req `
        -in $ServiceCsr `
        -CA $CaCrt `
        -CAkey $CaKey `
        -CAcreateserial `
        -out $ServiceCrt `
        -days $ValidityDays `
        -sha256 `
        -extensions v3_ext `
        -extfile $ServiceCnf 2>&1
    
    if (-not (Test-Path $ServiceCrt)) {
        throw "Failed to sign certificate for $ServiceName"
    }
    
    # Create PKCS12 keystore
    $null = & $OpenSSLPath pkcs12 -export `
        -in $ServiceCrt `
        -inkey $ServiceKey `
        -out $ServiceP12 `
        -name $ServiceName `
        -CAfile $CaCrt `
        -caname root `
        -password pass:changeit 2>&1
    
    if (-not (Test-Path $ServiceP12)) {
        throw "Failed to create PKCS12 keystore for $ServiceName"
    }
    
    Write-Info "$ServiceName certificate generated successfully"
}

function New-Truststore {
    Write-Info "Creating truststore with CA certificate..."
    
    $CaDir = Join-Path $CertsDir "ca"
    $CaCrt = Join-Path $CaDir "ca.crt"
    $Truststore = Join-Path $CertsDir "truststore.p12"
    
    # Create truststore with CA certificate
    & $KeytoolPath -import -trustcacerts `
        -alias ca-root `
        -file $CaCrt `
        -keystore $Truststore `
        -storetype PKCS12 `
        -storepass changeit `
        -noprompt
    
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to create truststore"
    }
    
    # Copy truststore to each service directory
    Copy-Item $Truststore (Join-Path $CertsDir "backend")
    Copy-Item $Truststore (Join-Path $CertsDir "middleware")
    Copy-Item $Truststore (Join-Path $CertsDir "bff-user")
    Copy-Item $Truststore (Join-Path $CertsDir "bff-order")
    
    Write-Info "Truststore created and distributed"
}

function Test-Certificates {
    Write-Info "Verifying certificate chain..."
    
    $CaDir = Join-Path $CertsDir "ca"
    $CaCrt = Join-Path $CaDir "ca.crt"
    
    foreach ($service in @("backend", "middleware", "bff-user", "bff-order")) {
        $ServiceDir = Join-Path $CertsDir $service
        $ServiceCrt = Join-Path $ServiceDir "$service.crt"
        $result = & $OpenSSLPath verify -CAfile $CaCrt $ServiceCrt 2>&1
        Write-Host "  $result"
    }
    
    Write-Info "All certificates verified successfully"
}

function Write-Summary {
    Write-Host ""
    Write-Host "==================================================================" -ForegroundColor Green
    Write-Host "              Certificate Generation Complete                      " -ForegroundColor Green
    Write-Host "==================================================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Generated certificates:"
    Write-Host "  $CertsDir\ca\           - Root CA"
    Write-Host "  $CertsDir\backend\      - Backend Service"
    Write-Host "  $CertsDir\middleware\   - Security Gateway"
    Write-Host "  $CertsDir\bff-user\     - User BFF"
    Write-Host "  $CertsDir\bff-order\    - Order BFF"
    Write-Host ""
    Write-Host "Keystore password: changeit"
    Write-Host "Truststore password: changeit"
    Write-Host ""
    Write-Host "mTLS Flow:"
    Write-Host "  BFF -> Middleware -> Backend"
    Write-Host ""
}

# Main execution
function Main {
    Write-Header
    
    # Check for required tools
    if (-not (Test-OpenSSL)) {
        Write-Error "OpenSSL is required but not installed or not in PATH."
        Write-Host "Install OpenSSL from: https://slproweb.com/products/Win32OpenSSL.html"
        Write-Host "Or install Git for Windows which includes OpenSSL."
        exit 1
    }
    
    Write-Info "Using OpenSSL: $OpenSSLPath"
    
    if (-not (Test-Keytool)) {
        Write-Error "keytool (Java) is required but not installed or not in PATH."
        exit 1
    }
    
    Write-Info "Using keytool: $KeytoolPath"
    
    Initialize-Directories
    New-RootCA
    
    # Generate service certificates with appropriate SANs
    New-ServiceCertificate -ServiceName "backend" -CN "backend.local" -SAN "DNS:localhost,DNS:backend.local,IP:127.0.0.1"
    New-ServiceCertificate -ServiceName "middleware" -CN "middleware.local" -SAN "DNS:localhost,DNS:middleware.local,IP:127.0.0.1"
    New-ServiceCertificate -ServiceName "bff-user" -CN "bff-user.local" -SAN "DNS:localhost,DNS:bff-user.local,IP:127.0.0.1"
    New-ServiceCertificate -ServiceName "bff-order" -CN "bff-order.local" -SAN "DNS:localhost,DNS:bff-order.local,IP:127.0.0.1"
    
    New-Truststore
    Test-Certificates
    Write-Summary
}

Main
