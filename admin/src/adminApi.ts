import {httpsCallable} from "firebase/functions";
import {functions} from "./firebase";
import {sampleClubDetails, sampleOverview} from "./sampleData";
import {
  AdminDecideAccessApplicationPayload,
  AdminDecideAccessApplicationResponse,
  AdminDecideClubClaimPayload,
  AdminDecideClubClaimResponse,
  AdminGetClubDetailsPayload,
  AdminGetClubDetailsResponse,
  AdminOverviewResponse,
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
