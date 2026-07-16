# Web Platform Hardening Spec — Testing, Primitives, Lexicon, Visual Regression (for Codex)

Status: implementation complete; final verification recorded below · 2026-07-12
Scope: `website/`, `admin/`, `packages/`, `design/`, `tool/web/`, CI workflows
Companion: [`website_copy_implementation_spec.md`](website_copy_implementation_spec.md)
("the copy spec") — sequencing constraints in §8 are MANDATORY; do not start
website-touching phases before the copy spec's PR 5 lands.

This spec hardens the two React surfaces after a 2026-07-12 architecture
review. Findings were verified against the repo (evidence cited inline). §10
lists things the review CONFIRMED HEALTHY — do not "improve" them.

---

## 0. Goals and non-goals

Goals:
1. Real unit-test coverage for web-surface logic (admin first — it has the
   most consequential logic and zero tests today).
2. Break up the two primitive monoliths and extract genuinely shared
   primitives into one workspace package.
3. Make the cross-stack design lexicon (`design/components/`) a binding,
   machine-checked registry across Flutter, website, and admin.
4. Visual regression coverage keyed to the component registries.
5. Runtime validation at the admin↔callable trust boundary.

Non-goals:
- No Flutter↔React component-implementation sharing (ruled out: wrong
  altitude; sharing happens via tokens, contracts, lexicon, content).
- No new UI framework, CSS system, state library, or CMS.
- No visual redesign; pixel output is expected UNCHANGED by Phases B/C
  (visual regression exists to prove exactly that).
- No changes to `contracts/` generation, the token generator
  (`tool/design_tokens.dart`), or Firestore rules.
- No Flutter code changes except the additive lexicon check in Phase D
  (which is a repo-level `.mjs` check, NOT an analyzer-plugin rule — see
  §5.3 warning).

---

## 1. Findings register (verified 2026-07-12)

| # | Finding | Evidence | Disposition |
|---|---------|----------|-------------|
| F1 | Zero test files in either React `src/` tree; admin has no test runner at all; website's vitest runs only the Storybook a11y project | `find website/src admin/src -name "*.test.*"` → empty; `admin/package.json` has no vitest; `website/package.json` `test:storybook:a11y` | Phase A |
| F2 | Primitive monoliths: `website/src/shared/ui/primitives.tsx` = 4,977 lines / 197 exports; `admin/src/shared/ui/AdminPrimitives.tsx` = 3,956 lines / 223 exports; overlapping basics rebuilt twice | `wc -l`, `grep -c "^export"` | Phases B, C |
| F3 | `design/components/catch.components.json` + `check_component_contracts.mjs` validate the lexicon internally (schema + token refs) but nothing forces shipped components in any stack to map to it | `tool/design/check_component_contracts.mjs` reads only registry + tokens | Phase D |
| F4 | No visual regression anywhere; both surfaces have Storybook + registries with review states, so the substrate exists | package.json scripts; `design/website/components.json` review blocks | Phase E |
| F5 | Admin API layer is a single choke point (`admin/src/shared/api/adminApi.ts`) but payloads/responses are not validated against the JSON schemas that exist in `contracts/callables/` + `contracts/callable_responses/` | grep `httpsCallable` → 2 files repo-wide; schemas exist per callable | Phase F |
| F6 | Root npm workspaces = `["admin", "website"]` only; `packages/` (catch_ui_lints, phosphor_flutter, web-config) is outside the workspace list | root `package.json` | Phase C prerequisite |

Confirmed healthy (§10): token pipeline, contract generation + consumption on
BOTH web surfaces, TanStack Query discipline (empty baseline), governance
checker culture, web font delivery (Archivo VF + Plex Mono via
`packages/web-config/generated/`, verified present in `website/dist`).

---

## 2. Phase A — Testing foundation

### A1. Admin unit tests (highest priority in this spec)

- Add to `admin/`: `vitest` + `@testing-library/react` + `@testing-library/user-event`
  + `jsdom` (devDependencies; match website's vitest major).
- `admin/vitest.config.ts`: single `unit` project, environment `jsdom`,
  include `src/**/*.test.{ts,tsx}`.
- Script: `"test": "vitest run"`, `"test:watch": "vitest"`.
- Colocate tests next to sources (`foo.ts` → `foo.test.ts`). No `__tests__`
  dirs, no markup-snapshot tests.
- First targets, in order (test behavior, not implementation):
  1. `admin/src/features/finance/controllers/**` — every controller: state
     transitions, error paths, and that money-touching mutations call
     `adminApi` with exactly the expected payload (mock the api module).
  2. Intake approval logic — `admin/src/features/intake/**` decision paths
     and `admin/src/shared/contracts/intakeApprovalContracts.ts` mapping
     functions (these produce durable cross-surface shapes; lock them).
  3. `admin/src/shared/api/adminApi.ts` — callable-name→function mapping,
     error normalization, auth/App Check failure surfaces (mock
     `httpsCallable`).
  4. `admin/src/shared/controllers/**` and `admin/src/shared/query/**`
     helpers.
- Mock boundary rule: mock `firebase/functions` (and the `adminApi` module in
  feature tests). Never mock a module under test's own feature directory.

### A2. Website unit tests

- Website already has vitest; add a `unit` project beside the existing
  `storybook` project in its vitest config (keep `test:storybook:a11y`
  untouched). Script: `"test:unit": "vitest run --project=unit"`.
- First targets:
  1. `features/organizers/selectors.ts` and `publicDiscovery*` (the copy
     spec's §11.3 event-eligibility selector with injected `now` gets its
     tests here if not already landed).
  2. `features/waitlist/useWaitlistFormController.ts` and
     `features/host/application/useHostApplicationController.ts` +
     `applicationModel.ts` (renderHook: validation, submit, status).
  3. `features/marketing/tracking.ts` payload shapes (locks the §11.6
     analytics contract from the copy spec).
  4. Copy-spec artifacts once landed: interpolation helper, meta reader,
     market selectors.

### A3. Admin Storybook a11y gate

- Mirror website's setup: add `@storybook/addon-vitest` +
  `@vitest/browser-playwright` to admin, `test:storybook:a11y` script, same
  configuration shape as `website/`.

### A4. CI wiring

- `admin-website.yml`: add `npm --workspace catch-admin run test` and
  `test:storybook:a11y` jobs (same pattern as marketing workflow's line
  running the website a11y suite).
- `marketing-website.yml`: add `npm --workspace catch-marketing run
  test:unit`.
- Coverage: report via `vitest --coverage` in CI (informational). Do NOT add
  a coverage-percentage gate in this pass; the gate is "named first targets
  above have tests and they run in CI."

---

## 3. Phase B — Primitive monolith split (mechanical, zero behavior change)

Applies twice: `website/src/shared/ui/` and `admin/src/shared/ui/`.

- Convert `primitives.tsx` / `AdminPrimitives.tsx` into a directory:
  `shared/ui/primitives/` with per-family files + `index.ts` barrel that
  re-exports EVERYTHING under the existing names. Every existing import path
  (`../../shared/ui/primitives`) must keep working — imports elsewhere in the
  app should need zero edits (barrel resolves).
- Family grouping rule: group by UI family, not by page — e.g. `actions.tsx`
  (Button, ButtonLink, ActionGroup, TextActionButton), `forms.tsx`
  (TextField, SelectField, HoneypotField, FormStatus, WaitlistFormShell),
  `layout.tsx` (Section shells, grids, PanelShell/ProductShell),
  `feedback.tsx` (EmptyState, status/consent), `media.tsx` (captures),
  plus surface-specific families (`host.tsx`, `organizer.tsx` for website;
  the admin equivalents per its component registry groups). Target ≤ ~400
  lines per file; deviation allowed with a one-line justification comment at
  file top.
- Codex generates the concrete family manifest (export → target file) as a
  PR deliverable appended to this spec (same pattern as copy-spec §14), then
  executes it.
- Update anything that references the monolith path literally:
  `check_react_component_governance.mjs` / `check_react_ui_primitives.mjs`
  configs, story imports, and the copy spec's §1.7 checker prop-scan config
  if it names the file.
- Gate: `npm run typecheck` + `npm run build` + Storybook build green on
  both surfaces; `git diff --stat` shows only `shared/ui/**`, stories, and
  checker-config changes; visual output unchanged (Phase E baselines, if
  already captured, must not shift — see §8 ordering).

## 4. Phase C — `packages/web-ui` extraction

Prerequisite: F6 — add `"packages/web-ui"` to root `package.json`
`workspaces` (leave existing non-JS packages out).

- Create `packages/web-ui/` (name `@catch/web-ui`): React 19 peer dep,
  TypeScript, no Firebase/router/query imports allowed (pure presentational
  package). It consumes design tokens exclusively via the `--catch-*` CSS
  custom properties from `packages/web-config` (peer/style dependency —
  import of the token CSS stays in each app, as today).
- Extraction inventory (PR deliverable, same map pattern): list every export
  present in BOTH surfaces' primitive dirs with compatible APIs. Starter
  candidates from the review: buttons/action groups, text/select/honeypot
  fields + form status, labels (`UiLabel`), card/panel shells, empty states,
  FAQ list (website `HostFaqList` ↔ admin equivalent if present). Rule: a
  component moves ONLY if both surfaces adopt it in the same PR — no
  speculative package residents.
- Surface-specific styling stays surface-side: the package ships structural
  class names; each app's CSS may extend via its existing class-name
  governance. If the two surfaces' variants of a component differ visually,
  the package component takes a `variant` prop only when the variant is a
  designed state in the lexicon (Phase D) — otherwise it does not move.
- Stories live IN the package (`packages/web-ui/src/**/*.stories.tsx`) and
  are loaded by BOTH surfaces' Storybooks via an added glob in each
  `.storybook/main.ts`.
- Governance: register the package as surface `webui` in
  `check_react_ui_primitives.mjs`, `check_react_classname_boundaries.mjs`,
  and `check_react_component_governance.mjs`; new registry file
  `design/web-ui/components.json` following the existing schemas. The
  import-boundary checkers for both apps must allow `@catch/web-ui` and
  forbid deep imports (`@catch/web-ui/src/...`).
- Both apps' `check:*` suites plus typecheck/build/storybook must stay green;
  net LOC in the two `shared/ui` dirs must DROP by at least the size of the
  moved components (no copy-leave-behind).

## 5. Phase D — Binding cross-stack design lexicon

### 5.1 Registry becomes binding

- `design/components/catch.components.json` gains, per component:
  `surfaces: {flutter?: string, website?: string, admin?: string, webui?:
  string}` where each value is the implementing symbol name (e.g. flutter:
  `"CatchChip"`, webui: `"UiLabel"`). Update
  `design/components/catch.components.schema.json` accordingly.
- Extend `tool/design/check_component_contracts.mjs` (or add a sibling
  `check_component_lexicon.mjs` if cleaner) to enforce, for every declared
  surface implementation:
  1. the symbol exists in that surface (website/admin/webui: exported from
     the primitives barrel or package; flutter: declared in `lib/**` — a
     text-level `grep -rn "class <Name>"` match is sufficient);
  2. reverse direction: every entry in `design/website/components.json`,
     `design/admin/components.json`, and `design/web-ui/components.json`
     that is marked design-system-level (add a boolean `lexicon` field to
     those schemas) references an existing `catch.components.json` id.
- Seed the lexicon links for the Phase C extracted set + the obvious
  existing pairs; do NOT attempt exhaustive back-fill of all ~420 exports —
  new/moved components must link; legacy ones link opportunistically.

### 5.2 CI

- Run the lexicon check in `flutter-ci.yml` (it reads `lib/**`),
  `admin-website.yml`, and `marketing-website.yml`. Register the checker +
  a seeded known-bad vacuity proof in `tool/tools_manifest.json` per repo
  enforcement-integrity convention.

### 5.3 Hard warning (from repo memory)

Do NOT implement the Flutter side as a `catch_ui_lints` analyzer-plugin
rule: editing that plugin crashes local `dart analyze` (fresh plugin compile
failure, documented in project memory). The Flutter existence check stays a
repo-level `.mjs` text check.

## 6. Phase E — Visual regression on Storybook

- New checker `tool/web/check_storybook_visuals.mjs`:
  - Input: a built `storybook-static/` for a surface; drives Playwright
    (already a transitive dev capability via `@vitest/browser-playwright`;
    add `playwright` devDependency at root if needed) over the story index.
  - Scope: only stories whose component-registry entry has review status
    `ready` (read `design/{website,admin,web-ui}/components.json`) — keeps
    the baseline set intentional.
  - Determinism: fixed viewport(s) desktop 1280×800 + mobile 375×812,
    `prefers-reduced-motion: reduce`, wait for `document.fonts.ready`,
    disable animations via injected CSS.
  - Baselines committed under `design/visual_baselines/<surface>/<story>.<viewport>.png`;
    `--update` flag rewrites; CI runs compare mode with a small
    antialiasing-tolerant pixel threshold; failure artifact = diff images.
- CI: after each surface's `build:storybook` in its workflow.
- Baseline capture happens ONLY after the copy spec's PR 5 and Phase B land
  (§8) — never baseline the pre-migration UI.

## 7. Phase F — Runtime validation at the admin trust boundary

- Add `ajv` (+ `ajv-formats`) to admin.
- Build step (small `.mjs` in `admin/scripts/`) compiles the relevant
  `contracts/callables/*.schema.json` + `contracts/callable_responses/*` into
  typed validators under `admin/src/generated/validators/` (generated,
  committed, with a `--check` drift mode wired into admin `pretypecheck` —
  same pattern as other generated artifacts in this repo).
- `adminApi.ts` validates request payloads ALWAYS (they're cheap and the
  admin surface is low-traffic) and validates responses when
  `import.meta.env.DEV` or a `VITE_ADMIN_VALIDATE_RESPONSES` flag is set.
  Validation failure throws a typed error that the existing feedback layer
  renders; it must name the callable and the failing JSON path.
- Unit tests (Phase A infra): one known-good and one known-bad fixture per
  wired callable family.
- Website is OUT of scope for ajv (its two callables are already thin;
  revisit only if the claim flow grows).

---

## 8. Sequencing and conflict management (MANDATORY)

The copy spec owns `website/src/features/**` + `website/src/content/**`
until its PR 5 lands. Therefore:

| Order | Work | May start |
|-------|------|-----------|
| 1 | Phase A1/A3/A4 (admin tests + a11y + CI), Phase B-admin split, Phase F | immediately, parallel to copy PRs |
| 2 | Phase A2 (website unit tests) | after copy PR 2 (tests target post-migration selectors/controllers) |
| 3 | Phase B-website split | after copy PR 5 |
| 4 | Phase C extraction (needs both splits) | after 3 |
| 5 | Phase D lexicon (links Phase C set) | after 4 (checker scaffold may land earlier, non-blocking) |
| 6 | Phase E baselines | last — after copy v2 + splits, so baselines capture the target UI |

PR slicing: one PR per phase per surface (A-admin, A-website, B-admin,
B-website, C, D, E, F). Each PR includes its own checker/manifest updates
and appends its inventory/manifest deliverable to this spec.

## 9. Verification gates

Every PR: the owning surface's full `check:*` suite + typecheck + build +
Storybook build; new checkers registered in `tool/tools_manifest.json` with
seeded known-bad proofs; `node tool/run.mjs check --manifest-only` green.

Phase-specific:
- A: new test scripts run in CI and fail on seeded assertion break (prove
  non-vacuity once, in the PR description).
- B: zero import-site edits outside `shared/ui/**`/stories/checker configs;
  both builds byte-identical CSS class output where feasible (spot-check via
  Storybook).
- C: net `shared/ui` LOC reduction ≥ moved-component size; deep-import ban
  enforced by import-boundary checkers.
- D: vacuity proof = temporarily point a `surfaces.website` symbol at a
  nonexistent export → checker fails.
- E: `--update` on an unchanged tree produces zero diffs twice in a row
  (determinism proof) before the gate turns blocking.
- F: drift mode fails when a `contracts/callables` schema changes without
  regenerating validators.

## 10. Verified healthy — DO NOT "fix"

1. **Design-token pipeline**: `design/tokens/catch.tokens.json` →
   `tool/design_tokens.dart` → `lib/core/theme/generated/catch_design_tokens.g.dart`
   + `packages/web-config/generated/catch-tokens.css`, with `--check` drift
   gating. Leave the generator alone.
2. **Web typography**: Archivo VF + IBM Plex Mono ship via
   `packages/web-config/generated/assets/fonts/` `@font-face` and appear in
   built output (`website/dist/assets/Archivo-Roman-VF-*.woff2`);
   `--catch-font-sans: system-ui` is the intentional DS body choice.
3. **Contracts**: `contracts/` → generated TS in
   `functions/src/shared/generated/` consumed by admin
   (`intakeApprovalContracts.ts`) AND website (`organizers/types.ts`,
   `firebase.ts`), Dart mirror for Flutter, `contracts-ci.yml` gating.
4. **Query discipline**: `tool/web/react_query_state_baseline.json` has zero
   allowed findings — keep it that way.
5. **Governance culture**: bidirectional story↔registry checks, import
   boundaries, class-name boundaries. Phases here EXTEND these; never bypass
   or weaken them.

---

## 11. Implementation ledger

### 11.1 Phase A-admin — implemented locally 2026-07-12

Scope completed:
- Admin Vitest unit project, colocated behavioral tests, watch and informational
  coverage scripts.
- Finance controller loading/filtering/selection/error behavior and all three
  finance evidence-bound review states.
- Event/organizer intake decision mapping, checklist, curation, and publication
  readiness helpers.
- Live admin callable name/payload/error propagation coverage for the finance
  read boundary.
- Shared marketing decision, query-key, and pending-mutation-record helpers.
- Admin Storybook Vitest/a11y project and blocking CI wiring; informational
  coverage is non-blocking.

Local proof:
- `npm --workspace catch-admin run test` — 7 files, 19 tests passed.
- `npm --workspace catch-admin run test:coverage` — passed; informational
  aggregate line coverage 27.98%, finance controller line coverage 95.06%.
- `npm --workspace catch-admin run test:storybook:a11y` — 5 files, 249 tests
  passed.
- `npm --workspace catch-admin run typecheck` — passed, including all admin
  React governance scanners.
- `npm --workspace catch-admin run build` — passed.
- `npm --workspace catch-admin run build:storybook` — passed.

Verified review deltas:
- The finance controller currently exposes no money-touching mutation. Tests
  therefore lock its read/query/error behavior and its explicit blocked-action
  evidence boundaries; mutation payload coverage becomes required when such a
  callable is introduced.
- `admin/src/shared/contracts/intakeApprovalContracts.ts` currently declares
  schema-generated aliases only and has no mapping functions. Mapping-function
  tests remain pending until a real runtime mapper exists; no speculative API
  was added in this foundation PR.
- CI is wired locally but is not considered GitHub-verified until the workflow
  runs on the pushed PR.


### 11.2 Phase B-admin family manifest

Generated from the pre-split declaration order. Existing imports continue to resolve through `AdminPrimitives/index.ts`.

| Export | Target file |
|---|---|
| `AdminAppShell` | `admin/src/shared/ui/AdminPrimitives/shell.tsx` |
| `AdminSidebar` | `admin/src/shared/ui/AdminPrimitives/shell.tsx` |
| `AdminBrandBlock` | `admin/src/shared/ui/AdminPrimitives/shell.tsx` |
| `AdminBrandMark` | `admin/src/shared/ui/AdminPrimitives/shell.tsx` |
| `AdminBrandCopy` | `admin/src/shared/ui/AdminPrimitives/shell.tsx` |
| `AdminBrandTitle` | `admin/src/shared/ui/AdminPrimitives/shell.tsx` |
| `AdminBrandSubtitle` | `admin/src/shared/ui/AdminPrimitives/shell.tsx` |
| `AdminNavList` | `admin/src/shared/ui/AdminPrimitives/shell.tsx` |
| `AdminSidebarFooter` | `admin/src/shared/ui/AdminPrimitives/shell.tsx` |
| `AdminWorkspace` | `admin/src/shared/ui/AdminPrimitives/shell.tsx` |
| `AdminTopbar` | `admin/src/shared/ui/AdminPrimitives/shell.tsx` |
| `AdminTopbarActions` | `admin/src/shared/ui/AdminPrimitives/shell.tsx` |
| `AdminSignInScreen` | `admin/src/shared/ui/AdminPrimitives/shell.tsx` |
| `AdminSignInPanel` | `admin/src/shared/ui/AdminPrimitives/shell.tsx` |
| `AdminSignInMeta` | `admin/src/shared/ui/AdminPrimitives/shell.tsx` |
| `AdminSignInActions` | `admin/src/shared/ui/AdminPrimitives/shell.tsx` |
| `AdminEyebrow` | `admin/src/shared/ui/AdminPrimitives/shell.tsx` |
| `AdminButton` | `admin/src/shared/ui/AdminPrimitives/overview.tsx` |
| `AdminOverviewMainGrid` | `admin/src/shared/ui/AdminPrimitives/overview.tsx` |
| `AdminOverviewQueueColumns` | `admin/src/shared/ui/AdminPrimitives/overview.tsx` |
| `AdminOverviewAnalyticsClearButton` | `admin/src/shared/ui/AdminPrimitives/overview.tsx` |
| `AdminOverviewQueueList` | `admin/src/shared/ui/AdminPrimitives/overview.tsx` |
| `AdminOverviewQueueHeading` | `admin/src/shared/ui/AdminPrimitives/overview.tsx` |
| `AdminOverviewQueueItems` | `admin/src/shared/ui/AdminPrimitives/overview.tsx` |
| `AdminOverviewQueueRow` | `admin/src/shared/ui/AdminPrimitives/overview.tsx` |
| `AdminOverviewQueueRowActions` | `admin/src/shared/ui/AdminPrimitives/overview.tsx` |
| `AdminOverviewQueueActionHint` | `admin/src/shared/ui/AdminPrimitives/overview.tsx` |
| `AdminOverviewQueueDecisionButton` | `admin/src/shared/ui/AdminPrimitives/overview.tsx` |
| `AdminOverviewQueueDetailPanel` | `admin/src/shared/ui/AdminPrimitives/overview.tsx` |
| `AdminOverviewLineChart` | `admin/src/shared/ui/AdminPrimitives/overview.tsx` |
| `AdminOverviewBarChart` | `admin/src/shared/ui/AdminPrimitives/overview.tsx` |
| `AdminOverviewValueSignals` | `admin/src/shared/ui/AdminPrimitives/overview.tsx` |
| `AdminIconButton` | `admin/src/shared/ui/AdminPrimitives/actions.tsx` |
| `AdminLinkButton` | `admin/src/shared/ui/AdminPrimitives/actions.tsx` |
| `FilePickerButton` | `admin/src/shared/ui/AdminPrimitives/actions.tsx` |
| `AdminNavButton` | `admin/src/shared/ui/AdminPrimitives/actions.tsx` |
| `SearchField` | `admin/src/shared/ui/AdminPrimitives/actions.tsx` |
| `InlineTextField` | `admin/src/shared/ui/AdminPrimitives/actions.tsx` |
| `SegmentedControl` | `admin/src/shared/ui/AdminPrimitives/actions.tsx` |
| `StatusBanner` | `admin/src/shared/ui/AdminPrimitives/metrics.tsx` |
| `AdminMetricGrid` | `admin/src/shared/ui/AdminPrimitives/metrics.tsx` |
| `AdminMetricCard` | `admin/src/shared/ui/AdminPrimitives/metrics.tsx` |
| `AdminPublishingLoadbar` | `admin/src/shared/ui/AdminPrimitives/metrics.tsx` |
| `AdminSurfacePreview` | `admin/src/shared/ui/AdminPrimitives/metrics.tsx` |
| `AdminMutedCell` | `admin/src/shared/ui/AdminPrimitives/metrics.tsx` |
| `AdminPanelActions` | `admin/src/shared/ui/AdminPrimitives/metrics.tsx` |
| `AdminEventSupplyReviewGrid` | `admin/src/shared/ui/AdminPrimitives/metrics.tsx` |
| `AdminEventSupplyDetailStack` | `admin/src/shared/ui/AdminPrimitives/metrics.tsx` |
| `AdminEventSupplyDetail` | `admin/src/shared/ui/AdminPrimitives/metrics.tsx` |
| `AdminEventSupplyLinks` | `admin/src/shared/ui/AdminPrimitives/metrics.tsx` |
| `AdminToolbar` | `admin/src/shared/ui/AdminPrimitives/workbench.tsx` |
| `AdminCommandStack` | `admin/src/shared/ui/AdminPrimitives/workbench.tsx` |
| `AdminCommandRow` | `admin/src/shared/ui/AdminPrimitives/workbench.tsx` |
| `AdminWorkbenchNote` | `admin/src/shared/ui/AdminPrimitives/workbench.tsx` |
| `AdminWorkbenchStack` | `admin/src/shared/ui/AdminPrimitives/workbench.tsx` |
| `AdminChecklistStack` | `admin/src/shared/ui/AdminPrimitives/workbench.tsx` |
| `AdminDirectoryScreenStack` | `admin/src/shared/ui/AdminPrimitives/workbench.tsx` |
| `AdminDetailScreenStack` | `admin/src/shared/ui/AdminPrimitives/workbench.tsx` |
| `AdminEditorGrid` | `admin/src/shared/ui/AdminPrimitives/workbench.tsx` |
| `AdminStatusGrid` | `admin/src/shared/ui/AdminPrimitives/workbench.tsx` |
| `AdminFilterBar` | `admin/src/shared/ui/AdminPrimitives/workbench.tsx` |
| `EmptyState` | `admin/src/shared/ui/AdminPrimitives/workbench.tsx` |
| `AdminEventSupplyEmptyState` | `admin/src/shared/ui/AdminPrimitives/workbench.tsx` |
| `AdminFeatureLoadingState` | `admin/src/shared/ui/AdminPrimitives/workbench.tsx` |
| `AdminLoadingIcon` | `admin/src/shared/ui/AdminPrimitives/workbench.tsx` |
| `AdminEnvironmentStatus` | `admin/src/shared/ui/AdminPrimitives/workbench.tsx` |
| `AdminAuthStatus` | `admin/src/shared/ui/AdminPrimitives/workbench.tsx` |
| `PageHeader` | `admin/src/shared/ui/AdminPrimitives/marketing-shell.tsx` |
| `AdminMarketingOpsShell` | `admin/src/shared/ui/AdminPrimitives/marketing-shell.tsx` |
| `AdminIntakeEventWorkspaceShell` | `admin/src/shared/ui/AdminPrimitives/marketing-shell.tsx` |
| `AdminIntakeWorkspaceHeader` | `admin/src/shared/ui/AdminPrimitives/marketing-shell.tsx` |
| `AdminIntakeWorkspaceTabs` | `admin/src/shared/ui/AdminPrimitives/marketing-shell.tsx` |
| `AdminIntakeLayout` | `admin/src/shared/ui/AdminPrimitives/marketing-shell.tsx` |
| `AdminMarketingStudioHeader` | `admin/src/shared/ui/AdminPrimitives/marketing-shell.tsx` |
| `AdminMarketingStudioActions` | `admin/src/shared/ui/AdminPrimitives/marketing-shell.tsx` |
| `AdminMarketingStudioNav` | `admin/src/shared/ui/AdminPrimitives/marketing-shell.tsx` |
| `AdminMarketingTabs` | `admin/src/shared/ui/AdminPrimitives/marketing-shell.tsx` |
| `AdminMarketingStudioStack` | `admin/src/shared/ui/AdminPrimitives/marketing-shell.tsx` |
| `AdminMarketingStudioSummary` | `admin/src/shared/ui/AdminPrimitives/marketing-shell.tsx` |
| `AdminMarketingStudioSummaryItem` | `admin/src/shared/ui/AdminPrimitives/marketing-shell.tsx` |
| `AdminMarketingStudioFilterTabs` | `admin/src/shared/ui/AdminPrimitives/marketing-shell.tsx` |
| `AdminMarketingPostBoard` | `admin/src/shared/ui/AdminPrimitives/marketing-shell.tsx` |
| `AdminMarketingBoardColumn` | `admin/src/shared/ui/AdminPrimitives/marketing-shell.tsx` |
| `AdminMarketingBoardList` | `admin/src/shared/ui/AdminPrimitives/marketing-shell.tsx` |
| `AdminMarketingPostTypeBadge` | `admin/src/shared/ui/AdminPrimitives/marketing-shell.tsx` |
| `AdminMarketingComposer` | `admin/src/shared/ui/AdminPrimitives/marketing-composer.tsx` |
| `AdminMarketingComposerHeader` | `admin/src/shared/ui/AdminPrimitives/marketing-composer.tsx` |
| `AdminMarketingComposerBackButton` | `admin/src/shared/ui/AdminPrimitives/marketing-composer.tsx` |
| `AdminMarketingStepStrip` | `admin/src/shared/ui/AdminPrimitives/marketing-composer.tsx` |
| `AdminMarketingStepChip` | `admin/src/shared/ui/AdminPrimitives/marketing-composer.tsx` |
| `AdminMarketingStepLayout` | `admin/src/shared/ui/AdminPrimitives/marketing-composer.tsx` |
| `AdminMarketingComposerFooter` | `admin/src/shared/ui/AdminPrimitives/marketing-composer.tsx` |
| `AdminMarketingPickerList` | `admin/src/shared/ui/AdminPrimitives/marketing-composer.tsx` |
| `AdminMarketingPickerRow` | `admin/src/shared/ui/AdminPrimitives/marketing-composer.tsx` |
| `AdminMarketingFeatureShotGrid` | `admin/src/shared/ui/AdminPrimitives/marketing-composer.tsx` |
| `AdminMarketingFeatureShotCard` | `admin/src/shared/ui/AdminPrimitives/marketing-composer.tsx` |
| `AdminMarketingBrandContract` | `admin/src/shared/ui/AdminPrimitives/marketing-composer.tsx` |
| `AdminMarketingBrandContractItem` | `admin/src/shared/ui/AdminPrimitives/marketing-composer.tsx` |
| `AdminMarketingHelpText` | `admin/src/shared/ui/AdminPrimitives/marketing-library.tsx` |
| `AdminMarketingComplianceList` | `admin/src/shared/ui/AdminPrimitives/marketing-library.tsx` |
| `AdminMarketingEventLibraryGrid` | `admin/src/shared/ui/AdminPrimitives/marketing-library.tsx` |
| `AdminMarketingLibraryCard` | `admin/src/shared/ui/AdminPrimitives/marketing-library.tsx` |
| `AdminMarketingCardLink` | `admin/src/shared/ui/AdminPrimitives/marketing-library.tsx` |
| `AdminMarketingMediaGrid` | `admin/src/shared/ui/AdminPrimitives/marketing-library.tsx` |
| `AdminMarketingMediaCard` | `admin/src/shared/ui/AdminPrimitives/marketing-library.tsx` |
| `AdminMarketingNewPostGrid` | `admin/src/shared/ui/AdminPrimitives/marketing-library.tsx` |
| `AdminMarketingNewPostCard` | `admin/src/shared/ui/AdminPrimitives/marketing-library.tsx` |
| `AdminMarketingGuideLayout` | `admin/src/shared/ui/AdminPrimitives/marketing-library.tsx` |
| `AdminMarketingDeliverable` | `admin/src/shared/ui/AdminPrimitives/marketing-library.tsx` |
| `AdminMarketingStackedSections` | `admin/src/shared/ui/AdminPrimitives/marketing-library.tsx` |
| `AdminMarketingGrid` | `admin/src/shared/ui/AdminPrimitives/marketing-library.tsx` |
| `AdminMarketingPanel` | `admin/src/shared/ui/AdminPrimitives/marketing-library.tsx` |
| `AdminMarketingTitleInput` | `admin/src/shared/ui/AdminPrimitives/marketing-library.tsx` |
| `AdminMarketingSection` | `admin/src/shared/ui/AdminPrimitives/marketing-library.tsx` |
| `AdminMarketingSectionHeader` | `admin/src/shared/ui/AdminPrimitives/marketing-library.tsx` |
| `AdminMarketingEditGrid` | `admin/src/shared/ui/AdminPrimitives/marketing-library.tsx` |
| `AdminMarketingAppCapturePreview` | `admin/src/shared/ui/AdminPrimitives/marketing-library.tsx` |
| `AdminMarketingAppMediaPaths` | `admin/src/shared/ui/AdminPrimitives/marketing-library.tsx` |
| `AdminCard` | `admin/src/shared/ui/AdminPrimitives/cards.tsx` |
| `AdminCardList` | `admin/src/shared/ui/AdminPrimitives/cards.tsx` |
| `AdminStatGrid` | `admin/src/shared/ui/AdminPrimitives/cards.tsx` |
| `AdminDiffList` | `admin/src/shared/ui/AdminPrimitives/cards.tsx` |
| `AdminDiffRow` | `admin/src/shared/ui/AdminPrimitives/cards.tsx` |
| `SelectableCardButton` | `admin/src/shared/ui/AdminPrimitives/cards.tsx` |
| `CardHeader` | `admin/src/shared/ui/AdminPrimitives/cards.tsx` |
| `StatusChip` | `admin/src/shared/ui/AdminPrimitives/cards.tsx` |
| `AdminTag` | `admin/src/shared/ui/AdminPrimitives/cards.tsx` |
| `AdminTagList` | `admin/src/shared/ui/AdminPrimitives/cards.tsx` |
| `AdminRowTitle` | `admin/src/shared/ui/AdminPrimitives/cards.tsx` |
| `AdminTagRow` | `admin/src/shared/ui/AdminPrimitives/cards.tsx` |
| `AdminRoadmapList` | `admin/src/shared/ui/AdminPrimitives/cards.tsx` |
| `AdminRoadmapListItem` | `admin/src/shared/ui/AdminPrimitives/cards.tsx` |
| `AdminIntakeSection` | `admin/src/shared/ui/AdminPrimitives/intake.tsx` |
| `AdminOrganizerIntakeCurationPanel` | `admin/src/shared/ui/AdminPrimitives/intake.tsx` |
| `AdminIntakeSectionTitle` | `admin/src/shared/ui/AdminPrimitives/intake.tsx` |
| `AdminIntakeStateGrid` | `admin/src/shared/ui/AdminPrimitives/intake.tsx` |
| `AdminOrganizerIntakeList` | `admin/src/shared/ui/AdminPrimitives/intake.tsx` |
| `AdminOrganizerIntakeCard` | `admin/src/shared/ui/AdminPrimitives/intake.tsx` |
| `AdminOrganizerIntakeCardHeader` | `admin/src/shared/ui/AdminPrimitives/intake.tsx` |
| `AdminOrganizerIntakeBadges` | `admin/src/shared/ui/AdminPrimitives/intake.tsx` |
| `AdminOrganizerPolicyGapColumns` | `admin/src/shared/ui/AdminPrimitives/intake.tsx` |
| `AdminOrganizerLocationResolutionForm` | `admin/src/shared/ui/AdminPrimitives/intake.tsx` |
| `AdminOrganizerIntakeSurfaceGrid` | `admin/src/shared/ui/AdminPrimitives/intake.tsx` |
| `AdminOrganizerSurfaceList` | `admin/src/shared/ui/AdminPrimitives/intake.tsx` |
| `AdminOrganizerSurfaceRow` | `admin/src/shared/ui/AdminPrimitives/intake.tsx` |
| `AdminOrganizerCurationControlSection` | `admin/src/shared/ui/AdminPrimitives/intake.tsx` |
| `AdminOrganizerCurationControlGrid` | `admin/src/shared/ui/AdminPrimitives/intake.tsx` |
| `AdminIntakeDecisionState` | `admin/src/shared/ui/AdminPrimitives/intake.tsx` |
| `AdminIntakeDecisionBox` | `admin/src/shared/ui/AdminPrimitives/intake.tsx` |
| `AdminIntakeDecisionActions` | `admin/src/shared/ui/AdminPrimitives/intake.tsx` |
| `AdminDecisionFooterShell` | `admin/src/shared/ui/AdminPrimitives/intake.tsx` |
| `AdminSearchCandidatePanel` | `admin/src/shared/ui/AdminPrimitives/intake.tsx` |
| `AdminSearchCandidateList` | `admin/src/shared/ui/AdminPrimitives/intake.tsx` |
| `AdminSearchCandidateCard` | `admin/src/shared/ui/AdminPrimitives/intake.tsx` |
| `AdminSearchCandidateHeader` | `admin/src/shared/ui/AdminPrimitives/intake.tsx` |
| `AdminSearchCandidateSnippet` | `admin/src/shared/ui/AdminPrimitives/intake.tsx` |
| `AdminSearchCandidateActions` | `admin/src/shared/ui/AdminPrimitives/intake.tsx` |
| `TagList` | `admin/src/shared/ui/AdminPrimitives/marketing-editor.tsx` |
| `AdminQueryList` | `admin/src/shared/ui/AdminPrimitives/marketing-editor.tsx` |
| `AdminQueryRow` | `admin/src/shared/ui/AdminPrimitives/marketing-editor.tsx` |
| `AdminMarketingSlideList` | `admin/src/shared/ui/AdminPrimitives/marketing-editor.tsx` |
| `AdminMarketingSlideEditor` | `admin/src/shared/ui/AdminPrimitives/marketing-editor.tsx` |
| `AdminMarketingSlideEditorTopline` | `admin/src/shared/ui/AdminPrimitives/marketing-editor.tsx` |
| `AdminMarketingRecommendationList` | `admin/src/shared/ui/AdminPrimitives/marketing-editor.tsx` |
| `AdminMarketingRecommendationItem` | `admin/src/shared/ui/AdminPrimitives/marketing-editor.tsx` |
| `AdminMarketingAuditList` | `admin/src/shared/ui/AdminPrimitives/marketing-editor.tsx` |
| `AdminMarketingAuditRow` | `admin/src/shared/ui/AdminPrimitives/marketing-editor.tsx` |
| `AdminFeatureDropFeatureList` | `admin/src/shared/ui/AdminPrimitives/marketing-editor.tsx` |
| `AdminFeatureDropFeatureEditor` | `admin/src/shared/ui/AdminPrimitives/marketing-editor.tsx` |
| `AdminFeatureDropControlGrid` | `admin/src/shared/ui/AdminPrimitives/marketing-editor.tsx` |
| `AdminFeatureDropWideField` | `admin/src/shared/ui/AdminPrimitives/marketing-editor.tsx` |
| `AdminFeatureDropPreviewGrid` | `admin/src/shared/ui/AdminPrimitives/marketing-editor.tsx` |
| `AdminFeatureDropPreviewCard` | `admin/src/shared/ui/AdminPrimitives/marketing-editor.tsx` |
| `AdminMarketingPreviewShell` | `admin/src/shared/ui/AdminPrimitives/marketing-editor.tsx` |
| `AdminMarketingPreviewToolbar` | `admin/src/shared/ui/AdminPrimitives/marketing-editor.tsx` |
| `AdminMarketingPreviewActions` | `admin/src/shared/ui/AdminPrimitives/marketing-editor.tsx` |
| `AdminMarketingCarouselPreview` | `admin/src/shared/ui/AdminPrimitives/marketing-editor.tsx` |
| `AdminMarketingPreviewSlide` | `admin/src/shared/ui/AdminPrimitives/marketing-editor.tsx` |
| `AdminMarketingPreviewMeta` | `admin/src/shared/ui/AdminPrimitives/marketing-editor.tsx` |
| `AdminMarketingPreviewImage` | `admin/src/shared/ui/AdminPrimitives/marketing-editor.tsx` |
| `AdminMarketingPreviewBrandNote` | `admin/src/shared/ui/AdminPrimitives/marketing-editor.tsx` |
| `AdminMarketingPreviewCopy` | `admin/src/shared/ui/AdminPrimitives/marketing-editor.tsx` |
| `AdminMarketingExportStatus` | `admin/src/shared/ui/AdminPrimitives/marketing-editor.tsx` |
| `AdminMarketingImageEditor` | `admin/src/shared/ui/AdminPrimitives/media.tsx` |
| `AdminMarketingImageEditorHeader` | `admin/src/shared/ui/AdminPrimitives/media.tsx` |
| `AdminMarketingImageControls` | `admin/src/shared/ui/AdminPrimitives/media.tsx` |
| `AdminMarketingFilePickerButton` | `admin/src/shared/ui/AdminPrimitives/media.tsx` |
| `AdminMarketingImageReviewRow` | `admin/src/shared/ui/AdminPrimitives/media.tsx` |
| `AdminMarketingImageThumb` | `admin/src/shared/ui/AdminPrimitives/media.tsx` |
| `AdminFeatureDropCaptureThumb` | `admin/src/shared/ui/AdminPrimitives/media.tsx` |
| `AdminMarketingImageMetaFields` | `admin/src/shared/ui/AdminPrimitives/media.tsx` |
| `AdminMarketingImageSourceNote` | `admin/src/shared/ui/AdminPrimitives/media.tsx` |
| `AdminMarketingImageEmpty` | `admin/src/shared/ui/AdminPrimitives/media.tsx` |
| `AdminGuardrailList` | `admin/src/shared/ui/AdminPrimitives/media.tsx` |
| `AdminIntakeSourceList` | `admin/src/shared/ui/AdminPrimitives/media.tsx` |
| `AdminIntakeGateList` | `admin/src/shared/ui/AdminPrimitives/media.tsx` |
| `AdminIntakeGate` | `admin/src/shared/ui/AdminPrimitives/media.tsx` |
| `AlertRow` | `admin/src/shared/ui/AdminPrimitives/data.tsx` |
| `QualityRow` | `admin/src/shared/ui/AdminPrimitives/data.tsx` |
| `QualityList` | `admin/src/shared/ui/AdminPrimitives/data.tsx` |
| `DataTable` | `admin/src/shared/ui/AdminPrimitives/data.tsx` |
| `AdminTableRow` | `admin/src/shared/ui/AdminPrimitives/data.tsx` |
| `AdminForm` | `admin/src/shared/ui/AdminPrimitives/data.tsx` |
| `AdminPublishingFormShell` | `admin/src/shared/ui/AdminPrimitives/data.tsx` |
| `AdminEditorSection` | `admin/src/shared/ui/AdminPrimitives/data.tsx` |
| `AdminFieldGrid` | `admin/src/shared/ui/AdminPrimitives/data.tsx` |
| `TableActionButton` | `admin/src/shared/ui/AdminPrimitives/data.tsx` |
| `RiskBadge` | `admin/src/shared/ui/AdminPrimitives/data.tsx` |
| `AdminPanel` | `admin/src/shared/ui/AdminPrimitives/data.tsx` |
| `Panel` | `admin/src/shared/ui/AdminPrimitives/data.tsx` |
| `AdminIntakePublicationBoundaryPanel` | `admin/src/shared/ui/AdminPrimitives/data.tsx` |
| `AdminEditorPanel` | `admin/src/shared/ui/AdminPrimitives/forms.tsx` |
| `AdminStateRow` | `admin/src/shared/ui/AdminPrimitives/forms.tsx` |
| `StateRow` | `admin/src/shared/ui/AdminPrimitives/forms.tsx` |
| `AdminTextField` | `admin/src/shared/ui/AdminPrimitives/forms.tsx` |
| `TextField` | `admin/src/shared/ui/AdminPrimitives/forms.tsx` |
| `CheckboxField` | `admin/src/shared/ui/AdminPrimitives/forms.tsx` |
| `AdminOrganizerIntakeCheckboxField` | `admin/src/shared/ui/AdminPrimitives/forms.tsx` |
| `AdminTextareaField` | `admin/src/shared/ui/AdminPrimitives/forms.tsx` |
| `DecisionFooter` | `admin/src/shared/ui/AdminPrimitives/forms.tsx` |
| `TextareaField` | `admin/src/shared/ui/AdminPrimitives/forms.tsx` |
| `AdminMarketingSelectField` | `admin/src/shared/ui/AdminPrimitives/forms.tsx` |
| `SelectField` | `admin/src/shared/ui/AdminPrimitives/forms.tsx` |

### 11.3 Phase B-admin — implemented locally 2026-07-12

- Replaced the 3,956-line monolith with 14 UI-family modules, a private shared
  type/helper module, and the existing-path `AdminPrimitives/index.ts` barrel.
- Preserved all 223 export names and every external import site unchanged.
- Updated the admin component registry to point each primitive at its concrete
  family owner; registry version is 20.
- Production and Storybook CSS are byte-identical before and after the split:
  `5d9c1bba841ac3cce2c0dd280b07c96c6e76bb8e` and
  `d9e01d2c902296d149b48d1e4ed7ec763f42bd0a`, respectively.
- Local gates passed: admin unit tests, typecheck/governance, production build,
  and Storybook build. Storybook a11y is rerun as the final phase receipt.

### 11.4 Phase F — implemented locally 2026-07-12

- `adminApi.ts` now routes all 34 live callable names through one validating
  wrapper. Requests validate before Firebase invocation; responses validate in
  development or when `VITE_ADMIN_VALIDATE_RESPONSES=true`.
- The committed generated registry covers every callable, with 18 strict
  request schemas and 2 strict response schemas sourced from `contracts/`.
  Remaining callables have explicit top-level object validators and are listed
  separately from strict coverage rather than being silently omitted.
- `admin/scripts/generateCallableValidators.mjs --check` is wired into
  `pretypecheck`, the tool manifest, enforcement integrity, and admin CI path
  triggers for callable, response, and shared schema changes.
- `AdminCallableValidationError` names the callable, request/response direction,
  and first failing JSON instance path.
- Known-good and known-bad fixtures cover analytics, organizer-claim, and event
  publishing schema families. The API boundary tests prove invalid requests do
  not invoke Firebase and invalid development responses fail visibly.
- Local proof: 8 unit files / 28 tests passed; validator drift self-test,
  typecheck/governance, and production build passed.

### 11.5 Phase D checker scaffold — implemented locally 2026-07-12

- Component registry version 2 requires a `surfaces` map on every contract;
  all 60 current contracts bind their Flutter symbol.
- Seeded 11 website/admin links across button, badge, empty-state, field,
  icon-button, search-field, and segmented-control families. Phase C will add
  the extracted `webui` links and any matching reverse registry entries.
- Website/admin component schemas support `lexicon: true` plus `lexiconId`;
  reverse links must match the contract's declared surface symbol exactly.
- `design:component-lexicon` is registered as a blocking gate and runs in
  Flutter, admin, and marketing CI. Its seeded known-bad test replaces a real
  website symbol with a nonexistent export and proves the checker fails.
- Local proof: 60 contracts / 71 surface links pass; component contracts pass;
  known-bad test passes; enforcement integrity reports 63 active rules and 45
  bound tools.

### 11.6 Phase A-website — implemented locally 2026-07-12

- Added the Vitest `unit` project beside the unchanged Storybook project plus
  blocking `test:unit` and informational coverage scripts/CI steps.
- Seven colocated suites / 14 tests cover organizer URL/event selectors, public
  discovery models, waitlist validation/submission/status, host application
  completeness/navigation/submission, CTA analytics payloads, interpolation,
  metadata validation, and market-derived selectors.
- Tests read generated organizer data only through the feature data boundary
  and introduce no unmanaged marketing copy.
- Local proof: unit tests pass; aggregate unit line coverage is 62.25%; website
  typecheck and all copy/route/component/import/governance gates pass;
  production and Storybook builds pass.

### 11.7 Phase B-website — implemented locally 2026-07-12

- Replaced the 4,977-line primitive monolith with an existing-path
  `primitives/index.ts` barrel and 17 dependency-checked family modules:
  `actions{,2}`, `forms{,2}`, `feedback`, `foundation`, `host{,2,3}`,
  `layout{,2}`, `marketing`, `media{,2}`, and `organizer{,2,3}`.
- Every external `shared/ui/primitives` import remains unchanged. The 45
  registry-backed shared primitives now point to their concrete family owner.
- Family files are grouped by UI responsibility and remain near the target
  size (20–414 lines); cross-family dependencies are explicit imports rather
  than hidden page buckets.
- The website copy ratchet was reconciled with the split: baseline remains
  empty and only shared technical class/accessibility defaults are allowlisted.
- Local proof: route/component/copy/import/primitive/class-name/governance
  gates and TypeScript pass; production/Storybook/a11y/visual proof is part of
  the final verification receipt.

### 11.8 Phase C — implemented locally 2026-07-12

- Added `packages/web-ui` as the third JavaScript workspace with React 19 as a
  peer dependency and no Firebase, router, query, or feature imports.
- Extraction inventory and adoption:

| Shared export | Website adoption | Admin adoption |
|---|---|---|
| `classNames` | re-exported by `primitives/foundation.tsx` | re-exported by `AdminPrimitives/shared.ts` |
| `UiLabel` | configured by the website `UiLabel` adapter | configured by `AdminEyebrow` |
| `CheckboxControl` | configured by website `CheckboxField` | configured by admin `CheckboxField` |

- Both Storybooks load the package story file. `design/web-ui/components.json`
  registers the two visual components; both app import-boundary gates permit
  only the package root and reject `@catch/web-ui/*` deep imports.
- The primitive, class-name, and component-governance scanners accept
  `--surface webui`. Both app typecheck suites and the lexicon check pass.

### 11.9 Phase D — completed locally 2026-07-12

- The Phase C set adds `webui: UiLabel` to `catch.badge` and
  `webui: CheckboxControl` to `catch.field`, with matching reverse links in
  the web-ui registry.
- Final local lexicon proof: 60 contracts and 73 surface links; Flutter,
  website, admin, and web-ui symbol existence all pass.

### 11.10 Phase E — implemented locally 2026-07-12

- Added `tool/web/check_storybook_visuals.mjs`, registered as
  `web:storybook-visuals` with a deterministic pixel-comparison self-test and
  rule `WEB-VISUAL-001`.
- The checker resolves only registry entries marked `ready` from the built
  Storybook index, fixes desktop 1280×800 and mobile 375×812 viewports,
  requests reduced motion, waits for fonts, disables animation, tolerates
  small antialiasing deltas, and writes failure diffs under
  `artifacts/visual-diffs/`.
- CI builds Storybook before compare mode on both apps. Website CI also checks
  the shared web-ui registry.
- Committed baseline inventory: website 103 stories / 206 captures, admin 249
  stories / 498 captures, web-ui 2 stories / 4 captures (708 PNGs total).
- Immediate compare-mode rerun passed all 708 captures.

### 11.11 Final verification receipt — 2026-07-12

- Unit tests: website 7 files / 14 tests; admin 8 files / 28 tests.
- Storybook accessibility: website 15 files / 123 tests; admin 6 files / 251
  tests. The lower website count relative to the pre-migration suite is the
  intentional removal of Host Preview route/section stories; web-ui stories
  are included by both Storybooks.
- Production builds: marketing Vite + postbuild and admin Vite passed after
  both full typecheck/governance chains.
- Visual regression: 708 committed captures; update mode followed immediately
  by clean compare mode for the changed website/web-ui set, with the unchanged
  admin set also clean in compare mode.
- Contracts/gates: route self-test and live contract, website/admin component
  registries, 60-component design contract, 73-link lexicon, zero-entry copy
  baseline, callable-validator drift, visual self-test, tool manifest, and
  `git diff --check` passed.
- Audit receipt: `2026-07-12-web-platform-hardening-final` stamped nine owner
  paths with the implementation proof. Agent readiness is 100/100
  (1313/1313 checks).
