import os
import subprocess
import sys
import time
from datetime import datetime
from pathlib import Path


POLL_INTERVAL = 10

telemetry_directory = Path(__file__).resolve().parent
main_script = telemetry_directory / "main.py"

stop_file = telemetry_directory / "stop.flag"
pid_file = telemetry_directory / "telemetry.pid"


def should_stop():
    return stop_file.exists()


def wait_for_next_poll():
    for _ in range(POLL_INTERVAL):
        if should_stop():
            return

        time.sleep(1)


def get_value(lines, prefix):
    for line in lines:
        stripped = line.strip()

        if stripped.startswith(prefix):
            return stripped.split(":", 1)[1].strip()

    return None


def run_telemetry_poll():
    result = subprocess.run(
        [
            sys.executable,
            str(main_script),
        ],
        cwd=telemetry_directory,
        capture_output=True,
        text=True,
    )

    return result


def display_poll(result):
    current_time = datetime.now().strftime("%H:%M:%S")

    if result.returncode != 0:
        print(
            f"{current_time} | ERROR | "
            f"Telemetry returned code {result.returncode}"
        )

        if result.stdout.strip():
            print(result.stdout.strip())

        if result.stderr.strip():
            print(result.stderr.strip())

        return

    lines = result.stdout.splitlines()

    bot_count = get_value(
        lines,
        "[INFO] Online random bots"
    )

    level_up_count = get_value(
        lines,
        "Level-up events"
    )

    zone_change_count = get_value(
        lines,
        "Zone-change events"
    )

    total_event_count = get_value(
        lines,
        "Total saved events"
    )

    level_up_count = int(level_up_count or 0)
    zone_change_count = int(zone_change_count or 0)

    new_event_count = (
        level_up_count
        + zone_change_count
    )

    event_lines = []

    for line in lines:
        stripped = line.strip()

        if stripped.startswith("[LEVEL UP]"):
            event_lines.append(stripped)

        elif stripped.startswith("[POSSIBLE DEATH]"):
            event_lines.append(stripped)

        elif stripped.startswith("[ZONE CHANGE]"):
            event_lines.append(stripped)

    if new_event_count == 0 and not event_lines:
        print(
            f"{current_time} | "
            f"Bots: {bot_count or '?'} | "
            f"No new events | "
            f"Total: {total_event_count or '?'}"
        )

        return

    print()
    print(
        f"{current_time} | "
        f"Bots: {bot_count or '?'} | "
        f"New events: {max(new_event_count, len(event_lines))} | "
        f"Total: {total_event_count or '?'}"
    )

    for event in event_lines:
        print(f"  {event}")

    if zone_change_count > 0:
        visible_zone_changes = sum(
            1
            for event in event_lines
            if event.startswith("[ZONE CHANGE]")
        )

        hidden_zone_changes = (
            zone_change_count
            - visible_zone_changes
        )

        if hidden_zone_changes > 0:
            print(
                f"  [ZONE CHANGE] "
                f"{hidden_zone_changes} additional zone change(s)"
            )

    print()


def main():
    if stop_file.exists():
        stop_file.unlink()

    pid_file.write_text(
        str(os.getpid()),
        encoding="utf-8"
    )

    print("==============================================")
    print("        AZEROTH BOTS TELEMETRY")
    print("==============================================")
    print()
    print(f"Polling every {POLL_INTERVAL} seconds")
    print(f"Process ID: {os.getpid()}")
    print()
    print("----------------------------------------------")
    print(" TIME     | STATUS")
    print("----------------------------------------------")

    try:
        while not should_stop():
            result = run_telemetry_poll()

            display_poll(result)

            wait_for_next_poll()

    except KeyboardInterrupt:
        print()
        print("[INFO] Ctrl+C received.")

    finally:
        print()
        print("----------------------------------------------")
        print("[INFO] Stopping telemetry...")

        if pid_file.exists():
            pid_file.unlink()

        if stop_file.exists():
            stop_file.unlink()

        print("[OK] Telemetry stopped cleanly.")


if __name__ == "__main__":
    main()