@echo off
setlocal
title Azeroth Bots - Server Status

call "%~dp0server-env.bat"

echo ============================================
echo          AzerothCore Server Status
echo ============================================
echo.


REM ==================================================
REM MySQL
REM ==================================================

sc query MySQL84 | find /I "RUNNING" >nul

if errorlevel 1 (
    echo MySQL84:       STOPPED
) else (
    echo MySQL84:       RUNNING
)


REM ==================================================
REM AuthServer
REM ==================================================

tasklist /FI "IMAGENAME eq authserver.exe" | find /I "authserver.exe" >nul

if errorlevel 1 (
    echo AuthServer:    STOPPED
    set "AUTH_RUNNING=0"
) else (
    echo AuthServer:    RUNNING
    set "AUTH_RUNNING=1"
)


REM ==================================================
REM WorldServer
REM ==================================================

tasklist /FI "IMAGENAME eq worldserver.exe" | find /I "worldserver.exe" >nul

if errorlevel 1 (
    echo WorldServer:   STOPPED
    set "WORLD_RUNNING=0"
) else (
    echo WorldServer:   RUNNING
    set "WORLD_RUNNING=1"
)


echo.
echo ============================================
echo              Network Status
echo ============================================
echo.

echo Server IP:      %SERVER_IP%
echo Auth Port:      %AUTH_PORT%
echo World Port:     %WORLD_PORT%
echo SOAP Port:      %SOAP_PORT%
echo.

call :CHECK_PORT "AuthServer" 127.0.0.1 %AUTH_PORT%
call :CHECK_PORT "WorldServer" 127.0.0.1 %WORLD_PORT%
call :CHECK_PORT "SOAP" 127.0.0.1 %SOAP_PORT%

echo.
echo ============================================
echo               Server Info
echo ============================================
echo.

if "%WORLD_RUNNING%"=="0" (
    echo WorldServer is not running.
    goto DONE
)

powershell -NoProfile -ExecutionPolicy Bypass ^
    -File "%~dp0Send-AcoreCommand.ps1" ^
    -Command "server info"

if errorlevel 1 (
    echo.
    echo [WARNING] Could not retrieve server info through SOAP.
)

goto DONE


REM ==================================================
REM Port Check Function
REM ==================================================

:CHECK_PORT

powershell -NoProfile -Command ^
    "if (Test-NetConnection -ComputerName '%~2' -Port %~3 -InformationLevel Quiet -WarningAction SilentlyContinue) { exit 0 } else { exit 1 }"

if errorlevel 1 (
    echo %~1 Port %~3: CLOSED
) else (
    echo %~1 Port %~3: OPEN
)

exit /b


:DONE

echo.
echo ============================================
echo.
pause

endlocal