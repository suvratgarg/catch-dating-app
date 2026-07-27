import fs from "node:fs/promises";
import path from "node:path";
import {fileURLToPath} from "node:url";
import {hashValue, shortHash} from "../../platform/canonical-json.mjs";
import {safeId} from "../../platform/contracts.mjs";
import {OperationsError, invariant} from "../../platform/errors.mjs";
import {validateJsonSchema} from "../../platform/json-schema.mjs";

const moduleDirectory = path.dirname(fileURLToPath(import.meta.url));
const policyPath = path.join(
  moduleDirectory,
  "config",
  "freshness_policy.json"
);
const schemaPath = path.join(
  moduleDirectory,
  "config",
  "freshness_policy.schema.json"
);

export const SUPPLY_FRESHNESS_RECORD_TYPE =
  "supply_freshness_coverage";
export const SUPPLY_FRESHNESS_KINDS = Object.freeze([
  "city_discovery_sweep",
  "candidate_verification",
  "known_organizer_event_refresh",
  "event_detail_prepublication",
]);

export async function loadSupplyFreshnessPolicy({
  readFile = fs.readFile,
} = {}) {
  const [policyText, schemaText] = await Promise.all([
    readFile(policyPath, "utf8"),
    readFile(schemaPath, "utf8"),
  ]);
  const policy = JSON.parse(policyText);
  const schema = JSON.parse(schemaText);
  const validation = validateJsonSchema(schema, policy);
  if (!validation.valid) {
    throw new OperationsError(
      "INVALID_FRESHNESS_POLICY",
      "Supply Intake freshness policy does not satisfy its schema.",
      {details: {errors: validation.errors}}
    );
  }
  return structuredClone(policy);
}

export function freshnessRequestsFromInputs({
  searchPlan,
  crawlSurfaces,
  market,
}) {
  const queries = [
    ...(searchPlan?.planned ?? []),
    ...(searchPlan?.skippedFresh ?? []),
  ]
    .filter((entry) => entry?.citySlug === market)
    .map((entry) => ({
      kind: entry.planKind === "candidate_verification" ?
        "candidate_verification" :
        "city_discovery_sweep",
      scopeKey: requiredString(entry.runKey, "search runKey"),
      runKey: entry.runKey,
      market,
      sourceProfileId: requiredString(
        entry.source,
        "search source"
      ),
      entityId: nullableString(entry.candidateId),
      surfaceId: null,
      url: null,
      schedulerStatus: null,
      surfacePolicy: null,
      fetchEnabled: false,
    }));
  const sources = (crawlSurfaces ?? [])
    .filter((entry) =>
      typeof entry?.entityId === "string" &&
      typeof entry?.surfaceId === "string" &&
      (entry.markets ?? []).some((entryMarket) =>
        entryMarket?.marketSlug === market))
    .map((entry) => ({
      kind: "known_organizer_event_refresh",
      scopeKey: sourceCadenceScopeKey(entry),
      runKey: null,
      market,
      sourceProfileId: requiredString(
        entry.platform,
        "crawl platform"
      ),
      entityId: entry.entityId,
      surfaceId: entry.surfaceId,
      url: nullableString(entry.url),
      schedulerStatus:
        entry.schedulerStatus === "enabled" ?
          "enabled" :
          "disabled",
      surfacePolicy:
        nullableString(entry.surfacePolicy) ?? "manualOnly",
      fetchEnabled: entry.fetchEnabled === true,
    }));
  return uniqueRequests([...queries, ...sources]);
}

export function planFreshnessRequests({
  requests,
  policy,
  runs,
  workItems,
  now,
}) {
  assertPolicy(policy);
  const currentTime = isoTime(now, "freshness plan now");
  const completedRunIds = new Set(
    (runs ?? [])
      .filter((run) => run?.status === "completed")
      .map((run) => run.runId)
  );
  const coverage = latestCoverageByScope({
    workItems,
    completedRunIds,
  });
  const scheduled = [];
  const skippedFresh = [];
  for (const request of uniqueRequests(requests ?? [])) {
    const window = policy.kinds[request.kind];
    invariant(
      window,
      "INVALID_FRESHNESS_KIND",
      `No freshness policy exists for ${request.kind}.`,
      {kind: request.kind}
    );
    const key = freshnessLedgerKey(request);
    const prior = coverage.get(key) ?? null;
    const freshUntil = prior ?
      addHours(prior.completedAt, window.freshForHours) :
      null;
    const entry = {
      ...request,
      cadence: {
        policyVersion: policy.policyVersion,
        freshForHours: window.freshForHours,
        lastFetchedAt: prior?.completedAt ?? null,
        nextEligibleAt: freshUntil,
      },
    };
    if (prior && isFresh({
      completedAt: prior.completedAt,
      freshUntil,
      now: currentTime,
      clockSkewToleranceMinutes:
        policy.clockSkewToleranceMinutes,
    })) {
      skippedFresh.push({
        ...entry,
        coveredByRunId: prior.runId,
        coverageId: prior.coverageId,
      });
    } else {
      scheduled.push(entry);
    }
  }
  return {
    schemaVersion: 1,
    policyVersion: policy.policyVersion,
    asOf: currentTime.slice(0, 10),
    summary: {
      requested: scheduled.length + skippedFresh.length,
      scheduled: scheduled.length,
      skippedFresh: skippedFresh.length,
      perKind: Object.fromEntries(
        SUPPLY_FRESHNESS_KINDS.map((kind) => [
          kind,
          {
            scheduled: scheduled.filter((entry) =>
              entry.kind === kind).length,
            skippedFresh: skippedFresh.filter((entry) =>
              entry.kind === kind).length,
          },
        ])
      ),
    },
    scheduled,
    skippedFresh,
  };
}

export function createFreshnessCoverage({
  request,
  runId,
  completedAt,
  policyVersion,
}) {
  const normalized = normalizeRequest(request);
  const completed = isoTime(
    completedAt,
    "freshness completion"
  );
  invariant(
    typeof runId === "string" && runId.length > 0,
    "INVALID_FRESHNESS_COVERAGE",
    "Freshness coverage requires a run id."
  );
  invariant(
    typeof policyVersion === "string" &&
      policyVersion.length > 0,
    "INVALID_FRESHNESS_COVERAGE",
    "Freshness coverage requires a policy version."
  );
  const identity = {
    kind: normalized.kind,
    scopeKey: normalized.scopeKey,
    runId,
    completedAt: completed,
  };
  return {
    schemaVersion: 1,
    recordType: SUPPLY_FRESHNESS_RECORD_TYPE,
    coverageId: safeId(
      `fresh-${shortHash(identity)}-${normalized.kind}`
    ),
    runId,
    kind: normalized.kind,
    scopeKey: normalized.scopeKey,
    runKey: normalized.runKey,
    market: normalized.market,
    sourceProfileId: normalized.sourceProfileId,
    entityId: normalized.entityId,
    surfaceId: normalized.surfaceId,
    schedulerStatus: normalized.schedulerStatus,
    surfacePolicy: normalized.surfacePolicy,
    fetchEnabled: normalized.fetchEnabled,
    completedAt: completed,
    policyVersion,
    requestHash: hashValue(normalized),
  };
}

export function freshnessCoverageFromWorkItem(item) {
  const intake = item?.adminProjection ??
    item?.normalizedPayload?.intake;
  if (intake?.recordType !== SUPPLY_FRESHNESS_RECORD_TYPE) {
    return null;
  }
  const value = intake.coverage;
  if (!value || value.recordType !== SUPPLY_FRESHNESS_RECORD_TYPE) {
    return null;
  }
  if (value.runId !== item.runId) {
    throw new OperationsError(
      "INVALID_FRESHNESS_COVERAGE",
      `Freshness coverage ${value.coverageId ?? "unknown"} ` +
        "does not belong to its work-item run.",
      {
        details: {
          coverageRunId: value.runId ?? null,
          workItemRunId: item.runId ?? null,
        },
      }
    );
  }
  return {
    ...value,
    completedAt: isoTime(
      value.completedAt,
      "freshness completion"
    ),
  };
}

export function freshnessLedgerKey(value) {
  const request = normalizeRequest(value);
  return `${request.kind}|${request.scopeKey}`;
}

export function sourceCadenceScopeKey(value) {
  return [
    requiredString(value.entityId, "source entityId"),
    requiredString(value.surfaceId, "source surfaceId"),
  ].join("|");
}

function latestCoverageByScope({
  workItems,
  completedRunIds,
}) {
  const index = new Map();
  for (const item of workItems ?? []) {
    if (!completedRunIds.has(item?.runId)) continue;
    const record = freshnessCoverageFromWorkItem(item);
    if (!record) continue;
    const key = freshnessLedgerKey(record);
    const current = index.get(key);
    if (!current ||
        record.completedAt > current.completedAt ||
        (record.completedAt === current.completedAt &&
          record.coverageId > current.coverageId)) {
      index.set(key, record);
    }
  }
  return index;
}

function normalizeRequest(value) {
  invariant(
    value && typeof value === "object" && !Array.isArray(value),
    "INVALID_FRESHNESS_REQUEST",
    "Freshness request must be an object."
  );
  invariant(
    SUPPLY_FRESHNESS_KINDS.includes(value.kind),
    "INVALID_FRESHNESS_KIND",
    `Unsupported freshness kind ${value.kind ?? "missing"}.`,
    {kind: value.kind ?? null}
  );
  return {
    kind: value.kind,
    scopeKey: boundedString(
      value.scopeKey,
      "freshness scopeKey",
      500
    ),
    runKey: nullableBoundedString(
      value.runKey,
      "freshness runKey",
      500
    ),
    market: nullableBoundedString(
      value.market,
      "freshness market",
      80
    ),
    sourceProfileId: nullableBoundedString(
      value.sourceProfileId,
      "freshness sourceProfileId",
      160
    ),
    entityId: nullableBoundedString(
      value.entityId,
      "freshness entityId",
      200
    ),
    surfaceId: nullableBoundedString(
      value.surfaceId,
      "freshness surfaceId",
      200
    ),
    url: nullableBoundedString(
      value.url,
      "freshness url",
      1000
    ),
    schedulerStatus: nullableBoundedString(
      value.schedulerStatus,
      "freshness schedulerStatus",
      40
    ),
    surfacePolicy: nullableBoundedString(
      value.surfacePolicy,
      "freshness surfacePolicy",
      80
    ),
    fetchEnabled: value.fetchEnabled === true,
  };
}

function uniqueRequests(requests) {
  const index = new Map();
  for (const value of requests) {
    const request = normalizeRequest(value);
    const key = freshnessLedgerKey(request);
    const existing = index.get(key);
    if (existing &&
        hashValue(existing) !== hashValue(request)) {
      throw new OperationsError(
        "FRESHNESS_SCOPE_COLLISION",
        `Freshness scope ${key} maps to conflicting requests.`,
        {details: {key}}
      );
    }
    index.set(key, request);
  }
  return [...index.values()].sort((left, right) =>
    freshnessLedgerKey(left).localeCompare(
      freshnessLedgerKey(right)
    ));
}

function assertPolicy(policy) {
  invariant(
    policy?.schemaVersion === 1 &&
      typeof policy.policyVersion === "string" &&
      Number.isSafeInteger(policy.clockSkewToleranceMinutes),
    "INVALID_FRESHNESS_POLICY",
    "Supply Intake freshness policy is invalid."
  );
  for (const kind of SUPPLY_FRESHNESS_KINDS) {
    invariant(
      Number.isSafeInteger(
        policy.kinds?.[kind]?.freshForHours
      ) &&
        policy.kinds[kind].freshForHours > 0,
      "INVALID_FRESHNESS_POLICY",
      `Freshness policy is missing ${kind}.`,
      {kind}
    );
  }
}

function isFresh({
  completedAt,
  freshUntil,
  now,
  clockSkewToleranceMinutes,
}) {
  const completed = Date.parse(completedAt);
  const current = Date.parse(now);
  const expiry = Date.parse(freshUntil);
  const skewMs = clockSkewToleranceMinutes * 60 * 1000;
  return completed <= current + skewMs && current <= expiry;
}

function addHours(value, hours) {
  return new Date(
    Date.parse(value) + hours * 60 * 60 * 1000
  ).toISOString();
}

function isoTime(value, label) {
  const parsed = Date.parse(value ?? "");
  invariant(
    Number.isFinite(parsed),
    "INVALID_FRESHNESS_TIME",
    `${label} must be an ISO-8601 timestamp.`,
    {value: value ?? null}
  );
  return new Date(parsed).toISOString();
}

function requiredString(value, label) {
  return boundedString(value, label, 500);
}

function boundedString(value, label, maxLength) {
  invariant(
    typeof value === "string" &&
      value.length > 0 &&
      value.length <= maxLength,
    "INVALID_FRESHNESS_REQUEST",
    `${label} must be a non-empty string of at most ` +
      `${maxLength} characters.`
  );
  return value;
}

function nullableString(value) {
  return typeof value === "string" && value.length > 0 ?
    value :
    null;
}

function nullableBoundedString(value, label, maxLength) {
  if (value === null || value === undefined || value === "") {
    return null;
  }
  return boundedString(value, label, maxLength);
}
