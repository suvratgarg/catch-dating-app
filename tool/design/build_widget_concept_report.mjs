#!/usr/bin/env node
import fs from "node:fs";
import path from "node:path";
import {fromRepo, relativeToRepo} from "../lib/repo_paths.mjs";

const outputPath = fromRepo("docs/audit_registry/widget_concept_report.md");
const metricsPath = fromRepo("docs/audit_registry/widget_concept_metrics.json");
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
const ownerReviewQueue = buildOwnerReviewQueue(patterns.families);
const familyDeltas = buildFamilyDeltas();
const widgetbookCoverage = classification.summary.widgetbookCoverage;

const metricsDocument = {
  version: 1,
  updated: sync.updated,
  sourceOfTruth: {
    componentContracts: "design/components/catch.components.json",
    classification: "docs/audit_registry/widget_classification.json",
    similarity: "docs/audit_registry/widget_similarity.json",
    patternFamilies: "docs/design_parity/widget_consolidation/pattern_families.json",
    designSync: "design/sync/catch.design-sync.json",
    generator: "tool/design/build_widget_concept_report.mjs",
  },
  totals: {
    baselineTopLevelConceptProxy: baselineTopLevelCount,
    topLevelContracts: components.components.length,
    concepts: conceptCount,
    conceptDelta: conceptCount - baselineTopLevelCount,
    publicContractClasses: sync.metrics.publicClassCount,
    productionWidgetAndStateClasses: classification.summary.total,
    members: sync.metrics.memberCount,
    membersPerConcept: sync.metrics.membersPerConcept,
    unclassifiedContractEntries: sync.metrics.unclassifiedCount,
    unclassifiedProductionEntries: classification.summary.unclassifiedCount,
    unresolvedCollisionFamilies: similarity.summary.unresolvedClusters,
    ownerReviewQueueSize: ownerReviewQueue.length,
  },
  ledgerCoverage: {
    normalizedMemberSetCoveredClusters: similarity.summary.exactClusterDecisionCoverage,
    totalClusters: similarity.summary.clusters,
    unresolvedClusters: similarity.summary.unresolvedClusters,
    rankedPairsCovered: similarity.summary.rankedPairDecisionCoverage,
    totalRankedPairs: similarity.summary.rankedPairs,
    unresolvedRankedPairs: similarity.summary.unresolvedRankedPairs,
    decisionsIndexed: similarity.summary.ledgerDecisions,
  },
  widgetbookEvidence: {
    completeConcepts: widgetbookCoverage.conceptPrimariesCataloged,
    totalInstantiatedConcepts: widgetbookCoverage.conceptPrimaries,
    coveredMembers: widgetbookCoverage.memberClassesCataloged,
    totalMembers: widgetbookCoverage.memberClasses,
  },
  figmaMappings: {
    current: sync.metrics.figmaMappingStates.current ?? 0,
    stale: sync.metrics.figmaMappingStates.stale ?? 0,
    missing: sync.metrics.figmaMappingStates.missing ?? 0,
    propertyDrift: sync.metrics.figmaPropertyDriftCount,
  },
  claudeContext: sync.claudeContext,
  familyDeltas,
  ownerReviewQueue,
};

const report = `---
doc_id: widget_concept_report
version: 2.0.0
updated: ${sync.updated}
owner: widget_consolidation
status: generated
generated_by: tool/design/build_widget_concept_report.mjs
---

# Widget concept system report

This report is generated from the component contract, production widget
classification, similarity registry, decision ledger reconciliation, and
design-sync manifest. Do not edit it by hand. The machine-readable companion is
\`docs/audit_registry/widget_concept_metrics.json\`.

## Outcome

| Measure | Before | Current | Interpretation |
|---|---:|---:|---|
| Top-level contract entries | ${baselineTopLevelCount} | ${components.components.length} | Contracts may remain useful without claiming concept identity. |
| Independent concepts | ${baselineTopLevelCount} proxy | ${conceptCount} | ${reduction} fewer than the old top-level proxy (${reductionPercent}%); count accuracy, not reduction, is the objective. |
| Contracted public widget classes | — | ${sync.metrics.publicClassCount} | Primaries and members are counted separately from concepts. |
| Member APIs | — | ${sync.metrics.memberCount} (${sync.metrics.membersPerConcept} per concept) | Public seams do not inflate concept count. |
| Unclassified contracted entries | — | ${sync.metrics.unclassifiedCount} | Must remain zero. |
| Production widget/state classes | — | ${classification.summary.total} | Exhaustive generated inventory. |
| Instantiated concept primaries | — | ${classification.summary.conceptCount} | One contracted primary is not a runtime Widget declaration. |
| Public member widget classes | — | ${classification.summary.memberClassCount} | Role is inherited from the component contract. |
| Public composition widget classes | — | ${classification.summary.compositionClassCount} | Excluded from concept count. |
| Public screen widget classes | — | ${classification.summary.screenClassCount} | Excluded from concept count. |
| Unclassified public widgets | — | ${classification.summary.unclassifiedCount} | Must remain zero. |
| Widgetbook-complete concept primaries | — | ${widgetbookCoverage.conceptPrimariesCataloged}/${widgetbookCoverage.conceptPrimaries} | Evidence is role-derived. |
| Widgetbook-covered member classes | — | ${widgetbookCoverage.memberClassesCataloged}/${widgetbookCoverage.memberClasses} | Reviewed directly or under the parent family. |
| Owner-review queue | — | ${ownerReviewQueue.length} | Only unresolved semantic decisions appear here. |

## Collision and ledger coverage

| Measure | Current |
|---|---:|
| Derived contracted collision groups | ${sync.metrics.collisionCount} |
| Production collision groups | ${classification.summary.collisionGroupCount} |
| Structural similarity clusters | ${similarity.summary.clusters} |
| Clusters with exact normalized-member-set decisions | ${similarity.summary.exactClusterDecisionCoverage}/${similarity.summary.clusters} |
| Unresolved collision families | ${similarity.summary.unresolvedClusters} |
| Ranked pairs covered by a ledger decision | ${similarity.summary.rankedPairDecisionCoverage}/${similarity.summary.rankedPairs} |
| Unresolved ranked pairs | ${similarity.summary.unresolvedRankedPairs} |
| Ledger decisions indexed | ${similarity.summary.ledgerDecisions} |

Similarity is discovery evidence only. A collision or unresolved pair is a
candidate for review, never permission to merge.

## Per-family concept and class deltas

| Family | Concepts before | Concepts current | Concept delta | Proposed concepts | Public classes before | Public classes current | Class delta |
|---|---:|---:|---:|---:|---:|---:|---:|
${familyDeltas.map((family) => `| ${family.family} | ${family.baselineConcepts} | ${family.currentConcepts} | ${signed(family.conceptDelta)} | ${family.proposedConcepts ?? "—"} | ${family.baselineClasses} | ${family.currentClasses} | ${signed(family.classDelta)} |`).join("\n")}

Concept identity and Dart class count are deliberately independent. The
accepted changes are classification-only, so no family claims class deletion
as an architectural improvement.

## Four-outcome calibration

| Family | Classification | Result |
|---|---|---|
| Error and person rows | one concept, multiple members | Placement and layout APIs remain public while sharing one concept id. |
| CatchMetaRow vs StageSectionLabel | concept vs feature composition | Metadata and structural hierarchy remain separate despite visual similarity. |
| NotificationRow and CatchPrivacyBadge | composition and recipe member | Notification composes CatchField; privacy composes CatchBadge.privacy. |
| Loading | ${loading?.status ?? "missing"} | Owner review is required before decompression is finalized. |

## Design-tool readiness

| Measure | Current |
|---|---:|
| Figma current mappings | ${sync.metrics.figmaMappingStates.current ?? 0} |
| Figma stale mappings | ${sync.metrics.figmaMappingStates.stale ?? 0} |
| Figma missing mappings | ${sync.metrics.figmaMappingStates.missing ?? 0} |
| Figma property drift findings | ${sync.metrics.figmaPropertyDriftCount} |
| Figma review snapshots | ${sync.figmaSnapshot.reviewSnapshotCount} |
| Code Connect mapped contracts | ${sync.metrics.codeConnectMappingStates.mapped ?? 0} |
| Code Connect planned contracts | ${sync.metrics.codeConnectMappingStates.planned ?? 0} |
| Claude-allowed contracts | ${sync.metrics.claudeAllowed} |
| Claude context status | ${sync.claudeContext.status} |

The Badge + Field spike is ${sync.spike.status}. Code Connect is
${sync.spike.codeConnectStatus}; the live gate remains red until the Figma
publish snapshot, plan tier, and generated mappings satisfy the prerequisites.

## Owner review queue

${ownerReviewQueue.length === 0
    ? "No owner decisions remain."
    : ownerReviewQueue.map((item) => `- \`${item.familyId}/${item.questionId}\`: ${item.prompt} Recommended: ${item.recommendation}`).join("\n")}

## Reproduce

\`\`\`sh
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
\`\`\`
`;

if (check) {
  const failures = [];
  if (!fs.existsSync(outputPath) || fs.readFileSync(outputPath, "utf8") !== report) {
    failures.push(`${relativeToRepo(outputPath)} is stale`);
  }
  const expectedMetrics = `${JSON.stringify(metricsDocument, null, 2)}\n`;
  if (!fs.existsSync(metricsPath) || fs.readFileSync(metricsPath, "utf8") !== expectedMetrics) {
    failures.push(`${relativeToRepo(metricsPath)} is stale`);
  }
  if (failures.length > 0) {
    console.error(`${failures.join("\n")}; run node tool/design/build_widget_concept_report.mjs`);
    process.exit(1);
  }
  console.log("Widget concept report and metrics check passed.");
} else {
  fs.mkdirSync(path.dirname(outputPath), {recursive: true});
  fs.writeFileSync(outputPath, report);
  fs.writeFileSync(metricsPath, `${JSON.stringify(metricsDocument, null, 2)}\n`);
  console.log(`Wrote ${relativeToRepo(outputPath)} and ${relativeToRepo(metricsPath)}.`);
}

function buildOwnerReviewQueue(families) {
  const familyQuestions = families.flatMap((family) => (family.reviewQuestions ?? [])
    .filter((question) => !question.selectedOption)
    .map((question) => ({
      familyId: family.id,
      familyStatus: family.status,
      questionId: question.id,
      prompt: question.prompt,
      recommendation: question.recommendation,
      options: question.options,
    })));
  const designSyncQuestions = [];
  if (!sync.capabilities.figma.fileKey) {
    designSyncQuestions.push({
      familyId: "design-sync",
      familyStatus: sync.spike.status,
      questionId: "FIGMA1",
      prompt: "May Codex create the Catch Design System Figma file for the Badge + Field live spike?",
      recommendation: "Approve creation of one dedicated design-system file in the verified Suvrat Garg's team workspace.",
      options: [
        "Approve creation of the dedicated Catch Design System file.",
        "Provide an existing editable Figma design-system file URL instead.",
      ],
    });
  }
  if (sync.capabilities.codeConnect.status !== "available") {
    designSyncQuestions.push({
      familyId: "design-sync",
      familyStatus: sync.capabilities.codeConnect.status,
      questionId: "CODECONNECT1",
      prompt: "How should the live Code Connect exit gate be resolved on the current Starter plan?",
      recommendation: "Upgrade or move the spike to an Organization/Enterprise workspace before claiming published Code Connect; keep repository templates planned until then.",
      options: [
        "Use an Organization or Enterprise workspace for the published spike.",
        "Formally revise the exit gate to stop at generated local mappings on Starter.",
      ],
    });
  }
  return [...familyQuestions, ...designSyncQuestions]
    .sort((a, b) => a.familyId.localeCompare(b.familyId) || a.questionId.localeCompare(b.questionId));
}

function buildFamilyDeltas() {
  const definitions = [
    family("error-state", "Error state", ["catch.error_state"], ["CatchErrorBody", "CatchErrorIcon", "CatchErrorScaffold", "CatchErrorState", "CatchFrameworkErrorDebugDetails", "CatchFrameworkErrorView", "CatchInlineErrorState", "CatchSliverErrorState"], 1, 8),
    family("person-row", "Person row", ["catch.person_row"], ["CatchPersonChatLayout", "CatchPersonChatTrailing", "CatchPersonNewMatchDot", "CatchPersonRosterLayout", "CatchPersonRow", "CatchPersonUnreadCountPill"], 1, 6),
    family("meta-vs-stage", "Meta row vs stage label", ["catch.meta_row"], ["CatchMetaRow", "StageSectionLabel"], 0, 2),
    family("notification-privacy", "Notification + privacy", ["catch.badge", "catch.privacy_badge", "catch.field", "catch.notification_row"], ["CatchBadge", "CatchPrivacyBadge", "CatchField", "NotificationRow"], 4, 4),
    family("option-group-tab-rail", "Option group + tab rail", ["catch.option_group", "catch.tab_rail"], ["CatchOptionGroup", "CatchTabRail"], 2, 2),
    family("club-dock", "Club dock", ["catch.club_dock"], ["ClubDetailDock"], 1, 1),
    family("event-detail-screen", "Event detail screen body", ["catch.event_detail_sections"], ["EventDetailBody"], 1, 1),
    {...family("loading", "Loading", ["catch.loading"], ["CatchAsyncScreenLoading", "CatchAsyncSliverLoading", "CatchAsyncValueSliver", "CatchAsyncValueView", "CatchLoadingIndicator", "CatchSkeleton", "CatchSkeletonList", "CatchStartupLoadingScreen"], 1, 8), proposedConcepts: 3},
  ];
  const liveNames = new Set(classification.widgets.map((entry) => entry.name));
  const componentsById = new Map(components.components.map((component) => [component.id, component]));
  return definitions.map((definition) => {
    const currentConceptIds = new Set(definition.contractIds
      .map((id) => componentsById.get(id))
      .filter(Boolean)
      .filter((component) => ["concept", "member"].includes(component.governance?.conceptRole))
      .map((component) => component.governance.conceptId));
    const currentConcepts = currentConceptIds.size;
    const currentClasses = definition.classSymbols.filter((symbol) => liveNames.has(symbol)).length;
    return {
      ...definition,
      currentConcepts,
      conceptDelta: currentConcepts - definition.baselineConcepts,
      proposedConcepts: definition.proposedConcepts ?? null,
      proposedConceptDelta: definition.proposedConcepts === undefined
        ? null
        : definition.proposedConcepts - currentConcepts,
      currentClasses,
      classDelta: currentClasses - definition.baselineClasses,
    };
  });
}

function family(id, name, contractIds, classSymbols, baselineConcepts, baselineClasses) {
  return {id, family: name, contractIds, classSymbols, baselineConcepts, baselineClasses};
}

function signed(value) {
  return value > 0 ? `+${value}` : String(value);
}

function read(relativePath) {
  return JSON.parse(fs.readFileSync(fromRepo(relativePath), "utf8"));
}
