# Branching Strategy (4-Person Team)

Each developer works in their own module branch.

## Module branches

- `feature/identity/*`  → Identity owner
- `feature/catalog/*`   → Catalog owner
- `feature/ordering/*`  → Ordering owner
- `feature/operations/*`→ Operations owner

## Rules

- Nobody pushes directly to `main`.
- All changes go through Pull Request.
- CODEOWNERS review is required for module folders.
- Cross-module or `src/BuildingBlocks` changes require shared review.
