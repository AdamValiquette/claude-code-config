# Ma configuration Claude Code

La configuration que j'utilise au quotidien avec [Claude Code](https://docs.claude.com/en/docs/claude-code)
sur mes projets backend (Python/FastAPI, Ruby/Rails, PostgreSQL, Docker, n8n).

L'idée : **déléguer le travail mécanique à l'agent, garder le contrôle sur ce qui est risqué.**
Claude code, teste et se relit lui-même ; les actions irréversibles (push, migrations, suppression,
infrastructure) restent derrière une confirmation humaine ou sont bloquées.

```
.
├── CLAUDE.md                     # Instructions permanentes : façon de travailler, conventions, garde-fous
├── install.sh                    # Copie la config dans un autre projet
└── .claude/
    ├── settings.json             # Permissions (allow / ask / deny) + branchement des hooks
    ├── agents/
    │   ├── code-reviewer.md      # Relecture du diff, lecture seule
    │   ├── test-writer.md        # Tests pytest / RSpec, reproduction de bogues
    │   └── migration-reviewer.md # Revue des migrations Alembic / Rails côté production
    └── hooks/
        ├── guard-bash.sh         # PreToolUse : bloque rm -rf, push --force, DROP TABLE…
        ├── format.sh             # PostToolUse : ruff / rubocop / shellcheck après chaque édition
        └── notify.sh             # Stop : webhook n8n → notification quand la tâche est finie
```

## Ma façon de travailler

1. **Je décris le résultat attendu, pas les étapes.** `CLAUDE.md` fixe le cadre : petits pas, test d'abord
   quand c'est possible, plan proposé avant toute tâche qui touche plus de trois fichiers ou le schéma.
2. **Claude implémente et vérifie.** Il lance les tests et le linter lui-même ; le hook `format.sh`
   formate chaque fichier modifié, donc les diffs restent propres sans y penser.
3. **Un second regard avant le commit.** Le sous-agent `code-reviewer` relit le diff dans un contexte neuf,
   sans le biais de celui qui a écrit le code. Il cherche des bogues, pas du style.
4. **Je relis, je pousse.** `git push` demande toujours ma confirmation.
5. **Je ne surveille pas le terminal.** Le hook `Stop` appelle un workflow n8n qui m'envoie une
   notification : je peux lancer une tâche longue et faire autre chose.

## Les sous-agents

Chaque agent a un rôle étroit, des outils limités et le modèle adapté à la tâche.

| Agent | Outils | Modèle | Pourquoi |
|---|---|---|---|
| `code-reviewer` | lecture + Bash | Opus | Ne peut rien modifier : il rapporte, je décide. Raisonnement profond pour les bogues subtils. |
| `test-writer` | lecture + écriture | Sonnet | Travail plus mécanique ; interdit de toucher au code de production pour faire passer un test. |
| `migration-reviewer` | lecture + Bash | Opus | Raisonne en « 50 millions de lignes en production » : verrous, `CONCURRENTLY`, réversibilité, déploiement progressif. Ne lance jamais de migration. |

## Les permissions

`settings.json` classe les commandes en trois niveaux :

- **allow** — sans friction : tests, linters, `git status/diff/log/commit`, inspection Alembic et Docker.
- **ask** — confirmation à chaque fois : `git push`, migrations, `docker compose up/down`, installation de paquets, réseau.
- **deny** — jamais : lecture ou édition de `.env`, `~/.aws`, `~/.ssh`, `sudo`, CLI AWS, `terraform apply/destroy`.

Les règles `deny` filtrent les outils de Claude ; le hook `guard-bash.sh` ajoute une deuxième barrière
au niveau du contenu des commandes (`rm -rf`, `git reset --hard`, `DROP TABLE` glissé dans un `psql -c`…).
Il renvoie un message explicatif à Claude, qui propose alors la commande au lieu de l'exécuter.

## Installation

```bash
git clone https://github.com/AdamValiquette/claude-code-config.git
./claude-code-config/install.sh ~/code/mon-projet
```

Pour les notifications, définir l'URL du webhook (n8n, Slack, ntfy…) dans son shell :

```bash
export CLAUDE_NOTIFY_WEBHOOK="https://<instance>.app.n8n.cloud/webhook/claude-code-done"
```

Sans cette variable, le hook ne fait rien. Prérequis : `jq` ; `ruff`, `rubocop` et `shellcheck` sont utilisés s'ils sont présents.

## Tester les hooks

Les hooks lisent du JSON sur l'entrée standard, ce qui permet de les tester sans Claude :

```bash
echo '{"tool_input":{"command":"rm -rf build"}}' | .claude/hooks/guard-bash.sh; echo $?   # 2 = bloqué
echo '{"tool_input":{"command":"pytest -q"}}'    | .claude/hooks/guard-bash.sh; echo $?   # 0 = autorisé
```
