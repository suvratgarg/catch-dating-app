import {OrganizerDocument} from "./generated/firestoreAdminTypes";

export type OrganizerTeamRole = "owner" | "manager";

export interface OrganizerHostProfile {
  uid: string;
  displayName: string;
  avatarUrl: string | null;
  role: "owner" | "host";
}

/** Returns the canonical organizer owner id. */
export function organizerOwnerUserId(
  organizer: OrganizerDocument
): string | null {
  return organizer.ownerUserId ?? organizer.hostUserId ?? null;
}

/** Returns all users with organizer management privileges. */
export function organizerManagerUserIds(
  organizer: OrganizerDocument
): string[] {
  return uniqueStrings([
    organizer.hostUserId,
    organizer.ownerUserId,
    ...organizer.hostUserIds,
    ...organizer.hostProfiles.map((host) => host.uid),
  ]);
}

/** Checks whether a user can manage an organizer. */
export function isOrganizerManager(
  organizer: OrganizerDocument,
  uid: string
): boolean {
  return organizerManagerUserIds(organizer).includes(uid);
}

/** Checks whether a user owns an organizer. */
export function isOrganizerOwner(
  organizer: OrganizerDocument,
  uid: string
): boolean {
  return organizerOwnerUserId(organizer) === uid;
}

/** Returns public owner and manager projections. */
export function organizerHostProfiles(
  organizer: OrganizerDocument
): OrganizerHostProfile[] {
  if (organizer.hostProfiles.length > 0) return organizer.hostProfiles;
  if (!organizer.hostUserId || !organizer.hostName) return [];
  return [{
    uid: organizer.hostUserId,
    displayName: organizer.hostName,
    avatarUrl: organizer.hostAvatarUrl,
    role: "owner",
  }];
}

function uniqueStrings(
  values: Array<string | null | undefined>
): string[] {
  return [...new Set(values.filter((value): value is string =>
    typeof value === "string" && value.length > 0
  ))];
}
