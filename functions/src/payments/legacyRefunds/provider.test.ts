import assert from "node:assert/strict";
import test from "node:test";
import {Timestamp} from "firebase-admin/firestore";
import type {PaymentDocument} from "../../shared/generated/firestoreAdminTypes";
import {planLegacyCancellationRefund} from "./intent";
import {LegacyRefundReviewRequired} from "./errors";
import {NativeCancellationRefundProvider} from "./provider";

function setup(provider: "stripe" | "razorpay" = "stripe") {
  const payment: PaymentDocument = {userId: "user1", eventId: "event1",
    orderId: "order_one", paymentId: "pay_one", providerPaymentId: "pi_one",
    provider, stripeAccountId: "acct_original", applicationFeeAmount: 100,
    amount: 1000, currency: "INR", status: "completed", signUpFailed: false,
    createdAt: Timestamp.fromMillis(1)};
  const intent = planLegacyCancellationRefund({payment,
    reason: "eventCancelled", targetAmountMinor: 1000, nowMillis: 1});
  const attempt = {amountMinor: 1000, idempotencyKey: "refund_stable_key",
    state: "pending" as const, providerRefundId: null, startedAtMillis: 1};
  intent.attempts = [attempt];
  const calls: Array<{url: string; init: RequestInit}> = [];
  let response: unknown = {};
  let responseStatus = 200;
  const client = new NativeCancellationRefundProvider({
    razorpayCredentials: () => ({keyId: "rzp_test", secret: "rzp_secret"}),
    stripeSecret: () => "stripe_secret",
    fetchImpl: async (url, init) => {
      calls.push({url: String(url), init: init!});
      return new Response(JSON.stringify(response), {status: responseStatus});
    },
  });
  return {payment, intent, attempt, client, calls,
    respond: (value: unknown, status = 200) => {
      response = value; responseStatus = status;
    }};
}

function stripePayment() {
  return {object: "payment_intent", id: "pi_one", status: "succeeded",
    amount: 1000, amount_received: 1000, currency: "inr",
    transfer_data: {destination: "acct_original"},
    on_behalf_of: "acct_original", application_fee_amount: 100};
}
function stripeRefund() {
  return {object: "refund", id: "re_one", payment_intent: "pi_one",
    amount: 1000, currency: "inr", status: "succeeded",
    transfer_reversal: "trr_one"};
}

test("Stripe pins destination, amount, fee and charge", async () => {
  const h = setup(); h.respond(stripePayment());
  await h.client.verifyPayment(h.payment, h.intent);
  for (const patch of [{amount_received: 900}, {application_fee_amount: 0},
    {transfer_data: {destination: "acct_changed"}},
    {on_behalf_of: "acct_other"},
    {id: "pi_other"}, {currency: "usd"}]) {
    h.respond({...stripePayment(), ...patch});
    await assert.rejects(h.client.verifyPayment(h.payment, h.intent),
      /reconciliation/);
  }
});

test("Stripe refund retries retain key and reverse transfer/application fee",
  async () => {
    const h = setup(); h.respond(stripeRefund());
    const result = await h.client.createRefund(h.intent, h.attempt);
    assert.equal(result.state, "processed");
    const request = h.calls[0];
    assert.equal(request.url, "https://api.stripe.com/v1/refunds");
    const headers = request.init.headers as Record<string, string>;
    assert.equal(headers["Idempotency-Key"], "refund_stable_key");
    const body = request.init.body as URLSearchParams;
    assert.equal(body.get("payment_intent"), "pi_one");
    assert.equal(body.get("amount"), "1000");
    assert.equal(body.get("reverse_transfer"), "true");
    assert.equal(body.get("refund_application_fee"), "true");
    h.respond({...stripeRefund(), transfer_reversal: null});
    await assert.rejects(h.client.createRefund(h.intent, h.attempt),
      /reconciliation/);
  });

test("Stripe pending/action-required results never claim success", async () => {
  const h = setup();
  for (const status of ["pending", "requires_action", "failed", "canceled"]) {
    h.respond({...stripeRefund(), status, transfer_reversal: null});
    assert.notEqual((await h.client.fetchRefund(h.intent,
      {...h.attempt, providerRefundId: "re_one"})).state, "processed");
    assert.equal(h.calls.at(-1)!.init.method, "GET");
  }
});

test("Razorpay pins platform credentials and captured order", async () => {
  const h = setup("razorpay");
  h.respond({entity: "payment", id: "pay_one", order_id: "order_one",
    amount: 1000, currency: "INR", captured: true, status: "captured",
    amount_refunded: 0});
  await h.client.verifyPayment(h.payment, h.intent);
  h.respond({entity: "refund", id: "rfnd_one", payment_id: "pay_one",
    amount: 1000, currency: "INR", status: "pending"});
  assert.equal((await h.client.createRefund(h.intent, h.attempt)).state,
    "pending");
  const headers = h.calls.at(-1)!.init.headers as Record<string, string>;
  assert.equal(headers["X-Refund-Idempotency"], "refund_stable_key");
  assert.equal(headers.Authorization,
    `Basic ${Buffer.from("rzp_test:rzp_secret").toString("base64")}`);
});


test("definite provider rejection needs review while outages remain retryable",
  async () => {
    for (const provider of ["stripe", "razorpay"] as const) {
      const h = setup(provider);
      for (const status of [400, 401, 403, 404, 422]) {
        h.respond({}, status);
        await assert.rejects(h.client.createRefund(h.intent, h.attempt),
          LegacyRefundReviewRequired);
      }
      for (const status of [408, 409, 429, 500, 503]) {
        h.respond({}, status);
        await assert.rejects(h.client.createRefund(h.intent, h.attempt),
          (error: unknown) => !(error instanceof LegacyRefundReviewRequired));
      }
    }
  });
