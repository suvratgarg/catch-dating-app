import {
  decideOrganizerClaim as decideOrganizerClaimRequest,
  getOrganizerClaimRequestDetails as getOrganizerClaimRequest,
  listOrganizerClaimRequests as listOrganizerClaimRequestRows,
  listClubDetails,
  loadClubDetails,
  saveClubDetails,
  setOrganizerIndexStatus as setOrganizerIndexStatusRequest,
} from "../../../shared/api/adminApi";
import type {
  AdminDecideClubClaimPayload,
  AdminDecideClubClaimResponse,
  AdminGetClubClaimRequestDetailsPayload,
  AdminGetClubClaimRequestDetailsResponse,
  AdminGetClubDetailsPayload,
  AdminGetClubDetailsResponse,
  AdminListClubDetailsPayload,
  AdminListClubDetailsResponse,
  AdminSetClubIndexStatusPayload,
  AdminSetClubIndexStatusResponse,
  AdminUpdateClubDetailsPayload,
  AdminUpdateClubDetailsResponse,
} from "../../../shared/types/adminTypes";

export function listOrganizerClaimRequests() {
  return listOrganizerClaimRequestRows();
}

export function loadOrganizerClaimRequest(
  payload: AdminGetClubClaimRequestDetailsPayload
): Promise<AdminGetClubClaimRequestDetailsResponse> {
  return getOrganizerClaimRequest(payload);
}

export function decideOrganizerClaim(
  payload: AdminDecideClubClaimPayload
): Promise<AdminDecideClubClaimResponse> {
  return decideOrganizerClaimRequest(payload);
}

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
  return setOrganizerIndexStatusRequest(payload);
}
