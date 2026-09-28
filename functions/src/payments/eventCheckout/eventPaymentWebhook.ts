import {InvalidFormPaymentWebhook} from "../formPayments/formPaymentWebhook";
import type {FormPaymentOrder} from "../formPayments/razorpayPaymentProvider";
import type {
  EventPaymentLedger,
  EventSeatPaymentState,
} from "./eventPaymentState";

export interface VerifiedEventPaymentOrder {
  db: FirebaseFirestore.Firestore;
  order: FormPaymentOrder;
  providerPaymentId: string;
  accountId: string;
  mode: "test" | "live";
  route: "razorpayRoute" | "razorpayOAuth";
  connectionId?: string;
  organizerId?: string;
}

/** Called only after signature/account authentication and a fetched provider
 * order. Source prefixes select a ledger; they never establish payment proof.
 */
export async function reconcileVerifiedEventOrder<
  P extends EventSeatPaymentState,
>(
  input: VerifiedEventPaymentOrder,
  deps: {
    pattern: RegExp;
    ledger: EventPaymentLedger<P>;
    execution: (input: {
      db: FirebaseFirestore.Firestore;
      paymentId: string;
    }) => Promise<{ reconcile: (id: string) => Promise<P> }>;
  },
): Promise<boolean> {
  const {db, order} = input;
  if (!deps.pattern.test(order.receipt)) return false;
  const snap = await db
    .collection(deps.ledger.collection)
    .doc(order.receipt)
    .get();
  if (!snap.exists) return false;
  const payment = deps.ledger.parse(snap.data(), order.receipt);
  const routing = payment.routing;
  if (
    routing.selection.route !== input.route ||
    routing.selection.mode !== input.mode ||
    routing.merchantAccountId !== input.accountId ||
    (input.route === "razorpayOAuth" &&
      (routing.bindingId !== input.connectionId ||
        payment.organizerId !== input.organizerId)) ||
    payment.amountPaise !== order.amount ||
    payment.currency !== order.currency ||
    (payment.providerOrderId && payment.providerOrderId !== order.id)
  ) {
    throw new InvalidFormPaymentWebhook("Event payment webhook mismatch.");
  }
  const processor = await deps.execution({db, paymentId: order.receipt});
  const updated = await processor.reconcile(input.providerPaymentId);
  if (
    !updated.providerOrderId ||
    ["creatingOrder", "orderUnknown"].includes(updated.status)
  ) {
    throw new Error("Event payment order recovery is pending.");
  }
  return true;
}
