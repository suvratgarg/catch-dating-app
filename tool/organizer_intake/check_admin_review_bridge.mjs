#!/usr/bin/env node
import fs from "node:fs";
import path from "node:path";
import {fileURLToPath, pathToFileURL} from "node:url";

const scriptDir = path.dirname(fileURLToPath(import.meta.url));
const repoRoot = path.resolve(scriptDir, "..", "..");

export const adminReviewBridgeChannels = [
  {
    id: "organizer_publication",
    label: "Organizer publication review",
    callableName: "adminDecideOrganizerIntake",
    adminApiWrapper: "decideOrganizerIntake",
    payloadType: "AdminDecideOrganizerIntakePayload",
    responseType: "AdminDecideOrganizerIntakeResponse",
    handlerFile: "functions/src/admin/organizerIntake.ts",
    handlerTest: "functions/src/admin/organizerIntake.test.ts",
    payloadSchema:
      "contracts/callables/admin_decide_organizer_intake_payload.schema.json",
    firestoreSchema:
      "contracts/firestore/organizer_intake_review_decisions.schema.json",
    generatedPayload:
      "functions/src/shared/generated/adminDecideOrganizerIntakeCallablePayload.ts",
    generatedDocument:
      "functions/src/shared/generated/organizerIntakeReviewDecisionDocument.ts",
    firestoreCollection: "organizerIntakeReviewDecisions",
    exporter: "tool/organizer_intake/export_review_decisions_from_firestore.mjs",
    exporterTest:
      "tool/organizer_intake/export_review_decisions_from_firestore.test.mjs",
    localDecisionRoot: "tool/organizer_intake/review_decisions",
    localDecisionCli: "tool/organizer_intake/review_decision.mjs",
    pipelineFlag: "--export-review-decisions",
    pipelineLabel: "export review decisions",
    toolId: "organizer-intake:export-review-decisions",
  },
  {
    id: "organizer_curation",
    label: "Organizer dedupe curation",
    callableName: "adminRecordOrganizerCuration",
    adminApiWrapper: "recordOrganizerCuration",
    payloadType: "AdminRecordOrganizerCurationPayload",
    responseType: "AdminRecordOrganizerCurationResponse",
    handlerFile: "functions/src/admin/organizerCuration.ts",
    handlerTest: "functions/src/admin/organizerCuration.test.ts",
    payloadSchema:
      "contracts/callables/admin_record_organizer_curation_payload.schema.json",
    firestoreSchema:
      "contracts/firestore/organizer_intake_curation_decisions.schema.json",
    generatedPayload:
      "functions/src/shared/generated/adminRecordOrganizerCurationCallablePayload.ts",
    generatedDocument:
      "functions/src/shared/generated/organizerIntakeCurationDecisionDocument.ts",
    firestoreCollection: "organizerIntakeCurationDecisions",
    exporter:
      "tool/organizer_intake/export_curation_decisions_from_firestore.mjs",
    exporterTest:
      "tool/organizer_intake/export_curation_decisions_from_firestore.test.mjs",
    localDecisionRoot: "tool/organizer_intake/curation_decisions",
    localDecisionCli: "tool/organizer_intake/curation_decision.mjs",
    pipelineFlag: "--export-curation-decisions",
    pipelineLabel: "export curation decisions",
    toolId: "organizer-intake:export-curation-decisions",
  },
  {
    id: "external_event_candidate_review",
    label: "External event candidate review",
    callableName: "adminDecideOrganizerEventCandidate",
    adminApiWrapper: "decideOrganizerEventCandidate",
    payloadType: "AdminDecideOrganizerEventCandidatePayload",
    responseType: "AdminDecideOrganizerEventCandidateResponse",
    handlerFile: "functions/src/admin/organizerEventIntake.ts",
    handlerTest: "functions/src/admin/organizerEventIntake.test.ts",
    payloadSchema:
      "contracts/callables/admin_decide_organizer_event_candidate_payload.schema.json",
    firestoreSchema:
      "contracts/firestore/organizer_event_candidate_review_decisions.schema.json",
    generatedPayload:
      "functions/src/shared/generated/adminDecideOrganizerEventCandidateCallablePayload.ts",
    generatedDocument:
      "functions/src/shared/generated/organizerEventCandidateReviewDecisionDocument.ts",
    firestoreCollection: "organizerEventCandidateReviewDecisions",
    exporter:
      "tool/organizer_intake/export_event_review_decisions_from_firestore.mjs",
    exporterTest:
      "tool/organizer_intake/export_event_review_decisions_from_firestore.test.mjs",
    localDecisionRoot: "tool/organizer_intake/event_review_decisions",
    localDecisionCli: "tool/organizer_intake/event_review_decision.mjs",
    pipelineFlag: "--export-event-review-decisions",
    pipelineLabel: "export event review decisions",
    toolId: "organizer-intake:export-event-review-decisions",
  },
  {
    id: "external_event_location_resolution",
    label: "External event location resolution",
    callableName: "adminResolveOrganizerEventLocation",
    adminApiWrapper: "resolveOrganizerEventLocation",
    payloadType: "AdminResolveOrganizerEventLocationPayload",
    responseType: "AdminResolveOrganizerEventLocationResponse",
    handlerFile: "functions/src/admin/organizerEventLocationResolution.ts",
    handlerTest: "functions/src/admin/organizerEventLocationResolution.test.ts",
    payloadSchema:
      "contracts/callables/admin_resolve_organizer_event_location_payload.schema.json",
    firestoreSchema:
      "contracts/firestore/organizer_event_location_resolution_decisions.schema.json",
    generatedPayload:
      "functions/src/shared/generated/adminResolveOrganizerEventLocationCallablePayload.ts",
    generatedDocument:
      "functions/src/shared/generated/organizerEventLocationResolutionDecisionDocument.ts",
    firestoreCollection: "organizerEventLocationResolutionDecisions",
    exporter:
      "tool/organizer_intake/export_event_location_resolutions_from_firestore.mjs",
    exporterTest:
      "tool/organizer_intake/export_event_location_resolutions_from_firestore.test.mjs",
    localDecisionRoot: "tool/organizer_intake/event_location_resolutions",
    localDecisionCli: "tool/organizer_intake/event_location_resolution.mjs",
    pipelineFlag: "--export-event-location-resolutions",
    pipelineLabel: "export event location resolutions",
    toolId: "organizer-intake:export-event-location-resolutions",
  },
  {
    id: "organizer_policy_gap_review",
    label: "Organizer policy gap review",
    callableName: "adminDecideOrganizerPolicyGap",
    adminApiWrapper: "decideOrganizerPolicyGap",
    payloadType: "AdminDecideOrganizerPolicyGapPayload",
    responseType: "AdminDecideOrganizerPolicyGapResponse",
    handlerFile: "functions/src/admin/organizerPolicyGap.ts",
    handlerTest: "functions/src/admin/organizerPolicyGap.test.ts",
    payloadSchema:
      "contracts/callables/admin_decide_organizer_policy_gap_payload.schema.json",
    firestoreSchema:
      "contracts/firestore/organizer_policy_gap_review_decisions.schema.json",
    generatedPayload:
      "functions/src/shared/generated/adminDecideOrganizerPolicyGapCallablePayload.ts",
    generatedDocument:
      "functions/src/shared/generated/organizerPolicyGapReviewDecisionDocument.ts",
    firestoreCollection: "organizerPolicyGapReviewDecisions",
    exporter:
      "tool/organizer_intake/export_policy_gap_decisions_from_firestore.mjs",
    exporterTest:
      "tool/organizer_intake/export_policy_gap_decisions_from_firestore.test.mjs",
    localDecisionRoot: "tool/organizer_intake/policy_gap_decisions",
    localDecisionCli: "tool/organizer_intake/policy_gap_decision.mjs",
    pipelineFlag: "--export-policy-gap-decisions",
    pipelineLabel: "export policy gap decisions",
    toolId: "organizer-intake:export-policy-gap-decisions",
  },
];

const sharedFiles = {
  adminApi: "admin/src/adminApi.ts",
  adminApp: "admin/src/App.tsx",
  adminBridge: "admin/src/generated/organizerIntakeBridge.json",
  adminTypes: "admin/src/types.ts",
  generatedPendingInputRequest:
    "tool/organizer_intake/generated/organizer_pending_input_request.json",
  generatedPendingWorkCoverage:
    "tool/organizer_intake/generated/organizer_pending_work_coverage.json",
  generatedReviewedDecisionAnswerPackets:
    "tool/organizer_intake/generated/organizer_reviewed_decision_answer_packets.json",
  generatedPromotionExecutionPacket:
    "tool/organizer_intake/generated/organizer_promotion_execution_packet.json",
  pendingInputCli: "tool/organizer_intake/pending_input_request.mjs",
  pendingWorkCoverageCli: "tool/organizer_intake/pending_work_coverage.mjs",
  reviewedDecisionAnswerPacketsCli:
    "tool/organizer_intake/reviewed_decision_answer_packets.mjs",
  promotionExecutionCli: "tool/organizer_intake/promotion_execution_packet.mjs",
  functionsIndex: "functions/src/index.ts",
  readme: "tool/organizer_intake/README.md",
  runPipeline: "tool/organizer_intake/run_promotion_pipeline.mjs",
  toolsManifest: "tool/tools_manifest.json",
  remoteOpsManifest: "tool/remote_ops_manifest.json",
};

const exactEmbeddedGeneratedArtifacts = [
  {
    bridgeKey: "canonicalEvidenceIndex",
    sourceKey: "canonicalEvidenceIndex",
  },
  {
    bridgeKey: "canonicalHostEntities",
    sourceKey: "canonicalHostEntities",
  },
  {
    bridgeKey: "claimTargetSyncPreview",
    sourceKey: "claimTargetSyncPreview",
  },
  {
    bridgeKey: "operationalHealth",
    sourceKey: "operationalHealth",
  },
  {
    bridgeKey: "operatorActionQueue",
    sourceKey: "operatorActionQueue",
  },
  {
    bridgeKey: "policyDecisionPackets",
    sourceKey: "policyDecisionPackets",
  },
  {
    bridgeKey: "policyGaps",
    sourceKey: "policyGapRegister",
  },
  {
    bridgeKey: "publicationDecisionImpactPreview",
    sourceKey: "publicationDecisionImpactPreview",
  },
  {
    bridgeKey: "publicationReviewPackets",
    sourceKey: "publicationReviewPackets",
  },
  {
    bridgeKey: "reviewedDecisionAnswerPackets",
    sourceKey: "reviewedDecisionAnswerPackets",
  },
  {
    bridgeKey: "promotionExecutionPacket",
    sourceKey: "promotionExecutionPacket",
  },
];

if (isMain()) {
  main();
}

export function checkAdminReviewBridge({
  root = repoRoot,
  channels = adminReviewBridgeChannels,
} = {}) {
  const errors = [];
  const warnings = [];
  const fileCache = new Map();

  for (const [label, file] of Object.entries(sharedFiles)) {
    requireFile({root, file, label, errors});
  }

  for (const channel of channels) {
    checkChannel({root, channel, errors, warnings, fileCache});
  }
  checkExactEmbeddedGeneratedArtifactParity({root, errors, fileCache});
  const pendingInputBridge = checkPendingInputBridge({
    root,
    errors,
    fileCache,
  });
  const pendingWorkCoverageBridge = checkPendingWorkCoverageBridge({
    root,
    errors,
    fileCache,
  });
  const reviewedDecisionAnswerPacketsBridge =
    checkReviewedDecisionAnswerPacketsBridge({
      root,
      errors,
      fileCache,
    });
  const promotionExecutionBridge = checkPromotionExecutionBridge({
    root,
    errors,
    fileCache,
  });
  checkBridgeItemDecisionCommands({root, errors, fileCache});

  return {
    ok: errors.length === 0,
    errors,
    warnings,
    summary: {
      channels: channels.length,
      readyChannels: errors.length === 0 ? channels.length : readyChannelCount({
        root,
        channels,
        fileCache,
      }),
      firestoreCollections: channels
        .map((channel) => channel.firestoreCollection)
        .sort(),
      exporters: channels.map((channel) => channel.exporter).sort(),
      pendingInputRequests: pendingInputBridge?.summary?.requests ?? 0,
      pendingInputFollowUps: pendingInputBridge?.summary?.workflowFollowUps ?? 0,
      pendingInputCallableSubmissions:
        pendingInputBridge?.requests?.filter((request) =>
          request.callableSubmission
        ).length ?? 0,
      pendingWorkCovered:
        pendingWorkCoverageBridge?.summary?.coveredWorkstreams ?? 0,
      pendingWorkUntriaged:
        pendingWorkCoverageBridge?.summary?.untriagedWorkstreams ?? 0,
      reviewedAnswerPacketStatus:
        reviewedDecisionAnswerPacketsBridge?.summary?.status ?? "missing",
      reviewedAnswerPackets:
        reviewedDecisionAnswerPacketsBridge?.summary?.packets ?? 0,
      reviewedAnswerPacketsReady:
        reviewedDecisionAnswerPacketsBridge?.summary?.readyToApply ?? 0,
      reviewedAnswerPacketsStale:
        reviewedDecisionAnswerPacketsBridge?.summary?.stale ?? 0,
      promotionExecutionStatus:
        promotionExecutionBridge?.summary?.status ?? "missing",
      promotionExecutionPhases:
        promotionExecutionBridge?.summary?.phases ?? 0,
      promotionExecutionBlockedPhases:
        promotionExecutionBridge?.summary?.blockedPhases ?? 0,
    },
    channels: channels.map((channel) => ({
      id: channel.id,
      label: channel.label,
      callableName: channel.callableName,
      firestoreCollection: channel.firestoreCollection,
      exporter: channel.exporter,
      localDecisionRoot: channel.localDecisionRoot,
      pipelineFlag: channel.pipelineFlag,
      toolId: channel.toolId,
    })),
  };
}

function checkReviewedDecisionAnswerPacketsBridge({root, errors, fileCache}) {
  mustContain({
    root,
    file: sharedFiles.adminApp,
    token: "reviewedDecisionAnswerPackets",
    label: "reviewed-answer-packets: admin bridge property",
    errors,
    fileCache,
  });
  mustContain({
    root,
    file: sharedFiles.adminApp,
    token: "OrganizerReviewedDecisionAnswerPacketsView",
    label: "reviewed-answer-packets: admin UI view",
    errors,
    fileCache,
  });
  mustContain({
    root,
    file: sharedFiles.adminApp,
    token: "Reviewed answer packets",
    label: "reviewed-answer-packets: admin panel title",
    errors,
    fileCache,
  });
  mustContain({
    root,
    file: sharedFiles.toolsManifest,
    token: `"id": "organizer-intake:reviewed-decision-answer-packets"`,
    label: "reviewed-answer-packets: tools manifest id",
    errors,
    fileCache,
  });
  mustContain({
    root,
    file: sharedFiles.readme,
    token: "reviewed_decision_answer_packets.mjs --check",
    label: "reviewed-answer-packets: README check command",
    errors,
    fileCache,
  });
  mustContain({
    root,
    file: sharedFiles.reviewedDecisionAnswerPacketsCli,
    token: "checkReviewedDecisionAnswerPacketRegister",
    label: "reviewed-answer-packets: checker export",
    errors,
    fileCache,
  });

  const bridge = readJson({
    root,
    file: sharedFiles.adminBridge,
    label: "reviewed-answer-packets: admin generated bridge",
    errors,
    fileCache,
  });
  const generatedRegister = readJson({
    root,
    file: sharedFiles.generatedReviewedDecisionAnswerPackets,
    label: "reviewed-answer-packets: generated register",
    errors,
    fileCache,
  });
  if (!bridge || !generatedRegister) return null;
  const embedded = bridge.reviewedDecisionAnswerPackets;
  if (!embedded) {
    errors.push(
      "reviewed-answer-packets: admin bridge missing " +
        "reviewedDecisionAnswerPackets"
    );
    return null;
  }
  if (!jsonSemanticallyEqual(embedded, generatedRegister)) {
    errors.push(
      "reviewed-answer-packets: embedded register does not match generated " +
        "register"
    );
  }
  if (embedded.summary?.packets !== generatedRegister.summary?.packets) {
    errors.push(
      "reviewed-answer-packets: embedded packet count does not match " +
        "generated register"
    );
  }
  if (
    bridge.summary?.reviewedAnswerPacketStatus !==
      generatedRegister.summary?.status
  ) {
    errors.push(
      "reviewed-answer-packets: bridge status does not match generated " +
        "register"
    );
  }
  if (
    bridge.summary?.reviewedAnswerPacketsReady !==
      generatedRegister.summary?.readyToApply
  ) {
    errors.push(
      "reviewed-answer-packets: bridge ready count does not match " +
        "generated register"
    );
  }
  return embedded;
}

function checkPromotionExecutionBridge({root, errors, fileCache}) {
  mustContain({
    root,
    file: sharedFiles.adminApp,
    token: "promotionExecutionPacket",
    label: "promotion-execution: admin bridge property",
    errors,
    fileCache,
  });
  mustContain({
    root,
    file: sharedFiles.adminApp,
    token: "OrganizerPromotionExecutionView",
    label: "promotion-execution: admin UI view",
    errors,
    fileCache,
  });
  mustContain({
    root,
    file: sharedFiles.adminApp,
    token: "Promotion execution",
    label: "promotion-execution: admin panel title",
    errors,
    fileCache,
  });
  mustContain({
    root,
    file: sharedFiles.adminApp,
    token: "promotionPhaseTone",
    label: "promotion-execution: admin status tone helper",
    errors,
    fileCache,
  });
  mustContain({
    root,
    file: sharedFiles.toolsManifest,
    token: `"id": "organizer-intake:promotion-execution-packet"`,
    label: "promotion-execution: tools manifest id",
    errors,
    fileCache,
  });
  mustContain({
    root,
    file: sharedFiles.promotionExecutionCli,
    token: "checkOrganizerPromotionExecutionPacket",
    label: "promotion-execution: checker export",
    errors,
    fileCache,
  });
  const bridge = readJson({
    root,
    file: sharedFiles.adminBridge,
    label: "promotion-execution: admin generated bridge",
    errors,
    fileCache,
  });
  const generatedPacket = readJson({
    root,
    file: sharedFiles.generatedPromotionExecutionPacket,
    label: "promotion-execution: generated packet",
    errors,
    fileCache,
  });
  if (!bridge || !generatedPacket) return null;
  const embedded = bridge.promotionExecutionPacket;
  if (!embedded) {
    errors.push("promotion-execution: admin bridge missing promotionExecutionPacket");
    return null;
  }
  if (!jsonSemanticallyEqual(embedded, generatedPacket)) {
    errors.push(
      "promotion-execution: embedded packet does not match generated packet"
    );
  }
  if (embedded.summary?.phases !== generatedPacket.summary?.phases) {
    errors.push(
      "promotion-execution: embedded phase count does not match generated packet"
    );
  }
  if (
    bridge.summary?.promotionExecutionStatus !==
      generatedPacket.summary?.status
  ) {
    errors.push(
      "promotion-execution: bridge status does not match generated packet"
    );
  }
  if (
    bridge.summary?.promotionExecutionPhases !==
      generatedPacket.summary?.phases
  ) {
    errors.push(
      "promotion-execution: bridge phase count does not match generated packet"
    );
  }
  if (
    bridge.summary?.promotionExecutionBlockedPhases !==
      generatedPacket.summary?.blockedPhases
  ) {
    errors.push(
      "promotion-execution: bridge blocked phase count does not match " +
        "generated packet"
    );
  }
  return embedded;
}

function checkBridgeItemDecisionCommands({root, errors, fileCache}) {
  const bridge = readJson({
    root,
    file: sharedFiles.adminBridge,
    label: "review-item-commands: admin generated bridge",
    errors,
    fileCache,
  });
  if (!bridge) return;
  const packetsByEntity = new Map(
    (bridge.publicationReviewPackets?.packets ?? [])
      .map((packet) => [packet.entityId, packet])
  );
  for (const item of bridge.items ?? []) {
    const prefix = `review-item-commands:${item.entityId}`;
    const commands = item.decisionCommands;
    if (!commands || typeof commands !== "object") {
      errors.push(`${prefix}: missing decisionCommands`);
      continue;
    }
    for (const key of ["approvePublic", "hold", "suppress"]) {
      if (typeof commands[key] !== "string" || commands[key].length === 0) {
        errors.push(`${prefix}: missing ${key} command`);
      }
    }
    if (!commands.approvePublic?.includes("--app-visibility hidden")) {
      errors.push(`${prefix}: approvePublic must keep app visibility hidden`);
    }
    if (!commands.hold?.includes("--app-visibility hidden")) {
      errors.push(`${prefix}: hold must keep app visibility hidden`);
    }
    if (!commands.suppress?.includes("--app-visibility hidden")) {
      errors.push(`${prefix}: suppress must keep app visibility hidden`);
    }
    const packet = packetsByEntity.get(item.entityId);
    if (
      packet?.evidenceSummary?.manualReportsWithoutArtifacts > 0 &&
      !commands.approvePublic?.includes("--confirm-manual-reports-reviewed")
    ) {
      errors.push(
        `${prefix}: approvePublic must acknowledge manual reports`
      );
    }
  }
}

function checkExactEmbeddedGeneratedArtifactParity({root, errors, fileCache}) {
  const bridge = readJson({
    root,
    file: sharedFiles.adminBridge,
    label: "embedded-generated: admin generated bridge",
    errors,
    fileCache,
  });
  if (!bridge) return;
  for (const artifact of exactEmbeddedGeneratedArtifacts) {
    const prefix = `embedded-generated:${artifact.bridgeKey}`;
    const sourceFile = bridge.generatedFrom?.[artifact.sourceKey];
    if (typeof sourceFile !== "string" || sourceFile.length === 0) {
      errors.push(`${prefix}: missing generatedFrom.${artifact.sourceKey}`);
      continue;
    }
    const source = readJson({
      root,
      file: sourceFile,
      label: `${prefix}: source artifact`,
      errors,
      fileCache,
    });
    if (!source) continue;
    if (!Object.hasOwn(bridge, artifact.bridgeKey)) {
      errors.push(`${prefix}: admin bridge missing embedded artifact`);
      continue;
    }
    if (!jsonSemanticallyEqual(bridge[artifact.bridgeKey], source)) {
      errors.push(
        `${prefix}: embedded artifact does not match ${sourceFile}`
      );
    }
  }
}

function checkPendingWorkCoverageBridge({root, errors, fileCache}) {
  mustContain({
    root,
    file: sharedFiles.adminApp,
    token: "pendingWorkCoverage",
    label: "pending-work-coverage: admin bridge property",
    errors,
    fileCache,
  });
  mustContain({
    root,
    file: sharedFiles.adminApp,
    token: "OrganizerPendingWorkCoverageView",
    label: "pending-work-coverage: admin UI view",
    errors,
    fileCache,
  });
  mustContain({
    root,
    file: sharedFiles.adminApp,
    token: "Pending work coverage",
    label: "pending-work-coverage: admin panel title",
    errors,
    fileCache,
  });
  mustContain({
    root,
    file: sharedFiles.toolsManifest,
    token: `"id": "organizer-intake:pending-work-coverage"`,
    label: "pending-work-coverage: tools manifest id",
    errors,
    fileCache,
  });
  mustContain({
    root,
    file: sharedFiles.pendingWorkCoverageCli,
    token: "checkOrganizerPendingWorkCoverage",
    label: "pending-work-coverage: checker export",
    errors,
    fileCache,
  });
  const bridge = readJson({
    root,
    file: sharedFiles.adminBridge,
    label: "pending-work-coverage: admin generated bridge",
    errors,
    fileCache,
  });
  const generatedCoverage = readJson({
    root,
    file: sharedFiles.generatedPendingWorkCoverage,
    label: "pending-work-coverage: generated coverage",
    errors,
    fileCache,
  });
  if (!bridge || !generatedCoverage) return null;
  const embedded = bridge.pendingWorkCoverage;
  if (!embedded) {
    errors.push("pending-work-coverage: admin bridge missing pendingWorkCoverage");
    return null;
  }
  if (!jsonSemanticallyEqual(embedded, generatedCoverage)) {
    errors.push(
      "pending-work-coverage: embedded coverage does not match generated " +
        "coverage"
    );
  }
  if (
    embedded.summary?.unresolvedWorkstreams !==
      generatedCoverage.summary?.unresolvedWorkstreams
  ) {
    errors.push(
      "pending-work-coverage: embedded unresolved count does not match " +
        "generated coverage"
    );
  }
  if (
    bridge.summary?.pendingWorkUntriaged !==
      generatedCoverage.summary?.untriagedWorkstreams
  ) {
    errors.push(
      "pending-work-coverage: bridge untriaged count does not match " +
        "generated coverage"
    );
  }
  if (
    bridge.summary?.pendingWorkCoverageStatus !==
      generatedCoverage.summary?.status
  ) {
    errors.push(
      "pending-work-coverage: bridge coverage status does not match " +
        "generated coverage"
    );
  }
  return embedded;
}

function checkPendingInputBridge({root, errors, fileCache}) {
  mustContain({
    root,
    file: sharedFiles.adminApp,
    token: "pendingInputRequest",
    label: "pending-input: admin bridge property",
    errors,
    fileCache,
  });
  mustContain({
    root,
    file: sharedFiles.adminApp,
    token: "OrganizerPendingInputRequestView",
    label: "pending-input: admin UI view",
    errors,
    fileCache,
  });
  mustContain({
    root,
    file: sharedFiles.adminApp,
    token: "handlePendingInputDecision",
    label: "pending-input: admin UI decision handler",
    errors,
    fileCache,
  });
  mustContain({
    root,
    file: sharedFiles.adminApp,
    token: "onPendingDecision",
    label: "pending-input: admin UI action prop",
    errors,
    fileCache,
  });
  mustContain({
    root,
    file: sharedFiles.adminApp,
    token: "Pending admin/product inputs",
    label: "pending-input: admin panel title",
    errors,
    fileCache,
  });
  mustContain({
    root,
    file: sharedFiles.toolsManifest,
    token: `"id": "organizer-intake:pending-input-request"`,
    label: "pending-input: tools manifest id",
    errors,
    fileCache,
  });
  mustContain({
    root,
    file: sharedFiles.readme,
    token: "pending_input_request.mjs --format markdown",
    label: "pending-input: README render command",
    errors,
    fileCache,
  });
  mustContain({
    root,
    file: sharedFiles.pendingInputCli,
    token: "checkOrganizerPendingInputRequest",
    label: "pending-input: checker export",
    errors,
    fileCache,
  });

  const bridge = readJson({
    root,
    file: sharedFiles.adminBridge,
    label: "pending-input: admin generated bridge",
    errors,
    fileCache,
  });
  const generatedRequest = readJson({
    root,
    file: sharedFiles.generatedPendingInputRequest,
    label: "pending-input: generated request",
    errors,
    fileCache,
  });
  if (!bridge || !generatedRequest) return null;
  const embedded = bridge.pendingInputRequest;
  if (!embedded) {
    errors.push("pending-input: admin bridge missing pendingInputRequest");
    return null;
  }
  if (!jsonSemanticallyEqual(embedded, generatedRequest)) {
    errors.push(
      "pending-input: embedded request does not match generated request"
    );
  }
  if (embedded.schemaVersion !== generatedRequest.schemaVersion) {
    errors.push(
      "pending-input: embedded schemaVersion does not match generated request"
    );
  }
  if (embedded.summary?.requests !== generatedRequest.summary?.requests) {
    errors.push(
      "pending-input: embedded request count does not match generated request"
    );
  }
  if (
    bridge.summary?.pendingInputRequests !== generatedRequest.summary?.requests
  ) {
    errors.push(
      "pending-input: bridge summary pendingInputRequests does not match " +
        "generated request count"
    );
  }
  if (
    bridge.summary?.pendingAdminPublicationInputs !==
      generatedRequest.summary?.adminPublicationRequests
  ) {
    errors.push(
      "pending-input: bridge admin publication count does not match " +
        "generated request summary"
    );
  }
  if (
    bridge.summary?.pendingPolicyDecisionInputs !==
      generatedRequest.summary?.policyDecisionRequests
  ) {
    errors.push(
      "pending-input: bridge policy input count does not match generated " +
        "request summary"
    );
  }
  if (!Array.isArray(embedded.requests)) {
    errors.push("pending-input: embedded requests must be an array");
  } else {
    checkPendingInputCallableSubmissions({requests: embedded.requests, errors});
  }
  if (!Array.isArray(embedded.followUps)) {
    errors.push("pending-input: embedded followUps must be an array");
  }
  return embedded;
}

function checkPendingInputCallableSubmissions({requests, errors}) {
  for (const request of requests) {
    const expected = expectedCallableForPendingInput(request);
    if (!expected) continue;
    const prefix = `pending-input:${request.requestId}: callable`;
    const submission = request.callableSubmission;
    if (!submission || typeof submission !== "object") {
      errors.push(`${prefix}: missing callableSubmission`);
      continue;
    }
    for (const [field, value] of Object.entries(expected)) {
      if (submission[field] !== value) {
        errors.push(`${prefix}: expected ${field} ${value}`);
      }
    }
    const payloads = submission.payloadsByDecision;
    if (!payloads || typeof payloads !== "object") {
      errors.push(`${prefix}: missing payloadsByDecision`);
      continue;
    }
    for (const decision of request.decisionOptions ?? []) {
      const payload = payloads[decision];
      if (!payload || typeof payload !== "object") {
        errors.push(`${prefix}: missing ${decision} payload`);
        continue;
      }
      if (request.requestType === "admin_publication_decision") {
        checkPublicationCallablePayload({
          decision,
          errors,
          payload,
          prefix,
          request,
        });
      } else if (request.requestType === "policy_decision") {
        checkPolicyCallablePayload({
          decision,
          errors,
          payload,
          prefix,
          request,
        });
      }
    }
    const expectedSafeDefault = (request.decisionOptions ?? [])
      .includes(request.safeDefaultAction) ?
      request.safeDefaultAction :
      "hold";
    if (submission.safeDefaultPayload?.decision !== expectedSafeDefault) {
      errors.push(
        `${prefix}: safeDefaultPayload must use ${expectedSafeDefault}`
      );
    }
  }
}

function expectedCallableForPendingInput(request) {
  if (request.requestType === "admin_publication_decision") {
    return {
      callableName: "adminDecideOrganizerIntake",
      adminApiWrapper: "decideOrganizerIntake",
      payloadType: "AdminDecideOrganizerIntakePayload",
      firestoreCollection: "organizerIntakeReviewDecisions",
    };
  }
  if (request.requestType === "policy_decision") {
    return {
      callableName: "adminDecideOrganizerPolicyGap",
      adminApiWrapper: "decideOrganizerPolicyGap",
      payloadType: "AdminDecideOrganizerPolicyGapPayload",
      firestoreCollection: "organizerPolicyGapReviewDecisions",
    };
  }
  return null;
}

function checkPublicationCallablePayload({
  decision,
  errors,
  payload,
  prefix,
  request,
}) {
  if (payload.entityId !== request.subjectId) {
    errors.push(`${prefix}: ${decision} payload entityId mismatch`);
  }
  if (payload.decision !== decision) {
    errors.push(`${prefix}: ${decision} payload decision mismatch`);
  }
  if (payload.appVisibility !== "hidden") {
    errors.push(`${prefix}: ${decision} payload must keep appVisibility hidden`);
  }
  if (typeof payload.note !== "string" || payload.note.trim().length === 0) {
    errors.push(`${prefix}: ${decision} payload note is required`);
  }
  const checklist = payload.checklist;
  for (const field of [
    "identityReviewed",
    "surfaceInventoryReviewed",
    "ownerSafeCopyReviewed",
    "marketScopeReviewed",
    "mediaRightsReviewed",
    "crawlDisabledReviewed",
  ]) {
    if (typeof checklist?.[field] !== "boolean") {
      errors.push(`${prefix}: ${decision} checklist missing ${field}`);
    }
  }
  if (
    decision === "approve_public" &&
    request.requiredAcknowledgements?.manualReportsReviewed === true &&
    checklist?.manualReportsReviewed !== true
  ) {
    errors.push(
      `${prefix}: approve_public payload must acknowledge manual reports`
    );
  }
}

function checkPolicyCallablePayload({
  decision,
  errors,
  payload,
  prefix,
  request,
}) {
  if (payload.gapId !== request.subjectId) {
    errors.push(`${prefix}: ${decision} payload gapId mismatch`);
  }
  if (payload.decision !== decision) {
    errors.push(`${prefix}: ${decision} payload decision mismatch`);
  }
  if (!Array.isArray(payload.requiredInputsReviewed)) {
    errors.push(`${prefix}: ${decision} requiredInputsReviewed must be array`);
  }
  if (typeof payload.note !== "string" || payload.note.trim().length === 0) {
    errors.push(`${prefix}: ${decision} payload note is required`);
  }
  const checklist = payload.checklist;
  for (const field of [
    "requiredInputsReviewed",
    "costAndSafetyReviewed",
    "implementationOwnerReviewed",
    "behaviorStillDisabledAcknowledged",
  ]) {
    if (typeof checklist?.[field] !== "boolean") {
      errors.push(`${prefix}: ${decision} checklist missing ${field}`);
    }
  }
  if (decision !== "accept") return;
  const requiredInputs = (request.requiredInputs ?? [])
    .filter((input) => input.requiredForAcceptance === true)
    .map((input) => input.input)
    .filter(Boolean)
    .sort();
  const reviewed = [...(payload.requiredInputsReviewed ?? [])].sort();
  if (JSON.stringify(reviewed) !== JSON.stringify(requiredInputs)) {
    errors.push(
      `${prefix}: accept payload requiredInputsReviewed does not match ` +
        "required policy inputs"
    );
  }
}

function checkChannel({root, channel, errors, warnings, fileCache}) {
  const requiredFiles = [
    channel.handlerFile,
    channel.handlerTest,
    channel.payloadSchema,
    channel.firestoreSchema,
    channel.generatedPayload,
    channel.generatedDocument,
    channel.exporter,
    channel.exporterTest,
    channel.localDecisionRoot,
  ];
  if (channel.localDecisionCli) requiredFiles.push(channel.localDecisionCli);

  for (const file of requiredFiles) {
    requireFile({root, file, label: `${channel.id}:${file}`, errors});
  }

  mustContain({
    root,
    file: sharedFiles.functionsIndex,
    token: channel.callableName,
    label: `${channel.id}: functions export`,
    errors,
    fileCache,
  });
  mustContain({
    root,
    file: sharedFiles.adminApi,
    token: `function ${channel.adminApiWrapper}`,
    label: `${channel.id}: admin API wrapper`,
    errors,
    fileCache,
  });
  mustContain({
    root,
    file: sharedFiles.adminApi,
    token: `"${channel.callableName}"`,
    label: `${channel.id}: admin API callable name`,
    errors,
    fileCache,
  });
  mustContain({
    root,
    file: sharedFiles.adminApp,
    token: `${channel.adminApiWrapper}(`,
    label: `${channel.id}: admin UI action`,
    errors,
    fileCache,
  });
  mustContain({
    root,
    file: sharedFiles.adminTypes,
    token: `interface ${channel.payloadType}`,
    label: `${channel.id}: admin payload type`,
    errors,
    fileCache,
  });
  mustContain({
    root,
    file: sharedFiles.adminTypes,
    token: `interface ${channel.responseType}`,
    label: `${channel.id}: admin response type`,
    errors,
    fileCache,
  });
  mustContain({
    root,
    file: channel.handlerFile,
    token: `const decisionCollection = "${channel.firestoreCollection}"`,
    label: `${channel.id}: Firestore collection constant`,
    errors,
    fileCache,
    fallbackToken:
      `const curationCollection = "${channel.firestoreCollection}"`,
  });
  mustContain({
    root,
    file: channel.handlerFile,
    token: `"${channel.callableName}"`,
    label: `${channel.id}: rate-limit action`,
    errors,
    fileCache,
  });
  mustContain({
    root,
    file: channel.handlerFile,
    token: "setAdminAuditLogInTransaction",
    label: `${channel.id}: admin audit log`,
    errors,
    fileCache,
  });
  mustContain({
    root,
    file: channel.exporter,
    token: `const decisionCollection = "${channel.firestoreCollection}"`,
    label: `${channel.id}: exporter collection`,
    errors,
    fileCache,
    fallbackToken:
      `const curationCollection = "${channel.firestoreCollection}"`,
  });
  mustContain({
    root,
    file: sharedFiles.runPipeline,
    token: channel.pipelineFlag,
    label: `${channel.id}: pipeline export flag`,
    errors,
    fileCache,
  });
  mustContain({
    root,
    file: sharedFiles.runPipeline,
    token: channel.pipelineLabel,
    label: `${channel.id}: pipeline step label`,
    errors,
    fileCache,
  });
  mustContain({
    root,
    file: sharedFiles.toolsManifest,
    token: `"id": "${channel.toolId}"`,
    label: `${channel.id}: tools manifest id`,
    errors,
    fileCache,
  });
  if (channel.localDecisionCli) {
    mustContain({
      root,
      file: sharedFiles.toolsManifest,
      token: `"path": "${channel.localDecisionCli}"`,
      label: `${channel.id}: local decision CLI manifest path`,
      errors,
      fileCache,
    });
  }
  mustContain({
    root,
    file: sharedFiles.readme,
    token: channel.exporter,
    label: `${channel.id}: README exporter command`,
    errors,
    fileCache,
  });
  mustContain({
    root,
    file: sharedFiles.readme,
    token: channel.firestoreCollection,
    label: `${channel.id}: README Firestore collection`,
    errors,
    fileCache,
  });

  void warnings;
}

function readyChannelCount({root, channels, fileCache}) {
  return channels.filter((channel) => {
    const localErrors = [];
    checkChannel({
      root,
      channel,
      errors: localErrors,
      warnings: [],
      fileCache,
    });
    return localErrors.length === 0;
  }).length;
}

function requireFile({root, file, label, errors}) {
  const absolutePath = path.resolve(root, file);
  if (!fs.existsSync(absolutePath)) {
    errors.push(`${label}: missing ${file}`);
  }
}

function mustContain({
  root,
  file,
  token,
  label,
  errors,
  fileCache,
  fallbackToken,
}) {
  const source = readText({root, file, fileCache});
  if (source === null) {
    errors.push(`${label}: cannot read ${file}`);
    return;
  }
  if (source.includes(token)) return;
  if (fallbackToken && source.includes(fallbackToken)) return;
  errors.push(`${label}: ${file} does not contain ${token}`);
}

function readText({root, file, fileCache}) {
  const absolutePath = path.resolve(root, file);
  if (fileCache.has(absolutePath)) return fileCache.get(absolutePath);
  if (!fs.existsSync(absolutePath)) {
    fileCache.set(absolutePath, null);
    return null;
  }
  const source = fs.readFileSync(absolutePath, "utf8");
  fileCache.set(absolutePath, source);
  return source;
}

function readJson({root, file, label, errors, fileCache}) {
  const source = readText({root, file, fileCache});
  if (source === null) {
    errors.push(`${label}: cannot read ${file}`);
    return null;
  }
  try {
    return JSON.parse(source);
  } catch (error) {
    errors.push(`${label}: cannot parse ${file}: ${error.message}`);
    return null;
  }
}

function jsonSemanticallyEqual(left, right) {
  return stableJsonStringify(left) === stableJsonStringify(right);
}

function stableJsonStringify(value) {
  if (Array.isArray(value)) {
    return `[${value.map((item) => stableJsonStringify(item)).join(",")}]`;
  }
  if (value && typeof value === "object") {
    const entries = Object.keys(value)
      .sort()
      .map((key) =>
        `${JSON.stringify(key)}:${stableJsonStringify(value[key])}`
      )
      .join(",");
    return `{${entries}}`;
  }
  return JSON.stringify(value);
}

function main(argv = process.argv.slice(2)) {
  const args = parseArgs(argv);
  if (args.help) {
    printHelp();
    return;
  }
  const result = checkAdminReviewBridge();
  if (args.json) {
    console.log(JSON.stringify(result, null, 2));
  }
  for (const warning of result.warnings) {
    console.warn(`Warning: ${warning}`);
  }
  if (!result.ok) {
    console.error("Organizer admin review bridge validation failed:");
    for (const error of result.errors) console.error(`- ${error}`);
    process.exit(1);
  }
  if (!args.json) {
    console.log(
      "Organizer admin review bridge ok: " +
        `${result.summary.channels} channel(s), ` +
        `${result.summary.exporters.length} exporter(s), ` +
        `${result.summary.firestoreCollections.length} Firestore collection(s), ` +
        `${result.summary.pendingInputRequests} pending input(s), ` +
        `${result.summary.pendingInputCallableSubmissions} callable payload(s), ` +
        `${result.summary.reviewedAnswerPackets} reviewed answer packet(s), ` +
        `${result.summary.promotionExecutionPhases} promotion phase(s), ` +
        `${result.summary.pendingWorkUntriaged} untriaged workstream(s).`
    );
  }
}

function parseArgs(argv) {
  const parsed = {
    help: false,
    json: false,
  };
  for (let index = 0; index < argv.length; index += 1) {
    const arg = argv[index];
    if (arg === "--help" || arg === "-h") parsed.help = true;
    else if (arg === "--json") parsed.json = true;
    else fail(`Unknown argument: ${arg}`);
  }
  return parsed;
}

function printHelp() {
  console.log(`Usage: node tool/organizer_intake/check_admin_review_bridge.mjs [options]

Validates that every organizer admin review channel is wired across:
  - admin UI/API wrapper and TypeScript payload/response types
  - backend callable export, schema validation, audit log, and rate limit action
  - generated contract payload/document files
  - Firestore decision collection export back to repo-backed JSON batches
  - promotion pipeline flags, tool manifest entries, and operator docs

Options:
  --json      Print the channel manifest and validation result.
  -h, --help  Show this help.
`);
}

function fail(message) {
  console.error(message);
  process.exit(1);
}

function isMain() {
  return process.argv[1] &&
    import.meta.url === pathToFileURL(process.argv[1]).href;
}
