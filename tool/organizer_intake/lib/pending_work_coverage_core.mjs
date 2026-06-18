const inputCoverageRules = [
  {
    workstreamId: "publication_review",
    requestTypes: ["admin_publication_decision"],
  },
  {
    workstreamId: "policy_decisions",
    requestTypes: ["policy_decision"],
  },
];

const readyStatuses = new Set(["clear", "idle", "ready"]);

export function buildOrganizerPendingWorkCoverage({
  operationalHealth = emptyOperationalHealth(),
  pendingInputRequest = emptyPendingInputRequest(),
} = {}) {
  const unresolvedWorkstreams = (operationalHealth.workstreams ?? [])
    .filter((workstream) => !readyStatuses.has(workstream.status));
  const requests = pendingInputRequest.requests ?? [];
  const followUps = pendingInputRequest.followUps ?? [];
  const entries = unresolvedWorkstreams
    .map((workstream) => coverageForWorkstream({
      followUps,
      requests,
      workstream,
    }))
    .sort((left, right) =>
      priorityRank(left.priority) - priorityRank(right.priority) ||
        left.workstreamId.localeCompare(right.workstreamId));

  return {
    schemaVersion: 1,
    generatedFrom: {
      operationalHealth:
        "tool/organizer_intake/generated/organizer_operational_health.json",
      pendingInputRequest:
        "tool/organizer_intake/generated/organizer_pending_input_request.json",
    },
    summary: summaryFor(entries),
    guardrails: [
      "Pending-work coverage is read-only; it never records decisions, writes Firestore, publishes pages, enables crawls, uploads artifacts, or imports events.",
      "Every unresolved operational-health workstream must be covered by either a pending decision request or a workflow follow-up.",
      "Covered workstreams can still be blocked; coverage only proves the blocker is visible and assigned.",
    ],
    entries,
  };
}

function coverageForWorkstream({followUps, requests, workstream}) {
  const rule = inputCoverageRules.find((item) =>
    item.workstreamId === workstream.id);
  const matchingRequests = rule ? requests.filter((request) =>
    rule.requestTypes.includes(request.requestType)) : [];
  const matchingFollowUps = followUps.filter((followUp) =>
    followUp.workstreamId === workstream.id);
  const coverageStatus = matchingRequests.length > 0 ?
    "covered_by_input_request" :
    matchingFollowUps.length > 0 ?
      "covered_by_follow_up" :
      "untriaged";
  const blockerClass = matchingRequests.length > 0 ?
    "requires_decision_input" :
    matchingFollowUps.length > 0 ?
      "covered_follow_up" :
      "missing_pending_input";

  return {
    coverageId: `pending-work:${workstream.id}`,
    workstreamId: workstream.id,
    label: workstream.label,
    status: workstream.status,
    priority: workstream.priority,
    coverageStatus,
    blockerClass,
    pendingRequestIds: matchingRequests.map((request) => request.requestId),
    followUpIds: matchingFollowUps.map((followUp) => followUp.followUpId),
    blockers: workstream.blockers ?? [],
    nextActions: workstream.nextActions ?? [],
    commands: unique([
      ...matchingRequests.flatMap((request) => request.commands ?? []),
      ...matchingFollowUps.flatMap((followUp) => followUp.commands ?? []),
      ...(workstream.commands ?? []),
    ]),
  };
}

function summaryFor(entries) {
  const coveredByInput = entries.filter((entry) =>
    entry.coverageStatus === "covered_by_input_request").length;
  const coveredByFollowUp = entries.filter((entry) =>
    entry.coverageStatus === "covered_by_follow_up").length;
  const untriaged = entries.filter((entry) =>
    entry.coverageStatus === "untriaged").length;
  return {
    status: entries.length === 0 ?
      "ready" :
      untriaged > 0 ?
        "untriaged_work" :
        "awaiting_required_input",
    unresolvedWorkstreams: entries.length,
    coveredWorkstreams: coveredByInput + coveredByFollowUp,
    coveredByInputRequest: coveredByInput,
    coveredByFollowUp,
    untriagedWorkstreams: untriaged,
    highestPriority: highestPriority(entries.map((entry) => entry.priority)),
    coverageByStatus: countBy(entries, "coverageStatus"),
    workstreamsByStatus: countBy(entries, "status"),
    workstreamsByPriority: countBy(entries, "priority"),
  };
}

function priorityRank(priority) {
  if (priority === "p0") return 0;
  if (priority === "p1") return 1;
  if (priority === "p2") return 2;
  if (priority === "p3") return 3;
  return 99;
}

function highestPriority(priorities) {
  return priorities
    .filter(Boolean)
    .sort((left, right) => priorityRank(left) - priorityRank(right))[0] ??
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

function unique(values) {
  return [...new Set(values.filter((value) =>
    value !== undefined && value !== null && value !== ""))];
}

function emptyOperationalHealth() {
  return {workstreams: []};
}

function emptyPendingInputRequest() {
  return {requests: [], followUps: []};
}
