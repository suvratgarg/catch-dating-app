import * as admin from "firebase-admin";
import {HttpsError} from "firebase-functions/v2/https";
import type {
  OrganizerDocument,
  OrganizerProgramDocument,
  ProgramStaffGrantDocument,
} from "./generated/firestoreAdminTypes";
import {isOrganizerManager} from "./organizerHosts";
import {requireDoc} from "./validation";
import {staffTimestampMillis} from "./eventOperatorAuthority";

export type ProgramStaffDuty =
  ProgramStaffGrantDocument["duties"][number]["duty"];

export type ProgramDutyAssignment =
  ProgramStaffGrantDocument["duties"][number];

export const programStaffDuties: ProgramStaffDuty[] = [
  "programCoordinator",
  "airportGreeter",
  "hotelDesk",
  "transportDispatcher",
  "reconciliationViewer",
];

export function programStaffGrantId(programId: string, uid: string): string {
  return `${programId}__${uid}`;
}

export interface ProgramAccess {
  program: OrganizerProgramDocument;
  organizer: OrganizerDocument;
  role: "manager" | "staff";
  grant: ProgramStaffGrantDocument | null;
}

export async function loadProgramBundle(params: {
  db: FirebaseFirestore.Firestore;
  programId: string;
  transaction?: FirebaseFirestore.Transaction;
}): Promise<{program: OrganizerProgramDocument;
  organizer: OrganizerDocument}> {
  const programRef = params.db.collection("organizerPrograms")
    .doc(params.programId);
  const programSnap = params.transaction ?
    await params.transaction.get(programRef) : await programRef.get();
  if (!programSnap.exists) {
    throw new HttpsError("not-found", "Program not found.");
  }
  const program = requireDoc<OrganizerProgramDocument>(
    programSnap, "OrganizerProgramDocument");
  const organizerSnap = params.transaction ?
    await params.transaction.get(
      params.db.collection("organizers").doc(program.organizerId)) :
    await params.db.collection("organizers").doc(program.organizerId).get();
  if (!organizerSnap.exists) {
    throw new HttpsError("failed-precondition", "Program organizer missing.");
  }
  const organizer = requireDoc<OrganizerDocument>(
    organizerSnap, "OrganizerDocument");
  return {program, organizer};
}

/** Manager bypass first; otherwise an active, unexpired, matching grant. */
export async function requireProgramAccess(params: {
  db: FirebaseFirestore.Firestore;
  programId: string;
  actorUid: string;
  now?: FirebaseFirestore.Timestamp;
  transaction?: FirebaseFirestore.Transaction;
}): Promise<ProgramAccess> {
  const {program, organizer} = await loadProgramBundle(params);
  if (isOrganizerManager(organizer, params.actorUid)) {
    return {program, organizer, role: "manager", grant: null};
  }
  const grantRef = params.db.collection("programStaffGrants")
    .doc(programStaffGrantId(params.programId, params.actorUid));
  const grantSnap = params.transaction ?
    await params.transaction.get(grantRef) : await grantRef.get();
  const grant = grantSnap.data() as ProgramStaffGrantDocument | undefined;
  const now = params.now ?? admin.firestore.Timestamp.now();
  if (!grant || grant.programId !== params.programId ||
      grant.organizerId !== program.organizerId ||
      grant.uid !== params.actorUid || grant.status !== "active" ||
      staffTimestampMillis(grant.expiresAt) <= now.toMillis()) {
    throw new HttpsError(
      "permission-denied",
      "This account does not have active program access."
    );
  }
  return {program, organizer, role: "staff", grant};
}

function findDuty(grant: ProgramStaffGrantDocument,
  duty: ProgramStaffDuty): ProgramDutyAssignment | undefined {
  return (grant.duties ?? []).find((assignment) => assignment.duty === duty);
}

/** Coordinators implicitly satisfy every operational duty. */
export function dutyAssignments(access: ProgramAccess,
  duty: ProgramStaffDuty): ProgramDutyAssignment[] {
  if (access.role === "manager") return [];
  const grant = access.grant!;
  const coordinator = findDuty(grant, "programCoordinator");
  if (coordinator) return [coordinator];
  const assignment = findDuty(grant, duty);
  return assignment ? [assignment] : [];
}

export function requireProgramDuty(access: ProgramAccess,
  duty: ProgramStaffDuty): ProgramDutyAssignment[] {
  const assignments = dutyAssignments(access, duty);
  if (access.role !== "manager" && assignments.length === 0) {
    throw new HttpsError(
      "permission-denied",
      `This account lacks the ${duty} duty for this program.`
    );
  }
  return assignments;
}

/** Empty scope list means all stations of that kind. */
export function dutyCoversPickupPoint(assignments: ProgramDutyAssignment[],
  pickupPointId: string): boolean {
  return assignments.some((assignment) =>
    assignment.pickupPointIds.length === 0 ||
    assignment.pickupPointIds.includes(pickupPointId));
}

export function dutyCoversHotel(assignments: ProgramDutyAssignment[],
  hotelId: string): boolean {
  return assignments.some((assignment) =>
    assignment.hotelIds.length === 0 ||
    assignment.hotelIds.includes(hotelId));
}

export function allowedPickupPointIds(access: ProgramAccess,
  duty: ProgramStaffDuty): Set<string> | null {
  if (access.role === "manager") return null;
  const scoped = new Set<string>();
  let unrestricted = false;
  for (const assignment of dutyAssignments(access, duty)) {
    if (assignment.pickupPointIds.length === 0) unrestricted = true;
    for (const id of assignment.pickupPointIds) scoped.add(id);
  }
  return unrestricted ? null : scoped;
}

export function allowedHotelIds(access: ProgramAccess,
  duty: ProgramStaffDuty): Set<string> | null {
  if (access.role === "manager") return null;
  const scoped = new Set<string>();
  let unrestricted = false;
  for (const assignment of dutyAssignments(access, duty)) {
    if (assignment.hotelIds.length === 0) unrestricted = true;
    for (const id of assignment.hotelIds) scoped.add(id);
  }
  return unrestricted ? null : scoped;
}

export function assertRevision(actual: number, expected: number | undefined):
  void {
  if (expected !== undefined && actual !== expected) {
    throw new HttpsError(
      "aborted",
      "Record changed since you loaded it. Reload and retry."
    );
  }
}

export function nextRevision(current: number | undefined,
  now: FirebaseFirestore.Timestamp): number {
  return Math.max((current ?? 0) + 1, now.toMillis());
}
