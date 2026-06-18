const priorityRank = {
  p0: 0,
  p1: 1,
  p2: 2,
  p3: 3,
};

const publicationChecklistFields = [
  "identityReviewed",
  "surfaceInventoryReviewed",
  "ownerSafeCopyReviewed",
  "marketScopeReviewed",
  "mediaRightsReviewed",
  "crawlDisabledReviewed",
];

const policyChecklistFields = [
  "requiredInputsReviewed",
  "costAndSafetyReviewed",
  "implementationOwnerReviewed",
  "behaviorStillDisabledAcknowledged",
];

export function buildOrganizerPendingInputRequest({
  operatorActionQueue = emptyOperatorActionQueue(),
  operationalHealth = emptyOperationalHealth(),
  policyDecisionPackets = emptyPolicyDecisionPackets(),
  publicationReviewPackets = emptyPublicationReviewPackets(),
} = {}) {
  const publicationRequests = publicationInputRequests({
    operatorActionQueue,
    publicationReviewPackets,
  });
  const policyRequests = policyInputRequests({
    operatorActionQueue,
    policyDecisionPackets,
  });
  const followUps = workflowFollowUps(operationalHealth);
  const requests = [
    ...publicationRequests,
    ...policyRequests,
  ].sort(requestComparator);

  return {
    schemaVersion: 1,
    generatedFrom: {
      operatorActionQueue:
        "tool/organizer_intake/generated/organizer_operator_action_queue.json",
      operationalHealth:
        "tool/organizer_intake/generated/organizer_operational_health.json",
      policyDecisionPackets:
        "tool/organizer_intake/generated/organizer_policy_decision_packets.json",
      publicationReviewPackets:
        "tool/organizer_intake/generated/publication_review_packets.json",
    },
    summary: summaryFor({
      followUps,
      policyRequests,
      publicationRequests,
      requests,
    }),
    guardrails: [
      "Pending input requests are decision prompts only; they never approve publication, enable crawls, import events, upload artifacts, or write Firestore.",
      "The safe default for unresolved policy input is to hold and keep the related behavior disabled.",
      "Publication approval still requires admin QA and any listed acknowledgement before promotion artifacts can publish.",
      "Workflow follow-ups should run only after their upstream admin or policy inputs have been recorded and artifacts regenerated.",
    ],
    requests,
    followUps,
  };
}

function publicationInputRequests({operatorActionQueue, publicationReviewPackets}) {
  const actionsByEntity = new Map(
    (operatorActionQueue.actions ?? [])
      .filter((action) => action.actionType === "publication_review")
      .map((action) => [action.subjectId, action])
  );

  return (publicationReviewPackets.packets ?? [])
    .filter((packet) => packet.status === "ready_for_manual_publication_review")
    .map((packet) => {
      const action = actionsByEntity.get(packet.entityId) ?? {};
      const manualReportsRequired =
        packet.evidenceSummary?.manualReportsWithoutArtifacts > 0 ||
        action.requiredAcknowledgements?.manualReportsReviewed === true;
      return {
        requestId: `admin-publication:${packet.entityId}`,
        requestType: "admin_publication_decision",
        priority: packet.priority ?? action.priority ?? "p1",
        owner: "admin",
        subjectId: packet.entityId,
        subjectName: packet.displayName,
        prompt:
          `Should ${packet.displayName} become a public unclaimed Host page, ` +
          "be held for later, or be suppressed?",
        decisionOptions: packet.adminDecision?.allowedDecisions ??
          action.decisionOptions ?? ["approve_public", "hold", "suppress"],
        safeDefaultAction: "hold",
        requiredAcknowledgements: {
          manualReportsReviewed: manualReportsRequired,
          publicationChecklist:
            Object.entries(packet.approvalChecklist ?? {})
              .filter(([, value]) => value === true)
              .map(([key]) => key)
              .sort(),
        },
        currentState: {
          evidenceRecords: packet.evidenceSummary?.records ?? 0,
          manualReportsWithoutArtifacts:
            packet.evidenceSummary?.manualReportsWithoutArtifacts ?? 0,
          riskFlags: packet.evidenceSummary?.riskFlags ?? [],
          taskType: packet.taskType,
        },
        impact: action.impact ?? null,
        commands: unique([
          packet.adminDecision?.command,
          ...(action.commands ?? []),
        ].filter(Boolean)),
        callableSubmission: publicationCallableSubmission({
          decisionOptions: packet.adminDecision?.allowedDecisions ??
            action.decisionOptions ?? ["approve_public", "hold", "suppress"],
          displayName: packet.displayName,
          entityId: packet.entityId,
          manualReportsRequired,
          packet,
          safeDefaultAction: "hold",
        }),
        sourceArtifacts: [
          "tool/organizer_intake/generated/publication_review_packets.json",
          "tool/organizer_intake/generated/organizer_operator_action_queue.json",
        ],
      };
    });
}

function policyInputRequests({operatorActionQueue, policyDecisionPackets}) {
  const actionsByGap = new Map(
    (operatorActionQueue.actions ?? [])
      .filter((action) => action.actionType === "policy_decision")
      .map((action) => [action.subjectId, action])
  );

  return (policyDecisionPackets.packets ?? [])
    .filter((packet) => packet.decisionStatus !== "accepted")
    .map((packet) => {
      const action = actionsByGap.get(packet.gapId) ?? {};
      const requiredInputs = (packet.questions ?? [])
        .filter((question) => question.answerState !== "reviewed")
        .map((question) => ({
          questionId: question.questionId,
          input: question.input,
          prompt: question.prompt,
          currentDefault: question.currentDefault,
          recommendedSafeDefault: question.recommendedSafeDefault,
          requiredForAcceptance: question.requiredForAcceptance === true,
        }));
      return {
        requestId: `policy:${packet.gapId}`,
        requestType: "policy_decision",
        priority: action.priority ?? severityPriority(packet.severity),
        owner: packet.decisionOwner ?? "product_ops",
        subjectId: packet.gapId,
        subjectName: packet.area,
        prompt: packet.decisionPrompt,
        decisionOptions: action.decisionOptions ?? ["accept", "hold", "reject"],
        safeDefaultAction: packet.safeDefaultAction,
        requiredInputs,
        currentState: {
          blockedArtifacts: packet.blockedArtifacts ?? [],
          currentState: packet.currentState,
          implementationGate: packet.implementationGate,
          unblockCriteria: packet.unblockCriteria ?? [],
        },
        nextAction: packet.nextAction,
        commands: unique([
          ...(action.commands ?? []),
        ]),
        callableSubmission: policyCallableSubmission({
          decisionOptions: action.decisionOptions ?? ["accept", "hold", "reject"],
          gapId: packet.gapId,
          packet,
          safeDefaultAction: "hold",
        }),
        sourceArtifacts: [
          "tool/organizer_intake/generated/organizer_policy_decision_packets.json",
          "tool/organizer_intake/generated/organizer_operator_action_queue.json",
        ],
      };
    });
}

function workflowFollowUps(operationalHealth) {
  return (operationalHealth.workstreams ?? [])
    .filter((workstream) =>
      workstream.status?.startsWith("waiting_") ||
      workstream.status === "blocked_by_policy" ||
      workstream.status === "disabled_by_policy" ||
      workstream.status === "dry_run_review_required" ||
      workstream.status === "review_needed")
    .map((workstream) => ({
      followUpId: `workflow:${workstream.id}`,
      workstreamId: workstream.id,
      label: workstream.label,
      status: workstream.status,
      priority: workstream.priority,
      blockers: workstream.blockers ?? [],
      nextActions: workstream.nextActions ?? [],
      commands: workstream.commands ?? [],
    }))
    .sort(requestComparator);
}

function publicationCallableSubmission({
  decisionOptions,
  displayName,
  entityId,
  manualReportsRequired,
  packet,
  safeDefaultAction,
}) {
  const payloadsByDecision = Object.fromEntries(
    decisionOptions.map((decision) => [
      decision,
      {
        entityId,
        decision,
        appVisibility: "hidden",
        checklist: publicationChecklistForDecision({
          decision,
          manualReportsRequired,
          packet,
        }),
        note: defaultPublicationNote(displayName, decision),
      },
    ])
  );
  return {
    callableName: "adminDecideOrganizerIntake",
    adminApiWrapper: "decideOrganizerIntake",
    payloadType: "AdminDecideOrganizerIntakePayload",
    firestoreCollection: "organizerIntakeReviewDecisions",
    payloadsByDecision,
    safeDefaultPayload:
      payloadsByDecision[safeDefaultAction] ??
      payloadsByDecision.hold ??
      Object.values(payloadsByDecision)[0] ??
      null,
  };
}

function publicationChecklistForDecision({
  decision,
  manualReportsRequired,
  packet,
}) {
  const source = packet.approvalChecklist ?? {};
  const checklist = Object.fromEntries(
    publicationChecklistFields.map((field) => [field, source[field] === true])
  );
  if (decision !== "approve_public") {
    checklist.mediaRightsReviewed = false;
  }
  if (decision === "approve_public" && manualReportsRequired) {
    checklist.manualReportsReviewed = true;
  }
  return checklist;
}

function defaultPublicationNote(displayName, decision) {
  if (decision === "approve_public") {
    return `Manual QA approved ${displayName} for public website projection.`;
  }
  if (decision === "hold") {
    return `Manual QA held ${displayName} for additional evidence.`;
  }
  return `Manual QA suppressed ${displayName} from public projection.`;
}

function policyCallableSubmission({
  decisionOptions,
  gapId,
  packet,
  safeDefaultAction,
}) {
  const payloadsByDecision = Object.fromEntries(
    decisionOptions.map((decision) => [
      decision,
      {
        gapId,
        decision,
        requiredInputsReviewed:
          decision === "accept" ? requiredInputsForPolicyPacket(packet) : [],
        checklist: policyChecklistForDecision(decision),
        note: defaultPolicyNote(gapId, decision),
      },
    ])
  );
  return {
    callableName: "adminDecideOrganizerPolicyGap",
    adminApiWrapper: "decideOrganizerPolicyGap",
    payloadType: "AdminDecideOrganizerPolicyGapPayload",
    firestoreCollection: "organizerPolicyGapReviewDecisions",
    payloadsByDecision,
    safeDefaultPayload:
      payloadsByDecision[safeDefaultAction] ??
      payloadsByDecision.hold ??
      Object.values(payloadsByDecision)[0] ??
      null,
  };
}

function requiredInputsForPolicyPacket(packet) {
  return unique(
    (packet.questions ?? [])
      .filter((question) => question.requiredForAcceptance === true)
      .map((question) => question.input)
      .filter(Boolean)
  ).sort();
}

function policyChecklistForDecision(decision) {
  if (decision === "accept") {
    return Object.fromEntries(
      policyChecklistFields.map((field) => [field, true])
    );
  }
  return {
    requiredInputsReviewed: false,
    costAndSafetyReviewed: false,
    implementationOwnerReviewed: true,
    behaviorStillDisabledAcknowledged: true,
  };
}

function defaultPolicyNote(gapId, decision) {
  if (decision === "accept") {
    return `Product policy accepted for ${gapId}; behavior remains disabled until encoded in repo-backed policy.`;
  }
  if (decision === "hold") {
    return `Product policy held for ${gapId}; required inputs remain unresolved.`;
  }
  return `Product policy rejected for ${gapId}.`;
}

function summaryFor({followUps, policyRequests, publicationRequests, requests}) {
  const requiredPolicyQuestions = policyRequests.reduce((total, request) =>
    total + (request.requiredInputs ?? []).filter((input) =>
      input.requiredForAcceptance).length, 0);
  const manualAcknowledgements = publicationRequests.filter((request) =>
    request.requiredAcknowledgements?.manualReportsReviewed).length;
  return {
    requests: requests.length,
    adminPublicationRequests: publicationRequests.length,
    policyDecisionRequests: policyRequests.length,
    requiredPolicyQuestions,
    manualPublicationAcknowledgements: manualAcknowledgements,
    workflowFollowUps: followUps.length,
    highestPriority: highestPriority([
      ...requests.map((request) => request.priority),
      ...followUps.map((followUp) => followUp.priority),
    ]),
    requestsByOwner: countBy(requests, "owner"),
    requestsByPriority: countBy(requests, "priority"),
    requestsByType: countBy(requests, "requestType"),
    followUpsByStatus: countBy(followUps, "status"),
  };
}

function requestComparator(left, right) {
  return (priorityRank[left.priority] ?? 99) -
    (priorityRank[right.priority] ?? 99) ||
    left.requestType?.localeCompare(right.requestType ?? "") ||
    left.requestId?.localeCompare(right.requestId ?? "") ||
    left.followUpId?.localeCompare(right.followUpId ?? "") ||
    0;
}

function highestPriority(priorities) {
  return priorities
    .filter(Boolean)
    .sort((left, right) =>
      (priorityRank[left] ?? 99) - (priorityRank[right] ?? 99))[0] ?? null;
}

function severityPriority(severity) {
  if (severity === "critical" || severity === "high") return "p0";
  if (severity === "medium") return "p1";
  return "p2";
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

function emptyOperatorActionQueue() {
  return {actions: []};
}

function emptyOperationalHealth() {
  return {workstreams: []};
}

function emptyPolicyDecisionPackets() {
  return {packets: []};
}

function emptyPublicationReviewPackets() {
  return {packets: []};
}
