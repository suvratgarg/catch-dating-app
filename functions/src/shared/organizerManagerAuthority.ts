import {HttpsError} from "firebase-functions/v2/https";
import type {OrganizerDocument} from "./generated/firestoreAdminTypes";
import {isOrganizerManager} from "./organizerHosts";
import {requireDoc} from "./validation";

/** Requires canonical organizer management authority. */
export async function requireOrganizerManager(params: {
  db: FirebaseFirestore.Firestore;
  organizerId: string;
  actorUid: string;
}): Promise<void> {
  const organizerSnap = await params.db.collection("organizers")
    .doc(params.organizerId).get();
  if (!organizerSnap.exists) {
    throw new HttpsError("not-found", "Organizer not found.");
  }
  const authorized = isOrganizerManager(
    requireDoc<OrganizerDocument>(organizerSnap, "OrganizerDocument"),
    params.actorUid
  );
  if (!authorized) {
    throw new HttpsError(
      "permission-denied",
      "Only organizer owners and managers can access this audience."
    );
  }
}
