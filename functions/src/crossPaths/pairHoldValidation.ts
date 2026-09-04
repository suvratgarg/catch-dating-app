import {HttpsError} from "firebase-functions/v2/https";
import type {CrossPathsPairHoldDocument} from
  "../shared/generated/firestoreAdminTypes";
import {requireDoc} from "../shared/validation";

export async function requireActiveCrossPathsPairHold(params: {
  db: FirebaseFirestore.Firestore;
  holdId: string;
  eventId: string;
  requesterUid: string;
  nowMillis?: number;
}): Promise<CrossPathsPairHoldDocument> {
  const snap = await params.db.collection("crossPathsPairHolds")
    .doc(params.holdId).get();
  if (!snap.exists) throw unavailable();
  const hold = requireDoc<CrossPathsPairHoldDocument>(
    snap,
    "CrossPathsPairHoldDocument (payment preflight)"
  );
  if (
    hold.eventId !== params.eventId ||
    hold.requesterUid !== params.requesterUid ||
    hold.status !== "active" ||
    hold.requesterBookingStatus !== "held" ||
    hold.expiresAt.toMillis() <= (params.nowMillis ?? Date.now())
  ) {
    throw unavailable();
  }
  return hold;
}

function unavailable(): HttpsError {
  return new HttpsError(
    "failed-precondition",
    "This Cross Paths hold is no longer available."
  );
}
