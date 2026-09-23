import {HttpsError} from "firebase-functions/v2/https";
import {isOrganizerManager} from "../shared/organizerHosts";
import {loadProgramBundle} from "../shared/programAuthority";
import type {
  ProgramHotelDocument,
  ProgramPickupPointDocument,
  ProgramStaffGrantDocument,
} from "../shared/generated/firestoreAdminTypes";
import type {GrantProgramStaffCallablePayload} from
  "../shared/generated/grantProgramStaffCallablePayload";

export const maxProgramStaff = 100;
export const maxGrantDurationMillis = 14 * 24 * 60 * 60 * 1000;

export async function requireProgramManager(
  db: FirebaseFirestore.Firestore,
  programId: string,
  actorUid: string,
  transaction?: FirebaseFirestore.Transaction
): Promise<Awaited<ReturnType<typeof loadProgramBundle>>> {
  const bundle = await loadProgramBundle({db, programId, transaction});
  if (!isOrganizerManager(bundle.organizer, actorUid)) {
    throw new HttpsError(
      "permission-denied",
      "Only organizer managers can manage program staff."
    );
  }
  return bundle;
}

/** Referenced stations must exist inside the program. */
export async function validateDutyStations(
  db: FirebaseFirestore.Firestore,
  programId: string,
  duties: GrantProgramStaffCallablePayload["duties"]
): Promise<void> {
  const pickupIds = new Set<string>();
  const hotelIds = new Set<string>();
  for (const assignment of duties) {
    for (const id of assignment.pickupPointIds) pickupIds.add(id);
    for (const id of assignment.hotelIds) hotelIds.add(id);
  }
  const missing: string[] = [];
  for (const id of pickupIds) {
    const snap = await db.collection("programPickupPoints").doc(id).get();
    const point = snap.data() as ProgramPickupPointDocument | undefined;
    if (!point || point.programId !== programId) missing.push(id);
  }
  for (const id of hotelIds) {
    const snap = await db.collection("programHotels").doc(id).get();
    const hotel = snap.data() as ProgramHotelDocument | undefined;
    if (!hotel || hotel.programId !== programId) missing.push(id);
  }
  if (missing.length > 0) {
    throw new HttpsError(
      "invalid-argument",
      `Stations outside this program: ${missing.join(", ")}.`
    );
  }
}

type DutyScope = GrantProgramStaffCallablePayload["duties"][number];

/** Canonicalize exact scope tuples, never their Cartesian product. */
export function dedupeDuties<T extends DutyScope>(duties: T[]): T[] {
  const byScope = new Map<string, T>();
  for (const assignment of duties) {
    if (assignment.duty === "programCoordinator" &&
        (assignment.pickupPointIds.length || assignment.hotelIds.length)) {
      throw new HttpsError("invalid-argument",
        "Program coordinators must have program-wide scope.");
    }
    const normalized = {...assignment,
      pickupPointIds: [...new Set(assignment.pickupPointIds)].sort(),
      hotelIds: [...new Set(assignment.hotelIds)].sort()};
    const key = JSON.stringify([normalized.duty,
      normalized.pickupPointIds, normalized.hotelIds]);
    const existing = byScope.get(key);
    if (existing && "expiresAtMillis" in existing &&
        "expiresAtMillis" in normalized) {
      normalized.expiresAtMillis = Math.max(
        existing.expiresAtMillis as number,
        normalized.expiresAtMillis as number);
    }
    byScope.set(key, normalized);
  }
  if (byScope.size > 8) {
    throw new HttpsError("resource-exhausted",
      "More than eight duty scopes. Ask a manager to review staff access.");
  }
  return [...byScope.values()];
}

export function grantDuties(duties: DutyScope[], expiresAtMillis: number):
  ProgramStaffGrantDocument["duties"] {
  return dedupeDuties(duties).map((assignment) =>
    ({...assignment, expiresAtMillis}));
}

export function unionScope(grant: ProgramStaffGrantDocument,
  field: "pickupPointIds" | "hotelIds"): Set<string> | null {
  const scoped = new Set<string>();
  for (const assignment of grant.duties) {
    if (assignment[field].length === 0) return null;
    for (const id of assignment[field]) scoped.add(id);
  }
  return scoped;
}
