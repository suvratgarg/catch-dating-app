---
doc_id: widget_concept_report
version: 1.0.0
updated: 2026-07-18
owner: widget_consolidation
status: generated
generated_by: tool/design/build_widget_concept_report.mjs
---

# Widget concept system report

This report is generated from the component contract, production widget
classification, similarity registry, decision ledger reconciliation, and
design-sync manifest. Do not edit it by hand.

## Outcome

| Measure | Before | Current | Interpretation |
|---|---:|---:|---|
| Top-level contract entries | 64 | 65 | Contracts may remain useful without claiming concept identity. |
| Independent concepts | 64 proxy | 60 | 4 fewer than the old top-level proxy (6.25%); pending loading review may raise this accurately. |
| Contracted public widget classes | — | 194 | Primaries and members are counted separately from concepts. |
| Member APIs | — | 118 | Variants, anatomy, adapters, recipes, and layouts retain public seams without inflating concepts. |
| Unclassified contracted entries | — | 0 | Must remain zero. |
| Production widget/state classes | — | 1094 | Exhaustive generated inventory. |
| Instantiated concept primaries | — | 59 | One contracted primary is not a runtime Widget declaration. |
| Public member widget classes | — | 116 | Role is inherited from the component contract. |
| Public composition widget classes | — | 517 | Excluded from the concept count. |
| Public screen widget classes | — | 269 | Excluded from the concept count. |
| Unclassified public widgets | — | 0 | Must remain zero. |
| Widgetbook-covered concept primaries | — | 59/59 | Primary concept coverage is role-derived. |
| Widgetbook-covered member classes | — | 116/116 | Missing member previews remain visible without creating concepts. |

## Collision and ledger coverage

| Measure | Current |
|---|---:|
| Derived contracted collision groups | 31 |
| Production collision groups | 31 |
| Structural similarity clusters | 45 |
| Clusters with exact normalized-member-set decisions | 30 |
| Unresolved clusters | 15 |
| Ranked pairs covered by a ledger decision | 145 |
| Unresolved ranked pairs | 55 |
| Ledger decisions indexed | 296 |

Similarity is discovery evidence only. A collision or unresolved pair is a
candidate for review, never permission to merge.

## Four-outcome calibration

| Family | Classification | Result |
|---|---|---|
| Error and person rows | one concept, multiple members | Placement and layout APIs remain public while sharing one concept id. |
| CatchMetaRow vs StageSectionLabel | concept vs feature composition | Metadata and structural hierarchy remain separate despite visual similarity. |
| NotificationRow and CatchPrivacyBadge | composition and recipe member | Notification behavior composes CatchField; privacy semantics compose CatchBadge.privacy. |
| Loading | review | Owner review is required before decompression is finalized. |

## Design-tool readiness

| Measure | Current |
|---|---:|
| Figma mapped contracts | 0 |
| Figma unmapped contracts | 65 |
| Code Connect mapped contracts | 0 |
| Code Connect planned contracts | 65 |
| Claude-allowed contracts | 65 |

The Badge + Field spike is awaiting-figma-file-approval. Code Connect is
blocked-plan-tier; the live gate deliberately remains red until
the plan tier and node-specific mappings satisfy the published prerequisites.

## Reproduce

```sh
node tool/design/check_component_contracts.mjs
node --test tool/design/component_concepts.test.mjs
node tool/design/generate_widget_classification.mjs
node tool/design/check_widget_classification.mjs
node tool/design/build_widget_similarity.mjs --check
node tool/design/build_design_sync_manifest.mjs --check
node tool/design/build_context_pack.mjs --check
node tool/design/check_widget_pattern_families.mjs --check
```
