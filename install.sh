#!/usr/bin/env bash
# Copie la configuration dans un projet cible (par défaut : le répertoire courant).
# N'écrase rien d'existant sans --force.
set -euo pipefail

src=$(cd "$(dirname "$0")" && pwd)
dest=${1:-$PWD}
force=${2:-}

copy() {
  local from=$src/$1 to=$dest/$1
  if [[ -e $to && $force != --force ]]; then
    echo "existe déjà, ignoré : $1 (relancer avec --force pour écraser)"
    return
  fi
  mkdir -p "$(dirname "$to")"
  cp -R "$from" "$to"
  echo "copié : $1"
}

copy CLAUDE.md
copy .claude/settings.json
copy .claude/agents
copy .claude/hooks
chmod +x "$dest"/.claude/hooks/*.sh
