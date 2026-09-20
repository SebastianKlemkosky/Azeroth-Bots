import sqlite3
import sys
from pathlib import Path


script_directory = Path(__file__).resolve().parent
project_directory = script_directory.parent
database_path = project_directory / "data" / "overseer.db"


if len(sys.argv) < 2:
    print("Usage:")
    print("py Telemetry\\history.py <character name>")
    sys.exit(1)


character_name = " ".join(sys.argv[1:])


connection = sqlite3.connect(database_path)
cursor = connection.cursor()


bot = cursor.execute(
    """
    SELECT
        bot_id,
        name,
        race_name,
        class_name,
        first_seen,
        last_seen
    FROM bots
    WHERE LOWER(name) = LOWER(?)
    """,
    (character_name,),
).fetchone()


if bot is None:
    print(f"[ERROR] Character not found: {character_name}")

    cursor.close()
    connection.close()
    sys.exit(1)


bot_id, name, race_name, class_name, first_seen, last_seen = bot


state = cursor.execute(
    """
    SELECT
        level,
        xp,
        money,
        zone_id,
        map_id,
        health,
        total_time,
        level_time,
        last_updated
    FROM bot_state
    WHERE bot_id = ?
    """,
    (bot_id,),
).fetchone()


events = cursor.execute(
    """
    SELECT
        timestamp,
        event_type,
        old_value,
        new_value,
        details
    FROM events
    WHERE bot_id = ?
    ORDER BY event_id
    """,
    (bot_id,),
).fetchall()


print("====================================")
print("       Azeroth Bots Character")
print("====================================")
print()

print(f"Name:       {name}")
print(f"Race:       {race_name}")
print(f"Class:      {class_name}")
print(f"Bot ID:     {bot_id}")
print()


if state is not None:
    (
        level,
        xp,
        money,
        zone_id,
        map_id,
        health,
        total_time,
        level_time,
        last_updated,
    ) = state

    print("Current State")
    print("------------------------------------")
    print(f"Level:      {level}")
    print(f"XP:         {xp}")
    print(f"Money:      {money}")
    print(f"Health:     {health}")
    print(f"Map ID:     {map_id}")
    print(f"Zone ID:    {zone_id}")
    print(f"Total Time: {total_time} seconds")
    print(f"Level Time: {level_time} seconds")
    print(f"Updated:    {last_updated}")
    print()


print("History")
print("------------------------------------")


if not events:
    print("No recorded events yet.")

else:
    for timestamp, event_type, old_value, new_value, details in events:
        print(
            f"{timestamp} | "
            f"{event_type:<16} | "
            f"{details}"
        )


print()
print(f"First seen: {first_seen}")
print(f"Last seen:  {last_seen}")


cursor.close()
connection.close()