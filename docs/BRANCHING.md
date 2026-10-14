# Branching Strategy (4-Person Team)

Each developer works in one branch named after their module.

## Module branches

- `feature/identity` → @PnterNN
- `feature/catalog` → @sdnrkaleli
- `feature/ordering` → @AhmetEfe0
- `feature/operations` → @selincellkk

## Rules

- Nobody pushes directly to `main`.
- All changes go through Pull Request.
- CODEOWNERS review is required for module folders.
- Cross-module or `src/BuildingBlocks` changes require shared review.
- After a module PR is merged, update the module branch from `main` before starting more work.
