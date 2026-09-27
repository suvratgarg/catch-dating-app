import type {OrganizerEventOfferPaymentDocument as Payment} from
  "../../shared/generated/firestoreAdminTypes";
import type {LoadRecipientAuth} from
  "../../organizerEventOfferRecipients/recipientGrant";
import {EventPaymentProcessor, type EventPaymentAuthority,
  type EventPaymentProcessorDeps} from "../eventCheckout/eventPaymentProcessor";
import {OFFER_PAYMENT_COLLECTION, parseOfferPayment} from
  "./offerPaymentReservation";
import {releaseOfferPaymentHold} from "./offerPaymentExpiry";
import {finalizeCapturedOfferPayment} from "./offerPaymentAdmission";
import {cancelPaidOfferForCancelledEvent} from "./offerPaymentCancellation";

export type OfferPaymentAuthority = EventPaymentAuthority;
export type OfferPaymentProcessorDeps = Omit<
  EventPaymentProcessorDeps<Payment>, "port"> & {
    loadCurrentAuthUser?: LoadRecipientAuth;
  };

/** Reviewed offers retain their own grant, approval and admission authority.
 * Only provider order/capture/refund mechanics are shared with open checkout.
 */
export class OfferPaymentProcessor extends EventPaymentProcessor<Payment> {
  constructor(deps: OfferPaymentProcessorDeps) {
    const {db, paymentId, loadCurrentAuthUser} = deps;
    super({...deps, port: {
      collection: OFFER_PAYMENT_COLLECTION,
      parse: parseOfferPayment,
      // Preserve already-used provider idempotency keys across the refactor.
      refundIdempotencyKey: `offer_refund_${paymentId}`,
      expire: (nowMillis) => releaseOfferPaymentHold({db, paymentId,
        nowMillis, reason: "expired"}),
      finalize: (nowMillis) => finalizeCapturedOfferPayment({db, paymentId,
        nowMillis, loadCurrentAuthUser}),
      cancelIfEventCancelled: (nowMillis) =>
        cancelPaidOfferForCancelledEvent({db, paymentId, nowMillis}),
    }});
  }
}
