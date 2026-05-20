import {ClubDoc} from "./firestore";

export type ClubHostRole = "owner" | "host";

export interface ClubHostProfile {
  uid: string;
  displayName: string;
  avatarUrl: string | null;
  role: ClubHostRole;
}

type MultiHostClubFields = ClubDoc & {
  ownerUserId?: string | null;
  hostUserIds?: string[];
  hostProfiles?: ClubHostProfile[];
};

/**
 * Returns the canonical club owner id, falling back to legacy hostUserId.
 * @param {ClubDoc} club Club document.
 * @return {string} Owner user id.
 */
export function clubOwnerUserId(club: ClubDoc): string {
  const multiHostClub = club as MultiHostClubFields;
  return multiHostClub.ownerUserId ?? club.hostUserId;
}

/**
 * Returns every user id with host privileges for this club.
 * @param {ClubDoc} club Club document.
 * @return {string[]} Owner and co-host ids.
 */
export function clubHostUserIds(club: ClubDoc): string[] {
  const multiHostClub = club as MultiHostClubFields;
  return uniqueStrings([
    club.hostUserId,
    multiHostClub.ownerUserId ?? null,
    ...(multiHostClub.hostUserIds ?? []),
    ...(multiHostClub.hostProfiles ?? []).map((host) => host.uid),
  ]);
}

/**
 * Checks whether a user has host privileges for a club.
 * @param {ClubDoc} club Club document.
 * @param {string} uid User id to check.
 * @return {boolean} True when the user is owner or co-host.
 */
export function isClubHost(club: ClubDoc, uid: string): boolean {
  return clubHostUserIds(club).includes(uid);
}

/**
 * Checks whether a user is the canonical club owner.
 * @param {ClubDoc} club Club document.
 * @param {string} uid User id to check.
 * @return {boolean} True when the user owns the club.
 */
export function isClubOwner(club: ClubDoc, uid: string): boolean {
  return clubOwnerUserId(club) === uid;
}

/**
 * Returns public host profiles, falling back to the legacy single-host shape.
 * @param {ClubDoc} club Club document.
 * @return {ClubHostProfile[]} Public owner and co-host projections.
 */
export function clubHostProfiles(club: ClubDoc): ClubHostProfile[] {
  const multiHostClub = club as MultiHostClubFields;
  if (multiHostClub.hostProfiles?.length) {
    return multiHostClub.hostProfiles;
  }
  return [{
    uid: club.hostUserId,
    displayName: club.hostName,
    avatarUrl: club.hostAvatarUrl ?? null,
    role: "owner",
  }];
}

/**
 * Removes empty and duplicate string values while preserving first-seen order.
 * @param {Array<string | null | undefined>} values Candidate values.
 * @return {string[]} Unique non-empty values.
 */
function uniqueStrings(values: Array<string | null | undefined>): string[] {
  return [...new Set(values.filter((value): value is string =>
    typeof value === "string" && value.length > 0
  ))];
}
