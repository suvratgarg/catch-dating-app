---
doc_id: agent_skill_catch_react_surface_refactor
version: 1.0.129
updated: 2026-07-03
owner: agent_operating_model
status: active
---

# catch-react-surface-refactor

Use when changing shared React architecture across `website/`, `admin/`, or
`packages/web-config/`: routing, feature folder shape, query/controller seams,
UI primitives, Storybook/component coverage, import boundaries, or React
scanner/tooling rules.

Read: `AGENTS.md`, `docs/agent_operating_model.md`,
`docs/web_surface_architecture.md`, `docs/marketing_website_architecture.md`,
`design/website/routes.json`, `design/website/components.json`,
`design/admin/components.json`,
`website/README.md`, `admin/README.md` when present, `packages/web-config/README.md`,
`tool/tools_manifest.json`, and `docs/audit_registry/README.md`.

Loop:

1. Generate a scoped context pack before editing React architecture:
   `node tool/agent/context_pack.mjs --task react-surface-refactor --paths website,admin,packages/web-config,docs/web_surface_architecture.md,docs/marketing_website_architecture.md,design/website,tool`.
2. Preserve dirty work outside the declared React scope.
3. Pick one reference implementation first. Do not migrate sibling screens from
   prose only.
4. Keep route shells thin. Route shells own routing, URL-derived state,
   auth/role guards, metadata, lifecycle, and provider setup. Feature pages own
   composition. Controllers may consume explicit route-state objects, but should
   not parse `window.location` or call router hooks directly.
5. Use React Router for URL/routing state and TanStack Query for true remote
   reads and mutations. Keep generated/static data as typed imports until it is
   genuinely remote.
6. Do not hand-roll interactive controls in feature code. Use the surface's
   shared UI primitive owner and run:
   `node tool/run.mjs check web:react-ui-primitives`.
7. Do not hand-roll governed component families in feature code. The canonical governed-family registry is emitted by `node tool/web/check_react_component_governance.mjs --families-json` and checked in at `docs/audit_registry/react_component_governance_families.json`. Run `node tool/run.mjs check web:react-component-governance`. This scanner is a known-family blocklist: passing it does not classify novel shell families automatically, so repeated new shell drift must be added to the scanner before handoff.
8. For the marketing website, every exported uppercase component under `website/src/features/**/*.tsx` must be declared in `design/website/components.json` as a route, section, flow, or supporting component, or made private. Run `node tool/run.mjs check marketing:website-components` after adding, moving, or exporting website route/section/supporting components.
9. For admin feature UI, export only route/workspace entry components such as `*Screen` and `*Workspace`; reusable panels/cards/lists/sections belong in `admin/src/shared/ui` or stay private. Route/workspace entries, shared admin primitives, and admin feedback providers must be declared in `design/admin/components.json`. Run `node tool/run.mjs check web:admin-feature-exports` and `node tool/run.mjs check web:admin-components` after touching admin feature or shared admin UI exports. When an admin registry entry becomes preview-ready, add or update `admin/src/stories/**` metadata and run `node tool/run.mjs check web:admin-storybook`.
10. For marketing website public route changes, update
   `design/website/routes.json` first and run
   `node tool/run.mjs check marketing:website-routes`.
11. For React feature-boundary changes, run
   `node tool/run.mjs check web:react-architecture-boundaries`. For
   marketing website import-direction changes, also run
   `node tool/run.mjs check web:website-import-boundaries`.
12. For marketing route/section/component coverage changes, update
   `design/website/components.json` and Storybook together. Story exports must
   declare `parameters.catchComponent.id`, `routeIds`, and `states` that match
   the registry, then run
   `node tool/run.mjs check marketing:website-components` and
   `npm --workspace catch-marketing run build:storybook`.
13. For admin feature work, keep `features/<feature>/api|controllers|ui` intact
   and run `npm --workspace catch-admin run check:boundaries`.
14. Stamp the pass with `dart tool/audit_registry.dart mark-pass`, including
    `WEB-UI-PRIMITIVE-001` and `WEB-UI-COMPONENT-001` whenever UI primitive or
    component-family enforcement is relevant.

Parallel agent protocol:

- Use `docs/agent_skills/catch-parallel-delegation.md` for any subagent work.
- Parent owns canonical docs, route/component registries, generated files, tool
  manifest entries, audit receipts, and final verification.
- Subagents may do read-only inventory, candidate selection, isolated patch
  proposals in disjoint feature files, or scanner interpretation.
- Assign disjoint paths. Do not let two agents edit the same React primitive,
  route registry, docs file, or manifest in one loop.
- Every subagent packet must include `pattern_delta`, checks run, changed files,
  and do-not-merge conditions.

Required checks for a cross-React pass:

```sh
node tool/run.mjs check web:react-ui-primitives
node tool/run.mjs check web:react-component-governance
node tool/run.mjs check web:admin-feature-exports
node tool/run.mjs check web:admin-components
node tool/run.mjs check web:admin-storybook
npm --workspace catch-marketing run typecheck
npm --workspace catch-admin run typecheck
npm --workspace catch-marketing run build
npm --workspace catch-admin run build
node tool/run.mjs check --manifest-only
node tool/agent/check_agent_readiness.mjs
```

Add marketing route/component checks when `website/` route or Storybook coverage
changes.

Failure modes to avoid:

- Adding raw `<button>`, `<a>`, `<input>`, `<select>`, or `<textarea>` in a
  feature file.
- Rendering a governed component family directly instead of using the shared primitive named by `docs/audit_registry/react_component_governance_families.json`. The scanner is a known-family blocklist; if a new repeated shell family appears, add it to `tool/web/check_react_component_governance.mjs` rather than documenting it only in prose.
- Recreating or importing `website/src/components/site.tsx` instead of importing
  neutral site chrome from `shared/site`, governed visual primitives from
  `shared/ui/primitives`, or domain adapters from their owning feature folder.
- Passing governed route-shell class names into a generic primitive from a
  feature file instead of adding a named shared wrapper.
- Exporting reusable admin feature panels, cards, lists, badges, or sections
  instead of moving them into `admin/src/shared/ui` or keeping them private.
- Exporting or renaming admin route/workspace entries, shared primitives, or
  feedback providers without updating `design/admin/components.json`.
- Marking an admin component preview-ready without a matching Storybook export
  and `parameters.catchComponent` declaration.
- Moving website route behavior without updating the route contract and
  postbuild proof.
- Migrating generated/static data into TanStack Query just to match a pattern.
- Leaving admin navigation as hidden local state after adding route-like
  behavior.
- Letting subagents update canonical docs, generated registries, or audit
  receipts without parent integration.
