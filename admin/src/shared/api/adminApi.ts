import {httpsCallable as firebaseHttpsCallable} from "firebase/functions";
import {functions} from "./firebaseFunctions";
import {dataMode} from "./dataMode";
export {dataMode} from "./dataMode";
import {
  validateAdminCallableRequest,
  validateAdminCallableResponse,
} from "../../generated/validators/adminCallableValidators";
import {
  sampleClubDetails,
  sampleEventDetails,
  sampleExternalEventRows,
  sampleHostAnalytics,
  sampleOverview,
  sampleUserAnalyticsReport,
} from "./sampleData";
import marketingOpsBridgeJson from "../../generated/marketingOpsBridge.json";
import eventIntakeBridgeJson from "../../generated/eventIntakeBridge.json";
import externalEventImportExecutionPlanJson
  from "../../generated/externalEventImportExecutionPlan.json";
import externalEventImportPlanJson
  from "../../generated/externalEventImportPlan.json";
import {sampleIntakeOperations} from
  "../operations/sampleIntakeOperations";
import type {
  AdminListIntakeOperationsPayload,
  AdminListIntakeOperationsResponse,
} from "../operations/operationsTypes";
import {
  AdminAssignSafetyTriageItemPayload,
  AdminAssignSafetyTriageItemResponse,
  AdminCreateMarketingContentDraftPayload,
  AdminCreateMarketingContentDraftResponse,
  AdminGetAdminUserRolesPayload,
  AdminGetAdminUserRolesResponse,
  AdminListAdminRoleAssignmentsPayload,
  AdminListAdminRoleAssignmentsResponse,
  AdminEventListRow,
  AdminDecideSafetyTriageItemPayload,
  AdminDecideSafetyTriageItemResponse,
  AdminGetEventDetailsPayload,
  AdminGetEventDetailsResponse,
  AdminGetEventSupplyReadinessResponse,
  AdminGetMarketingOpsDashboardResponse,
  AdminGetSafetyTriageDetailsPayload,
  AdminGetSafetyTriageDetailsResponse,
  AdminSafetyTriageDetails,
  AdminSafetyTriageEvidence,
  AdminSafetyTriageSeverity,
  AdminSafetyTriageSla,
  AdminDecideAccessApplicationPayload,
  AdminDecideAccessApplicationResponse,
  AdminGetAccessApplicationDetailsPayload,
  AdminGetAccessApplicationDetailsResponse,
  AdminDecideClubClaimPayload,
  AdminDecideClubClaimResponse,
  AdminGetClubClaimRequestDetailsPayload,
  AdminGetClubClaimRequestDetailsResponse,
  AdminListClubClaimRequestsResponse,
  AdminDecideOrganizerEventCandidatePayload,
  AdminDecideOrganizerEventCandidateResponse,
  AdminDecideOrganizerIntakePayload,
  AdminDecideOrganizerIntakeResponse,
  AdminDecideOrganizerPolicyGapPayload,
  AdminDecideOrganizerPolicyGapResponse,
  AdminRecordOrganizerCurationPayload,
  AdminRecordOrganizerCurationResponse,
  AdminRecordEventIntakeReviewDecisionPayload,
  AdminRecordEventIntakeReviewDecisionResponse,
  AdminPublishExternalEventPayload,
  AdminPublishExternalEventResponse,
  AdminRecordMarketingReviewDecisionPayload,
  AdminRecordMarketingReviewDecisionResponse,
  AdminGetEventIntakeDashboardResponse,
  AdminRoleClaim,
  AdminRoleAssignmentRow,
  AdminSetAdminUserRolesPayload,
  AdminSetAdminUserRolesResponse,
  AdminUserRoleRecord,
  AdminClubListRow,
  AdminGetClubDetailsPayload,
  AdminGetClubDetailsResponse,
  AdminListEventDetailsPayload,
  AdminListEventDetailsResponse,
  AdminListExternalEventDetailsPayload,
  AdminListExternalEventDetailsResponse,
  AdminListClubDetailsPayload,
  AdminListClubDetailsResponse,
  AdminOverviewResponse,
  AdminResolveOrganizerEventLocationPayload,
  AdminResolveOrganizerEventLocationResponse,
  AdminSetClubIndexStatusPayload,
  AdminSetClubIndexStatusResponse,
  AdminUpdateEventDetailsPayload,
  AdminUpdateEventDetailsResponse,
  AdminUpdateClubDetailsPayload,
  AdminUpdateClubDetailsResponse,
  HostAnalyticsQueryPayload,
  HostAnalyticsResponse,
  MarketingOpsBridge,
  EventIntakeBridge,
  MarketingContentDraft,
  UserAnalyticsQueryPayload,
  UserAnalyticsResponse,
} from "../types/adminTypes";

const sampleGeneratedAt = "2026-06-25T08:30:00.000Z";

function shouldValidateAdminCallableResponses() {
  return import.meta.env.DEV ||
    import.meta.env.VITE_ADMIN_VALIDATE_RESPONSES === "true";
}

function httpsCallable<RequestData, ResponseData>(
  functionsInstance: typeof functions,
  name: string
) {
  const callable = firebaseHttpsCallable<RequestData, ResponseData>(
    functionsInstance,
    name
  );
  return async (payload: RequestData) => {
    validateAdminCallableRequest(name, payload);
    const result = await callable(payload);
    if (shouldValidateAdminCallableResponses()) {
      validateAdminCallableResponse(name, result.data);
    }
    return result;
  };
}

const sampleAdminUsers = new Map<string, AdminUserRoleRecord>([
  ["admin-owner", {
    targetUid: "admin-owner",
    email: "owner@catch.local",
    displayName: "Catch Admin Owner",
    disabled: false,
    roles: ["adminOwner"],
    assignmentPath: "adminRoleAssignments/admin-owner",
  }],
  ["support-ops", {
    targetUid: "support-ops",
    email: "support@catch.local",
    displayName: "Support Ops",
    disabled: false,
    roles: ["support"],
    assignmentPath: "adminRoleAssignments/support-ops",
  }],
]);

function sampleAdminRoleAssignments(
  payload: AdminListAdminRoleAssignmentsPayload = {}
): AdminListAdminRoleAssignmentsResponse {
  const status = payload.status ?? "all";
  const limit = Math.max(1, Math.min(payload.limit ?? 50, 100));
  const rows: AdminRoleAssignmentRow[] = Array.from(sampleAdminUsers.values())
    .map((user) => {
      const assignmentStatus: AdminRoleAssignmentRow["status"] =
        user.roles.length > 0 ? "active" : "revoked";
      return {
        ...user,
        roles: [...user.roles],
        status: assignmentStatus,
        updatedAt: sampleGeneratedAt,
        updatedByUid: "admin-owner",
      };
    })
    .filter((row) => status === "all" || row.status === status)
    .sort((a, b) => a.targetUid.localeCompare(b.targetUid))
    .slice(0, limit);
  return {
    generatedAt: sampleGeneratedAt,
    rows,
    source: "adminRoleAssignments",
  };
}

function sampleAdminUser(targetUid: string): AdminUserRoleRecord {
  const normalizedUid = targetUid.trim();
  const existing = sampleAdminUsers.get(normalizedUid);
  if (existing) {
    return {
      ...existing,
      roles: [...existing.roles],
    };
  }
  const fallback: AdminUserRoleRecord = {
    targetUid: normalizedUid,
    email: `${normalizedUid}@example.local`,
    displayName: normalizedUid,
    disabled: false,
    roles: [] as AdminRoleClaim[],
    assignmentPath: `adminRoleAssignments/${normalizedUid}`,
  };
  sampleAdminUsers.set(normalizedUid, fallback);
  return {
    ...fallback,
    roles: [...fallback.roles],
  };
}

export async function loadOverview(): Promise<AdminOverviewResponse> {
  if (dataMode() === "sample") {
    await new Promise((resolve) => window.setTimeout(resolve, 180));
    return sampleOverview;
  }

  const callable = httpsCallable<unknown, AdminOverviewResponse>(
    functions,
    "adminGetOverview"
  );
  const result = await callable({});
  return result.data;
}

export async function getAdminUserRoles(
  payload: AdminGetAdminUserRolesPayload
): Promise<AdminGetAdminUserRolesResponse> {
  if (dataMode() === "sample") {
    await new Promise((resolve) => window.setTimeout(resolve, 140));
    return {user: sampleAdminUser(payload.targetUid)};
  }

  const callable = httpsCallable<
    AdminGetAdminUserRolesPayload,
    AdminGetAdminUserRolesResponse
  >(functions, "adminGetAdminUserRoles");
  const result = await callable(payload);
  return result.data;
}

export async function listAdminRoleAssignments(
  payload: AdminListAdminRoleAssignmentsPayload = {}
): Promise<AdminListAdminRoleAssignmentsResponse> {
  if (dataMode() === "sample") {
    await new Promise((resolve) => window.setTimeout(resolve, 140));
    return sampleAdminRoleAssignments(payload);
  }

  const callable = httpsCallable<
    AdminListAdminRoleAssignmentsPayload,
    AdminListAdminRoleAssignmentsResponse
  >(functions, "adminListAdminRoleAssignments");
  const result = await callable(payload);
  return result.data;
}

export async function setAdminUserRoles(
  payload: AdminSetAdminUserRolesPayload
): Promise<AdminSetAdminUserRolesResponse> {
  if (dataMode() === "sample") {
    await new Promise((resolve) => window.setTimeout(resolve, 220));
    const before = sampleAdminUser(payload.targetUid);
    if (!payload.note.trim()) {
      throw new Error("A review note is required for admin role changes.");
    }
    const after = {
      ...before,
      roles: [...payload.roles],
    };
    sampleAdminUsers.set(payload.targetUid, after);
    return {
      user: after,
      beforeRoles: before.roles,
      afterRoles: after.roles,
    };
  }

  const callable = httpsCallable<
    AdminSetAdminUserRolesPayload,
    AdminSetAdminUserRolesResponse
  >(functions, "adminSetAdminUserRoles");
  const result = await callable(payload);
  return result.data;
}

export async function loadSafetyTriageDetails(
  payload: AdminGetSafetyTriageDetailsPayload
): Promise<AdminGetSafetyTriageDetailsResponse> {
  if (dataMode() === "sample") {
    await new Promise((resolve) => window.setTimeout(resolve, 160));
    return sampleSafetyTriageDetails(payload.targetPath);
  }

  const callable = httpsCallable<
    AdminGetSafetyTriageDetailsPayload,
    AdminGetSafetyTriageDetailsResponse
  >(functions, "adminGetSafetyTriageDetails");
  const result = await callable(payload);
  return result.data;
}

export async function decideSafetyTriageItem(
  payload: AdminDecideSafetyTriageItemPayload
): Promise<AdminDecideSafetyTriageItemResponse> {
  if (dataMode() === "sample") {
    await new Promise((resolve) => window.setTimeout(resolve, 220));
    const rows = [
      ...sampleOverview.queues.safetyReports,
      ...sampleOverview.queues.moderationFlags,
      ...sampleOverview.queues.eventSafetyReports,
    ];
    const row = rows.find((item) => item.targetPath === payload.targetPath);
    if (!row) {
      throw new Error(`Safety item ${payload.targetPath} was not found in local preview data.`);
    }
    const status = payload.decision === "review" ? "reviewed" : "dismissed";
    row.status = status;
    return {
      targetPath: payload.targetPath,
      decision: payload.decision,
      status,
    };
  }

  const callable = httpsCallable<
    AdminDecideSafetyTriageItemPayload,
    AdminDecideSafetyTriageItemResponse
  >(functions, "adminDecideSafetyTriageItem");
  const result = await callable(payload);
  return result.data;
}

export async function assignSafetyTriageItem(
  payload: AdminAssignSafetyTriageItemPayload
): Promise<AdminAssignSafetyTriageItemResponse> {
  if (dataMode() === "sample") {
    await new Promise((resolve) => window.setTimeout(resolve, 180));
    if (!payload.note.trim()) {
      throw new Error("Add an assignment note before saving.");
    }
    const details = sampleSafetyTriageDetails(payload.targetPath).item;
    return {
      targetPath: payload.targetPath,
      assignment: {
        ...details.assignment,
        assigneeUid: payload.assigneeUid,
      },
    };
  }

  const callable = httpsCallable<
    AdminAssignSafetyTriageItemPayload,
    AdminAssignSafetyTriageItemResponse
  >(functions, "adminAssignSafetyTriageItem");
  const result = await callable(payload);
  return result.data;
}

function sampleSafetyTriageDetails(
  targetPath: string
): AdminGetSafetyTriageDetailsResponse {
  const rows = [
    ...sampleOverview.queues.safetyReports,
    ...sampleOverview.queues.moderationFlags,
    ...sampleOverview.queues.eventSafetyReports,
  ];
  const row = rows.find((item) => item.targetPath === targetPath);
  if (!row) {
    throw new Error(`Safety item ${targetPath} was not found in local preview data.`);
  }
  const [collection] = targetPath.split("/");
  const kind = collection === "reports" ? "report" :
    collection === "moderationFlags" ? "moderationFlag" :
      "eventSafetyReport";
  const detailParts = row.detail.split(" - ");
  const primaryUserId = extractDetailValue(detailParts, "target") ??
    extractDetailValue(detailParts, "reporter");
  const source = detailParts.find((part) =>
    !part.startsWith("target ") &&
    !part.startsWith("club ") &&
    !part.startsWith("reporter ")
  ) ?? null;
  const severity = sampleSafetySeverity(kind, row.title, row.detail);
  const item: AdminSafetyTriageDetails = {
    targetPath,
    kind,
    title: row.title,
    summary: row.detail,
    status: row.status,
    createdAt: row.createdAt,
    updatedAt: null,
    primaryUserId,
    secondaryUserId: kind === "report" ?
      extractDetailValue(detailParts, "reporter") :
      null,
    eventId: kind === "eventSafetyReport" ?
      row.title.replace(/^Event\s+/u, "") :
      null,
    clubId: extractDetailValue(detailParts, "club"),
    source: kind === "eventSafetyReport" ? "event_success_feedback" : source,
    contextId: kind === "moderationFlag" ?
      "local-preview/moderation/context" :
      kind === "eventSafetyReport" ? "local-preview/feedback" : "local-preview/context",
    assignment: {
      ownerTeam: sampleSafetyOwnerTeam(kind, source),
      assigneeUid: null,
      queue: collection,
      severity,
    },
    sla: sampleSafetySla(row.createdAt, severity),
    evidence: sampleSafetyEvidence({
      clubId: extractDetailValue(detailParts, "club"),
      contextId: kind === "moderationFlag" ?
        "local-preview/moderation/context" :
        kind === "eventSafetyReport" ? "local-preview/feedback" : "local-preview/context",
      detail: row.detail,
      eventId: kind === "eventSafetyReport" ?
        row.title.replace(/^Event\s+/u, "") :
        null,
      primaryUserId,
      secondaryUserId: kind === "report" ?
        extractDetailValue(detailParts, "reporter") :
        null,
      source: kind === "eventSafetyReport" ? "event_success_feedback" : source,
      title: row.title,
    }),
    fields: [
      {label: "Queue item", value: row.title},
      {label: "Detail", value: row.detail},
      {label: "Status", value: row.status},
      {label: "Target path", value: row.targetPath},
    ],
    priorHistory: sampleSafetyPriorHistory({
      eventId: kind === "eventSafetyReport" ?
        row.title.replace(/^Event\s+/u, "") :
        null,
      kind,
      primaryUserId,
      targetPath,
    }),
    outcomeGuidance: sampleSafetyOutcomeGuidance({
      hasContext: true,
      kind,
      severity,
      targetPath,
    }),
    nextActions: [
      "Open the source document before resolving.",
      "Confirm reporter, subject, event, and channel context.",
      "Use audited safety mutations only after the policy outcome is explicit.",
    ],
  };
  return {item};
}

function sampleSafetyPriorHistory({
  eventId,
  kind,
  primaryUserId,
  targetPath,
}: {
  eventId: string | null;
  kind: AdminSafetyTriageDetails["kind"];
  primaryUserId: string | null;
  targetPath: string;
}): AdminSafetyTriageDetails["priorHistory"] {
  const history: AdminSafetyTriageDetails["priorHistory"] = [];
  if (primaryUserId && kind !== "eventSafetyReport") {
    history.push({
      id: "reportsAboutPrimaryUser",
      label: "Reports about primary user",
      count: 1,
      sampleTargetPaths: [targetPath === "reports/report-2" ?
        "reports/report-1" :
        "reports/report-2"],
    });
  }
  if (kind === "moderationFlag" && primaryUserId) {
    history.push({
      id: "moderationForPrimaryUser",
      label: "Moderation flags for primary user",
      count: 1,
      sampleTargetPaths: ["moderationFlags/flag-2"],
    });
  }
  if (kind === "eventSafetyReport" && eventId) {
    history.push({
      id: "eventSafetyForEvent",
      label: "Event safety reports for event",
      count: 1,
      sampleTargetPaths: ["eventSafetyReports/event-2_user-7"],
    });
  }
  return history;
}

function sampleSafetyOutcomeGuidance({
  hasContext,
  kind,
  severity,
  targetPath,
}: {
  hasContext: boolean;
  kind: AdminSafetyTriageDetails["kind"];
  severity: AdminSafetyTriageSeverity;
  targetPath: string;
}): AdminSafetyTriageDetails["outcomeGuidance"] {
  const guidance: AdminSafetyTriageDetails["outcomeGuidance"] = [];
  if (severity === "high") {
    guidance.push({
      id: "escalate_safety_lead",
      label: "Escalate to safety lead",
      detail: "High-severity queue item. Keep a safety reviewer assigned before any account action.",
      severity: "critical",
      actionStatus: "manual",
    });
  }
  if (targetPath.includes("report") || kind === "moderationFlag") {
    guidance.push({
      id: "restriction_requires_contract",
      label: "Restriction requires separate account action",
      detail: "This tab does not restrict accounts. Use a dedicated account-safety callable before changing user state.",
      severity: "warning",
      actionStatus: "needs_contract",
    });
  }
  if (kind === "eventSafetyReport") {
    guidance.push({
      id: "route_event_owner",
      label: "Route event follow-up",
      detail: "Review event, host, attendance, and feedback context before resolving the event safety report.",
      severity: "warning",
      actionStatus: "manual",
    });
  }
  if (!hasContext) {
    guidance.push({
      id: "request_more_context",
      label: "Request more information",
      detail: "No source context id is present. Ask for supporting detail before closing the queue item.",
      severity: "info",
      actionStatus: "manual",
    });
  }
  guidance.push({
    id: "status_only_resolution",
    label: "Reviewed/dismissed is queue-only",
    detail: "The current mutation only updates the queue document status. Account, content, event, and payment changes require their owning workflow.",
    severity: "info",
    actionStatus: "available",
  });
  return guidance;
}

function extractDetailValue(
  parts: string[],
  label: string
): string | null {
  const prefix = `${label} `;
  const match = parts.find((part) => part.startsWith(prefix));
  return match ? match.slice(prefix.length) : null;
}

function sampleAccessApplicationDetails(
  applicationUid: string
): AdminGetAccessApplicationDetailsResponse["application"] {
  const row = sampleOverview.queues.accessApplications.find((item) =>
    item.targetPath === `accessApplications/${applicationUid}`
  );
  if (!row) {
    throw new Error(
      `Access application ${applicationUid} was not found in local preview data.`
    );
  }
  const isMumbai = row.detail.toLowerCase().includes("mumbai");
  const wantsToHost = row.detail.toLowerCase().includes("wants to host") ||
    row.detail.toLowerCase().includes("host");
  const city = isMumbai ? "mumbai" : "delhi";
  const role = wantsToHost ? "host" : "attendee";
  const referralSource = isMumbai ? "organizer referral" : "founder waitlist";
  const inviteCode = isMumbai ? "mumbai-launch" : "delhi-founder";
  const instagramHandle = isMumbai ? "@rohanruns" : "@mayaruns";
  return {
    uid: applicationUid,
    targetPath: row.targetPath,
    status: row.status,
    city,
    role,
    eventTypes: wantsToHost ? ["running", "singlesMixer"] : ["running"],
    availabilityWindows: isMumbai ?
      ["weekdayEvening", "weekendMorning"] :
      ["weekendMorning"],
    wantsToHost,
    inviteCode,
    instagramHandle,
    referralSource,
    whyCatch: wantsToHost ?
      "I can help host launch events and bring a reliable first group." :
      "I want to meet people offline through curated active events.",
    cohortId: null,
    hostUserId: null,
    reviewerUid: null,
    reviewNote: null,
    submissionCount: isMumbai ? 1 : 2,
    createdAt: row.createdAt,
    submittedAt: row.createdAt,
    updatedAt: row.createdAt,
    reviewedAt: null,
    duplicateSignals: [
      {
        id: "inviteCode",
        label: "Invite code",
        value: inviteCode,
        count: 0,
        sampleTargetPaths: [],
      },
      {
        id: "instagramHandle",
        label: "Instagram",
        value: instagramHandle,
        count: 0,
        sampleTargetPaths: [],
      },
      {
        id: "referralSource",
        label: "Referral source",
        value: referralSource,
        count: isMumbai ? 0 : 1,
        sampleTargetPaths: isMumbai ?
          [] :
          ["accessApplications/application-2"],
      },
      {
        id: "cityRole",
        label: "City and role",
        value: `${city} / ${role}`,
        count: 0,
        sampleTargetPaths: [],
      },
    ],
  };
}

function sampleSafetySeverity(
  kind: AdminSafetyTriageDetails["kind"],
  title: string,
  detail: string
): AdminSafetyTriageSeverity {
  if (kind === "eventSafetyReport") return "high";
  const haystack = `${title} ${detail}`.toLowerCase();
  if (haystack.includes("harassment") || haystack.includes("explicit")) {
    return "high";
  }
  if (haystack.includes("fake") || haystack.includes("banned")) {
    return "medium";
  }
  return "watch";
}

function sampleSafetyOwnerTeam(
  kind: AdminSafetyTriageDetails["kind"],
  source: string | null
): string {
  if (kind === "eventSafetyReport") return "Event safety";
  if (kind === "moderationFlag") return "Moderation";
  return source?.includes("chat") ? "Trust and safety" : "Support review";
}

function sampleSafetySla(
  createdAt: string | null,
  severity: AdminSafetyTriageSeverity
): AdminSafetyTriageSla {
  const hours = severity === "high" ? 24 : severity === "medium" ? 48 : 72;
  const dueAt = createdAt ?
    new Date(Date.parse(createdAt) + hours * 3600000).toISOString() :
    null;
  return {
    dueAt,
    state: sampleSafetySlaState(dueAt),
    policy: `${severity} queue default response SLA: ${hours}h.`,
  };
}

function sampleSafetySlaState(
  dueAt: string | null
): AdminSafetyTriageSla["state"] {
  if (!dueAt) return "unknown";
  const diffMs = Date.parse(dueAt) - Date.parse(sampleGeneratedAt);
  if (Number.isNaN(diffMs)) return "unknown";
  if (diffMs < 0) return "overdue";
  if (diffMs <= 6 * 3600000) return "due_soon";
  return "ok";
}

function sampleSafetyEvidence({
  clubId,
  contextId,
  detail,
  eventId,
  primaryUserId,
  secondaryUserId,
  source,
  title,
}: {
  clubId: string | null;
  contextId: string | null;
  detail: string;
  eventId: string | null;
  primaryUserId: string | null;
  secondaryUserId: string | null;
  source: string | null;
  title: string;
}): AdminSafetyTriageEvidence[] {
  return [
    safetyEvidence("Primary user", primaryUserId, sampleUserPath(primaryUserId),
      false),
    safetyEvidence("Secondary user", secondaryUserId,
      sampleUserPath(secondaryUserId), false),
    safetyEvidence("Event", eventId, eventId ? `events/${eventId}` : null,
      false),
    safetyEvidence("Club", clubId, clubId ? `clubs/${clubId}` : null, false),
    safetyEvidence("Source", source, null, false),
    safetyEvidence("Context", contextId, contextId, false),
    safetyEvidence("Queue detail", `${title} - ${detail}`, null, true),
  ].filter((item): item is AdminSafetyTriageEvidence => item !== null);
}

function safetyEvidence(
  label: string,
  value: string | null,
  sourcePath: string | null,
  sensitive: boolean
): AdminSafetyTriageEvidence | null {
  if (!value) return null;
  return {label, value, sourcePath, sensitive};
}

function sampleUserPath(userId: string | null): string | null {
  return userId ? `users/${userId}` : null;
}

export async function loadHostAnalytics(
  payload: HostAnalyticsQueryPayload = {}
): Promise<HostAnalyticsResponse> {
  if (dataMode() === "sample") {
    await new Promise((resolve) => window.setTimeout(resolve, 180));
    return sampleHostAnalytics;
  }

  const callable = httpsCallable<
    HostAnalyticsQueryPayload,
    HostAnalyticsResponse
  >(functions, "adminGetHostAnalytics");
  const result = await callable(payload);
  return result.data;
}

export async function loadUserAnalytics(
  payload: UserAnalyticsQueryPayload
): Promise<UserAnalyticsResponse> {
  if (dataMode() === "sample") {
    await new Promise((resolve) => window.setTimeout(resolve, 180));
    return sampleUserAnalyticsReport(payload);
  }

  const callable = httpsCallable<
    UserAnalyticsQueryPayload,
    UserAnalyticsResponse
  >(functions, "adminGetUserAnalytics");
  const result = await callable(payload);
  return result.data;
}

const sampleMarketingOpsBridge =
  marketingOpsBridgeJson as unknown as MarketingOpsBridge;
let sampleMarketingOpsBridgeState = sampleMarketingOpsBridge;
const sampleEventIntakeBridge =
  eventIntakeBridgeJson as unknown as EventIntakeBridge;
let sampleEventIntakeBridgeState = sampleEventIntakeBridge;

export async function loadMarketingOpsBridge():
  Promise<AdminGetMarketingOpsDashboardResponse> {
  if (dataMode() === "sample") {
    await new Promise((resolve) => window.setTimeout(resolve, 180));
    return {bridge: sampleMarketingOpsBridgeState};
  }

  const callable = httpsCallable<unknown, AdminGetMarketingOpsDashboardResponse>(
    functions,
    "adminGetMarketingOpsDashboard"
  );
  const result = await callable({});
  return result.data;
}

export async function loadEventIntakeDashboard():
  Promise<AdminGetEventIntakeDashboardResponse> {
  if (dataMode() === "sample") {
    await new Promise((resolve) => window.setTimeout(resolve, 180));
    return {bridge: sampleEventIntakeBridgeState};
  }

  const callable = httpsCallable<unknown, AdminGetEventIntakeDashboardResponse>(
    functions,
    "adminGetEventIntakeDashboard"
  );
  const result = await callable({});
  return result.data;
}

export async function listIntakeOperations(
  payload: AdminListIntakeOperationsPayload = {}
): Promise<AdminListIntakeOperationsResponse> {
  if (dataMode() === "sample") {
    await new Promise((resolve) => window.setTimeout(resolve, 180));
    return sampleIntakeOperations(payload);
  }

  const callable = httpsCallable<
    AdminListIntakeOperationsPayload,
    AdminListIntakeOperationsResponse
  >(functions, "adminListIntakeOperations");
  const result = await callable(payload);
  return result.data;
}

export async function createMarketingContentDraft(
  payload: AdminCreateMarketingContentDraftPayload
): Promise<AdminCreateMarketingContentDraftResponse> {
  if (dataMode() === "sample") {
    await new Promise((resolve) => window.setTimeout(resolve, 240));
    const draft = buildSampleMarketingDraft(
      payload,
      sampleMarketingOpsBridgeState
    );
    const bridge = appendSampleMarketingDraft(
      sampleMarketingOpsBridgeState,
      draft
    );
    sampleMarketingOpsBridgeState = bridge;
    return {
      draft,
      bridge,
      dashboardPath: "local-preview/marketingOpsDashboards/current",
    };
  }

  const callable = httpsCallable<
    AdminCreateMarketingContentDraftPayload,
    AdminCreateMarketingContentDraftResponse
  >(functions, "adminCreateMarketingContentDraft");
  const result = await callable(payload);
  return result.data;
}

function buildSampleMarketingDraft(
  payload: AdminCreateMarketingContentDraftPayload,
  bridge: MarketingOpsBridge
): MarketingContentDraft {
  const createdAt = new Date().toISOString();
  const cityId = payload.cityId ?? bridge.city.id;
  const weekStart = payload.weekStart ?? bridge.weekStart;
  const draftId = [
    cityId,
    weekStart,
    payload.draftType.replace("_", "-"),
    String(Date.now()).slice(-6),
  ].join("-");
  const base: Omit<
    MarketingContentDraft,
    "recommendationSetId" | "caption" | "slides"
  > = {
    id: draftId,
    cityId,
    weekStart,
    format: "instagram_carousel",
    tone: payload.draftType,
    status: "draft",
    reviewState: "new",
    aspectRatio: "4:5",
    delivery: {
      posting: "manual_instagram_upload",
      currentExport: "copy_and_png",
      finalImageExport: "1080x1350_png",
      autoPosting: false,
    },
    brandContract: {
      logo: "Catch _",
      headlineFont: "Archivo",
      labelFont: "IBM Plex Mono",
      bodyFont: "SF Pro Text",
      primitives: ["wordmark", "activity-accent", "source-footnote"],
      rendererStatus: "admin_draft",
    },
    ctas: [
      {
        id: "join-waitlist",
        label: "Join waitlist",
        destination: "catch_waitlist",
        purpose: "member_acquisition",
      },
      {
        id: "submit-event",
        label: "Submit an event",
        destination: "organizer_intake",
        purpose: "organizer_acquisition",
      },
    ],
    latestDecision: {
      decision: "new",
      note: `Draft created in local preview at ${createdAt}.`,
      reviewer: "local-preview-admin",
      reviewedAt: createdAt,
    },
  };
  if (payload.draftType === "feature_explainer") {
    const captures = (bridge.appFeatureMedia?.captures ?? [])
      .filter((capture) => capture.status !== "paused")
      .slice(0, 4);
    return {
      ...base,
      recommendationSetId: "app-feature-media",
      caption: [
        "A quick product tour from approved Catch screenshots.",
        "Review copy and screenshot rights before marking export ready.",
      ].join("\n"),
      slides: [
        {
          id: "cover",
          role: "cover",
          headline: payload.title || "Four things you won't find in a swipe app.",
          body: "A short tour of what makes Catch different.",
          image: null,
        },
        ...captures.map((capture, index) => ({
          id: `feature-${index + 1}`,
          role: "feature",
          headline: capture.walkthroughStep || capture.surface,
          body: capture.caption,
          image: {
            sourceType: "app_capture" as const,
            url: capture.webPath ?? "",
            captureId: capture.id,
            sourcePath: capture.sourcePath,
            websitePath: capture.websitePath,
            webPath: capture.webPath,
            fileName: `${capture.id}.png`,
            altText: capture.alt,
            credit: "Catch deterministic app screenshot pipeline",
            fit: "contain" as const,
          },
        })),
        {
          id: "cta",
          role: "cta",
          headline: "Update Catch to try it.",
          body: "Feature explainers use approved product screenshots and reviewed copy before export.",
          image: null,
        },
      ],
    };
  }

  const set = bridge.recommendationSets.find((item) =>
    item.id === payload.sourceRecommendationSetId
  ) ?? bridge.recommendationSets.find((item) => item.items.length > 0) ??
    bridge.recommendationSets[0] ??
    null;
  const eventById = new Map(bridge.eventCandidates.map((event) => [
    event.id,
    event,
  ]));
  const picks = (set?.items ?? []).slice(0, 3);
  return {
    ...base,
    recommendationSetId: set?.id ?? "manual",
    caption: [
      `${bridge.city.label} plans this week, checked before public use.`,
      ...picks.map((item, index) => `${index + 1}. ${item.title}`),
      "",
      "Catch is not the host for third-party events unless explicitly stated.",
    ].join("\n"),
    slides: [
      {
        id: "cover",
        role: "cover",
        headline: payload.title || set?.title || "Plans worth leaving the app for.",
        body: "Source-backed events for the week, checked for public use before export.",
        image: null,
      },
      ...picks.map((item, index) => {
        const event = eventById.get(item.eventCandidateId);
        const details = [
          event?.venue,
          event?.neighborhood,
          event?.startDate,
          event?.time,
          event?.price,
        ].filter(Boolean).join(" / ");
        return {
          id: `event-${index + 1}`,
          role: "event",
          eventCandidateId: item.eventCandidateId,
          headline: item.title,
          body: details ?
            `${details}\n${item.inclusionReason}` :
            item.inclusionReason,
          image: null,
        };
      }),
      {
        id: "cta",
        role: "cta",
        headline: "Know a plan we should review?",
        body: "Send it through organizer intake. Catch only promotes sourced events after human review.",
        image: null,
      },
    ],
  };
}

function appendSampleMarketingDraft(
  bridge: MarketingOpsBridge,
  draft: MarketingContentDraft
): MarketingOpsBridge {
  const contentDrafts = [...bridge.contentDrafts, draft];
  return {
    ...bridge,
    summary: {
      ...bridge.summary,
      contentDrafts: contentDrafts.length,
      exportReadyDrafts: contentDrafts.filter((item) =>
        item.latestDecision?.decision === "export_ready" ||
        item.status === "export_ready"
      ).length,
    },
    contentDrafts,
    auditTrail: [
      ...bridge.auditTrail,
      {
        targetType: "content_draft",
        targetId: draft.id,
        decision: "new",
        note: `Created ${draft.tone.replace("_", " ")} draft.`,
        reviewer: "local-preview-admin",
        reviewedAt: draft.latestDecision?.reviewedAt ?? null,
        edits: {draftType: draft.tone},
      },
    ],
  };
}

export async function decideAccessApplication(
  payload: AdminDecideAccessApplicationPayload
): Promise<AdminDecideAccessApplicationResponse> {
  if (dataMode() === "sample") {
    await new Promise((resolve) => window.setTimeout(resolve, 240));
    return {
      applicationUid: payload.applicationUid,
      decision: payload.decision,
      status: payload.decision === "approve" ?
        "approvedForProfile" :
        "notSelectedYet",
    };
  }

  const callable = httpsCallable<
    AdminDecideAccessApplicationPayload,
    AdminDecideAccessApplicationResponse
  >(functions, "adminDecideAccessApplication");
  const result = await callable(payload);
  return result.data;
}

export async function getAccessApplicationDetails(
  payload: AdminGetAccessApplicationDetailsPayload
): Promise<AdminGetAccessApplicationDetailsResponse> {
  if (dataMode() === "sample") {
    await new Promise((resolve) => window.setTimeout(resolve, 160));
    return {
      application: sampleAccessApplicationDetails(payload.applicationUid),
    };
  }

  const callable = httpsCallable<
    AdminGetAccessApplicationDetailsPayload,
    AdminGetAccessApplicationDetailsResponse
  >(functions, "adminGetAccessApplicationDetails");
  const result = await callable(payload);
  return result.data;
}

export async function decideClubClaim(
  payload: AdminDecideClubClaimPayload
): Promise<AdminDecideClubClaimResponse> {
  if (dataMode() === "sample") {
    await new Promise((resolve) => window.setTimeout(resolve, 240));
    return {
      requestId: payload.requestId,
      clubId: "local-preview-club",
      decision: payload.decision,
      status: payload.decision === "approve" ? "approved" : "rejected",
    };
  }

  const callable = httpsCallable<
    AdminDecideClubClaimPayload,
    AdminDecideClubClaimResponse
  >(functions, "adminDecideClubClaim");
  const result = await callable(payload);
  return result.data;
}

export async function listClubClaimRequests():
Promise<AdminListClubClaimRequestsResponse> {
  if (dataMode() === "sample") {
    await new Promise((resolve) => window.setTimeout(resolve, 180));
    return {
      generatedAt: sampleOverview.generatedAt,
      rows: sampleOverview.queues.clubClaimRequests.map((row, index) => ({
        requestId: row.targetPath.split("/").at(-1) ?? row.id,
        targetPath: row.targetPath,
        clubId: index === 0 ? "afterfly" : "bhag",
        requesterUid: index === 0 ? "local-preview-afterfly-owner" : "local-preview-bhag-manager",
        requesterName: row.title,
        requesterRole: index === 0 ? "founder" : "manager",
        contact: index === 0 ? "hello@afterfly.in" : null,
        proofCount: index === 0 ? 2 : 1,
        status: row.status,
        createdAt: row.createdAt,
      })),
    };
  }

  const callable = httpsCallable<unknown, AdminListClubClaimRequestsResponse>(
    functions,
    "adminListClubClaimRequests"
  );
  const result = await callable({});
  return result.data;
}

export async function getClubClaimRequestDetails(
  payload: AdminGetClubClaimRequestDetailsPayload
): Promise<AdminGetClubClaimRequestDetailsResponse> {
  if (dataMode() === "sample") {
    await new Promise((resolve) => window.setTimeout(resolve, 140));
    const list = await listClubClaimRequests();
    const row = list.rows.find((item) => item.requestId === payload.requestId);
    if (!row) throw new Error("Organizer claim request not found.");
    return {
      request: {
        ...row,
        businessEmail: row.contact?.includes("@") ? row.contact : null,
        businessPhone: row.contact && !row.contact.includes("@") ? row.contact : null,
        proofUrls: row.clubId === "afterfly" ? [
          "https://www.instagram.com/afterfly.in/",
          "https://luma.com/pxgmph3b",
        ] : ["https://thebhag.in/"],
        message: "Please verify this claim against the listed public sources.",
        updatedAt: row.createdAt,
        requesterProfile: {exists: true, profileComplete: row.clubId === "afterfly"},
        club: {
          exists: true,
          name: row.clubId === "afterfly" ? "AFTER FLY" : "Bhag Club",
          claimState: "claimPending",
          ownershipState: "programmatic",
          ownerUserId: null,
          canonicalPath: `/organizers/${row.clubId}/`,
        },
      },
    };
  }

  const callable = httpsCallable<
    AdminGetClubClaimRequestDetailsPayload,
    AdminGetClubClaimRequestDetailsResponse
  >(functions, "adminGetClubClaimRequestDetails");
  const result = await callable(payload);
  return result.data;
}

export async function setClubIndexStatus(
  payload: AdminSetClubIndexStatusPayload
): Promise<AdminSetClubIndexStatusResponse> {
  if (dataMode() === "sample") {
    await new Promise((resolve) => window.setTimeout(resolve, 240));
    const club = sampleClubDetails[payload.clubId];
    if (club) {
      club.publicPage.indexStatus = payload.indexStatus;
      club.publicPage.publishStatus =
        payload.indexStatus === "noindex" ? "qa" : "published";
      club.publicPage.robots = payload.indexStatus === "noindex" ?
        "noindex, follow" :
        "index, follow";
    }
    return {
      clubId: payload.clubId,
      indexStatus: payload.indexStatus,
      publishStatus: payload.indexStatus === "noindex" ? "qa" : "published",
      robots: payload.indexStatus === "noindex" ?
        "noindex, follow" :
        "index, follow",
    };
  }

  const callable = httpsCallable<
    AdminSetClubIndexStatusPayload,
    AdminSetClubIndexStatusResponse
  >(functions, "adminSetClubIndexStatus");
  const result = await callable(payload);
  return result.data;
}

export async function decideOrganizerIntake(
  payload: AdminDecideOrganizerIntakePayload
): Promise<AdminDecideOrganizerIntakeResponse> {
  if (dataMode() === "sample") {
    await new Promise((resolve) => window.setTimeout(resolve, 240));
    return {
      entityId: payload.entityId,
      decision: payload.decision,
      decisionStatus: payload.decision === "approve_public" ?
        "approved_public" :
        payload.decision === "hold" ? "held" : "suppressed",
      appVisibility: payload.appVisibility,
      decisionPath: `organizerIntakeReviewDecisions/${payload.entityId}`,
      projectionState: payload.decision === "approve_public" ?
        "pending_static_generation" :
        "not_projectable",
    };
  }

  const callable = httpsCallable<
    AdminDecideOrganizerIntakePayload,
    AdminDecideOrganizerIntakeResponse
  >(functions, "adminDecideOrganizerIntake");
  const result = await callable(payload);
  return result.data;
}

export async function decideOrganizerEventCandidate(
  payload: AdminDecideOrganizerEventCandidatePayload
): Promise<AdminDecideOrganizerEventCandidateResponse> {
  if (dataMode() === "sample") {
    await new Promise((resolve) => window.setTimeout(resolve, 240));
    const decisionId = `event-${payload.candidateId
      .toLowerCase()
      .replace(/[^a-z0-9]+/g, "-")
      .replace(/^-+|-+$/g, "")}`;
    return {
      candidateId: payload.candidateId,
      decisionId,
      decision: payload.decision,
      decisionStatus: payload.decision === "approve_for_import" ?
        "approved_for_import" :
        payload.decision === "hold" ? "held" : "rejected",
      decisionPath: `organizerEventCandidateReviewDecisions/${decisionId}`,
      importState: payload.decision === "approve_for_import" ?
        "blocked_by_policy" :
        "not_importable",
    };
  }

  const callable = httpsCallable<
    AdminDecideOrganizerEventCandidatePayload,
    AdminDecideOrganizerEventCandidateResponse
  >(functions, "adminDecideOrganizerEventCandidate");
  const result = await callable(payload);
  return result.data;
}

export async function decideOrganizerPolicyGap(
  payload: AdminDecideOrganizerPolicyGapPayload
): Promise<AdminDecideOrganizerPolicyGapResponse> {
  if (dataMode() === "sample") {
    await new Promise((resolve) => window.setTimeout(resolve, 240));
    const decisionId = `policy-${payload.gapId
      .toLowerCase()
      .replace(/[^a-z0-9]+/g, "-")
      .replace(/^-+|-+$/g, "")}`;
    return {
      gapId: payload.gapId,
      decisionId,
      decision: payload.decision,
      decisionStatus: payload.decision === "accept" ?
        "accepted" :
        payload.decision === "hold" ? "held" : "rejected",
      decisionPath: `organizerPolicyGapReviewDecisions/${decisionId}`,
      operationalState: payload.decision === "reject" ?
        "not_approved" :
        "blocked_until_policy_encoded",
    };
  }

  const callable = httpsCallable<
    AdminDecideOrganizerPolicyGapPayload,
    AdminDecideOrganizerPolicyGapResponse
  >(functions, "adminDecideOrganizerPolicyGap");
  const result = await callable(payload);
  return result.data;
}

export async function resolveOrganizerEventLocation(
  payload: AdminResolveOrganizerEventLocationPayload
): Promise<AdminResolveOrganizerEventLocationResponse> {
  if (dataMode() === "sample") {
    await new Promise((resolve) => window.setTimeout(resolve, 240));
    const resolutionId = `loc-${payload.candidateId
      .toLowerCase()
      .replace(/[^a-z0-9]+/g, "-")
      .replace(/^-+|-+$/g, "")}`;
    return {
      candidateId: payload.candidateId,
      resolutionId,
      resolutionStatus: "resolved",
      decisionPath:
        `organizerEventLocationResolutionDecisions/${resolutionId}`,
      location: payload.location,
    };
  }

  const callable = httpsCallable<
    AdminResolveOrganizerEventLocationPayload,
    AdminResolveOrganizerEventLocationResponse
  >(functions, "adminResolveOrganizerEventLocation");
  const result = await callable(payload);
  return result.data;
}

export async function recordOrganizerCuration(
  payload: AdminRecordOrganizerCurationPayload
): Promise<AdminRecordOrganizerCurationResponse> {
  if (dataMode() === "sample") {
    await new Promise((resolve) => window.setTimeout(resolve, 240));
    return {
      operationId: payload.operationId ??
        `${payload.operationType}-${payload.entityId ?? payload.sourceEntityId ?? "operation"}`,
      operationType: payload.operationType,
      operationStatus: "active",
      decisionPath: "organizerIntakeCurationDecisions/sample-operation",
    };
  }

  const callable = httpsCallable<
    AdminRecordOrganizerCurationPayload,
    AdminRecordOrganizerCurationResponse
  >(functions, "adminRecordOrganizerCuration");
  const result = await callable(payload);
  return result.data;
}

export async function recordMarketingReviewDecision(
  payload: AdminRecordMarketingReviewDecisionPayload
): Promise<AdminRecordMarketingReviewDecisionResponse> {
  if (dataMode() === "sample") {
    await new Promise((resolve) => window.setTimeout(resolve, 240));
    const decisionId = `marketing-${payload.targetType}-${payload.targetId}`
      .toLowerCase()
      .replace(/[^a-z0-9]+/g, "-")
      .replace(/^-+|-+$/g, "");
    return {
      decisionId,
      targetType: payload.targetType,
      targetId: payload.targetId,
      decision: payload.decision,
      decisionStatus: marketingDecisionStatus(payload.decision),
      decisionPath: `marketingReviewDecisions/${decisionId}`,
    };
  }

  const callable = httpsCallable<
    AdminRecordMarketingReviewDecisionPayload,
    AdminRecordMarketingReviewDecisionResponse
  >(functions, "adminRecordMarketingReviewDecision");
  const result = await callable(payload);
  return result.data;
}

export async function recordEventIntakeReviewDecision(
  payload: AdminRecordEventIntakeReviewDecisionPayload
): Promise<AdminRecordEventIntakeReviewDecisionResponse> {
  if (dataMode() === "sample") {
    await new Promise((resolve) => window.setTimeout(resolve, 240));
    const decisionId = `event-intake-${payload.targetType}-${payload.targetId}`
      .toLowerCase()
      .replace(/[^a-z0-9]+/g, "-")
      .replace(/^-+|-+$/g, "");
    return {
      decisionId,
      targetType: payload.targetType,
      targetId: payload.targetId,
      decision: payload.decision,
      decisionStatus: eventIntakeDecisionStatus(payload.decision),
      decisionPath: `eventIntakeReviewDecisions/${decisionId}`,
    };
  }

  const callable = httpsCallable<
    AdminRecordEventIntakeReviewDecisionPayload,
    AdminRecordEventIntakeReviewDecisionResponse
  >(functions, "adminRecordEventIntakeReviewDecision");
  const result = await callable(payload);
  return result.data;
}

function marketingDecisionStatus(
  decision: AdminRecordMarketingReviewDecisionPayload["decision"]
): AdminRecordMarketingReviewDecisionResponse["decisionStatus"] {
  if (decision === "approve") return "approved";
  if (decision === "hold") return "held";
  if (decision === "reject") return "rejected";
  if (decision === "export_ready") return "export_ready";
  return "needs_changes";
}

function eventIntakeDecisionStatus(
  decision: AdminRecordEventIntakeReviewDecisionPayload["decision"]
): AdminRecordEventIntakeReviewDecisionResponse["decisionStatus"] {
  if (decision === "approve") return "approved";
  if (decision === "hold") return "held";
  if (decision === "reject") return "rejected";
  return "needs_changes";
}

export async function loadClubDetails(
  payload: AdminGetClubDetailsPayload
): Promise<AdminGetClubDetailsResponse> {
  if (dataMode() === "sample") {
    await new Promise((resolve) => window.setTimeout(resolve, 180));
    const club = sampleClubDetails[payload.clubId];
    if (!club) {
      throw new Error(
        `Organizer ${payload.clubId} was not found in local preview data.`
      );
    }
    return {club};
  }

  const callable = httpsCallable<
    AdminGetClubDetailsPayload,
    AdminGetClubDetailsResponse
  >(functions, "adminGetClubDetails");
  const result = await callable(payload);
  return result.data;
}

export async function listClubDetails(
  payload: AdminListClubDetailsPayload = {}
): Promise<AdminListClubDetailsResponse> {
  if (dataMode() === "sample") {
    await new Promise((resolve) => window.setTimeout(resolve, 180));
    const rows = Object.values(sampleClubDetails)
      .map(sampleClubListRow)
      .filter((row) => sampleClubListRowMatches(row, payload))
      .sort((a, b) => a.name.localeCompare(b.name))
      .slice(0, payload.limit ?? 50);
    return {
      generatedAt: sampleGeneratedAt,
      rows,
    };
  }

  const callable = httpsCallable<
    AdminListClubDetailsPayload,
    AdminListClubDetailsResponse
  >(functions, "adminListClubDetails");
  const result = await callable(payload);
  return result.data;
}

export async function saveClubDetails(
  payload: AdminUpdateClubDetailsPayload
): Promise<AdminUpdateClubDetailsResponse> {
  if (dataMode() === "sample") {
    await new Promise((resolve) => window.setTimeout(resolve, 280));
    const club = sampleClubDetails[payload.clubId];
    if (club) applySampleClubDetailsPatch(club, payload.fields);
    return {
      clubId: payload.clubId,
      updatedFieldCount: Object.keys(payload.fields).length,
    };
  }

  const callable = httpsCallable<
    AdminUpdateClubDetailsPayload,
    AdminUpdateClubDetailsResponse
  >(functions, "adminUpdateClubDetails");
  const result = await callable(payload);
  return result.data;
}

export async function loadEventDetails(
  payload: AdminGetEventDetailsPayload
): Promise<AdminGetEventDetailsResponse> {
  if (dataMode() === "sample") {
    await new Promise((resolve) => window.setTimeout(resolve, 180));
    const event = sampleEventDetails[payload.eventId];
    if (!event) {
      throw new Error(
        `Event ${payload.eventId} was not found in local preview data.`
      );
    }
    return {event};
  }

  const callable = httpsCallable<
    AdminGetEventDetailsPayload,
    AdminGetEventDetailsResponse
  >(functions, "adminGetEventDetails");
  const result = await callable(payload);
  return result.data;
}

export async function listEventDetails(
  payload: AdminListEventDetailsPayload = {}
): Promise<AdminListEventDetailsResponse> {
  if (dataMode() === "sample") {
    await new Promise((resolve) => window.setTimeout(resolve, 180));
    const rows = Object.values(sampleEventDetails)
      .map(sampleEventListRow)
      .filter((row) => sampleEventListRowMatches(row, payload))
      .sort((a, b) =>
        (a.startTime ?? "").localeCompare(b.startTime ?? "") ||
        a.title.localeCompare(b.title)
      )
      .slice(0, payload.limit ?? 50);
    return {
      generatedAt: sampleGeneratedAt,
      rows,
    };
  }

  const callable = httpsCallable<
    AdminListEventDetailsPayload,
    AdminListEventDetailsResponse
  >(functions, "adminListEventDetails");
  const result = await callable(payload);
  return result.data;
}

export async function listExternalEventDetails(
  payload: AdminListExternalEventDetailsPayload = {}
): Promise<AdminListExternalEventDetailsResponse> {
  if (dataMode() === "sample") {
    await new Promise((resolve) => window.setTimeout(resolve, 180));
    const rows = sampleExternalEventRows
      .filter((row) => sampleExternalEventListRowMatches(row, payload))
      .sort((a, b) =>
        (a.startTime ?? "").localeCompare(b.startTime ?? "") ||
        a.title.localeCompare(b.title)
      )
      .slice(0, payload.limit ?? 50);
    return {
      generatedAt: sampleGeneratedAt,
      rows,
    };
  }

  const callable = httpsCallable<
    AdminListExternalEventDetailsPayload,
    AdminListExternalEventDetailsResponse
  >(functions, "adminListExternalEventDetails");
  const result = await callable(payload);
  return result.data;
}

export async function loadEventSupplyReadiness():
  Promise<AdminGetEventSupplyReadinessResponse> {
  if (dataMode() === "sample") {
    await new Promise((resolve) => window.setTimeout(resolve, 120));
    return {
      generatedAt: sampleGeneratedAt,
      source: "sample",
      importPlan:
        externalEventImportPlanJson as
          AdminGetEventSupplyReadinessResponse["importPlan"],
      executionPlan:
        externalEventImportExecutionPlanJson as
          AdminGetEventSupplyReadinessResponse["executionPlan"],
    };
  }

  const callable = httpsCallable<
    unknown,
    AdminGetEventSupplyReadinessResponse
  >(functions, "adminGetEventSupplyReadiness");
  const result = await callable({});
  return result.data;
}

export async function publishExternalEvent(
  payload: AdminPublishExternalEventPayload
): Promise<AdminPublishExternalEventResponse> {
  if (dataMode() === "sample") {
    await new Promise((resolve) => window.setTimeout(resolve, 220));
    if (!payload.reviewNote.trim()) {
      throw new Error("A review note is required to publish external supply.");
    }
    const eventId = payload.targetPath.split("/")[1] ?? payload.sourceActionId;
    return {
      eventId,
      targetPath: payload.targetPath,
      sourceActionId: payload.sourceActionId,
      publicationStatus: "public",
      externalLinkCount: 1,
      publishedAt: sampleGeneratedAt,
    };
  }

  const callable = httpsCallable<
    AdminPublishExternalEventPayload,
    AdminPublishExternalEventResponse
  >(functions, "adminPublishExternalEvent");
  const result = await callable(payload);
  return result.data;
}

export async function saveEventDetails(
  payload: AdminUpdateEventDetailsPayload
): Promise<AdminUpdateEventDetailsResponse> {
  if (dataMode() === "sample") {
    await new Promise((resolve) => window.setTimeout(resolve, 280));
    const event = sampleEventDetails[payload.eventId];
    if (!event) {
      throw new Error(
        `Event ${payload.eventId} was not found in local preview data.`
      );
    }
    if (event.status === "cancelled") {
      throw new Error("Cancelled events cannot be updated from Events.");
    }
    applySampleEventDetailsPatch(event, payload.fields);
    return {
      eventId: payload.eventId,
      updatedFieldCount: Object.keys(payload.fields).length,
    };
  }

  const callable = httpsCallable<
    AdminUpdateEventDetailsPayload,
    AdminUpdateEventDetailsResponse
  >(functions, "adminUpdateEventDetails");
  const result = await callable(payload);
  return result.data;
}

function sampleClubListRow(club: AdminGetClubDetailsResponse["club"]):
  AdminClubListRow {
  return {
    clubId: club.clubId,
    name: club.name,
    organizerType: club.organizerType,
    publicCategoryLabel: club.publicCategoryLabel,
    displayCategory: club.displayCategory,
    cityName: club.cityName ?? club.area,
    citySlug: club.location ?? club.publicPage.citySlug,
    regionName: club.regionName,
    countryCode: club.countryCode,
    appVisibility: club.appVisibility,
    claimState: club.claimState,
    ownershipState: club.ownershipState,
    canonicalPath: club.publicPage.canonicalPath,
    publishStatus: club.publicPage.publishStatus,
    indexStatus: club.publicPage.indexStatus,
    robots: club.publicPage.robots,
    sourceConfidence: club.provenance.sourceConfidence,
    verificationStatus: club.provenance.verificationStatus,
    routeStatus: club.publicPage.canonicalPath ? "valid" : "missing",
    routeReservationStatus:
      club.publicPage.canonicalPath ? "reserved" : "missing",
    searchIndexStatus: "indexed",
  };
}

function sampleEventListRow(event: AdminGetEventDetailsResponse["event"]):
  AdminEventListRow {
  return {
    eventId: event.eventId,
    clubId: event.clubId,
    organizerName: event.organizerName,
    title: event.title,
    activityKind: event.eventFormat.activityKind,
    activityLabel: event.eventFormat.label,
    startTime: event.startTime,
    citySlug: event.discovery.citySlug,
    meetingPoint: event.meetingPoint,
    status: event.status,
    availability: event.discovery.availability,
    bookedCount: event.bookedCount,
    capacityLimit: event.capacityLimit,
    priceInPaise: event.priceInPaise,
    currency: event.currency,
    searchIndexStatus: event.searchIndexStatus,
  };
}

function sampleClubListRowMatches(
  row: AdminClubListRow,
  payload: AdminListClubDetailsPayload
): boolean {
  if (payload.citySlug && row.citySlug !== payload.citySlug) return false;
  if (
    payload.citySlugs &&
    payload.citySlugs.length > 0 &&
    !payload.citySlugs.includes(row.citySlug ?? "")
  ) {
    return false;
  }
  if (payload.publishStatus && row.publishStatus !== payload.publishStatus) {
    return false;
  }
  if (payload.appVisibility && row.appVisibility !== payload.appVisibility) {
    return false;
  }
  const query = (payload.query ?? "").trim().toLowerCase();
  if (!query) return true;
  const haystack = [
    row.clubId,
    row.name,
    row.displayCategory,
    row.cityName,
    row.citySlug,
    row.regionName,
    row.countryCode,
    row.canonicalPath,
    row.publishStatus,
    row.indexStatus,
    row.appVisibility,
    row.claimState,
    row.ownershipState,
    row.sourceConfidence,
    row.verificationStatus,
  ]
    .filter((item): item is string => typeof item === "string")
    .join(" ")
    .toLowerCase();
  return query
    .split(/\s+/u)
    .filter(Boolean)
    .every((token) => haystack.includes(token));
}

function sampleEventListRowMatches(
  row: AdminEventListRow,
  payload: AdminListEventDetailsPayload
): boolean {
  if (payload.clubId && row.clubId !== payload.clubId) return false;
  if (payload.citySlug && row.citySlug !== payload.citySlug) return false;
  if (
    payload.citySlugs &&
    payload.citySlugs.length > 0 &&
    !payload.citySlugs.includes(row.citySlug ?? "")
  ) {
    return false;
  }
  if (payload.activityKind && row.activityKind !== payload.activityKind) {
    return false;
  }
  if (payload.status && row.status !== payload.status) return false;
  if (!sampleEventMatchesTimeWindow(row, payload.timeWindow)) return false;
  const query = (payload.query ?? "").trim().toLowerCase();
  if (!query) return true;
  const haystack = [
    row.eventId,
    row.clubId,
    row.organizerName,
    row.title,
    row.activityKind,
    row.activityLabel,
    row.citySlug,
    row.meetingPoint,
    row.status,
    row.availability,
  ]
    .filter((item): item is string => typeof item === "string")
    .join(" ")
    .toLowerCase();
  return query
    .split(/\s+/u)
    .filter(Boolean)
    .every((token) => haystack.includes(token));
}

function sampleExternalEventListRowMatches(
  row: AdminListExternalEventDetailsResponse["rows"][number],
  payload: AdminListExternalEventDetailsPayload
): boolean {
  if (payload.citySlug && row.citySlug !== payload.citySlug) return false;
  if (
    payload.citySlugs &&
    payload.citySlugs.length > 0 &&
    !payload.citySlugs.includes(row.citySlug ?? "")
  ) {
    return false;
  }
  if (
    payload.publicationStatus &&
    row.publicationStatus !== payload.publicationStatus
  ) {
    return false;
  }
  if (payload.status && row.status !== payload.status) return false;
  if (!sampleExternalEventMatchesTimeWindow(row, payload.timeWindow)) {
    return false;
  }
  const query = (payload.query ?? "").trim().toLowerCase();
  if (!query) return true;
  const haystack = [
    row.eventId,
    row.targetPath,
    row.canonicalHostId,
    row.compatibilityClubId,
    row.title,
    row.citySlug,
    row.countryCode,
    row.meetingPoint,
    row.activityKind,
    row.interactionModel,
    row.publicationStatus,
    row.status,
    row.platform,
    row.sourceEventKey,
    row.candidateId,
    row.normalizedEventKey,
  ]
    .filter((item): item is string => typeof item === "string")
    .join(" ")
    .toLowerCase();
  return query
    .split(/\s+/u)
    .filter(Boolean)
    .every((token) => haystack.includes(token));
}

function sampleEventMatchesTimeWindow(
  row: AdminEventListRow,
  timeWindow: AdminListEventDetailsPayload["timeWindow"]
): boolean {
  if (!timeWindow || timeWindow === "all") return true;
  if (!row.startTime) return false;
  const startMillis = Date.parse(row.startTime);
  if (!Number.isFinite(startMillis)) return false;
  const now = Date.parse(sampleGeneratedAt);
  return timeWindow === "upcoming" ?
    startMillis >= now :
    startMillis < now;
}

function sampleExternalEventMatchesTimeWindow(
  row: AdminListExternalEventDetailsResponse["rows"][number],
  timeWindow: AdminListExternalEventDetailsPayload["timeWindow"]
): boolean {
  if (!timeWindow || timeWindow === "all") return true;
  if (!row.startTime) return false;
  const startMillis = Date.parse(row.startTime);
  if (!Number.isFinite(startMillis)) return false;
  const now = Date.parse(sampleGeneratedAt);
  return timeWindow === "upcoming" ?
    startMillis >= now :
    startMillis < now;
}

function applySampleClubDetailsPatch(
  club: AdminGetClubDetailsResponse["club"],
  fields: AdminUpdateClubDetailsPayload["fields"]
) {
  Object.assign(club, {
    ...copyDefined(fields, [
      "name",
      "description",
      "location",
      "area",
      "tags",
      "instagramHandle",
      "phoneNumber",
      "email",
      "imageUrl",
      "profileImageUrl",
      "entityKind",
      "entitySubtypes",
      "displayCategory",
      "cityName",
      "regionName",
      "countryCode",
      "countryName",
      "appVisibility",
    ]),
  });
  if (fields.publicPage) {
    Object.assign(club.publicPage, fields.publicPage);
  }
  if (fields.provenance) {
    Object.assign(club.provenance, fields.provenance);
  }
  if (fields.publicProfile) {
    Object.assign(club.publicProfile, fields.publicProfile);
  }
}

function applySampleEventDetailsPatch(
  event: AdminGetEventDetailsResponse["event"],
  fields: AdminUpdateEventDetailsPayload["fields"]
) {
  Object.assign(event, copyDefined(fields, [
    "description",
    "photoUrl",
    "distanceKm",
    "pace",
  ]));
  if (fields.eventFormat) {
    event.eventFormat = {
      ...event.eventFormat,
      ...fields.eventFormat,
      customActivityLabel: fields.eventFormat.customActivityLabel ?? null,
      label: fields.eventFormat.customActivityLabel ??
        titleFromCamel(fields.eventFormat.activityKind),
    };
    event.title = event.eventFormat.label;
    event.discovery.activityKind = event.eventFormat.activityKind;
  }
  event.searchIndexStatus = "indexed";
}

function copyDefined<T extends Record<string, unknown>>(
  source: T,
  keys: Array<keyof T>
): Partial<T> {
  const result: Partial<T> = {};
  for (const key of keys) {
    if (source[key] !== undefined) result[key] = source[key];
  }
  return result;
}

function titleFromCamel(value: string): string {
  return value
    .replace(/([a-z])([A-Z])/g, "$1 $2")
    .replace(/\b\w/g, (character) => character.toUpperCase());
}
