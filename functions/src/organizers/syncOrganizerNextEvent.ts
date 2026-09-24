import {onDocumentWritten} from "firebase-functions/v2/firestore";
import * as admin from "firebase-admin";
import * as logger from "firebase-functions/logger";
import {isEventPubliclyAccessible} from "../events/eventPublicationAccess";
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
  const now = deps.nowTimestamp();
  const exhausted = await db.runTransaction(async (tx) => {
    const organizerSnap = await tx.get(organizerRef);
    if (!organizerSnap.exists) return false;
    const baseQuery = db.collection("events")
      .where("organizerId", "==", organizerId)
      .where("status", "==", "active")
      .where("startTime", ">=", now)
      .orderBy("startTime", "asc")
      .orderBy(admin.firestore.FieldPath.documentId(), "asc");
    let nextEvent: EventDocument | undefined;
    let last: FirebaseFirestore.QueryDocumentSnapshot | undefined;
    let complete = false;
    // Legacy public events have no publication field. Scan bounded pages until
    // that compatibility population can be migrated to an indexed predicate.
    for (let pageNumber = 0; pageNumber < 20; pageNumber++) {
      const query = last ? baseQuery.startAfter(last) : baseQuery;
      const page = await tx.get(query.limit(25));
      nextEvent = page.docs.map((doc) => doc.data() as EventDocument)
        .find(isEventPubliclyAccessible);
      if (nextEvent || page.size < 25) {
        complete = true;
        break;
      }
      last = page.docs[page.docs.length - 1];
    }
    // Clear a stale projection even when the budget is exhausted: never retain
    // a now-private event's label or schedule on the public organizer record.
    tx.set(organizerRef, {
      nextEventAt: nextEvent?.startTime ?? null,
      nextEventLabel: nextEvent ?
        nextEvent.meetingLocation?.name ?? nextEvent.meetingPoint ?? null :
        null,
    }, {merge: true});
    return !complete;
  });
  if (exhausted) {
    logger.warn("Public next-event projection scan exhausted", {
      organizerId, maxScannedEvents: 500,
    });
  }
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
