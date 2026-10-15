import {HttpsError} from "firebase-functions/v2/https";
import {programOwnerAuthorizationDeadline, requireProgramAccess,
  requireProgramDuty, supportsProgramDutyScope} from
  "../shared/programAuthority";
import type {ProgramAccess, ProgramAuthorization} from
  "../shared/programAuthority";
import {staffTimestampMillis} from "../shared/eventOperatorAuthority";
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
  transaction?: FirebaseFirestore.Transaction,
  now?: FirebaseFirestore.Timestamp
): Promise<ProgramAccess> {
  const access = await requireProgramAccess({db, programId, actorUid,
    transaction, now});
  requireProgramDuty(access, "programAdmin");
  return access;
}

/** Delegation cannot extend the creator-approved root or live admin duty. */
export function programAdministrationDeadline(access: ProgramAccess,
  nowMillis: number): number | null {
  if (access.role === "manager") return null;
  const assignments = requireProgramDuty(access, "programAdmin")
    .filter((assignment) => assignment.expiresAtMillis > nowMillis);
  const root = programOwnerAuthorizationDeadline(access.program,
    access.grant!);
  if (root === null || root <= nowMillis || assignments.length === 0) {
    throw new HttpsError("permission-denied",
      "Program administration expired.");
  }
  return Math.min(root, staffTimestampMillis(access.grant!.expiresAt),
    Math.max(...assignments.map((assignment) => assignment.expiresAtMillis)));
}

/** Called again at the commit boundary, preserving a bounded approval chain. */
export function authorizeProgramStaffGrant(access: ProgramAccess,
  actorUid: string, expiresAtMillis: number, nowMillis: number):
  ProgramAuthorization {
  const deadline = programAdministrationDeadline(access, nowMillis);
  if (expiresAtMillis <= nowMillis ||
      (deadline !== null && expiresAtMillis > deadline)) {
    throw new HttpsError("permission-denied",
      "Delegated access must end within your approved program admin window.");
  }
  return {ownerUid: access.program.createdBy, approvedByUid: actorUid,
    approvedAtMillis: nowMillis,
    authorizedUntilMillis: expiresAtMillis};
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
          "Program administrators and coordinators need program-wide scope.");
    }
    const normalized = {...assignment,
      pickupPointIds: [...new Set(assignment.pickupPointIds)].sort(),
      hotelIds: [...new Set(assignment.hotelIds)].sort(),
      ...(assignment.functionIds === undefined ? {} :
        {functionIds: [...new Set(assignment.functionIds)].sort()})};
    const key = JSON.stringify([normalized.duty,
      normalized.pickupPointIds, normalized.hotelIds,
      normalized.functionIds ?? []]);
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
  field: "pickupPointIds" | "hotelIds" | "functionIds"): Set<string> | null {
  const scoped = new Set<string>();
  for (const assignment of duties) {
    const ids = assignment[field] ?? [];
    if (ids.length === 0) return null;
    for (const id of ids) scoped.add(id);
  }
  return scoped;
}
