#!/usr/bin/env bash
set -euo pipefail

SNIPPET_FILE="vimrc_todo_snippet.vim"
VIMRC="${HOME}/.vimrc"

START_MARK="\" >>> vim-todo-board (begin)"
END_MARK="\" <<< vim-todo-board (end)"

if [[ ! -f "${SNIPPET_FILE}" ]]; then
  echo "Error: ${SNIPPET_FILE} not found. Run this script from the repo root." >&2
  exit 1
fi

if [[ ! -f "${VIMRC}" ]]; then
  echo "${VIMRC} does not exist; creating it."
  touch "${VIMRC}"
fi

if grep -Fq "${START_MARK}" "${VIMRC}"; then
  echo "Looks like the snippet is already installed (marker found in ${VIMRC})."
  echo "If you want to reinstall, remove the block between the markers and re-run."
  exit 0
fi

echo "Installing vim-todo-board mappings into ${VIMRC} ..."
{
  echo ""
  echo "${START_MARK}"
  cat "${SNIPPET_FILE}"
  echo "${END_MARK}"
} >> "${VIMRC}"

echo "Done. Restart Vim (or :source ~/.vimrc) to load the mappings."