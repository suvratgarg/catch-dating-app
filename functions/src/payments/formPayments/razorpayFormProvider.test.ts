import assert from "node:assert/strict";
import {createHmac} from "node:crypto";
import test from "node:test";
import {
  FormPaymentProviderError, formWebhookEvents, isCapturedFormPayment,
  RazorpayFormProvider,
} from "./razorpayFormProvider";

const config = {clientId: "partner-client", clientSecret: "partner-secret",
  redirectUri: "https://catchdates.com/razorpay/callback",
  mode: "test" as const};
const tokenResponse = {token_type: "Bearer", access_token: "private-access",
  refresh_token: "private-refresh", public_token: "rzp_test_oauth_public",
  razorpay_account_id: "acc_merchant", expires_in: 3600};
const paymentResponse = {entity: "payment", id: "pay_one",
  order_id: "order_one",
  amount: 10000, currency: "INR", status: "captured", captured: true,
  amount_refunded: 0};

function fixture(body: unknown, status = 200) {
  const calls: Array<{url: string; init: RequestInit}> = [];
  const fetcher: typeof fetch = async (url, init) => {
    calls.push({url: String(url), init: init ?? {}});
    return new Response(JSON.stringify(body), {status});
  };
  return {calls,
    provider: new RazorpayFormProvider(config, fetcher, () => 1000)};
}

test("OAuth uses configured callback and server state; no secret in URL",
  () => {
    const {provider} = fixture({});
    const url = new URL(provider.authorizationUrl("a".repeat(43)));
    assert.equal(url.origin, "https://auth.razorpay.com");
    assert.equal(url.searchParams.get("redirect_uri"), config.redirectUri);
    assert.equal(url.searchParams.get("scope"), "read_write");
    assert.equal(url.searchParams.get("state"), "a".repeat(43));
    assert.equal(url.searchParams.has("client_secret"), false);
    assert.throws(() => provider.authorizationUrl("unsafe state"));
    assert.throws(() => new RazorpayFormProvider({...config, clientSecret: ""})
      .authorizationUrl("a".repeat(43)), /not configured/u);
    assert.throws(() => new RazorpayFormProvider({...config,
      redirectUri: "https://secret@catchdates.com/callback"})
      .authorizationUrl("a".repeat(43)));
  });

test("code exchange binds mode and account; refresh preserves account",
  async () => {
    const {provider, calls} = fixture(tokenResponse);
    const token = await provider.exchangeCode("code");
    assert.deepEqual(token, {accessToken: "private-access",
      refreshToken: "private-refresh", publicToken: "rzp_test_oauth_public",
      expiresAt: 3601000, accountId: "acc_merchant"});
    assert.deepEqual(JSON.parse(String(calls[0].init.body)), {
      client_id: config.clientId, client_secret: config.clientSecret,
      grant_type: "authorization_code", code: "code",
      redirect_uri: config.redirectUri, mode: "test",
    });
    const refresh = fixture({...tokenResponse, razorpay_account_id: undefined,
      refresh_token: "rotated-refresh"});
    assert.equal((await refresh.provider.refreshToken(token)).accountId,
      "acc_merchant");
    assert.equal((await refresh.provider.refreshToken(token)).refreshToken,
      "rotated-refresh");
    await assert.rejects(fixture({...tokenResponse,
      razorpay_account_id: "acc_other"}).provider.refreshToken(token));
  });

test("OAuth rejects wrong mode, malformed expiry and non-Bearer responses",
  async () => {
    for (const patch of [{public_token: "rzp_live_oauth_wrong"},
      {expires_in: -1}, {expires_in: 1.5}, {token_type: "Basic"},
      {access_token: "contains whitespace"},
      {razorpay_account_id: "../other"}]) {
      await assert.rejects(fixture({...tokenResponse, ...patch})
        .provider.exchangeCode("code"), FormPaymentProviderError);
    }
  });

test("orders use merchant bearer, paise, stable receipt and no partial payment",
  async () => {
    const {provider, calls} = fixture({entity: "order", id: "order_one",
      amount: 10000, currency: "INR", receipt: "form_attempt",
      status: "created"});
    await provider.createOrder("merchant-token", {amount: 10000,
      receipt: "form_attempt"});
    assert.equal(calls[0].url, "https://api.razorpay.com/v1/orders");
    assert.equal(new Headers(calls[0].init.headers).get("Authorization"),
      "Bearer merchant-token");
    assert.deepEqual(JSON.parse(String(calls[0].init.body)), {amount: 10000,
      currency: "INR", receipt: "form_attempt", partial_payment: false});
    assert.equal(calls[0].init.redirect, "error");
    assert.ok(calls[0].init.signal);
    for (const amount of [0, 99, 100.5, NaN, Infinity]) {
      await assert.rejects(provider.createOrder("merchant-token", {
        amount, receipt: "form_attempt"}));
    }
    assert.equal(calls.length, 1);
    await assert.rejects(provider.createOrder("merchant-token", {
      amount: 20000, receipt: "form_attempt"}));
  });

test("checkout signature uses partner secret and persisted server order",
  () => {
    const {provider} = fixture({});
    const signature = createHmac("sha256", config.clientSecret)
      .update("order_one|pay_one").digest("hex");
    const input = {serverOrderId: "order_one", paymentId: "pay_one", signature};
    assert.equal(provider.verifyCheckout(input), true);
    assert.equal(provider.verifyCheckout({...input,
      serverOrderId: "order_other"}),
    false);
    assert.equal(provider.verifyCheckout({...input,
      signature: signature + "f"}),
    false);
  });

test("only exact captured, unrefunded INR payment is eligible", async () => {
  const {provider} = fixture(paymentResponse);
  const payment = await provider.fetchPayment("merchant-token", "pay_one");
  const expected = {orderId: "order_one", amount: 10000};
  assert.equal(isCapturedFormPayment(payment, expected), true);
  for (const patch of [{status: "authorized" as const}, {captured: false},
    {orderId: "order_other"}, {currency: "USD"}, {amount: 20000},
    {amountRefunded: 1}, {status: "refunded" as const}]) {
    assert.equal(isCapturedFormPayment({...payment, ...patch}, expected),
      false);
  }
  await assert.rejects(provider.fetchPayment("merchant-token", "pay_other"));
  await assert.rejects(provider.fetchPayment("merchant-token",
    "../../accounts"));
});

test("capture uses the stored amount and preserves payment identity",
  async () => {
    const {provider, calls} = fixture(paymentResponse);
    await provider.capturePayment("merchant-token", "pay_one", 10000);
    assert.equal(calls[0].url,
      "https://api.razorpay.com/v1/payments/pay_one/capture");
    assert.deepEqual(JSON.parse(String(calls[0].init.body)), {
      amount: 10000, currency: "INR"});
    await assert.rejects(provider.capturePayment("merchant-token", "pay_one",
      20000));
  });

test("webhook verification binds merchant, URL, activation and required events",
  async () => {
    const url = "https://catchdates.com/api/form-payment-hook/connection";
    const body = {entity: "webhook", id: "webhook1", owner_id: "merchant",
      owner_type: "merchant", url, active: true, secret_exists: true,
      events: [...formWebhookEvents]};
    const input = {accessToken: "merchant-token", accountId: "acc_merchant",
      url, secret: "s".repeat(43)};
    const {provider, calls} = fixture(body);
    assert.equal(await provider.createWebhook(input), "webhook1");
    assert.equal(calls[0].url,
      "https://api.razorpay.com/v2/accounts/acc_merchant/webhooks");
    for (const patch of [{owner_id: "other"}, {url: "https://evil.test"},
      {active: false}, {secret_exists: false},
      {events: ["payment.authorized"]}]) {
      await assert.rejects(fixture({...body, ...patch}).provider.verifyWebhook({
        ...input, webhookId: "webhook1"}));
    }
  });

test("provider errors sanitize bodies; uncertain POSTs are never auto-retried",
  async () => {
    for (const status of [400, 401, 429, 500, 503]) {
      const {provider, calls} = fixture({
        error: "private-token customer@example.com"},
      status);
      await assert.rejects(provider.createOrder("token", {
        amount: 10000, receipt: "form_attempt"}), (error: unknown) => {
        assert.ok(error instanceof FormPaymentProviderError);
        assert.equal(error.disposition, status >= 500 ? "outcomeUnknown" :
          "rejected");
        assert.equal(error.httpStatus, status);
        assert.doesNotMatch(String(error), /private-token|customer@/u);
        return true;
      });
      assert.equal(calls.length, 1);
    }
    const provider = new RazorpayFormProvider(config, async () => {
      throw new Error("network private-token");
    });
    await assert.rejects(provider.createOrder("token", {amount: 10000,
      receipt: "form_attempt"}), /outcome is unknown/u);
  });

test("oversized, invalid and unrelated successful bodies fail closed",
  async () => {
    for (const body of [null, [], {unexpected: "x".repeat(65537)},
      {...paymentResponse, amount_refunded: -1},
      {...paymentResponse, amount: 1.5}]) {
      await assert.rejects(fixture(body).provider.fetchPayment("token",
        "pay_one"),
      /Invalid Razorpay response/u);
    }
  });
