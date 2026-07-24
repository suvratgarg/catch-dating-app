# React dependency graph

Generated from TypeScript ASTs under `website/src`, `admin/src`, `packages/web-ui/src` by
`node tool/web/react_dependency_graph.mjs --write`. The JSON file is the complete module graph;
the Mermaid file is the aggregated feature and shared-layer map.

## Current inventory

| Measure | Count |
|---|---:|
| Scanned TypeScript modules | 335 |
| Dependency leaf nodes | 23 |
| Module edges | 1236 |
| Dynamic imports | 29 |
| Re-exports | 65 |
| Feature/shared groups | 33 |
| Aggregated feature dependencies | 100 |
| External packages | 14 |
| Unresolved repo-local imports | 0 |
| Direct website/admin violations | 0 |
| Runtime module cycles | 6 |
| Type-inclusive module cycles | 6 |

Blocking gate health: **healthy**.

## Refresh and check

    node tool/web/react_dependency_graph.mjs --write
    node tool/web/react_dependency_graph.mjs --check
    node tool/web/react_dependency_graph.mjs --summary

The check fails when generated artifacts are stale, a repo-local relative,
TypeScript-path, or workspace import cannot be resolved, or website and admin
import one another directly. Runtime and type-only cycles plus non-literal
dynamic imports remain visible in JSON health data. Cycles are report-only while
the existing graph has unresolved cycle debt, rather than hidden behind a
baseline that would make new cycles look acceptable.
