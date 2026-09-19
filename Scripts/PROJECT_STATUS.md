# Azeroth Bots — Project Checkpoint

Last known working state: September 19, 2026

## Current milestone

AzerothCore + Playerbots is working end-to-end.

- AzerothCore Playerbot branch compiled successfully.
- `mod-playerbots` compiled successfully.
- MySQL 8.4.11 is installed and working.
- OpenSSL 3.5.8 is installed and on PATH.
- Boost 1.81 is installed at `C:/local/boost_1_81_0`.
- Visual Studio 2026 is installed with the v143 / VS 2022 C++ toolset.
- CMake 4.4.3 is installed.
- Server data (`dbc`, `maps`, `vmaps`, `mmaps`, `Cameras`) is installed.
- AuthServer and WorldServer start successfully.
- SOAP remote administration is enabled locally on `127.0.0.1:7878`.
- 500/500 random Playerbots log in.
- WoW 3.3.5a client connects from the main PC.
- A player character was created successfully.
- `/who` showed 501 people: the player plus 500 bots.
- Server lifecycle automation is working through BAT/PowerShell scripts.

## Project paths

Outer project repo:

`C:\Users\Klemkosky\Desktop\Azeroth Bots`

AzerothCore source:

`C:\Users\Klemkosky\Desktop\Azeroth Bots\AzerothCore\azerothcore-wotlk`

Runtime binaries:

`C:\Users\Klemkosky\Desktop\Azeroth Bots\AzerothCore\azerothcore-wotlk\build\bin\RelWithDebInfo`

Runtime configs:

`...\build\bin\RelWithDebInfo\configs`

Server data:

`...\build\bin\RelWithDebInfo\Data`

Scripts:

`C:\Users\Klemkosky\Desktop\Azeroth Bots\scripts`

## Git setup

The outer repository intentionally ignores:

- `AzerothCore/`
- `Installs/`
- `scripts/soap-secrets.txt`

The `scripts/` directory and this checkpoint file should be committed to the outer repository.

Never commit passwords, credentials, or `soap-secrets.txt`.

## Database setup

MySQL service:

`MySQL84`

Databases:

- `acore_auth`
- `acore_characters`
- `acore_world`
- `acore_playerbots`

AzerothCore database user:

`acore`

Do not store database or game-account passwords in this repository.

## Realm/network

Server PC LAN IP:

`192.168.1.115`

Realm port:

`8085`

Authentication port:

`3724`

SOAP port:

`7878`

SOAP bind address:

`127.0.0.1`

Realm database entry:

- Name: `AzerothCore`
- Address: `192.168.1.115`
- Port: `8085`
- Game build: `12340`
- Flag: `0`

Main PC WoW client `realmlist.wtf`:

`set realmlist 192.168.1.115`

WoW client version:

`3.3.5a / build 12340`

## Game accounts

Player account username:

`Sebs`

SOAP automation account:

`ServerAdmin`

Passwords are intentionally not documented here.

The SOAP automation account requires administrator access for remote command execution.

## Shared environment configuration

The file:

`scripts\server-env.bat`

is the single source of truth for shared paths, ports, build settings, and runtime dependency locations.

Current key settings:

- `PROJECT_ROOT=C:\Users\Klemkosky\Desktop\Azeroth Bots`
- `AC_ROOT=%PROJECT_ROOT%\AzerothCore\azerothcore-wotlk`
- `AC_BUILD=%AC_ROOT%\build`
- `AC_BIN=%AC_BUILD%\bin\RelWithDebInfo`
- `AC_CONFIG=%AC_BIN%\configs`
- `AC_DATA=%AC_BIN%\Data`
- `BOOST_ROOT=C:/local/boost_1_81_0`
- `SERVER_IP=192.168.1.115`
- `AUTH_PORT=3724`
- `WORLD_PORT=8085`
- `SOAP_PORT=7878`
- `CMAKE_GENERATOR=Visual Studio 18 2026`
- `CMAKE_TOOLSET=v143`
- `BUILD_CONFIG=RelWithDebInfo`
- `BUILD_JOBS=4`

Runtime dependency paths are also centralized there for:

- `libmysql.dll`
- `legacy.dll`
- `libcrypto-3-x64.dll`
- `libssl-3-x64.dll`

## Server management scripts

### Main control center

Run:

`scripts\Azeroth-Bots.bat`

Current menu functions:

1. Start Server
2. Stop Server
3. Restart Server
4. Server Status
5. Open Configs
6. Rebuild AzerothCore
7. Open Project Folder
8. Open AzerothCore Runtime Folder
9. Exit

### Start-Server.bat

Starts the server safely and verifies readiness.

Flow:

1. Verify `authserver.exe` and `worldserver.exe`.
2. Ensure MySQL84 is running.
3. Start AuthServer if needed.
4. Wait for port `3724`.
5. Start WorldServer if needed.
6. Wait for port `8085`.
7. Wait for SOAP port `7878`.
8. Verify SOAP command access with `server info`.
9. Report startup success.

### Stop-Server.bat

Performs an automated clean shutdown.

Flow:

1. Send `server shutdown 1` to WorldServer through SOAP.
2. Wait for WorldServer to exit cleanly.
3. Force-stop AuthServer after WorldServer is safely down.
4. Verify AuthServer stopped.
5. Leave MySQL84 running.

### Restart-Server.bat

Performs a complete clean restart.

Flow:

1. Cleanly stop WorldServer through SOAP.
2. Stop AuthServer.
3. Ensure MySQL84 is running.
4. Start AuthServer.
5. Wait for port `3724`.
6. Start WorldServer.
7. Wait for port `8085`.
8. Wait for SOAP using `%SOAP_PORT%`.
9. Report restart success.

This flow has been tested successfully.

### Server-Status.bat

Checks:

- MySQL84 process state
- AuthServer process state
- WorldServer process state
- Server IP
- Auth port
- World port
- SOAP port
- Port open/closed state
- SOAP `server info`
- Connected real players
- Characters in world
- Server uptime
- Update-time statistics

A known-good status showed:

- MySQL84: RUNNING
- AuthServer: RUNNING
- WorldServer: RUNNING
- AuthServer port 3724: OPEN
- WorldServer port 8085: OPEN
- SOAP port 7878: OPEN
- Connected players: 0
- Characters in world: 500

### Rebuild-Server.bat

Automates the rebuild workflow.

Flow:

1. Detect whether the server was running.
2. Cleanly stop WorldServer through SOAP.
3. Stop AuthServer.
4. Verify AzerothCore source/build paths.
5. Create the build directory if it does not exist.
6. Configure CMake using values from `server-env.bat`.
7. Build `ALL_BUILD` using `RelWithDebInfo`.
8. Refresh MySQL/OpenSSL runtime DLLs automatically.
9. If the server was running before the rebuild, ask whether to start it again.

Current build settings:

- Generator: Visual Studio 18 2026
- Architecture: x64
- Toolset: v143
- Configuration: RelWithDebInfo
- Tools: all
- Warnings: disabled
- Parallel jobs: 4

### Open-Configs.bat

Provides shortcuts for:

- `worldserver.conf`
- `playerbots.conf`
- `authserver.conf`
- Config folder
- Runtime folder
- Logs folder
- AzerothCore source folder
- Project folder

### Send-AcoreCommand.ps1

SOAP helper used by the BAT scripts.

It:

- reads credentials from ignored `soap-secrets.txt`
- reads the SOAP port from the inherited `SOAP_PORT` environment variable
- falls back to port `7878` if the environment variable is missing
- sends AzerothCore console commands through local SOAP
- parses and displays command results

A known-good test command is:

`server info`

## SOAP configuration

`worldserver.conf` currently uses:

```ini
SOAP.Enabled = 1
SOAP.IP = "127.0.0.1"
SOAP.Port = 7878
```

SOAP is intentionally bound to localhost only.

The local credentials file is:

`scripts\soap-secrets.txt`

It is ignored by Git and must never be committed.

## Important runtime files

The runtime directory contains:

- `authserver.exe`
- `worldserver.exe`
- `dbimport.exe`
- `map_extractor.exe`
- `vmap4_extractor.exe`
- `vmap4_assembler.exe`
- `mmaps_generator.exe`
- `libmysql.dll`
- `legacy.dll`
- `libcrypto-3-x64.dll`
- `libssl-3-x64.dll`

Active configs:

- `configs\authserver.conf`
- `configs\worldserver.conf`
- `configs\modules\playerbots.conf`

## Test checklist before moving on

Run these tests in order.

### 1. Start test

Run:

`scripts\Start-Server.bat`

Expected:

- MySQL84 running
- AuthServer port 3724 open
- WorldServer port 8085 open
- SOAP port 7878 open
- SOAP command verification succeeds
- Playerbots begin logging in

### 2. Status test

Run:

`scripts\Server-Status.bat`

Expected:

- MySQL84 RUNNING
- AuthServer RUNNING
- WorldServer RUNNING
- Ports 3724, 8085, and 7878 OPEN
- `server info` returns successfully
- Characters in world reaches 500

### 3. Restart test

Run:

`scripts\Restart-Server.bat`

Expected:

- WorldServer cleanly shuts down through SOAP
- AuthServer stops
- MySQL remains running
- AuthServer restarts
- WorldServer restarts
- all three ports return OPEN
- restart completes successfully

### 4. Status-after-restart test

Run:

`scripts\Server-Status.bat`

Expected:

- all services/ports healthy again
- server info works
- bots begin returning to 500 online

### 5. Stop test

Run:

`scripts\Stop-Server.bat`

Expected:

- WorldServer cleanly shuts down
- AuthServer stops
- MySQL84 remains running

### 6. Stopped-status test

Run:

`scripts\Server-Status.bat`

Expected:

- MySQL84 RUNNING
- AuthServer STOPPED
- WorldServer STOPPED
- ports 3724, 8085, and 7878 CLOSED

### 7. Rebuild test

Only run when desired because a full rebuild can take significant time.

Run:

`scripts\Rebuild-Server.bat`

Expected:

- running servers stop cleanly first
- CMake configuration succeeds
- build succeeds
- runtime dependencies are refreshed
- optional restart works

## Next project milestone

After the server-management test checklist passes, stop adding infrastructure and resume the actual bot project:

1. Discover/test current Playerbots command syntax.
2. Create a deliberately controlled bot party.
3. Test follow, stay, combat, travel, role, and grouping behavior.
4. Test dungeon behavior.
5. Identify which Playerbots commands can be driven through SOAP.
6. Define the interface between Playerbots and the custom controller.
7. Begin the overseer dashboard.
8. Later add hardcore death tracking, strategy iterations, combat logs, and raid-attempt analysis.

## Notes

The server produced occasional `MoveSplineInitArgs::Validate` velocity messages while bots were online. They did not prevent the server from running or the 500 bots from logging in.

The WoW client initially black-screened in windowed mode. A safe troubleshooting resolution was 1920x1080 windowed on the 4K monitor.

The main PC successfully connected to the server PC over LAN using `192.168.1.115`.

The management scripts are intended to keep MySQL84 running between AzerothCore sessions.
