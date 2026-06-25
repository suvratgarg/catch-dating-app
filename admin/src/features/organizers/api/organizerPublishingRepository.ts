import {
  listClubDetails,
  loadClubDetails,
  saveClubDetails,
  setClubIndexStatus,
} from "../../../shared/api/adminApi";
import type {
  AdminGetClubDetailsPayload,
  AdminGetClubDetailsResponse,
  AdminListClubDetailsPayload,
  AdminListClubDetailsResponse,
  AdminSetClubIndexStatusPayload,
  AdminSetClubIndexStatusResponse,
  AdminUpdateClubDetailsPayload,
  AdminUpdateClubDetailsResponse,
} from "../../../shared/types/adminTypes";

export function listOrganizerProfiles(
  payload: AdminListClubDetailsPayload = {}
): Promise<AdminListClubDetailsResponse> {
  return listClubDetails(payload);
}

export function loadOrganizerProfile(
  payload: AdminGetClubDetailsPayload
): Promise<AdminGetClubDetailsResponse> {
  return loadClubDetails(payload);
}

export function saveOrganizerProfile(
  payload: AdminUpdateClubDetailsPayload
): Promise<AdminUpdateClubDetailsResponse> {
  return saveClubDetails(payload);
}

export function publishOrganizerProfile(
  payload: AdminSetClubIndexStatusPayload
): Promise<AdminSetClubIndexStatusResponse> {
  return setClubIndexStatus(payload);
}
