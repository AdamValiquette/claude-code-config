# Façon de travailler

Je suis développeur backend / DevOps senior (Python, Ruby, PostgreSQL, Docker, AWS).
Je communique en français ; le code, les noms et les messages de commit restent en anglais.

## Principes

- **Petits pas vérifiables.** Une modification à la fois, testée avant de passer à la suivante.
- **Lire avant d'écrire.** Avant de modifier un fichier, lis-le et suis les conventions déjà en place
  (nommage, densité de commentaires, structure des modules).
- **Pas de dépendance nouvelle sans le demander.** Préfère la bibliothèque standard ou ce qui est déjà installé.
- **Pas de magie.** Code explicite plutôt que clever ; pas d'abstraction avant le troisième usage.
- **Secrets hors du code.** Configuration par variables d'environnement, `.env.example` à jour, jamais de `.env` commité.

## Boucle de travail

1. Reformuler la tâche en une phrase et identifier les fichiers touchés.
2. Si la tâche dépasse ~3 fichiers ou touche le schéma de données : proposer un plan avant de coder.
3. Écrire ou ajuster le test d'abord quand le comportement est bien défini.
4. Implémenter, puis lancer `pytest -q` (ou `bundle exec rspec`) et le linter.
5. Avant de déclarer « terminé » : déléguer la relecture au sous-agent `code-reviewer`.
6. Résumer ce qui a changé, ce qui a été vérifié, et ce qui ne l'a pas été.

## Sous-agents

| Agent | Quand l'utiliser |
|---|---|
| `code-reviewer` | Après toute modification non triviale, avant un commit. Lecture seule. |
| `test-writer` | Pour ajouter la couverture manquante ou reproduire un bug par un test qui échoue. |
| `migration-reviewer` | Dès qu'une migration (Alembic, Rails, SQL brut) est créée ou modifiée. |

## Git

- Branche par tâche ; jamais de commit direct sur `main`.
- Messages au format Conventional Commits (`feat:`, `fix:`, `chore:`…), à l'impératif.
- Ne jamais `push`, `rebase` ou `reset --hard` sans que je l'aie demandé.

## Stack par défaut

- **Python** : 3.12, FastAPI, SQLAlchemy 2 + Alembic, pytest, ruff.
- **Ruby** : Rails, RSpec, RuboCop.
- **Infra** : Docker Compose en local, PostgreSQL, n8n pour l'orchestration (cron, webhooks, alertes).

## Garde-fous

- Pas de scraping de sites qui l'interdisent dans leurs CGU (LinkedIn, Indeed) : sources propres seulement (API, RSS, alertes courriel).
- Toute commande destructive (`rm -rf`, `DROP`, `TRUNCATE`, `terraform destroy`) est bloquée par un hook ; si elle est vraiment nécessaire, me la proposer plutôt que de la contourner.
