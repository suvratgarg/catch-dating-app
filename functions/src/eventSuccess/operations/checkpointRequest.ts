import {HttpsError} from "firebase-functions/v2/https";
import type {Firestore, Transaction} from "firebase-admin/firestore";
import type {EventAssistanceDepartureRosterDocument as Roster} from
  "../../shared/generated/eventAssistanceDepartureRosterDocument";
import {requireGroupPermission} from "./groupStaffAuthority";
import {invalidSource, ProgressContext} from "./groupProgressSource";

export type CheckpointRequest = NonNullable<Roster["checkpointRequest"]>;
export const MAX_REPORT_DELAY = 7 * 24 * 60 * 60 * 1000;
export const REPORT_CLOSEOUT_WINDOW = 4 * 60 * 60 * 1000;

/** Naming an owner uses existing authority; it never grants staff access. */
export async function authorizeCheckpointRequest(db: Firestore,
  tx: Transaction, context: ProgressContext, groupId: string,
  actorUid: string, actorRole: "eventLead" | "groupLead",
  request: CheckpointRequest, clock: () => number) {
  if (actorRole !== "eventLead" &&
      request.responsibleOperatorId !== actorUid) {
    throw new HttpsError("permission-denied",
      "Only organizer managers can name another checkpoint reporter.");
  }
  const owner = await requireGroupPermission(db, tx, context, groupId,
    request.responsibleOperatorId, "recordCheckpoint", clock);
  return owner.validUntil;
}

export function assertCheckpointRequestDeadline(request: CheckpointRequest,
  ownerValidUntil: number, now: number, eventEnd: number) {
  if (request.dueAt < now || request.dueAt > Math.min(
    now + MAX_REPORT_DELAY, eventEnd + REPORT_CLOSEOUT_WINDOW) ||
      ownerValidUntil <= request.dueAt) {
    throw new HttpsError("failed-precondition",
      "Choose a reporting deadline within the reporter's current access.");
  }
}

/** Permission loss stays visible; source failures are not denials. */
export async function readCheckpointOwnerValidity(db: Firestore,
  tx: Transaction, context: ProgressContext, groupId: string,
  request: CheckpointRequest, clock: () => number): Promise<number> {
  try {
    return (await requireGroupPermission(db, tx, context, groupId,
      request.responsibleOperatorId, "recordCheckpoint", clock)).validUntil;
  } catch (error) {
    if (error instanceof HttpsError && error.code === "permission-denied") {
      return 0;
    }
    throw error;
  }
}

export function assertSavedCheckpointRequest(roster: Roster) {
  const request = roster.checkpointRequest;
  if (request && (request.dueAt < roster.confirmedAt ||
      request.dueAt > roster.confirmedAt + MAX_REPORT_DELAY ||
      (roster.destination?.kind !== "itineraryStop" &&
        roster.destination?.kind !== "groupCheckpoint"))) {
    throw invalidSource();
  }
}
