const statuses = new Set([
  "creatingOrder",
  "orderUnknown",
  "checkoutReady",
  "verifying",
  "captured",
  "admitted",
  "cancelled",
  "expired",
  "refundPending",
  "refunded",
  "reviewRequired",
  "failed",
]);
export const record = (value: unknown): value is Record<string, unknown> =>
  !!value && typeof value === "object" && !Array.isArray(value);
export const integer = (value: unknown, minimum = 1): value is number =>
  typeof value === "number" && Number.isSafeInteger(value) && value >= minimum;
export const matches = (value: unknown, pattern: RegExp): value is string =>
  typeof value === "string" && pattern.test(value);
export function keys(value: Record<string, unknown>, expected: string[]) {
  return (
    Object.keys(value).length === expected.length &&
    expected.every((key) => key in value)
  );
}
export function policy(value: unknown): boolean {
  return (
    record(value) &&
    keys(value, ["refundDeadlineMillis", "eventStartsAtMillis"]) &&
    integer(value.refundDeadlineMillis, 0) &&
    integer(value.eventStartsAtMillis) &&
    value.refundDeadlineMillis <= value.eventStartsAtMillis
  );
}
export function validEventPayment(
  payment: unknown,
  prefix: "ep" | "pp",
  extraKeys: string[] = [],
): boolean {
  if (payment !== null) {
    if (
      !record(payment) ||
      !keys(payment, [
        "paymentId",
        "status",
        "amountPaise",
        "currency",
        "mode",
        "refundedAmountPaise",
        "expiresAtMillis",
        "checkout",
        "cancellationReason",
        "cancellationPolicy",
        "cancellationQuote",
        ...extraKeys,
      ]) ||
      !matches(
        payment.paymentId,
        new RegExp(`^${prefix}_[a-f0-9]{32}$`, "u"),
      ) ||
      typeof payment.status !== "string" ||
      !statuses.has(payment.status) ||
      !integer(payment.amountPaise, 100) ||
      payment.amountPaise > 100_000_000 ||
      payment.currency !== "INR" ||
      !["test", "live"].includes(String(payment.mode)) ||
      !integer(payment.refundedAmountPaise, 0) ||
      payment.refundedAmountPaise > payment.amountPaise ||
      ![null, "eventCancelled", "guestCancelled"].includes(
        payment.cancellationReason as null | string,
      ) ||
      (payment.cancellationReason !== null &&
        !["cancelled", "refundPending", "refunded", "reviewRequired"].includes(
          String(payment.status),
        )) ||
      !integer(payment.expiresAtMillis)
    )
      return false;
    if (
      payment.cancellationPolicy !== null &&
      !policy(payment.cancellationPolicy)
    )
      return false;
    if (
      payment.status === "cancelled" &&
      (payment.cancellationReason !== "guestCancelled" ||
        payment.refundedAmountPaise !== 0 ||
        payment.checkout !== null)
    )
      return false;
    const quote = payment.cancellationQuote;
    if (
      quote !== null &&
      (!record(quote) ||
        !keys(quote, ["refundAmountPaise"]) ||
        ![0, payment.amountPaise].includes(quote.refundAmountPaise as number) ||
        payment.status !== "admitted" ||
        payment.cancellationReason !== null ||
        payment.cancellationPolicy === null ||
        payment.refundedAmountPaise !== 0)
    )
      return false;
    const checkout = payment.checkout;
    if (
      checkout !== null &&
      (!record(checkout) ||
        !keys(checkout, [
          "publicToken",
          "orderId",
          "amountPaise",
          "currency",
          "description",
          "expiresAtMillis",
        ]) ||
        !["checkoutReady", "failed"].includes(payment.status) ||
        !matches(
          checkout.publicToken,
          /^rzp_(test|live)_[A-Za-z0-9_-]{1,490}$/u,
        ) ||
        !checkout.publicToken.startsWith(`rzp_${payment.mode}_`) ||
        !matches(checkout.orderId, /^order_[A-Za-z0-9]+$/u) ||
        checkout.amountPaise !== payment.amountPaise ||
        checkout.currency !== "INR" ||
        checkout.expiresAtMillis !== payment.expiresAtMillis ||
        typeof checkout.description !== "string" ||
        checkout.description.length > 200)
    )
      return false;
  }
  return true;
}
