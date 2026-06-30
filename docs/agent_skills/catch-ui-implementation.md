# catch-ui-implementation

Use for Flutter UI implementation from design files, screenshots, Widgetbook
states, or handoff notes.

Read: `docs/design_language.md`, `docs/design_parity/README.md`,
`docs/widget_catalog.md`, and `docs/app_architecture.md`.

Loop: convert design intent into contracts or Widgetbook states where relevant,
implement the smallest coherent surface, run focused Flutter and design checks,
and update widget/catalog/design ledgers when APIs or coverage changed.

Failure modes to avoid: eyeballing design without a contract surface, duplicating
global primitives locally, and validating only one viewport.
