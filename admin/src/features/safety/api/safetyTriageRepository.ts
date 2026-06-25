import {
  assignSafetyTriageItem,
  decideSafetyTriageItem,
  loadOverview,
  loadSafetyTriageDetails,
} from "../../../shared/api/adminApi";
import type {
  AdminAssignSafetyTriageItemPayload,
  AdminAssignSafetyTriageItemResponse,
  AdminDecideSafetyTriageItemPayload,
  AdminDecideSafetyTriageItemResponse,
  AdminGetSafetyTriageDetailsResponse,
  AdminOverviewResponse,
} from "../../../shared/types/adminTypes";

export async function loadSafetyTriageSnapshot():
  Promise<AdminOverviewResponse> {
  return loadOverview();
}

export function loadSafetyTriageItem(
  targetPath: string
): Promise<AdminGetSafetyTriageDetailsResponse> {
  return loadSafetyTriageDetails({targetPath});
}

export function decideSafetyTriageItemStatus(
  payload: AdminDecideSafetyTriageItemPayload
): Promise<AdminDecideSafetyTriageItemResponse> {
  return decideSafetyTriageItem(payload);
}

export function assignSafetyTriageItemOwner(
  payload: AdminAssignSafetyTriageItemPayload
): Promise<AdminAssignSafetyTriageItemResponse> {
  return assignSafetyTriageItem(payload);
}
