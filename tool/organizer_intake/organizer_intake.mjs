#!/usr/bin/env node
import crypto from "node:crypto";
import fs from "node:fs";
import path from "node:path";
import {fileURLToPath} from "node:url";
import {normalizeOrganizerSurfaceUrl} from "./lib/platform_adapters.mjs";
import {buildOrganizerPolicyGapRegister} from "./lib/policy_gap_core.mjs";
import {buildOrganizerPolicyDecisionPackets} from
  "./lib/policy_decision_packet_core.mjs";
import {buildEventCrawlRunPlan} from
  "./lib/event_crawl_run_plan_core.mjs";
import {buildRawArtifactStorageManifest} from
  "./lib/raw_artifact_storage_core.mjs";
import {buildCanonicalHostEntityRegistry} from
  "./lib/canonical_host_entity_core.mjs";
import {buildCanonicalEvidenceIndex} from
  "./lib/canonical_evidence_index_core.mjs";
import {buildPublicationReviewPackets} from
  "./lib/publication_review_packet_core.mjs";
import {buildClaimTargetSyncPreview} from
  "./lib/claim_target_sync_core.mjs";
import {buildOrganizerOperatorActionQueue} from
  "./lib/operator_action_queue_core.mjs";
import {buildOrganizerOperationalHealthReport} from
  "./lib/operational_health_core.mjs";
import {buildOrganizerPendingInputRequest} from
  "./lib/pending_input_request_core.mjs";
import {buildOrganizerPendingWorkCoverage} from
  "./lib/pending_work_coverage_core.mjs";
import {buildOrganizerPendingDecisionAnswerPacket} from
  "./lib/pending_decision_answer_packet_core.mjs";
import {buildOrganizerPromotionExecutionPacket} from
  "./lib/promotion_execution_packet_core.mjs";
import {buildSourceMentionResolution} from
  "./lib/source_mention_resolution_core.mjs";
import {buildPromptQueue as buildSourceMentionLlmPromptQueue} from
  "./llm_source_resolution.mjs";
import {buildReviewedDecisionAnswerPacketRegister} from
  "./reviewed_decision_answer_packets.mjs";

const scriptDir = path.dirname(fileURLToPath(import.meta.url));
const intakeRoot = scriptDir;
const repoRoot = path.resolve(intakeRoot, "..", "..");
const args = parseArgs(process.argv.slice(2));
if (args.help) {
  printHelp();
  process.exit(0);
}

const batchesRoot = path.resolve(args.batchesRoot ?? path.join(intakeRoot, "batches"));
const curationDecisionsRoot = path.resolve(
  args.curationDecisionsRoot ?? path.join(intakeRoot, "curation_decisions")
);
const reviewDecisionsRoot = path.resolve(
  args.reviewDecisionsRoot ?? path.join(intakeRoot, "review_decisions")
);
const policyGapDecisionsRoot = path.resolve(
  args.policyGapDecisionsRoot ?? path.join(intakeRoot, "policy_gap_decisions")
);
const answerPacketsRoot = path.resolve(
  args.answerPacketsRoot ?? path.join(intakeRoot, "answer_packets")
);
const rawArtifactsRoot = path.resolve(
  args.rawArtifactsRoot ?? path.join(intakeRoot, "raw_artifacts")
);
const generatedRoot = path.resolve(args.generatedRoot ?? path.join(intakeRoot, "generated"));
const adminGeneratedRoot = path.resolve(
  args.adminGeneratedRoot ??
    path.join(repoRoot, "admin", "src", "features", "intake", "organizer", "generated")
);
const hostDiscoverySearchPlanPath = path.resolve(
  args.hostDiscoverySearchPlan ??
    path.join(repoRoot, "tool", "host_discovery", "generated", "search_plan.json")
);
const searchResultCandidateQueuePath = path.join(generatedRoot, "search_result_candidate_queue.json");
const externalEventCandidateQueuePath = path.join(generatedRoot, "external_event_candidate_queue.json");
const externalEventLocationResolutionQueuePath = path.join(
  generatedRoot,
  "external_event_location_resolution_queue.json"
);
const externalEventImportPlanPath = path.join(generatedRoot, "external_event_import_plan.json");
const externalEventImportExecutionPlanPath = path.join(
  generatedRoot,
  "external_event_import_execution_plan.json"
);
const checkMode = args.check;

const allowedEntityKinds = new Set([
  "brand",
  "clubCommunity",
  "creatorCommunity",
  "eventOrganizer",
  "individual",
  "venue",
]);
const allowedReviewStatuses = new Set([
  "candidate",
  "needs_admin_review",
  "needs_more_evidence",
  "approved_public",
  "published",
  "claimed",
  "suppressed",
]);
const allowedRelationshipStates = new Set([
  "unclaimed",
  "claimPending",
  "claimed",
  "internalOnly",
]);
const allowedSurfacePlatforms = new Set([
  "bookMyShow",
  "district",
  "instagram",
  "linkedin",
  "luma",
  "news",
  "officialWebsite",
  "partiful",
  "sortMyScene",
  "userReport",
  "other",
]);
const allowedSurfaceKinds = new Set([
  "eventListing",
  "eventCalendar",
  "organizerProfile",
  "personProfile",
  "press",
  "socialProfile",
  "website",
  "wrongEntity",
]);
const allowedSurfaceRoles = new Set([
  "primary",
  "secondary",
  "backup",
  "historical",
  "ambiguous",
  "rejected",
]);
const allowedSurfaceStatuses = new Set([
  "active",
  "candidate",
  "ambiguous",
  "historical",
  "rejected",
]);
const allowedConfidence = new Set(["low", "medium", "high"]);
const allowedGeoScopes = new Set(["city", "multiCity", "national", "global", "remote"]);
const allowedCrawlStatuses = new Set(["disabled", "candidate", "approved", "paused"]);
const allowedCrawlPolicies = new Set(["manualOnly", "blocked", "apiPreferred"]);

const errors = [];
const warnings = [];
const batches = loadBatches();
const curationDecisionBatches = loadCurationDecisionBatches();
const reviewDecisionBatches = loadReviewDecisionBatches();
const policyGapDecisionBatches = loadPolicyGapDecisionBatches();
const entities = batches.flatMap((batch) =>
  (batch.entities ?? []).map((entity) => ({
    ...entity,
    batchId: batch.batchId,
    batchCreatedAt: batch.createdAt,
    batchFile: batch.file,
    promotionPolicy: batch.promotionPolicy,
  }))
);

validateBatches(batches);
validateEntities(entities);
validateCurationDecisions(curationDecisionBatches, entities);

const curationState = buildCurationState(curationDecisionBatches, entities);
const effectiveEntities = applyCurationState(entities, curationState);
validateReviewDecisions(reviewDecisionBatches, effectiveEntities);

const dedupeIndex = buildDedupeIndex(effectiveEntities, curationState);
validateDedupeConflicts(dedupeIndex);
const reviewDecisions = latestReviewDecisions(reviewDecisionBatches);
const reviewQueue = buildReviewQueue(effectiveEntities, dedupeIndex, reviewDecisions, curationState);
const projectionPlan = buildProjectionPlan(effectiveEntities, reviewQueue, reviewDecisions);
const claimTargetPlan = buildClaimTargetPlan(effectiveEntities, projectionPlan);
const claimTargetSyncPreview = buildClaimTargetSyncPreview({
  claimTargetPlan,
  existingDocs: new Map(),
  existingDocsSource:
    "tool/organizer_intake/fixtures/existing_club_docs.empty.json",
});
const canonicalHostEntities = buildCanonicalHostEntityRegistry({
  claimTargetPlan,
  curationState,
  dedupeIndex,
  entityList: effectiveEntities,
  projectionPlan,
  reviewQueue,
});
const eventCrawlPlan = buildEventCrawlPlan(effectiveEntities, curationState);
const eventCrawlRunPlan = buildEventCrawlRunPlan({eventCrawlPlan});
const searchResultCandidateQueue = loadSearchResultCandidateQueue();
const discoverySearchPlan = buildDiscoverySearchPlan({
  launchCitySlugs: ["indore", "mumbai"],
  searchPlan: loadHostDiscoverySearchPlan(),
});
const externalEventCandidateQueue = loadExternalEventCandidateQueue();
const sourceMentionResolution = buildSourceMentionResolution({
  externalEventCandidateQueue,
  searchResultCandidateQueue,
});
const sourceMentionLlmPromptQueue = buildSourceMentionLlmPromptQueue({
  candidates: sourceMentionResolution.resolutionCandidates,
  clusters: sourceMentionResolution.resolutionClusters,
});
const externalEventLocationResolutionQueue =
  loadExternalEventLocationResolutionQueue();
const externalEventImportPlan = loadExternalEventImportPlan();
const externalEventImportExecutionPlan = loadExternalEventImportExecutionPlan();
const rawArtifactStorageManifest = buildRawArtifactStorageManifest({
  artifactFiles: collectRawArtifactFiles(),
});
const canonicalEvidenceIndex = buildCanonicalEvidenceIndex({
  canonicalHostEntities,
  curationState,
  externalEventCandidateQueue,
  rawArtifactStorageManifest,
  referencedArtifactFiles: collectEvidenceReferenceFiles(canonicalHostEntities),
  reviewQueue,
  searchResultCandidateQueue,
});
const publicationReviewPackets = buildPublicationReviewPackets({
  canonicalEvidenceIndex,
  canonicalHostEntities,
  claimTargetPlan,
  entityList: effectiveEntities,
  projectionPlan,
  reviewQueue,
});
validateApprovedReviewDecisionsAgainstPublicationReadiness({
  curationState,
  dedupeIndex,
  entityList: effectiveEntities,
  externalEventCandidateQueue,
  rawArtifactStorageManifest,
  reviewDecisions,
  searchResultCandidateQueue,
});
const publicationDecisionImpactPreview = buildPublicationDecisionImpactPreview({
  entityList: effectiveEntities,
  publicationReviewPackets,
  reviewDecisions,
  reviewQueue,
});
const policyGapRegister = buildOrganizerPolicyGapRegister({
  eventCrawlPlan,
  externalEventCandidateQueue,
  externalEventLocationResolutionQueue,
  externalEventImportExecutionPlan,
  externalEventImportPlan,
  policyGapDecisionBatches,
  sourceMentionResolution,
});
for (const error of policyGapRegister.errors ?? []) {
  errors.push(error);
}
const policyDecisionPackets =
  buildOrganizerPolicyDecisionPackets(policyGapRegister);
const workflowReadiness = buildWorkflowReadinessReport({
  claimTargetPlan,
  claimTargetSyncPreview,
  curationState,
  eventCrawlPlan,
  eventCrawlRunPlan,
  externalEventCandidateQueue,
  externalEventLocationResolutionQueue,
  externalEventImportExecutionPlan,
  externalEventImportPlan,
  canonicalHostEntities,
  canonicalEvidenceIndex,
  publicationReviewPackets,
  publicationDecisionImpactPreview,
  policyDecisionPackets,
  projectionPlan,
  rawArtifactStorageManifest,
  reviewQueue,
  searchResultCandidateQueue,
});
const operatorActionQueue = buildOrganizerOperatorActionQueue({
  claimTargetSyncPreview,
  policyDecisionPackets,
  publicationDecisionImpactPreview,
  publicationReviewPackets,
  workflowReadiness,
});
const operationalHealth = buildOrganizerOperationalHealthReport({
  canonicalEvidenceIndex,
  canonicalHostEntities,
  claimTargetSyncPreview,
  eventCrawlPlan,
  eventCrawlRunPlan,
  externalEventCandidateQueue,
  externalEventImportExecutionPlan,
  externalEventImportPlan,
  externalEventLocationResolutionQueue,
  operatorActionQueue,
  policyDecisionPackets,
  policyGapRegister,
  publicationDecisionImpactPreview,
  publicationReviewPackets,
  rawArtifactStorageManifest,
  searchResultCandidateQueue,
  workflowReadiness,
});
const pendingInputRequest = buildOrganizerPendingInputRequest({
  operatorActionQueue,
  operationalHealth,
  policyDecisionPackets,
  publicationReviewPackets,
});
const pendingWorkCoverage = buildOrganizerPendingWorkCoverage({
  operationalHealth,
  pendingInputRequest,
});
const pendingDecisionAnswerPacket =
  buildOrganizerPendingDecisionAnswerPacket({
    pendingInputRequest,
    pendingWorkCoverage,
  });
const reviewedDecisionAnswerPackets =
  buildReviewedDecisionAnswerPacketRegister({
    root: answerPacketsRoot,
  });
const promotionExecutionPacket = buildOrganizerPromotionExecutionPacket({
  claimTargetSyncPreview,
  pendingDecisionAnswerPacket,
  pendingInputRequest,
  pendingWorkCoverage,
  reviewedDecisionAnswerPackets,
  projectionPlan,
  publicationDecisionImpactPreview,
  workflowReadiness,
});
const adminBridge = buildAdminBridge(
  reviewQueue,
  projectionPlan,
  claimTargetPlan,
  claimTargetSyncPreview,
  eventCrawlPlan,
  eventCrawlRunPlan,
  workflowReadiness,
  canonicalHostEntities,
  canonicalEvidenceIndex,
  publicationReviewPackets,
  publicationDecisionImpactPreview,
  operatorActionQueue,
  operationalHealth,
  pendingInputRequest,
  pendingWorkCoverage,
  reviewedDecisionAnswerPackets,
  promotionExecutionPacket,
  policyGapRegister,
  policyDecisionPackets,
  curationState,
  searchResultCandidateQueue,
  externalEventCandidateQueue,
  externalEventLocationResolutionQueue,
  externalEventImportPlan,
  externalEventImportExecutionPlan,
  rawArtifactStorageManifest,
  sourceMentionResolution,
  sourceMentionLlmPromptQueue
);

if (errors.length > 0) {
  console.error("Organizer intake validation failed:");
  for (const error of errors) console.error(`- ${error}`);
  if (warnings.length > 0) {
    console.error("\nWarnings:");
    for (const warning of warnings) console.error(`- ${warning}`);
  }
  process.exit(1);
}

const artifacts = [
  {
    name: "organizer dedupe index",
    path: path.join(generatedRoot, "organizer_dedupe_index.json"),
    data: dedupeIndex,
  },
  {
    name: "organizer curation state",
    path: path.join(generatedRoot, "organizer_curation_state.json"),
    data: curationState,
  },
  {
    name: "admin review queue",
    path: path.join(generatedRoot, "admin_review_queue.json"),
    data: reviewQueue,
  },
  {
    name: "public projection plan",
    path: path.join(generatedRoot, "public_projection_plan.json"),
    data: projectionPlan,
  },
  {
    name: "organizer claim targets",
    path: path.join(generatedRoot, "organizer_claim_targets.json"),
    data: claimTargetPlan,
  },
  {
    name: "organizer claim target sync preview",
    path: path.join(generatedRoot, "organizer_claim_target_sync_preview.json"),
    data: claimTargetSyncPreview,
  },
  {
    name: "canonical host entities",
    path: path.join(generatedRoot, "canonical_host_entities.json"),
    data: canonicalHostEntities,
  },
  {
    name: "canonical evidence index",
    path: path.join(generatedRoot, "canonical_evidence_index.json"),
    data: canonicalEvidenceIndex,
  },
  {
    name: "publication review packets",
    path: path.join(generatedRoot, "publication_review_packets.json"),
    data: publicationReviewPackets,
  },
  {
    name: "publication decision impact preview",
    path: path.join(generatedRoot, "publication_decision_impact_preview.json"),
    data: publicationDecisionImpactPreview,
  },
  {
    name: "source mention resolution policy",
    path: path.join(generatedRoot, "source_mention_resolution_policy.json"),
    data: sourceMentionResolution.resolutionPolicy,
  },
  {
    name: "source mention source artifacts",
    path: path.join(generatedRoot, "source_mention_source_artifacts.json"),
    data: sourceMentionResolution.sourceArtifacts,
  },
  {
    name: "source mention extracted mentions",
    path: path.join(generatedRoot, "source_mention_extracted_mentions.json"),
    data: sourceMentionResolution.extractedMentions,
  },
  {
    name: "source mention resolution candidates",
    path: path.join(generatedRoot, "source_mention_resolution_candidates.json"),
    data: sourceMentionResolution.resolutionCandidates,
  },
  {
    name: "source mention resolution clusters",
    path: path.join(generatedRoot, "source_mention_resolution_clusters.json"),
    data: sourceMentionResolution.resolutionClusters,
  },
  {
    name: "source mention resolution review packets",
    path: path.join(generatedRoot, "source_mention_resolution_review_packets.json"),
    data: sourceMentionResolution.reviewPackets,
  },
  {
    name: "source mention LLM prompt queue",
    path: path.join(generatedRoot, "source_mention_llm_prompt_queue.json"),
    data: sourceMentionLlmPromptQueue,
  },
  {
    name: "event crawl plan",
    path: path.join(generatedRoot, "event_crawl_plan.json"),
    data: eventCrawlPlan,
  },
  {
    name: "event crawl run plan",
    path: path.join(generatedRoot, "event_crawl_run_plan.json"),
    data: eventCrawlRunPlan,
  },
  {
    name: "organizer workflow readiness",
    path: path.join(generatedRoot, "organizer_workflow_readiness.json"),
    data: workflowReadiness,
  },
  {
    name: "organizer operator action queue",
    path: path.join(generatedRoot, "organizer_operator_action_queue.json"),
    data: operatorActionQueue,
  },
  {
    name: "organizer operational health",
    path: path.join(generatedRoot, "organizer_operational_health.json"),
    data: operationalHealth,
  },
  {
    name: "organizer pending input request",
    path: path.join(generatedRoot, "organizer_pending_input_request.json"),
    data: pendingInputRequest,
  },
  {
    name: "organizer pending work coverage",
    path: path.join(generatedRoot, "organizer_pending_work_coverage.json"),
    data: pendingWorkCoverage,
  },
  {
    name: "organizer pending decision answer packet",
    path: path.join(
      generatedRoot,
      "organizer_pending_decision_answer_packet.json"
    ),
    data: pendingDecisionAnswerPacket,
  },
  {
    name: "organizer reviewed decision answer packets",
    path: path.join(
      generatedRoot,
      "organizer_reviewed_decision_answer_packets.json"
    ),
    data: reviewedDecisionAnswerPackets,
  },
  {
    name: "organizer promotion execution packet",
    path: path.join(generatedRoot, "organizer_promotion_execution_packet.json"),
    data: promotionExecutionPacket,
  },
  {
    name: "raw artifact storage manifest",
    path: path.join(generatedRoot, "raw_artifact_storage_manifest.json"),
    data: rawArtifactStorageManifest,
  },
  {
    name: "organizer policy gap register",
    path: path.join(generatedRoot, "organizer_policy_gap_register.json"),
    data: policyGapRegister,
  },
  {
    name: "organizer policy decision packets",
    path: path.join(generatedRoot, "organizer_policy_decision_packets.json"),
    data: policyDecisionPackets,
  },
  {
    name: "admin organizer intake bridge",
    path: path.join(adminGeneratedRoot, "organizerIntakeBridge.json"),
    data: adminBridge,
  },
];

if (checkMode) {
  let stale = false;
  for (const artifact of artifacts) {
    const rendered = `${stableStringify(artifact.data)}\n`;
    if (!fs.existsSync(artifact.path)) {
      console.error(`Missing ${artifact.name}: ${relative(artifact.path)}`);
      stale = true;
      continue;
    }
    const current = fs.readFileSync(artifact.path, "utf8");
    if (current !== rendered) {
      console.error(`${artifact.name} is stale: ${relative(artifact.path)}`);
      stale = true;
    }
  }
  if (stale) {
    console.error("Run: node tool/organizer_intake/organizer_intake.mjs");
    process.exit(1);
  }
} else {
  fs.mkdirSync(generatedRoot, {recursive: true});
  fs.mkdirSync(adminGeneratedRoot, {recursive: true});
  for (const artifact of artifacts) {
    fs.writeFileSync(artifact.path, `${stableStringify(artifact.data)}\n`);
  }
}

console.log(
  `Organizer intake ready: ${entities.length} entities, ` +
    `${curationState.summary.operations} curation operations, ` +
    `${dedupeIndex.dedupeKeys.length} dedupe keys, ` +
    `${reviewQueue.items.length} review items, ` +
    `${projectionPlan.summary.approvedPublic} approved public projections, ` +
    `${claimTargetPlan.summary.targets} claim targets.`
);
if (warnings.length > 0) {
  for (const warning of warnings) console.warn(`Warning: ${warning}`);
}

function loadBatches() {
  const files = fs.existsSync(batchesRoot) ?
    fs.readdirSync(batchesRoot).filter((file) => file.endsWith(".json")).sort() :
    [];
  return files.map((file) => {
    const fullPath = path.join(batchesRoot, file);
    return {
      ...readJson(fullPath),
      file: relative(fullPath),
    };
  });
}

function loadCurationDecisionBatches() {
  if (!fs.existsSync(curationDecisionsRoot)) return [];
  const files = fs
    .readdirSync(curationDecisionsRoot)
    .filter((file) => file.endsWith(".json"))
    .sort();
  return files.map((file) => {
    const fullPath = path.join(curationDecisionsRoot, file);
    return {
      ...readJson(fullPath),
      file: relative(fullPath),
    };
  });
}

function loadReviewDecisionBatches() {
  if (!fs.existsSync(reviewDecisionsRoot)) return [];
  const files = fs
    .readdirSync(reviewDecisionsRoot)
    .filter((file) => file.endsWith(".json"))
    .sort();
  return files.map((file) => {
    const fullPath = path.join(reviewDecisionsRoot, file);
    return {
      ...readJson(fullPath),
      file: relative(fullPath),
    };
  });
}

function loadPolicyGapDecisionBatches() {
  if (!fs.existsSync(policyGapDecisionsRoot)) return [];
  const files = fs
    .readdirSync(policyGapDecisionsRoot)
    .filter((file) => file.endsWith(".json"))
    .sort();
  return files.map((file) => {
    const fullPath = path.join(policyGapDecisionsRoot, file);
    return {
      ...readJson(fullPath),
      file: relative(fullPath),
    };
  });
}

function loadSearchResultCandidateQueue() {
  if (!fs.existsSync(searchResultCandidateQueuePath)) {
    return {
      schemaVersion: 1,
      generatedFrom: {
        batches: [],
        dedupeIndexGeneratedAt: null,
      },
      summary: {
        batches: 0,
        results: 0,
        candidates: 0,
        matchedExistingEntities: 0,
        duplicateNormalizedKeys: 0,
        platforms: {},
      },
      candidates: [],
      duplicateKeys: [],
      warnings: [],
      errors: [],
    };
  }
  return readJson(searchResultCandidateQueuePath);
}

function loadExternalEventCandidateQueue() {
  if (!fs.existsSync(externalEventCandidateQueuePath)) {
    return {
      schemaVersion: 1,
      generatedFrom: {
        batches: [],
        reviewDecisionBatches: [],
      },
      policy: {
        status: "disabled",
        reason:
          "External event import is modeled for review only. No recurring " +
          "crawl or Firestore event write is enabled by this artifact.",
        importWritesEnabled: false,
      },
      summary: {
        batches: 0,
        events: 0,
        candidates: 0,
        platforms: {},
        duplicateEventKeys: 0,
        blocked: 0,
        reviewed: 0,
        approvedForImport: 0,
        held: 0,
        rejected: 0,
      },
      candidates: [],
      duplicateEventKeys: [],
      warnings: [],
      errors: [],
      commands: {
        captureLuma:
          "node tool/organizer_intake/capture_luma_events.mjs " +
          "--entity ENTITY --surface SURFACE --raw-results LUMA_JSON " +
          "--date YYYY-MM-DD",
        ingest: "node tool/organizer_intake/ingest_event_sources.mjs",
      },
    };
  }
  return readJson(externalEventCandidateQueuePath);
}

function loadExternalEventLocationResolutionQueue() {
  if (!fs.existsSync(externalEventLocationResolutionQueuePath)) {
    return {
      schemaVersion: 1,
      generatedFrom: {
        externalEventCandidateQueue:
          "tool/organizer_intake/generated/external_event_candidate_queue.json",
        batches: [],
        reviewDecisionBatches: [],
      },
      policy: {
        status: "disabled",
        providerLookupEnabled: false,
        provider: "googlePlaces",
        reason:
          "External event location resolution is queue-only. No Places API " +
          "or geocoding provider is enabled.",
      },
      summary: {
        candidates: 0,
        tasks: 0,
        missingExactCoordinates: 0,
        missingLocationText: 0,
        providerDisabled: 0,
        tasksByPlatform: {},
        tasksByCountry: {},
      },
      guardrails: [
        "location_resolution_queue_never_calls_external_providers",
        "exact_coordinates_required_before_event_import_write",
      ],
      tasks: [],
      commands: {
        ingest: "node tool/organizer_intake/ingest_event_sources.mjs",
        planLocations:
          "node tool/organizer_intake/plan_event_location_resolution.mjs",
        planImports:
          "node tool/organizer_intake/plan_external_event_imports.mjs",
      },
    };
  }
  return readJson(externalEventLocationResolutionQueuePath);
}

function loadExternalEventImportPlan() {
  if (!fs.existsSync(externalEventImportPlanPath)) {
    return {
      schemaVersion: 1,
      generatedFrom: {
        externalEventCandidateQueue:
          "tool/organizer_intake/generated/external_event_candidate_queue.json",
        batches: [],
        reviewDecisionBatches: [],
      },
      policy: {
        status: "disabled",
        writeEnabled: false,
        reason:
          "External event import is planned for review only. No Firestore " +
          "event write is enabled by this artifact.",
      },
      summary: {
        candidates: 0,
        proposedReadOnlyEvents: 0,
        proposedCreates: 0,
        mergedSourceLinks: 0,
        writeReady: 0,
        blocked: 0,
        waitingReview: 0,
        rejected: 0,
        duplicateEventKeys: 0,
        actionsByStatus: {},
        actionsByPlatform: {},
      },
      guardrails: [
        "event_import_writes_disabled_by_default",
        "approved_event_candidates_project_to_read_only_external_events",
        "catch_booking_payments_reservations_and_waitlists_remain_disabled",
      ],
      actions: [],
      commands: {
        ingest: "node tool/organizer_intake/ingest_event_sources.mjs",
        plan: "node tool/organizer_intake/plan_external_event_imports.mjs",
        exportReviewDecisions:
          "node tool/organizer_intake/export_event_review_decisions_from_firestore.mjs " +
          "--env dev --date YYYY-MM-DD",
      },
    };
  }
  return readJson(externalEventImportPlanPath);
}

function loadExternalEventImportExecutionPlan() {
  if (!fs.existsSync(externalEventImportExecutionPlanPath)) {
    return {
      schemaVersion: 1,
      generatedFrom: {
        externalEventImportPlan:
          "tool/organizer_intake/generated/external_event_import_plan.json",
        importPlanGeneratedFrom: {},
      },
      policy: {
        status: "disabled",
        writeEnabled: false,
        authorityModel: "undecided",
        reason:
          "External event import execution is preflight-only for read-only " +
          "external event projections. No createEvent callable invocation, " +
          "Catch booking, payment, reservation, waitlist, or Firestore write " +
          "is enabled.",
      },
      summary: {
        importActions: 0,
        createActions: 0,
        readOnlyActions: 0,
        skipped: 0,
        blocked: 0,
        projectionInvalid: 0,
        schemaInvalid: 0,
        wouldPublishReadOnly: 0,
        wouldCreate: 0,
        projectionValid: 0,
        projectionInvalidCount: 0,
        payloadValid: 0,
        payloadInvalid: 0,
        actionsByStatus: {},
      },
      guardrails: [
        "execution_preflight_never_writes_firestore",
        "create_event_callable_is_not_used_for_external_read_only_imports",
        "read_only_projection_requires_outbound_external_link",
      ],
      actions: [],
      commands: {
        plan: "node tool/organizer_intake/plan_external_event_imports.mjs",
        preflight:
          "node tool/organizer_intake/preflight_external_event_imports.mjs",
        write:
          "not available: approve ownership, defaults, and import policy first",
      },
    };
  }
  return readJson(externalEventImportExecutionPlanPath);
}

function collectRawArtifactFiles() {
  const roots = [
    rawArtifactsRoot,
    path.join(intakeRoot, "fixtures"),
    path.join(intakeRoot, "search_result_batches"),
    path.join(intakeRoot, "event_source_batches"),
    batchesRoot,
    curationDecisionsRoot,
    reviewDecisionsRoot,
    path.join(intakeRoot, "event_review_decisions"),
    path.join(intakeRoot, "event_location_resolutions"),
    policyGapDecisionsRoot,
  ];
  return roots.flatMap((root) => {
    if (!fs.existsSync(root)) return [];
    return walkJsonFiles(root).map((filePath) => {
      const content = fs.readFileSync(filePath);
      return {
        path: relative(filePath),
        sizeBytes: content.length,
        sha256: crypto.createHash("sha256").update(content).digest("hex"),
      };
    });
  }).sort((a, b) => a.path.localeCompare(b.path));
}

function collectEvidenceReferenceFiles(canonicalHostRegistry) {
  const refs = new Set();
  for (const host of canonicalHostRegistry.entries ?? []) {
    for (const surface of host.surfaces ?? []) {
      for (const evidence of surface.evidenceRefs ?? []) {
        if (typeof evidence.ref !== "string") continue;
        if (!evidence.ref.startsWith("tool/")) continue;
        refs.add(evidence.ref);
      }
    }
  }

  return [...refs].sort().flatMap((ref) => {
    const filePath = path.join(repoRoot, ref);
    if (!fs.existsSync(filePath) || !fs.statSync(filePath).isFile()) {
      return [];
    }
    const content = fs.readFileSync(filePath);
    return [{
      path: ref,
      sizeBytes: content.length,
      sha256: crypto.createHash("sha256").update(content).digest("hex"),
    }];
  });
}

function walkJsonFiles(root) {
  const entries = fs.readdirSync(root, {withFileTypes: true})
    .sort((a, b) => a.name.localeCompare(b.name));
  const files = [];
  for (const entry of entries) {
    const fullPath = path.join(root, entry.name);
    if (entry.isDirectory()) {
      files.push(...walkJsonFiles(fullPath));
    } else if (entry.isFile() && entry.name.endsWith(".json")) {
      files.push(fullPath);
    }
  }
  return files;
}

function validateBatches(batchList) {
  if (batchList.length === 0) {
    errors.push("No organizer intake batches found.");
  }
  const batchIds = new Set();
  for (const batch of batchList) {
    const prefix = batch.file;
    requiredExact(batch, "schemaVersion", 1, prefix);
    requiredSlug(batch, "batchId", prefix);
    requiredDate(batch, "createdAt", prefix);
    if (batch.batchId) {
      if (batchIds.has(batch.batchId)) errors.push(`${prefix}: duplicate batchId ${batch.batchId}`);
      batchIds.add(batch.batchId);
    }
    if (!batch.promotionPolicy || typeof batch.promotionPolicy !== "object") {
      errors.push(`${prefix}: missing promotionPolicy object`);
    } else {
      requiredString(batch.promotionPolicy, "policyVersion", `${prefix}/promotionPolicy`);
      requiredExact(
        batch.promotionPolicy,
        "publicPromotionDefault",
        "manual_admin_review_required",
        `${prefix}/promotionPolicy`
      );
      requiredExact(
        batch.promotionPolicy,
        "indexingDefault",
        "admin_public_approval_sets_index_follow",
        `${prefix}/promotionPolicy`
      );
      requiredExact(
        batch.promotionPolicy,
        "appVisibilityDefault",
        "hidden_until_claimed_or_app_approved",
        `${prefix}/promotionPolicy`
      );
      requiredExact(
        batch.promotionPolicy,
        "crawlDefault",
        "manual_only_disabled",
        `${prefix}/promotionPolicy`
      );
    }
    if (!Array.isArray(batch.entities) || batch.entities.length === 0) {
      errors.push(`${prefix}: entities must be a non-empty array`);
    }
  }
}

function validateReviewDecisions(decisionBatches, entityList) {
  const entityIds = new Set(entityList.map((entity) => entity.entityId));
  const decisionIds = new Set();
  const decidedEntities = new Set();
  for (const batch of decisionBatches) {
    const prefix = batch.file;
    requiredExact(batch, "schemaVersion", 1, prefix);
    requiredSlug(batch, "decisionBatchId", prefix);
    requiredDate(batch, "decidedAt", prefix);
    requiredString(batch, "reviewer", prefix);
    if (batch.decisionBatchId) {
      if (decisionIds.has(batch.decisionBatchId)) {
        errors.push(`${prefix}: duplicate decisionBatchId ${batch.decisionBatchId}`);
      }
      decisionIds.add(batch.decisionBatchId);
    }
    if (!Array.isArray(batch.decisions)) {
      errors.push(`${prefix}: decisions must be an array`);
      continue;
    }
    for (const [index, decision] of batch.decisions.entries()) {
      const decisionPrefix = `${prefix}/decisions[${index}]`;
      requiredSlug(decision, "entityId", decisionPrefix);
      if (decision.entityId && !entityIds.has(decision.entityId)) {
        errors.push(`${decisionPrefix}: unknown entityId ${decision.entityId}`);
      }
      const decisionKey = `${decision.entityId}`;
      if (decision.entityId) {
        if (decidedEntities.has(decisionKey)) {
          errors.push(`${decisionPrefix}: entity has multiple review decisions ${decision.entityId}`);
        }
        decidedEntities.add(decisionKey);
      }
      requiredEnum(
        decision,
        "decision",
        new Set(["approve_public", "hold", "suppress"]),
        decisionPrefix
      );
      requiredEnum(decision, "appVisibility", new Set(["hidden", "discoverable"]), decisionPrefix);
      validateReviewChecklist(decision.checklist, decisionPrefix);
      requiredString(decision, "note", decisionPrefix);
      if (decision.decision === "approve_public" && decision.appVisibility === "discoverable") {
        warnings.push(`${decisionPrefix}: public approval also makes entity app-discoverable`);
      }
    }
  }
}

function validateCurationDecisions(decisionBatches, entityList) {
  const entityById = new Map(entityList.map((entity) => [entity.entityId, entity]));
  const batchIds = new Set();
  const entityOps = new Set();
  const surfaceOps = new Set();
  for (const batch of decisionBatches) {
    const prefix = batch.file;
    requiredExact(batch, "schemaVersion", 1, prefix);
    requiredSlug(batch, "curationBatchId", prefix);
    requiredDate(batch, "decidedAt", prefix);
    requiredString(batch, "reviewer", prefix);
    if (batch.curationBatchId) {
      if (batchIds.has(batch.curationBatchId)) {
        errors.push(`${prefix}: duplicate curationBatchId ${batch.curationBatchId}`);
      }
      batchIds.add(batch.curationBatchId);
    }
    if (!Array.isArray(batch.operations)) {
      errors.push(`${prefix}: operations must be an array`);
      continue;
    }
    for (const [index, operation] of batch.operations.entries()) {
      const opPrefix = `${prefix}/operations[${index}]`;
      requiredEnum(
        operation,
        "type",
        new Set([
          "attach_surface",
          "merge_entity",
          "suppress_entity",
          "surface_decision",
          "split_surface",
        ]),
        opPrefix
      );
      requiredString(operation, "reason", opPrefix);
      if (operation.type === "attach_surface") {
        validateAttachSurfaceOperation(operation, entityById, surfaceOps, opPrefix);
      } else if (operation.type === "merge_entity") {
        validateMergeOperation(operation, entityById, entityOps, opPrefix);
      } else if (operation.type === "suppress_entity") {
        validateSuppressOperation(operation, entityById, entityOps, opPrefix);
      } else if (operation.type === "surface_decision") {
        validateSurfaceOperation(operation, entityById, surfaceOps, opPrefix);
      } else if (operation.type === "split_surface") {
        validateSplitSurfaceOperation(operation, entityById, surfaceOps, opPrefix);
      }
    }
  }
}

function validateAttachSurfaceOperation(operation, entityById, surfaceOps, prefix) {
  requiredSlug(operation, "entityId", prefix);
  requiredString(operation, "sourceCandidateId", prefix);
  if (operation.entityId && !entityById.has(operation.entityId)) {
    errors.push(`${prefix}: unknown entityId ${operation.entityId}`);
  }
  if (!operation.surface || typeof operation.surface !== "object") {
    errors.push(`${prefix}: missing surface object`);
    return;
  }
  validateCuratedSurfaceShape(operation.surface, prefix);
  const entity = entityById.get(operation.entityId);
  if (entity && operation.surface.surfaceId) {
    const surfaceIds = new Set((entity.surfaces ?? []).map((surface) => surface.surfaceId));
    if (surfaceIds.has(operation.surface.surfaceId)) {
      errors.push(`${prefix}: surfaceId ${operation.surface.surfaceId} already exists on ${operation.entityId}`);
    }
    const normalizedKeys = new Set((entity.surfaces ?? [])
      .map((surface) => surface.normalizedKey)
      .filter(Boolean));
    if (operation.surface.normalizedKey && normalizedKeys.has(operation.surface.normalizedKey)) {
      warnings.push(
        `${prefix}: normalizedKey ${operation.surface.normalizedKey} already exists on ${operation.entityId}`
      );
    }
  }
  trackSingleSurfaceOperation(surfaceOps, operation.entityId, operation.surface.surfaceId, operation.type, prefix);
}

function validateCuratedSurfaceShape(surface, prefix) {
  requiredSlug(surface, "surfaceId", `${prefix}/surface`);
  requiredEnum(surface, "platform", allowedSurfacePlatforms, `${prefix}/surface`);
  requiredEnum(surface, "surfaceKind", allowedSurfaceKinds, `${prefix}/surface`);
  requiredEnum(surface, "role", allowedSurfaceRoles, `${prefix}/surface`);
  requiredEnum(surface, "status", allowedSurfaceStatuses, `${prefix}/surface`);
  validateUrlOrNull(surface.url, `${prefix}/surface/url`);
  validateSurfaceNormalization(surface, `${prefix}/surface`);
  if (surface.normalizedKey !== null && typeof surface.normalizedKey !== "string") {
    errors.push(`${prefix}/surface: normalizedKey must be string or null`);
  }
  validateConfidence(surface.confidence, `${prefix}/surface`);
  validateCrawl(surface.crawl, `${prefix}/surface`);
  validateEvidenceRefs(surface.evidenceRefs, `${prefix}/surface`);
  requiredString(surface, "notes", `${prefix}/surface`);
}

function validateMergeOperation(operation, entityById, entityOps, prefix) {
  requiredSlug(operation, "sourceEntityId", prefix);
  requiredSlug(operation, "targetEntityId", prefix);
  if (operation.sourceEntityId === operation.targetEntityId) {
    errors.push(`${prefix}: merge source and target must differ`);
  }
  if (operation.sourceEntityId && !entityById.has(operation.sourceEntityId)) {
    errors.push(`${prefix}: unknown sourceEntityId ${operation.sourceEntityId}`);
  }
  if (operation.targetEntityId && !entityById.has(operation.targetEntityId)) {
    errors.push(`${prefix}: unknown targetEntityId ${operation.targetEntityId}`);
  }
  trackSingleEntityOperation(entityOps, operation.sourceEntityId, operation.type, prefix);
}

function validateSuppressOperation(operation, entityById, entityOps, prefix) {
  requiredSlug(operation, "entityId", prefix);
  if (operation.entityId && !entityById.has(operation.entityId)) {
    errors.push(`${prefix}: unknown entityId ${operation.entityId}`);
  }
  trackSingleEntityOperation(entityOps, operation.entityId, operation.type, prefix);
}

function validateSurfaceOperation(operation, entityById, surfaceOps, prefix) {
  requiredSlug(operation, "entityId", prefix);
  requiredSlug(operation, "surfaceId", prefix);
  requiredEnum(
    operation,
    "decision",
    new Set(["accept_primary", "accept_secondary", "reject_wrong_entity", "mark_ambiguous", "mark_historical"]),
    prefix
  );
  validateSurfaceReference(operation.entityId, operation.surfaceId, entityById, prefix);
  trackSingleSurfaceOperation(surfaceOps, operation.entityId, operation.surfaceId, operation.type, prefix);
}

function validateSplitSurfaceOperation(operation, entityById, surfaceOps, prefix) {
  requiredSlug(operation, "entityId", prefix);
  requiredSlug(operation, "surfaceId", prefix);
  requiredSlug(operation, "newEntityId", prefix);
  if (operation.newEntityId && entityById.has(operation.newEntityId)) {
    warnings.push(`${prefix}: newEntityId ${operation.newEntityId} already exists`);
  }
  validateSurfaceReference(operation.entityId, operation.surfaceId, entityById, prefix);
  trackSingleSurfaceOperation(surfaceOps, operation.entityId, operation.surfaceId, operation.type, prefix);
}

function validateSurfaceReference(entityId, surfaceId, entityById, prefix) {
  const entity = entityById.get(entityId);
  if (!entity) {
    if (entityId) errors.push(`${prefix}: unknown entityId ${entityId}`);
    return;
  }
  const surfaceIds = new Set((entity.surfaces ?? []).map((surface) => surface.surfaceId));
  if (surfaceId && !surfaceIds.has(surfaceId)) {
    errors.push(`${prefix}: unknown surfaceId ${surfaceId} for ${entityId}`);
  }
}

function trackSingleEntityOperation(entityOps, entityId, type, prefix) {
  if (!entityId) return;
  const key = `entity:${entityId}`;
  if (entityOps.has(key)) {
    errors.push(`${prefix}: entity ${entityId} has multiple curation operations`);
  }
  entityOps.add(key);
}

function trackSingleSurfaceOperation(surfaceOps, entityId, surfaceId, type, prefix) {
  if (!entityId || !surfaceId) return;
  const key = `surface:${entityId}:${surfaceId}`;
  if (surfaceOps.has(key)) {
    errors.push(`${prefix}: surface ${entityId}/${surfaceId} has multiple curation operations`);
  }
  surfaceOps.add(key);
}

function validateReviewChecklist(checklist, prefix) {
  if (!checklist || typeof checklist !== "object") {
    errors.push(`${prefix}: missing checklist object`);
    return;
  }
  for (const field of [
    "identityReviewed",
    "surfaceInventoryReviewed",
    "ownerSafeCopyReviewed",
    "marketScopeReviewed",
    "mediaRightsReviewed",
    "crawlDisabledReviewed",
  ]) {
    if (typeof checklist[field] !== "boolean") {
      errors.push(`${prefix}/checklist: ${field} must be boolean`);
    }
  }
  if (
    checklist.manualReportsReviewed !== undefined &&
    typeof checklist.manualReportsReviewed !== "boolean"
  ) {
    errors.push(`${prefix}/checklist: manualReportsReviewed must be boolean`);
  }
}

function validateEntities(entityList) {
  const entityIds = new Set();
  const canonicalPaths = new Map();
  for (const entity of entityList) {
    const prefix = `${entity.batchId ?? "<missing-batch>"}/${entity.entityId ?? "<missing-entity>"}`;
    requiredSlug(entity, "entityId", prefix);
    requiredString(entity, "displayName", prefix);
    requiredSlug(entity, "canonicalSlug", prefix);
    requiredEnum(entity, "entityKind", allowedEntityKinds, prefix);
    requiredEnum(entity, "reviewStatus", allowedReviewStatuses, prefix);
    requiredEnum(entity, "relationshipToCatch", allowedRelationshipStates, prefix);
    requiredEnum(entity, "priority", new Set(["p0", "p1", "p2", "p3"]), prefix);
    requiredStringArray(entity, "aliases", prefix);
    requiredStringArray(entity, "reviewNotes", prefix);
    if (entity.entityId) {
      if (entityIds.has(entity.entityId)) errors.push(`${prefix}: duplicate entityId`);
      entityIds.add(entity.entityId);
    }

    validateActivityDefaults(entity.activityDefaults, entity, prefix);
    validateGeographicScope(entity.geographicScope, prefix);
    validatePublicListingIntent(entity.publicListingIntent, entity, canonicalPaths, prefix);
    validatePublicDraft(entity.publicDraft, prefix);
    validateSurfaces(entity.surfaces, entity, prefix);
    validateDedupeHints(entity.dedupeHints, prefix);
  }
}

function validateActivityDefaults(defaults, entity, prefix) {
  if (!defaults || typeof defaults !== "object") {
    errors.push(`${prefix}: missing activityDefaults object`);
    return;
  }
  if (defaults.primaryActivityKind !== null && typeof defaults.primaryActivityKind !== "string") {
    errors.push(`${prefix}/activityDefaults: primaryActivityKind must be string or null`);
  }
  requiredStringArray(defaults, "supportedActivityKinds", `${prefix}/activityDefaults`);
  requiredEnum(defaults, "confidence", allowedConfidence, `${prefix}/activityDefaults`);
  if (!Array.isArray(defaults.derivedFromSurfaceIds)) {
    errors.push(`${prefix}/activityDefaults: derivedFromSurfaceIds must be an array`);
    return;
  }
  const surfaceIds = new Set((entity.surfaces ?? []).map((surface) => surface.surfaceId));
  for (const surfaceId of defaults.derivedFromSurfaceIds) {
    if (!surfaceIds.has(surfaceId)) {
      errors.push(`${prefix}/activityDefaults: unknown derived surface ${surfaceId}`);
    }
  }
}

function validateGeographicScope(scope, prefix) {
  if (!scope || typeof scope !== "object") {
    errors.push(`${prefix}: missing geographicScope object`);
    return;
  }
  requiredEnum(scope, "kind", allowedGeoScopes, `${prefix}/geographicScope`);
  if (scope.primaryMarketSlug !== null && !isSlug(scope.primaryMarketSlug)) {
    errors.push(`${prefix}/geographicScope: primaryMarketSlug must be a slug or null`);
  }
  if (!Array.isArray(scope.markets)) {
    errors.push(`${prefix}/geographicScope: markets must be an array`);
  } else if (scope.kind !== "remote" && scope.markets.length === 0) {
    errors.push(`${prefix}/geographicScope: non-remote entities need at least one market`);
  } else {
    const marketIds = new Set();
    for (const [index, market] of scope.markets.entries()) {
      const marketPrefix = `${prefix}/geographicScope/markets[${index}]`;
      requiredSlug(market, "marketSlug", marketPrefix);
      requiredString(market, "displayName", marketPrefix);
      requiredCountryCode(market, "countryCode", marketPrefix);
      if (market.marketSlug) {
        if (marketIds.has(market.marketSlug)) errors.push(`${marketPrefix}: duplicate marketSlug`);
        marketIds.add(market.marketSlug);
      }
      if (!market.eventFilter || typeof market.eventFilter !== "object") {
        errors.push(`${marketPrefix}: missing eventFilter object`);
      } else {
        requiredExact(market.eventFilter, "mode", "eventCity", `${marketPrefix}/eventFilter`);
        requiredSlug(market.eventFilter, "citySlug", `${marketPrefix}/eventFilter`);
      }
    }
    if (scope.primaryMarketSlug && !marketIds.has(scope.primaryMarketSlug)) {
      errors.push(`${prefix}/geographicScope: primaryMarketSlug is not in markets`);
    }
  }
  if (!Array.isArray(scope.countryCodes) || scope.countryCodes.length === 0) {
    errors.push(`${prefix}/geographicScope: countryCodes must be non-empty`);
  } else {
    for (const countryCode of scope.countryCodes) {
      if (!/^[A-Z]{2}$/.test(String(countryCode))) {
        errors.push(`${prefix}/geographicScope: invalid countryCode ${countryCode}`);
      }
    }
  }
}

function validatePublicListingIntent(intent, entity, canonicalPaths, prefix) {
  if (!intent || typeof intent !== "object") {
    errors.push(`${prefix}: missing publicListingIntent object`);
    return;
  }
  requiredPath(intent, "canonicalPath", `${prefix}/publicListingIntent`);
  if (intent.canonicalPath) {
    const existing = canonicalPaths.get(intent.canonicalPath);
    if (existing && existing !== entity.entityId) {
      errors.push(`${prefix}: canonicalPath duplicates ${existing}`);
    }
    canonicalPaths.set(intent.canonicalPath, entity.entityId);
  }
  if (!Array.isArray(intent.legacyPaths)) {
    errors.push(`${prefix}/publicListingIntent: legacyPaths must be an array`);
  } else {
    for (const legacyPath of intent.legacyPaths) {
      if (!isOrganizerPath(legacyPath)) {
        errors.push(`${prefix}/publicListingIntent: invalid legacyPath ${legacyPath}`);
      }
    }
  }
  requiredExact(intent, "pageMode", "singleEntity", `${prefix}/publicListingIntent`);
  if (typeof intent.indexOnAdminApproval !== "boolean") {
    errors.push(`${prefix}/publicListingIntent: indexOnAdminApproval must be boolean`);
  }
  requiredEnum(
    intent,
    "appVisibilityOnAdminApproval",
    new Set(["hidden", "discoverable"]),
    `${prefix}/publicListingIntent`
  );
}

function validatePublicDraft(draft, prefix) {
  if (!draft || typeof draft !== "object") {
    errors.push(`${prefix}: missing publicDraft object`);
    return;
  }
  optionalString(draft, "headline", `${prefix}/publicDraft`);
  optionalString(draft, "summary", `${prefix}/publicDraft`);
  optionalString(draft, "sourceSummary", `${prefix}/publicDraft`);
  requiredStringArray(draft, "formats", `${prefix}/publicDraft`);
  requiredStringArray(draft, "missingEvidence", `${prefix}/publicDraft`);
}

function validateSurfaces(surfaces, entity, prefix) {
  if (!Array.isArray(surfaces) || surfaces.length === 0) {
    errors.push(`${prefix}: surfaces must be a non-empty array`);
    return;
  }
  const surfaceIds = new Set();
  for (const [index, surface] of surfaces.entries()) {
    const surfacePrefix = `${prefix}/surfaces[${index}]`;
    requiredSlug(surface, "surfaceId", surfacePrefix);
    if (surface.surfaceId) {
      if (surfaceIds.has(surface.surfaceId)) errors.push(`${surfacePrefix}: duplicate surfaceId`);
      surfaceIds.add(surface.surfaceId);
    }
    requiredEnum(surface, "platform", allowedSurfacePlatforms, surfacePrefix);
    requiredEnum(surface, "surfaceKind", allowedSurfaceKinds, surfacePrefix);
    requiredEnum(surface, "role", allowedSurfaceRoles, surfacePrefix);
    requiredEnum(surface, "status", allowedSurfaceStatuses, surfacePrefix);
    if (surface.role === "rejected" && surface.status !== "rejected") {
      errors.push(`${surfacePrefix}: rejected role requires rejected status`);
    }
    if (surface.surfaceKind === "wrongEntity" && surface.status !== "rejected") {
      errors.push(`${surfacePrefix}: wrongEntity surfaces must be rejected`);
    }
    validateUrlOrNull(surface.url, `${surfacePrefix}/url`);
    validateSurfaceNormalization(surface, surfacePrefix);
    if (surface.normalizedKey !== null && typeof surface.normalizedKey !== "string") {
      errors.push(`${surfacePrefix}: normalizedKey must be string or null`);
    }
    validateConfidence(surface.confidence, surfacePrefix);
    validateCrawl(surface.crawl, surfacePrefix);
    validateEvidenceRefs(surface.evidenceRefs, surfacePrefix);
    requiredString(surface, "notes", surfacePrefix);
  }

  const activeSurfaces = surfaces.filter((surface) => surface.status === "active");
  if (!activeSurfaces.some((surface) => surface.role === "primary")) {
    warnings.push(`${prefix}: no active primary surface`);
  }
  const derived = new Set(entity.activityDefaults?.derivedFromSurfaceIds ?? []);
  for (const surface of surfaces) {
    if (derived.has(surface.surfaceId) && surface.status === "rejected") {
      errors.push(`${prefix}: activityDefaults cannot derive from rejected surface ${surface.surfaceId}`);
    }
  }
}

function validateSurfaceNormalization(surface, prefix) {
  if (typeof surface.url !== "string") return;
  let normalized;
  try {
    normalized = normalizeOrganizerSurfaceUrl(surface.url);
  } catch (error) {
    errors.push(`${prefix}: could not normalize surface URL: ${error.message}`);
    return;
  }
  if (surface.platform !== normalized.platform) {
    errors.push(
      `${prefix}: platform ${surface.platform} does not match normalized platform ${normalized.platform}`
    );
  }
  if (surface.surfaceKind !== normalized.surfaceKind) {
    errors.push(
      `${prefix}: surfaceKind ${surface.surfaceKind} does not match normalized kind ${normalized.surfaceKind}`
    );
  }
  if (surface.normalizedKey && normalized.normalizedKey && surface.normalizedKey !== normalized.normalizedKey) {
    errors.push(
      `${prefix}: normalizedKey ${surface.normalizedKey} does not match adapter key ${normalized.normalizedKey}`
    );
  }
}

function validateConfidence(confidence, prefix) {
  if (!confidence || typeof confidence !== "object") {
    errors.push(`${prefix}: missing confidence object`);
    return;
  }
  requiredEnum(confidence, "entityMatch", allowedConfidence, `${prefix}/confidence`);
  requiredEnum(confidence, "ownership", allowedConfidence, `${prefix}/confidence`);
  requiredEnum(confidence, "city", allowedConfidence, `${prefix}/confidence`);
}

function validateCrawl(crawl, prefix) {
  if (!crawl || typeof crawl !== "object") {
    errors.push(`${prefix}: missing crawl object`);
    return;
  }
  requiredEnum(crawl, "eventDiscoveryStatus", allowedCrawlStatuses, `${prefix}/crawl`);
  requiredEnum(crawl, "policy", allowedCrawlPolicies, `${prefix}/crawl`);
  if (typeof crawl.supportsEventExtraction !== "boolean") {
    errors.push(`${prefix}/crawl: supportsEventExtraction must be boolean`);
  }
  if (crawl.eventDiscoveryStatus !== "disabled") {
    warnings.push(`${prefix}: crawl is not disabled; cost and platform policy review required`);
  }
}

function validateEvidenceRefs(evidenceRefs, prefix) {
  if (!Array.isArray(evidenceRefs)) {
    errors.push(`${prefix}: evidenceRefs must be an array`);
    return;
  }
  for (const [index, evidence] of evidenceRefs.entries()) {
    const evidencePrefix = `${prefix}/evidenceRefs[${index}]`;
    requiredEnum(
      evidence,
      "type",
      new Set(["hostDiscoveryRun", "seedClub", "userReportedSearchResult", "manualNote"]),
      evidencePrefix
    );
    if (evidence.ref !== null && typeof evidence.ref !== "string") {
      errors.push(`${evidencePrefix}: ref must be string or null`);
    }
    requiredString(evidence, "description", evidencePrefix);
    if (typeof evidence.ref === "string" && evidence.ref.startsWith("tool/") &&
      !fs.existsSync(path.join(repoRoot, evidence.ref))) {
      errors.push(`${evidencePrefix}: referenced file does not exist ${evidence.ref}`);
    }
  }
}

function validateDedupeHints(dedupeHints, prefix) {
  if (!Array.isArray(dedupeHints)) {
    errors.push(`${prefix}: dedupeHints must be an array`);
    return;
  }
  for (const [index, hint] of dedupeHints.entries()) {
    const hintPrefix = `${prefix}/dedupeHints[${index}]`;
    requiredEnum(
      hint,
      "type",
      new Set(["legacyClubId", "canonicalPath", "platformId", "normalizedName", "manual"]),
      hintPrefix
    );
    requiredString(hint, "value", hintPrefix);
    requiredEnum(hint, "strength", new Set(["weak", "medium", "strong"]), hintPrefix);
  }
}

function buildCurationState(decisionBatches, entityList) {
  const operations = [];
  for (const batch of decisionBatches) {
    for (const [index, operation] of (batch.operations ?? []).entries()) {
      operations.push({
        ...operation,
        operationId: `${batch.curationBatchId}:${index}`,
        decidedAt: batch.decidedAt,
        reviewer: batch.reviewer,
        curationBatchId: batch.curationBatchId,
        sourceFile: batch.file,
      });
    }
  }

  const attachedSurfaces = operations.filter((operation) => operation.type === "attach_surface");
  const mergedEntities = operations.filter((operation) => operation.type === "merge_entity");
  const suppressedEntities = operations.filter((operation) => operation.type === "suppress_entity");
  const surfaceDecisions = operations.filter((operation) => operation.type === "surface_decision");
  const splitSurfaces = operations.filter((operation) => operation.type === "split_surface");
  const targetEntityIds = new Set(mergedEntities.map((operation) => operation.targetEntityId));
  const sourceEntityIds = new Set(mergedEntities.map((operation) => operation.sourceEntityId));

  return {
    schemaVersion: 1,
    generatedFrom: {
      batches: batches.map((batch) => batch.file).sort(),
      curationDecisionBatches: decisionBatches.map((batch) => batch.file).sort(),
      schema: "tool/organizer_intake/schemas/organizer_curation_decisions.schema.json",
    },
    summary: {
      entities: entityList.length,
      operations: operations.length,
      attachedSurfaces: attachedSurfaces.length,
      merges: mergedEntities.length,
      suppressions: suppressedEntities.length,
      surfaceDecisions: surfaceDecisions.length,
      splitSurfaces: splitSurfaces.length,
      mergeTargets: targetEntityIds.size,
      mergedSources: sourceEntityIds.size,
    },
    attachedSurfaces: attachedSurfaces.map((operation) => operationSummary(operation)),
    mergedEntities: mergedEntities.map((operation) => operationSummary(operation)),
    suppressedEntities: suppressedEntities.map((operation) => operationSummary(operation)),
    surfaceDecisions: surfaceDecisions.map((operation) => operationSummary(operation)),
    splitSurfaces: splitSurfaces.map((operation) => operationSummary(operation)),
    commands: curationCommands(),
  };
}

function applyCurationState(entityList, curationState) {
  const entitiesById = new Map(entityList.map((entity) => [
    entity.entityId,
    structuredClone(entity),
  ]));

  for (const operation of curationState.attachedSurfaces) {
    const entity = entitiesById.get(operation.entityId);
    if (!entity) continue;
    entity.surfaces = uniqueBy(
      [...(entity.surfaces ?? []), curatedAttachedSurface(operation)],
      (surface) => surface.surfaceId
    );
    appendReviewNote(
      entity,
      `Attached ${operation.surface.surfaceId} from ${operation.sourceCandidateId}: ${operation.reason}`
    );
  }

  for (const operation of curationState.surfaceDecisions) {
    const entity = entitiesById.get(operation.entityId);
    if (!entity) continue;
    entity.surfaces = entity.surfaces.map((surface) =>
      surface.surfaceId === operation.surfaceId ?
        curatedSurface(surface, operation) :
        surface
    );
    appendReviewNote(entity, curationReviewNote(operation));
  }

  for (const operation of curationState.splitSurfaces) {
    const entity = entitiesById.get(operation.entityId);
    if (!entity) continue;
    entity.surfaces = entity.surfaces.map((surface) =>
      surface.surfaceId === operation.surfaceId ?
        splitSurface(surface, operation) :
        surface
    );
    appendReviewNote(
      entity,
      `Split ${operation.surfaceId} toward ${operation.newEntityId}: ${operation.reason}`
    );
  }

  for (const operation of curationState.mergedEntities) {
    const source = entitiesById.get(operation.sourceEntityId);
    const target = entitiesById.get(operation.targetEntityId);
    if (!source || !target) continue;
    mergeEntityIntoTarget({source, target, operation});
    entitiesById.delete(operation.sourceEntityId);
  }

  for (const operation of curationState.suppressedEntities) {
    const entity = entitiesById.get(operation.entityId);
    if (!entity) continue;
    entity.reviewStatus = "suppressed";
    entity.relationshipToCatch = "internalOnly";
    appendReviewNote(entity, `Suppressed by curation: ${operation.reason}`);
  }

  return [...entitiesById.values()].sort((a, b) => a.entityId.localeCompare(b.entityId));
}

function curatedAttachedSurface(operation) {
  return {
    ...operation.surface,
    notes: appendSentence(
      operation.surface.notes,
      `Attached by curation from ${operation.sourceCandidateId}: ${operation.reason}`
    ),
  };
}

function curatedSurface(surface, operation) {
  const next = {
    ...surface,
    notes: appendSentence(surface.notes, `Curated ${operation.decision}: ${operation.reason}`),
  };
  if (operation.decision === "accept_primary") {
    next.status = "active";
    next.role = "primary";
  } else if (operation.decision === "accept_secondary") {
    next.status = "active";
    next.role = "secondary";
  } else if (operation.decision === "reject_wrong_entity") {
    next.status = "rejected";
    next.role = "rejected";
    next.surfaceKind = "wrongEntity";
    next.crawl = blockedCrawl(surface);
  } else if (operation.decision === "mark_ambiguous") {
    next.status = "ambiguous";
    next.role = "ambiguous";
    next.crawl = disabledCrawl(surface);
  } else if (operation.decision === "mark_historical") {
    next.status = "historical";
    next.role = "historical";
    next.crawl = disabledCrawl(surface);
  }
  return next;
}

function splitSurface(surface, operation) {
  return {
    ...surface,
    status: "rejected",
    role: "rejected",
    surfaceKind: "wrongEntity",
    crawl: blockedCrawl(surface),
    notes: appendSentence(
      surface.notes,
      `Split from this entity; create ${operation.newEntityId}. ${operation.reason}`
    ),
  };
}

function mergeEntityIntoTarget({source, target, operation}) {
  target.aliases = uniqueStrings([
    ...(target.aliases ?? []),
    source.displayName,
    ...(source.aliases ?? []),
  ]);
  target.surfaces = uniqueBy(
    [...(target.surfaces ?? []), ...(source.surfaces ?? [])],
    (surface) => surface.surfaceId
  );
  target.dedupeHints = uniqueBy(
    [...(target.dedupeHints ?? []), ...(source.dedupeHints ?? [])],
    (hint) => `${hint.type}:${hint.value}`
  );
  target.reviewNotes = uniqueStrings([
    ...(target.reviewNotes ?? []),
    ...(source.reviewNotes ?? []),
    `Merged ${source.entityId} into ${target.entityId}: ${operation.reason}`,
  ]);
  target.entitySubtypes = uniqueStrings([
    ...(target.entitySubtypes ?? []),
    source.entityKind,
  ]);
  target.curation = {
    ...(target.curation ?? {}),
    mergedEntityIds: uniqueStrings([
      ...(target.curation?.mergedEntityIds ?? []),
      source.entityId,
      ...(source.curation?.mergedEntityIds ?? []),
    ]),
  };
  target.activityDefaults = {
    ...target.activityDefaults,
    supportedActivityKinds: uniqueStrings([
      ...(target.activityDefaults?.supportedActivityKinds ?? []),
      ...(source.activityDefaults?.supportedActivityKinds ?? []),
    ]),
    derivedFromSurfaceIds: uniqueStrings([
      ...(target.activityDefaults?.derivedFromSurfaceIds ?? []),
      ...(source.activityDefaults?.derivedFromSurfaceIds ?? []),
    ]).filter((surfaceId) =>
      (target.surfaces ?? []).some((surface) => surface.surfaceId === surfaceId)
    ),
  };
  mergeGeographicScope(target, source);
}

function mergeGeographicScope(target, source) {
  const targetMarkets = target.geographicScope?.markets ?? [];
  const sourceMarkets = source.geographicScope?.markets ?? [];
  target.geographicScope = {
    ...target.geographicScope,
    kind: mergedGeoScopeKind(target.geographicScope?.kind, source.geographicScope?.kind),
    markets: uniqueBy([...targetMarkets, ...sourceMarkets], (market) => market.marketSlug),
    countryCodes: uniqueStrings([
      ...(target.geographicScope?.countryCodes ?? []),
      ...(source.geographicScope?.countryCodes ?? []),
    ]),
  };
}

function mergedGeoScopeKind(left, right) {
  if (left === right) return left;
  if ([left, right].includes("global")) return "global";
  if ([left, right].includes("national")) return "national";
  if ([left, right].includes("multiCity")) return "multiCity";
  if ([left, right].includes("remote")) return "multiCity";
  return "multiCity";
}

function operationSummary(operation) {
  return Object.fromEntries(
    Object.entries(operation)
      .filter(([key]) => !["type"].includes(key))
      .sort(([a], [b]) => a.localeCompare(b))
  );
}

function curationCommands() {
  return {
    attachSurface:
      "node tool/organizer_intake/curation_decision.mjs draft attach_surface " +
      "--entity ENTITY --search-candidate CANDIDATE_ID --reviewer REVIEWER " +
      "--date YYYY-MM-DD --reason \"Surface belongs to this organizer.\"",
    mergeEntity:
      "node tool/organizer_intake/curation_decision.mjs draft merge_entity " +
      "--source SOURCE_ENTITY --target TARGET_ENTITY --reviewer REVIEWER " +
      "--date YYYY-MM-DD --reason \"Same organizer entity.\"",
    suppressEntity:
      "node tool/organizer_intake/curation_decision.mjs draft suppress_entity " +
      "--entity ENTITY --reviewer REVIEWER --date YYYY-MM-DD " +
      "--reason \"False-positive organizer candidate.\"",
    surfaceDecision:
      "node tool/organizer_intake/curation_decision.mjs draft surface_decision " +
      "--entity ENTITY --surface SURFACE --decision reject_wrong_entity " +
      "--reviewer REVIEWER --date YYYY-MM-DD --reason \"Wrong entity.\"",
    splitSurface:
      "node tool/organizer_intake/curation_decision.mjs draft split_surface " +
      "--entity ENTITY --surface SURFACE --new-entity NEW_ENTITY " +
      "--reviewer REVIEWER --date YYYY-MM-DD --reason \"Surface belongs to a separate organizer.\"",
  };
}

function curationReviewNote(operation) {
  return `Surface ${operation.surfaceId} ${operation.decision}: ${operation.reason}`;
}

function curationSummaryByEntity(curationState) {
  const byEntity = new Map();
  const ensure = (entityId) => {
    if (!byEntity.has(entityId)) {
      byEntity.set(entityId, {
        attachedSurfaces: [],
        mergedFrom: [],
        mergedInto: null,
        suppressed: null,
        surfaceDecisions: [],
        splitSurfaces: [],
      });
    }
    return byEntity.get(entityId);
  };
  for (const operation of curationState.mergedEntities) {
    ensure(operation.targetEntityId).mergedFrom.push(operation.sourceEntityId);
    ensure(operation.sourceEntityId).mergedInto = operation.targetEntityId;
  }
  for (const operation of curationState.attachedSurfaces) {
    ensure(operation.entityId).attachedSurfaces.push({
      surfaceId: operation.surface.surfaceId,
      sourceCandidateId: operation.sourceCandidateId,
      reason: operation.reason,
    });
  }
  for (const operation of curationState.suppressedEntities) {
    ensure(operation.entityId).suppressed = operation.reason;
  }
  for (const operation of curationState.surfaceDecisions) {
    ensure(operation.entityId).surfaceDecisions.push({
      surfaceId: operation.surfaceId,
      decision: operation.decision,
      reason: operation.reason,
    });
  }
  for (const operation of curationState.splitSurfaces) {
    ensure(operation.entityId).splitSurfaces.push({
      surfaceId: operation.surfaceId,
      newEntityId: operation.newEntityId,
      reason: operation.reason,
    });
  }
  return byEntity;
}

function appendReviewNote(entity, note) {
  entity.reviewNotes = uniqueStrings([...(entity.reviewNotes ?? []), note]);
}

function disabledCrawl(surface) {
  return {
    ...surface.crawl,
    eventDiscoveryStatus: "disabled",
    policy: "manualOnly",
  };
}

function blockedCrawl(surface) {
  return {
    ...surface.crawl,
    eventDiscoveryStatus: "disabled",
    policy: "blocked",
    supportsEventExtraction: false,
  };
}

function latestReviewDecisions(decisionBatches) {
  const decisions = new Map();
  for (const batch of decisionBatches) {
    for (const decision of batch.decisions ?? []) {
      decisions.set(decision.entityId, {
        ...decision,
        decidedAt: batch.decidedAt,
        decisionBatchId: batch.decisionBatchId,
        reviewer: batch.reviewer,
        sourceFile: batch.file,
      });
    }
  }
  return decisions;
}

function buildDedupeIndex(entityList, curationState) {
  const dedupeKeys = [];
  const candidateSummaries = [];
  for (const entity of [...entityList].sort((a, b) => a.entityId.localeCompare(b.entityId))) {
    const keys = [];
    addKey(keys, "entity_id", entity.entityId, "strong", "Canonical organizer entity id.");
    addKey(keys, "canonical_slug", entity.canonicalSlug, "medium", "Canonical public slug.");
    addKey(keys, "normalized_name", normalizeName(entity.displayName), "medium", "Normalized display name.");
    for (const alias of entity.aliases ?? []) {
      addKey(keys, "alias", normalizeName(alias), "weak", "Normalized alias.");
    }
    for (const legacyPath of entity.publicListingIntent?.legacyPaths ?? []) {
      addKey(keys, "legacy_public_path", legacyPath, "medium", "Legacy public path kept for redirect/dedupe.");
    }
    if (entity.publicListingIntent?.canonicalPath) {
      addKey(keys, "canonical_public_path", entity.publicListingIntent.canonicalPath, "strong", "Canonical public path.");
    }
    for (const hint of entity.dedupeHints ?? []) {
      addKey(keys, hint.type, hint.value, hint.strength, "Manual or compatibility dedupe hint.");
    }
    for (const surface of entity.surfaces ?? []) {
      if (!surface.normalizedKey) continue;
      const isRejected = surface.status === "rejected" || surface.role === "rejected";
      addKey(
        keys,
        isRejected ? "rejected_surface" : "surface",
        surface.normalizedKey,
        isRejected ? "weak" : "strong",
        `${surface.platform} ${surface.surfaceKind} surface.`
      );
    }

    const uniqueKeys = [...new Map(keys.map((entry) => [`${entry.type}:${entry.value}`, entry])).values()]
      .sort((a, b) => `${a.type}:${a.value}`.localeCompare(`${b.type}:${b.value}`));
    dedupeKeys.push(...uniqueKeys.map((key) => ({...key, entityId: entity.entityId})));
    candidateSummaries.push({
      entityId: entity.entityId,
      displayName: entity.displayName,
      entityKind: entity.entityKind,
      reviewStatus: entity.reviewStatus,
      relationshipToCatch: entity.relationshipToCatch,
      geographicScope: entity.geographicScope?.kind ?? null,
      markets: (entity.geographicScope?.markets ?? []).map((market) => market.marketSlug).sort(),
      canonicalPath: entity.publicListingIntent?.canonicalPath ?? null,
      legacyPaths: entity.publicListingIntent?.legacyPaths ?? [],
      activeSurfaceCount: (entity.surfaces ?? []).filter((surface) => surface.status === "active").length,
      ambiguousSurfaceCount: (entity.surfaces ?? []).filter((surface) =>
        surface.status === "ambiguous" || surface.role === "ambiguous"
      ).length,
      rejectedSurfaceCount: (entity.surfaces ?? []).filter((surface) =>
        surface.status === "rejected" || surface.role === "rejected"
      ).length,
      mergedEntityIds: entity.curation?.mergedEntityIds ?? [],
      dedupeKeys: uniqueKeys,
    });
  }
  const conflicts = duplicateKeyConflicts(dedupeKeys);
  return {
    schemaVersion: 1,
    generatedFrom: {
      batches: batches.map((batch) => batch.file).sort(),
      curationDecisionBatches: curationDecisionBatches.map((batch) => batch.file).sort(),
      reviewDecisionBatches: reviewDecisionBatches.map((batch) => batch.file).sort(),
      schema: "tool/organizer_intake/schemas/organizer_intake_batch.schema.json",
    },
    entityCount: entityList.length,
    counts: {
      byEntityKind: countBy(entityList, "entityKind"),
      byReviewStatus: countBy(entityList, "reviewStatus"),
      byRelationshipToCatch: countBy(entityList, "relationshipToCatch"),
      byGeographicScope: countBy(entityList.map((entity) => ({
        geographicScope: entity.geographicScope?.kind ?? "<missing>",
      })), "geographicScope"),
    },
    candidates: candidateSummaries,
    curationSummary: curationState.summary,
    dedupeKeys: dedupeKeys.sort((a, b) =>
      `${a.type}:${a.value}:${a.entityId}`.localeCompare(`${b.type}:${b.value}:${b.entityId}`)
    ),
    conflicts,
    inputHash: hashObject({
      batches: batches.map((batch) => ({...batch, file: undefined})),
      curation: curationState,
    }),
  };
}

function validateDedupeConflicts(index) {
  for (const conflict of index.conflicts) {
    if (conflict.maxStrength === "strong") {
      errors.push(
        `strong dedupe conflict ${conflict.type}:${conflict.value} on ${conflict.entityIds.join(", ")}`
      );
    } else {
      warnings.push(
        `dedupe conflict ${conflict.type}:${conflict.value} on ${conflict.entityIds.join(", ")}`
      );
    }
  }
}

function buildReviewQueue(entityList, index, decisions, curationState) {
  const conflictsByEntity = new Map();
  const curationByEntity = curationSummaryByEntity(curationState);
  for (const conflict of index.conflicts) {
    for (const entityId of conflict.entityIds) {
      if (!conflictsByEntity.has(entityId)) conflictsByEntity.set(entityId, []);
      conflictsByEntity.get(entityId).push(conflict);
    }
  }

  const items = [];
  for (const entity of [...entityList].sort((a, b) => reviewSortKey(a).localeCompare(reviewSortKey(b)))) {
    if (["published", "claimed", "suppressed"].includes(entity.reviewStatus)) continue;
    const decision = decisions.get(entity.entityId) ?? null;
    const gates = reviewGates(entity, conflictsByEntity.get(entity.entityId) ?? [], decision);
    const blockers = gates.filter((gate) => !gate.passed).map((gate) => gate.id);
    items.push({
      entityId: entity.entityId,
      displayName: entity.displayName,
      priority: entity.priority,
      reviewStatus: entity.reviewStatus,
      relationshipToCatch: entity.relationshipToCatch,
      taskType: entity.reviewStatus === "needs_more_evidence" ?
        "evidence_review" :
        "promotion_review",
      recommendedAction: blockers.length === 0 ?
        "Admin can review final copy and approve public indexed website listing." :
        "Resolve blockers before public promotion.",
      promotionPolicy: {
        adminApprovalPublishesWebsite: true,
        adminApprovalIndexesWebsite: entity.publicListingIntent?.indexOnAdminApproval === true,
        appVisibilityAfterPublicApproval: decision?.appVisibility ??
          entity.publicListingIntent?.appVisibilityOnAdminApproval ??
          "hidden",
      },
      reviewDecision: decision ? reviewDecisionSummary(decision) : null,
      canonicalPath: entity.publicListingIntent?.canonicalPath ?? null,
      legacyPaths: entity.publicListingIntent?.legacyPaths ?? [],
      markets: entity.geographicScope?.markets ?? [],
      surfaceSummary: surfaceSummary(entity.surfaces ?? []),
      surfaces: organizerSurfacesForAdmin(entity.surfaces ?? []),
      curation: curationByEntity.get(entity.entityId) ?? null,
      gates,
      blockers,
      reviewNotes: entity.reviewNotes ?? [],
    });
  }

  return {
    schemaVersion: 1,
    generatedFrom: {
      batches: batches.map((batch) => batch.file).sort(),
      curationDecisionBatches: curationDecisionBatches.map((batch) => batch.file).sort(),
      dedupeIndex: "tool/organizer_intake/generated/organizer_dedupe_index.json",
      reviewDecisionBatches: reviewDecisionBatches.map((batch) => batch.file).sort(),
    },
    summary: {
      total: items.length,
      promotionReview: items.filter((item) => item.taskType === "promotion_review").length,
      evidenceReview: items.filter((item) => item.taskType === "evidence_review").length,
      blocked: items.filter((item) => item.blockers.length > 0).length,
      readyForManualApproval: items.filter((item) => item.blockers.length === 0).length,
      approvedByDecision: items.filter((item) => item.reviewDecision?.decision === "approve_public").length,
    },
    items,
  };
}

function buildProjectionPlan(entityList, reviewQueue, decisions) {
  const reviewByEntity = new Map(reviewQueue.items.map((item) => [item.entityId, item]));
  const entries = [...entityList].sort((a, b) => a.entityId.localeCompare(b.entityId)).map((entity) => {
    const queueItem = reviewByEntity.get(entity.entityId) ?? null;
    const decision = decisions.get(entity.entityId) ?? null;
    const approvedPublic =
      decision?.decision === "approve_public" ||
      entity.reviewStatus === "approved_public" ||
      entity.reviewStatus === "published";
    const suppressed = decision?.decision === "suppress" || entity.reviewStatus === "suppressed";
    const indexStatus = approvedPublic && entity.publicListingIntent?.indexOnAdminApproval === true ?
      "indexed" :
      "noindex";
    const publishStatus = suppressed ? "suppressed" : approvedPublic ? "published" : "blocked";
    return {
      entityId: entity.entityId,
      displayName: entity.displayName,
      projectionStatus: suppressed ? "suppressed" : approvedPublic ? "ready" : "blocked",
      publishStatus,
      indexStatus,
      appVisibility: approvedPublic ?
        decision?.appVisibility ?? entity.publicListingIntent?.appVisibilityOnAdminApproval ?? "hidden" :
        "hidden",
      canonicalPath: entity.publicListingIntent?.canonicalPath ?? null,
      legacyPaths: entity.publicListingIntent?.legacyPaths ?? [],
      pageMode: entity.publicListingIntent?.pageMode ?? null,
      reviewDecision: decision ? reviewDecisionSummary(decision) : null,
      publicListing: approvedPublic ? publicListingProjection(entity) : null,
      blockedBy: approvedPublic ? [] : queueItem?.blockers ?? ["manual_admin_review_required"],
    };
  });
  return {
    schemaVersion: 1,
    generatedFrom: {
      batches: batches.map((batch) => batch.file).sort(),
      reviewQueue: "tool/organizer_intake/generated/admin_review_queue.json",
      reviewDecisionBatches: reviewDecisionBatches.map((batch) => batch.file).sort(),
    },
    summary: {
      entities: entries.length,
      approvedPublic: entries.filter((entry) => entry.projectionStatus === "ready").length,
      blocked: entries.filter((entry) => entry.projectionStatus !== "ready").length,
      appDiscoverable: entries.filter((entry) => entry.appVisibility === "discoverable").length,
    },
    guardrails: [
      "Do not import blocked projections into Firestore clubs.",
      "Public website approval and app discoverability are separate gates.",
      "Admin approval publishes and indexes website pages by default under organizer-intake-v1.",
      "Recurring event crawling remains disabled until a separate crawl policy review.",
    ],
    entries,
  };
}

function buildClaimTargetPlan(entityList, projectionPlan) {
  const entityById = new Map(entityList.map((entity) => [entity.entityId, entity]));
  const targets = projectionPlan.entries
    .filter((entry) =>
      entry.projectionStatus === "ready" &&
        entry.publishStatus === "published" &&
        entry.publicListing
    )
    .map((entry) => {
      const entity = entityById.get(entry.entityId);
      if (!entity) {
        errors.push(`Missing entity for claim target ${entry.entityId}`);
        return null;
      }
      const clubDocument = clubDocumentForClaimTarget(entity, entry);
      return {
        entityId: entry.entityId,
        clubId: entry.publicListing.id,
        path: `clubs/${entry.publicListing.id}`,
        writeMode: "create_or_refresh_unclaimed_public_fields",
        appVisibility: entry.appVisibility,
        claimState: "unclaimed",
        canonicalPath: entry.canonicalPath,
        legacyPaths: entry.legacyPaths,
        sourceHash: hashObject({
          entityId: entity.entityId,
          publicListing: entry.publicListing,
          appVisibility: entry.appVisibility,
          reviewDecision: entry.reviewDecision,
        }),
        clubDocument,
      };
    })
    .filter(Boolean)
    .sort((a, b) => a.entityId.localeCompare(b.entityId));

  return {
    schemaVersion: 1,
    generatedFrom: {
      projectionPlan: "tool/organizer_intake/generated/public_projection_plan.json",
      batches: batches.map((batch) => batch.file).sort(),
      reviewDecisionBatches: reviewDecisionBatches.map((batch) => batch.file).sort(),
    },
    summary: {
      targets: targets.length,
      hidden: targets.filter((target) => target.appVisibility === "hidden").length,
      discoverable: targets.filter((target) => target.appVisibility === "discoverable").length,
    },
    applyRequires: [
      "Export and review live admin decisions before generation.",
      "Run a dry-run Firestore sync before any remote write.",
      "Never overwrite claimed or owner-bound organizer club documents.",
    ],
    guardrails: [
      "Only approved public organizer projections become Firestore claim targets.",
      "Claim targets start unclaimed and app-hidden unless the review decision explicitly approved app discoverability.",
      "Claim approval, not public website publication, unlocks app discoverability by default.",
      "Existing claimed organizer documents must be skipped by the sync tool.",
    ],
    targets,
  };
}

function validateApprovedReviewDecisionsAgainstPublicationReadiness({
  curationState,
  dedupeIndex,
  entityList,
  externalEventCandidateQueue,
  rawArtifactStorageManifest,
  reviewDecisions,
  searchResultCandidateQueue,
}) {
  const approvedDecisions = [...reviewDecisions.values()]
    .filter((decision) => decision.decision === "approve_public");
  if (approvedDecisions.length === 0) return;

  const preApprovalDecisions = new Map(
    [...reviewDecisions.entries()].filter(([, decision]) =>
      decision.decision !== "approve_public"
    )
  );
  const preApprovalReviewQueue = buildReviewQueue(
    entityList,
    dedupeIndex,
    preApprovalDecisions,
    curationState
  );
  const preApprovalProjectionPlan = buildProjectionPlan(
    entityList,
    preApprovalReviewQueue,
    preApprovalDecisions
  );
  const preApprovalClaimTargetPlan = buildClaimTargetPlan(
    entityList,
    preApprovalProjectionPlan
  );
  const preApprovalCanonicalHostEntities = buildCanonicalHostEntityRegistry({
    claimTargetPlan: preApprovalClaimTargetPlan,
    curationState,
    dedupeIndex,
    entityList,
    projectionPlan: preApprovalProjectionPlan,
    reviewQueue: preApprovalReviewQueue,
  });
  const preApprovalCanonicalEvidenceIndex = buildCanonicalEvidenceIndex({
    canonicalHostEntities: preApprovalCanonicalHostEntities,
    curationState,
    externalEventCandidateQueue,
    rawArtifactStorageManifest,
    referencedArtifactFiles:
      collectEvidenceReferenceFiles(preApprovalCanonicalHostEntities),
    reviewQueue: preApprovalReviewQueue,
    searchResultCandidateQueue,
  });
  const preApprovalPublicationPackets = buildPublicationReviewPackets({
    canonicalEvidenceIndex: preApprovalCanonicalEvidenceIndex,
    canonicalHostEntities: preApprovalCanonicalHostEntities,
    claimTargetPlan: preApprovalClaimTargetPlan,
    entityList,
    projectionPlan: preApprovalProjectionPlan,
    reviewQueue: preApprovalReviewQueue,
  });
  const packetsByEntity = new Map(
    preApprovalPublicationPackets.packets.map((packet) => [
      packet.entityId,
      packet,
    ])
  );

  for (const decision of approvedDecisions) {
    const packet = packetsByEntity.get(decision.entityId);
    if (!packet) {
      errors.push(
        `${decision.sourceFile}: approve_public for ${decision.entityId} ` +
          "has no pre-approval publication packet."
      );
      continue;
    }
    const readiness = publicationPacketApprovalReadiness(packet);
    if (!readiness.ready) {
      errors.push(
        `${decision.sourceFile}: approve_public for ${decision.entityId} ` +
          "does not match a ready pre-approval publication packet: " +
          readiness.blockers.join(", ")
      );
    }
    const manualReports =
      packet.evidenceSummary?.manualReportsWithoutArtifacts ?? 0;
    if (manualReports > 0 &&
      decision.checklist?.manualReportsReviewed !== true) {
      errors.push(
        `${decision.sourceFile}: approve_public for ${decision.entityId} ` +
          "requires checklist:manualReportsReviewed because " +
          `${packet.packetId} has ${manualReports} manual report(s) ` +
          "without artifacts."
      );
    }
  }
}

function buildPublicationDecisionImpactPreview({
  entityList,
  publicationReviewPackets,
  reviewDecisions,
  reviewQueue,
}) {
  const entries = (publicationReviewPackets.packets ?? [])
    .map((packet) => {
      const readiness = publicationPacketApprovalReadiness(packet);
      if (!readiness.ready) {
        return blockedPublicationImpactPreview(packet, readiness);
      }

      const simulatedDecisions = new Map(reviewDecisions);
      const approvalChecklist = publicationApprovalChecklistForPacket(packet);
      simulatedDecisions.set(packet.entityId, {
        appVisibility: "hidden",
        checklist: approvalChecklist,
        decidedAt: "YYYY-MM-DD",
        decision: "approve_public",
        decisionBatchId: "impact-preview-only",
        entityId: packet.entityId,
        note: "Impact preview only; no review decision has been recorded.",
        reviewer: "impact-preview",
      });
      const simulatedProjectionPlan = buildProjectionPlan(
        entityList,
        reviewQueue,
        simulatedDecisions
      );
      const simulatedProjection = simulatedProjectionPlan.entries.find((entry) =>
        entry.entityId === packet.entityId
      );
      const simulatedClaimTargetPlan = buildClaimTargetPlan(
        entityList,
        simulatedProjectionPlan
      );
      const simulatedClaimTarget = simulatedClaimTargetPlan.targets.find((target) =>
        target.entityId === packet.entityId
      );
      const publicListing = simulatedProjection?.publicListing ?? null;

      return {
        impactId: `publication-impact-${packet.entityId}`,
        packetId: packet.packetId,
        entityId: packet.entityId,
        displayName: packet.displayName,
        status: "would_publish_after_admin_approval",
        decisionRequired: {
          decision: "approve_public",
          appVisibility: "hidden",
          checklist: approvalChecklist,
          command: packet.adminDecision.command,
        },
        preconditions: {
          packetStatus: packet.status,
          dataBlockers: packet.dataBlockers,
          evidenceBlockers: packet.evidenceBlockers,
          manualReportsWithoutArtifacts:
            packet.evidenceSummary.manualReportsWithoutArtifacts,
          reviewerAcknowledgementRequired:
            packet.evidenceSummary.manualReportsWithoutArtifacts > 0,
        },
        publicProjection: {
          wouldPublish: simulatedProjection?.publishStatus === "published",
          wouldIndex: simulatedProjection?.indexStatus === "indexed",
          projectionStatus: simulatedProjection?.projectionStatus ?? "blocked",
          publishStatus: simulatedProjection?.publishStatus ?? "blocked",
          indexStatus: simulatedProjection?.indexStatus ?? "noindex",
          canonicalPath: simulatedProjection?.canonicalPath ?? null,
          legacyPaths: simulatedProjection?.legacyPaths ?? [],
          pageMode: simulatedProjection?.pageMode ?? null,
          listingId: publicListing?.id ?? null,
          listingName: publicListing?.name ?? null,
          listingVariant: publicListing ? "unclaimedScraped" : null,
          dataOrigin: publicListing ? "organizerIntake" : null,
          indexing: publicListing?.indexing ?? "noindex, follow",
          sourceCount: publicListing?.sources?.length ?? 0,
          missingEvidence: publicListing?.missingEvidence ?? [],
        },
        claimTarget: simulatedClaimTarget ? {
          wouldCreateOrRefresh: true,
          path: simulatedClaimTarget.path,
          writeMode: simulatedClaimTarget.writeMode,
          appVisibility: simulatedClaimTarget.appVisibility,
          claimState: simulatedClaimTarget.claimState,
          sourceHash: simulatedClaimTarget.sourceHash,
        } : {
          wouldCreateOrRefresh: false,
          path: null,
          writeMode: null,
          appVisibility: "hidden",
          claimState: "not_created",
          sourceHash: null,
        },
        app: {
          appVisibility: simulatedProjection?.appVisibility ?? "hidden",
          wouldBeDiscoverable:
            simulatedProjection?.appVisibility === "discoverable",
        },
        remoteEffects: {
          writesDuringPreview: 0,
          writesDuringDecisionExport: 0,
          claimSyncRequired: Boolean(simulatedClaimTarget),
          claimSyncTargetPath: simulatedClaimTarget?.path ?? null,
          websiteGenerationRequired: true,
          sitemapEligible: simulatedProjection?.indexStatus === "indexed",
        },
        commands: [
          packet.adminDecision.command,
          "node tool/organizer_intake/organizer_intake.mjs",
          "npm --workspace catch-marketing run generate:organizer-listings",
          "node tool/organizer_intake/check_promotion_bridge.mjs",
          "node tool/organizer_intake/sync_claim_targets_to_firestore.mjs --check",
        ],
      };
    })
    .sort((a, b) =>
      impactRank(a) - impactRank(b) ||
      a.entityId.localeCompare(b.entityId)
    );

  return {
    schemaVersion: 1,
    generatedFrom: {
      publicationReviewPackets:
        "tool/organizer_intake/generated/publication_review_packets.json",
      reviewQueue: "tool/organizer_intake/generated/admin_review_queue.json",
      projectionPlan: "tool/organizer_intake/generated/public_projection_plan.json",
      claimTargetPlan:
        "tool/organizer_intake/generated/organizer_claim_targets.json",
    },
    summary: {
      impacts: entries.length,
      wouldPublish: entries.filter((entry) =>
        entry.publicProjection?.wouldPublish === true).length,
      wouldIndex: entries.filter((entry) =>
        entry.publicProjection?.wouldIndex === true).length,
      wouldCreateClaimTargets: entries.filter((entry) =>
        entry.claimTarget?.wouldCreateOrRefresh === true).length,
      wouldBeAppDiscoverable: entries.filter((entry) =>
        entry.app?.wouldBeDiscoverable === true).length,
      blocked: entries.filter((entry) => entry.status === "blocked").length,
      reviewerAcknowledgementsRequired: entries.filter((entry) =>
        entry.preconditions?.reviewerAcknowledgementRequired === true).length,
      byStatus: countBy(entries, "status"),
    },
    guardrails: [
      "Impact previews do not record decisions, write Firestore, publish pages, update sitemaps, or sync claim targets.",
      "Only the explicit admin approve_public decision can publish and index a website projection.",
      "Claim-target Firestore writes still require a separate reviewed dry run and --write.",
      "App discoverability remains hidden in this preview unless a separate app-visibility approval is added.",
    ],
    entries,
  };
}

function blockedPublicationImpactPreview(packet, readiness) {
  return {
    impactId: `publication-impact-${packet.entityId}`,
    packetId: packet.packetId,
    entityId: packet.entityId,
    displayName: packet.displayName,
    status: "blocked",
    decisionRequired: {
      decision: "approve_public",
      appVisibility: "hidden",
      checklist: publicationApprovalChecklistForPacket(packet),
      command: packet.adminDecision.command,
    },
    preconditions: {
      packetStatus: packet.status,
      dataBlockers: packet.dataBlockers ?? [],
      evidenceBlockers: packet.evidenceBlockers ?? [],
      manualReportsWithoutArtifacts:
        packet.evidenceSummary?.manualReportsWithoutArtifacts ?? 0,
      reviewerAcknowledgementRequired:
        (packet.evidenceSummary?.manualReportsWithoutArtifacts ?? 0) > 0,
      blockers: readiness.blockers,
    },
    publicProjection: {
      wouldPublish: false,
      wouldIndex: false,
      projectionStatus: "blocked",
      publishStatus: "blocked",
      indexStatus: "noindex",
      canonicalPath: packet.publicPresence?.canonicalPath ?? null,
      legacyPaths: packet.publicPresence?.legacyPaths ?? [],
      pageMode: null,
      listingId: null,
      listingName: null,
      listingVariant: null,
      dataOrigin: null,
      indexing: "noindex, follow",
      sourceCount: packet.evidenceSummary?.records ?? 0,
      missingEvidence: packet.publicDraft?.missingEvidence ?? [],
    },
    claimTarget: {
      wouldCreateOrRefresh: false,
      path: null,
      writeMode: null,
      appVisibility: "hidden",
      claimState: "not_created",
      sourceHash: null,
    },
    app: {
      appVisibility: "hidden",
      wouldBeDiscoverable: false,
    },
    remoteEffects: {
      writesDuringPreview: 0,
      writesDuringDecisionExport: 0,
      claimSyncRequired: false,
      claimSyncTargetPath: null,
      websiteGenerationRequired: false,
      sitemapEligible: false,
    },
    commands: [],
  };
}

function publicationPacketApprovalReadiness(packet) {
  const blockers = [];
  if (packet.status !== "ready_for_manual_publication_review") {
    blockers.push(`packet_status:${packet.status}`);
  }
  for (const blocker of packet.dataBlockers ?? []) {
    blockers.push(`data:${blocker}`);
  }
  for (const blocker of packet.evidenceBlockers ?? []) {
    blockers.push(`evidence:${blocker}`);
  }
  const checklist = packet.approvalChecklist ?? {};
  for (const [key, value] of Object.entries(checklist)) {
    if (value !== true) blockers.push(`checklist:${key}`);
  }
  return {
    ready: blockers.length === 0,
    blockers,
  };
}

function publicationApprovalChecklistForPacket(packet) {
  const manualReports =
    packet.evidenceSummary?.manualReportsWithoutArtifacts ?? 0;
  return {
    ...packet.approvalChecklist,
    ...(manualReports > 0 ? {manualReportsReviewed: true} : {}),
  };
}

function impactRank(entry) {
  return {
    would_publish_after_admin_approval: 0,
    blocked: 1,
  }[entry.status] ?? 9;
}

function buildEventCrawlPlan(entityList, curationState) {
  const entries = entityList
    .flatMap((entity) => (entity.surfaces ?? [])
      .filter((surface) => surface.crawl?.supportsEventExtraction === true)
      .map((surface) => eventCrawlPlanEntry(entity, surface)))
    .sort((a, b) =>
      a.entityId.localeCompare(b.entityId) ||
      a.platform.localeCompare(b.platform) ||
      String(a.normalizedKey ?? a.surfaceId).localeCompare(String(b.normalizedKey ?? b.surfaceId))
    );

  return {
    schemaVersion: 1,
    generatedFrom: {
      batches: batches.map((batch) => batch.file).sort(),
      curationDecisionBatches: curationState.generatedFrom.curationDecisionBatches,
      policy: "organizer-event-crawl-v0-disabled",
    },
    policy: {
      status: "disabled",
      schedulerEnabled: false,
      defaultSurfacePolicy: "manualOnly",
      reason:
        "Recurring event crawling is modeled for future support but remains disabled " +
        "until cost, provider policy, rate limits, and owner-safety rules are approved.",
    },
    summary: {
      entities: entityList.length,
      crawlCapableSurfaces: entries.length,
      approvedSurfaces: entries.filter((entry) => entry.readiness === "approved").length,
      blockedSurfaces: entries.filter((entry) => entry.readiness !== "approved").length,
      platforms: countBy(entries, "platform"),
      blockers: countCrawlBlockers(entries),
    },
    guardrails: [
      "No scheduled event crawling is enabled by this artifact.",
      "Manual-only surfaces require explicit policy approval before any recurring fetch.",
      "Rejected, ambiguous, historical, or URL-missing surfaces stay blocked.",
      "Organizer publication, app discoverability, claim approval, and crawl approval are separate gates.",
    ],
    entries,
  };
}

function eventCrawlPlanEntry(entity, surface) {
  const blockedBy = ["global_recurring_crawl_disabled"];
  if (surface.status !== "active") blockedBy.push("surface_not_active");
  if (!surface.url) blockedBy.push("surface_url_missing");
  if (surface.crawl?.eventDiscoveryStatus !== "approved") {
    blockedBy.push("surface_crawl_status_not_approved");
  }
  if (surface.crawl?.policy !== "apiPreferred") {
    blockedBy.push("surface_crawl_policy_not_api_preferred");
  }
  if (!["approved_public", "published", "claimed"].includes(entity.reviewStatus)) {
    blockedBy.push("organizer_not_public_approved");
  }
  if (entity.relationshipToCatch?.state === "claimed" && surface.status !== "active") {
    blockedBy.push("claimed_organizer_surface_needs_owner_review");
  }

  return {
    entityId: entity.entityId,
    displayName: entity.displayName,
    entityKind: entity.entityKind,
    reviewStatus: entity.reviewStatus,
    relationshipState: entity.relationshipToCatch?.state ?? null,
    markets: (entity.markets ?? []).map((market) => ({
      marketSlug: market.marketSlug,
      displayName: market.displayName,
      countryCode: market.countryCode,
    })),
    surfaceId: surface.surfaceId,
    platform: surface.platform,
    surfaceKind: surface.surfaceKind,
    role: surface.role,
    status: surface.status,
    url: surface.url ?? null,
    normalizedKey: surface.normalizedKey ?? null,
    crawl: surface.crawl,
    readiness: blockedBy.length === 0 ? "approved" : "blocked",
    blockedBy,
    nextGate: "crawl_policy_review",
  };
}

function countCrawlBlockers(entries) {
  const counts = {};
  for (const entry of entries) {
    for (const blocker of entry.blockedBy ?? []) {
      counts[blocker] = (counts[blocker] ?? 0) + 1;
    }
  }
  return Object.fromEntries(Object.entries(counts).sort(([a], [b]) => a.localeCompare(b)));
}

function buildWorkflowReadinessReport({
  canonicalEvidenceIndex,
  canonicalHostEntities,
  claimTargetPlan,
  claimTargetSyncPreview,
  curationState,
  eventCrawlPlan,
  eventCrawlRunPlan,
  externalEventCandidateQueue,
  externalEventLocationResolutionQueue,
  externalEventImportExecutionPlan,
  externalEventImportPlan,
  publicationReviewPackets,
  policyDecisionPackets,
  projectionPlan,
  rawArtifactStorageManifest,
  reviewQueue,
  searchResultCandidateQueue,
}) {
  const eventCandidates = externalEventCandidateQueue.summary.candidates;
  const reviewedEventCandidates =
    externalEventCandidateQueue.summary.reviewed ?? 0;
  const unreviewedEventCandidates = Math.max(
    0,
    eventCandidates - reviewedEventCandidates
  );
  const approvedEventCandidates =
    externalEventCandidateQueue.summary.approvedForImport ?? 0;
  const gates = [
    readinessGate({
      id: "canonical_host_registry",
      label: "Canonical host registry",
      status: canonicalHostEntities.summary.entities > 0 ? "ready" : "blocked",
      detail:
        `${canonicalHostEntities.summary.entities} canonical host entity record(s), ` +
        `${canonicalHostEntities.summary.publicPublished} public, ` +
        `${canonicalHostEntities.summary.claimTargets} claim target(s).`,
      nextAction:
        "Use canonicalHostId as the durable organizer identity before projecting into public pages, legacy clubs, crawls, or event imports.",
    }),
    readinessGate({
      id: "canonical_evidence_index",
      label: "Canonical evidence index",
      status:
        canonicalEvidenceIndex.summary.unresolvedLocalRefs > 0 ||
          canonicalEvidenceIndex.summary.surfacesWithoutEvidence > 0 ?
          "review_needed" :
          "ready",
      detail:
        `${canonicalEvidenceIndex.summary.records} evidence record(s), ` +
        `${canonicalEvidenceIndex.summary.resolvedArtifactRefs} resolved artifact ref(s), ` +
        `${canonicalEvidenceIndex.summary.surfacesWithoutEvidence} surface(s) missing evidence.`,
      nextAction:
        canonicalEvidenceIndex.summary.unresolvedLocalRefs > 0 ||
          canonicalEvidenceIndex.summary.surfacesWithoutEvidence > 0 ?
          "Attach or correct reviewed evidence refs before using affected surfaces for publication, crawls, or event imports." :
        "Use evidence record ids as provenance for publication review, crawl planning, and event import planning.",
    }),
    readinessGate({
      id: "publication_review_packets",
      label: "Publication review packets",
      status:
        publicationReviewPackets.summary.blockedByData > 0 ?
          "blocked" :
          publicationReviewPackets.summary.readyForManualPublicationReview > 0 ?
            "review_needed" :
            "ready",
      detail:
        `${publicationReviewPackets.summary.packets} publication packet(s), ` +
        `${publicationReviewPackets.summary.readyForManualPublicationReview} ready for manual review, ` +
        `${publicationReviewPackets.summary.blockedByData} blocked by data.`,
      nextAction:
        publicationReviewPackets.summary.blockedByData > 0 ?
          "Resolve packet data blockers before recording publication approval." :
          publicationReviewPackets.summary.readyForManualPublicationReview > 0 ?
            "Review the publication packet and record approve, hold, or suppress through the admin bridge." :
            "Keep publication packets regenerated after curation or evidence changes.",
    }),
    readinessGate({
      id: "search_capture_ingestion",
      label: "Search capture ingestion",
      status: searchResultCandidateQueue.summary.candidates > 0 ?
        "review_needed" :
        "ready",
      detail:
        `${searchResultCandidateQueue.summary.candidates} captured surface candidate(s), ` +
        `${searchResultCandidateQueue.summary.matchedExistingEntities} matched existing entities.`,
      nextAction: searchResultCandidateQueue.summary.candidates > 0 ?
        "Review captured surface candidates and attach, reject, split, or leave them as supporting evidence." :
        "Capture provider search payloads when a new planned search run is reviewed.",
    }),
    readinessGate({
      id: "raw_artifact_storage",
      label: "Raw artifact storage",
      status: rawArtifactStorageManifest.summary.retentionDecisionRequired > 0 ?
        "policy_needed" :
        "ready",
      detail:
        `${rawArtifactStorageManifest.summary.rawProviderPayloads} raw provider payload(s), ` +
        `${rawArtifactStorageManifest.summary.remoteUploadBlocked} remote upload blocked, ` +
        `${rawArtifactStorageManifest.summary.totalBytes} byte(s) inventoried.`,
      nextAction: rawArtifactStorageManifest.summary.retentionDecisionRequired > 0 ?
        "Choose object-storage bucket, retention days, and deletion policy before recurring crawls upload raw payloads." :
        "Keep raw payloads out of Firestore; object-storage upload remains a separate policy-controlled step.",
    }),
    readinessGate({
      id: "policy_decision_packets",
      label: "Policy decision packets",
      status: policyDecisionPackets.summary.unansweredQuestions > 0 ?
        "policy_needed" :
        "ready",
      detail:
        `${policyDecisionPackets.summary.packets} policy packet(s), ` +
        `${policyDecisionPackets.summary.questions} question(s), ` +
        `${policyDecisionPackets.summary.unansweredQuestions} still need input.`,
      nextAction: policyDecisionPackets.summary.unansweredQuestions > 0 ?
        "Answer or hold the policy decision packets before enabling crawls, provider lookups, imports, storage, or naming migration." :
        "Keep encoded implementation gates checked before enabling behavior.",
    }),
    readinessGate({
      id: "external_event_candidates",
      label: "External event candidates",
      status: unreviewedEventCandidates > 0 ?
        "review_needed" :
        approvedEventCandidates > 0 ? "policy_needed" : "ready",
      detail:
        `${eventCandidates} external event candidate(s), ` +
        `${reviewedEventCandidates} reviewed, ` +
        `${externalEventCandidateQueue.summary.blocked} blocked by import policy.`,
      nextAction: unreviewedEventCandidates > 0 ?
        "Review external event candidates for dedupe and import safety; do not write events until import policy is approved." :
        approvedEventCandidates > 0 ?
          "Event candidates are manually approved for future import, but import writes remain disabled by product policy." :
        "Capture reviewed provider event payloads when event import testing is needed.",
    }),
    readinessGate({
      id: "external_event_location_resolution",
      label: "External event location resolution",
      status: externalEventLocationResolutionQueue.summary.tasks > 0 ?
        "blocked" :
        "ready",
      detail:
        `${externalEventLocationResolutionQueue.summary.tasks} location task(s), ` +
        `${externalEventLocationResolutionQueue.summary.missingExactCoordinates} missing exact coordinate(s).`,
      nextAction: externalEventLocationResolutionQueue.summary.tasks > 0 ?
        "Resolve exact coordinates through manual review or an approved Places provider before event import writes are possible." :
        "Run the location queue after each event-source ingestion.",
    }),
    readinessGate({
      id: "external_event_import_plan",
      label: "External event import plan",
      status: externalEventImportPlan.summary.writeReady > 0 ?
        "policy_needed" :
        externalEventImportPlan.summary.blocked > 0 ||
          externalEventImportPlan.summary.waitingReview > 0 ?
          "review_needed" :
          "ready",
      detail:
        `${externalEventImportPlan.summary.proposedReadOnlyEvents ?? externalEventImportPlan.summary.proposedCreates} proposed read-only event(s), ` +
        `${externalEventImportPlan.summary.blocked} blocked, ` +
        `${externalEventImportPlan.summary.writeReady} write-ready.`,
      nextAction: externalEventImportPlan.summary.writeReady > 0 ?
        "External read-only event writes are planned but require explicit import policy approval." :
        (externalEventImportPlan.summary.proposedReadOnlyEvents ??
          externalEventImportPlan.summary.proposedCreates) > 0 ?
          "Review import blockers for approved event candidates before enabling writes." :
          "Review event candidates before planning any external read-only event writes.",
    }),
    readinessGate({
      id: "external_event_import_execution_preflight",
      label: "External event import execution preflight",
      status: (externalEventImportExecutionPlan.summary.wouldPublishReadOnly ??
        externalEventImportExecutionPlan.summary.wouldCreate) > 0 ?
        "policy_needed" :
        (externalEventImportExecutionPlan.summary.projectionInvalid ??
          externalEventImportExecutionPlan.summary.schemaInvalid) > 0 ?
          "blocked" :
          externalEventImportExecutionPlan.summary.blocked > 0 ?
            "policy_needed" :
            "ready",
      detail:
        `${externalEventImportExecutionPlan.summary.readOnlyActions ?? externalEventImportExecutionPlan.summary.createActions} read-only action(s), ` +
        `${externalEventImportExecutionPlan.summary.projectionInvalidCount ?? externalEventImportExecutionPlan.summary.payloadInvalid} invalid projection(s), ` +
        `${externalEventImportExecutionPlan.summary.wouldPublishReadOnly ?? externalEventImportExecutionPlan.summary.wouldCreate} would publish.`,
      nextAction: (externalEventImportExecutionPlan.summary.projectionInvalid ??
        externalEventImportExecutionPlan.summary.schemaInvalid) > 0 ?
        "Resolve projection blockers until every approved candidate validates as a read-only external event with outbound links only." :
        externalEventImportExecutionPlan.summary.blocked > 0 ?
          "Approve import authority, owner model, and execution policy before enabling any read-only external event writes." :
          "Run preflight after each import-plan regeneration; keep writes disabled until policy is approved.",
    }),
    readinessGate({
      id: "dedupe_curation",
      label: "Dedupe curation",
      status: "ready",
      detail:
        `${curationState.summary.operations} curation operation(s), ` +
        `${curationState.summary.merges} merge(s), ` +
        `${curationState.summary.surfaceDecisions} surface decision(s).`,
      nextAction:
        "Continue using curation decisions for merges, wrong-entity surfaces, suppressions, and splits before approval.",
    }),
    readinessGate({
      id: "admin_review",
      label: "Manual admin review",
      status: reviewQueue.summary.readyForManualApproval > 0 ?
        "ready" :
        reviewQueue.summary.total > 0 ? "blocked" : "ready",
      detail:
        `${reviewQueue.summary.total} private entity review item(s), ` +
        `${reviewQueue.summary.readyForManualApproval} ready for approval, ` +
        `${reviewQueue.summary.blocked} blocked.`,
      nextAction:
        "An admin decision is required before any private intake entity becomes public or indexable.",
    }),
    readinessGate({
      id: "public_projection",
      label: "Public projection",
      status: projectionPlan.summary.approvedPublic > 0 ? "ready" : "waiting",
      detail:
        `${projectionPlan.summary.approvedPublic} approved public projection(s), ` +
        `${projectionPlan.summary.blocked} blocked projection(s).`,
      nextAction:
        "Export admin review decisions, regenerate intake artifacts, regenerate website listings, then run the promotion bridge check.",
    }),
    readinessGate({
      id: "claim_target_sync",
      label: "Claim target sync",
      status: claimTargetPlan.summary.targets > 0 ? "ready" : "waiting",
      detail:
        `${claimTargetPlan.summary.targets} claim target(s), ` +
        `${claimTargetSyncPreview.summary.writesNeeded} write(s) needed in the local preview, ` +
        `${claimTargetSyncPreview.summary.skippedOwnerBound} owner-bound skip(s).`,
      nextAction:
        "Review the generated claim-target sync preview, then run a Firestore dry run before any write.",
    }),
    readinessGate({
      id: "event_crawl_policy",
      label: "Recurring event crawl policy",
      status: "policy_needed",
      detail:
        `${eventCrawlPlan.summary.crawlCapableSurfaces} crawl-capable surface(s), ` +
        `${eventCrawlPlan.summary.approvedSurfaces} approved for recurring crawl.`,
      nextAction:
        "Choose provider order, frequency, budget cap, API-vs-scrape fallback, and owner-safety rules before enabling recurring crawls.",
    }),
    readinessGate({
      id: "event_crawl_run_plan",
      label: "Recurring event crawl run plan",
      status: eventCrawlRunPlan.summary.wouldFetch > 0 ?
        "policy_needed" :
        "ready",
      detail:
        `${eventCrawlRunPlan.summary.candidateSurfaces} run intent(s), ` +
        `${eventCrawlRunPlan.summary.blocked} blocked, ` +
        `${eventCrawlRunPlan.summary.wouldFetch} would fetch.`,
      nextAction:
        eventCrawlRunPlan.summary.wouldFetch > 0 ?
          "Review crawl run intents, then keep provider fetches disabled until crawl policy is approved." :
          "Regenerate the crawl run plan after organizer approval or crawl policy changes.",
    }),
    readinessGate({
      id: "curation_persistence_policy",
      label: "Curation persistence",
      status: "ready",
      detail:
        "Low-volume curation operations can be recorded through the admin callable and exported into reviewed repo-backed JSON.",
      nextAction:
        "Export live curation decisions before projection, then review the generated curation batch in git.",
    }),
    readinessGate({
      id: "naming_migration_policy",
      label: "Naming migration",
      status: "policy_needed",
      detail:
        "Host is the public entity label, OrganizerEntity remains the private intake model, and Club remains the app/backend compatibility projection.",
      nextAction:
        "Confirm the public Host label, operator account label, URL policy, and legacy Club migration order before broader UI/schema renames.",
    }),
  ];
  const summary = {
    gates: gates.length,
    ready: gates.filter((gate) => gate.status === "ready").length,
    waiting: gates.filter((gate) => gate.status === "waiting").length,
    reviewNeeded: gates.filter((gate) => gate.status === "review_needed").length,
    blocked: gates.filter((gate) => gate.status === "blocked").length,
    policyNeeded: gates.filter((gate) => gate.status === "policy_needed").length,
  };
  return {
    schemaVersion: 1,
    generatedFrom: {
      adminReviewQueue: "tool/organizer_intake/generated/admin_review_queue.json",
      canonicalEvidenceIndex:
        "tool/organizer_intake/generated/canonical_evidence_index.json",
      canonicalHostEntities:
        "tool/organizer_intake/generated/canonical_host_entities.json",
      curationState: "tool/organizer_intake/generated/organizer_curation_state.json",
      eventCrawlPlan: "tool/organizer_intake/generated/event_crawl_plan.json",
      eventCrawlRunPlan:
        "tool/organizer_intake/generated/event_crawl_run_plan.json",
      externalEventCandidateQueue:
        "tool/organizer_intake/generated/external_event_candidate_queue.json",
      externalEventLocationResolutionQueue:
        "tool/organizer_intake/generated/external_event_location_resolution_queue.json",
      externalEventImportPlan:
        "tool/organizer_intake/generated/external_event_import_plan.json",
      externalEventImportExecutionPlan:
        "tool/organizer_intake/generated/external_event_import_execution_plan.json",
      projectionPlan: "tool/organizer_intake/generated/public_projection_plan.json",
      claimTargetPlan: "tool/organizer_intake/generated/organizer_claim_targets.json",
      claimTargetSyncPreview:
        "tool/organizer_intake/generated/organizer_claim_target_sync_preview.json",
      rawArtifactStorageManifest:
        "tool/organizer_intake/generated/raw_artifact_storage_manifest.json",
      policyDecisionPackets:
        "tool/organizer_intake/generated/organizer_policy_decision_packets.json",
      publicationReviewPackets:
        "tool/organizer_intake/generated/publication_review_packets.json",
      searchResultCandidateQueue:
        "tool/organizer_intake/generated/search_result_candidate_queue.json",
    },
    summary: {
      ...summary,
      localPromotionPipelineReady: true,
      canonicalEvidenceRecords: canonicalEvidenceIndex.summary.records,
      canonicalEvidenceResolvedRefs:
        canonicalEvidenceIndex.summary.resolvedArtifactRefs,
      canonicalEvidenceSurfacesWithoutEvidence:
        canonicalEvidenceIndex.summary.surfacesWithoutEvidence,
      canonicalEvidenceManualReportsWithoutArtifacts:
        canonicalEvidenceIndex.summary.manualReportsWithoutArtifacts,
      publicationReviewPackets: publicationReviewPackets.summary.packets,
      publicationReviewReady:
        publicationReviewPackets.summary.readyForManualPublicationReview,
      publicationReviewBlockedByData:
        publicationReviewPackets.summary.blockedByData,
      canonicalHostEntities: canonicalHostEntities.summary.entities,
      canonicalHostPublicPublished:
        canonicalHostEntities.summary.publicPublished,
      canonicalHostClaimTargets:
        canonicalHostEntities.summary.claimTargets,
      claimTargetSyncPreviewWrites:
        claimTargetSyncPreview.summary.writesNeeded,
      claimTargetSyncPreviewCreates:
        claimTargetSyncPreview.summary.creates,
      claimTargetSyncPreviewRefreshes:
        claimTargetSyncPreview.summary.refreshes,
      claimTargetSyncPreviewSkippedOwnerBound:
        claimTargetSyncPreview.summary.skippedOwnerBound,
      publicProjectionReady: projectionPlan.summary.approvedPublic > 0,
      claimSyncReady: claimTargetPlan.summary.targets > 0,
      recurringCrawlEnabled: eventCrawlPlan.policy.schedulerEnabled === true,
      crawlRunIntents: eventCrawlRunPlan.summary.candidateSurfaces,
      rawArtifacts: rawArtifactStorageManifest.summary.artifacts,
      rawProviderPayloads:
        rawArtifactStorageManifest.summary.rawProviderPayloads,
      rawArtifactStorageBlocked:
        rawArtifactStorageManifest.summary.remoteUploadBlocked,
      policyDecisionPackets: policyDecisionPackets.summary.packets,
      policyDecisionQuestions: policyDecisionPackets.summary.questions,
      policyDecisionUnanswered:
        policyDecisionPackets.summary.unansweredQuestions,
    },
    status: workflowReadinessStatus(summary, projectionPlan, claimTargetPlan),
    gates,
    commands: {
      localPromotionPreview: "node tool/organizer_intake/run_promotion_pipeline.mjs",
      exportCurationDecisions:
        "node tool/organizer_intake/run_promotion_pipeline.mjs " +
        "--export-curation-decisions --date YYYY-MM-DD --write-export",
      exportReviewDecisions:
        "node tool/organizer_intake/run_promotion_pipeline.mjs " +
        "--export-review-decisions --date YYYY-MM-DD --write-export",
      exportEventReviewDecisions:
        "node tool/organizer_intake/run_promotion_pipeline.mjs " +
        "--export-event-review-decisions --date YYYY-MM-DD --write-export",
      exportEventLocationResolutions:
        "node tool/organizer_intake/run_promotion_pipeline.mjs " +
        "--export-event-location-resolutions --date YYYY-MM-DD --write-export",
      exportPolicyGapDecisions:
        "node tool/organizer_intake/run_promotion_pipeline.mjs " +
        "--export-policy-gap-decisions --date YYYY-MM-DD --write-export",
      planExternalEventImports:
        "node tool/organizer_intake/plan_external_event_imports.mjs",
      planExternalEventLocationResolution:
        "node tool/organizer_intake/plan_event_location_resolution.mjs",
      preflightExternalEventImports:
        "node tool/organizer_intake/preflight_external_event_imports.mjs",
      exportCurationAndReview:
        "node tool/organizer_intake/run_promotion_pipeline.mjs " +
        "--export-curation-decisions --export-review-decisions " +
        "--export-event-review-decisions " +
        "--export-event-location-resolutions " +
        "--export-policy-gap-decisions --date YYYY-MM-DD --write-export",
      reviewedClaimSync:
        "node tool/organizer_intake/run_promotion_pipeline.mjs " +
        "--claim-sync firestore --env ENV",
      writeClaimTargets:
        "node tool/organizer_intake/run_promotion_pipeline.mjs " +
        "--claim-sync firestore --env ENV --write-claim-targets",
    },
  };
}

function readinessGate({id, label, status, detail, nextAction}) {
  return {id, label, status, detail, nextAction};
}

function workflowReadinessStatus(summary, projectionPlan, claimTargetPlan) {
  if (summary.blocked > 0) return "blocked_by_admin_review";
  if (claimTargetPlan.summary.targets > 0) return "ready_for_claim_sync_review";
  if (projectionPlan.summary.approvedPublic > 0) return "ready_for_website_projection";
  if (summary.reviewNeeded > 0) return "ready_with_candidate_review";
  return "ready_waiting_for_admin_decisions";
}

function clubDocumentForClaimTarget(entity, entry) {
  const listing = entry.publicListing;
  const markets = listing.markets ?? [];
  const primaryMarket = markets[0] ?? null;
  const citySlug = primaryMarket?.marketSlug ?? entity.geographicScope?.primaryMarketSlug ?? "multi-city";
  const cityName = markets.length > 1 ?
    "Multiple cities" :
    primaryMarket?.displayName ?? "Multiple cities";
  const countryCode = primaryMarket?.countryCode ??
    entity.geographicScope?.countryCodes?.[0] ??
    null;
  const reviewedAt = timestampForDate(entry.reviewDecision?.decidedAt ?? entity.batchCreatedAt);
  const formats = uniqueStrings(listing.formats ?? []);
  const publicSources = (listing.sources ?? []).map((source) => ({
    type: source.type,
    label: source.label,
    detail: `${source.label} source for ${listing.name}`,
    href: source.href ?? null,
    confidence: source.confidence,
    lastCheckedAt: reviewedAt,
  }));

  return {
    name: listing.name,
    description: listing.description,
    location: citySlug,
    area: cityName,
    hostUserId: null,
    hostName: null,
    hostAvatarUrl: null,
    ownerUserId: null,
    hostUserIds: [],
    hostProfiles: [],
    createdAt: reviewedAt,
    imageUrl: null,
    profileImageUrl: null,
    tags: uniqueStrings([
      ...formats,
      displayEntityKind(entity.entityKind),
      cityName,
    ]).slice(0, 20),
    memberCount: 0,
    rating: 0,
    reviewCount: 0,
    verifiedReviewCount: 0,
    nextEventAt: null,
    nextEventLabel: null,
    instagramHandle: instagramHandleForSurfaces(entity.surfaces ?? []),
    phoneNumber: null,
    email: null,
    status: "active",
    archived: false,
    archivedAt: null,
    archiveReason: null,
    hostDefaults: hostDefaultsForEntity(entity),
    entityKind: clubEntityKind(entity.entityKind),
    entitySubtypes: uniqueStrings([entity.entityKind, ...(entity.aliases ?? []).slice(0, 6)]),
    displayCategory: displayEntityKind(entity.entityKind),
    cityName,
    regionName: null,
    countryCode,
    countryName: countryNameForCode(countryCode),
    appVisibility: entry.appVisibility,
    ownership: {
      state: "programmatic",
      ownerUserId: null,
      primaryHostUserId: null,
      hostUserIds: [],
      claimedAt: null,
      claimedByUid: null,
    },
    claim: {
      state: "unclaimed",
      claimHref: `${listing.path}#claim`,
      lastClaimRequestId: null,
    },
    publicPage: {
      slug: listing.slug,
      citySlug,
      canonicalPath: entry.canonicalPath,
      publishStatus: "published",
      indexStatus: entry.indexStatus === "indexed" ? "indexed" : "noindex",
      robots: listing.indexing,
      seoTitle: truncateText(`${listing.name} organizer profile | Catch`, 120),
      seoDescription: truncateText(listing.description, 320),
      lastRenderedAt: null,
    },
    provenance: {
      origin: "scraper",
      sourceConfidence: highestSourceConfidence(publicSources),
      verificationStatus: "sourceBacked",
      lastVerifiedAt: reviewedAt,
    },
    publicProfile: {
      headline: listing.headline,
      summary: listing.description,
      sourceSummary: listing.sourceSummary,
      formats,
      facts: [
        {label: markets.length > 1 ? "Markets" : "Market", value: markets.map((market) => market.displayName).join(", ") || cityName},
        {label: "Organizer type", value: displayEntityKind(entity.entityKind)},
        {label: "Claim state", value: "Unclaimed"},
      ],
      fitNotes: [
        "This organizer profile was promoted from public source evidence after manual admin review.",
        "Claiming unlocks owner-managed copy, official media, Catch events, and review tools.",
      ],
      missingEvidence: listing.missingEvidence ?? [],
      eventEvidence: [],
    },
    publicSources,
  };
}

function organizerSurfacesForAdmin(surfaces) {
  return surfaces.map((surface) => ({
    surfaceId: surface.surfaceId,
    platform: surface.platform,
    surfaceKind: surface.surfaceKind,
    url: surface.url ?? null,
    normalizedKey: surface.normalizedKey ?? null,
    role: surface.role,
    status: surface.status,
    crawl: surface.crawl,
    notes: surface.notes ?? "",
  })).sort((a, b) => a.surfaceId.localeCompare(b.surfaceId));
}

function buildAdminBridge(
  reviewQueue,
  projectionPlan,
  claimTargetPlan,
  claimTargetSyncPreview,
  eventCrawlPlan,
  eventCrawlRunPlan,
  workflowReadiness,
  canonicalHostEntities,
  canonicalEvidenceIndex,
  publicationReviewPackets,
  publicationDecisionImpactPreview,
  operatorActionQueue,
  operationalHealth,
  pendingInputRequest,
  pendingWorkCoverage,
  reviewedDecisionAnswerPackets,
  promotionExecutionPacket,
  policyGapRegister,
  policyDecisionPackets,
  curationState,
  searchResultCandidateQueue,
  externalEventCandidateQueue,
  externalEventLocationResolutionQueue,
  externalEventImportPlan,
  externalEventImportExecutionPlan,
  rawArtifactStorageManifest,
  sourceMentionResolution,
  sourceMentionLlmPromptQueue
) {
  return {
    schemaVersion: 1,
    generatedFrom: {
      curationState: "tool/organizer_intake/generated/organizer_curation_state.json",
      reviewQueue: "tool/organizer_intake/generated/admin_review_queue.json",
      canonicalEvidenceIndex:
        "tool/organizer_intake/generated/canonical_evidence_index.json",
      canonicalHostEntities:
        "tool/organizer_intake/generated/canonical_host_entities.json",
      publicationReviewPackets:
        "tool/organizer_intake/generated/publication_review_packets.json",
      publicationDecisionImpactPreview:
        "tool/organizer_intake/generated/publication_decision_impact_preview.json",
      operatorActionQueue:
        "tool/organizer_intake/generated/organizer_operator_action_queue.json",
      operationalHealth:
        "tool/organizer_intake/generated/organizer_operational_health.json",
      pendingInputRequest:
        "tool/organizer_intake/generated/organizer_pending_input_request.json",
      pendingWorkCoverage:
        "tool/organizer_intake/generated/organizer_pending_work_coverage.json",
      reviewedDecisionAnswerPackets:
        "tool/organizer_intake/generated/organizer_reviewed_decision_answer_packets.json",
      promotionExecutionPacket:
        "tool/organizer_intake/generated/organizer_promotion_execution_packet.json",
      projectionPlan: "tool/organizer_intake/generated/public_projection_plan.json",
      claimTargetPlan: "tool/organizer_intake/generated/organizer_claim_targets.json",
      claimTargetSyncPreview:
        "tool/organizer_intake/generated/organizer_claim_target_sync_preview.json",
      eventCrawlPlan: "tool/organizer_intake/generated/event_crawl_plan.json",
      eventCrawlRunPlan:
        "tool/organizer_intake/generated/event_crawl_run_plan.json",
      workflowReadiness: "tool/organizer_intake/generated/organizer_workflow_readiness.json",
      policyGapRegister:
        "tool/organizer_intake/generated/organizer_policy_gap_register.json",
      policyDecisionPackets:
        "tool/organizer_intake/generated/organizer_policy_decision_packets.json",
      searchResultCandidateQueue:
        "tool/organizer_intake/generated/search_result_candidate_queue.json",
      externalEventCandidateQueue:
        "tool/organizer_intake/generated/external_event_candidate_queue.json",
      externalEventLocationResolutionQueue:
        "tool/organizer_intake/generated/external_event_location_resolution_queue.json",
      externalEventImportPlan:
        "tool/organizer_intake/generated/external_event_import_plan.json",
      externalEventImportExecutionPlan:
        "tool/organizer_intake/generated/external_event_import_execution_plan.json",
      rawArtifactStorageManifest:
        "tool/organizer_intake/generated/raw_artifact_storage_manifest.json",
      sourceMentionResolutionPolicy:
        "tool/organizer_intake/generated/source_mention_resolution_policy.json",
      sourceMentionSourceArtifacts:
        "tool/organizer_intake/generated/source_mention_source_artifacts.json",
      sourceMentionExtractedMentions:
        "tool/organizer_intake/generated/source_mention_extracted_mentions.json",
      sourceMentionResolutionCandidates:
        "tool/organizer_intake/generated/source_mention_resolution_candidates.json",
      sourceMentionResolutionClusters:
        "tool/organizer_intake/generated/source_mention_resolution_clusters.json",
      sourceMentionResolutionReviewPackets:
        "tool/organizer_intake/generated/source_mention_resolution_review_packets.json",
      sourceMentionLlmPromptQueue:
        "tool/organizer_intake/generated/source_mention_llm_prompt_queue.json",
    },
    summary: {
      reviewItems: reviewQueue.summary.total,
      evidenceReview: reviewQueue.summary.evidenceReview,
      promotionReview: reviewQueue.summary.promotionReview,
      blocked: reviewQueue.summary.blocked,
      approvedPublic: projectionPlan.summary.approvedPublic,
      appDiscoverable: projectionPlan.summary.appDiscoverable,
      claimTargets: claimTargetPlan.summary.targets,
      claimTargetSyncPreviewWrites:
        claimTargetSyncPreview.summary.writesNeeded,
      claimTargetSyncPreviewCreates:
        claimTargetSyncPreview.summary.creates,
      claimTargetSyncPreviewRefreshes:
        claimTargetSyncPreview.summary.refreshes,
      claimTargetSyncPreviewSkippedOwnerBound:
        claimTargetSyncPreview.summary.skippedOwnerBound,
      canonicalHostEntities: canonicalHostEntities.summary.entities,
      canonicalHostPublicPublished:
        canonicalHostEntities.summary.publicPublished,
      canonicalHostIndexed: canonicalHostEntities.summary.indexed,
      canonicalHostClaimTargets:
        canonicalHostEntities.summary.claimTargets,
      canonicalHostSurfaces: canonicalHostEntities.summary.surfaces,
      canonicalHostCrawlCapableSurfaces:
        canonicalHostEntities.summary.crawlCapableSurfaces,
      canonicalEvidenceRecords: canonicalEvidenceIndex.summary.records,
      canonicalEvidenceResolvedRefs:
        canonicalEvidenceIndex.summary.resolvedArtifactRefs,
      canonicalEvidenceSurfacesWithoutEvidence:
        canonicalEvidenceIndex.summary.surfacesWithoutEvidence,
      canonicalEvidenceManualReportsWithoutArtifacts:
        canonicalEvidenceIndex.summary.manualReportsWithoutArtifacts,
      canonicalEvidenceRawProviderArtifacts:
        canonicalEvidenceIndex.summary.rawProviderArtifacts,
      publicationReviewPackets: publicationReviewPackets.summary.packets,
      publicationReviewReady:
        publicationReviewPackets.summary.readyForManualPublicationReview,
      publicationReviewBlockedByData:
        publicationReviewPackets.summary.blockedByData,
      publicationImpacts:
        publicationDecisionImpactPreview.summary.impacts,
      publicationImpactWouldPublish:
        publicationDecisionImpactPreview.summary.wouldPublish,
      publicationImpactWouldIndex:
        publicationDecisionImpactPreview.summary.wouldIndex,
      publicationImpactClaimTargets:
        publicationDecisionImpactPreview.summary.wouldCreateClaimTargets,
      publicationImpactAppDiscoverable:
        publicationDecisionImpactPreview.summary.wouldBeAppDiscoverable,
      operatorActions: operatorActionQueue.summary.actions,
      operatorAdminDecisionsRequired:
        operatorActionQueue.summary.adminDecisionsRequired,
      operatorPolicyInputsRequired:
        operatorActionQueue.summary.policyInputsRequired,
      operatorWaitingActions:
        operatorActionQueue.summary.waitingActions,
      operationalHealthStatus:
        operationalHealth.summary.healthStatus,
      operationalHealthWorkstreams:
        operationalHealth.summary.workstreams,
      operationalHealthActionRequired:
        operationalHealth.summary.actionRequiredWorkstreams,
      operationalHealthPolicyBlocked:
        operationalHealth.summary.policyBlockedWorkstreams,
      operationalHealthWaiting:
        operationalHealth.summary.waitingWorkstreams,
      pendingInputRequests:
        pendingInputRequest.summary.requests,
      pendingAdminPublicationInputs:
        pendingInputRequest.summary.adminPublicationRequests,
      pendingPolicyDecisionInputs:
        pendingInputRequest.summary.policyDecisionRequests,
      pendingRequiredPolicyQuestions:
        pendingInputRequest.summary.requiredPolicyQuestions,
      pendingWorkCoverageStatus:
        pendingWorkCoverage.summary.status,
      pendingWorkUntriaged:
        pendingWorkCoverage.summary.untriagedWorkstreams,
      pendingWorkCovered:
        pendingWorkCoverage.summary.coveredWorkstreams,
      reviewedAnswerPackets:
        reviewedDecisionAnswerPackets.summary.packets,
      reviewedAnswerPacketsReady:
        reviewedDecisionAnswerPackets.summary.readyToApply,
      reviewedAnswerPacketsAwaitingAnswers:
        reviewedDecisionAnswerPackets.summary.awaitingAnswers,
      reviewedAnswerPacketsInvalid:
        reviewedDecisionAnswerPackets.summary.invalid,
      reviewedAnswerPacketsStale:
        reviewedDecisionAnswerPackets.summary.stale,
      reviewedAnswerPacketStatus:
        reviewedDecisionAnswerPackets.summary.status,
      promotionExecutionStatus:
        promotionExecutionPacket.summary.status,
      promotionExecutionPhases:
        promotionExecutionPacket.summary.phases,
      promotionExecutionBlockedPhases:
        promotionExecutionPacket.summary.blockedPhases,
      promotionCanRunLocalPreview:
        promotionExecutionPacket.summary.canRunLocalPreview,
      promotionCanDeployNewPublicPages:
        promotionExecutionPacket.summary.canDeployNewPublicPages,
      promotionCanWriteClaimTargets:
        promotionExecutionPacket.summary.canWriteClaimTargets,
      curationOperations: curationState.summary.operations,
      attachedSurfaces: curationState.summary.attachedSurfaces,
      mergedSources: curationState.summary.mergedSources,
      splitSurfaces: curationState.summary.splitSurfaces,
      searchResultCandidates: searchResultCandidateQueue.summary.candidates,
      matchedSearchResultCandidates: searchResultCandidateQueue.summary.matchedExistingEntities,
      duplicateSearchResultKeys: searchResultCandidateQueue.summary.duplicateNormalizedKeys,
      sourceArtifacts: sourceMentionResolution.sourceArtifacts.summary.artifacts,
      sourceMentions:
        sourceMentionResolution.extractedMentions.summary.mentions,
      sourceMentionEventMentions:
        sourceMentionResolution.extractedMentions.summary.eventMentions,
      sourceMentionOrganizerMentions:
        sourceMentionResolution.extractedMentions.summary.organizerMentions,
      sourceMentionCandidates:
        sourceMentionResolution.resolutionCandidates.summary.candidates,
      sourceMentionClusters:
        sourceMentionResolution.resolutionClusters.summary.clusters,
      sourceMentionAutoAttachClusters:
        sourceMentionResolution.resolutionClusters.summary.autoAttachClusters,
      sourceMentionNeedsReviewClusters:
        sourceMentionResolution.resolutionClusters.summary.needsHumanReviewClusters,
      sourceMentionLlmReviewQueued:
        sourceMentionResolution.resolutionClusters.summary.llmReviewQueued,
      sourceMentionReviewPackets:
        sourceMentionResolution.reviewPackets.summary.packets,
      sourceMentionHumanReviewRequired:
        sourceMentionResolution.reviewPackets.summary.humanReviewRequired,
      sourceMentionLlmPromptRequests:
        sourceMentionLlmPromptQueue.summary.requests,
      discoverySearchPlanPlanned: discoverySearchPlan.summary.planned,
      discoverySearchPlanSkippedFresh: discoverySearchPlan.summary.skippedFresh,
      discoverySearchPlanLaunchCityPlanned:
        discoverySearchPlan.summary.launchCityPlanned,
      discoverySearchPlanLaunchCitySkippedFresh:
        discoverySearchPlan.summary.launchCitySkippedFresh,
      discoverySearchPlanMissingLaunchCityCategories:
        discoverySearchPlan.summary.missingLaunchCityCategories.length,
      externalEventCandidates: externalEventCandidateQueue.summary.candidates,
      externalEventCandidatesBlocked: externalEventCandidateQueue.summary.blocked,
      externalEventCandidatesReviewed: externalEventCandidateQueue.summary.reviewed ?? 0,
      externalEventCandidatesApproved:
        externalEventCandidateQueue.summary.approvedForImport ?? 0,
      externalEventCandidatesHeld: externalEventCandidateQueue.summary.held ?? 0,
      externalEventCandidatesRejected:
        externalEventCandidateQueue.summary.rejected ?? 0,
      externalEventLocationTasks:
        externalEventLocationResolutionQueue.summary.tasks,
      externalEventLocationMissingCoordinates:
        externalEventLocationResolutionQueue.summary.missingExactCoordinates,
      externalEventLocationProviderDisabled:
        externalEventLocationResolutionQueue.summary.providerDisabled,
      externalEventImportProposedCreates:
        externalEventImportPlan.summary.proposedCreates,
      externalEventImportProposedReadOnlyEvents:
        externalEventImportPlan.summary.proposedReadOnlyEvents ??
          externalEventImportPlan.summary.proposedCreates,
      externalEventImportBlocked: externalEventImportPlan.summary.blocked,
      externalEventImportWriteReady: externalEventImportPlan.summary.writeReady,
      externalEventImportExecutionWouldCreate:
        externalEventImportExecutionPlan.summary.wouldCreate ?? 0,
      externalEventImportExecutionWouldPublishReadOnly:
        externalEventImportExecutionPlan.summary.wouldPublishReadOnly ??
          externalEventImportExecutionPlan.summary.wouldCreate,
      externalEventImportExecutionBlocked:
        externalEventImportExecutionPlan.summary.blocked,
      externalEventImportExecutionSchemaInvalid:
        externalEventImportExecutionPlan.summary.schemaInvalid ?? 0,
      externalEventImportExecutionProjectionInvalid:
        externalEventImportExecutionPlan.summary.projectionInvalid ??
          externalEventImportExecutionPlan.summary.schemaInvalid,
      externalEventImportExecutionPayloadInvalid:
        externalEventImportExecutionPlan.summary.payloadInvalid ?? 0,
      externalEventImportExecutionProjectionInvalidCount:
        externalEventImportExecutionPlan.summary.projectionInvalidCount ??
          externalEventImportExecutionPlan.summary.payloadInvalid,
      crawlCapableSurfaces: eventCrawlPlan.summary.crawlCapableSurfaces,
      crawlApprovedSurfaces: eventCrawlPlan.summary.approvedSurfaces,
      crawlBlockedSurfaces: eventCrawlPlan.summary.blockedSurfaces,
      crawlRunIntents: eventCrawlRunPlan.summary.candidateSurfaces,
      crawlRunWouldFetch: eventCrawlRunPlan.summary.wouldFetch,
      crawlRunBlocked: eventCrawlRunPlan.summary.blocked,
      readinessBlocked: workflowReadiness.summary.blocked,
      readinessPolicyNeeded: workflowReadiness.summary.policyNeeded,
      readinessReviewNeeded: workflowReadiness.summary.reviewNeeded,
      policyGaps: policyGapRegister.summary.gaps,
      policyGapsDecisionRequired:
        policyGapRegister.summary.decisionRequired,
      policyGapReviewDecisions:
        policyGapRegister.summary.reviewDecisions,
      policyGapReviewAccepted:
        policyGapRegister.summary.reviewAccepted,
      policyGapReviewHeld:
        policyGapRegister.summary.reviewHeld,
      policyGapReviewRejected:
        policyGapRegister.summary.reviewRejected,
      policyGapReviewInvalid:
        policyGapRegister.summary.reviewInvalid,
      policyDecisionPackets: policyDecisionPackets.summary.packets,
      policyDecisionQuestions: policyDecisionPackets.summary.questions,
      policyDecisionUnanswered:
        policyDecisionPackets.summary.unansweredQuestions,
      rawArtifacts: rawArtifactStorageManifest.summary.artifacts,
      rawProviderPayloads:
        rawArtifactStorageManifest.summary.rawProviderPayloads,
      rawArtifactStorageBlocked:
        rawArtifactStorageManifest.summary.remoteUploadBlocked,
      rawArtifactBytes: rawArtifactStorageManifest.summary.totalBytes,
    },
    guardrails: projectionPlan.guardrails,
    workflowReadiness: {
      status: workflowReadiness.status,
      summary: workflowReadiness.summary,
      gates: workflowReadiness.gates,
      commands: workflowReadiness.commands,
    },
    policyGaps: policyGapRegister,
    policyDecisionPackets,
    canonicalHostEntities,
    canonicalEvidenceIndex,
    publicationReviewPackets,
    publicationDecisionImpactPreview,
    operatorActionQueue,
    operationalHealth,
    pendingInputRequest,
    pendingWorkCoverage,
    reviewedDecisionAnswerPackets,
    promotionExecutionPacket,
    claimTargetSyncPreview,
    crawlPlan: {
      summary: eventCrawlPlan.summary,
      policy: eventCrawlPlan.policy,
      guardrails: eventCrawlPlan.guardrails,
    },
    crawlRunPlan: {
      summary: eventCrawlRunPlan.summary,
      policy: eventCrawlRunPlan.policy,
      guardrails: eventCrawlRunPlan.guardrails,
      runIntents: eventCrawlRunPlan.runIntents,
    },
    rawArtifactStorage: {
      summary: rawArtifactStorageManifest.summary,
      policy: rawArtifactStorageManifest.policy,
      guardrails: rawArtifactStorageManifest.guardrails,
      artifacts: rawArtifactStorageManifest.artifacts,
    },
    publishingContracts: buildPublishingContracts(),
    discoverySearchPlan,
    sourceMentionResolution: {
      policy: sourceMentionResolution.resolutionPolicy,
      sourceArtifacts: sourceMentionResolution.sourceArtifacts,
      extractedMentions: sourceMentionResolution.extractedMentions,
      resolutionCandidates: sourceMentionResolution.resolutionCandidates,
      resolutionClusters: sourceMentionResolution.resolutionClusters,
      reviewPackets: sourceMentionResolution.reviewPackets,
      llmPromptQueue: sourceMentionLlmPromptQueue,
    },
    searchCandidates: {
      summary: searchResultCandidateQueue.summary,
      generatedFrom: searchResultCandidateQueue.generatedFrom,
      candidates: searchResultCandidateQueue.candidates,
      duplicateKeys: searchResultCandidateQueue.duplicateKeys,
      warnings: searchResultCandidateQueue.warnings,
      errors: searchResultCandidateQueue.errors,
      commands: {
        capture:
          "node tool/organizer_intake/capture_search_results.mjs " +
          "--run-key RUN_KEY --raw-results PROVIDER_RESULTS_JSON " +
          "--date YYYY-MM-DD --write",
        ingest:
          "node tool/organizer_intake/ingest_search_results.mjs",
        normalize:
          "node tool/organizer_intake/normalize_surface_url.mjs URL",
        curateSurface:
          "node tool/organizer_intake/curation_decision.mjs draft attach_surface " +
          "--entity ENTITY --search-candidate CANDIDATE_ID " +
          "--reviewer REVIEWER --date YYYY-MM-DD --reason \"Surface belongs to this organizer.\"",
      },
    },
    externalEventCandidates: {
      summary: externalEventCandidateQueue.summary,
      policy: externalEventCandidateQueue.policy,
      generatedFrom: externalEventCandidateQueue.generatedFrom,
      candidates: externalEventCandidateQueue.candidates,
      duplicateEventKeys: externalEventCandidateQueue.duplicateEventKeys,
      warnings: externalEventCandidateQueue.warnings,
      errors: externalEventCandidateQueue.errors,
      commands: externalEventCandidateQueue.commands,
    },
    externalEventLocationResolution: {
      summary: externalEventLocationResolutionQueue.summary,
      policy: externalEventLocationResolutionQueue.policy,
      generatedFrom: externalEventLocationResolutionQueue.generatedFrom,
      guardrails: externalEventLocationResolutionQueue.guardrails,
      tasks: externalEventLocationResolutionQueue.tasks,
      commands: externalEventLocationResolutionQueue.commands,
    },
    externalEventImportPlan: {
      summary: externalEventImportPlan.summary,
      policy: externalEventImportPlan.policy,
      generatedFrom: externalEventImportPlan.generatedFrom,
      guardrails: externalEventImportPlan.guardrails,
      actions: externalEventImportPlan.actions,
      commands: externalEventImportPlan.commands,
    },
    externalEventImportExecutionPlan: {
      summary: externalEventImportExecutionPlan.summary,
      policy: externalEventImportExecutionPlan.policy,
      generatedFrom: externalEventImportExecutionPlan.generatedFrom,
      guardrails: externalEventImportExecutionPlan.guardrails,
      actions: externalEventImportExecutionPlan.actions,
      commands: externalEventImportExecutionPlan.commands,
    },
    curation: {
      summary: curationState.summary,
      commands: curationState.commands,
      attachedSurfaces: curationState.attachedSurfaces,
      mergedEntities: curationState.mergedEntities,
      suppressedEntities: curationState.suppressedEntities,
      surfaceDecisions: curationState.surfaceDecisions,
      splitSurfaces: curationState.splitSurfaces,
    },
    items: reviewQueue.items.map((item) => {
      const projection = projectionPlan.entries.find((entry) => entry.entityId === item.entityId);
      const claimTarget = claimTargetPlan.targets.find((target) => target.entityId === item.entityId);
      const publicationPacket = publicationReviewPackets.packets.find((packet) =>
        packet.entityId === item.entityId
      );
      return {
        entityId: item.entityId,
        displayName: item.displayName,
        priority: item.priority,
        taskType: item.taskType,
        reviewStatus: item.reviewStatus,
        relationshipToCatch: item.relationshipToCatch,
        canonicalPath: item.canonicalPath,
        legacyPaths: item.legacyPaths,
        markets: item.markets,
        blockers: item.blockers,
        gates: item.gates,
        surfaceSummary: item.surfaceSummary,
        surfaces: item.surfaces,
        curation: item.curation,
        promotionPolicy: item.promotionPolicy,
        reviewDecision: item.reviewDecision,
        projectionStatus: projection?.projectionStatus ?? "blocked",
        publishStatus: projection?.publishStatus ?? "blocked",
        indexStatus: projection?.indexStatus ?? "noindex",
        appVisibility: projection?.appVisibility ?? "hidden",
        claimTargetPath: claimTarget?.path ?? null,
        decisionCommands: decisionCommandsFor(item.entityId, publicationPacket),
      };
    }),
  };
}

function loadHostDiscoverySearchPlan() {
  if (!fs.existsSync(hostDiscoverySearchPlanPath)) {
    return {
      schemaVersion: 1,
      generatedFrom: {
        searchMatrix: "tool/host_discovery/search_matrix.json",
        targetCategories: "tool/host_discovery/target_categories.json",
        queryTemplates: "tool/host_discovery/query_templates.json",
        batches: [],
        runs: [],
      },
      asOf: null,
      freshForDays: null,
      plannedCount: 0,
      skippedFreshCount: 0,
      planned: [],
      skippedFresh: [],
      warnings: [
        `Missing host discovery search plan: ${relative(hostDiscoverySearchPlanPath)}`,
      ],
    };
  }
  return readJson(hostDiscoverySearchPlanPath);
}

function buildDiscoverySearchPlan({launchCitySlugs, searchPlan}) {
  const planned = (searchPlan.planned ?? []).map(discoverySearchPlanEntry);
  const skippedFresh = (searchPlan.skippedFresh ?? []).map(discoverySearchPlanEntry);
  const launchCities = launchCitySlugs.map((citySlug) =>
    discoveryLaunchCity(citySlug, planned, skippedFresh)
  );
  const missingLaunchCityCategories = launchCities.flatMap((city) =>
    city.missingCategoryIds.map((categoryId) => ({
      citySlug: city.citySlug,
      city: city.city,
      categoryId,
    }))
  );
  return {
    schemaVersion: 1,
    generatedFrom: {
      searchPlan: relative(hostDiscoverySearchPlanPath),
      searchMatrix: searchPlan.generatedFrom?.searchMatrix ?? null,
      targetCategories: searchPlan.generatedFrom?.targetCategories ?? null,
      queryTemplates: searchPlan.generatedFrom?.queryTemplates ?? null,
      batches: searchPlan.generatedFrom?.batches ?? [],
      runs: searchPlan.generatedFrom?.runs ?? [],
    },
    asOf: searchPlan.asOf ?? null,
    freshForDays: searchPlan.freshForDays ?? null,
    summary: {
      planned: planned.length,
      skippedFresh: skippedFresh.length,
      launchCityPlanned:
        planned.filter((entry) => launchCitySlugs.includes(entry.citySlug)).length,
      launchCitySkippedFresh:
        skippedFresh.filter((entry) => launchCitySlugs.includes(entry.citySlug)).length,
      plannedByCity: countBy(planned, (entry) => entry.citySlug),
      plannedByCategory: countBy(planned, (entry) => entry.categoryId),
      plannedByKind: countBy(planned, (entry) => entry.planKind),
      launchCities: launchCitySlugs,
      missingLaunchCityCategories,
    },
    contracts: buildPublishingContracts(),
    launchCities,
    planned,
    skippedFresh,
    warnings: searchPlan.warnings ?? [],
    commands: {
      configure:
        "Edit tool/host_discovery/search_matrix.json and " +
        "tool/host_discovery/query_templates.json.",
      regenerate:
        "node tool/host_discovery/plan_search_runs.mjs && " +
        "node tool/organizer_intake/organizer_intake.mjs",
      capture:
        "node tool/organizer_intake/capture_search_results.mjs " +
        "--run-key RUN_KEY --raw-results PROVIDER_RESULTS_JSON " +
        "--date YYYY-MM-DD --write",
      ingest:
        "node tool/organizer_intake/ingest_search_results.mjs",
    },
  };
}

function discoveryLaunchCity(citySlug, planned, skippedFresh) {
  const cityEntries = [...planned, ...skippedFresh]
    .filter((entry) => entry.citySlug === citySlug);
  const categories = [...new Set(cityEntries.map((entry) => entry.categoryId))]
    .sort();
  const expectedCategoryIds = [
    "racket_sport_social",
    "singles_event_operator",
    "social_run_club",
  ];
  return {
    citySlug,
    city: cityEntries[0]?.city ?? citySlug,
    planned:
      planned.filter((entry) => entry.citySlug === citySlug).length,
    skippedFresh:
      skippedFresh.filter((entry) => entry.citySlug === citySlug).length,
    categoryIds: categories,
    missingCategoryIds: expectedCategoryIds.filter((categoryId) =>
      !categories.includes(categoryId)
    ),
  };
}

function discoverySearchPlanEntry(entry) {
  return {
    runKey: entry.runKey,
    planKind: entry.planKind,
    source: entry.source,
    citySlug: entry.citySlug,
    city: entry.city,
    categoryId: entry.categoryId,
    queryTemplateId: entry.queryTemplateId,
    queryTemplate: entry.queryTemplate,
    renderedQuery: entry.renderedQuery,
    candidateId: entry.candidateId ?? null,
    candidateName: entry.candidateName ?? null,
    resultFingerprint: entry.resultFingerprint ?? null,
    existingRunId: entry.existingRunId ?? null,
    existingRunFile: entry.existingRunFile ?? null,
    searchedAt: entry.searchedAt ?? null,
  };
}

function buildPublishingContracts() {
  return {
    organizer: {
      intakeTarget: "organizer",
      callablePayloadSchema: "contracts/callables/create_club_payload.schema.json",
      firestoreSchema: "contracts/firestore/clubs.schema.json",
      generatedCallablePayload:
        "functions/src/shared/generated/createClubCallablePayload.ts",
      writeCallable: "createClub",
      projectionNotes: [
        "Unclaimed supply must remain ownership.state=programmatic and claim.state=unclaimed until a real owner claims it.",
        "App browse can use clubs.appVisibility; website routes use clubs.publicPage.",
        "Public copy must stay source-backed through clubs.provenance and clubs.publicProfile.",
      ],
    },
    event: {
      intakeTarget: "event",
      callablePayloadSchema: "contracts/callables/create_event_payload.schema.json",
      firestoreSchema: "contracts/firestore/events.schema.json",
      generatedCallablePayload:
        "functions/src/shared/generated/createEventCallablePayload.ts",
      writeCallable: "createEvent",
      projectionNotes: [
        "External event candidates stay review-only until they can produce createEvent-compatible payloads.",
        "App discovery depends on events discovery fields derived from the canonical event document.",
        "Location, time, capacity, price, constraints, and eventFormat must satisfy createEvent before publish.",
      ],
    },
  };
}

function decisionCommandsFor(entityId, publicationPacket = null) {
  const base = `node tool/organizer_intake/review_decision.mjs draft ${entityId}`;
  return {
    approvePublic:
      publicationPacket?.adminDecision?.command ??
      `${base} --decision approve_public --app-visibility hidden ` +
      `--reviewer REVIEWER --date YYYY-MM-DD --note "Manual QA complete." ` +
      `--confirm-publication-checklist`,
    hold:
      `${base} --decision hold --app-visibility hidden ` +
      `--reviewer REVIEWER --date YYYY-MM-DD --note "More evidence required."`,
    suppress:
      `${base} --decision suppress --app-visibility hidden ` +
      `--reviewer REVIEWER --date YYYY-MM-DD ` +
      `--note "Suppressing this intake entity."`,
  };
}

function hostDefaultsForEntity(entity) {
  const defaults = entity.activityDefaults ?? {};
  const primaryActivityKind = defaults.primaryActivityKind ?? "openActivity";
  const supportedActivityKinds = uniqueStrings([
    primaryActivityKind,
    ...(defaults.supportedActivityKinds ?? []),
  ]).slice(0, 16);
  return {
    primaryActivityKind,
    supportedActivityKinds,
  };
}

function clubEntityKind(entityKind) {
  if (entityKind === "clubCommunity") return "club";
  if (entityKind === "individual") return "eventOrganizer";
  if (entityKind === "eventOrganizer") return "eventOrganizer";
  if (entityKind === "creatorCommunity") return "creatorCommunity";
  if (entityKind === "venue") return "venue";
  return "brand";
}

function displayEntityKind(entityKind) {
  return {
    brand: "Brand",
    clubCommunity: "Club community",
    creatorCommunity: "Creator community",
    eventOrganizer: "Event organizer",
    individual: "Individual organizer",
    venue: "Venue",
  }[entityKind] ?? "Organizer";
}

function instagramHandleForSurfaces(surfaces) {
  const surface = surfaces.find((candidate) =>
    candidate.platform === "instagram" &&
      candidate.status === "active" &&
      typeof candidate.url === "string"
  );
  if (!surface) return null;
  try {
    const url = new URL(surface.url);
    const [handle] = url.pathname.split("/").filter(Boolean);
    return handle ? handle.replace(/^@/, "") : null;
  } catch {
    return null;
  }
}

function highestSourceConfidence(sources) {
  const values = sources.map((source) => source.confidence);
  if (values.includes("high")) return "high";
  if (values.includes("medium")) return "medium";
  return values.includes("low") ? "low" : "seedOnly";
}

function countryNameForCode(countryCode) {
  if (countryCode === "IN") return "India";
  if (countryCode === "US") return "United States";
  return countryCode ?? null;
}

function timestampForDate(dateValue) {
  const value = typeof dateValue === "string" && /^\d{4}-\d{2}-\d{2}$/.test(dateValue) ?
    dateValue :
    "1970-01-01";
  return {
    _seconds: Math.floor(Date.parse(`${value}T00:00:00.000Z`) / 1000),
    _nanoseconds: 0,
  };
}

function truncateText(value, maxLength) {
  const text = String(value ?? "").trim();
  if (text.length <= maxLength) return text;
  return `${text.slice(0, Math.max(0, maxLength - 3)).trimEnd()}...`;
}

function appendSentence(value, sentence) {
  const base = String(value ?? "").trim();
  const next = String(sentence ?? "").trim();
  if (!base) return next;
  if (!next) return base;
  return `${base} ${next}`;
}

function uniqueStrings(values) {
  return [...new Set(
    values
      .filter((value) => typeof value === "string")
      .map((value) => value.trim())
      .filter(Boolean)
  )];
}

function uniqueBy(values, keyFor) {
  const items = new Map();
  for (const value of values) {
    const key = keyFor(value);
    if (!items.has(key)) items.set(key, value);
  }
  return [...items.values()];
}

function reviewGates(entity, conflicts, decision) {
  const surfaces = entity.surfaces ?? [];
  const activeSurfaces = surfaces.filter((surface) => surface.status === "active");
  const nonRejected = surfaces.filter((surface) => surface.status !== "rejected");
  const draft = entity.publicDraft ?? {};
  return [
    gate(
      "manual_admin_review_required",
      decision?.decision === "approve_public" && reviewChecklistComplete(decision.checklist),
      "Every public promotion requires an explicit admin decision."
    ),
    gate(
      "identity_surface_present",
      activeSurfaces.some((surface) =>
        ["officialWebsite", "luma", "instagram", "partiful", "bookMyShow", "district", "sortMyScene"]
          .includes(surface.platform) &&
        surface.confidence?.entityMatch !== "low"
      ),
      "At least one active public surface supports organizer identity."
    ),
    gate(
      "market_model_present",
      entity.geographicScope?.kind === "remote" ||
        (Array.isArray(entity.geographicScope?.markets) && entity.geographicScope.markets.length > 0),
      "Entity has one canonical profile with market filters, not duplicate city identities."
    ),
    gate(
      "owner_safe_public_draft",
      textLength(draft.summary) >= 120 &&
        textLength(draft.sourceSummary) >= 80 &&
        Array.isArray(draft.formats) &&
        draft.formats.length > 0,
      "Draft has original, owner-safe public copy."
    ),
    gate(
      "no_strong_dedupe_conflicts",
      !conflicts.some((conflict) => conflict.maxStrength === "strong"),
      "No strong identifier is shared by multiple organizer entities."
    ),
    gate(
      "surface_inventory_reviewable",
      nonRejected.length > 0 &&
        surfaces.every((surface) =>
          surface.status !== "candidate" || surface.notes.trim().length > 0
        ),
      "Surface inventory is explicit enough for admin QA."
    ),
    gate(
      "app_visibility_separate_from_publication",
      entity.publicListingIntent?.appVisibilityOnAdminApproval === "hidden",
      "Unclaimed public listings remain hidden from the native app by default."
    ),
    gate(
      "crawl_disabled_by_default",
      surfaces.every((surface) => surface.crawl?.eventDiscoveryStatus === "disabled"),
      "Future event extraction is modeled but not scheduled."
    ),
  ];
}

function reviewChecklistComplete(checklist) {
  return Boolean(
    checklist?.identityReviewed &&
      checklist?.surfaceInventoryReviewed &&
      checklist?.ownerSafeCopyReviewed &&
      checklist?.marketScopeReviewed &&
      checklist?.mediaRightsReviewed &&
      checklist?.crawlDisabledReviewed
  );
}

function reviewDecisionSummary(decision) {
  return {
    decision: decision.decision,
    appVisibility: decision.appVisibility,
    decidedAt: decision.decidedAt,
    reviewer: decision.reviewer,
    decisionBatchId: decision.decisionBatchId,
    sourceFile: decision.sourceFile,
  };
}

function publicListingProjection(entity) {
  return {
    id: entity.entityId,
    name: entity.displayName,
    slug: entity.canonicalSlug,
    path: entity.publicListingIntent.canonicalPath,
    status: entity.relationshipToCatch === "claimed" ? "claimed" : "unclaimed",
    indexing: entity.publicListingIntent.indexOnAdminApproval ? "index, follow" : "noindex, follow",
    category: entity.entityKind,
    headline: entity.publicDraft.headline,
    description: entity.publicDraft.summary,
    sourceSummary: entity.publicDraft.sourceSummary,
    formats: entity.publicDraft.formats,
    missingEvidence: approvedPublicMissingEvidence(entity.publicDraft.missingEvidence),
    markets: entity.geographicScope.markets,
    sources: entity.surfaces
      .filter((surface) => surface.status === "active" && surface.url)
      .map((surface) => ({
        type: surface.platform,
        label: surfaceLabel(surface),
        href: surface.url,
        confidence: surface.confidence.entityMatch,
      })),
  };
}

function approvedPublicMissingEvidence(missingEvidence = []) {
  return missingEvidence.filter((item) =>
    item !== "Manual admin approval for public publication"
  );
}

function addKey(keys, type, value, strength, reason) {
  if (typeof value !== "string" || value.length === 0) return;
  keys.push({type, value, strength, reason});
}

function duplicateKeyConflicts(keys) {
  const groups = new Map();
  for (const key of keys) {
    if (key.type === "alias" || key.type === "rejected_surface") continue;
    const groupKey = `${key.type}:${key.value}`;
    if (!groups.has(groupKey)) groups.set(groupKey, []);
    groups.get(groupKey).push(key);
  }
  const conflicts = [];
  for (const [groupKey, group] of groups.entries()) {
    const entityIds = [...new Set(group.map((key) => key.entityId))].sort();
    if (entityIds.length <= 1) continue;
    const [type, ...valueParts] = groupKey.split(":");
    const strengths = group.map((key) => key.strength);
    conflicts.push({
      type,
      value: valueParts.join(":"),
      entityIds,
      maxStrength: maxStrength(strengths),
    });
  }
  return conflicts.sort((a, b) => `${a.type}:${a.value}`.localeCompare(`${b.type}:${b.value}`));
}

function maxStrength(strengths) {
  if (strengths.includes("strong")) return "strong";
  if (strengths.includes("medium")) return "medium";
  return "weak";
}

function surfaceSummary(surfaces) {
  return {
    total: surfaces.length,
    active: surfaces.filter((surface) => surface.status === "active").length,
    candidate: surfaces.filter((surface) => surface.status === "candidate").length,
    ambiguous: surfaces.filter((surface) => surface.status === "ambiguous").length,
    rejected: surfaces.filter((surface) => surface.status === "rejected").length,
    platforms: countBy(surfaces, "platform"),
  };
}

function surfaceLabel(surface) {
  if (surface.platform === "luma") return "Luma";
  if (surface.platform === "instagram") return "Instagram";
  if (surface.platform === "officialWebsite") return "Official website";
  if (surface.platform === "sortMyScene") return "Sort My Scene";
  if (surface.platform === "bookMyShow") return "BookMyShow";
  if (surface.platform === "district") return "District";
  if (surface.platform === "partiful") return "Partiful";
  return surface.platform;
}

function gate(id, passed, description) {
  return {id, passed, description};
}

function reviewSortKey(entity) {
  const priorityOrder = {p0: "0", p1: "1", p2: "2", p3: "3"};
  const statusOrder = {
    needs_admin_review: "0",
    needs_more_evidence: "1",
    candidate: "2",
    approved_public: "3",
    published: "4",
    claimed: "5",
    suppressed: "6",
  };
  return `${priorityOrder[entity.priority] ?? "9"}:${statusOrder[entity.reviewStatus] ?? "9"}:${entity.entityId}`;
}

function requiredExact(record, field, expected, prefix) {
  if (record?.[field] !== expected) {
    errors.push(`${prefix}: ${field} must equal ${JSON.stringify(expected)}`);
  }
}

function requiredString(record, field, prefix) {
  if (typeof record?.[field] !== "string" || record[field].trim().length === 0) {
    errors.push(`${prefix}: missing ${field}`);
  }
}

function optionalString(record, field, prefix) {
  if (record?.[field] !== null && record?.[field] !== undefined && typeof record[field] !== "string") {
    errors.push(`${prefix}: ${field} must be string or null`);
  }
}

function requiredSlug(record, field, prefix) {
  if (!isSlug(record?.[field])) {
    errors.push(`${prefix}: ${field} must be a lowercase slug`);
  }
}

function requiredPath(record, field, prefix) {
  if (!isOrganizerPath(record?.[field])) {
    errors.push(`${prefix}: ${field} must be an /organizers/.../ path`);
  }
}

function requiredDate(record, field, prefix) {
  if (typeof record?.[field] !== "string" || !/^\d{4}-\d{2}-\d{2}$/.test(record[field])) {
    errors.push(`${prefix}: ${field} must be YYYY-MM-DD`);
  }
}

function requiredCountryCode(record, field, prefix) {
  if (typeof record?.[field] !== "string" || !/^[A-Z]{2}$/.test(record[field])) {
    errors.push(`${prefix}: ${field} must be ISO 3166-1 alpha-2`);
  }
}

function requiredEnum(record, field, values, prefix) {
  if (!values.has(record?.[field])) {
    errors.push(`${prefix}: invalid ${field} ${JSON.stringify(record?.[field])}`);
  }
}

function requiredStringArray(record, field, prefix) {
  if (!Array.isArray(record?.[field])) {
    errors.push(`${prefix}: ${field} must be an array`);
    return;
  }
  for (const [index, item] of record[field].entries()) {
    if (typeof item !== "string" || item.trim().length === 0) {
      errors.push(`${prefix}: ${field}[${index}] must be a non-empty string`);
    }
  }
}

function validateUrlOrNull(value, prefix) {
  if (value === null) return;
  if (typeof value !== "string" || value.trim().length === 0) {
    errors.push(`${prefix}: url must be string or null`);
    return;
  }
  try {
    const url = new URL(value);
    if (!["http:", "https:"].includes(url.protocol)) {
      errors.push(`${prefix}: url must use http or https`);
    }
  } catch {
    errors.push(`${prefix}: invalid URL ${value}`);
  }
}

function isSlug(value) {
  return typeof value === "string" && /^[a-z0-9]+(?:-[a-z0-9]+)*$/.test(value);
}

function isOrganizerPath(value) {
  return typeof value === "string" && /^\/organizers\/[a-z0-9/-]+\/$/.test(value);
}

function normalizeName(value) {
  return String(value)
    .normalize("NFKD")
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, " ")
    .trim()
    .replace(/\s+/g, " ");
}

function textLength(value) {
  return typeof value === "string" ? value.trim().length : 0;
}

function countBy(items, field) {
  const counts = {};
  for (const item of items) {
    const key =
      typeof field === "function" ? field(item) ?? "<missing>" : item[field] ?? "<missing>";
    counts[key] = (counts[key] ?? 0) + 1;
  }
  return Object.fromEntries(Object.entries(counts).sort(([a], [b]) => a.localeCompare(b)));
}

function parseArgs(argv) {
  const parsed = {
    adminGeneratedRoot: null,
    answerPacketsRoot: null,
    batchesRoot: null,
    check: false,
    curationDecisionsRoot: null,
    generatedRoot: null,
    hostDiscoverySearchPlan: null,
    help: false,
    policyGapDecisionsRoot: null,
    rawArtifactsRoot: null,
    reviewDecisionsRoot: null,
  };

  for (let index = 0; index < argv.length; index += 1) {
    const arg = argv[index];
    if (arg === "--check") parsed.check = true;
    else if (arg === "--help" || arg === "-h") parsed.help = true;
    else if (arg === "--admin-generated-root") {
      parsed.adminGeneratedRoot = requiredValue(argv, ++index, arg);
    } else if (arg === "--answer-packets-root") {
      parsed.answerPacketsRoot = requiredValue(argv, ++index, arg);
    } else if (arg === "--batches-root") {
      parsed.batchesRoot = requiredValue(argv, ++index, arg);
    } else if (arg === "--curation-decisions-root") {
      parsed.curationDecisionsRoot = requiredValue(argv, ++index, arg);
    } else if (arg === "--generated-root") {
      parsed.generatedRoot = requiredValue(argv, ++index, arg);
    } else if (arg === "--host-discovery-search-plan") {
      parsed.hostDiscoverySearchPlan = requiredValue(argv, ++index, arg);
    } else if (arg === "--policy-gap-decisions-root") {
      parsed.policyGapDecisionsRoot = requiredValue(argv, ++index, arg);
    } else if (arg === "--raw-artifacts-root") {
      parsed.rawArtifactsRoot = requiredValue(argv, ++index, arg);
    } else if (arg === "--review-decisions-root") {
      parsed.reviewDecisionsRoot = requiredValue(argv, ++index, arg);
    } else {
      fail(`Unknown argument: ${arg}`);
    }
  }

  return parsed;
}

function requiredValue(argv, index, flag) {
  const value = argv[index];
  if (!value || value.startsWith("--")) fail(`${flag} requires a value.`);
  return value;
}

function printHelp() {
  console.log(`Usage: node tool/organizer_intake/organizer_intake.mjs [options]

Options:
  --check                         Check generated organizer intake artifact drift.
  --host-discovery-search-plan <path>
                                  Read the organizer discovery search plan from a specific file.
  --answer-packets-root <path>    Read reviewed answer packets from a specific folder.
  --batches-root <path>            Read organizer entity batches from a specific folder.
  --curation-decisions-root <path> Read curation decisions from a specific folder.
  --review-decisions-root <path>   Read admin review decisions from a specific folder.
  --policy-gap-decisions-root <path>
                                  Read policy gap decisions from a specific folder.
  --raw-artifacts-root <path>     Read ignored raw provider payloads from a folder.
  --generated-root <path>          Write or check generated organizer artifacts in a folder.
  --admin-generated-root <path>    Write or check admin bridge artifacts in a folder.
`);
}

function fail(message) {
  console.error(message);
  process.exit(1);
}

function readJson(file) {
  return JSON.parse(fs.readFileSync(file, "utf8"));
}

function hashObject(value) {
  return crypto.createHash("sha256")
    .update(stableStringify(value))
    .digest("hex");
}

function stableStringify(value) {
  return JSON.stringify(sortValue(value), null, 2);
}

function sortValue(value) {
  if (Array.isArray(value)) return value.map(sortValue);
  if (!value || typeof value !== "object") return value;
  return Object.fromEntries(
    Object.entries(value)
      .sort(([a], [b]) => a.localeCompare(b))
      .map(([key, nested]) => [key, sortValue(nested)])
  );
}

function relative(file) {
  return path.relative(repoRoot, file);
}
