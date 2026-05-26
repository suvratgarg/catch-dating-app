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
  clubId: string,
  deps: SyncClubNextEventDeps = defaultDeps
): Promise<void> {
  const db = deps.firestore();
  const clubRef = db.collection("clubs").doc(clubId);
  const clubSnap = await clubRef.get();

  if (!clubSnap.exists) {
    return;
  }

  const nextEventSnap = await db
    .collection("events")
    .where("clubId", "==", clubId)
    .where("status", "==", "active")
    .where("startTime", ">=", deps.nowTimestamp())
    .orderBy("startTime", "asc")
    .limit(1)
    .get();

  const nextEvent = nextEventSnap.docs[0]?.data() as EventDocument | undefined;
  await clubRef.set({
    nextEventAt: nextEvent?.startTime ?? null,
    nextEventLabel: nextEvent ?
      nextEvent.meetingLocation?.name ?? nextEvent.meetingPoint :
      null,
  }, {merge: true});
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
  const clubIds = new Set<string>();

  if (before?.clubId) {
    clubIds.add(before.clubId);
  }
  if (after?.clubId) {
    clubIds.add(after.clubId);
  }

  await Promise.all(
    Array.from(clubIds).map(
      (clubId) => refreshClubNextEvent(clubId, deps)
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
