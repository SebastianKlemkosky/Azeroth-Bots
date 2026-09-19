@echo off
setlocal
title Azeroth Bots - Config Menu

call "%~dp0server-env.bat"


:MENU

cls

echo ==================================================
echo.
echo              AZEROTH BOTS CONFIG MENU
echo.
echo ==================================================
echo.
echo   [1] Open worldserver.conf
echo.
echo   [2] Open playerbots.conf
echo.
echo   [3] Open authserver.conf
echo.
echo   [4] Open Config Folder
echo.
echo   [5] Open Runtime Folder
echo.
echo   [6] Open Logs Folder
echo.
echo   [7] Open AzerothCore Source
echo.
echo   [8] Open Project Folder
echo.
echo   [9] Back
echo.
echo ==================================================
echo.

choice /C 123456789 /N /M "Select an option: "


if errorlevel 9 goto EXIT
if errorlevel 8 goto PROJECT
if errorlevel 7 goto SOURCE
if errorlevel 6 goto LOGS
if errorlevel 5 goto RUNTIME
if errorlevel 4 goto CONFIG_FOLDER
if errorlevel 3 goto AUTH_CONFIG
if errorlevel 2 goto PLAYERBOTS_CONFIG
if errorlevel 1 goto WORLD_CONFIG



:WORLD_CONFIG

if not exist "%AC_CONFIG%\worldserver.conf" (
    echo.
    echo [ERROR] worldserver.conf was not found.
    echo.
    pause
    goto MENU
)

start "" notepad "%AC_CONFIG%\worldserver.conf"

goto MENU



:PLAYERBOTS_CONFIG

if not exist "%AC_CONFIG%\modules\playerbots.conf" (
    echo.
    echo [ERROR] playerbots.conf was not found.
    echo.
    pause
    goto MENU
)

start "" notepad "%AC_CONFIG%\modules\playerbots.conf"

goto MENU



:AUTH_CONFIG

if not exist "%AC_CONFIG%\authserver.conf" (
    echo.
    echo [ERROR] authserver.conf was not found.
    echo.
    pause
    goto MENU
)

start "" notepad "%AC_CONFIG%\authserver.conf"

goto MENU



:CONFIG_FOLDER

if exist "%AC_CONFIG%" (
    start "" "%AC_CONFIG%"
) else (
    echo.
    echo [ERROR] Config folder was not found.
    echo.
    pause
)

goto MENU



:RUNTIME

if exist "%AC_BIN%" (
    start "" "%AC_BIN%"
) else (
    echo.
    echo [ERROR] Runtime folder was not found.
    echo.
    pause
)

goto MENU



:LOGS

if exist "%AC_BIN%\logs" (
    start "" "%AC_BIN%\logs"
) else (
    echo.
    echo [INFO] Logs folder does not exist yet.
    echo.
    echo Expected:
    echo %AC_BIN%\logs
    echo.
    pause
)

goto MENU



:SOURCE

if exist "%AC_ROOT%" (
    start "" "%AC_ROOT%"
) else (
    echo.
    echo [ERROR] AzerothCore source folder was not found.
    echo.
    pause
)

goto MENU



:PROJECT

if exist "%PROJECT_ROOT%" (
    start "" "%PROJECT_ROOT%"
) else (
    echo.
    echo [ERROR] Project folder was not found.
    echo.
    pause
)

goto MENU



:EXIT

endlocal
exit /b 0