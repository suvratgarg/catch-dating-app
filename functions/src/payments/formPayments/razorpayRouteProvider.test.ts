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
  let refunded = false;
  const provider = new RazorpayRouteProvider({keyId: "rzp_test_platform",
    keySecret: "platform-secret", mode: "test", terms: {
      paymentAmountMinor: 10000,
      destinationAccountId: "acc_host", transferAmountMinor: 9500,
      settlementHold: true,
    }}, (async (url, init) => {
      requests.push({url: String(url), init: init!});
      if (String(url).includes("/refund") && init?.method === "POST") {
        refunded = true;
      }
      const payment = {entity: "payment", id: "pay_one", order_id: "order_one",
        amount: 10000, currency: "INR", captured: true,
        status: refunded ? "refunded" : "captured",
        amount_refunded: refunded ? 10000 : 0};
      const body = String(url).includes("/refund") ? {
        entity: "refund", id: "rfnd_one", payment_id: "pay_one", amount: 10000,
        currency: "INR", status: "processed",
      } : String(url).endsWith("/orders/order_one/payments") ? {
        entity: "collection", count: 1, items: [payment],
      } : String(url).endsWith("/payments/pay_one") ? payment :
        String(url).includes("expand[]") ? {...order,
          transfers: {entity: "collection", count: 1,
            items: [{...transfer, amount_reversed: refunded ? 9500 : 0,
              ...patch}]}} : order;
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
  const refundRequest = requests.find((item) => item.init.method === "POST")!;
  assert.equal(JSON.parse(String(refundRequest.init.body)).reverse_all, true);
  assert.equal((refundRequest.init.headers as Record<string, string>)[
    "X-Refund-Idempotency"], "stable_refund_key");
  const signature = createHmac("sha256", "platform-secret")
    .update("order_one|pay_one").digest("hex");
  assert.equal(provider.verifyCheckout({serverOrderId: "order_one",
    paymentId: "pay_one", signature}), true);
  assert.equal(provider.verifyCheckout({serverOrderId: "order_other",
    paymentId: "pay_one", signature}), false);
});

test("every full-refund observation requires the exact transfer reversal",
  async () => {
    const {provider} = fixture({amount_reversed: 0});
    await assert.rejects(provider.refundPayment("rzp_test_platform", {
      paymentId: "pay_one", amount: 10000, idempotencyKey: "stable_refund_key",
    }), /Invalid Razorpay response/);
    await assert.rejects(provider.fetchPayment("rzp_test_platform", "pay_one"));
    await assert.rejects(provider.fetchOrderPayments("rzp_test_platform",
      "order_one"));
    await assert.rejects(provider.fetchRefund("rzp_test_platform", "rfnd_one"));
  });

test("new orders reject reversed or released transfers", async () => {
  for (const patch of [{amount_reversed: 1}, {on_hold: false},
    {on_hold_until: 1000}]) {
    await assert.rejects(fixture(patch).provider.createOrder(
      "rzp_test_platform", {amount: 10000, receipt: "frozen_receipt"}));
  }
});

function settlementFixture(input: {transferPatch?: Record<string, unknown>;
  paymentPatch?: Record<string, unknown>; losePatchResponse?: boolean;
} = {}) {
  let held = true;
  let patches = 0;
  const provider = new RazorpayRouteProvider({keyId: "rzp_test_platform",
    keySecret: "platform-secret", mode: "test", terms: {
      paymentAmountMinor: 10000, destinationAccountId: "acc_host",
      transferAmountMinor: 9500, settlementHold: true}},
  (async (url, init) => {
    if (init?.method === "PATCH") {
      assert.equal(String(url), "https://api.razorpay.com/v1/transfers/trf_one");
      assert.deepEqual(JSON.parse(String(init.body)), {on_hold: false});
      held = false;
      patches++;
      if (input.losePatchResponse) throw new Error("response lost");
    }
    const paid = {...order, status: "paid"};
    const body = String(url).endsWith("/payments/pay_one") ? {
      entity: "payment", id: "pay_one", order_id: "order_one", amount: 10000,
      currency: "INR", captured: true, status: "captured", amount_refunded: 0,
      ...input.paymentPatch,
    } : String(url).includes("expand[]") ? {...paid,
      transfers: {entity: "collection", count: 1, items: [{...transfer,
        on_hold: held, status: "processed",
        settlement_status: held ? "on_hold" : "pending",
        ...input.transferPatch}]}} : paid;
    return new Response(JSON.stringify(body), {status: 200});
  }) as typeof fetch);
  return {provider, patches: () => patches};
}
const settlement = {orderId: "order_one", paymentId: "pay_one",
  receipt: "frozen_receipt", transferId: "trf_one"};

test("settlement releases the pinned paid transfer and verifies the result",
  async () => {
    const {provider, patches} = settlementFixture();
    assert.equal((await provider.inspectSettlement("rzp_test_platform",
      settlement)).onHold, true);
    const result = await provider.releaseSettlement("rzp_test_platform",
      settlement);
    assert.equal(result.onHold, false);
    assert.equal(result.settlementStatus, "pending");
    await provider.releaseSettlement("rzp_test_platform", settlement);
    assert.equal(patches(), 1);
  });

test("uncertain release resumes from provider state without a second PATCH",
  async () => {
    const {provider, patches} = settlementFixture({losePatchResponse: true});
    await assert.rejects(provider.releaseSettlement("rzp_test_platform",
      settlement), /outcome is unknown/u);
    assert.equal((await provider.releaseSettlement("rzp_test_platform",
      settlement)).onHold, false);
    assert.equal(patches(), 1);
  });

test("unsettleable or mismatched funds never release a transfer", async () => {
  for (const input of [
    {transferPatch: {recipient: "acc_other"}},
    {transferPatch: {amount_reversed: 1}},
    {transferPatch: {status: "pending"}},
    {transferPatch: {on_hold_until: 99}},
    {transferPatch: {settlement_status: "settled"}},
    {paymentPatch: {amount_refunded: 10000, status: "refunded"}},
    {paymentPatch: {captured: false, status: "authorized"}},
  ]) {
    const {provider, patches} = settlementFixture(input);
    await assert.rejects(provider.releaseSettlement("rzp_test_platform",
      settlement));
    assert.equal(patches(), 0);
  }
  const {provider, patches} = settlementFixture();
  await assert.rejects(provider.releaseSettlement("rzp_test_platform",
    {...settlement, transferId: "trf_other"}));
  await assert.rejects(provider.releaseSettlement("rzp_test_platform",
    {...settlement, receipt: "other_receipt"}));
  assert.equal(patches(), 0);
});
