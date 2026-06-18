export function buildOrganizerPromotionExecutionPacket({
  pendingInputRequest = emptyPendingInputRequest(),
  pendingWorkCoverage = emptyPendingWorkCoverage(),
  pendingDecisionAnswerPacket = emptyPendingDecisionAnswerPacket(),
  reviewedDecisionAnswerPackets = emptyReviewedDecisionAnswerPackets(),
  workflowReadiness = emptyWorkflowReadiness(),
  publicationDecisionImpactPreview = emptyPublicationDecisionImpactPreview(),
  claimTargetSyncPreview = emptyClaimTargetSyncPreview(),
  projectionPlan = emptyProjectionPlan(),
} = {}) {
  const summary = buildSummary({
    claimTargetSyncPreview,
    pendingDecisionAnswerPacket,
    pendingInputRequest,
    pendingWorkCoverage,
    projectionPlan,
    publicationDecisionImpactPreview,
    reviewedDecisionAnswerPackets,
    workflowReadiness,
  });
  const phases = buildPhases({summary, workflowReadiness});
  const phaseCounts = countBy(phases, "status");

  return {
    schemaVersion: 1,
    generatedFrom: {
      pendingInputRequest:
        "tool/organizer_intake/generated/organizer_pending_input_request.json",
      pendingWorkCoverage:
        "tool/organizer_intake/generated/organizer_pending_work_coverage.json",
      pendingDecisionAnswerPacket:
        "tool/organizer_intake/generated/organizer_pending_decision_answer_packet.json",
      reviewedDecisionAnswerPackets:
        "tool/organizer_intake/generated/organizer_reviewed_decision_answer_packets.json",
      workflowReadiness:
        "tool/organizer_intake/generated/organizer_workflow_readiness.json",
      publicationDecisionImpactPreview:
        "tool/organizer_intake/generated/publication_decision_impact_preview.json",
      claimTargetSyncPreview:
        "tool/organizer_intake/generated/organizer_claim_target_sync_preview.json",
      projectionPlan:
        "tool/organizer_intake/generated/public_projection_plan.json",
    },
    summary: {
      ...summary,
      phases: phases.length,
      phasesByStatus: phaseCounts,
      blockedPhases: phases.filter((phase) =>
        phase.status.startsWith("blocked") ||
          phase.status.startsWith("waiting") ||
          phase.status.startsWith("disabled")).length,
      guardedRemoteReadPhases: phases.filter((phase) =>
        phase.executionMode === "remote_read_local_write_guarded").length,
      guardedRemoteWritePhases: phases.filter((phase) =>
        phase.executionMode === "remote_write_guarded").length,
    },
    guardrails: [
      "This packet is a promotion execution preflight only; it never exports decisions, builds the website, writes Firestore, deploys pages, or syncs claim targets.",
      "Public unclaimed Host pages become deployable only after admin publication approval is exported, intake artifacts are regenerated, website listings are regenerated, and the promotion bridge passes.",
      "Claim-target writes require a reviewed generated preview plus a live Firestore dry run before any --write flag is used.",
      "Policy inputs for crawling, raw artifact storage, provider location lookup, event imports, and naming migration remain separate from public-page promotion and must not be inferred from publication approval.",
    ],
    phases,
  };
}

function buildSummary({
  claimTargetSyncPreview,
  pendingDecisionAnswerPacket,
  pendingInputRequest,
  pendingWorkCoverage,
  projectionPlan,
  publicationDecisionImpactPreview,
  reviewedDecisionAnswerPackets,
  workflowReadiness,
}) {
  const pendingAdminDecisions =
    pendingInputRequest.summary?.adminPublicationRequests ??
      countRequests(pendingInputRequest, "admin_publication_decision");
  const pendingPolicyDecisions =
    pendingInputRequest.summary?.policyDecisionRequests ??
      countRequests(pendingInputRequest, "policy_decision");
  const pendingAnswerSlots =
    pendingDecisionAnswerPacket.summary?.answerSlots ??
      (pendingDecisionAnswerPacket.answerSlots ?? []).length;
  const reviewedAnswerPackets =
    reviewedDecisionAnswerPackets.summary?.packets ?? 0;
  const reviewedAnswerPacketsReady =
    reviewedDecisionAnswerPackets.summary?.readyToApply ?? 0;
  const reviewedAnswerPacketsAwaitingAnswers =
    reviewedDecisionAnswerPackets.summary?.awaitingAnswers ?? 0;
  const reviewedAnswerPacketsInvalid =
    reviewedDecisionAnswerPackets.summary?.invalid ?? 0;
  const reviewedAnswerPacketsStale =
    reviewedDecisionAnswerPackets.summary?.stale ?? 0;
  const reviewedAnswerPacketStatus =
    reviewedDecisionAnswerPackets.summary?.status ?? "no_reviewed_packets";
  const approvedPublicProjections =
    projectionPlan.summary?.approvedPublic ?? countApprovedProjections(projectionPlan);
  const publicationImpacts =
    publicationDecisionImpactPreview.summary?.impacts ??
      (publicationDecisionImpactPreview.impacts ?? []).length;
  const publicationImpactWouldPublish =
    publicationDecisionImpactPreview.summary?.wouldPublish ?? 0;
  const claimTargetPreviewWrites =
    claimTargetSyncPreview.summary?.writesNeeded ?? 0;
  const claimTargetPreviewTargets =
    claimTargetSyncPreview.summary?.targets ?? 0;
  const untriagedWorkstreams =
    pendingWorkCoverage.summary?.untriagedWorkstreams ?? 0;
  const workflowSummary = workflowReadiness.summary ?? {};

  return {
    status: statusFor({
      approvedPublicProjections,
      pendingAdminDecisions,
      pendingAnswerSlots,
      untriagedWorkstreams,
    }),
    localPromotionPipelineReady:
      workflowSummary.localPromotionPipelineReady === true,
    publicProjectionReady: workflowSummary.publicProjectionReady === true,
    claimSyncReady: workflowSummary.claimSyncReady === true,
    pendingAdminDecisions,
    pendingPolicyDecisions,
    pendingAnswerSlots,
    reviewedAnswerPacketStatus,
    reviewedAnswerPackets,
    reviewedAnswerPacketsReady,
    reviewedAnswerPacketsAwaitingAnswers,
    reviewedAnswerPacketsInvalid,
    reviewedAnswerPacketsStale,
    pendingWorkUntriaged: untriagedWorkstreams,
    approvedPublicProjections,
    publicationImpacts,
    publicationImpactWouldPublish,
    claimTargetPreviewTargets,
    claimTargetPreviewWrites,
    canRunLocalPreview:
      untriagedWorkstreams === 0 &&
        workflowSummary.localPromotionPipelineReady === true,
    canDeployNewPublicPages:
      pendingAdminDecisions === 0 &&
        approvedPublicProjections > 0 &&
        workflowSummary.publicProjectionReady === true,
    canWriteClaimTargets:
      pendingAdminDecisions === 0 &&
        claimTargetPreviewWrites > 0 &&
        workflowSummary.claimSyncReady === true,
    policyInputRequiredBeforeCrawlStorageOrImport:
      pendingPolicyDecisions > 0,
  };
}

function buildPhases({summary, workflowReadiness}) {
  const commands = workflowReadiness.commands ?? {};
  const adminDecisionStatus = summary.pendingAdminDecisions > 0 ?
    "waiting_on_admin_review" :
    "ready";
  const policyDecisionStatus = summary.pendingPolicyDecisions > 0 ?
    "waiting_on_policy_input" :
    "ready";
  const applyAnsweredDecisionsStatus = applyAnsweredDecisionStatus(summary);
  const projectionStatus = summary.approvedPublicProjections > 0 ?
    "ready" :
    "waiting_on_public_projection";
  const claimPreviewStatus = summary.claimTargetPreviewWrites > 0 ?
    "ready_for_firestore_dry_run" :
    "waiting_on_public_projection";
  const claimWriteStatus = summary.canWriteClaimTargets ?
    "ready_after_reviewed_firestore_dry_run" :
    "disabled_until_public_projection_and_dry_run";

  return [
    {
      phaseId: "review_admin_publication_decisions",
      label: "Review admin publication decisions",
      status: adminDecisionStatus,
      executionMode: "manual_review",
      command:
        "node tool/organizer_intake/pending_decision_answer_packet.mjs --format markdown",
      blockers: summary.pendingAdminDecisions > 0 ? [
        `${summary.pendingAdminDecisions} admin publication decision(s) pending`,
      ] : [],
      outputs: [
        "filled organizer_pending_decision_answer_packet copy",
        "organizerIntakeReviewDecisions Firestore documents or repo-backed review_decisions JSON",
      ],
    },
    {
      phaseId: "review_product_policy_decisions",
      label: "Review product policy decisions",
      status: policyDecisionStatus,
      executionMode: "manual_review",
      command:
        "node tool/organizer_intake/pending_decision_answer_packet.mjs --format markdown",
      blockers: summary.pendingPolicyDecisions > 0 ? [
        `${summary.pendingPolicyDecisions} product policy decision(s) pending`,
      ] : [],
      outputs: [
        "filled organizer_pending_decision_answer_packet copy",
        "organizerPolicyGapReviewDecisions Firestore documents or repo-backed policy_gap_decisions JSON",
      ],
    },
    {
      phaseId: "apply_answered_decision_packet",
      label: "Apply answered decision packet",
      status: applyAnsweredDecisionsStatus,
      executionMode: "local_write_guarded",
      command:
        "node tool/organizer_intake/run_promotion_pipeline.mjs " +
          "--apply-decision-answers --answer-packet PATH --write-decision-answers",
      blockers: summary.pendingAnswerSlots > 0 ? [
        `${summary.pendingAnswerSlots} answer slot(s) remain in generated packet`,
        summary.reviewedAnswerPacketsReady > 0 ?
          `${summary.reviewedAnswerPacketsReady} reviewed answer packet(s) ready to apply` :
          "no reviewed answer packet is ready to apply",
        summary.reviewedAnswerPacketsStale > 0 ?
          `${summary.reviewedAnswerPacketsStale} reviewed answer packet(s) stale` :
          null,
        summary.reviewedAnswerPacketsInvalid > 0 ?
          `${summary.reviewedAnswerPacketsInvalid} reviewed answer packet(s) invalid` :
          null,
        "use --write only against a reviewed copied answer packet",
      ].filter(Boolean) : [],
      outputs: [
        "reviewed answer-packet readiness check",
        "dry-run preflight for every answered decision command",
        "review_decisions JSON",
        "policy_gap_decisions JSON",
      ],
    },
    {
      phaseId: "export_review_decisions",
      label: "Export reviewed admin and policy decisions",
      status: adminDecisionStatus,
      executionMode: "remote_read_local_write_guarded",
      command:
        commands.exportCurationAndReview ??
          "node tool/organizer_intake/run_promotion_pipeline.mjs --export-review-decisions --date YYYY-MM-DD --write-export",
      blockers: summary.pendingAdminDecisions > 0 ? [
        "admin publication decisions must exist before export is useful",
      ] : [],
      outputs: [
        "review_decisions JSON",
        "curation_decisions JSON",
        "event_review_decisions JSON",
        "event_location_resolutions JSON",
        "policy_gap_decisions JSON",
      ],
    },
    {
      phaseId: "local_promotion_preview",
      label: "Run local promotion preview",
      status: summary.canRunLocalPreview ? "ready" : "blocked_by_untriaged_work",
      executionMode: "local",
      command:
        commands.localPromotionPreview ??
          "node tool/organizer_intake/run_promotion_pipeline.mjs",
      blockers: summary.pendingWorkUntriaged > 0 ? [
        `${summary.pendingWorkUntriaged} untriaged workstream(s) remain`,
      ] : [],
      outputs: [
        "regenerated organizer intake artifacts",
        "regenerated website organizer listings",
        "admin bridge validation",
        "promotion bridge validation",
        "marketing website build",
        "fixture claim-target sync preview",
      ],
    },
    {
      phaseId: "validate_promotion_bridge",
      label: "Validate public listing and claim-target bridge",
      status: projectionStatus,
      executionMode: "local",
      command: "node tool/organizer_intake/check_promotion_bridge.mjs",
      blockers: summary.approvedPublicProjections === 0 ? [
        "no approved public projections exist yet",
      ] : [],
      outputs: [
        "canonical Host entity to website listing parity",
        "website listing to claim target parity",
        "empty-fixture claim-target sync preview parity",
      ],
    },
    {
      phaseId: "build_marketing_website",
      label: "Build marketing website",
      status: projectionStatus,
      executionMode: "local",
      command: "npm --workspace catch-marketing run build",
      blockers: summary.approvedPublicProjections === 0 ? [
        "website build can run, but no new organizer-intake public pages are approved",
      ] : [],
      outputs: [
        "route HTML",
        "canonical tags",
        "robots tags",
        "sitemap",
      ],
    },
    {
      phaseId: "claim_target_firestore_dry_run",
      label: "Run Firestore claim-target dry run",
      status: claimPreviewStatus,
      executionMode: "remote_read_local_preview",
      command:
        commands.reviewedClaimSync ??
          "node tool/organizer_intake/run_promotion_pipeline.mjs --claim-sync firestore --env ENV",
      blockers: summary.claimTargetPreviewWrites === 0 ? [
        "no claim-target preview writes exist until a public projection is approved",
      ] : [],
      outputs: [
        "live Firestore create/refresh/skip preview",
      ],
    },
    {
      phaseId: "claim_target_firestore_write",
      label: "Write reviewed claim targets",
      status: claimWriteStatus,
      executionMode: "remote_write_guarded",
      command:
        commands.writeClaimTargets ??
          "node tool/organizer_intake/run_promotion_pipeline.mjs --claim-sync firestore --env ENV --write-claim-targets",
      blockers: summary.canWriteClaimTargets ? [] : [
        "requires approved public projections",
        "requires generated claim-target preview writes",
        "requires a reviewed Firestore dry run",
        "requires explicit --write-claim-targets guard",
      ],
      outputs: [
        "clubs/{entityId} unclaimed claim-target documents",
      ],
    },
  ];
}

function applyAnsweredDecisionStatus(summary) {
  if (summary.pendingAnswerSlots === 0) return "ready";
  if (summary.reviewedAnswerPacketsInvalid > 0 ||
    summary.reviewedAnswerPacketsStale > 0) {
    return "blocked_by_invalid_answer_packet";
  }
  if (summary.reviewedAnswerPacketsReady > 0) {
    return "ready_to_apply_reviewed_answer_packet";
  }
  if (summary.reviewedAnswerPacketsAwaitingAnswers > 0) {
    return "waiting_on_completed_answer_packet";
  }
  return "waiting_on_answer_packet";
}

function statusFor({
  approvedPublicProjections,
  pendingAdminDecisions,
  pendingAnswerSlots,
  untriagedWorkstreams,
}) {
  if (untriagedWorkstreams > 0) return "untriaged_work";
  if (pendingAdminDecisions > 0) return "waiting_on_admin_publication_review";
  if (pendingAnswerSlots > 0) return "waiting_on_policy_input";
  if (approvedPublicProjections === 0) return "waiting_on_public_projection";
  return "ready_for_reviewed_promotion";
}

function countRequests(pendingInputRequest, requestType) {
  return (pendingInputRequest.requests ?? [])
    .filter((request) => request.requestType === requestType).length;
}

function countApprovedProjections(projectionPlan) {
  return (projectionPlan.entries ?? []).filter((entry) =>
    entry.projectionStatus === "ready" &&
      entry.publishStatus === "published" &&
      entry.publicListing).length;
}

function countBy(items, field) {
  return Object.fromEntries([...items.reduce((counts, item) => {
    const key = item[field] ?? "unknown";
    counts.set(key, (counts.get(key) ?? 0) + 1);
    return counts;
  }, new Map()).entries()].sort(([left], [right]) =>
    String(left).localeCompare(String(right))));
}

function emptyPendingInputRequest() {
  return {requests: [], summary: {}};
}

function emptyPendingWorkCoverage() {
  return {entries: [], summary: {untriagedWorkstreams: 0}};
}

function emptyPendingDecisionAnswerPacket() {
  return {answerSlots: [], summary: {}};
}

function emptyReviewedDecisionAnswerPackets() {
  return {
    entries: [],
    summary: {
      awaitingAnswers: 0,
      invalid: 0,
      packets: 0,
      readyToApply: 0,
      stale: 0,
      status: "no_reviewed_packets",
    },
  };
}

function emptyWorkflowReadiness() {
  return {commands: {}, summary: {}};
}

function emptyPublicationDecisionImpactPreview() {
  return {impacts: [], summary: {}};
}

function emptyClaimTargetSyncPreview() {
  return {actions: [], summary: {}};
}

function emptyProjectionPlan() {
  return {entries: [], summary: {}};
}
