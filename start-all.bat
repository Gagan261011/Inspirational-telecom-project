@echo off
:: ============================================================================
:: TelecomPro - Start All Services (Batch Wrapper)
:: ============================================================================
:: This is a wrapper to run the PowerShell start script
:: ============================================================================

title TelecomPro - Starting Services

echo.
echo ========================================
echo   TelecomPro - Enterprise Platform
echo   Starting All Services...
echo ========================================
echo.

:: Check if PowerShell is available
where powershell >nul 2>nul
if %errorlevel% neq 0 (
    echo ERROR: PowerShell is not available
    pause
    exit /b 1
)

:: Run the PowerShell script
powershell -ExecutionPolicy Bypass -File "%~dp0start-all.ps1"

pause
