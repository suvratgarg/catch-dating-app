import {httpsCallable} from "firebase/functions";
import {functions} from "./firebase";
import {sampleOverview} from "./sampleData";
import {
  AdminDecideAccessApplicationPayload,
  AdminDecideAccessApplicationResponse,
  AdminOverviewResponse,
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
