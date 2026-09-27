import {HttpsError} from "firebase-functions/v2/https";
import type {OrganizerEventOfferPaymentDocument as Payment} from
  "../../shared/generated/firestoreAdminTypes";
import type {ManageEventOfferCheckoutCallableResponse as Response} from
  "../../shared/generated/manageEventOfferCheckoutCallableResponse";
import {readVerifiedOfferRecipient} from
  "../../organizerEventOfferRecipients/recipientGrant";
import {assertRazorpayCollectionBindingReady} from
  "../razorpayCollectionRouting";

/** Account-owned financial history remains readable after invitation expiry. */
export async function projectOfferPayment(input: {
  db: FirebaseFirestore.Firestore; paymentId: string; payment: Payment;
  uid: string; nowMillis: number;
}): Promise<NonNullable<Response["payment"]>> {
  const {db, paymentId, payment, uid, nowMillis} = input;
  if (payment.recipientUid !== uid) {
    throw new HttpsError("permission-denied", "Payment unavailable.");
  }
  let checkout: NonNullable<Response["payment"]>["checkout"] = null;
  if (["checkoutReady", "failed"].includes(payment.status) &&
      !payment.capturedAt && !payment.admissionReceiptId &&
      !payment.reservationReleased && payment.providerOrderId &&
      typeof payment.routing.checkoutKey === "string" &&
      payment.checkoutExpiresAt.toMillis() > nowMillis) {
    try {
      await db.runTransaction(async (tx) => {
        await readVerifiedOfferRecipient({db, tx, grantId: payment.grantId,
          uid, nowMillis});
        await assertRazorpayCollectionBindingReady({db, tx,
          snapshot: payment.routing, nowMillis});
      });
      checkout = {publicToken: payment.routing.checkoutKey,
        orderId: payment.providerOrderId, amountPaise: payment.amountPaise,
        currency: "INR", description: "Event admission",
        expiresAtMillis: payment.checkoutExpiresAt.toMillis()};
    } catch (error) {
      if (!(error instanceof HttpsError) ||
          !["failed-precondition", "permission-denied"].includes(error.code)) {
        throw error;
      }
    }
  }
  return {paymentId, status: payment.status, amountPaise: payment.amountPaise,
    currency: "INR", mode: payment.routing.selection.mode,
    refundedAmountPaise: payment.refundedAmountPaise,
    cancellationReason: payment.cancellation?.reason ?? null,
    expiresAtMillis: payment.checkoutExpiresAt.toMillis(), checkout};
}
