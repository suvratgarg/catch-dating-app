---
doc_id: host_shell_route_ui_audit
version: 1.0.0
updated: 2026-08-29
owner: design_parity_review
status: active
---

# Host shell route UI audit

This is the extensible, source-backed UI-composition matrix for the primary
Host shell routes. Checklist items are rows; audited pages are columns. To add
a route, add one page column, its evidence block, and any new findings. Do not
fork the checklist for a new page.

The first pass audits source `06fa4297c8c0` on
`codex/component-geometry-system-simplify-20260828`, based on and zero commits
behind `origin/main` at `3fd7d84fdc24`. The audit branch contains the approved
geometry-system work that has not yet been merged to `origin/main`; this report
must not be read as a production-deployment receipt.

## Verdicts

| Mark | Meaning |
|---|---|
| ✅ | Conforms in inspected source and captured states |
| ◐ | Partially conforms, or a decision/risk remains |
| ❌ | Confirmed inconsistency or defect |
| ⏺ | Not applicable to this page |
| ◌ | Not exercised in this audit; do not infer a pass |

Issue references such as `HSA-001` point to the findings below. A terse cell is
intentional: the matrix should remain scannable as page columns are appended.

## Matrix

| Checklist | Events | Customers | Forms | Messages | Organizer |
|---|---|---|---|---|---|
| **SHELL-01 · One production route body inside the shared Host shell** | ✅ `/host/events` | ✅ `/host/customers` | ✅ `/host/forms` | ✅ `/host/inbox` | ✅ `/host/organizer` |
| **SHELL-02 · Correct destination order, selection, and organizer identity** | ◐ `HSA-003` | ◐ `HSA-003` | ◐ `HSA-003` | ◐ `HSA-003` | ◐ `HSA-003` |
| **HEADER-01 · Page owns one title/top-bar hierarchy** | ✅ scroll title + Create | ✅ scroll title + actions | ✅ tabbed scaffold | ◐ shared header reads global role, `HSA-006` | ✅ tabbed scaffold |
| **SCROLL-01 · Exactly one page scroll owner with terminal shell clearance** | ✅ sliver root + terminal padding | ✅ sliver root + terminal padding | ✅ one controller per tab | ✅ sliver root + terminal padding | ✅ one controller per tab |
| **RESP-01 · Compact, medium, and expanded composition is intentional** | ✅ coherent single workspace | ◐ no wide-pane strategy, `HSA-005` | ✅ bounded content lane | ◐ no master-detail strategy, `HSA-005` | ✅ bounded editor workspace |
| **GUTTER-01 · Page gutters and content-width constraints have one owner** | ✅ page/sliver owns lanes | ✅ page/sliver owns lanes | ✅ tabbed page constrains width | ✅ page/sliver owns lanes | ✅ tabbed page constrains width |
| **SECTION-01 · Contained/divided/plain treatment follows semantic role** | ✅ operational modules earn surfaces | ✅ summary/action/list frames earn surfaces | ✅ flat divided directory | ✅ flat context rails + thread rows | ✅ field sections use canonical variants |
| **SECTION-02 · Containment depth stays at one visible border** | ✅ | ✅ | ✅ | ✅ | ✅ |
| **SECTION-03 · Headers, kickers, counts, and dividers share one geometry** | ✅ | ✅ | ✅ | ✅ | ❌ media header collapses at 200%, `HSA-002` |
| **FIELD-01 · Rows/fields own capability geometry; parent owns list frame** | ✅ lifecycle rows | ✅ contained customer rows | ✅ divided rows | ✅ thread rows | ✅ canonical `CatchField` lanes |
| **RHYTHM-01 · Vertical spacing distinguishes hierarchy without card soup** | ✅ | ✅ borders have distinct jobs | ✅ | ✅ | ✅ |
| **ACTION-01 · One clear primary action per hierarchy level** | ◐ Create, run, and urgent review are distinct but visually loud | ◐ header, sort, filter, and campaign actions compete | ✅ | ✅ | ✅ |
| **SEARCH-01 · Search/filter/menu placement matches its scope** | ⏺ | ❌ whole-view search is body-owned, `HSA-004` | ✅ top-bar search + body lifecycle filter | ✅ top-bar search + workspace rails | ⏺ |
| **STATE-01 · Loading, empty, error, offline, and retry preserve the same shell** | ✅ source-backed | ✅ source-backed | ✅ source-backed | ✅ source-backed | ✅ source-backed |
| **MOTION-01 · Focus, selection, tab, and route transitions are coherent** | ◌ | ◌ | ◐ tab/menu tests exist; motion not visually audited | ◐ workspace transitions source-only | ◐ tabs/editor reveal source-only |
| **A11Y-01 · 200% text scale reflows without clipping or overflow** | ❌ 7.2 px overflow, `HSA-001` | ◐ awkward stat/nav compression, `HSA-003` | ◐ title/status rail truncate | ◐ nav/context labels truncate, `HSA-003` | ❌ title/media header collapse, `HSA-002/003` |
| **A11Y-02 · Labels, targets, and light/dark contrast remain legible** | ◐ shared primitives; visual check only | ◐ shared primitives; visual check only | ◐ shared primitives; visual check only | ◐ shared primitives; visual check only | ◐ shared primitives; visual check only |
| **ARCH-01 · Component boundaries expose ownership instead of a screen monolith** | ✅ feature split into focused parts | ❌ 1,855-line mixed surface, `HSA-007` | ◐ 633-line route + row actions | ◐ 874-line route + workspaces; `HSA-006` | ✅ route/scaffold/edit modules split |
| **GOV-01 · Widgetbook/capture/catalog use production widgets and current routes** | ◐ capture fixed; manifest stale, `HSA-008` | ◐ capture fixed; manifest stale, `HSA-008` | ◐ production capture added; manifest stale, `HSA-008` | ◐ index/role fixed; manifest stale, `HSA-008` | ◐ index fixed; manifest stale, `HSA-008` |

## Findings

### HSA-001 · Events spotlight overflows at 200% text — high

The deterministic `host_home_events_list` capture fails with a 7.2 px
horizontal `RenderFlex` overflow in
`HostEventOperationalSpotlight` (`host_events_overview.dart`, the stats/action
row around line 180). The title and venue also compete for the same horizontal
lane. The component needs a large-text layout branch that stacks the metadata
and lets the stats/action group wrap or switch to a vertical arrangement.

This is a production-widget defect, not a capture approximation.

### HSA-002 · Organizer media header does not reflow at 200% text — high

At 200% text, the `MEDIA` kicker is reduced to `M…` while the count and
`Manage images` action retain the row. The default-scale layout is good, but
the section-header primitive/call site needs a reflow contract: title/count on
one line and the trailing action below, or a wrap layout with the kicker given
non-negotiable width. The top title also truncates, but the destructive loss is
the section label.

### HSA-003 · The five-destination shell needs a large-label policy — medium

The 96 px medium rail truncates `Messaging`, and selected labels become
truncated at 200% text on the compact bottom bar. This is a shell-level issue,
so it repeats in every page column. The shell should explicitly choose one of
these policies by breakpoint/text scale: icon-only rail with full semantics,
a wider rail, or the expanded sidebar sooner. Do not solve it in individual
pages.

### HSA-004 · Customers uses a different whole-view search grammar — medium

Customers renders `CatchSearchField.expanded` inside the page body, while
Forms and Messages use the top-bar search contract for the active view.
Customers' sort and filter are correctly body-owned, but the search scope is
the whole directory. Either move it to `CatchTopBarSearch` for consistency or
document a deliberate `persistentDirectorySearch` variant and use it wherever
that behavior is intended. The current difference has no expressed semantic
reason in the API.

### HSA-005 · Wide Customers and Messages have no pane-composition rule — medium decision

Both pages adapt chrome at medium/expanded widths, but their content remains a
single list lane. At 1024 px, selecting a customer or thread still navigates
away instead of using the space for a persistent detail pane. This is not a
compact-layout defect; it is an unresolved wide-workspace policy. Recommended
default: introduce master-detail only at the expanded breakpoint, keep medium
as a rail plus single task, and let the page layout own the pane split.

### HSA-006 · Messaging header behavior depends on global app role — medium

`HostInboxScreen` composes `ChatsBrowseHeader`, and that shared header reads
`AppConfig.appRole` to choose host title/search copy. The hidden dependency is
why a capture lifecycle reset could render the consumer title `Chats` inside
the Host shell. Pass the presentation/title/search contract explicitly from
the host route (or add a typed host constructor); production widgets should not
derive visible hierarchy from mutable global test state.

### HSA-007 · Customers mixes too many composition layers in one file — medium

`host_customers_screen.dart` is 1,855 lines and owns the route, directory
toolbar, filter summary/sheet, add-customer sheet, identity card, conversation
card, attendance, revenue, and history components. The visible nesting is
mostly correct, but the source boundary obscures ownership. Split by route,
directory, filters, add sheet, and customer-detail sections without changing
their public primitives.

### HSA-008 · Host coverage metadata and capture routing drifted from production — high governance

The production shell has Events, Customers, Forms, Messaging, and Organizer.
Before this audit, `_HostRoutedShellCapture` still had four branches, Messaging
and Organizer used obsolete indices, Forms had no full-shell capture, Events
read the live repository instead of deterministic timeline data, and the
light/dark cycle could reset the role. Those capture defects are corrected in
this working branch.

`design/source_packs/host-v2/host-coverage-manifest.json` still calls itself
authoritative while describing four tabs (`Today / Events / Inbox /
Organizer`) and omitting the current Customers/Forms shell destinations. It
needs a deliberate full refresh; a partial date or count edit would preserve a
false claim of authority.

## Page evidence

The capture IDs below instantiate the canonical production shell and route
widgets with deterministic provider fixtures. Generated PNGs are local,
ignored artifacts; rerun the commands rather than treating the PNG directory
as source authority.

| Page | Route | Production widget | Capture ID | Primary source |
|---|---|---|---|---|
| Events | `/host/events` | `HostOperationsHomeScreen` | `host_home_events_list` | `lib/hosts/presentation/host_operations/host_events_list.dart` |
| Customers | `/host/customers` | `HostCustomersScreen` | `host_customers_populated` | `lib/hosts/presentation/customers/host_customers_screen.dart` |
| Forms | `/host/forms` | `HostFormsScreen` | `host_forms_populated` | `lib/hosts/presentation/forms/host_forms_screen.dart` |
| Messages | `/host/inbox` | `HostInboxScreen` | `host_inbox_queries` | `lib/hosts/presentation/inbox/host_inbox_screen.dart` |
| Organizer | `/host/organizer` | `HostClubsScreen` | `host_clubs_management` | `lib/hosts/presentation/host_operations/host_clubs_scaffold.dart` |

Reproducible capture contexts:

```sh
node tool/ui_capture/run_captures.mjs \
  --ids host_home_events_list,host_customers_populated,host_forms_populated,host_inbox_queries,host_clubs_management \
  --device claude-phone-390x812 \
  --output-dir artifacts/ui-captures/host-shell-audit/phone

node tool/ui_capture/run_captures.mjs \
  --ids host_home_events_list,host_customers_populated,host_forms_populated,host_inbox_queries,host_clubs_management \
  --device audit-medium-700x1000 \
  --output-dir artifacts/ui-captures/host-shell-audit/medium

node tool/ui_capture/run_captures.mjs \
  --ids host_home_events_list,host_customers_populated,host_forms_populated,host_inbox_queries,host_clubs_management \
  --device audit-tablet-1024x1366 \
  --output-dir artifacts/ui-captures/host-shell-audit/tablet

node tool/ui_capture/run_captures.mjs \
  --ids host_home_events_list,host_customers_populated,host_forms_populated,host_inbox_queries,host_clubs_management \
  --device claude-phone-390x812 \
  --text-scale 2.0 \
  --output-dir artifacts/ui-captures/host-shell-audit/text-scale-2
```

The first three runs pass. The 200% run intentionally remains red until
`HSA-001` is fixed; it records the confirmed Events overflow while still
writing the five page images.

## Visual baseline

### Compact, light

| Events | Customers | Forms | Messages | Organizer |
|---|---|---|---|---|
| ![Events compact](../../artifacts/ui-captures/host-shell-audit/phone/host_home_events_list/light.png) | ![Customers compact](../../artifacts/ui-captures/host-shell-audit/phone/host_customers_populated/light.png) | ![Forms compact](../../artifacts/ui-captures/host-shell-audit/phone/host_forms_populated/light.png) | ![Messages compact](../../artifacts/ui-captures/host-shell-audit/phone/host_inbox_queries/light.png) | ![Organizer compact](../../artifacts/ui-captures/host-shell-audit/phone/host_clubs_management/light.png) |

### Expanded, light

| Events | Customers | Forms | Messages | Organizer |
|---|---|---|---|---|
| ![Events expanded](../../artifacts/ui-captures/host-shell-audit/tablet/host_home_events_list/light.png) | ![Customers expanded](../../artifacts/ui-captures/host-shell-audit/tablet/host_customers_populated/light.png) | ![Forms expanded](../../artifacts/ui-captures/host-shell-audit/tablet/host_forms_populated/light.png) | ![Messages expanded](../../artifacts/ui-captures/host-shell-audit/tablet/host_inbox_queries/light.png) | ![Organizer expanded](../../artifacts/ui-captures/host-shell-audit/tablet/host_clubs_management/light.png) |

## Evidence limits

- Default, dark, medium, expanded, and 200% text layouts were rendered.
- Loading/empty/error/offline shell preservation was inspected in source, not
  exhaustively screenshot in this pass.
- Tab, focus, pressed, menu, keyboard, route, and animation sequences were not
  interacted through end to end; `MOTION-01` stays unverified or source-only.
- Contrast was judged visually in both themes; no automated WCAG contrast
  measurement was run.
- The audit is an architecture/design assessment, not a production deployment
  or merge receipt.
