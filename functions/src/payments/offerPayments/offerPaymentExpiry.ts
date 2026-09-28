import {HttpsError} from "firebase-functions/v2/https";
import {releaseEventPaymentHold} from "../eventCheckout/eventPaymentExpiry";
import {OFFER_PAYMENT_COLLECTION, parseOfferPayment} from
  "./offerPaymentReservation";

export async function releaseOfferPaymentHold(params: {
  db: FirebaseFirestore.Firestore; paymentId: string;
  reason: "expired" | "fulfillmentFailed"; nowMillis: number;
}): Promise<string> {
  if (!/^ep_[a-f0-9]{32}$/u.test(params.paymentId)) {
    throw new HttpsError("failed-precondition",
      "Payment inventory needs reconciliation.");
  }
  return releaseEventPaymentHold({...params, ledger: {
    collection: OFFER_PAYMENT_COLLECTION, parse: parseOfferPayment,
  }});
}
