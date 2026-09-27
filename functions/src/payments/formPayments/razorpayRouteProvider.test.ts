import {strict as assert} from "node:assert";
import {createHmac} from "node:crypto";
import {test} from "node:test";
import {RazorpayRouteProvider} from "./razorpayRouteProvider";

const order = {entity: "order", id: "order_one", amount: 10000,
  currency: "INR", receipt: "frozen_receipt", status: "created"};
const transfer = {entity: "transfer", id: "trf_one", source: "order_one",
  recipient: "acc_host", amount: 9500, currency: "INR", amount_reversed: 0,
  on_hold: true, on_hold_until: null};
function fixture(patch: Record<string, unknown> = {}) {
  const requests: Array<{url: string; init: RequestInit}> = [];
  const provider = new RazorpayRouteProvider({keyId: "rzp_test_platform",
    keySecret: "platform-secret", mode: "test", terms: {
      paymentAmountMinor: 10000,
      destinationAccountId: "acc_host", transferAmountMinor: 9500,
      settlementHold: true,
    }}, (async (url, init) => {
      requests.push({url: String(url), init: init!});
      const body = String(url).includes("/refund") ? {
        entity: "refund", id: "rfnd_one", payment_id: "pay_one", amount: 10000,
        currency: "INR", status: "processed",
      } : String(url).includes("expand[]") ? {...order,
        transfers: {entity: "collection", count: 1,
          items: [{...transfer, ...patch}]}} : order;
      return new Response(JSON.stringify(body), {status: 200});
    }) as typeof fetch);
  return {provider, requests};
}

test("Route transfer uses platform auth without OAuth", async () => {
  const {provider, requests} = fixture();
  assert.equal((await provider.createOrder("rzp_test_platform", {
    amount: 10000, receipt: "frozen_receipt"})).id, "order_one");
  assert.equal(requests.length, 3);
  const headers = requests[0].init.headers as Record<string, string>;
  assert.equal(headers.Authorization, "Basic " +
    Buffer.from("rzp_test_platform:platform-secret").toString("base64"));
  assert.deepEqual(JSON.parse(String(requests[0].init.body)).transfers,
    [{account: "acc_host", amount: 9500, currency: "INR", on_hold: true}]);
  assert.equal(requests.some((request) =>
    request.url.includes("auth.razorpay")),
  false);
});

test("invalid handle or transfer fails before POST", async () => {
  const {provider, requests} = fixture();
  await assert.rejects(provider.createOrder("oauth-token", {
    amount: 10000, receipt: "frozen_receipt"}));
  await assert.rejects(provider.createOrder("rzp_test_platform", {
    amount: 9000, receipt: "frozen_receipt"}));
  assert.equal(requests.length, 0);
});

test("reconciliation checks beneficiary and split", async () => {
  for (const patch of [{recipient: "acc_other"}, {amount: 9499},
    {source: "order_other"}, {currency: "USD"}, {amount_reversed: 9501}]) {
    await assert.rejects(fixture(patch).provider.fetchOrder(
      "rzp_test_platform", "order_one"), /Invalid Razorpay response/);
  }
});

test("Route refund retains idempotency and reverses transfers", async () => {
  const {provider, requests} = fixture();
  await assert.rejects(provider.refundPayment("rzp_test_platform", {
    paymentId: "pay_one", amount: 9000, idempotencyKey: "stable_refund_key"}));
  assert.equal(requests.length, 0);
  await provider.refundPayment("rzp_test_platform", {paymentId: "pay_one",
    amount: 10000, idempotencyKey: "stable_refund_key"});
  assert.equal(JSON.parse(String(requests[0].init.body)).reverse_all, true);
  assert.equal((requests[0].init.headers as Record<string, string>)[
    "X-Refund-Idempotency"], "stable_refund_key");
  const signature = createHmac("sha256", "platform-secret")
    .update("order_one|pay_one").digest("hex");
  assert.equal(provider.verifyCheckout({serverOrderId: "order_one",
    paymentId: "pay_one", signature}), true);
  assert.equal(provider.verifyCheckout({serverOrderId: "order_other",
    paymentId: "pay_one", signature}), false);
});
