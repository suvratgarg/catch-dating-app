import {HttpsError} from "firebase-functions/v2/https";
import type {ProgramHouseholdDocument} from
  "../shared/generated/firestoreAdminTypes";

export interface HouseholdMembershipChange {
  guestId: string;
  previousHouseholdId: string | null;
  nextHouseholdId: string | null;
}

export function householdMemberIds(doc: ProgramHouseholdDocument): string[] {
  const ids = doc.memberGuestIds;
  if (!Array.isArray(ids) || ids.length > 50 ||
      ids.some((value) => typeof value !== "string" || !value) ||
      new Set(ids).size !== ids.length) {
    throw new HttpsError("failed-precondition",
      "Household membership needs reconciliation.");
  }
  return ids;
}

/** Apply all moves before checking capacity; never delete contact records. */
export function planHouseholdMembership(
  programId: string,
  organizerId: string,
  households: ReadonlyMap<string, ProgramHouseholdDocument>,
  changes: readonly HouseholdMembershipChange[],
): Map<string, string[]> {
  const members = new Map<string, Set<string>>();
  const group = (id: string) => {
    const household = households.get(id);
    if (!household || household.programId !== programId ||
        household.organizerId !== organizerId) {
      throw new HttpsError("failed-precondition",
        "Household ownership needs reconciliation.");
    }
    const ids = householdMemberIds(household);
    if (!members.has(id)) members.set(id, new Set(ids));
    return members.get(id)!;
  };
  const guests = new Set<string>();
  for (const change of changes) {
    if (guests.has(change.guestId)) {
      throw new HttpsError("invalid-argument",
        "A guest can have only one household assignment.");
    }
    guests.add(change.guestId);
    if (change.previousHouseholdId) {
      group(change.previousHouseholdId).delete(change.guestId);
    }
    if (change.nextHouseholdId) {
      group(change.nextHouseholdId).add(change.guestId);
    }
  }
  const result = new Map<string, string[]>();
  for (const [id, values] of members) {
    if (values.size > 50) {
      throw new HttpsError("failed-precondition",
        "A household cannot contain more than 50 guests.");
    }
    const previous = households.get(id)!.memberGuestIds;
    if (values.size !== previous.length ||
        [...values].some((value) => !previous.includes(value))) {
      result.set(id, [...values].sort());
    }
  }
  return result;
}
