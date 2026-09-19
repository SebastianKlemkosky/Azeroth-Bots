@echo off
setlocal EnableDelayedExpansion
title Azeroth Bots - Server Restart

call "%~dp0server-env.bat"

echo ============================================
echo        AzerothCore Automatic Restart
echo ============================================
echo.


REM ==================================================
REM STEP 1 - Shut down WorldServer cleanly
REM ==================================================

tasklist /FI "IMAGENAME eq worldserver.exe" | find /I "worldserver.exe" >nul

if errorlevel 1 (
    echo [OK] WorldServer is already stopped.
    goto STOP_AUTH
)

echo [INFO] Sending clean shutdown command to WorldServer...

powershell -NoProfile -ExecutionPolicy Bypass ^
    -File "%~dp0Send-AcoreCommand.ps1" ^
    -Command "server shutdown 1"

if errorlevel 1 (
    echo.
    echo [ERROR] Could not send shutdown command through SOAP.
    echo Restart cancelled.
    echo.
    pause
    exit /b 1
)

echo [INFO] Waiting for WorldServer to stop...

set /a WAIT_COUNT=0


:WAIT_WORLD

tasklist /FI "IMAGENAME eq worldserver.exe" | find /I "worldserver.exe" >nul

if errorlevel 1 goto WORLD_STOPPED

set /a WAIT_COUNT+=1

if !WAIT_COUNT! GEQ 60 goto WORLD_TIMEOUT

timeout /t 1 /nobreak >nul
goto WAIT_WORLD


:WORLD_STOPPED

echo [OK] WorldServer stopped cleanly.
echo.
goto STOP_AUTH


:WORLD_TIMEOUT

echo.
echo [ERROR] WorldServer did not stop within 60 seconds.
echo Restart cancelled.
echo.
pause
exit /b 1


REM ==================================================
REM STEP 2 - Stop AuthServer
REM ==================================================

:STOP_AUTH

tasklist /FI "IMAGENAME eq authserver.exe" | find /I "authserver.exe" >nul

if errorlevel 1 (
    echo [OK] AuthServer is already stopped.
    goto CHECK_MYSQL
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
goto CHECK_MYSQL


:AUTH_STOP_FAILED

echo.
echo [ERROR] AuthServer did not stop.
echo Restart cancelled.
echo.
pause
exit /b 1


REM ==================================================
REM STEP 3 - Make sure MySQL is running
REM ==================================================

:CHECK_MYSQL

echo [INFO] Checking MySQL84...

sc query MySQL84 | find /I "RUNNING" >nul

if errorlevel 1 (
    echo [INFO] MySQL84 is stopped.
    echo [INFO] Attempting to start MySQL84...

    net start MySQL84

    if errorlevel 1 (
        echo.
        echo [ERROR] Could not start MySQL84.
        echo Try running this BAT file as Administrator.
        echo.
        pause
        exit /b 1
    )
)

echo [OK] MySQL84 is running.
echo.


REM ==================================================
REM STEP 4 - Start AuthServer
REM ==================================================

echo [INFO] Starting AuthServer...

start "AzerothCore - AuthServer" /D "%AC_BIN%" authserver.exe

echo [INFO] Waiting for AuthServer port %AUTH_PORT%...

set /a WAIT_COUNT=0


:WAIT_AUTH_PORT

powershell -NoProfile -Command ^
    "if (Test-NetConnection -ComputerName '127.0.0.1' -Port %AUTH_PORT% -InformationLevel Quiet -WarningAction SilentlyContinue) { exit 0 } else { exit 1 }"

if not errorlevel 1 goto AUTH_READY

set /a WAIT_COUNT+=1

if !WAIT_COUNT! GEQ 30 goto AUTH_START_TIMEOUT

timeout /t 1 /nobreak >nul
goto WAIT_AUTH_PORT


:AUTH_READY

echo [OK] AuthServer port %AUTH_PORT% is open.
echo.


REM ==================================================
REM STEP 5 - Start WorldServer
REM ==================================================

echo [INFO] Starting WorldServer...

start "AzerothCore - WorldServer" /D "%AC_BIN%" worldserver.exe

echo [INFO] Waiting for WorldServer port %WORLD_PORT%...

set /a WAIT_COUNT=0


:WAIT_WORLD_PORT

powershell -NoProfile -Command ^
    "if (Test-NetConnection -ComputerName '127.0.0.1' -Port %WORLD_PORT% -InformationLevel Quiet -WarningAction SilentlyContinue) { exit 0 } else { exit 1 }"

if not errorlevel 1 goto WORLD_PORT_READY

set /a WAIT_COUNT+=1

if !WAIT_COUNT! GEQ 120 goto WORLD_START_TIMEOUT

timeout /t 1 /nobreak >nul
goto WAIT_WORLD_PORT


:WORLD_PORT_READY

echo [OK] WorldServer port %WORLD_PORT% is open.
echo.


REM ==================================================
REM STEP 6 - Wait for SOAP
REM ==================================================

echo [INFO] Waiting for SOAP port %SOAP_PORT%...

set /a WAIT_COUNT=0


:WAIT_SOAP

powershell -NoProfile -Command ^
    "if (Test-NetConnection -ComputerName '127.0.0.1' -Port %SOAP_PORT% -InformationLevel Quiet -WarningAction SilentlyContinue) { exit 0 } else { exit 1 }"

if not errorlevel 1 goto SERVER_READY

set /a WAIT_COUNT+=1

if !WAIT_COUNT! GEQ 120 goto SOAP_TIMEOUT

timeout /t 1 /nobreak >nul
goto WAIT_SOAP


REM ==================================================
REM COMPLETE
REM ==================================================

:SERVER_READY

echo [OK] SOAP port %SOAP_PORT% is open.

echo.
echo ============================================
echo             Restart Complete
echo ============================================
echo.
echo MySQL84:      RUNNING
echo AuthServer:   RUNNING
echo WorldServer:  RUNNING
echo.
echo Server IP:    %SERVER_IP%
echo Auth Port:    %AUTH_PORT%
echo World Port:   %WORLD_PORT%
echo SOAP Port:    %SOAP_PORT%
echo.
echo Playerbots will continue logging in after
echo WorldServer finishes initialization.
echo.
echo Run Server-Status.bat to check bot population.
echo.

pause
endlocal
exit /b 0


REM ==================================================
REM ERROR HANDLERS
REM ==================================================

:AUTH_START_TIMEOUT

echo.
echo [ERROR] AuthServer did not open port %AUTH_PORT%
echo within 30 seconds.
echo.
echo Check the AuthServer window for errors.
echo.
pause
endlocal
exit /b 1


:WORLD_START_TIMEOUT

echo.
echo [ERROR] WorldServer did not open port %WORLD_PORT%
echo within 120 seconds.
echo.
echo Check the WorldServer window for errors.
echo.
pause
endlocal
exit /b 1


:SOAP_TIMEOUT

echo.
echo [ERROR] SOAP did not open port %SOAP_PORT%
echo within 120 seconds.
echo.
echo WorldServer may still be loading or may have
echo encountered an error.
echo.
pause
endlocal
exit /b 1