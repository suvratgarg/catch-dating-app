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

  const eventSnap = await db
    .collection("eventIntakeDashboards")
    .doc("current")
    .get();
  const eventBridge = bridgeFromDashboard(eventSnap.data() ?? {});
  if (eventBridge) {
    return {bridge: projectEventIntakeBridge(eventBridge, "event_intake")};
  }

  return {bridge: emptyEventIntakeBridge()};
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
