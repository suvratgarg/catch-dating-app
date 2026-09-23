import {HttpsError} from "firebase-functions/v2/https";
import {isOrganizerManager} from "../shared/organizerHosts";
import {loadProgramBundle, supportsProgramDutyScope} from
  "../shared/programAuthority";
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

/** Validate the same resource versions that the staff mutation commits with. */
export async function validateDutyStations(params: {
  db: FirebaseFirestore.Firestore;
  programId: string;
  organizerId: string;
  duties: GrantProgramStaffCallablePayload["duties"];
  transaction?: FirebaseFirestore.Transaction;
}): Promise<void> {
  const duties = dedupeDuties(params.duties);
  const pickupIds = new Set(duties.flatMap((duty) => duty.pickupPointIds));
  const hotelIds = new Set(duties.flatMap((duty) => duty.hotelIds));
  const refs = [
    ...[...pickupIds].map((id) =>
      params.db.collection("programPickupPoints").doc(id)),
    ...[...hotelIds].map((id) => params.db.collection("programHotels").doc(id)),
  ];
  const snaps = await Promise.all(refs.map((ref) => params.transaction ?
    params.transaction.get(ref) : ref.get()));
  for (const snap of snaps) {
    const resource = snap.data() as ProgramPickupPointDocument |
      ProgramHotelDocument | undefined;
    if (!resource || resource.programId !== params.programId ||
        resource.organizerId !== params.organizerId ||
        resource.active !== true) {
      throw new HttpsError("invalid-argument",
        "Assigned resources must be active and belong to this program.");
    }
  }
}

type DutyScope = GrantProgramStaffCallablePayload["duties"][number];

/** Canonicalize exact scope tuples, never their Cartesian product. */
export function dedupeDuties<T extends DutyScope>(duties: T[]): T[] {
  const byScope = new Map<string, T>();
  for (const assignment of duties) {
    if (!supportsProgramDutyScope(assignment)) {
      throw new HttpsError("invalid-argument",
        assignment.duty === "hotelDesk" ?
          "Hotel desk duties are scoped by hotel, not pickup point." :
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

export function unionScope(duties: ProgramStaffGrantDocument["duties"],
  field: "pickupPointIds" | "hotelIds"): Set<string> | null {
  const scoped = new Set<string>();
  for (const assignment of duties) {
    if (assignment[field].length === 0) return null;
    for (const id of assignment[field]) scoped.add(id);
  }
  return scoped;
}
