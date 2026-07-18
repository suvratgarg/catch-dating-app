#!/usr/bin/env node
import fs from "node:fs";
import path from "node:path";
import {fromRepo, relativeToRepo} from "../lib/repo_paths.mjs";

const outputPath = fromRepo("docs/audit_registry/widget_concept_report.md");
const check = process.argv.includes("--check");
const components = read("design/components/catch.components.json");
const classification = read("docs/audit_registry/widget_classification.json");
const similarity = read("docs/audit_registry/widget_similarity.json");
const sync = read("design/sync/catch.design-sync.json");
const patterns = read("docs/design_parity/widget_consolidation/pattern_families.json");
const baselineTopLevelCount = 64;
const conceptCount = sync.metrics.conceptCount;
const reduction = baselineTopLevelCount - conceptCount;
const reductionPercent = ((reduction / baselineTopLevelCount) * 100).toFixed(2);
const loading = patterns.families.find((family) => family.id === "loading-concept-decompression");

const report = `---
doc_id: widget_concept_report
version: 1.0.0
updated: ${sync.updated}
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
| Top-level contract entries | ${baselineTopLevelCount} | ${components.components.length} | Contracts may remain useful without claiming concept identity. |
| Independent concepts | ${baselineTopLevelCount} proxy | ${conceptCount} | ${reduction} fewer than the old top-level proxy (${reductionPercent}%); pending loading review may raise this accurately. |
| Contracted public widget classes | — | ${sync.metrics.publicClassCount} | Primaries and members are counted separately from concepts. |
| Member APIs | — | ${sync.metrics.memberCount} | Variants, anatomy, adapters, recipes, and layouts retain public seams without inflating concepts. |
| Unclassified contracted entries | — | ${sync.metrics.unclassifiedCount} | Must remain zero. |
| Production widget/state classes | — | ${classification.summary.total} | Exhaustive generated inventory. |
| Instantiated concept primaries | — | ${classification.summary.conceptCount} | One contracted primary is not a runtime Widget declaration. |
| Public member widget classes | — | ${classification.summary.memberClassCount} | Role is inherited from the component contract. |
| Public composition widget classes | — | ${classification.summary.compositionClassCount} | Excluded from the concept count. |
| Public screen widget classes | — | ${classification.summary.screenClassCount} | Excluded from the concept count. |
| Unclassified public widgets | — | ${classification.summary.unclassifiedCount} | Must remain zero. |
| Widgetbook-covered concept primaries | — | ${classification.summary.widgetbookCoverage.conceptPrimariesCataloged}/${classification.summary.widgetbookCoverage.conceptPrimaries} | Primary concept coverage is role-derived. |
| Widgetbook-covered member classes | — | ${classification.summary.widgetbookCoverage.memberClassesCataloged}/${classification.summary.widgetbookCoverage.memberClasses} | Missing member previews remain visible without creating concepts. |

## Collision and ledger coverage

| Measure | Current |
|---|---:|
| Derived contracted collision groups | ${sync.metrics.collisionCount} |
| Production collision groups | ${classification.summary.collisionGroupCount} |
| Structural similarity clusters | ${similarity.summary.clusters} |
| Clusters with exact normalized-member-set decisions | ${similarity.summary.exactClusterDecisionCoverage} |
| Unresolved clusters | ${similarity.summary.unresolvedClusters} |
| Ranked pairs covered by a ledger decision | ${similarity.summary.rankedPairDecisionCoverage} |
| Unresolved ranked pairs | ${similarity.summary.unresolvedRankedPairs} |
| Ledger decisions indexed | ${similarity.summary.ledgerDecisions} |

Similarity is discovery evidence only. A collision or unresolved pair is a
candidate for review, never permission to merge.

## Four-outcome calibration

| Family | Classification | Result |
|---|---|---|
| Error and person rows | one concept, multiple members | Placement and layout APIs remain public while sharing one concept id. |
| CatchMetaRow vs StageSectionLabel | concept vs feature composition | Metadata and structural hierarchy remain separate despite visual similarity. |
| NotificationRow and CatchPrivacyBadge | composition and recipe member | Notification behavior composes CatchField; privacy semantics compose CatchBadge.privacy. |
| Loading | ${loading?.status ?? "missing"} | Owner review is required before decompression is finalized. |

## Design-tool readiness

| Measure | Current |
|---|---:|
| Figma mapped contracts | ${sync.metrics.figmaMappingStates.mapped ?? 0} |
| Figma unmapped contracts | ${sync.metrics.figmaMappingStates.unmapped ?? 0} |
| Code Connect mapped contracts | ${sync.metrics.codeConnectMappingStates.mapped ?? 0} |
| Code Connect planned contracts | ${sync.metrics.codeConnectMappingStates.planned ?? 0} |
| Claude-allowed contracts | ${sync.metrics.claudeAllowed} |

The Badge + Field spike is ${sync.spike.status}. Code Connect is
${sync.spike.codeConnectStatus}; the live gate deliberately remains red until
the plan tier and node-specific mappings satisfy the published prerequisites.

## Reproduce

\`\`\`sh
node tool/design/check_component_contracts.mjs
node --test tool/design/component_concepts.test.mjs
node tool/design/generate_widget_classification.mjs
node tool/design/check_widget_classification.mjs
node tool/design/build_widget_similarity.mjs --check
node tool/design/build_design_sync_manifest.mjs --check
node tool/design/build_context_pack.mjs --check
node tool/design/check_widget_pattern_families.mjs --check
\`\`\`
`;

if (check) {
  if (!fs.existsSync(outputPath) || fs.readFileSync(outputPath, "utf8") !== report) {
    console.error(`${relativeToRepo(outputPath)} is stale; run node tool/design/build_widget_concept_report.mjs`);
    process.exit(1);
  }
  console.log("Widget concept report check passed.");
} else {
  fs.mkdirSync(path.dirname(outputPath), {recursive: true});
  fs.writeFileSync(outputPath, report);
  console.log(`Wrote ${relativeToRepo(outputPath)}.`);
}

function read(relativePath) {
  return JSON.parse(fs.readFileSync(fromRepo(relativePath), "utf8"));
}
