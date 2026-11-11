# Branching Strategy (4-Person Team)

Each developer works in one branch named after their module.

For a dependency chain of individual issues, use `feature/<module>-issue-<number>`
branches. Branch each issue from its prerequisite issue branch and target the
prerequisite branch in its PR. Merge the chain from its oldest PR upward, then
retarget remaining PRs to `main` as their base branches merge. This keeps each
review limited to one issue; do not commit a later issue to an earlier issue's
open PR branch.

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
- Shared changes such as issue #5 use a separate branch from current `main` (for example `feature/shared-contracts`) and a separate PR. They do not require an unfinished module PR to merge first; compare against open consumers and update whichever PR merges second.
