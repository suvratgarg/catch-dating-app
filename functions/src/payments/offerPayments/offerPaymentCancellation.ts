import {Timestamp} from "firebase-admin/firestore";
import {HttpsError} from "firebase-functions/v2/https";
import {validateEventAttendeeDocument} from
  "../../shared/generated/validators/eventAttendeeDocument";
import {eventParticipationId} from "../../shared/relationshipDocuments";
import {formAdmissionOwnershipId} from
  "../../organizerFormAdmission/admissionService";
import {FirestoreSeatIdentityAuthority, SeatIdentityAuthorityError} from
  "../../events/seatIdentityAuthority";
import {readSeatMigrationWriterFence} from "../../events/seatMigrationPaged";
import {FirestoreSeatTransaction, assertCurrentReadySeatSnapshot} from
  "../../events/seatAuthority/firestoreAdapter";
import {prepareSeatCommand, applySeatPlan, SeatAuthorityError} from
  "../../events/seatAuthority/seatAuthority";
import {OFFER_PAYMENT_COLLECTION, parseOfferPayment} from
  "./offerPaymentReservation";
import {assertPaidOfferAdmission} from "./offerPaymentAdmissionProof";

function unavailable(): never {
  throw new HttpsError("failed-precondition",
    "Paid cancellation needs reconciliation.");
}

/** Trusted host-event cancellation consumer. The event is reread in the same
 * transaction as seat release and refund intent; it does not cancel an event
 * itself. The immutable admission receipt remains historical financial proof.
 * A live settlement lease is preserved for refund coordination, not bypassed.
 */
export async function cancelPaidOfferForCancelledEvent(input: {
  db: FirebaseFirestore.Firestore; paymentId: string; nowMillis: number;
}): Promise<boolean> {
  const {db, paymentId, nowMillis} = input;
  if (!Number.isSafeInteger(nowMillis) || nowMillis <= 0) unavailable();
  return db.runTransaction(async (tx) => {
    const ref = db.collection(OFFER_PAYMENT_COLLECTION).doc(paymentId);
    const payment = parseOfferPayment((await tx.get(ref)).data(), paymentId);
    if (payment.cancellation) return true;
    if (!payment.admissionReceiptId || payment.status !== "admitted") {
      return false;
    }
    const {eventId, organizerId, responseId, recipientUid} = payment;
    const eventRef = db.collection("events").doc(eventId);
    const event = (await tx.get(eventRef)).data();
    if (event?.status !== "cancelled") return false;
    const [receiptSnap, ownershipSnap, participationSnap] =
      await Promise.all([
        tx.get(db.collection("organizerFormAdmissionReceipts")
          .doc(payment.admissionReceiptId)),
        tx.get(db.collection("organizerFormAdmissions").doc(
          formAdmissionOwnershipId(organizerId, eventId, responseId))),
        tx.get(db.collection("eventParticipations")
          .doc(eventParticipationId(eventId, recipientUid))),
      ]);
    if ((event.organizerId ?? event.clubId) !== organizerId ||
        payment.refundedAmountPaise !== 0 || !payment.providerPaymentId ||
        !payment.providerOrderId) unavailable();
    const {receipt} = assertPaidOfferAdmission({payment, paymentId,
      receipt: receiptSnap.data(), ownership: ownershipSnap.data()});
    const attendeeRef = db.collection("eventAttendees").doc(receipt.attendeeId);
    const attendee = (await tx.get(attendeeRef)).data();
    if (!validateEventAttendeeDocument(attendee) ||
        attendee.eventId !== eventId || attendee.organizerId !== organizerId ||
        attendee.linkedUid !== recipientUid ||
        !["registered", "checkedIn"].includes(attendee.status) ||
        attendee.revenueOrderReference !== payment.providerOrderId ||
        attendee.revenueAmountMinor !== payment.amountPaise) {
      unavailable();
    }
    const fenceMode = await readSeatMigrationWriterFence({db, tx, eventId})
      .catch(async (error) => {
        if (error instanceof HttpsError &&
            error.code === "failed-precondition") {
          const fence = (await tx.get(db.collection("eventSeatMigrationFences")
            .doc(eventId))).data();
          if (fence?.eventId === eventId && fence.state === "locked") {
            throw new HttpsError("unavailable",
              "Paid cancellation is waiting for seat migration.");
          }
        }
        throw error;
      });
    if (fenceMode !== "ready") unavailable();
    const identity = await new FirestoreSeatIdentityAuthority().resolve({
      db, tx, eventId, organizerId,
      subject: {kind: "importAttendee", attendeeId: receipt.attendeeId}});
    if (!identity || identity.key !== payment.canonicalSeatKey) unavailable();
    const seatTx = new FirestoreSeatTransaction(db, tx);
    const [ledger, reservation] = await Promise.all([
      seatTx.ledger(eventId), seatTx.reservation(eventId, identity.key),
    ]);
    assertCurrentReadySeatSnapshot({event, eventId, organizerId, identity,
      ledger, reservation, expectedActive: true});
    if (!ledger || !reservation || reservation.checkoutHold) unavailable();
    const participation = participationSnap.data();
    // Preserve an independent Catch booking's attribution to the shared seat.
    // Its cancellation is owned by that booking flow, not this paid admission.
    const seatRetained = !!participation &&
      ["signedUp", "attended"].includes(participation.status);
    if (seatRetained && (participation?.eventId !== eventId ||
        participation?.uid !== recipientUid ||
        (participation?.organizerId ?? participation?.clubId) !==
          organizerId)) {
      unavailable();
    }
    const release = seatRetained ? null : await prepareSeatCommand({
      tx: seatTx, command: {eventId, subject: identity, operation: "release",
        requestId: `cancel_paid_${paymentId}`,
        expectedLedgerRevision: ledger.revision,
        expectedCapacityRevision: ledger.capacityRevision,
        expectedMigrationRevision: ledger.migrationRevision,
        expectedReservationRevision: reservation.revision, nowMillis},
      resolveIdentity: async () => identity});
    const now = Timestamp.fromMillis(nowMillis);
    if (release) {
      applySeatPlan(seatTx, release);
      tx.update(eventRef, {bookedCount: ledger.occupied - 1});
    }
    tx.update(attendeeRef, {status: "cancelled", cancelledAt: now,
      preCheckInStatus: null, updatedAt: now});
    tx.update(ref, {status: "refundPending", reservationReleased: true,
      cancellation: {reason: "eventCancelled", requestedAtMillis: nowMillis,
        attendeeId: receipt.attendeeId, refundAmountPaise: payment.amountPaise,
        seatRetained},
      updatedAt: now, lastErrorCode: null});
    return true;
  }).catch((error) => {
    if (error instanceof SeatAuthorityError ||
        error instanceof SeatIdentityAuthorityError) unavailable();
    throw error;
  });
}
