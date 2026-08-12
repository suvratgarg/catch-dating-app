import {HttpsError} from "firebase-functions/v2/https";
import {ClubDocument, OrganizerDocument} from
  "./generated/firestoreAdminTypes";
import {isClubHost} from "./clubHosts";
import {isOrganizerManager} from "./organizerHosts";
import {requireDoc} from "./validation";

/** Requires canonical or compatibility organizer management authority. */
export async function requireOrganizerManager(params: {
  db: FirebaseFirestore.Firestore;
  organizerId: string;
  actorUid: string;
}): Promise<void> {
  const [organizerSnap, clubSnap] = await Promise.all([
    params.db.collection("organizers").doc(params.organizerId).get(),
    params.db.collection("clubs").doc(params.organizerId).get(),
  ]);
  if (!organizerSnap.exists && !clubSnap.exists) {
    throw new HttpsError("not-found", "Organizer not found.");
  }
  const authorized = organizerSnap.exists ? isOrganizerManager(
    requireDoc<OrganizerDocument>(organizerSnap, "OrganizerDocument"),
    params.actorUid
  ) : isClubHost(
    requireDoc<ClubDocument>(clubSnap, "ClubDocument"),
    params.actorUid
  );
  if (!authorized) {
    throw new HttpsError(
      "permission-denied",
      "Only organizer owners and managers can access this audience."
    );
  }
}
