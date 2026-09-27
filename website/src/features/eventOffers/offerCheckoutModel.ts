import {eventOfferCopy, offerPaymentCopy} from "../../content/eventOffer";
import type {EventOfferCheckoutResponse as Response} from "../../firebase";
export type OfferGrant = NonNullable<Response["grant"]>;
export type OfferPayment = NonNullable<Response["payment"]>;

export const paymentCopy = (payment: OfferPayment) =>
  offerPaymentCopy(payment.status, payment.checkout !== null);
export function formatOfferAmount(amountPaise: number) {
  return new Intl.NumberFormat("en-IN", {style: "currency", currency: "INR"}).format(amountPaise / 100);
}
const statuses = new Set(["creatingOrder", "orderUnknown", "checkoutReady", "verifying",
  "captured", "admitted", "expired", "refundPending", "refunded", "reviewRequired", "failed"]);
const record = (value: unknown): value is Record<string, unknown> =>
  !!value && typeof value === "object" && !Array.isArray(value);
const integer = (value: unknown, minimum = 1): value is number =>
  typeof value === "number" && Number.isSafeInteger(value) && value >= minimum;
const matches = (value: unknown, pattern: RegExp): value is string =>
  typeof value === "string" && pattern.test(value);
function keys(value: Record<string, unknown>, expected: string[]) {
  return Object.keys(value).length === expected.length && expected.every((key) => key in value);
}
export function assertOfferResponse(value: unknown): Response {
  const invalid = () => {throw new Error(eventOfferCopy.responseError);};
  if (!record(value) || !keys(value, ["grant", "payment", "serverTimeMillis"]) ||
      !integer(value.serverTimeMillis) || value.grant && value.payment) return invalid();
  const grant = value.grant;
  if (grant !== null && (!record(grant) || !keys(grant, ["grantId", "eventName", "eventId",
    "startTimeMillis", "amountPaise", "currency", "expiresAtMillis"]) ||
    !matches(grant.grantId, /^[a-f0-9]{64}$/u) ||
    !matches(grant.eventId, /^[A-Za-z0-9_:-]{1,180}$/u) ||
    typeof grant.eventName !== "string" || !grant.eventName || grant.eventName.length > 200 ||
    !integer(grant.startTimeMillis) || !integer(grant.expiresAtMillis) ||
    !integer(grant.amountPaise, 100) || grant.amountPaise > 100_000_000 ||
    grant.currency !== "INR")) return invalid();
  const payment = value.payment;
  if (payment !== null) {
    if (!record(payment) || !keys(payment, ["paymentId", "status", "amountPaise", "currency",
      "mode", "refundedAmountPaise", "expiresAtMillis", "checkout"]) ||
      !matches(payment.paymentId, /^ep_[a-f0-9]{32}$/u) ||
      typeof payment.status !== "string" || !statuses.has(payment.status) ||
      !integer(payment.amountPaise, 100) || payment.amountPaise > 100_000_000 ||
      payment.currency !== "INR" || !["test", "live"].includes(String(payment.mode)) ||
      !integer(payment.refundedAmountPaise, 0) || payment.refundedAmountPaise > payment.amountPaise ||
      !integer(payment.expiresAtMillis)) return invalid();
    const checkout = payment.checkout;
    if (checkout !== null && (!record(checkout) || !keys(checkout, ["publicToken", "orderId",
      "amountPaise", "currency", "description", "expiresAtMillis"]) ||
      !["checkoutReady", "failed"].includes(payment.status) ||
      !matches(checkout.publicToken, /^rzp_(test|live)_[A-Za-z0-9_-]{1,490}$/u) ||
      !checkout.publicToken.startsWith(`rzp_${payment.mode}_`) ||
      !matches(checkout.orderId, /^order_[A-Za-z0-9]+$/u) ||
      checkout.amountPaise !== payment.amountPaise || checkout.currency !== "INR" ||
      checkout.expiresAtMillis !== payment.expiresAtMillis ||
      typeof checkout.description !== "string" || checkout.description.length > 200)) return invalid();
  }
  return value as unknown as Response;
}
