import {
  decideAccessApplication,
  getAccessApplicationDetails,
  loadOverview,
} from "../../../shared/api/adminApi";
import type {
  AdminDecideAccessApplicationPayload,
  AdminDecideAccessApplicationResponse,
  AdminGetAccessApplicationDetailsPayload,
  AdminGetAccessApplicationDetailsResponse,
  AdminOverviewResponse,
} from "../../../shared/types/adminTypes";

export async function listAccessApplications(): Promise<
  AdminOverviewResponse["queues"]["accessApplications"]
> {
  const overview = await loadOverview();
  return overview.queues.accessApplications;
}

export function decideAccessReview(
  payload: AdminDecideAccessApplicationPayload
): Promise<AdminDecideAccessApplicationResponse> {
  return decideAccessApplication(payload);
}

export function loadAccessApplicationDetails(
  payload: AdminGetAccessApplicationDetailsPayload
): Promise<AdminGetAccessApplicationDetailsResponse> {
  return getAccessApplicationDetails(payload);
}
