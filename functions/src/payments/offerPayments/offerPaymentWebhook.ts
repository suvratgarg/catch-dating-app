import {
  reconcileVerifiedEventOrder,
  type VerifiedEventPaymentOrder,
} from "../eventCheckout/eventPaymentWebhook";
import {
  OFFER_PAYMENT_COLLECTION,
  parseOfferPayment,
} from "./offerPaymentReservation";
import type {OfferPaymentProcessor} from "./offerPaymentProcessor";
import {offerPaymentExecutionFor} from "./offerPaymentRuntime";

export async function processVerifiedOfferPaymentOrder(
  input: VerifiedEventPaymentOrder,
  execution: (input: {
    db: FirebaseFirestore.Firestore;
    paymentId: string;
  }) => Promise<
    Pick<OfferPaymentProcessor, "reconcile">
  > = offerPaymentExecutionFor,
): Promise<boolean> {
  return reconcileVerifiedEventOrder(input, {
    pattern: /^ep_[a-f0-9]{32}$/u,
    ledger: {
      collection: OFFER_PAYMENT_COLLECTION,
      parse: parseOfferPayment,
    },
    execution,
  });
}
