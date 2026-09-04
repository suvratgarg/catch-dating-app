import {onDocumentWritten} from "firebase-functions/v2/firestore";
import * as admin from "firebase-admin";
import type {
  EventDocument,
} from "../shared/generated/firestoreAdminTypes";

interface SyncOrganizerNextEventDeps {
  firestore: () => FirebaseFirestore.Firestore;
  nowTimestamp: () => FirebaseFirestore.Timestamp;
}

const defaultDeps: SyncOrganizerNextEventDeps = {
  firestore: () => admin.firestore(),
  nowTimestamp: () => admin.firestore.Timestamp.now(),
};

/**
 * Recomputes the next upcoming active event projection for one organizer.
 * @param {string} organizerId Organizer id.
 * @param {SyncOrganizerNextEventDeps} deps Injectable Firebase dependencies.
 * @return {Promise<void>}
 */
export async function refreshOrganizerNextEvent(
  organizerId: string,
  deps: SyncOrganizerNextEventDeps = defaultDeps
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
  await organizerRef.set(projection, {merge: true});
}

/**
 * Recomputes organizer next-event projections affected by an event write.
 * @param {EventDocument | undefined} before Event before state.
 * @param {EventDocument | undefined} after Event after state.
 * @param {SyncOrganizerNextEventDeps} deps Injectable Firebase dependencies.
 * @return {Promise<void>}
 */
export async function syncOrganizerNextEventHandler(
  before: EventDocument | undefined,
  after: EventDocument | undefined,
  deps: SyncOrganizerNextEventDeps = defaultDeps
): Promise<void> {
  const organizerIds = new Set<string>();

  if (before?.organizerId) {
    organizerIds.add(before.organizerId);
  }
  if (after?.organizerId) {
    organizerIds.add(after.organizerId);
  }

  await Promise.all(
    Array.from(organizerIds).map(
      (organizerId) => refreshOrganizerNextEvent(organizerId, deps)
    )
  );
}

export const syncOrganizerNextEvent = onDocumentWritten(
  "events/{eventId}",
  async (event) => {
    const before = event.data?.before.data() as EventDocument | undefined;
    const after = event.data?.after.data() as EventDocument | undefined;
    await syncOrganizerNextEventHandler(before, after);
  }
);
