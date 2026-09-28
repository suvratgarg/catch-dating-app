import type {LoadRecipientAuth} from
  "../../organizerEventOfferRecipients/recipientGrant";
import {HttpsError} from "firebase-functions/v2/https";
import type {PublicEventPaymentDocument as Payment} from
  "../../shared/generated/firestoreAdminTypes";
import type {ManagePublicEventCheckoutCallableResponse as Response} from
  "../../shared/generated/managePublicEventCheckoutCallableResponse";
import {assertRazorpayCollectionBindingReady} from
  "../../payments/razorpayCollectionRouting";
import {eventGuestCancellationQuote} from
  "../../payments/eventCheckout/eventCancellationPolicy";
import {
  assertCurrentPublicGuest,
  readPublicEventSource,
} from "./authority";
import {assertPublicRegistrationPolicy} from "./policy";
import {readPublicPaidAdmission} from "./admissionProof";
import {
  PUBLIC_PAYMENT_COLLECTION,
  parsePublicPayment,
} from "./paymentLedger";

/** Read a current, UID-owned view. No merchant IDs, routing secrets, phone or
 * other guest records leave the callable. Ended payment history stays readable.
 */
export async function projectPublicPayment(input: {
  db: FirebaseFirestore.Firestore;
  paymentId: string;
  uid: string;
  nowMillis: number;
  loadCurrentAuthUser?: LoadRecipientAuth;
}): Promise<Pick<Response, "payment" | "admission">> {
  const {db, paymentId, uid, nowMillis} = input;
  return db.runTransaction(async (tx) => {
    const p = parsePublicPayment(
      (
        await tx.get(
          db.collection(PUBLIC_PAYMENT_COLLECTION).doc(paymentId),
        )
      ).data(),
      paymentId,
    );
    if (p.recipientUid !== uid) {
      throw new HttpsError("permission-denied", "Payment unavailable.");
    }
    let checkout: NonNullable<Response["payment"]>["checkout"] = null;
    let admission: Response["admission"] = null;
    if (
      ["checkoutReady", "failed"].includes(p.status) &&
      !p.capturedAt &&
      !p.admissionReceiptId &&
      !p.reservationReleased &&
      p.providerOrderId &&
      p.routing.checkoutKey &&
      p.checkoutExpiresAt.toMillis() > nowMillis
    ) {
      try {
        await assertCurrentPublicGuest({
          db,
          tx,
          uid,
          phoneE164: p.phoneE164,
          loadCurrentAuthUser: input.loadCurrentAuthUser,
        });
        const {event, organizer} = await readPublicEventSource({
          db,
          tx,
          eventId: p.eventId,
        });
        assertPublicRegistrationPolicy(event, organizer, "paid", nowMillis);
        if (
          event.startTime.toMillis() ===
          p.cancellationPolicy.eventStartsAtMillis
        ) {
          await assertRazorpayCollectionBindingReady({
            db,
            tx,
            snapshot: p.routing,
            nowMillis,
          });
          checkout = {
            publicToken: p.routing.checkoutKey,
            orderId: p.providerOrderId,
            amountPaise: p.amountPaise,
            currency: p.currency,
            description: p.eventName,
            expiresAtMillis: p.checkoutExpiresAt.toMillis(),
          };
        }
      } catch (error) {
        if (
          !(error instanceof HttpsError) ||
          ![
            "permission-denied",
            "failed-precondition",
            "not-found",
          ].includes(error.code)
        ) {
          throw error;
        }
      }
    }
    let cancellationQuote = eventGuestCancellationQuote(p, nowMillis);
    if (p.status === "admitted") {
      const proof = await readPublicPaidAdmission({
        db,
        tx,
        payment: p,
        paymentId,
      });
      const [event, attendee] = await Promise.all([
        tx.get(db.collection("events").doc(p.eventId)),
        tx.get(db.collection("eventAttendees").doc(proof.attendeeId)),
      ]);
      const row = attendee.data();
      if (
        row?.eventId === p.eventId &&
        row.organizerId === p.organizerId &&
        row.linkedUid === uid &&
        ["registered", "checkedIn"].includes(row.status) &&
        row.revenueOrderReference === p.providerOrderId
      ) {
        admission = {
          eventId: p.eventId,
          attendeeId: proof.attendeeId,
          status: row.status,
        };
      }
      if (
        !admission ||
        row?.status !== "registered" ||
        event.data()?.status !== "active" ||
        !(event.data()?.startTime?.toMillis?.() > nowMillis)
      ) {
        cancellationQuote = null;
      }
    }
    return {
      payment: paymentProjection(p, paymentId, checkout, cancellationQuote),
      admission,
    };
  });
}

function paymentProjection(
  p: Payment,
  paymentId: string,
  checkout: NonNullable<Response["payment"]>["checkout"],
  cancellationQuote: NonNullable<Response["payment"]>["cancellationQuote"],
): NonNullable<Response["payment"]> {
  return {
    paymentId,
    status: p.status,
    amountPaise: p.amountPaise,
    currency: p.currency,
    mode: p.routing.selection.mode,
    refundedAmountPaise: p.refundedAmountPaise,
    cancellationReason: p.cancellation?.reason ?? null,
    cancellationPolicy: p.cancellationPolicy,
    cancellationQuote,
    expiresAtMillis: p.checkoutExpiresAt.toMillis(),
    checkout,
    eventId: p.eventId,
    eventName: p.eventName,
    startTimeMillis: p.cancellationPolicy.eventStartsAtMillis,
  };
}
