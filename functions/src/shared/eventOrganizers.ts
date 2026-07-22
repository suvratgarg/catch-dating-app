import {HttpsError} from "firebase-functions/v2/https";
import {
  ClubDocument,
  EventDocument,
  OrganizerDocument,
} from "./generated/firestoreAdminTypes";
import {isClubHost} from "./clubHosts";
import {isOrganizerManager} from "./organizerHosts";
import {requireDoc} from "./validation";

export type EventOrganizerDocument = OrganizerDocument | ClubDocument;

/** Returns the canonical organizer id with legacy event fallback. */
export function eventOrganizerId(event: EventDocument): string {
  return event.organizerId ?? event.clubId;
}

/** Returns the correct organizer authority reference for an event. */
export function eventOrganizerRef(
  db: FirebaseFirestore.Firestore,
  event: EventDocument
): FirebaseFirestore.DocumentReference {
  return event.organizerId ?
    db.collection("organizers").doc(event.organizerId) :
    db.collection("clubs").doc(event.clubId);
}

/** Parses an event's organizer authority document. */
export function requireEventOrganizer(
  snap: FirebaseFirestore.DocumentSnapshot,
  event: EventDocument
): EventOrganizerDocument {
  if (!snap.exists) {
    throw new HttpsError("not-found", "Organizer not found.");
  }
  return event.organizerId ?
    requireDoc<OrganizerDocument>(snap, "OrganizerDocument") :
    requireDoc<ClubDocument>(snap, "ClubDocument");
}

/** Checks management privilege using canonical or compatibility authority. */
export function isEventOrganizerManager(
  organizer: EventOrganizerDocument,
  event: EventDocument,
  uid: string
): boolean {
  return event.organizerId ?
    isOrganizerManager(organizer as OrganizerDocument, uid) :
    isClubHost(organizer as ClubDocument, uid);
}
