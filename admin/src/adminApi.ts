import {httpsCallable} from "firebase/functions";
import {functions} from "./firebase";
import {sampleClubDetails, sampleOverview} from "./sampleData";
import {
  AdminDecideAccessApplicationPayload,
  AdminDecideAccessApplicationResponse,
  AdminDecideClubClaimPayload,
  AdminDecideClubClaimResponse,
  AdminDecideOrganizerEventCandidatePayload,
  AdminDecideOrganizerEventCandidateResponse,
  AdminDecideOrganizerIntakePayload,
  AdminDecideOrganizerIntakeResponse,
  AdminDecideOrganizerPolicyGapPayload,
  AdminDecideOrganizerPolicyGapResponse,
  AdminRecordOrganizerCurationPayload,
  AdminRecordOrganizerCurationResponse,
  AdminGetClubDetailsPayload,
  AdminGetClubDetailsResponse,
  AdminOverviewResponse,
  AdminResolveOrganizerEventLocationPayload,
  AdminResolveOrganizerEventLocationResponse,
  AdminSetClubIndexStatusPayload,
  AdminSetClubIndexStatusResponse,
  AdminUpdateClubDetailsPayload,
  AdminUpdateClubDetailsResponse,
  DataMode,
} from "./types";

export function dataMode(): DataMode {
  return import.meta.env.VITE_ADMIN_DATA_MODE === "live" ? "live" : "sample";
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

export async function decideClubClaim(
  payload: AdminDecideClubClaimPayload
): Promise<AdminDecideClubClaimResponse> {
  if (dataMode() === "sample") {
    await new Promise((resolve) => window.setTimeout(resolve, 240));
    return {
      requestId: payload.requestId,
      clubId: "sample-club",
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

export async function setClubIndexStatus(
  payload: AdminSetClubIndexStatusPayload
): Promise<AdminSetClubIndexStatusResponse> {
  if (dataMode() === "sample") {
    await new Promise((resolve) => window.setTimeout(resolve, 240));
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

export async function loadClubDetails(
  payload: AdminGetClubDetailsPayload
): Promise<AdminGetClubDetailsResponse> {
  if (dataMode() === "sample") {
    await new Promise((resolve) => window.setTimeout(resolve, 180));
    const club = sampleClubDetails[payload.clubId] ??
      sampleClubDetails["afterfly-run-club-indore"];
    return {club};
  }

  const callable = httpsCallable<
    AdminGetClubDetailsPayload,
    AdminGetClubDetailsResponse
  >(functions, "adminGetClubDetails");
  const result = await callable(payload);
  return result.data;
}

export async function saveClubDetails(
  payload: AdminUpdateClubDetailsPayload
): Promise<AdminUpdateClubDetailsResponse> {
  if (dataMode() === "sample") {
    await new Promise((resolve) => window.setTimeout(resolve, 280));
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
