# Tiny Todo in Vim

As developed by Simon Angus (Econ/SoDa Labs, Monash University) to manage this thing and that thing and the other thing.

A lightweight plain-text todo workflow designed for editing in Vim.

It’s built around a single `todo.txt` file with a **Today** area for active work and a **DONE** section that stores completed tasks. A few Vim mappings make it fast to mark items as done or move selected lines into DONE. A small Python script (`todo_visualizer.py`) scans the DONE section and prints an ASCII timeline chart of completed tasks per project per month.

## What this repo contains

- `todo-template.txt` — starter todo board you can copy and begin using.

- `vimrc_todo_snippet.vim` — the Vim mappings/functions used by this workflow.

- `install.sh` — appends the snippet to your `~/.vimrc` (idempotent, uses markers).

- `todo_visualizer.py` — CLI tool that prints a monthly timeline chart from DONE entries.

- `examples/project_timeline_output.txt` — example output from the visualiser.

## Quick start

1. Clone (or download) this repo.

2. Install Vim mappings into your `~/.vimrc`, in the shell:

   - Ensure `install.sh` is executable: `chmod +x install.sh`
   - Run: `./install.sh`

3. Create your todo file:

   - Run: `cp todo-template.txt ~/todo.txt`

4. Edit in Vim:

   - `vim ~/todo.txt`

5. Visualise your DONE history:

   - Run: `python3 todo_visualizer.py ~/todo.txt`

## Todo file format

- Items todo should have a project tag in square brackets, e.g., `[project-name]`, before this any indicator you like, and after your item e.g.

  `>> [project-name] your task text`

- Completed items (after applying the `<leader>x` mapping) will look like:

  `X [project-name] your task text (YYYY-MM-DD)`

The visualiser counts tasks by `project-name` and groups them by month.

## Vim mappings (defaults)

Use a leader (usually `\`) followed by a letter to trigger the following actions for the current line (or lines if in visual selection):

- `<leader>x` (e.g. `\x`) — mark the current line as done by prefixing `X ` and appending today’s date, then move it under `Today`.

- `<leader>m` — move the current line (or visually-selected lines) to the DONE section.

- `<leader>w` — toggle (add, or remove) a small `(wait:xx)` marker at the start of the item where you're waiting for someone or something to continue the task.

- `<leader>M` — insert a set of “monthly tasks” (edit these in `~/.vimrc`) to your needs).

Notes:

- You can edit the mappings in `vimrc_todo_snippet.vim` before installing.

## Visualiser options

- Choose how many projects to show:

  `python3 todo_visualizer.py ~/todo.txt --top 20`

- Disable screen clear:

  `python3 todo_visualizer.py ~/todo.txt --no-clear`

## Tips

- Keep projects short (or accept truncation) for prettier charts.

- Add a consistent `[project]` tag to tasks you want counted.

- Only lines beginning with `X ` are treated as “done”.
