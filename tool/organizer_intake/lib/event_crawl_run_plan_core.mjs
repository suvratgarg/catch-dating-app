export function buildEventCrawlRunPlan({
  eventCrawlPlan = emptyEventCrawlPlan(),
  executionPolicy = disabledExecutionPolicy(),
} = {}) {
  const policy = normalizedExecutionPolicy(eventCrawlPlan, executionPolicy);
  const runIntents = (eventCrawlPlan.entries ?? [])
    .map((entry) => crawlRunIntent(entry, policy))
    .sort((a, b) =>
      a.entityId.localeCompare(b.entityId) ||
      a.platform.localeCompare(b.platform) ||
      a.surfaceId.localeCompare(b.surfaceId)
    );

  return {
    schemaVersion: 1,
    generatedFrom: {
      eventCrawlPlan: "tool/organizer_intake/generated/event_crawl_plan.json",
      policy: "organizer-event-crawl-run-v0-disabled",
    },
    policy,
    summary: {
      candidateSurfaces: runIntents.length,
      wouldFetch: runIntents.filter((intent) =>
        intent.action === "would_fetch").length,
      blocked: runIntents.filter((intent) =>
        intent.action === "blocked").length,
      networkRequests: 0,
      firestoreWrites: 0,
      platforms: countBy(runIntents, "platform"),
      blockers: countRunBlockers(runIntents),
    },
    guardrails: [
      "This artifact does not fetch organizer pages or event listings.",
      "This artifact does not write Firestore, create events, notify hosts, or schedule jobs.",
      "A future runner must consume this plan through an approved crawl policy with rate and budget caps.",
      "Crawl results must become reviewed event source batches before import planning.",
    ],
    runIntents,
  };
}

function normalizedExecutionPolicy(eventCrawlPlan, executionPolicy) {
  const schedulerEnabled = eventCrawlPlan.policy?.schedulerEnabled === true &&
    executionPolicy.schedulerEnabled === true;
  const networkEnabled = executionPolicy.networkEnabled === true;
  const platformAllowlist = Array.isArray(executionPolicy.platformAllowlist) ?
    [...new Set(executionPolicy.platformAllowlist)].sort() :
    [];
  const maxRequestsPerRun = Number.isInteger(executionPolicy.maxRequestsPerRun) ?
    Math.max(0, executionPolicy.maxRequestsPerRun) :
    0;
  const executionEnabled =
    schedulerEnabled &&
    networkEnabled &&
    platformAllowlist.length > 0 &&
    maxRequestsPerRun > 0;

  return {
    status: executionEnabled ? "enabled" : "disabled",
    schedulerEnabled,
    networkEnabled,
    firestoreWritesEnabled: false,
    platformAllowlist,
    maxRequestsPerRun,
    reason: executionEnabled ?
      "Crawl run planning is enabled by explicit policy, but this planner still does not perform network or Firestore writes." :
      "Crawl run planning is generated for review only; scheduler, network access, platform allowlist, and request caps remain disabled.",
  };
}

function crawlRunIntent(entry, policy) {
  const blockedBy = [...(entry.blockedBy ?? [])];
  if (!policy.schedulerEnabled) blockedBy.push("scheduler_disabled");
  if (!policy.networkEnabled) blockedBy.push("network_disabled");
  if (policy.maxRequestsPerRun <= 0) {
    blockedBy.push("crawl_run_request_cap_missing");
  }
  if (!policy.platformAllowlist.includes(entry.platform)) {
    blockedBy.push("platform_not_allowlisted");
  }

  return {
    crawlRunId: crawlRunIdFor(entry),
    entityId: entry.entityId,
    displayName: entry.displayName,
    surfaceId: entry.surfaceId,
    platform: entry.platform,
    surfaceKind: entry.surfaceKind,
    url: entry.url ?? null,
    normalizedKey: entry.normalizedKey ?? null,
    action: blockedBy.length === 0 ? "would_fetch" : "blocked",
    blockedBy: [...new Set(blockedBy)].sort(),
    expectedOutput:
      "tool/organizer_intake/event_source_batches/<reviewed-provider-payload>.json",
    nextGate: blockedBy.length === 0 ?
      "reviewed_provider_capture" :
      "crawl_policy_review",
  };
}

function crawlRunIdFor(entry) {
  return [
    "crawl",
    slugPart(entry.entityId),
    slugPart(entry.platform),
    slugPart(entry.surfaceId),
  ].join("-");
}

function slugPart(value) {
  return String(value ?? "unknown")
    .trim()
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, "-")
    .replace(/^-+|-+$/g, "") || "unknown";
}

function countRunBlockers(runIntents) {
  const counts = {};
  for (const intent of runIntents) {
    for (const blocker of intent.blockedBy ?? []) {
      counts[blocker] = (counts[blocker] ?? 0) + 1;
    }
  }
  return Object.fromEntries(
    Object.entries(counts).sort(([a], [b]) => a.localeCompare(b))
  );
}

function countBy(items, field) {
  const counts = {};
  for (const item of items) {
    const key = item[field] ?? "unknown";
    counts[key] = (counts[key] ?? 0) + 1;
  }
  return Object.fromEntries(
    Object.entries(counts).sort(([a], [b]) => a.localeCompare(b))
  );
}

function emptyEventCrawlPlan() {
  return {
    entries: [],
    policy: {schedulerEnabled: false},
  };
}

function disabledExecutionPolicy() {
  return {
    schedulerEnabled: false,
    networkEnabled: false,
    platformAllowlist: [],
    maxRequestsPerRun: 0,
  };
}
