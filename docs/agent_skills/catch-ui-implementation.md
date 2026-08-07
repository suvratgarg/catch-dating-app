# catch-ui-implementation

Use for Flutter UI implementation from design files, screenshots, Widgetbook
states, or handoff notes.

Read: `docs/design_language.md`, `docs/design_parity/README.md`,
`docs/widget_catalog.md`, and `docs/app_architecture.md`.

Optional orientation:
`node tool/agent/context_pack.mjs --task ui-implementation --paths lib`.

Loop: convert design intent into contracts or Widgetbook states where relevant,
implement the smallest coherent surface, run focused Flutter and design checks,
and update owning widget, catalog, and design contracts when APIs or coverage
change.

Failure modes to avoid: eyeballing design without a contract surface, duplicating
global primitives locally, and validating only one viewport.
