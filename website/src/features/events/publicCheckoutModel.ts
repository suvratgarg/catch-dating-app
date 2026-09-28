import type { ManagePublicEventCheckoutCallableResponse as Response } from "../../shared/contracts/generated/managePublicEventCheckoutCallableResponse";
import {
  record,
  integer,
  matches,
  keys,
  policy,
  validEventPayment,
} from "../../shared/payments/eventPaymentValidation";
export type PublicQuote = NonNullable<Response["quote"]>;
export type PublicPayment = NonNullable<Response["payment"]>;
export type PublicAdmission = NonNullable<Response["admission"]>;
const eventIdValid = (value: unknown) =>
  matches(value, /^[A-Za-z0-9_:-]{1,180}$/u);
function eventFacts(value: Record<string, unknown>) {
  return (
    eventIdValid(value.eventId) &&
    typeof value.eventName === "string" &&
    value.eventName.length > 0 &&
    value.eventName.length <= 200 &&
    integer(value.startTimeMillis)
  );
}
export function assertPublicCheckoutResponse(
  value: unknown,
  eventId: string,
  paymentId?: string,
): Response {
  const invalid = () => {
    throw new Error("Invalid event checkout response");
  };
  if (
    !record(value) ||
    !keys(value, ["quote", "payment", "admission", "serverTimeMillis"]) ||
    !integer(value.serverTimeMillis) ||
    (value.quote && (value.payment || value.admission))
  )
    return invalid();
  const quote = value.quote;
  if (
    quote !== null &&
    (!record(quote) ||
      !keys(quote, [
        "eventId",
        "eventName",
        "registrationRevision",
        "startTimeMillis",
        "amountPaise",
        "currency",
        "cancellationPolicy",
      ]) ||
      !eventFacts(quote) ||
      quote.eventId !== eventId ||
      !integer(quote.registrationRevision, 0) ||
      !integer(quote.amountPaise, 100) ||
      quote.amountPaise > 100_000_000 ||
      quote.currency !== "INR" ||
      !policy(quote.cancellationPolicy) ||
      (quote.cancellationPolicy as PublicQuote["cancellationPolicy"])
        .eventStartsAtMillis !== quote.startTimeMillis)
  )
    return invalid();
  const payment = value.payment;
  if (
    !validEventPayment(payment, "pp", [
      "eventId",
      "eventName",
      "startTimeMillis",
    ])
  )
    return invalid();
  if (
    payment !== null &&
    (!record(payment) ||
      !eventFacts(payment) ||
      payment.eventId !== eventId ||
      (paymentId && payment.paymentId !== paymentId) ||
      (payment.cancellationPolicy &&
        (payment.cancellationPolicy as PublicQuote["cancellationPolicy"])
          .eventStartsAtMillis !== payment.startTimeMillis))
  )
    return invalid();
  const admission = value.admission;
  if (
    admission !== null &&
    (!record(admission) ||
      !keys(admission, ["eventId", "attendeeId", "status"]) ||
      admission.eventId !== eventId ||
      !eventIdValid(admission.attendeeId) ||
      !["registered", "checkedIn"].includes(String(admission.status)) ||
      (payment !== null && (payment as PublicPayment).status !== "admitted"))
  )
    return invalid();
  return value as unknown as Response;
}
