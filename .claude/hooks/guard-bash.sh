#!/usr/bin/env bash
# PreToolUse (Bash) : bloque les commandes destructives avant leur exécution.
# Code de sortie 2 = commande refusée ; le message sur stderr est renvoyé à Claude.
set -euo pipefail

cmd=$(jq -r '.tool_input.command // ""')

block() {
  echo "Bloqué par guard-bash : $1. Propose la commande à l'utilisateur au lieu de l'exécuter." >&2
  exit 2
}

shopt -s nocasematch
[[ $cmd =~ rm[[:space:]]+-[a-z]*r[a-z]*f|rm[[:space:]]+-[a-z]*f[a-z]*r ]] && block "rm -rf"
[[ $cmd =~ git[[:space:]]+push.*(--force|-f([[:space:]]|$)) ]]            && block "git push --force"
[[ $cmd =~ git[[:space:]]+reset[[:space:]]+--hard ]]                      && block "git reset --hard"
[[ $cmd =~ git[[:space:]]+clean[[:space:]]+-[a-z]*f ]]                    && block "git clean -f"
[[ $cmd =~ (drop|truncate)[[:space:]]+(table|database|schema) ]]          && block "DROP/TRUNCATE SQL"
[[ $cmd =~ terraform[[:space:]]+(destroy|apply[[:space:]].*-auto-approve) ]] && block "terraform destructif"
[[ $cmd =~ docker[[:space:]]+(system|volume)[[:space:]]+prune ]]          && block "docker prune"
[[ $cmd =~ (cat|less|head|tail|grep)[[:space:]].*\.env([[:space:]]|$) ]]  && block "lecture de .env"

exit 0
