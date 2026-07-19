---
doc_id: widget_concept_report
version: 2.0.0
updated: 2026-07-18
owner: widget_consolidation
status: generated
generated_by: tool/design/build_widget_concept_report.mjs
---

# Widget concept system report

This report is generated from the component contract, production widget
classification, similarity registry, decision ledger reconciliation, and
design-sync manifest. Do not edit it by hand. The machine-readable companion is
`docs/audit_registry/widget_concept_metrics.json`.

## Outcome

| Measure | Before | Current | Interpretation |
|---|---:|---:|---|
| Top-level contract entries | 64 | 69 | Contracts may remain useful without claiming concept identity. |
| Independent concepts | 64 proxy | 63 | 1 fewer than the old top-level proxy (1.56%); count accuracy, not reduction, is the objective. |
| Contracted public widget classes | — | 196 | Primaries and members are counted separately from concepts. |
| Member APIs | — | 116 (1.84 per concept) | Public seams do not inflate concept count. |
| Unclassified contracted entries | — | 0 | Must remain zero. |
| Production widget/state classes | — | 1094 | Exhaustive generated inventory. |
| Instantiated concept primaries | — | 62 | One contracted primary is not a runtime Widget declaration. |
| Public member widget classes | — | 116 | Role is inherited from the component contract. |
| Public composition widget classes | — | 514 | Excluded from concept count. |
| Public screen widget classes | — | 268 | Excluded from concept count. |
| Unclassified public widgets | — | 0 | Must remain zero. |
| Widgetbook-complete concept primaries | — | 62/62 | Evidence is role-derived. |
| Widgetbook-covered member classes | — | 116/116 | Reviewed directly or under the parent family. |
| Owner/live gate queue | — | 3 | Unresolved semantic decisions and externally gated design-tool proof appear here. |

## Collision and ledger coverage

| Measure | Current |
|---|---:|
| Derived contracted collision groups | 32 |
| Production collision groups | 32 |
| Structural similarity clusters | 43 |
| Clusters with exact normalized-member-set decisions | 43/43 |
| Unresolved collision families | 0 |
| Ranked pairs covered by a ledger decision | 145/200 |
| Unresolved ranked pairs | 55 |
| Ledger decisions indexed | 315 |

Similarity is discovery evidence only. A collision or unresolved pair is a
candidate for review, never permission to merge.

## Per-family concept and class deltas

| Family | Concepts before | Concepts current | Concept delta | Proposed concepts | Public classes before | Public classes current | Class delta |
|---|---:|---:|---:|---:|---:|---:|---:|
| Error state | 1 | 1 | 0 | — | 8 | 8 | 0 |
| Person row | 1 | 1 | 0 | — | 6 | 6 | 0 |
| Meta row vs stage label | 0 | 1 | +1 | — | 2 | 2 | 0 |
| Notification + privacy | 4 | 2 | -2 | — | 4 | 4 | 0 |
| Option group + tab rail | 2 | 1 | -1 | — | 2 | 2 | 0 |
| Club dock | 1 | 0 | -1 | — | 1 | 1 | 0 |
| Event detail screen body | 1 | 0 | -1 | — | 1 | 1 | 0 |
| Loading | 1 | 3 | +2 | 3 | 8 | 8 | 0 |

Concept identity and Dart class count are deliberately independent. The loading
decompression changes contract identity without unnecessary Dart API churn;
renderer consolidations are measured separately from concept count.

## Four-outcome calibration

| Family | Classification | Result |
|---|---|---|
| Error and person rows | one concept, multiple members | Placement and layout APIs remain public while sharing one concept id. |
| CatchMetaRow vs StageSectionLabel | concept vs feature composition | Metadata and structural hierarchy remain separate despite visual similarity. |
| NotificationRow and CatchPrivacyBadge | composition and recipe member | Notification composes CatchField; privacy composes CatchBadge.privacy. |
| Loading | implemented | Three concepts now own skeletons, indeterminate progress, and async-value boundaries; CatchStartupLoadingScreen is a composition. |

## Design-tool readiness

| Measure | Current |
|---|---:|
| Figma current mappings | 0 |
| Figma stale mappings | 0 |
| Figma missing mappings | 69 |
| Figma property drift findings | 0 |
| Figma mappings with variable-bound evidence | 0 |
| Figma review snapshots | 0 |
| Code Connect mapped contracts | 0 |
| Code Connect planned contracts | 69 |
| Claude-allowed contracts | 69 |
| Claude context status | current |
| Claude Design receipt status | missing |

The Badge + Field spike is awaiting-figma-file-approval. Code Connect is
blocked-plan-tier; the live gate remains red until the Figma
publish snapshot, plan tier, and generated mappings satisfy the prerequisites.

## Remaining owner/live gate queue

- `design-sync/CLAUDE1`: Can the generated Badge + Field handoff request be run through Claude Design and its exact JSON receipt returned? Recommended: Give Claude Design the committed design_context_pack, require the supplied receipt contract verbatim, and commit only a receipt whose source and supported-state digests pass the gate.
- `design-sync/CODECONNECT1`: How should the live Code Connect exit gate be resolved on the current Starter plan? Recommended: Upgrade or move the spike to an Organization/Enterprise workspace before claiming published Code Connect; keep repository templates planned until then.
- `design-sync/FIGMA1`: May Codex create the Catch Design System Figma file for the Badge + Field live spike? Recommended: Approve creation of one dedicated design-system file in the verified Suvrat Garg's team workspace.

## Completion audit

| Requirement | Status | Authoritative evidence |
|---|---|---|
| 1. Reconcile the existing decision ledger | proven | 43/43 exact normalized-member-set cluster decisions |
| 2. Prove all four vertical-slice outcomes | proven | Generated per-family deltas plus role-derived Widgetbook evidence cover member, separation, composition/recipe, and decompression cases |
| 3. Resolve owner-gated semantic decisions | proven | 0 unresolved semantic owner question(s) |
| 4. Verify accepted changes and stamp receipts | proven | Focused checks and audit receipt widget-concept-owner-decisions-2026-07-19 are recorded |
| 5. Give every cataloged entry exactly one governed role | proven | 0 unclassified contracts and 0 unclassified production entries |
| 6. Report concept and class counts separately | proven | 63 concepts, 196 contracted public classes, 1094 production widget/state classes |
| 7. Complete live Figma/Claude Badge + Field round trip | pending | awaiting-figma-file-approval; Code Connect blocked-plan-tier; Claude context current; Claude Design receipt missing |
| 8. Reduce remaining work to a bounded queue | proven | 3 generated owner/live gates and 55 advisory ranked-pair candidates |

The proposal is not complete while any row is `pending`. The local semantic
implementation and the live, published Badge + Field evidence are independent
proof obligations.

## Reproduce

```sh
node tool/design/check_component_contracts.mjs
node --test tool/design/component_concepts.test.mjs
node tool/design/generate_widget_classification.mjs
node tool/design/check_widget_classification.mjs
node tool/design/build_widget_similarity.mjs --check
node tool/design/import_figma_library_snapshot.mjs --check
node tool/design/build_design_sync_manifest.mjs --check
node tool/design/build_context_pack.mjs --check
node tool/design/check_widget_pattern_families.mjs --check
node tool/design/check_widgetbook_coverage.mjs --check
node tool/design/check_widget_dedupe_probes.mjs
```
