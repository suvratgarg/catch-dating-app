import {HttpsError} from "firebase-functions/v2/https";
import type {EventDocument, OrganizerEventOfferPaymentDocument as Payment}
  from "../../shared/generated/firestoreAdminTypes";
import {fullRefundDeadlineMillis} from
  "../../events/eventPolicy";

export type OfferCancellationPolicy = {
  refundDeadlineMillis: number; eventStartsAtMillis: number;
};

/** Cash-only terms for this release. Existing credit remedies are not promised
 * by this checkout. Freeze the cash deadline before a seat hold or provider
 * I/O.
 */
export function offerCancellationPolicy(event: EventDocument):
  OfferCancellationPolicy {
  const eventStartsAtMillis = event.startTime.toMillis();
  // A paid offer has its own price snapshot. A minimal private event or an
  // external companion may have no paid canonical policy. Use the displayed
  // standard cash deadline without rewriting its provenance or base price.
  const configured = event.eventPolicy?.cancellation?.policyId;
  const policyId = !configured || configured === "notApplicable" ?
    "standard" : configured;
  if (!["flexible", "standard", "strict"].includes(policyId)) {
    throw new HttpsError("failed-precondition", "Invalid cancellation policy.");
  }
  return {refundDeadlineMillis: fullRefundDeadlineMillis(policyId,
    eventStartsAtMillis), eventStartsAtMillis};
}

export function assertReviewedCancellationPolicy(
  reviewed: OfferCancellationPolicy | undefined,
  current: OfferCancellationPolicy
): void {
  if (!reviewed || reviewed.refundDeadlineMillis !==
      current.refundDeadlineMillis || reviewed.eventStartsAtMillis !==
      current.eventStartsAtMillis) {
    throw new HttpsError("failed-precondition",
      "Cancellation terms changed. Reopen and review your invitation.");
  }
}

export function offerGuestCancellationQuote(payment: Payment, now: number):
  {refundAmountPaise: number} | null {
  const policy = payment.cancellationPolicy;
  if (!Number.isSafeInteger(now) || now <= 0 || !policy ||
      payment.status !== "admitted" || payment.cancellation ||
      payment.refundedAmountPaise !== 0 ||
      now >= policy.eventStartsAtMillis) return null;
  return {refundAmountPaise: now <= policy.refundDeadlineMillis ?
    payment.amountPaise : 0};
}
