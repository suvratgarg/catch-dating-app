import {
  listExternalEventDetails,
  listEventDetails,
  loadEventSupplyReadiness as loadAdminEventSupplyReadiness,
  loadEventDetails,
  publishExternalEvent,
  saveEventDetails,
} from "../../../shared/api/adminApi";
import type {
  AdminGetEventSupplyReadinessResponse,
  AdminGetEventDetailsPayload,
  AdminGetEventDetailsResponse,
  AdminListExternalEventDetailsPayload,
  AdminListExternalEventDetailsResponse,
  AdminListEventDetailsPayload,
  AdminListEventDetailsResponse,
  AdminPublishExternalEventPayload,
  AdminPublishExternalEventResponse,
  AdminUpdateEventDetailsPayload,
  AdminUpdateEventDetailsResponse,
} from "../../../shared/types/adminTypes";

export type EventSupplyReadiness = AdminGetEventSupplyReadinessResponse;

export function listEventProfiles(
  payload: AdminListEventDetailsPayload = {}
): Promise<AdminListEventDetailsResponse> {
  return listEventDetails(payload);
}

export function listExternalEventProfiles(
  payload: AdminListExternalEventDetailsPayload = {}
): Promise<AdminListExternalEventDetailsResponse> {
  return listExternalEventDetails(payload);
}

export function loadEventProfile(
  payload: AdminGetEventDetailsPayload
): Promise<AdminGetEventDetailsResponse> {
  return loadEventDetails(payload);
}

export function saveEventProfile(
  payload: AdminUpdateEventDetailsPayload
): Promise<AdminUpdateEventDetailsResponse> {
  return saveEventDetails(payload);
}

export async function loadEventSupplyReadiness():
  Promise<EventSupplyReadiness> {
  return loadAdminEventSupplyReadiness();
}

export function publishExternalEventProfile(
  payload: AdminPublishExternalEventPayload
): Promise<AdminPublishExternalEventResponse> {
  return publishExternalEvent(payload);
}
