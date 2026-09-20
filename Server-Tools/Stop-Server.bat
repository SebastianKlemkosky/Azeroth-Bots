@echo off
setlocal EnableDelayedExpansion

title Azeroth Bots - Automatic Shutdown

call "%~dp0server-env.bat"

echo ============================================
echo       AzerothCore Automatic Shutdown
echo ============================================
echo.

REM ==================================================
REM STEP 1 - Stop WorldServer cleanly through SOAP
REM ==================================================

tasklist /FI "IMAGENAME eq worldserver.exe" | find /I "worldserver.exe" >nul

if errorlevel 1 (
echo [OK] WorldServer is already stopped.
goto STOP_TELEMETRY
)

echo [INFO] Sending clean shutdown command to WorldServer...

powershell -NoProfile -ExecutionPolicy Bypass ^
-File "%~dp0Send-AcoreCommand.ps1" ^
-Command "server shutdown 1"

if errorlevel 1 (
echo.
echo [ERROR] Could not send shutdown command through SOAP.
echo WorldServer has NOT been forcefully stopped.
echo.
pause
exit /b 1
)

echo.
echo [INFO] Waiting for WorldServer to shut down...

set /a WAIT_COUNT=0

:WAIT_WORLD

tasklist /FI "IMAGENAME eq worldserver.exe" | find /I "worldserver.exe" >nul

if errorlevel 1 goto WORLD_STOPPED

set /a WAIT_COUNT+=1

if !WAIT_COUNT! GEQ 60 goto WORLD_TIMEOUT

timeout /t 1 /nobreak >nul

goto WAIT_WORLD

:WORLD_STOPPED

echo [OK] WorldServer shut down cleanly.
echo.

goto STOP_TELEMETRY

:WORLD_TIMEOUT

echo.
echo [ERROR] WorldServer did not stop within 60 seconds.
echo.
echo It has been left running to avoid forcing
echo WorldServer closed.
echo.
echo Check the WorldServer console for errors.
echo.

pause
exit /b 1

REM ==================================================
REM STEP 2 - Stop Telemetry
REM ==================================================

:STOP_TELEMETRY

echo [INFO] Stopping telemetry...

call "%~dp0Stop-Telemetry.bat"

echo.

goto STOP_AUTH

REM ==================================================
REM STEP 3 - Stop AuthServer
REM ==================================================

:STOP_AUTH

tasklist /FI "IMAGENAME eq authserver.exe" | find /I "authserver.exe" >nul

if errorlevel 1 (
echo [OK] AuthServer is already stopped.
goto DONE
)

echo [INFO] Stopping AuthServer...

taskkill /F /IM authserver.exe >nul 2>&1

echo [INFO] Waiting for AuthServer to stop...

set /a AUTH_WAIT=0

:WAIT_AUTH_STOP

tasklist /FI "IMAGENAME eq authserver.exe" | find /I "authserver.exe" >nul

if errorlevel 1 goto AUTH_STOPPED

set /a AUTH_WAIT+=1

if !AUTH_WAIT! GEQ 10 goto AUTH_STOP_FAILED

timeout /t 1 /nobreak >nul

goto WAIT_AUTH_STOP

:AUTH_STOPPED

echo [OK] AuthServer stopped.
echo.

goto DONE

:AUTH_STOP_FAILED

echo.
echo [ERROR] AuthServer did not stop within 10 seconds.
echo.
echo Check the AuthServer window manually.
echo.

pause
exit /b 1

REM ==================================================
REM COMPLETE
REM ==================================================

:DONE

echo.
echo ============================================
echo          Server Shutdown Complete
echo ============================================
echo.

echo WorldServer: STOPPED
echo AuthServer:  STOPPED
echo Telemetry:   STOPPED
echo MySQL84:     LEFT RUNNING

echo.

pause

endlocal
exit /b 0
