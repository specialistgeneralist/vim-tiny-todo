#!/usr/bin/env python3
import argparse
import re
from collections import defaultdict


def ascii_art_header():
    return """
 _____  ______ _____   ____  _____ _______ 
|  __ \\|  ____|  __ \\ / __ \\|  __ \\__   __|
| |__) | |__  | |__) | |  | | |__) | | |   
|  _  /|  __| |  ___/| |  | |  _  /  | |   
| | \\ \\| |____| |    | |__| | | \\ \\  | |   
|_|  \\_\\______|_|     \\____/|_|  \\_\\ |_|   
"""


def parse_todo_list(filename: str):
    """Parse lines like:

        X [project-name] description (YYYY-MM-DD)

    Returns:
        tasks[YYYY-MM][project] = count
    """
    tasks = defaultdict(lambda: defaultdict(int))

    done_re = re.compile(r"^X\s+\[([\w-]+)\]\s+.+\((\d{4}-\d{2})-\d{2}\)\s*$")

    with open(filename, "r", encoding="utf-8") as f:
        for line in f:
            m = done_re.match(line.rstrip("\n"))
            if m:
                project, month = m.groups()
                tasks[month][project] += 1

    return tasks


def get_unique_months(tasks) -> list[str]:
    return sorted(tasks.keys())


def get_top_projects(tasks, n: int = 10) -> list[str]:
    project_totals = defaultdict(int)
    for month_data in tasks.values():
        for project, count in month_data.items():
            project_totals[project] += count

    top_projects = sorted(project_totals.items(), key=lambda x: x[1], reverse=True)[:n]
    return [project for project, _ in top_projects]


def generate_monthly_totals_chart(tasks, top_projects, months, max_name_length, month_width):
    monthly_totals = {month: sum(tasks[month].get(p, 0) for p in top_projects) for month in months}

    max_total = max(monthly_totals.values()) if monthly_totals else 0
    if max_total == 0:
        return

    print(f"{'Month Sum':<{max_name_length+2}} |", end="")
    for month in months:
        print(f" {monthly_totals[month]:2d}", end="")

    grand_total = sum(monthly_totals.values())
    print(f" | {grand_total:5d}")

    print("-" * (max_name_length + 3) + "+" + "-" * (len(months) * month_width + 1) + "+-------")

    max_bar_height = 8
    scale_factor = max_bar_height / max_total if max_total > 0 else 0

    for row in range(max_bar_height):
        level = max_bar_height - row
        threshold = level / scale_factor if scale_factor > 0 else 0

        label = "Bar Chart" if row == 0 else ""
        print(f"{label:<{max_name_length+2}} |", end="")

        for month in months:
            total = monthly_totals[month]
            if total >= threshold:
                print(" █ ", end="")
            else:
                print("   ", end="")

        print(" |")


def generate_sparkline_chart(tasks, top_projects):
    months = get_unique_months(tasks)

    if not months or not top_projects:
        print("No data available for timeline chart.")
        return

    max_name_length = min(max(len(p) for p in top_projects), 15)
    month_width = 3

    print("\nProject Timeline Chart (Tasks Completed per Month)")
    print("-" * (max_name_length + 3) + "+" + "-" * (len(months) * month_width + 1) + "+" + "-" * 7)

    print(f"{'Project':<{max_name_length+2}} |", end="")
    for month in months:
        month_display = month.split("-")[1] if "-" in month else month[-2:]
        print(f" {month_display}", end="")
    print(" | Total")

    print("-" * (max_name_length + 3) + "+" + "-" * (len(months) * month_width + 1) + "+" + "-" * 7)

    for project in top_projects:
        project_display = project[:max_name_length]
        print(f"{project_display:<{max_name_length+2}} |", end="")

        project_total = 0
        for month in months:
            count = tasks[month].get(project, 0)
            project_total += count

            if count == 0:
                symbol = "  "
            elif count < 3:
                symbol = " ·"
            elif count < 6:
                symbol = " ○"
            elif count < 10:
                symbol = " ◎"
            else:
                symbol = " ●"

            print(f" {symbol}", end="")

        print(f" | {project_total:5d}")

    print("-" * (max_name_length + 3) + "+" + "-" * (len(months) * month_width + 1) + "+" + "-" * 7)

    generate_monthly_totals_chart(tasks, top_projects, months, max_name_length, month_width)

    print("\nLegend: ● (10+)  ◎ (6-9)  ○ (3-5)  · (1-2)    (0)")


def main():
    parser = argparse.ArgumentParser(
        description="Parse a Vim todo.txt DONE section and print an ASCII monthly timeline chart."
    )
    parser.add_argument("todo_file", help="Path to your todo.txt")
    parser.add_argument("--top", type=int, default=20, help="Number of top projects to show (default: 20)")
    parser.add_argument("--no-clear", action="store_true", help="Do not clear the terminal before printing")
    args = parser.parse_args()

    try:
        all_tasks = parse_todo_list(args.todo_file)
        top_projects = get_top_projects(all_tasks, args.top)

        if not args.no_clear:
            print("\033[H\033[J", end="")

        print(ascii_art_header())
        generate_sparkline_chart(all_tasks, top_projects)

    except FileNotFoundError:
        print(f"Error: File '{args.todo_file}' not found.")
    except Exception as e:
        print(f"An error occurred: {e}")


if __name__ == "__main__":
    main()
