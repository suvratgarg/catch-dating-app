const priorityRank = {
  p0: 0,
  p1: 1,
  p2: 2,
  p3: 3,
};

export function buildOrganizerPendingDecisionAnswerPacket({
  pendingInputRequest = emptyPendingInputRequest(),
  pendingWorkCoverage = emptyPendingWorkCoverage(),
} = {}) {
  const requests = pendingInputRequest.requests ?? [];
  const coverageByRequest = coverageByPendingRequestId(pendingWorkCoverage);
  const answerSlots = requests
    .map((request) => answerSlotForRequest({
      coverageByRequest,
      request,
    }))
    .sort(slotComparator);
  const answerTemplate = {
    reviewer: "",
    decidedAt: "YYYY-MM-DD",
    answers: answerSlots.map((slot) => ({
      answerId: slot.answerId,
      decision: null,
      note: "",
      acknowledgements: Object.fromEntries(
        slot.requiredAcknowledgements.map((acknowledgement) => [
          acknowledgement,
          false,
        ])
      ),
      requiredInputsReviewed: [],
    })),
  };

  return {
    schemaVersion: 1,
    generatedFrom: {
      pendingInputRequest:
        "tool/organizer_intake/generated/organizer_pending_input_request.json",
      pendingWorkCoverage:
        "tool/organizer_intake/generated/organizer_pending_work_coverage.json",
    },
    summary: summaryFor({
      answerSlots,
      pendingInputRequest,
      pendingWorkCoverage,
    }),
    guardrails: [
      "The answer packet is a review template only; it never records decisions, writes Firestore, publishes pages, enables crawls, uploads artifacts, or imports events.",
      "Each answer must choose one of the listed decision options and include a reviewer note before a decision batch or admin callable should be used.",
      "Safe defaults keep publication held and disabled policy surfaces disabled until an admin or product owner records a different reviewed decision.",
    ],
    answerTemplate,
    answerSlots,
    followUps: pendingInputRequest.followUps ?? [],
  };
}

function answerSlotForRequest({coverageByRequest, request}) {
  const safeDefaultDecision = safeDefaultDecisionFor(request);
  const requiredInputs = (request.requiredInputs ?? [])
    .filter((input) => input.requiredForAcceptance === true)
    .map((input) => ({
      questionId: input.questionId ?? null,
      input: input.input ?? input.prompt,
      prompt: input.prompt,
      recommendedSafeDefault: input.recommendedSafeDefault,
    }));
  const requiredAcknowledgements = requiredAcknowledgementsFor(request);

  return {
    answerId: request.requestId,
    requestType: request.requestType,
    priority: request.priority,
    owner: request.owner,
    subjectId: request.subjectId,
    subjectName: request.subjectName,
    prompt: request.prompt,
    decisionOptions: request.decisionOptions ?? [],
    safeDefaultAction: request.safeDefaultAction,
    safeDefaultDecision,
    safeDefaultPayload:
      request.callableSubmission?.safeDefaultPayload ?? null,
    requiredAcknowledgements,
    requiredInputs,
    blockingWorkstreams: coverageByRequest.get(request.requestId) ?? [],
    dryRunCommands: dryRunCommandsForRequest({request, safeDefaultDecision}),
    sourceArtifacts: request.sourceArtifacts ?? [],
  };
}

function requiredAcknowledgementsFor(request) {
  const acknowledgements = [];
  if (request.requiredAcknowledgements?.manualReportsReviewed === true) {
    acknowledgements.push("manualReportsReviewed");
  }
  if (request.requestType === "admin_publication_decision") {
    for (const item of request.requiredAcknowledgements?.publicationChecklist ?? []) {
      acknowledgements.push(item);
    }
  }
  if (request.requestType === "policy_decision") {
    acknowledgements.push(
      "requiredInputsReviewed",
      "costAndSafetyReviewed",
      "implementationOwnerReviewed",
      "behaviorStillDisabledAcknowledged"
    );
  }
  return [...new Set(acknowledgements)].sort();
}

function safeDefaultDecisionFor(request) {
  const payloadDecision = request.callableSubmission?.safeDefaultPayload?.decision;
  if (request.decisionOptions?.includes(payloadDecision)) return payloadDecision;
  if (request.decisionOptions?.includes(request.safeDefaultAction)) {
    return request.safeDefaultAction;
  }
  if (request.decisionOptions?.includes("hold")) return "hold";
  return null;
}

function dryRunCommandsForRequest({request, safeDefaultDecision}) {
  if (!safeDefaultDecision) return [];
  if (request.requestType === "admin_publication_decision") {
    return [
      "node tool/organizer_intake/review_decision.mjs " +
        `draft ${request.subjectId} --decision ${safeDefaultDecision} ` +
        "--app-visibility hidden --reviewer REVIEWER --date YYYY-MM-DD " +
        "--note \"Hold pending admin review.\" --dry-run",
    ];
  }
  if (request.requestType === "policy_decision") {
    return [
      "node tool/organizer_intake/policy_gap_decision.mjs " +
        `draft ${request.subjectId} --decision ${safeDefaultDecision} ` +
        "--reviewer REVIEWER --date YYYY-MM-DD " +
        "--note \"Policy still held.\" --dry-run",
    ];
  }
  return [];
}

function coverageByPendingRequestId(pendingWorkCoverage) {
  const coverage = new Map();
  for (const entry of pendingWorkCoverage.entries ?? []) {
    for (const requestId of entry.pendingRequestIds ?? []) {
      const existing = coverage.get(requestId) ?? [];
      existing.push(entry.workstreamId);
      coverage.set(requestId, existing.sort());
    }
  }
  return coverage;
}

function summaryFor({answerSlots, pendingInputRequest, pendingWorkCoverage}) {
  const requiredPolicyQuestions = answerSlots.reduce((total, slot) =>
    total + slot.requiredInputs.length, 0);
  const requiredAcknowledgements = answerSlots.reduce((total, slot) =>
    total + slot.requiredAcknowledgements.length, 0);
  const safeDefaultDecisions = answerSlots.filter((slot) =>
    slot.safeDefaultDecision).length;
  return {
    status: answerSlots.length === 0 ?
      "ready" :
      pendingWorkCoverage.summary?.untriagedWorkstreams > 0 ?
        "untriaged_work" :
        "awaiting_user_input",
    answerSlots: answerSlots.length,
    adminPublicationDecisions: answerSlots.filter((slot) =>
      slot.requestType === "admin_publication_decision").length,
    policyDecisions: answerSlots.filter((slot) =>
      slot.requestType === "policy_decision").length,
    requiredPolicyQuestions,
    requiredAcknowledgements,
    safeDefaultDecisions,
    workflowFollowUps: (pendingInputRequest.followUps ?? []).length,
    untriagedWorkstreams:
      pendingWorkCoverage.summary?.untriagedWorkstreams ?? 0,
    highestPriority: highestPriority(answerSlots.map((slot) => slot.priority)),
    slotsByOwner: countBy(answerSlots, "owner"),
    slotsByType: countBy(answerSlots, "requestType"),
    slotsByPriority: countBy(answerSlots, "priority"),
  };
}

function slotComparator(left, right) {
  return priorityRankFor(left.priority) - priorityRankFor(right.priority) ||
    left.requestType.localeCompare(right.requestType) ||
    left.subjectId.localeCompare(right.subjectId);
}

function priorityRankFor(priority) {
  return priorityRank[priority] ?? 99;
}

function highestPriority(priorities) {
  return priorities
    .filter(Boolean)
    .sort((left, right) => priorityRankFor(left) - priorityRankFor(right))[0] ??
      null;
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
  return {requests: [], followUps: []};
}

function emptyPendingWorkCoverage() {
  return {entries: [], summary: {untriagedWorkstreams: 0}};
}
