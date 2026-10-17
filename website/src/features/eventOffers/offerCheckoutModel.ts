import {record, integer, matches, keys, policy, validEventPayment} from "../../shared/payments/eventPaymentValidation";
import {eventOfferCopy, offerPaymentCopy} from "../../content/eventOffer";
import type {EventOfferCheckoutResponse as Response} from "../../firebase";
export type OfferGrant = NonNullable<Response["grant"]>;
export type OfferPayment = NonNullable<Response["payment"]>;

export const paymentCopy = (payment: OfferPayment) =>
  offerPaymentCopy(payment.status, payment.checkout !== null, payment.cancellationReason);
export function formatOfferAmount(amountPaise: number) {
  return new Intl.NumberFormat("en-IN", {style: "currency", currency: "INR"}).format(amountPaise / 100);
}
export function assertOfferResponse(value: unknown): Response {
  const invalid = () => {throw new Error(eventOfferCopy.responseError);};
  if (!record(value) || !keys(value, ["grant", "payment", "serverTimeMillis", ...(value.admission ? ["admission"] : [])]) ||
      !integer(value.serverTimeMillis) || value.grant && value.payment) return invalid();
  const grant = value.grant;
  if (grant !== null && (!record(grant) || !keys(grant, ["grantId", "eventName", "eventId",
    "startTimeMillis", "amountPaise", "currency", "expiresAtMillis", "cancellationPolicy",
    ...(grant.freeAdmission ? ["freeAdmission"] : [])]) ||
    !matches(grant.grantId, /^[a-f0-9]{64}$/u) ||
    !matches(grant.eventId, /^[A-Za-z0-9_:-]{1,180}$/u) ||
    typeof grant.eventName !== "string" || !grant.eventName || grant.eventName.length > 200 ||
    !integer(grant.startTimeMillis) || !integer(grant.expiresAtMillis) ||
    !integer(grant.amountPaise, 0) || grant.amountPaise > 100_000_000 ||
    grant.amountPaise > 0 && grant.amountPaise < 100 ||
    !policy(grant.cancellationPolicy) ||
    (grant.cancellationPolicy as OfferGrant["cancellationPolicy"]).eventStartsAtMillis !== grant.startTimeMillis ||
    grant.currency !== "INR")) return invalid();
  if (record(grant)) {
    const free = grant.freeAdmission;
    if (grant.amountPaise === 0 ? !record(free) ||
        !keys(free, ["expectedOfferGeneration", "expectedOfferRevision", "expectedLedgerRevision"]) ||
        !Object.values(free).every((revision) => integer(revision)) :
        free !== undefined) return invalid();
  }
  const admission = value.admission;
  if (admission !== undefined && (!record(admission) || value.grant || value.payment ||
      !keys(admission, ["eventId", "attendeeId"]) ||
      !matches(admission.eventId, /^[A-Za-z0-9_:-]{1,180}$/u) ||
      !matches(admission.attendeeId, /^[A-Za-z0-9_:-]{1,180}$/u))) return invalid();
  const payment = value.payment;
  const paymentEventId = record(payment) ? payment.eventId : undefined;
  if (paymentEventId !== undefined && !matches(paymentEventId, /^[A-Za-z0-9_:-]{1,180}$/u)) return invalid();
  if (!validEventPayment(payment, "ep", paymentEventId === undefined ? [] : ["eventId"])) return invalid();
  return value as unknown as Response;
}
