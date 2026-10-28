#!/usr/bin/env bash
# PostToolUse (Edit|Write) : formate le fichier que Claude vient de modifier.
# N'échoue jamais : un formateur absent ne doit pas bloquer le travail.
set -uo pipefail

file=$(jq -r '.tool_input.file_path // ""')
[[ -f $file ]] || exit 0

case $file in
  *.py)
    command -v ruff >/dev/null && { ruff format -q "$file"; ruff check -q --fix "$file"; } ;;
  *.rb)
    command -v rubocop >/dev/null && rubocop -a --format quiet "$file" ;;
  *.sh)
    command -v shellcheck >/dev/null && shellcheck "$file" >&2 ;;
  *.json)
    command -v jq >/dev/null && tmp=$(mktemp) && jq . "$file" >"$tmp" && mv "$tmp" "$file" ;;
esac

exit 0
