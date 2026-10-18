import {HttpsError} from "firebase-functions/v2/https";
import type {
  EventDocument,
  UserProfileDocument,
} from "../shared/generated/firestoreAdminTypes";
import {eventAgeRange} from "../shared/profileReadiness";

export function eventAgeEligibility(
  event: EventDocument,
  user: UserProfileDocument | undefined,
  now: Date
) {
  const range = eventAgeRange(event);
  if (!range) return null;
  const candidate =
    typeof user?.dateOfBirth?.toDate === "function" ?
      user.dateOfBirth.toDate() :
      undefined;
  const birth =
    candidate && Number.isFinite(candidate.getTime()) && candidate <= now ?
      candidate :
      undefined;
  let age = birth ? now.getUTCFullYear() - birth.getUTCFullYear() : null;
  if (
    age !== null &&
    birth &&
    (now.getUTCMonth() < birth.getUTCMonth() ||
      (now.getUTCMonth() === birth.getUTCMonth() &&
        now.getUTCDate() < birth.getUTCDate()))
  ) {
    age--;
  }
  return {
    ...range,
    needsDateOfBirth: !birth,
    eligible: age !== null && age >= range.minimum && age <= range.maximum,
  };
}

/** Recheck stored birth date in the reservation/admission transaction. */
export async function assertPublicEventAge(input: {
  db: FirebaseFirestore.Firestore;
  tx: FirebaseFirestore.Transaction;
  uid: string;
  event: EventDocument;
  nowMillis: number;
}): Promise<void> {
  if (!eventAgeRange(input.event)) return;
  const user = (
    await input.tx.get(input.db.collection("users").doc(input.uid))
  ).data() as UserProfileDocument | undefined;
  const eligibility = eventAgeEligibility(
    input.event,
    user,
    new Date(input.nowMillis)
  );
  if (!eligibility?.eligible) {
    throw new HttpsError(
      "failed-precondition",
      eligibility?.needsDateOfBirth ?
        "Add your date of birth for this age-restricted event." :
        "Your age does not meet this event's requirements."
    );
  }
}
