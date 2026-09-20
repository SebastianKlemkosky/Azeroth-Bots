@echo off
setlocal EnableDelayedExpansion

call "%~dp0server-env.bat"

set "TELEMETRY_DIR=%PROJECT_ROOT%\Telemetry"
set "TELEMETRY_SCRIPT=%TELEMETRY_DIR%\watch.py"
set "PID_FILE=%TELEMETRY_DIR%\telemetry.pid"
set "STOP_FILE=%TELEMETRY_DIR%\stop.flag"


REM ==================================================
REM Verify telemetry
REM ==================================================

if not exist "%TELEMETRY_SCRIPT%" (
    echo [ERROR] Telemetry watcher was not found:
    echo %TELEMETRY_SCRIPT%
    exit /b 1
)


REM ==================================================
REM Verify Windows Terminal
REM ==================================================

where wt.exe >nul 2>&1

if errorlevel 1 (
    echo [ERROR] Windows Terminal ^(wt.exe^) was not found.
    exit /b 1
)


REM ==================================================
REM Check if telemetry is already running
REM ==================================================

if exist "%PID_FILE%" (

    set /p TELEMETRY_PID=<"%PID_FILE%"

    powershell -NoProfile -Command ^
        "if (Get-Process -Id !TELEMETRY_PID! -ErrorAction SilentlyContinue) { exit 0 } else { exit 1 }"

    if not errorlevel 1 (
        echo [OK] Telemetry is already running.
        echo [INFO] PID: !TELEMETRY_PID!
        exit /b 0
    )

    echo [INFO] Removing stale telemetry PID file.
    del /Q "%PID_FILE%" >nul 2>&1
)


REM ==================================================
REM Remove stale stop request
REM ==================================================

if exist "%STOP_FILE%" (
    del /Q "%STOP_FILE%" >nul 2>&1
)


REM ==================================================
REM Start telemetry
REM ==================================================

echo [INFO] Starting Azeroth Bots telemetry in Windows Terminal...

wt -w AzerothBots new-tab ^
    --title "Azeroth Bots - Telemetry" ^
    --suppressApplicationTitle ^
    -d "%TELEMETRY_DIR%" ^
    cmd /c py watch.py


REM ==================================================
REM Wait for telemetry PID file
REM ==================================================

set /a WAIT_COUNT=0

:WAIT_FOR_PID

if exist "%PID_FILE%" goto TELEMETRY_READY

set /a WAIT_COUNT+=1

if !WAIT_COUNT! GEQ 10 goto TELEMETRY_TIMEOUT

timeout /t 1 /nobreak >nul
goto WAIT_FOR_PID


REM ==================================================
REM Telemetry ready
REM ==================================================

:TELEMETRY_READY

set /p TELEMETRY_PID=<"%PID_FILE%"

echo [OK] Telemetry started.
echo [INFO] PID: %TELEMETRY_PID%

endlocal
exit /b 0


REM ==================================================
REM Telemetry startup failure
REM ==================================================

:TELEMETRY_TIMEOUT

echo.
echo [ERROR] Telemetry did not create its PID file
echo within 10 seconds.
echo.
echo Check the Telemetry tab for errors.
echo.

endlocal
exit /b 1