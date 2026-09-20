@echo off
setlocal EnableDelayedExpansion

call "%~dp0server-env.bat"

set "TELEMETRY_DIR=%PROJECT_ROOT%\Telemetry"
set "PID_FILE=%TELEMETRY_DIR%\telemetry.pid"
set "STOP_FILE=%TELEMETRY_DIR%\stop.flag"


REM ==================================================
REM Check whether telemetry is running
REM ==================================================

if not exist "%PID_FILE%" (
    echo [OK] Telemetry is already stopped.
    exit /b 0
)

set /p TELEMETRY_PID=<"%PID_FILE%"

powershell -NoProfile -Command ^
    "if (Get-Process -Id !TELEMETRY_PID! -ErrorAction SilentlyContinue) { exit 0 } else { exit 1 }"

if errorlevel 1 (
    echo [INFO] Telemetry process is no longer running.

    del /Q "%PID_FILE%" >nul 2>&1

    if exist "%STOP_FILE%" (
        del /Q "%STOP_FILE%" >nul 2>&1
    )

    exit /b 0
)


REM ==================================================
REM Request clean shutdown
REM ==================================================

echo [INFO] Requesting telemetry shutdown...

echo stop>"%STOP_FILE%"


REM ==================================================
REM Wait for clean shutdown
REM ==================================================

set /a WAIT_COUNT=0

:WAIT_TELEMETRY

powershell -NoProfile -Command ^
    "if (Get-Process -Id !TELEMETRY_PID! -ErrorAction SilentlyContinue) { exit 0 } else { exit 1 }"

if errorlevel 1 goto TELEMETRY_STOPPED

set /a WAIT_COUNT+=1

if !WAIT_COUNT! GEQ 20 goto TELEMETRY_TIMEOUT

timeout /t 1 /nobreak >nul
goto WAIT_TELEMETRY


:TELEMETRY_STOPPED

echo [OK] Telemetry stopped cleanly.

if exist "%PID_FILE%" (
    del /Q "%PID_FILE%" >nul 2>&1
)

if exist "%STOP_FILE%" (
    del /Q "%STOP_FILE%" >nul 2>&1
)

endlocal
exit /b 0


:TELEMETRY_TIMEOUT

echo.
echo [WARNING] Telemetry did not exit within 20 seconds.
echo [INFO] Forcing telemetry process to stop...

taskkill /PID !TELEMETRY_PID! /T /F >nul 2>&1

if exist "%PID_FILE%" (
    del /Q "%PID_FILE%" >nul 2>&1
)

if exist "%STOP_FILE%" (
    del /Q "%STOP_FILE%" >nul 2>&1
)

echo [OK] Telemetry process stopped.

endlocal
exit /b 0