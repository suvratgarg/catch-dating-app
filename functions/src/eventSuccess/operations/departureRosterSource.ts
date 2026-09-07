import {HttpsError} from "firebase-functions/v2/https";
import type {Firestore, Transaction, DocumentSnapshot} from
  "firebase-admin/firestore";
import {operationContentHash} from "../../operations/durableActions";
import type {EventAssistanceDepartureRosterDocument as Roster} from
  "../../shared/generated/eventAssistanceDepartureRosterDocument";
import {validateEventAttendeeDocument} from
  "../../shared/generated/validators/eventAttendeeDocument";
import {readGroupProgressState} from "./groupProgressReader";
import {invalidSource, timestampEvidence} from "./groupProgressSource";
import {guestCollections, guestIdentity, guestSourceFactsFromSnapshots,
  parseGuest, currentGuest} from "./guestRecords";
import {groupDutySource} from "./groupStaffAuthority";
import {MEMBERSHIPS, membershipIdentity, parseMembership,
  currentMembership} from "./membershipReader";

export const DEPARTURE_ROSTERS = "eventAssistanceDepartureRosters";
type State = Awaited<ReturnType<typeof readGroupProgressState>>;
export function departureRosterIdentity(context: Roster["context"],
  groupId: string, progressRevision: number) {
  return "departure-roster:" + operationContentHash([
    context, groupId, progressRevision]);
}

/** Explicit selection only. A current roster never proves who departed. */
export async function readDepartureRoster(db: Firestore, tx: Transaction,
  state: State, attendeeIds: readonly string[]) {
  const {context, groupId} = state.source;
  if (attendeeIds.length > 1000 ||
      new Set(attendeeIds).size !== attendeeIds.length) throw invalidSource();
  const ids = [...attendeeIds].sort();
  const members: Roster["members"] = [];
  // Bound each RPC while retaining the command's complete 1,000-person scope.
  for (let offset = 0; offset < ids.length; offset += 100) {
    const batch = ids.slice(offset, offset + 100);
    const refs = batch.flatMap((attendeeId) => [
      db.collection("eventAttendees").doc(attendeeId),
      db.collection(guestCollections.guests)
        .doc(guestIdentity(context, attendeeId)),
      ...(groupId === "event:whole" ? [] : [db.collection(MEMBERSHIPS)
        .doc(membershipIdentity({context, attendeeId}))]),
    ]);
    const snaps = await tx.getAll(...refs);
    const width = groupId === "event:whole" ? 2 : 3;
    for (const [index, id] of batch.entries()) {
      members.push(departureMember(state, id, snaps[index * width],
        snaps[index * width + 1], width === 3 ?
          snaps[index * width + 2] : undefined));
    }
  }
  const sourceHash = operationContentHash([state.source.context,
    state.source.groupId, state.source.sourceHash,
    state.progress?.revision ?? 0,
    state.eventSnapshot.data()!.eventFormat, members]);
  return {members, sourceHash};
}

function departureMember(state: State, attendeeId: string,
  attendeeSnap: DocumentSnapshot, guestSnap: DocumentSnapshot,
  memberSnap?: DocumentSnapshot): Roster["members"][number] {
  const {context, groupId} = state.source;
  const attendee = attendeeSnap.data();
  if (!validateEventAttendeeDocument(attendee) ||
      attendee.eventId !== context.eventId ||
      attendee.organizerId !== context.organizerId) throw invalidSource();
  const source = guestSourceFactsFromSnapshots(context, attendeeId,
    state.eventSnapshot, attendeeSnap);
  const guest = guestSnap.exists ? parseGuest(guestSnap.data()) : null;
  if (guest && (guest.guestId !== guestIdentity(context, attendeeId) ||
      guest.updatedAt > state.now)) throw invalidSource();
  const activeGuest = guest && currentGuest(guest, source) ? guest : null;
  let membershipHash: string | null = null;
  if (groupId !== "event:whole") {
    const raw = memberSnap?.data();
    const membership = raw === undefined ? null :
      parseMembership(raw, {context, attendeeId}, state.now);
    const event = state.eventSnapshot.data()!;
    const groups = [{groupId, label: groupId,
      sourceHash: groupDutySource(context, groupId,
        event as Parameters<typeof groupDutySource>[2],
        state.eventSnapshot.createTime).hash}];
    if (!currentMembership({membership, guest, source, groups}) ||
        membership?.accepted?.groupId !== groupId) {
      throw new HttpsError("failed-precondition",
        "Every selected guest must have an accepted membership in this group.");
    }
    membershipHash = operationContentHash([
      membership.revision, membership.accepted]);
  }
  if (attendee.status !== "checkedIn" || !attendee.checkedInAt) {
    throw new HttpsError("failed-precondition",
      "Check in every selected guest before recording the departure roster.");
  }
  const checkIn = timestampEvidence(attendee.checkedInAt);
  const millis = checkIn._seconds * 1000 + checkIn._nanoseconds / 1_000_000;
  if (millis > state.now || millis < 0) throw invalidSource();
  if (activeGuest && activeGuest.participation.state !== "active") {
    throw new HttpsError("failed-precondition",
      "Resume the selected guest's participation before departure.");
  }
  return {attendeeId, sourceGeneration: source.sourceGeneration,
    attendeeGeneration: source.attendeeGeneration,
    checkInHash: operationContentHash([attendee.attendanceRevision ?? 0,
      checkIn]), episodeId: activeGuest?.episodeId ?? null, membershipHash};
}
