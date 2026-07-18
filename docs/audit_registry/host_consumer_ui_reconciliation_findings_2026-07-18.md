---
doc_id: host_consumer_ui_reconciliation_findings_2026_07_18
version: 1.0.0
updated: 2026-07-18
owner: recursive_audit_loop
status: resolved
---

# Host and Consumer UI Reconciliation Findings

This pass started from the reported Host Team, Live event guide, Host loading,
Host empty-state, Host Events, and event-create regressions. The requested
surfaces are fixed in source; this note records additional systemic findings
discovered while tracing them.

## Resolved findings

1. **The catalog and implementation had diverged.** Widget Catalog revisions
   2.5.627–2.5.632 described field-local Host profile saving, flattened
   questionnaire editing, collapsed create-event fields, and activity-colored
   choices, but source and tests still asserted the older UI. The source,
   tests, catalog, and regression ledger now agree on the restored contracts.

2. **Empty/error centering ignored floating shell geometry.** Feature screens
   individually composed `SliverFillRemaining`, and one Chats empty state added
   a local vertical spacer. Both approaches centered against the obscured
   scaffold rather than the visible region. `CatchSliverStateViewport` now
   owns the bottom-overlay correction for both empty and error states; the
   tab-root scanner rejects direct presentation-level composition.

3. **Custom leading content exposed an icon-width assumption.** `CatchSection`
   correctly aligned standard icon rows but always derived internal divider
   inset from the 24px icon token. Host Past dates are 48px and team avatars are
   42px, so their text and rules could not share a lane. `CatchField.leadingExtent`
   now makes that geometry explicit and testable.

4. **Loading reused the wrapper but selected the wrong semantic inset.** Host
   tab loading and loaded branches were structurally shared, but Edit/Insights
   and route skeletons selected `pageBodyUnderHeader` (4px) instead of the
   normal `pageBody` top rhythm (24px). Both states now use the same normal body
   inset; architecture guidance forbids tightening solely because data loads.

5. **A legacy empty-state component encoded obsolete containment.** Product
   call sites no longer use `HostEmptyActionCard`. Its catalog adapter is
   deprecated and now delegates to the cardless canonical empty state so old
   Widgetbook stories cannot revive the bordered-card treatment.

6. **The Live event guide divider was not app-bar chrome.** It was the top rule
   of a headerless `CatchSection.fieldRows(first: true)` placed immediately
   below the app bar. The enable toggle is now a standalone flush field; other
   headerless field sections remain valid only where a section boundary is
   actually intended.

## Deliberate boundaries

- Profile Preview retains its two intentional `SliverFillRemaining` inner
  viewport contracts; they render arbitrary preview content, not empty/error
  state placement, and are excluded from the new scanner rule.
- Calendar opts out of floating-shell correction because its state sliver is
  used inside a viewport whose bottom navigation geometry is already reserved.
- No uncertain visual redesign was applied: the pass restores documented
  primitive contracts and adds enforcement around repeated failure modes.
