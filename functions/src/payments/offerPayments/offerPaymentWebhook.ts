import {InvalidFormPaymentWebhook} from "../formPayments/formPaymentWebhook";
import type {FormPaymentOrder} from
  "../formPayments/razorpayPaymentProvider";
import {OFFER_PAYMENT_COLLECTION, parseOfferPayment} from
  "./offerPaymentReservation";
import type {OfferPaymentProcessor} from "./offerPaymentProcessor";
import {offerPaymentExecutionFor} from "./offerPaymentRuntime";

/** Called after authenticating the webhook and fetching its provider order.
 * The common receipt inbox serves both fees and offers; fulfillment stays owned
 * by each ledger. Account/order mismatch never invokes a money mutation.
 */
export async function processVerifiedOfferPaymentOrder(input: {
  db: FirebaseFirestore.Firestore; order: FormPaymentOrder;
  providerPaymentId: string; accountId: string; mode: "test" | "live";
  route: "razorpayRoute" | "razorpayOAuth";
  connectionId?: string; organizerId?: string;
}, execution: (input: {db: FirebaseFirestore.Firestore; paymentId: string}) =>
  Promise<Pick<OfferPaymentProcessor, "reconcile">> =
offerPaymentExecutionFor): Promise<boolean> {
  const {db, order} = input;
  if (!/^ep_[a-f0-9]{32}$/u.test(order.receipt)) return false;
  const snap = await db.collection(OFFER_PAYMENT_COLLECTION)
    .doc(order.receipt).get();
  if (!snap.exists) return false;
  const payment = parseOfferPayment(snap.data(), order.receipt);
  const routing = payment.routing;
  if (routing.selection.route !== input.route ||
      routing.selection.mode !== input.mode ||
      routing.merchantAccountId !== input.accountId ||
      input.route === "razorpayOAuth" &&
        (routing.bindingId !== input.connectionId ||
          payment.organizerId !== input.organizerId) ||
      payment.amountPaise !== order.amount ||
      payment.currency !== order.currency ||
      payment.providerOrderId && payment.providerOrderId !== order.id) {
    throw new InvalidFormPaymentWebhook("Offer payment webhook mismatch.");
  }
  const processor = await execution({db, paymentId: order.receipt});
  const updated = await processor.reconcile(input.providerPaymentId);
  if (!updated.providerOrderId ||
      ["creatingOrder", "orderUnknown"].includes(updated.status)) {
    throw new Error("Offer payment order recovery is pending.");
  }
  return true;
}
