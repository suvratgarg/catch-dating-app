import {HttpsError} from "firebase-functions/v2/https";
import {validateEventDocument} from
  "../../shared/generated/validators/eventDocument";

const eventIdPattern = /^[A-Za-z0-9][A-Za-z0-9_-]{0,119}$/;

/** Existing downstream records that make a basics move unsafe. */
const commitmentCollections = [
  "eventAttendees",
  "eventAttendeeImports",
  "eventParticipations",
  "eventWaitlistOffers",
  "organizerEventOffers",
  "payments",
  "razorpayPendingOrders",
] as const;

/**
 * Call inside the same transaction that read and will update events/{id}.
 * A row of any lifecycle status is a commitment: a withdrawal, refund or
 * historical import must not make the previous date/city context disappear.
 */
export async function assertPrivateEventBasicsEditable(params: {
  tx: FirebaseFirestore.Transaction;
  db: FirebaseFirestore.Firestore;
  eventId: string;
  event: Record<string, unknown>;
}): Promise<void> {
  const {tx, db, eventId, event} = params;
  if (!eventIdPattern.test(eventId) ||
      !validateEventDocument(event) ||
      event.publicationState !== "private" ||
      event.publicRegistrationEnabled !== false ||
      event.status !== "active" ||
      event.clubId !== event.organizerId ||
      event.eventOrigin !== undefined ||
      !Number.isSafeInteger(event.setupRevision) ||
      Number(event.setupRevision) < 1 ||
      event.bookedCount !== 0 || event.checkedInCount !== 0 ||
      event.waitlistedCount !== 0) {
    throw new HttpsError("failed-precondition",
      "Event basics are no longer an uncommitted private setup.");
  }

  // Every query is an equality on the canonical eventId field and reads at
  // most one document. No lifecycle-status filter can hide prior commitments.
  for (const collection of commitmentCollections) {
    const witness = await tx.get(db.collection(collection)
      .where("eventId", "==", eventId).limit(1));
    if (!witness.empty) {
      throw new HttpsError("failed-precondition",
        "This event has roster, offer or payment commitments.");
    }
  }
}
