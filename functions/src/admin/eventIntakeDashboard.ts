import {onCall, CallableRequest} from "firebase-functions/v2/https";
import * as admin from "firebase-admin";
import {appCheckCallableOptions} from "../shared/callableOptions";
import {checkRateLimit as defaultCheckRateLimit} from "../shared/rateLimit";
import {requireAdminRole} from "./adminAuth";

const eventIntakeRoles = ["admin", "adminOwner", "support"] as const;

interface EventIntakeDashboardDeps {
  firestore: () => FirebaseFirestore.Firestore;
  checkRateLimit?: (
    db: FirebaseFirestore.Firestore,
    uid: string,
    action: string
  ) => Promise<void>;
}

const defaultDeps: EventIntakeDashboardDeps = {
  firestore: () => admin.firestore(),
  checkRateLimit: defaultCheckRateLimit,
};

export interface AdminGetEventIntakeDashboardResponse {
  bridge: Record<string, unknown>;
}

/**
 * Returns the current Event Intake dashboard bridge from the event-owned
 * dashboard document. Missing data returns an explicit empty bridge rather than
 * falling back to Marketing, so candidate provenance stays deterministic.
 * @param {CallableRequest<unknown>} request Callable request.
 * @param {EventIntakeDashboardDeps} deps Injectable dependencies.
 * @return {Promise<AdminGetEventIntakeDashboardResponse>} Event bridge.
 */
export async function adminGetEventIntakeDashboardHandler(
  request: CallableRequest<unknown>,
  deps: EventIntakeDashboardDeps = defaultDeps
): Promise<AdminGetEventIntakeDashboardResponse> {
  const adminContext = requireAdminRole(request, eventIntakeRoles);
  const db = deps.firestore();
  await deps.checkRateLimit?.(
    db,
    adminContext.uid,
    "adminGetEventIntakeDashboard"
  );

  const [eventSnap, decisionSnap] = await Promise.all([
    db.collection("eventIntakeDashboards").doc("current").get(),
    db.collection("eventIntakeReviewDecisions").limit(500).get(),
  ]);
  const eventBridge = bridgeFromDashboard(eventSnap.data() ?? {});
  if (eventBridge) {
    const decisions = decisionSnap.docs.map((doc) => doc.data());
    return {
      bridge: overlayEventIntakeDecisions(
        projectEventIntakeBridge(eventBridge, "event_intake"),
        decisions
      ),
    };
  }

  return {bridge: emptyEventIntakeBridge()};
}

export function overlayEventIntakeDecisions(
  bridge: Record<string, unknown>,
  decisions: Array<Record<string, unknown>>
): Record<string, unknown> {
  const byTarget = new Map(
    decisions.map((decision) => [
      `${stringValue(decision.targetType)}:${stringValue(decision.targetId)}`,
      decision,
    ])
  );
  const sourceProfiles = overlayDecisionArray(
    asArray(bridge.sourceProfiles),
    "source_profile",
    byTarget
  );
  const queryTemplates = overlayDecisionArray(
    asArray(bridge.queryTemplates),
    "query_template",
    byTarget
  );
  const sourceResults = overlayDecisionArray(
    asArray(bridge.sourceResults),
    "source_result",
    byTarget
  );
  const eventCandidates = overlayDecisionArray(
    asArray(bridge.eventCandidates),
    "event_candidate",
    byTarget
  );
  const runPlan = overlayDecisionObject(
    recordValue(bridge.runPlan),
    "run_plan",
    byTarget
  );
  const summary = recordValue(bridge.summary);
  return {
    ...bridge,
    summary: {
      ...summary,
      approvedCandidates: eventCandidates.filter((candidate) =>
        candidate.reviewState === "approved"
      ).length,
      candidatesNeedingReview: eventCandidates.filter((candidate) =>
        !["approved", "rejected"].includes(String(candidate.reviewState))
      ).length,
      overlaidDecisions: byTarget.size,
    },
    sourceProfiles,
    queryTemplates,
    runPlan,
    sourceResults,
    eventCandidates,
  };
}

function overlayDecisionArray(
  values: unknown[],
  targetType: string,
  byTarget: Map<string, Record<string, unknown>>
): Array<Record<string, unknown>> {
  return values.map((value) => {
    const item = recordValue(value);
    return overlayDecisionObject(item, targetType, byTarget);
  });
}

function overlayDecisionObject(
  item: Record<string, unknown>,
  targetType: string,
  byTarget: Map<string, Record<string, unknown>>
): Record<string, unknown> {
  const id = stringValue(item.id);
  const decision = id ? byTarget.get(`${targetType}:${id}`) : null;
  if (!decision) return item;
  const edits = recordValue(decision.edits);
  const decisionStatus =
    stringValue(decision.decisionStatus) ?? "needs_changes";
  const stateField =
    targetType === "event_candidate" ? "reviewState" : "status";
  return {
    ...item,
    ...edits,
    id,
    [stateField]: decisionStatus,
    latestDecision: {
      decision: stringValue(decision.decision),
      note: stringValue(decision.note),
      reviewer: stringValue(decision.reviewedByUid),
      reviewedAt: isoFromTimestamp(decision.reviewedAt),
    },
  };
}

/**
 * Extracts a dashboard bridge from a Firestore document.
 * @param {Record<string, unknown>} dashboard Dashboard doc.
 * @return {Record<string, unknown> | null} Bridge or null.
 */
function bridgeFromDashboard(
  dashboard: Record<string, unknown>
): Record<string, unknown> | null {
  const bridge = dashboard.bridge;
  if (bridge && typeof bridge === "object" && !Array.isArray(bridge)) {
    return bridge as Record<string, unknown>;
  }
  return null;
}

/**
 * Projects a broader generated bridge into the Event Intake read model.
 * @param {Record<string, unknown>} bridge Source bridge.
 * @param {string} bridgeSource Source marker.
 * @return {Record<string, unknown>} Event Intake bridge.
 */
function projectEventIntakeBridge(
  bridge: Record<string, unknown>,
  bridgeSource: string
): Record<string, unknown> {
  return {
    schemaVersion: bridge.schemaVersion ?? 1,
    program: "catch-event-intake",
    generatedAt: bridge.generatedAt ?? null,
    bridgeSource,
    city: bridge.city ?? {id: "unknown", label: "Unknown"},
    weekStart: bridge.weekStart ?? null,
    weekEnd: bridge.weekEnd ?? null,
    summary: bridge.summary ?? {},
    sourceProfiles: asArray(bridge.sourceProfiles),
    queryTemplates: asArray(bridge.queryTemplates),
    runPlan: bridge.runPlan ?? emptyRunPlan(),
    sourceResults: asArray(bridge.sourceResults),
    eventCandidates: asArray(bridge.eventCandidates),
    dedupeGroups: asArray(bridge.dedupeGroups),
    auditTrail: asArray(bridge.auditTrail),
    commands: stringRecord(bridge.commands),
  };
}

/**
 * Returns an empty event-intake bridge with the fields the admin UI expects.
 * @return {Record<string, unknown>} Empty bridge.
 */
function emptyEventIntakeBridge(): Record<string, unknown> {
  return projectEventIntakeBridge({}, "empty");
}

/**
 * Returns an empty run-plan shape for missing dashboard data.
 * @return {Record<string, unknown>} Empty run plan.
 */
function emptyRunPlan(): Record<string, unknown> {
  return {
    id: "event-intake-empty",
    status: "not_configured",
    schedule: {
      cadence: "manual",
      publishDay: "unassigned",
      lookaheadDays: 0,
    },
    budgets: {
      maxQueries: 0,
      maxSourceResults: 0,
      maxCandidatePool: 0,
    },
    automationPolicy: {
      searchProvider: "not_configured",
      networkFetchesEnabled: false,
      instagramScrapingEnabled: false,
    },
  };
}

/**
 * Narrows unknown values into arrays.
 * @param {unknown} value Raw value.
 * @return {unknown[]} Array value.
 */
function asArray(value: unknown): unknown[] {
  return Array.isArray(value) ? value : [];
}

function recordValue(value: unknown): Record<string, unknown> {
  return value && typeof value === "object" && !Array.isArray(value) ?
    value as Record<string, unknown> :
    {};
}

function stringValue(value: unknown): string | null {
  return typeof value === "string" && value.trim() ? value.trim() : null;
}

function isoFromTimestamp(value: unknown): string | null {
  if (value instanceof Date && Number.isFinite(value.getTime())) {
    return value.toISOString();
  }
  if (recordValue(value).toDate instanceof Function) {
    const date = (recordValue(value).toDate as () => unknown)();
    return date instanceof Date && Number.isFinite(date.getTime()) ?
      date.toISOString() :
      null;
  }
  if (typeof value === "string" && Number.isFinite(Date.parse(value))) {
    return new Date(value).toISOString();
  }
  return null;
}

/**
 * Narrows command maps into string-only records.
 * @param {unknown} value Raw value.
 * @return {Record<string, string>} Command record.
 */
function stringRecord(value: unknown): Record<string, string> {
  if (!value || typeof value !== "object" || Array.isArray(value)) return {};
  return Object.fromEntries(
    Object.entries(value as Record<string, unknown>).filter((entry):
      entry is [string, string] => typeof entry[1] === "string")
  );
}

export const adminGetEventIntakeDashboard = onCall(
  appCheckCallableOptions,
  (request) => adminGetEventIntakeDashboardHandler(request)
);
