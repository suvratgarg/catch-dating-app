import {onDocumentWritten} from "firebase-functions/v2/firestore";
import * as admin from "firebase-admin";
import {
  EventDocument,
} from "../shared/generated/firestoreAdminTypes";

interface SyncClubNextEventDeps {
  firestore: () => FirebaseFirestore.Firestore;
  nowTimestamp: () => FirebaseFirestore.Timestamp;
}

const defaultDeps: SyncClubNextEventDeps = {
  firestore: () => admin.firestore(),
  nowTimestamp: () => admin.firestore.Timestamp.now(),
};

/**
 * Recomputes the next upcoming active event projection for one club.
 * @param {string} clubId Club id.
 * @param {SyncClubNextEventDeps} deps Injectable Firebase dependencies.
 * @return {Promise<void>}
 */
export async function refreshClubNextEvent(
  organizerId: string,
  deps: SyncClubNextEventDeps = defaultDeps
): Promise<void> {
  const db = deps.firestore();
  const organizerRef = db.collection("organizers").doc(organizerId);
  const organizerSnap = await organizerRef.get();

  if (!organizerSnap.exists) {
    return;
  }

  const nextEventSnap = await db
    .collection("events")
    .where("organizerId", "==", organizerId)
    .where("status", "==", "active")
    .where("startTime", ">=", deps.nowTimestamp())
    .orderBy("startTime", "asc")
    .limit(1)
    .get();

  const nextEvent = nextEventSnap.docs[0]?.data() as EventDocument | undefined;
  const projection = {
    nextEventAt: nextEvent?.startTime ?? null,
    nextEventLabel: nextEvent ?
      nextEvent.meetingLocation?.name ?? nextEvent.meetingPoint :
      null,
  };
  const batch = db.batch();
  batch.set(organizerRef, projection, {merge: true});
  batch.set(db.collection("clubs").doc(organizerId), projection, {merge: true});
  await batch.commit();
}

/**
 * Recomputes club next-event projections affected by an event write.
 * @param {EventDocument | undefined} before Event before state.
 * @param {EventDocument | undefined} after Event after state.
 * @param {SyncClubNextEventDeps} deps Injectable Firebase dependencies.
 * @return {Promise<void>}
 */
export async function syncClubNextEventHandler(
  before: EventDocument | undefined,
  after: EventDocument | undefined,
  deps: SyncClubNextEventDeps = defaultDeps
): Promise<void> {
  const organizerIds = new Set<string>();

  if (before?.organizerId ?? before?.clubId) {
    organizerIds.add(before.organizerId ?? before!.clubId);
  }
  if (after?.organizerId ?? after?.clubId) {
    organizerIds.add(after.organizerId ?? after!.clubId);
  }

  await Promise.all(
    Array.from(organizerIds).map(
      (organizerId) => refreshClubNextEvent(organizerId, deps)
    )
  );
}

export const syncClubNextEvent = onDocumentWritten(
  "events/{eventId}",
  async (event) => {
    const before = event.data?.before.data() as EventDocument | undefined;
    const after = event.data?.after.data() as EventDocument | undefined;
    await syncClubNextEventHandler(before, after);
  }
);
