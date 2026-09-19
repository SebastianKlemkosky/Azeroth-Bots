@echo off
setlocal
title Azeroth Bots - Control Center

call "%~dp0server-env.bat"


:MENU

cls

echo ==================================================
echo.
echo              AZEROTH BOTS CONTROL CENTER
echo.
echo ==================================================
echo.
echo   Server IP:  %SERVER_IP%
echo.
echo --------------------------------------------------
echo.
echo   [1] Start Server
echo.
echo   [2] Stop Server
echo.
echo   [3] Restart Server
echo.
echo   [4] Server Status
echo.
echo   [5] Open Configs
echo.
echo   [6] Rebuild AzerothCore
echo.
echo   [7] Open Project Folder
echo.
echo   [8] Open AzerothCore Runtime Folder
echo.
echo   [9] Exit
echo.
echo ==================================================
echo.

choice /C 123456789 /N /M "Select an option: "


REM ==================================================
REM Handle Selection
REM ==================================================

if errorlevel 9 goto EXIT
if errorlevel 8 goto OPEN_RUNTIME
if errorlevel 7 goto OPEN_PROJECT
if errorlevel 6 goto REBUILD
if errorlevel 5 goto CONFIGS
if errorlevel 4 goto STATUS
if errorlevel 3 goto RESTART
if errorlevel 2 goto STOP
if errorlevel 1 goto START



REM ==================================================
REM START SERVER
REM ==================================================

:START

cls

echo ==================================================
echo                START SERVER
echo ==================================================
echo.

call "%~dp0Start-Server.bat"

goto MENU



REM ==================================================
REM STOP SERVER
REM ==================================================

:STOP

cls

echo ==================================================
echo                 STOP SERVER
echo ==================================================
echo.

call "%~dp0Stop-Server.bat"

goto MENU



REM ==================================================
REM RESTART SERVER
REM ==================================================

:RESTART

cls

echo ==================================================
echo               RESTART SERVER
echo ==================================================
echo.

call "%~dp0Restart-Server.bat"

goto MENU



REM ==================================================
REM STATUS
REM ==================================================

:STATUS

cls

call "%~dp0Server-Status.bat"

goto MENU



REM ==================================================
REM CONFIG FILES
REM ==================================================

:CONFIGS

cls

echo ==================================================
echo                  CONFIG FILES
echo ==================================================
echo.

if exist "%~dp0Open-Configs.bat" (

    call "%~dp0Open-Configs.bat"

) else (

    echo [ERROR] Open-Configs.bat was not found.
    echo.
    pause
)

goto MENU



REM ==================================================
REM REBUILD
REM ==================================================

:REBUILD

cls

echo ==================================================
echo              REBUILD AZEROTHCORE
echo ==================================================
echo.
echo This will rebuild AzerothCore + Playerbots.
echo.
echo It is recommended that WorldServer and
echo AuthServer are stopped before rebuilding.
echo.

choice /C YN /N /M "Continue with rebuild? [Y/N]: "

if errorlevel 2 goto MENU

call "%~dp0Rebuild-Server.bat"

goto MENU



REM ==================================================
REM OPEN PROJECT FOLDER
REM ==================================================

:OPEN_PROJECT

echo Opening project folder...

start "" "%PROJECT_ROOT%"

timeout /t 1 /nobreak >nul

goto MENU



REM ==================================================
REM OPEN RUNTIME FOLDER
REM ==================================================

:OPEN_RUNTIME

echo Opening AzerothCore runtime folder...

start "" "%AC_BIN%"

timeout /t 1 /nobreak >nul

goto MENU



REM ==================================================
REM EXIT
REM ==================================================

:EXIT

cls

echo ==================================================
echo.
echo              AZEROTH BOTS CONTROL CENTER
echo.
echo ==================================================
echo.
echo Control Center closed.
echo.

timeout /t 1 /nobreak >nul

endlocal
exit /b 0