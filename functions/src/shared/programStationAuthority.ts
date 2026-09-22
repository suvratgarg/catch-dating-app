import {HttpsError} from "firebase-functions/v2/https";
import {dutyAssignments, requireProgramAccess} from "./programAuthority";
import type {ProgramAccess, ProgramDutyAssignment} from "./programAuthority";

type StationAccess = {
  access: ProgramAccess;
  assignments: ProgramDutyAssignment[];
  stationScope: Set<string> | null;
};

/** Greeters and dispatchers share the operational arrivals surface. */
export async function requireStationAccess(
  db: FirebaseFirestore.Firestore,
  programId: string,
  actorUid: string,
  now: FirebaseFirestore.Timestamp,
  transaction?: FirebaseFirestore.Transaction,
): Promise<StationAccess> {
  const access = await requireProgramAccess({
    db, programId, actorUid, now, transaction,
  });
  const assignments = access.role === "manager" ? [] : [
    ...dutyAssignments(access, "airportGreeter"),
    ...dutyAssignments(access, "transportDispatcher"),
  ];
  if (access.role !== "manager" && assignments.length === 0) {
    throw new HttpsError(
      "permission-denied",
      "This account has no airport duty for this program."
    );
  }
  const stationScope = access.role === "manager" ? null :
    unionStationScope(assignments);
  return {access, assignments, stationScope};
}

function unionStationScope(
  assignments: ProgramDutyAssignment[]
): Set<string> | null {
  const scoped = new Set<string>();
  for (const assignment of assignments) {
    if (assignment.pickupPointIds.length === 0) return null;
    for (const id of assignment.pickupPointIds) scoped.add(id);
  }
  return scoped;
}

