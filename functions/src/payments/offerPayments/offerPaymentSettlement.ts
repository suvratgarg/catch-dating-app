import {reconcileEventPaymentSettlement} from
  "../eventCheckout/eventPaymentSettlement";
import {OFFER_PAYMENT_COLLECTION, parseOfferPayment} from
  "./offerPaymentReservation";
import {readPaidOfferAdmission} from "./offerPaymentAdmissionProof";

type Dependencies = Parameters<typeof reconcileEventPaymentSettlement>[1];

/** Route release still requires the reviewed offer's immutable paid proof. */
export async function reconcileOfferSettlement(input: {
  db: FirebaseFirestore.Firestore; paymentId: string;
}, deps?: Dependencies): Promise<void> {
  return reconcileEventPaymentSettlement({...input, ledger: {
    collection: OFFER_PAYMENT_COLLECTION, parse: parseOfferPayment,
  }, readAdmission: readPaidOfferAdmission}, deps);
}
