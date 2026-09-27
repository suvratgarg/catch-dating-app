import {cancelPaidEventAdmission} from
  "../eventCheckout/eventPaymentCancellation";
import {OFFER_PAYMENT_COLLECTION, parseOfferPayment} from
  "./offerPaymentReservation";
import {readPaidOfferAdmission} from "./offerPaymentAdmissionProof";

/** Reviewed-offer proof remains mandatory for all cancellation/replay paths. */
export async function cancelPaidOfferForCancelledEvent(input: {
  db: FirebaseFirestore.Firestore; paymentId: string; nowMillis: number;
  guest?: {uid: string; expectedRefundAmountPaise: number};
}): Promise<boolean> {
  return cancelPaidEventAdmission({...input, ledger: {
    collection: OFFER_PAYMENT_COLLECTION, parse: parseOfferPayment,
  }, readAdmission: readPaidOfferAdmission});
}
