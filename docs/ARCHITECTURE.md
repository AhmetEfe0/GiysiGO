# GiysiGO Architecture (Modular Monolith)

GiysiGO is intentionally implemented as a **Modular Monolith**:

- **Single repository**
- **Single deployable application host** (`src/API/GiysiGo.API`)
- **Multiple business modules** with explicit boundaries

## Modules and responsibilities

- **Identity**: users, roles, authentication, addresses
- **Catalog**: garment types, services, pricing, active/passive visibility
- **Ordering**: cart, checkout, order and order items
- **Operations**: QR/media/status workflow after ordering

## Boundary rules

- Modules do **not** directly use other modules' entities or database context.
- Cross-module collaboration uses **in-process public contracts** and **integration events**.
- This is **not** a microservices setup: no separate deployable services, no external message bus requirement.

## Team branching model

For 4-person collaboration, use per-module feature branches:

- `feature/identity/*`
- `feature/catalog/*`
- `feature/ordering/*`
- `feature/operations/*`

See `docs/BRANCHING.md` for team workflow rules.
