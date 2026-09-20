import json
from pathlib import Path

import mysql.connector


script_directory = Path(__file__).resolve().parent
config_path = script_directory / "config.json"


with open(config_path, "r", encoding="utf-8") as config_file:
    config = json.load(config_file)


mysql_config = config["mysql"]


connection = mysql.connector.connect(
    host=mysql_config["host"],
    port=mysql_config["port"],
    user=mysql_config["user"],
    password=mysql_config["password"],
    database=mysql_config["database"],
)


cursor = connection.cursor()

cursor.execute("DESCRIBE characters")

print("====================================")
print("     characters table structure")
print("====================================")
print()

for row in cursor.fetchall():
    print(row)


cursor.close()
connection.close()