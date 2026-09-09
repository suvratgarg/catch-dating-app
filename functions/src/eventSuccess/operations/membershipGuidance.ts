import {HttpsError} from "firebase-functions/v2/https";
import type {Firestore, Transaction, DocumentSnapshot} from
  "firebase-admin/firestore";
import type {MessageRecord} from "./messageOutbox";
import {validateEventAttendeeDocument} from
  "../../shared/generated/validators/eventAttendeeDocument";
import {validateEventDocument} from
  "../../shared/generated/validators/eventDocument";
import {MEMBERSHIPS, membershipIdentity, parseMembership} from
  "./membershipReader";
import {guestCollections, guestIdentity, parseGuest, currentGuest,
  guestSourceFactsFromSnapshots} from "./guestRecords";
import {groupDutySource} from "./groupStaffAuthority";

/** Only an accepted group can supply this guest's group-specific directions. */
export async function membershipGuidanceIsCurrent(db: Firestore,
  tx: Transaction, intent: MessageRecord["intent"], now: number,
  eventSnapshot: DocumentSnapshot): Promise<boolean> {
  if (intent.kind !== "joiningUpdate" ||
      intent.guidance.destination.kind !== "groupCheckpoint") return true;
  if (intent.context.mode !== "live") return false;
  const scope = {context: intent.context, attendeeId: intent.attendeeId};
  const [memberSnap, guestSnap, attendeeSnap] = await tx.getAll(
    db.collection(MEMBERSHIPS).doc(membershipIdentity(scope)),
    db.collection(guestCollections.guests).doc(guestIdentity(scope.context,
      scope.attendeeId)),
    db.collection("eventAttendees").doc(scope.attendeeId));
  if (!memberSnap.exists || !guestSnap.exists) return false;
  const event = eventSnapshot.data();
  const attendee = attendeeSnap.data();
  if (!validateEventDocument(event) ||
      !validateEventAttendeeDocument(attendee)) return false;
  try {
    const m = parseMembership(memberSnap.data(), scope, now);
    const guest = parseGuest(guestSnap.data());
    const source = guestSourceFactsFromSnapshots(scope.context,
      scope.attendeeId,
      eventSnapshot, attendeeSnap);
    const groupId = intent.guidance.destination.groupId;
    const group = groupDutySource(scope.context, groupId, event,
      eventSnapshot.createTime);
    return group.paceGroup && currentGuest(guest, source) &&
      guest.guestId === guestIdentity(scope.context, scope.attendeeId) &&
      guest.updatedAt <= now && guest.episodeId === intent.episodeId &&
      m.episodeId === guest.episodeId &&
      m.sourceGeneration === source.sourceGeneration &&
      m.attendeeGeneration === source.attendeeGeneration &&
      m.accepted?.groupId === groupId &&
      m.accepted.groupSourceHash === group.hash;
  } catch (error) {
    if (error instanceof HttpsError &&
        ["failed-precondition", "not-found"].includes(error.code)) return false;
    throw error;
  }
}
