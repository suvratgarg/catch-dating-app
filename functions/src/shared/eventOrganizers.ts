import {HttpsError} from "firebase-functions/v2/https";
import {
  EventDocument,
  OrganizerDocument,
} from "./generated/firestoreAdminTypes";
import {isOrganizerManager} from "./organizerHosts";
import {requireDoc} from "./validation";

export type EventOrganizerDocument = OrganizerDocument;

/** Returns an event's required canonical organizer id. */
export function eventOrganizerId(event: EventDocument): string {
  if (!event.organizerId) {
    throw new HttpsError("failed-precondition", "Event has no organizer.");
  }
  return event.organizerId;
}

/** Returns the canonical organizer authority reference for an event. */
export function eventOrganizerRef(
  db: FirebaseFirestore.Firestore,
  event: EventDocument
): FirebaseFirestore.DocumentReference {
  return db.collection("organizers").doc(eventOrganizerId(event));
}

/** Parses an event's canonical organizer authority document. */
export function requireEventOrganizer(
  snap: FirebaseFirestore.DocumentSnapshot,
  event: EventDocument
): EventOrganizerDocument {
  if (!snap.exists) {
    throw new HttpsError("not-found", "Organizer not found.");
  }
  eventOrganizerId(event);
  return requireDoc<OrganizerDocument>(snap, "OrganizerDocument");
}

/** Checks management privilege using canonical organizer authority. */
export function isEventOrganizerManager(
  organizer: EventOrganizerDocument,
  event: EventDocument,
  uid: string
): boolean {
  eventOrganizerId(event);
  return isOrganizerManager(organizer, uid);
}
