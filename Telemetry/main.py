import json
import sqlite3
from datetime import datetime
from pathlib import Path

import mysql.connector


RACES = {
    1: "Human",
    2: "Orc",
    3: "Dwarf",
    4: "Night Elf",
    5: "Undead",
    6: "Tauren",
    7: "Gnome",
    8: "Troll",
    10: "Blood Elf",
    11: "Draenei",
}

CLASSES = {
    1: "Warrior",
    2: "Paladin",
    3: "Hunter",
    4: "Rogue",
    5: "Priest",
    6: "Death Knight",
    7: "Shaman",
    8: "Mage",
    9: "Warlock",
    11: "Druid",
}


print("====================================")
print("      Azeroth Bots Telemetry")
print("====================================")
print()


# --------------------------------------------------
# Paths
# --------------------------------------------------

script_directory = Path(__file__).resolve().parent
project_directory = script_directory.parent

config_path = script_directory / "config.json"
database_path = project_directory / "data" / "overseer.db"

database_path.parent.mkdir(parents=True, exist_ok=True)


mysql_connection = None
mysql_cursor = None
sqlite_connection = None


try:
    # --------------------------------------------------
    # Load config
    # --------------------------------------------------

    with open(config_path, "r", encoding="utf-8") as config_file:
        config = json.load(config_file)

    mysql_config = config["mysql"]


    # --------------------------------------------------
    # Connect to AzerothCore
    # --------------------------------------------------

    mysql_connection = mysql.connector.connect(
        host=mysql_config["host"],
        port=mysql_config["port"],
        user=mysql_config["user"],
        password=mysql_config["password"],
        database=mysql_config["database"],
    )

    print("[OK] Connected to AzerothCore.")


    # --------------------------------------------------
    # Connect to telemetry database
    # --------------------------------------------------

    sqlite_connection = sqlite3.connect(database_path)

    print("[OK] Connected to overseer.db.")
    print()


    # --------------------------------------------------
    # Permanent bot identities
    # --------------------------------------------------

    sqlite_connection.execute(
        """
        CREATE TABLE IF NOT EXISTS bots (
            bot_id INTEGER PRIMARY KEY AUTOINCREMENT,
            character_guid INTEGER NOT NULL UNIQUE,
            account_id INTEGER NOT NULL,
            account_name TEXT NOT NULL,
            name TEXT NOT NULL,
            race_id INTEGER NOT NULL,
            race_name TEXT NOT NULL,
            class_id INTEGER NOT NULL,
            class_name TEXT NOT NULL,
            first_seen TEXT NOT NULL,
            last_seen TEXT NOT NULL
        )
        """
    )


    # --------------------------------------------------
    # Latest known state for each bot
    # --------------------------------------------------

    sqlite_connection.execute(
        """
        CREATE TABLE IF NOT EXISTS bot_state (
            bot_id INTEGER PRIMARY KEY,
            level INTEGER NOT NULL,
            xp INTEGER NOT NULL,
            money INTEGER NOT NULL,
            map_id INTEGER NOT NULL,
            zone_id INTEGER NOT NULL,
            position_x REAL NOT NULL,
            position_y REAL NOT NULL,
            position_z REAL NOT NULL,
            health INTEGER NOT NULL,
            online INTEGER NOT NULL,
            total_time INTEGER NOT NULL,
            level_time INTEGER NOT NULL,
            last_updated TEXT NOT NULL,

            FOREIGN KEY (bot_id)
                REFERENCES bots(bot_id)
        )
        """
    )


    # --------------------------------------------------
    # Permanent event history
    # --------------------------------------------------

    sqlite_connection.execute(
        """
        CREATE TABLE IF NOT EXISTS events (
            event_id INTEGER PRIMARY KEY AUTOINCREMENT,
            bot_id INTEGER NOT NULL,
            timestamp TEXT NOT NULL,
            event_type TEXT NOT NULL,
            old_value TEXT,
            new_value TEXT,
            details TEXT,

            FOREIGN KEY (bot_id)
                REFERENCES bots(bot_id)
        )
        """
    )

    sqlite_connection.commit()


    # --------------------------------------------------
    # Read the 500 online random bots
    # --------------------------------------------------

    mysql_cursor = mysql_connection.cursor(dictionary=True)

    query = """
        SELECT
            c.guid,
            c.account,
            a.username,
            c.name,
            c.race,
            c.class,
            c.level,
            c.xp,
            c.money,
            c.map,
            c.zone,
            c.position_x,
            c.position_y,
            c.position_z,
            c.health,
            c.online,
            c.totaltime,
            c.leveltime,
            c.creation_date
        FROM acore_characters.characters AS c
        INNER JOIN acore_auth.account AS a
            ON a.id = c.account
        INNER JOIN acore_playerbots.playerbots_account_type AS pat
            ON pat.account_id = c.account
        WHERE pat.account_type = 1
          AND c.online = 1
        ORDER BY c.guid
    """

    mysql_cursor.execute(query)

    bots = mysql_cursor.fetchall()

    print(f"[INFO] Online random bots: {len(bots)}")
    print()


    current_time = datetime.now().isoformat(timespec="seconds")

    new_identities = 0
    level_up_events = 0
    zone_change_events = 0


    # --------------------------------------------------
    # Process every bot
    # --------------------------------------------------

    for bot in bots:
        race_name = RACES.get(
            bot["race"],
            f"Unknown Race {bot['race']}"
        )

        class_name = CLASSES.get(
            bot["class"],
            f"Unknown Class {bot['class']}"
        )


        # --------------------------------------------------
        # Find or create permanent identity
        # --------------------------------------------------

        existing_identity = sqlite_connection.execute(
            """
            SELECT bot_id
            FROM bots
            WHERE character_guid = ?
            """,
            (bot["guid"],),
        ).fetchone()


        if existing_identity is None:
            cursor = sqlite_connection.execute(
                """
                INSERT INTO bots (
                    character_guid,
                    account_id,
                    account_name,
                    name,
                    race_id,
                    race_name,
                    class_id,
                    class_name,
                    first_seen,
                    last_seen
                )
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                """,
                (
                    bot["guid"],
                    bot["account"],
                    bot["username"],
                    bot["name"],
                    bot["race"],
                    race_name,
                    bot["class"],
                    class_name,
                    current_time,
                    current_time,
                ),
            )

            bot_id = cursor.lastrowid
            new_identities += 1

        else:
            bot_id = existing_identity[0]

            sqlite_connection.execute(
                """
                UPDATE bots
                SET last_seen = ?
                WHERE bot_id = ?
                """,
                (
                    current_time,
                    bot_id,
                ),
            )


        # --------------------------------------------------
        # Get previous state
        # --------------------------------------------------

        previous_state = sqlite_connection.execute(
            """
            SELECT
                level,
                xp,
                zone_id,
                health
            FROM bot_state
            WHERE bot_id = ?
            """,
            (bot_id,),
        ).fetchone()


        # --------------------------------------------------
        # Detect changes
        # --------------------------------------------------

        if previous_state is not None:
            previous_level = previous_state[0]
            previous_xp = previous_state[1]
            previous_zone = previous_state[2]
            previous_health = previous_state[3]


            # Level up
            if bot["level"] > previous_level:
                sqlite_connection.execute(
                    """
                    INSERT INTO events (
                        bot_id,
                        timestamp,
                        event_type,
                        old_value,
                        new_value,
                        details
                    )
                    VALUES (?, ?, ?, ?, ?, ?)
                    """,
                    (
                        bot_id,
                        current_time,
                        "LEVEL_UP",
                        str(previous_level),
                        str(bot["level"]),
                        f"{bot['name']} reached level {bot['level']}",
                    ),
                )

                level_up_events += 1

                print(
                    f"[LEVEL UP] "
                    f"{bot['name']}: "
                    f"{previous_level} -> {bot['level']}"
                )


            # Zone change
            if bot["zone"] != previous_zone:
                sqlite_connection.execute(
                    """
                    INSERT INTO events (
                        bot_id,
                        timestamp,
                        event_type,
                        old_value,
                        new_value,
                        details
                    )
                    VALUES (?, ?, ?, ?, ?, ?)
                    """,
                    (
                        bot_id,
                        current_time,
                        "ZONE_CHANGE",
                        str(previous_zone),
                        str(bot["zone"]),
                        f"{bot['name']} changed zones",
                    ),
                )

                zone_change_events += 1
                print(
                    f"[ZONE CHANGE] "
                    f"{bot['name']}: "
                    f"{previous_zone} -> {bot['zone']}"
                )

            # Possible death
            if previous_health > 0 and bot["health"] == 0:
                sqlite_connection.execute(
                    """
                    INSERT INTO events (
                        bot_id,
                        timestamp,
                        event_type,
                        old_value,
                        new_value,
                        details
                    )
                    VALUES (?, ?, ?, ?, ?, ?)
                    """,
                    (
                        bot_id,
                        current_time,
                        "POSSIBLE_DEATH",
                        str(previous_health),
                        "0",
                        f"{bot['name']} reached zero health",
                    ),
                )

                print(
                    f"[POSSIBLE DEATH] {bot['name']}"
                )


        # --------------------------------------------------
        # Save latest state
        # --------------------------------------------------

        sqlite_connection.execute(
            """
            INSERT INTO bot_state (
                bot_id,
                level,
                xp,
                money,
                map_id,
                zone_id,
                position_x,
                position_y,
                position_z,
                health,
                online,
                total_time,
                level_time,
                last_updated
            )
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)

            ON CONFLICT(bot_id)
            DO UPDATE SET
                level = excluded.level,
                xp = excluded.xp,
                money = excluded.money,
                map_id = excluded.map_id,
                zone_id = excluded.zone_id,
                position_x = excluded.position_x,
                position_y = excluded.position_y,
                position_z = excluded.position_z,
                health = excluded.health,
                online = excluded.online,
                total_time = excluded.total_time,
                level_time = excluded.level_time,
                last_updated = excluded.last_updated
            """,
            (
                bot_id,
                bot["level"],
                bot["xp"],
                bot["money"],
                bot["map"],
                bot["zone"],
                bot["position_x"],
                bot["position_y"],
                bot["position_z"],
                bot["health"],
                bot["online"],
                bot["totaltime"],
                bot["leveltime"],
                current_time,
            ),
        )


    sqlite_connection.commit()


    # --------------------------------------------------
    # Summary
    # --------------------------------------------------

    print()
    print("====================================")
    print("          Telemetry Summary")
    print("====================================")
    print()

    print(f"New identities:     {new_identities}")
    print(f"Level-up events:    {level_up_events}")
    print(f"Zone-change events: {zone_change_events}")

    total_events = sqlite_connection.execute(
        """
        SELECT COUNT(*)
        FROM events
        """
    ).fetchone()[0]

    print(f"Total saved events: {total_events}")


except mysql.connector.Error as error:
    print("[ERROR] AzerothCore database error.")
    print(error)

except sqlite3.Error as error:
    print("[ERROR] Telemetry database error.")
    print(error)

except FileNotFoundError:
    print("[ERROR] config.json was not found:")
    print(config_path)

except json.JSONDecodeError as error:
    print("[ERROR] config.json contains invalid JSON.")
    print(error)


finally:
    if mysql_cursor is not None:
        mysql_cursor.close()

    if mysql_connection is not None and mysql_connection.is_connected():
        mysql_connection.close()

    if sqlite_connection is not None:
        sqlite_connection.close()

    print()
    print("[OK] Database connections closed.")