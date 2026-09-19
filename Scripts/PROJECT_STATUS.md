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
- 500/500 random Playerbots log in.
- WoW 3.3.5a client connects from the main PC.
- A player character was created successfully.
- `/who` showed 501 people: the player plus 500 bots.

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

## Git setup

The outer repository intentionally ignores:

- `AzerothCore/`
- `Installs/`

The `scripts/` directory and this checkpoint file should be committed to the outer repository.

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

## Game account

Current account username:

`Sebs`

Password is intentionally not documented here.

GM level was intended to be set to level 3 for all realms.

## Starting the server

Preferred:

1. Run `scripts\Start-Server.bat`.
2. AuthServer starts first.
3. WorldServer starts after a short delay.
4. Wait for WorldServer to finish loading and for the random bot population to come online.
5. Start WoW on the main PC.

## Stopping the server

Preferred clean shutdown:

1. Press `Ctrl+C` in the WorldServer console.
2. Wait for WorldServer to exit.
3. Press `Ctrl+C` in the AuthServer console.

`scripts\Stop-Server.bat` also provides a taskkill fallback.

## Rebuilding after source changes

Run:

`scripts\Rebuild-Server.bat`

Current build settings:

- Generator: Visual Studio 18 2026
- Architecture: x64
- Toolset: v143
- Configuration: RelWithDebInfo
- Tools: all
- Warnings: disabled
- Parallel jobs: 4

## Important runtime files

The runtime directory currently contains the required DLLs:

- `libmysql.dll`
- `legacy.dll`
- `libcrypto-3-x64.dll`
- `libssl-3-x64.dll`

Active configs:

- `configs\authserver.conf`
- `configs\worldserver.conf`
- `configs\modules\playerbots.conf`

## Next project milestone

Resume here:

1. Learn/test the current Playerbots command syntax.
2. Create a controllable party of bots.
3. Test follow / combat / travel / dungeon behavior.
4. Define the interface between Playerbots and the custom controller.
5. Begin the overseer dashboard.
6. Later add hardcore death tracking, strategy iterations, combat logs, and raid-attempt analysis.

## Notes

The server produced occasional `MoveSplineInitArgs::Validate` velocity messages while bots were online. They did not prevent the server from running or the 500 bots from logging in.

The WoW client initially black-screened in windowed mode. A safe troubleshooting resolution was 1920x1080 windowed on the 4K monitor.
