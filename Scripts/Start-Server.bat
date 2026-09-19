@echo off
setlocal EnableDelayedExpansion
title Azeroth Bots - Server Launcher

call "%~dp0server-env.bat"

REM Use default SOAP port if it is not in server-env.bat yet
if not defined SOAP_PORT set "SOAP_PORT=7878"

echo ============================================
echo       AzerothCore + Playerbots Startup
echo ============================================
echo.


REM ==================================================
REM STEP 1 - Check required files
REM ==================================================

echo [INFO] Checking AzerothCore runtime files...

if not exist "%AC_BIN%\authserver.exe" (
    echo.
    echo [ERROR] authserver.exe was not found.
    echo.
    echo Expected:
    echo %AC_BIN%\authserver.exe
    echo.
    pause
    exit /b 1
)

if not exist "%AC_BIN%\worldserver.exe" (
    echo.
    echo [ERROR] worldserver.exe was not found.
    echo.
    echo Expected:
    echo %AC_BIN%\worldserver.exe
    echo.
    pause
    exit /b 1
)

echo [OK] AzerothCore binaries found.
echo.


REM ==================================================
REM STEP 2 - Check MySQL
REM ==================================================

echo [INFO] Checking MySQL84...

sc query MySQL84 | find /I "RUNNING" >nul

if errorlevel 1 (
    echo [INFO] MySQL84 is stopped.
    echo [INFO] Attempting to start MySQL84...

    net start MySQL84

    if errorlevel 1 (
        echo.
        echo [ERROR] Could not start MySQL84.
        echo.
        echo Try running this BAT file as Administrator
        echo or start the MySQL84 service manually.
        echo.
        pause
        exit /b 1
    )
)

echo [OK] MySQL84 is running.
echo.


REM ==================================================
REM STEP 3 - Start AuthServer
REM ==================================================

tasklist /FI "IMAGENAME eq authserver.exe" | find /I "authserver.exe" >nul

if not errorlevel 1 (
    echo [INFO] AuthServer is already running.
) else (
    echo [INFO] Starting AuthServer...

    start "AzerothCore - AuthServer" /D "%AC_BIN%" authserver.exe
)

echo [INFO] Waiting for AuthServer port %AUTH_PORT%...

set /a WAIT_COUNT=0


:WAIT_AUTH_PORT

powershell -NoProfile -Command ^
    "if (Test-NetConnection -ComputerName '127.0.0.1' -Port %AUTH_PORT% -InformationLevel Quiet -WarningAction SilentlyContinue) { exit 0 } else { exit 1 }"

if not errorlevel 1 goto AUTH_READY

set /a WAIT_COUNT+=1

if !WAIT_COUNT! GEQ 30 goto AUTH_TIMEOUT

timeout /t 1 /nobreak >nul
goto WAIT_AUTH_PORT


:AUTH_READY

echo [OK] AuthServer port %AUTH_PORT% is open.
echo.


REM ==================================================
REM STEP 4 - Start WorldServer
REM ==================================================

tasklist /FI "IMAGENAME eq worldserver.exe" | find /I "worldserver.exe" >nul

if not errorlevel 1 (
    echo [INFO] WorldServer is already running.
) else (
    echo [INFO] Starting WorldServer...

    start "AzerothCore - WorldServer" /D "%AC_BIN%" worldserver.exe
)

echo [INFO] Waiting for WorldServer port %WORLD_PORT%...

set /a WAIT_COUNT=0


:WAIT_WORLD_PORT

powershell -NoProfile -Command ^
    "if (Test-NetConnection -ComputerName '127.0.0.1' -Port %WORLD_PORT% -InformationLevel Quiet -WarningAction SilentlyContinue) { exit 0 } else { exit 1 }"

if not errorlevel 1 goto WORLD_READY

set /a WAIT_COUNT+=1

if !WAIT_COUNT! GEQ 120 goto WORLD_TIMEOUT

timeout /t 1 /nobreak >nul
goto WAIT_WORLD_PORT


:WORLD_READY

echo [OK] WorldServer port %WORLD_PORT% is open.
echo.


REM ==================================================
REM STEP 5 - Wait for SOAP
REM ==================================================

echo [INFO] Waiting for SOAP port %SOAP_PORT%...

set /a WAIT_COUNT=0


:WAIT_SOAP

powershell -NoProfile -Command ^
    "if (Test-NetConnection -ComputerName '127.0.0.1' -Port %SOAP_PORT% -InformationLevel Quiet -WarningAction SilentlyContinue) { exit 0 } else { exit 1 }"

if not errorlevel 1 goto SOAP_READY

set /a WAIT_COUNT+=1

if !WAIT_COUNT! GEQ 120 goto SOAP_TIMEOUT

timeout /t 1 /nobreak >nul
goto WAIT_SOAP


:SOAP_READY

echo [OK] SOAP port %SOAP_PORT% is open.
echo.


REM ==================================================
REM STEP 6 - Verify SOAP command access
REM ==================================================

echo [INFO] Verifying WorldServer command access...

powershell -NoProfile -ExecutionPolicy Bypass ^
    -File "%~dp0Send-AcoreCommand.ps1" ^
    -Command "server info" >nul 2>&1

if errorlevel 1 (
    echo [WARNING] SOAP port is open but server commands
    echo could not be verified.
    echo.
    echo The server may still be usable, but check:
    echo     Send-AcoreCommand.ps1
    echo     soap-secrets.txt
    echo.
) else (
    echo [OK] WorldServer SOAP commands are working.
    echo.
)


REM ==================================================
REM COMPLETE
REM ==================================================

echo ============================================
echo              Startup Complete
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
echo Playerbots are now loading into the world.
echo.
echo Run Server-Status.bat to check:
echo.
echo     Characters in world: 500
echo.
echo before logging into WoW if you want the full
echo bot population available.
echo.

pause
endlocal
exit /b 0


REM ==================================================
REM ERROR HANDLERS
REM ==================================================

:AUTH_TIMEOUT

echo.
echo ============================================
echo             STARTUP FAILED
echo ============================================
echo.
echo [ERROR] AuthServer did not open port %AUTH_PORT%
echo within 30 seconds.
echo.
echo Check the AuthServer window for errors.
echo.
pause
endlocal
exit /b 1


:WORLD_TIMEOUT

echo.
echo ============================================
echo             STARTUP FAILED
echo ============================================
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
echo ============================================
echo             STARTUP WARNING
echo ============================================
echo.
echo [ERROR] SOAP did not open port %SOAP_PORT%
echo within 120 seconds.
echo.
echo WorldServer may still be loading or SOAP may
echo not be enabled.
echo.
echo Check worldserver.conf and the WorldServer window.
echo.
pause
endlocal
exit /b 1