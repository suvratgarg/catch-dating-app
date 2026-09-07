import type {Firestore, Transaction, DocumentSnapshot} from
  "firebase-admin/firestore";
import {validateEventAttendeeDocument} from
  "../../shared/generated/validators/eventAttendeeDocument";
import {guestSourceFactsFromSnapshots} from "./guestRecords";
import {readGroupProgressState} from "./groupProgressReader";
import {DEPARTURE_ROSTERS, departureRosterIdentity,
  departureVisitHash} from "./departureRosterSource";
import {invalidSource} from "./groupProgressSource";
import {readCheckpointOwnerValidity} from "./checkpointRequest";
import {CHECKPOINTS, checkpointIdentity, CheckpointState,
  parseDepartureRoster, parseCheckpointReport, checkpointAvailability,
  Scope, Roster, Visit, ProgressState} from "./checkpointRecords";

/** Trusted reader. The caller must authorize the group before invoking it. */
export async function readCheckpoint(db: Firestore, tx: Transaction,
  scope: Scope, clock: () => number): Promise<CheckpointState> {
  const progress = await readGroupProgressState(db, tx, scope.context,
    scope.groupId, clock);
  const [rosterSnap, reportSnap] = await tx.getAll(
    db.collection(DEPARTURE_ROSTERS).doc(departureRosterIdentity(scope.context,
      scope.groupId, scope.progressRevision)),
    db.collection(CHECKPOINTS).doc(checkpointIdentity(scope)));
  const now = clock();
  if (!Number.isSafeInteger(now) || now < progress.now) throw invalidSource();
  const roster = parseDepartureRoster(rosterSnap.data(), scope, now);
  const report = parseCheckpointReport(reportSnap.data(), scope, roster, now);
  const state: CheckpointState = {scope, progress, roster, report, now,
    visits: [], ownerValidUntil: 0};
  if (roster && checkpointAvailability(state).kind === "ready") {
    for (let offset = 0; offset < roster.members.length; offset += 100) {
      const members = roster.members.slice(offset, offset + 100);
      const snapshots = await tx.getAll(...members.map((m) =>
        db.collection("eventAttendees").doc(m.attendeeId)));
      for (const [i, member] of members.entries()) {
        state.visits.push({attendeeId: member.attendeeId,
          visit: checkpointVisit(member, snapshots[i], progress)});
      }
    }
  }
  if (roster?.checkpointRequest) {
    state.ownerValidUntil = await readCheckpointOwnerValidity(db, tx,
      scope.context, scope.groupId, roster.checkpointRequest, clock);
  }
  const afterReads = clock();
  if (!Number.isSafeInteger(afterReads) || afterReads < now) {
    throw invalidSource();
  }
  state.now = afterReads;
  return state;
}

/** Changes never remove a person from the original departure roster. */
function checkpointVisit(member: Roster["members"][number],
  snapshot: DocumentSnapshot, progress: ProgressState): Visit {
  const unavailable = (reason: Extract<Visit,
    {kind: "unavailable"}>["reason"]): Visit => ({kind: "unavailable", reason});
  if (!snapshot.exists) return unavailable("registrationMissing");
  const attendee = snapshot.data();
  const context = progress.source.context;
  if (!validateEventAttendeeDocument(attendee) ||
      attendee.eventId !== context.eventId ||
      attendee.organizerId !== context.organizerId) {
    return unavailable("invalidSource");
  }
  try {
    const source = guestSourceFactsFromSnapshots(context, member.attendeeId,
      progress.eventSnapshot, snapshot);
    if (source.sourceGeneration !== member.sourceGeneration ||
        source.attendeeGeneration !== member.attendeeGeneration) {
      return unavailable("visitChanged");
    }
    if (attendee.status !== "checkedIn" || !attendee.checkedInAt) {
      return unavailable("notCheckedIn");
    }
    if (departureVisitHash(attendee) !== member.checkInHash) {
      return unavailable("visitChanged");
    }
    return {kind: "current"};
  } catch {
    // Only pure parsing is caught; database failures propagate.
    return unavailable("invalidSource");
  }
}
