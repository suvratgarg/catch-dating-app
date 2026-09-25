import {onDocumentWritten} from "firebase-functions/v2/firestore";
import * as admin from "firebase-admin";
import type {
  EventDocument,
} from "../shared/generated/firestoreAdminTypes";
import {isEventPubliclyAccessible} from "../events/eventPublicationAccess";

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
  await db.runTransaction(async (tx) => {
    const organizerSnap = await tx.get(organizerRef);
    if (!organizerSnap.exists) return;
    // Compatibility stage: legacy public events may lack publicationState.
    // Private event creation remains disabled until public-reader cutover.
    /* firestore-index: events (
      organizerId:ASCENDING, status:ASCENDING,
      startTime:ASCENDING, __name__:ASCENDING
    ) */
    const query = db.collection("events")
      .where("organizerId", "==", organizerId)
      .where("status", "==", "active")
      .where("startTime", ">=", now)
      .orderBy("startTime", "asc")
      .orderBy(admin.firestore.FieldPath.documentId(), "asc")
      .limit(1);
    const page = await tx.get(query);
    const nextEvent = page.docs[0]?.data() as EventDocument | undefined;
    // Query results are current event documents in this transaction snapshot.
    // A contradictory row must not project a public label.
    const visible = nextEvent && isEventPubliclyAccessible(nextEvent) &&
      nextEvent.organizerId === organizerId &&
      nextEvent.status === "active" ? nextEvent : undefined;
    tx.set(organizerRef, {
      nextEventAt: visible?.startTime ?? null,
      nextEventLabel: visible ?
        visible.meetingLocation?.name ?? visible.meetingPoint ?? null : null,
    }, {merge: true});
  });
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
