@echo off
setlocal EnableDelayedExpansion

title Azeroth Bots - Rebuild Server

call "%~dp0server-env.bat"

echo ============================================
echo        AzerothCore + Playerbots Rebuild
echo ============================================
echo.

REM ==================================================
REM STEP 1 - Detect current server state
REM ==================================================

set "SERVER_WAS_RUNNING=0"

tasklist /FI "IMAGENAME eq worldserver.exe" | find /I "worldserver.exe" >nul

if not errorlevel 1 (
set "SERVER_WAS_RUNNING=1"
)

tasklist /FI "IMAGENAME eq authserver.exe" | find /I "authserver.exe" >nul

if not errorlevel 1 (
set "SERVER_WAS_RUNNING=1"
)

REM ==================================================
REM STEP 2 - Stop WorldServer cleanly if needed
REM ==================================================

tasklist /FI "IMAGENAME eq worldserver.exe" | find /I "worldserver.exe" >nul

if errorlevel 1 (
echo [OK] WorldServer is already stopped.
goto STOP_AUTH
)

echo [INFO] WorldServer is running.
echo [INFO] Sending clean shutdown command through SOAP...

powershell -NoProfile -ExecutionPolicy Bypass ^
-File "%~dp0Send-AcoreCommand.ps1" ^
-Command "server shutdown 1"

if errorlevel 1 (
echo.
echo [ERROR] Could not send the shutdown command through SOAP.
echo Rebuild cancelled.
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
echo Rebuild cancelled.
echo.
pause
exit /b 1

REM ==================================================
REM STEP 3 - Stop AuthServer
REM ==================================================

:STOP_AUTH

tasklist /FI "IMAGENAME eq authserver.exe" | find /I "authserver.exe" >nul

if errorlevel 1 (
echo [OK] AuthServer is already stopped.
goto CHECK_BUILD
)

echo [INFO] Stopping AuthServer...

taskkill /F /IM authserver.exe >nul 2>&1

set /a AUTH_WAIT=0

:WAIT_AUTH

tasklist /FI "IMAGENAME eq authserver.exe" | find /I "authserver.exe" >nul

if errorlevel 1 goto AUTH_STOPPED

set /a AUTH_WAIT+=1

if !AUTH_WAIT! GEQ 10 goto AUTH_STOP_FAILED

timeout /t 1 /nobreak >nul
goto WAIT_AUTH

:AUTH_STOPPED

echo [OK] AuthServer stopped.
echo.

goto CHECK_BUILD

:AUTH_STOP_FAILED

echo.
echo [ERROR] AuthServer did not stop.
echo Rebuild cancelled.
echo.
pause
exit /b 1

REM ==================================================
REM STEP 4 - Verify source/build paths
REM ==================================================

:CHECK_BUILD

if not exist "%AC_ROOT%\CMakeLists.txt" (
echo.
echo [ERROR] AzerothCore source was not found.
echo.
echo Expected:
echo %AC_ROOT%
echo.
pause
exit /b 1
)

if not exist "%AC_BUILD%" (
echo [INFO] Build directory does not exist.
echo [INFO] Creating:
echo %AC_BUILD%


mkdir "%AC_BUILD%"


)

echo [OK] AzerothCore source found.
echo.

echo Build settings:
echo   Generator:     %CMAKE_GENERATOR%
echo   Toolset:       %CMAKE_TOOLSET%
echo   Configuration: %BUILD_CONFIG%
echo   Parallel jobs: %BUILD_JOBS%
echo.

REM ==================================================
REM STEP 5 - Configure CMake
REM ==================================================

echo ============================================
echo              Configuring CMake
echo ============================================
echo.

pushd "%AC_ROOT%"

cmake -S . -B build ^
-G "%CMAKE_GENERATOR%" ^
-A x64 ^
-T %CMAKE_TOOLSET% ^
-DTOOLS_BUILD=all ^
-DWITH_WARNINGS=0

if errorlevel 1 (
echo.
echo ============================================
echo              CONFIGURE FAILED
echo ============================================
echo.
echo CMake configuration failed.
echo Server will NOT be restarted.
echo.
popd
pause
exit /b 1
)

echo.
echo [OK] CMake configuration completed.
echo.

REM ==================================================
REM STEP 6 - Build
REM ==================================================

echo ============================================
echo                  Building
echo ============================================
echo.

cmake --build build ^
--config %BUILD_CONFIG% ^
--target ALL_BUILD ^
--parallel %BUILD_JOBS%

if errorlevel 1 (
echo.
echo ============================================
echo                BUILD FAILED
echo ============================================
echo.
echo AzerothCore / Playerbots build failed.
echo Server will NOT be restarted.
echo.
popd
pause
exit /b 1
)

popd

echo.
echo ============================================
echo               BUILD SUCCEEDED
echo ============================================
echo.

REM ==================================================
REM STEP 7 - Refresh runtime dependencies
REM ==================================================

echo [INFO] Refreshing runtime dependencies...

if not exist "%MYSQL_DLL%" (
echo.
echo [ERROR] libmysql.dll was not found:
echo %MYSQL_DLL%
echo.
echo Server will NOT be restarted.
echo.
pause
exit /b 1
)

if not exist "%OPENSSL_LEGACY%" (
echo.
echo [ERROR] legacy.dll was not found:
echo %OPENSSL_LEGACY%
echo.
echo Server will NOT be restarted.
echo.
pause
exit /b 1
)

if not exist "%OPENSSL_CRYPTO%" (
echo.
echo [ERROR] libcrypto-3-x64.dll was not found:
echo %OPENSSL_CRYPTO%
echo.
echo Server will NOT be restarted.
echo.
pause
exit /b 1
)

if not exist "%OPENSSL_SSL%" (
echo.
echo [ERROR] libssl-3-x64.dll was not found:
echo %OPENSSL_SSL%
echo.
echo Server will NOT be restarted.
echo.
pause
exit /b 1
)

copy /Y "%MYSQL_DLL%" "%AC_BIN%\libmysql.dll" >nul

if errorlevel 1 goto DEPENDENCY_COPY_FAILED

copy /Y "%OPENSSL_LEGACY%" "%AC_BIN%\legacy.dll" >nul

if errorlevel 1 goto DEPENDENCY_COPY_FAILED

copy /Y "%OPENSSL_CRYPTO%" "%AC_BIN%\libcrypto-3-x64.dll" >nul

if errorlevel 1 goto DEPENDENCY_COPY_FAILED

copy /Y "%OPENSSL_SSL%" "%AC_BIN%\libssl-3-x64.dll" >nul

if errorlevel 1 goto DEPENDENCY_COPY_FAILED

echo [OK] Runtime dependencies refreshed.
echo.

REM ==================================================
REM STEP 8 - Restart option
REM ==================================================

if "%SERVER_WAS_RUNNING%"=="0" (
echo The server was not running before the rebuild.
echo It will remain stopped.
echo.
goto DONE
)

echo The server was running before the rebuild.
echo.

choice /C YN /N /M "Start the server again now? [Y/N]: "

if errorlevel 2 goto DONE

echo.
echo [INFO] Starting AzerothCore...
echo.

call "%~dp0Start-Server.bat"

goto DONE

REM ==================================================
REM ERROR - Dependency copy failed
REM ==================================================

:DEPENDENCY_COPY_FAILED

echo.
echo ============================================
echo          DEPENDENCY COPY FAILED
echo ============================================
echo.
echo One of the required runtime DLLs could not
echo be copied into:
echo.
echo %AC_BIN%
echo.
echo Server will NOT be restarted.
echo.

pause

endlocal
exit /b 1

REM ==================================================
REM COMPLETE
REM ==================================================

:DONE

echo.
echo ============================================
echo              Rebuild Complete
echo ============================================
echo.

pause

endlocal
exit /b 0
