const priorityRank = {
  p0: 0,
  p1: 1,
  p2: 2,
  p3: 3,
};

const blockingStatuses = new Set([
  "blocked",
  "blocked_by_policy",
  "disabled_by_policy",
]);

const waitingStatuses = new Set([
  "waiting",
  "waiting_on_admin_review",
  "waiting_on_public_projection",
  "waiting_on_claim_sync",
]);

const actionStatuses = new Set([
  "curation_needed",
  "dry_run_review_required",
  "requires_admin_decision",
  "requires_policy_input",
  "requires_policy_decision",
  "review_needed",
]);

export function buildOrganizerOperationalHealthReport({
  canonicalEvidenceIndex = emptyCanonicalEvidenceIndex(),
  canonicalHostEntities = emptyCanonicalHostEntities(),
  claimTargetSyncPreview = emptyClaimTargetSyncPreview(),
  eventCrawlPlan = emptyEventCrawlPlan(),
  eventCrawlRunPlan = emptyEventCrawlRunPlan(),
  externalEventCandidateQueue = emptyExternalEventCandidateQueue(),
  externalEventImportExecutionPlan = emptyExternalEventImportExecutionPlan(),
  externalEventImportPlan = emptyExternalEventImportPlan(),
  externalEventLocationResolutionQueue =
    emptyExternalEventLocationResolutionQueue(),
  operatorActionQueue = emptyOperatorActionQueue(),
  policyDecisionPackets = emptyPolicyDecisionPackets(),
  policyGapRegister = emptyPolicyGapRegister(),
  publicationDecisionImpactPreview = emptyPublicationDecisionImpactPreview(),
  publicationReviewPackets = emptyPublicationReviewPackets(),
  rawArtifactStorageManifest = emptyRawArtifactStorageManifest(),
  searchResultCandidateQueue = emptySearchResultCandidateQueue(),
  workflowReadiness = emptyWorkflowReadiness(),
} = {}) {
  const workstreams = [
    publicationWorkstream({
      operatorActionQueue,
      publicationDecisionImpactPreview,
      publicationReviewPackets,
    }),
    policyWorkstream({
      operatorActionQueue,
      policyDecisionPackets,
      policyGapRegister,
    }),
    promotionWorkstream({
      canonicalHostEntities,
      claimTargetSyncPreview,
      operatorActionQueue,
      publicationDecisionImpactPreview,
      workflowReadiness,
    }),
    claimTargetWorkstream({
      claimTargetSyncPreview,
      operatorActionQueue,
      workflowReadiness,
    }),
    rawArtifactWorkstream(rawArtifactStorageManifest),
    crawlWorkstream({
      eventCrawlPlan,
      eventCrawlRunPlan,
    }),
    externalEventWorkstream({
      externalEventCandidateQueue,
      externalEventImportExecutionPlan,
      externalEventImportPlan,
      externalEventLocationResolutionQueue,
    }),
    searchIntakeWorkstream(searchResultCandidateQueue),
    evidenceWorkstream(canonicalEvidenceIndex),
  ].sort(workstreamComparator);

  return {
    schemaVersion: 1,
    generatedFrom: {
      canonicalEvidenceIndex:
        "tool/organizer_intake/generated/canonical_evidence_index.json",
      canonicalHostEntities:
        "tool/organizer_intake/generated/canonical_host_entities.json",
      claimTargetSyncPreview:
        "tool/organizer_intake/generated/organizer_claim_target_sync_preview.json",
      eventCrawlPlan:
        "tool/organizer_intake/generated/event_crawl_plan.json",
      eventCrawlRunPlan:
        "tool/organizer_intake/generated/event_crawl_run_plan.json",
      externalEventCandidateQueue:
        "tool/organizer_intake/generated/external_event_candidate_queue.json",
      externalEventImportExecutionPlan:
        "tool/organizer_intake/generated/external_event_import_execution_plan.json",
      externalEventImportPlan:
        "tool/organizer_intake/generated/external_event_import_plan.json",
      externalEventLocationResolutionQueue:
        "tool/organizer_intake/generated/external_event_location_resolution_queue.json",
      operatorActionQueue:
        "tool/organizer_intake/generated/organizer_operator_action_queue.json",
      policyDecisionPackets:
        "tool/organizer_intake/generated/organizer_policy_decision_packets.json",
      policyGapRegister:
        "tool/organizer_intake/generated/organizer_policy_gap_register.json",
      publicationDecisionImpactPreview:
        "tool/organizer_intake/generated/publication_decision_impact_preview.json",
      publicationReviewPackets:
        "tool/organizer_intake/generated/publication_review_packets.json",
      rawArtifactStorageManifest:
        "tool/organizer_intake/generated/raw_artifact_storage_manifest.json",
      searchResultCandidateQueue:
        "tool/organizer_intake/generated/search_result_candidate_queue.json",
      workflowReadiness:
        "tool/organizer_intake/generated/organizer_workflow_readiness.json",
    },
    summary: summaryFor({
      operatorActionQueue,
      workstreams,
      workflowReadiness,
    }),
    guardrails: [
      "Operational health is a read-only rollup; it never approves publication, writes Firestore, imports events, uploads artifacts, or enables crawls.",
      "Action-required workstreams must still be resolved through their owning admin decision, policy decision, or planner.",
      "Policy-blocked workstreams remain disabled until the specific owning policy/config is changed after review.",
      "Firestore remains reserved for low-volume decisions and promoted records; raw/search/provider payloads stay out of Firestore.",
    ],
    workstreams,
  };
}

function publicationWorkstream({
  operatorActionQueue,
  publicationDecisionImpactPreview,
  publicationReviewPackets,
}) {
  const actions = actionsOfType(operatorActionQueue, "publication_review");
  const adminActions = actions.filter((action) =>
    action.status === "requires_admin_decision");
  return workstream({
    id: "publication_review",
    label: "Publication Review",
    status: adminActions.length > 0 ?
      "requires_admin_decision" :
      publicationReviewPackets.summary?.readyForManualPublicationReview > 0 ?
        "review_needed" :
        "clear",
    priority: highestActionPriority(actions) ?? "p1",
    metrics: {
      packets: publicationReviewPackets.summary?.packets ?? 0,
      readyForManualReview:
        publicationReviewPackets.summary?.readyForManualPublicationReview ?? 0,
      blockedByData: publicationReviewPackets.summary?.blockedByData ?? 0,
      manualReportsWithoutArtifacts:
        publicationReviewPackets.summary?.manualReportsWithoutArtifacts ?? 0,
      wouldPublish:
        publicationDecisionImpactPreview.summary?.wouldPublish ?? 0,
      wouldIndex:
        publicationDecisionImpactPreview.summary?.wouldIndex ?? 0,
      wouldCreateClaimTargets:
        publicationDecisionImpactPreview.summary?.wouldCreateClaimTargets ?? 0,
    },
    blockers: unique(actions.flatMap((action) => action.blockers ?? [])),
    nextActions: unique(actions.map((action) => action.nextAction)),
    commands: commandsFrom(actions),
    sourceArtifacts: [
      "tool/organizer_intake/generated/publication_review_packets.json",
      "tool/organizer_intake/generated/publication_decision_impact_preview.json",
    ],
  });
}

function policyWorkstream({
  operatorActionQueue,
  policyDecisionPackets,
  policyGapRegister,
}) {
  const actions = actionsOfType(operatorActionQueue, "policy_decision");
  const summary = policyDecisionPackets.summary ?? {};
  const status =
    (summary.unansweredQuestions ?? 0) > 0 ?
      "requires_policy_input" :
      actions.length > 0 ?
        "requires_policy_decision" :
        "clear";
  return workstream({
    id: "policy_decisions",
    label: "Policy Decisions",
    status,
    priority: highestActionPriority(actions) ?? "p1",
    metrics: {
      gaps: policyGapRegister.summary?.gaps ?? 0,
      decisionRequired: policyGapRegister.summary?.decisionRequired ?? 0,
      packets: summary.packets ?? 0,
      questions: summary.questions ?? 0,
      unansweredQuestions: summary.unansweredQuestions ?? 0,
      accepted: summary.accepted ?? 0,
      held: summary.held ?? 0,
      rejected: summary.rejected ?? 0,
    },
    blockers: unique(actions.flatMap((action) => action.blockers ?? [])),
    nextActions: unique(actions.map((action) => action.nextAction)),
    commands: commandsFrom(actions),
    sourceArtifacts: [
      "tool/organizer_intake/generated/organizer_policy_gap_register.json",
      "tool/organizer_intake/generated/organizer_policy_decision_packets.json",
    ],
  });
}

function promotionWorkstream({
  canonicalHostEntities,
  claimTargetSyncPreview,
  operatorActionQueue,
  publicationDecisionImpactPreview,
  workflowReadiness,
}) {
  const publicProjectionGate = gateById(workflowReadiness, "public_projection");
  const publicationActions = actionsOfType(operatorActionQueue, "publication_review");
  const status = workflowReadiness.summary?.publicProjectionReady === true ?
    "ready" :
    publicationActions.length > 0 ?
      "waiting_on_admin_review" :
      "waiting_on_public_projection";
  return workstream({
    id: "promotion_pipeline",
    label: "Promotion Pipeline",
    status,
    priority: publicationActions.length > 0 ? "p1" : "p2",
    metrics: {
      localPromotionPipelineReady:
        workflowReadiness.summary?.localPromotionPipelineReady === true,
      publicProjectionReady:
        workflowReadiness.summary?.publicProjectionReady === true,
      publicPublished: canonicalHostEntities.summary?.publicPublished ?? 0,
      indexed: canonicalHostEntities.summary?.indexed ?? 0,
      impactWouldPublish:
        publicationDecisionImpactPreview.summary?.wouldPublish ?? 0,
      claimTargetWrites:
        claimTargetSyncPreview.summary?.writesNeeded ?? 0,
    },
    blockers: publicProjectionGate ? [publicProjectionGate.status] : [],
    nextActions: [
      publicProjectionGate?.nextAction,
    ].filter(Boolean),
    commands: [
      workflowReadiness.commands?.localPromotionPreview,
    ].filter(Boolean),
    sourceArtifacts: [
      "tool/organizer_intake/generated/organizer_workflow_readiness.json",
      "tool/organizer_intake/generated/public_projection_plan.json",
    ],
  });
}

function claimTargetWorkstream({
  claimTargetSyncPreview,
  operatorActionQueue,
  workflowReadiness,
}) {
  const gate = gateById(workflowReadiness, "claim_target_sync");
  const actions = actionsOfStatusPrefix(operatorActionQueue, "waiting:claim_target_sync");
  const writesNeeded = claimTargetSyncPreview.summary?.writesNeeded ?? 0;
  return workstream({
    id: "claim_target_sync",
    label: "Claim Target Sync",
    status: writesNeeded > 0 ?
      "dry_run_review_required" :
      gate?.status === "ready" ?
        "ready" :
        "waiting_on_public_projection",
    priority: writesNeeded > 0 ? "p1" : "p2",
    metrics: {
      targets: claimTargetSyncPreview.summary?.targets ?? 0,
      creates: claimTargetSyncPreview.summary?.creates ?? 0,
      refreshes: claimTargetSyncPreview.summary?.refreshes ?? 0,
      skippedOwnerBound:
        claimTargetSyncPreview.summary?.skippedOwnerBound ?? 0,
      writesNeeded,
      remoteWrites: claimTargetSyncPreview.mode?.remoteWrites ?? 0,
    },
    blockers: unique([
      gate?.status,
      ...actions.flatMap((action) => action.blockers ?? []),
    ].filter(Boolean)),
    nextActions: unique([
      gate?.nextAction,
      ...actions.map((action) => action.nextAction),
    ].filter(Boolean)),
    commands: unique([
      claimTargetSyncPreview.commands?.localFixturePreview,
      claimTargetSyncPreview.commands?.firestoreDryRun,
      ...commandsFrom(actions),
    ].filter(Boolean)),
    sourceArtifacts: [
      "tool/organizer_intake/generated/organizer_claim_target_sync_preview.json",
      "tool/organizer_intake/generated/organizer_claim_targets.json",
    ],
  });
}

function rawArtifactWorkstream(rawArtifactStorageManifest) {
  const summary = rawArtifactStorageManifest.summary ?? {};
  const blocked = summary.remoteUploadBlocked ?? 0;
  return workstream({
    id: "raw_artifact_storage",
    label: "Raw Artifact Storage",
    status: blocked > 0 ? "blocked_by_policy" : "clear",
    priority: blocked > 0 ? "p1" : "p3",
    metrics: {
      artifacts: summary.artifacts ?? 0,
      rawProviderPayloads: summary.rawProviderPayloads ?? 0,
      totalBytes: summary.totalBytes ?? 0,
      remoteUploadBlocked: blocked,
      remoteUploadReady: summary.remoteUploadReady ?? 0,
      firestoreRawStorageAllowed:
        summary.firestoreRawStorageAllowed === true,
      retentionDecisionRequired: summary.retentionDecisionRequired ?? 0,
    },
    blockers: Object.keys(summary.blockers ?? {}).sort(),
    nextActions: blocked > 0 ? [
      "Approve object storage bucket, retention, deletion, and crawl-cost policy before uploading raw payloads.",
    ] : [],
    commands: [
      "node tool/organizer_intake/plan_raw_artifact_storage.mjs --check",
    ],
    sourceArtifacts: [
      "tool/organizer_intake/generated/raw_artifact_storage_manifest.json",
    ],
  });
}

function crawlWorkstream({eventCrawlPlan, eventCrawlRunPlan}) {
  const runSummary = eventCrawlRunPlan.summary ?? {};
  const planSummary = eventCrawlPlan.summary ?? {};
  const status = (runSummary.wouldFetch ?? 0) > 0 ?
    "ready" :
    (runSummary.blocked ?? 0) > 0 ?
      "disabled_by_policy" :
      "idle";
  return workstream({
    id: "crawl_execution",
    label: "Crawl Execution",
    status,
    priority: status === "disabled_by_policy" ? "p1" : "p3",
    metrics: {
      crawlCapableSurfaces: planSummary.crawlCapableSurfaces ?? 0,
      approvedSurfaces: planSummary.approvedSurfaces ?? 0,
      blockedSurfaces: planSummary.blockedSurfaces ?? 0,
      runIntents: runSummary.candidateSurfaces ?? 0,
      wouldFetch: runSummary.wouldFetch ?? 0,
      blocked: runSummary.blocked ?? 0,
      schedulerEnabled:
        eventCrawlRunPlan.policy?.schedulerEnabled === true,
      networkEnabled:
        eventCrawlRunPlan.policy?.networkEnabled === true,
    },
    blockers: unique([
      ...Object.keys(planSummary.blockers ?? {}),
      ...Object.keys(runSummary.blockers ?? {}),
    ]),
    nextActions: status === "disabled_by_policy" ? [
      "Record crawl policy and budget decision before enabling any provider fetch.",
    ] : [],
    commands: [
      "node tool/organizer_intake/plan_event_crawl_runs.mjs --check",
    ],
    sourceArtifacts: [
      "tool/organizer_intake/generated/event_crawl_plan.json",
      "tool/organizer_intake/generated/event_crawl_run_plan.json",
    ],
  });
}

function externalEventWorkstream({
  externalEventCandidateQueue,
  externalEventImportExecutionPlan,
  externalEventImportPlan,
  externalEventLocationResolutionQueue,
}) {
  const candidates = externalEventCandidateQueue.summary ?? {};
  const importPlan = externalEventImportPlan.summary ?? {};
  const execution = externalEventImportExecutionPlan.summary ?? {};
  const locations = externalEventLocationResolutionQueue.summary ?? {};
  const status = (execution.wouldPublishReadOnly ?? execution.wouldCreate ?? 0) > 0 ?
    "dry_run_review_required" :
    (importPlan.blocked ?? 0) > 0 || (execution.blocked ?? 0) > 0 ?
      "blocked_by_policy" :
      (locations.tasks ?? 0) > 0 ?
        "review_needed" :
        "idle";
  return workstream({
    id: "external_event_imports",
    label: "External Event Imports",
    status,
    priority: status === "blocked_by_policy" ? "p1" : "p3",
    metrics: {
      candidates: candidates.candidates ?? 0,
      reviewed: candidates.reviewed ?? 0,
      approvedForImport: candidates.approvedForImport ?? 0,
      locationTasks: locations.tasks ?? 0,
      proposedReadOnlyEvents:
        importPlan.proposedReadOnlyEvents ?? importPlan.proposedCreates ?? 0,
      proposedCreates: importPlan.proposedCreates ?? 0,
      importBlocked: importPlan.blocked ?? 0,
      executionWouldPublishReadOnly:
        execution.wouldPublishReadOnly ?? execution.wouldCreate ?? 0,
      executionWouldCreate: 0,
      executionBlocked: execution.blocked ?? 0,
      projectionInvalid:
        execution.projectionInvalid ?? execution.schemaInvalid ?? 0,
      schemaInvalid: execution.schemaInvalid ?? 0,
      payloadInvalid:
        execution.projectionInvalidCount ?? execution.payloadInvalid ?? 0,
    },
    blockers: unique([
      ...Object.keys(importPlan.blockers ?? {}),
      ...Object.keys(execution.blockers ?? {}),
    ]),
    nextActions: status === "blocked_by_policy" ? [
      "Review event import policy before external candidates can write read-only external events.",
    ] : [],
    commands: [
      "node tool/organizer_intake/ingest_event_sources.mjs --check",
      "node tool/organizer_intake/plan_external_event_imports.mjs --check",
      "node tool/organizer_intake/preflight_external_event_imports.mjs --check",
    ],
    sourceArtifacts: [
      "tool/organizer_intake/generated/external_event_candidate_queue.json",
      "tool/organizer_intake/generated/external_event_import_plan.json",
      "tool/organizer_intake/generated/external_event_import_execution_plan.json",
    ],
  });
}

function searchIntakeWorkstream(searchResultCandidateQueue) {
  const summary = searchResultCandidateQueue.summary ?? {};
  return workstream({
    id: "search_intake",
    label: "Search Intake",
    status: (summary.candidates ?? 0) > 0 ? "curation_needed" : "idle",
    priority: (summary.candidates ?? 0) > 0 ? "p2" : "p3",
    metrics: {
      batches: summary.batches ?? 0,
      results: summary.results ?? 0,
      candidates: summary.candidates ?? 0,
      matchedExistingEntities: summary.matchedExistingEntities ?? 0,
      duplicateNormalizedKeys: summary.duplicateNormalizedKeys ?? 0,
    },
    blockers: (summary.duplicateNormalizedKeys ?? 0) > 0 ?
      ["duplicate_normalized_keys"] :
      [],
    nextActions: (summary.candidates ?? 0) > 0 ? [
      "Attach, split, suppress, or reject candidate surfaces through curation.",
    ] : [],
    commands: [
      "node tool/organizer_intake/ingest_search_results.mjs --check",
    ],
    sourceArtifacts: [
      "tool/organizer_intake/generated/search_result_candidate_queue.json",
    ],
  });
}

function evidenceWorkstream(canonicalEvidenceIndex) {
  const summary = canonicalEvidenceIndex.summary ?? {};
  const missing = summary.surfacesWithoutEvidence ?? 0;
  const manualOnly = summary.manualReportsWithoutArtifacts ?? 0;
  return workstream({
    id: "evidence_quality",
    label: "Evidence Quality",
    status: missing > 0 ? "blocked" : manualOnly > 0 ? "review_needed" : "clear",
    priority: missing > 0 ? "p0" : manualOnly > 0 ? "p1" : "p3",
    metrics: {
      records: summary.records ?? 0,
      surfaces: summary.surfaces ?? 0,
      resolvedArtifactRefs: summary.resolvedArtifactRefs ?? 0,
      surfacesWithoutEvidence: missing,
      manualReportsWithoutArtifacts: manualOnly,
      rawProviderArtifacts: summary.rawProviderArtifacts ?? 0,
      firestoreForbiddenArtifactRefs:
        summary.firestoreForbiddenArtifactRefs ?? 0,
    },
    blockers: missing > 0 ? ["missing_surface_evidence"] : [],
    nextActions: manualOnly > 0 ? [
      "Admin publication approvals must acknowledge manual reports without artifacts.",
    ] : [],
    commands: [
      "node tool/organizer_intake/organizer_intake.mjs --check",
    ],
    sourceArtifacts: [
      "tool/organizer_intake/generated/canonical_evidence_index.json",
    ],
  });
}

function workstream({
  blockers = [],
  commands = [],
  id,
  label,
  metrics = {},
  nextActions = [],
  priority,
  sourceArtifacts = [],
  status,
}) {
  return {
    id,
    label,
    status,
    priority,
    metrics,
    blockers: unique(blockers.filter(Boolean)),
    nextActions: unique(nextActions.filter(Boolean)),
    commands: unique(commands.filter(Boolean)).slice(0, 6),
    sourceArtifacts: unique(sourceArtifacts),
  };
}

function summaryFor({operatorActionQueue, workstreams, workflowReadiness}) {
  const actionRequiredWorkstreams = workstreams.filter((stream) =>
    actionStatuses.has(stream.status)).length;
  const policyBlockedWorkstreams = workstreams.filter((stream) =>
    stream.status === "blocked_by_policy" ||
    stream.status === "disabled_by_policy").length;
  const blockedWorkstreams = workstreams.filter((stream) =>
    blockingStatuses.has(stream.status)).length;
  const waitingWorkstreams = workstreams.filter((stream) =>
    waitingStatuses.has(stream.status)).length;
  const readyWorkstreams = workstreams.filter((stream) =>
    stream.status === "ready" || stream.status === "clear").length;
  const healthStatus = statusForSummary({
    actionRequiredWorkstreams,
    blockedWorkstreams,
    operatorActionQueue,
    policyBlockedWorkstreams,
    waitingWorkstreams,
  });

  return {
    healthStatus,
    workstreams: workstreams.length,
    readyWorkstreams,
    actionRequiredWorkstreams,
    policyBlockedWorkstreams,
    blockedWorkstreams,
    waitingWorkstreams,
    idleWorkstreams: workstreams.filter((stream) =>
      stream.status === "idle").length,
    highestPriority: highestWorkstreamPriority(workstreams),
    operatorActions: operatorActionQueue.summary?.actions ?? 0,
    adminDecisionsRequired:
      operatorActionQueue.summary?.adminDecisionsRequired ?? 0,
    policyInputsRequired:
      operatorActionQueue.summary?.policyInputsRequired ?? 0,
    waitingActions: operatorActionQueue.summary?.waitingActions ?? 0,
    workflowReady: workflowReadiness.summary?.ready ?? 0,
    workflowWaiting: workflowReadiness.summary?.waiting ?? 0,
    workflowBlocked: workflowReadiness.summary?.blocked ?? 0,
    workflowPolicyNeeded: workflowReadiness.summary?.policyNeeded ?? 0,
    workstreamsByStatus: countBy(workstreams, "status"),
    workstreamsByPriority: countBy(workstreams, "priority"),
  };
}

function statusForSummary({
  actionRequiredWorkstreams,
  blockedWorkstreams,
  operatorActionQueue,
  policyBlockedWorkstreams,
  waitingWorkstreams,
}) {
  if ((operatorActionQueue.summary?.actionsByPriority?.p0 ?? 0) > 0) {
    return "p0_action_required";
  }
  if (actionRequiredWorkstreams > 0) return "action_required";
  if (blockedWorkstreams > 0 || policyBlockedWorkstreams > 0) {
    return "blocked_by_policy";
  }
  if (waitingWorkstreams > 0) return "waiting";
  return "ready";
}

function workstreamComparator(left, right) {
  return (priorityRank[left.priority] ?? 99) -
    (priorityRank[right.priority] ?? 99) ||
    statusRank(left.status) - statusRank(right.status) ||
    left.id.localeCompare(right.id);
}

function statusRank(status) {
  if (actionStatuses.has(status)) return 0;
  if (blockingStatuses.has(status)) return 1;
  if (waitingStatuses.has(status)) return 2;
  if (status === "ready" || status === "clear") return 3;
  return 4;
}

function actionsOfType(queue, actionType) {
  return (queue.actions ?? []).filter((action) =>
    action.actionType === actionType);
}

function actionsOfStatusPrefix(queue, statusPrefix) {
  return (queue.actions ?? []).filter((action) =>
    action.status?.startsWith(statusPrefix));
}

function commandsFrom(actions) {
  return unique(actions.flatMap((action) => action.commands ?? []));
}

function gateById(workflowReadiness, id) {
  return (workflowReadiness.gates ?? []).find((gate) => gate.id === id) ?? null;
}

function highestActionPriority(actions) {
  return highestPriority(actions.map((action) => action.priority));
}

function highestWorkstreamPriority(workstreams) {
  return highestPriority(workstreams.map((stream) => stream.priority));
}

function highestPriority(priorities) {
  return priorities
    .filter(Boolean)
    .sort((left, right) =>
      (priorityRank[left] ?? 99) - (priorityRank[right] ?? 99))[0] ?? null;
}

function countBy(items, field) {
  return Object.fromEntries([...items.reduce((counts, item) => {
    const key = item[field] ?? "unknown";
    counts.set(key, (counts.get(key) ?? 0) + 1);
    return counts;
  }, new Map()).entries()].sort(([left], [right]) =>
    String(left).localeCompare(String(right))));
}

function unique(values) {
  return [...new Set(values.filter((value) =>
    value !== undefined && value !== null && value !== ""))];
}

function emptyCanonicalEvidenceIndex() {
  return {summary: {}};
}

function emptyCanonicalHostEntities() {
  return {summary: {}};
}

function emptyClaimTargetSyncPreview() {
  return {commands: {}, mode: {}, summary: {}};
}

function emptyEventCrawlPlan() {
  return {summary: {}};
}

function emptyEventCrawlRunPlan() {
  return {policy: {}, summary: {}};
}

function emptyExternalEventCandidateQueue() {
  return {summary: {}};
}

function emptyExternalEventImportExecutionPlan() {
  return {summary: {}};
}

function emptyExternalEventImportPlan() {
  return {summary: {}};
}

function emptyExternalEventLocationResolutionQueue() {
  return {summary: {}};
}

function emptyOperatorActionQueue() {
  return {actions: [], summary: {actionsByPriority: {}}};
}

function emptyPolicyDecisionPackets() {
  return {summary: {}};
}

function emptyPolicyGapRegister() {
  return {summary: {}};
}

function emptyPublicationDecisionImpactPreview() {
  return {summary: {}};
}

function emptyPublicationReviewPackets() {
  return {summary: {}};
}

function emptyRawArtifactStorageManifest() {
  return {summary: {}};
}

function emptySearchResultCandidateQueue() {
  return {summary: {}};
}

function emptyWorkflowReadiness() {
  return {commands: {}, gates: [], summary: {}};
}
