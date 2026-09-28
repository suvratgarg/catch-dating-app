import type {PaymentDocument} from "../../shared/generated/firestoreAdminTypes";
import {RazorpayPaymentProvider, FormPaymentProviderError} from
  "../formPayments/razorpayPaymentProvider";
import {razorpayKeyId, razorpayKeySecret} from "../razorpay";
import {stripeSecretKey} from "../stripe";
import type {LegacyRefundAttempt, LegacyRefundIntent} from "./intent";
import type {LegacyRefundObservation, LegacyRefundProvider} from "./processor";

import {LegacyRefundReviewRequired} from "./errors";

/** Native checkout used Catch's platform credentials. Organizer routing changes
 * cannot redirect an existing refund to a different account or provider.
 */
export class NativeCancellationRefundProvider implements LegacyRefundProvider {
  constructor(private readonly config: {
    razorpayCredentials: () => {keyId: string; secret: string};
    stripeSecret: () => string;
    fetchImpl?: typeof fetch;
  } = {razorpayCredentials: () => ({keyId: razorpayKeyId.value(),
    secret: razorpayKeySecret.value()}),
  stripeSecret: () => stripeSecretKey.value()}) {}

  async verifyPayment(payment: PaymentDocument, intent: LegacyRefundIntent):
    Promise<void> {
    if (intent.provider === "razorpay") {
      if (intent.currency !== "INR" || intent.attempts.some((attempt) =>
        attempt.state === "pending" && attempt.amountMinor < 100)) review();
      const {client, token} = this.razorpay();
      const observed = await razorpayResult(client.fetchPayment(token,
        intent.providerPaymentId));
      if (observed.orderId !== intent.orderId ||
          observed.amount !== payment.amount ||
          observed.currency !== intent.currency || !observed.captured ||
          !["captured", "refunded"].includes(observed.status)) review();
      return;
    }
    if (!intent.stripeAccountId ||
        !/^acct_[A-Za-z0-9]+$/u.test(intent.stripeAccountId)) review();
    const observed = await this.stripe(
      `/v1/payment_intents/${intent.providerPaymentId}`);
    const transfer = record(observed.transfer_data);
    if (observed.object !== "payment_intent" ||
        observed.id !== intent.providerPaymentId ||
        observed.status !== "succeeded" || observed.amount !== payment.amount ||
        observed.amount_received !== payment.amount ||
        observed.currency !== intent.currency.toLowerCase() ||
        transfer.destination !== intent.stripeAccountId ||
        observed.on_behalf_of !== intent.stripeAccountId ||
        (observed.application_fee_amount ?? 0) !==
          (payment.applicationFeeAmount ?? 0)) review();
  }

  async createRefund(intent: LegacyRefundIntent, attempt: LegacyRefundAttempt):
    Promise<LegacyRefundObservation> {
    if (intent.provider === "razorpay") {
      const {client, token} = this.razorpay();
      const result = await razorpayResult(client.refundPayment(token, {
        paymentId: intent.providerPaymentId, amount: attempt.amountMinor,
        idempotencyKey: attempt.idempotencyKey}));
      return {id: result.id, paymentId: result.paymentId,
        amountMinor: result.amount, currency: "INR", state: result.status};
    }
    const body = new URLSearchParams({payment_intent: intent.providerPaymentId,
      amount: String(attempt.amountMinor), reverse_transfer: "true",
      refund_application_fee: String(intent.refundApplicationFee)});
    return stripeRefund(await this.stripe("/v1/refunds", body,
      attempt.idempotencyKey));
  }

  async fetchRefund(intent: LegacyRefundIntent, attempt: LegacyRefundAttempt):
    Promise<LegacyRefundObservation> {
    const id = attempt.providerRefundId;
    if (!id) review();
    if (intent.provider === "razorpay") {
      const {client, token} = this.razorpay();
      const result = await razorpayResult(client.fetchRefund(token, id));
      return {id: result.id, paymentId: result.paymentId,
        amountMinor: result.amount, currency: "INR", state: result.status};
    }
    if (!/^re_[A-Za-z0-9]+$/u.test(id)) review();
    return stripeRefund(await this.stripe(`/v1/refunds/${id}`));
  }

  private razorpay(): {client: RazorpayPaymentProvider; token: string} {
    const credentials = this.config.razorpayCredentials();
    if (!credentials.keyId || !credentials.secret) {
      throw new Error("Native refund credentials are unavailable.");
    }
    return {client: new RazorpayPaymentProvider({
      signatureSecret: credentials.secret,
      authorization: () => `Basic ${Buffer.from(
        `${credentials.keyId}:${credentials.secret}`).toString("base64")}`,
    }, this.config.fetchImpl), token: credentials.secret};
  }

  /** Bounded transport never puts provider bodies or credentials in logs. */
  private async stripe(path: string, body?: URLSearchParams, key?: string):
    Promise<Record<string, unknown>> {
    const secret = this.config.stripeSecret();
    if (!secret) throw new Error("Native refund credentials are unavailable.");
    const response = await (this.config.fetchImpl ?? fetch)(
      `https://api.stripe.com${path}`, {
        method: body ? "POST" : "GET", redirect: "error",
        signal: AbortSignal.timeout(15_000), body,
        headers: {"Authorization": `Bearer ${secret}`,
          "Stripe-Version": "2026-02-25.clover",
          "Content-Type": "application/x-www-form-urlencoded",
          ...(key ? {"Idempotency-Key": key} : {})},
      });
    if (!response.ok) {
      await response.body?.cancel().catch(() => undefined);
      if (permanentRejection(response.status)) review();
      throw new Error("Native refund provider request failed.");
    }
    const reader = response.body?.getReader();
    if (!reader) throw new Error("Native refund response is unavailable.");
    const chunks: Uint8Array[] = [];
    let size = 0;
    try {
      for (;;) {
        const {done, value} = await reader.read();
        if (done) break;
        size += value.length;
        if (size > 64 * 1024) throw new Error("Refund response exceeds limit.");
        chunks.push(value);
      }
    } finally {
      await reader.cancel().catch(() => undefined);
      reader.releaseLock();
    }
    return record(JSON.parse(Buffer.concat(chunks).toString("utf8")));
  }
}

function stripeRefund(value: Record<string, unknown>): LegacyRefundObservation {
  if (value.object !== "refund" || typeof value.id !== "string" ||
      !/^re_[A-Za-z0-9]+$/u.test(value.id) ||
      typeof value.payment_intent !== "string" ||
      !/^pi_[A-Za-z0-9]+$/u.test(value.payment_intent) ||
      typeof value.amount !== "number" || !Number.isSafeInteger(value.amount) ||
      value.amount <= 0 || typeof value.currency !== "string" ||
      !/^[a-z]{3}$/u.test(value.currency) ||
      !["pending", "requires_action", "succeeded", "failed", "canceled"]
        .includes(String(value.status))) review();
  // A destination refund must also return the organizer's transferred funds.
  if (value.status === "succeeded" &&
      (typeof value.transfer_reversal !== "string" ||
        !/^trr_[A-Za-z0-9]+$/u.test(value.transfer_reversal))) review();
  return {id: value.id as string, paymentId: value.payment_intent as string,
    amountMinor: value.amount as number,
    currency: (value.currency as string).toUpperCase(),
    state: value.status === "succeeded" ? "processed" :
      value.status === "pending" ? "pending" : "failed"};
}

function record(value: unknown): Record<string, unknown> {
  if (!value || typeof value !== "object" || Array.isArray(value)) review();
  return value as Record<string, unknown>;
}
function review(): never {
  throw new LegacyRefundReviewRequired("Native refund needs reconciliation.");
}


function permanentRejection(status: number): boolean {
  return status >= 400 && status < 500 && ![408, 409, 429].includes(status);
}
async function razorpayResult<T>(request: Promise<T>): Promise<T> {
  try {
    return await request;
  } catch (error) {
    if (error instanceof FormPaymentProviderError &&
        error.httpStatus !== null && permanentRejection(error.httpStatus)) {
      review();
    }
    throw error;
  }
}
