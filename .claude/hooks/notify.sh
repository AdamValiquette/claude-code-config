#!/usr/bin/env bash
# Stop : prévient un workflow n8n quand Claude a fini sa tâche
# (n8n relaie ensuite vers une notification téléphone / courriel).
# L'URL du webhook vient de l'environnement pour ne jamais être commitée.
set -uo pipefail

[[ -n ${CLAUDE_NOTIFY_WEBHOOK:-} ]] || exit 0

project=$(basename "${CLAUDE_PROJECT_DIR:-$PWD}")
payload=$(jq -n --arg project "$project" '{project: $project, message: "Task finished"}')

curl -s -m 5 -X POST "$CLAUDE_NOTIFY_WEBHOOK" \
  -H 'Content-Type: application/json' \
  -d "$payload" >/dev/null || true
