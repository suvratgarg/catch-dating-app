const priorityRank = {
  p0: 0,
  p1: 1,
  p2: 2,
  p3: 3,
};

export function buildOrganizerOperatorActionQueue({
  claimTargetSyncPreview = emptyClaimTargetSyncPreview(),
  policyDecisionPackets = emptyPolicyDecisionPackets(),
  publicationDecisionImpactPreview = emptyPublicationDecisionImpactPreview(),
  publicationReviewPackets = emptyPublicationReviewPackets(),
  workflowReadiness = emptyWorkflowReadiness(),
} = {}) {
  const impactByEntity = new Map(
    (publicationDecisionImpactPreview.entries ?? []).map((entry) => [
      entry.entityId,
      entry,
    ])
  );
  const actions = [
    ...publicationActions({
      impactByEntity,
      publicationReviewPackets,
    }),
    ...policyActions(policyDecisionPackets),
    ...workflowGateActions({
      claimTargetSyncPreview,
      workflowReadiness,
    }),
  ].sort(actionComparator);

  return {
    schemaVersion: 1,
    generatedFrom: {
      claimTargetSyncPreview:
        "tool/organizer_intake/generated/organizer_claim_target_sync_preview.json",
      policyDecisionPackets:
        "tool/organizer_intake/generated/organizer_policy_decision_packets.json",
      publicationDecisionImpactPreview:
        "tool/organizer_intake/generated/publication_decision_impact_preview.json",
      publicationReviewPackets:
        "tool/organizer_intake/generated/publication_review_packets.json",
      workflowReadiness:
        "tool/organizer_intake/generated/organizer_workflow_readiness.json",
    },
    summary: summaryFor(actions),
    guardrails: [
      "Operator actions are a review queue only; they never approve publication, enable crawls, import events, sync claim targets, or write Firestore.",
      "Publication actions must be resolved through admin review decisions before website projection or claim-target sync can proceed.",
      "Policy actions record product or operations decisions only; accepting a policy packet does not enable behavior until the owning planner/config is changed.",
      "Waiting workflow actions should clear only after their upstream admin or policy action is reviewed and the promotion pipeline is regenerated.",
    ],
    actions,
  };
}

function publicationActions({impactByEntity, publicationReviewPackets}) {
  return (publicationReviewPackets.packets ?? [])
    .filter((packet) =>
      packet.status === "ready_for_manual_publication_review" ||
      packet.status === "blocked_by_data" ||
      packet.status === "held"
    )
    .map((packet) => {
      const impact = impactByEntity.get(packet.entityId) ?? null;
      const ready = packet.status === "ready_for_manual_publication_review";
      const manualReports =
        packet.evidenceSummary?.manualReportsWithoutArtifacts ?? 0;
      return {
        actionId: `publication-review:${packet.entityId}`,
        actionType: "publication_review",
        blockers: [
          ...(packet.dataBlockers ?? []).map((blocker) => `data:${blocker}`),
          ...(packet.evidenceBlockers ?? []).map((blocker) =>
            `evidence:${blocker}`),
        ].sort(),
        commands: [
          impact?.decisionRequired?.command ??
            packet.adminDecision?.command,
          ...(impact?.commands ?? []).filter((command) =>
            command !== impact?.decisionRequired?.command
          ),
        ].filter(Boolean),
        decisionOptions: packet.adminDecision?.allowedDecisions ?? [
          "approve_public",
          "hold",
          "suppress",
        ],
        detail:
          ready ?
            `${packet.displayName} can be approved, held, or suppressed after final QA.` :
            `${packet.displayName} still has blockers before publication approval.`,
        impact: impact ? {
          appVisibility: impact.app?.appVisibility ?? null,
          claimTargetPath: impact.claimTarget?.path ?? null,
          sitemapEligible: impact.remoteEffects?.sitemapEligible === true,
          wouldCreateClaimTarget:
            impact.claimTarget?.wouldCreateOrRefresh === true,
          wouldIndex: impact.publicProjection?.wouldIndex === true,
          wouldPublish: impact.publicProjection?.wouldPublish === true,
        } : null,
        nextAction: packet.nextActions?.[0] ?? "record_manual_publication_decision",
        priority: packet.priority ?? "p1",
        requiredAcknowledgements: {
          manualReportsReviewed: manualReports > 0,
          publicationChecklist:
            Object.entries(packet.approvalChecklist ?? {})
              .filter(([, value]) => value === true)
              .map(([key]) => key)
              .sort(),
        },
        sourceArtifacts: [
          "tool/organizer_intake/generated/publication_review_packets.json",
          "tool/organizer_intake/generated/publication_decision_impact_preview.json",
        ],
        status: ready ?
          "requires_admin_decision" :
          "blocked_before_admin_decision",
        subjectId: packet.entityId,
        subjectName: packet.displayName,
        taskType: packet.taskType,
      };
    });
}

function policyActions(policyDecisionPackets) {
  return (policyDecisionPackets.packets ?? [])
    .filter((packet) => packet.decisionStatus !== "accepted")
    .map((packet) => {
      const unanswered = (packet.questions ?? [])
        .filter((question) => question.answerState !== "reviewed")
        .map((question) => question.questionId)
        .sort();
      return {
        actionId: `policy-decision:${packet.gapId}`,
        actionType: "policy_decision",
        blockers: [...(packet.blockedArtifacts ?? [])].sort(),
        commands: [
          "node tool/organizer_intake/policy_gap_decision.mjs " +
            `draft ${packet.gapId} --decision hold --reviewer REVIEWER ` +
            "--date YYYY-MM-DD --note \"Policy still held.\" --dry-run",
        ],
        decisionOptions: ["accept", "hold", "reject"],
        detail: packet.decisionPrompt,
        nextAction: packet.nextAction,
        priority: severityPriority(packet.severity),
        requiredInputs: unanswered,
        safeDefaultAction: packet.safeDefaultAction,
        sourceArtifacts: [
          "tool/organizer_intake/generated/organizer_policy_decision_packets.json",
          "tool/organizer_intake/generated/organizer_policy_gap_register.json",
        ],
        status: unanswered.length > 0 ?
          "requires_policy_input" :
          "requires_policy_decision",
        subjectId: packet.gapId,
        subjectName: packet.area,
        taskType: packet.area,
      };
    });
}

function workflowGateActions({claimTargetSyncPreview, workflowReadiness}) {
  const waitingGateIds = new Set([
    "public_projection",
    "claim_target_sync",
  ]);
  return (workflowReadiness.gates ?? [])
    .filter((gate) => waitingGateIds.has(gate.id))
    .filter((gate) => gate.status !== "ready")
    .map((gate) => ({
      actionId: `workflow-gate:${gate.id}`,
      actionType: "workflow_gate",
      blockers: [gate.status],
      commands: gate.id === "claim_target_sync" ? [
        claimTargetSyncPreview.commands?.localFixturePreview,
        claimTargetSyncPreview.commands?.firestoreDryRun,
      ].filter(Boolean) : [
        workflowReadiness.commands?.localPromotionPreview,
      ].filter(Boolean),
      decisionOptions: [],
      detail: gate.detail,
      nextAction: gate.nextAction,
      priority: "p2",
      sourceArtifacts: [
        "tool/organizer_intake/generated/organizer_workflow_readiness.json",
        ...(gate.id === "claim_target_sync" ? [
          "tool/organizer_intake/generated/organizer_claim_target_sync_preview.json",
        ] : []),
      ],
      status: `waiting:${gate.id}`,
      subjectId: gate.id,
      subjectName: gate.label,
      taskType: "workflow_gate",
    }));
}

function severityPriority(severity) {
  if (severity === "critical" || severity === "high") return "p0";
  if (severity === "medium") return "p1";
  return "p2";
}

function summaryFor(actions) {
  return {
    actions: actions.length,
    publicationReviewActions:
      actions.filter((action) => action.actionType === "publication_review").length,
    policyDecisionActions:
      actions.filter((action) => action.actionType === "policy_decision").length,
    workflowGateActions:
      actions.filter((action) => action.actionType === "workflow_gate").length,
    adminDecisionsRequired:
      actions.filter((action) => action.status === "requires_admin_decision").length,
    policyInputsRequired:
      actions.filter((action) => action.status === "requires_policy_input").length,
    waitingActions:
      actions.filter((action) => action.status.startsWith("waiting:")).length,
    actionsByPriority: countBy(actions, "priority"),
    actionsByStatus: countBy(actions, "status"),
    actionsByType: countBy(actions, "actionType"),
    highestPriority:
      actions.length > 0 ? actions[0].priority : null,
  };
}

function actionComparator(left, right) {
  return (priorityRank[left.priority] ?? 99) -
    (priorityRank[right.priority] ?? 99) ||
    left.actionType.localeCompare(right.actionType) ||
    left.subjectId.localeCompare(right.subjectId);
}

function countBy(items, field) {
  const counts = {};
  for (const item of items) {
    const key = item[field] ?? "unknown";
    counts[key] = (counts[key] ?? 0) + 1;
  }
  return Object.fromEntries(
    Object.entries(counts).sort(([left], [right]) => left.localeCompare(right))
  );
}

function emptyClaimTargetSyncPreview() {
  return {actions: [], commands: {}, summary: {}};
}

function emptyPolicyDecisionPackets() {
  return {packets: []};
}

function emptyPublicationDecisionImpactPreview() {
  return {entries: []};
}

function emptyPublicationReviewPackets() {
  return {packets: []};
}

function emptyWorkflowReadiness() {
  return {commands: {}, gates: []};
}
