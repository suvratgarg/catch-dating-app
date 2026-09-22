import {verifyPaymentSignatureWithSecret} from "../razorpay";

export interface RazorpayPartnerConfig {
  clientId: string;
  clientSecret: string;
  redirectUri: string;
  mode: "test" | "live";
}

export interface RazorpayMerchantToken {
  accessToken: string;
  refreshToken: string;
  publicToken: string;
  expiresAt: number;
  accountId: string;
}

export interface FormPaymentOrder {
  id: string;
  amount: number;
  currency: "INR";
  receipt: string;
  status: "created" | "attempted" | "paid";
}

export interface FormProviderPayment {
  id: string;
  orderId: string;
  amount: number;
  currency: string;
  status: "created" | "authorized" | "captured" | "refunded" | "failed";
  captured: boolean;
  amountRefunded: number;
}

export interface FormProviderRefund {
  id: string;
  paymentId: string;
  amount: number;
  status: "pending" | "processed" | "failed";
}

export const formWebhookEvents = [
  "payment.authorized", "payment.captured", "payment.failed",
  "refund.created", "refund.failed", "refund.processed",
] as const;

export class FormPaymentProviderError extends Error {
  constructor(
    message: string,
    readonly disposition: "requestNotSent" | "rejected" | "outcomeUnknown",
    readonly httpStatus: number | null = null,
  ) {
    super(message);
    this.name = "FormPaymentProviderError";
  }
}

/** Merchant OAuth adapter. It never uses Catch's event payment credentials. */
export class RazorpayFormProvider {
  constructor(
    private readonly config: RazorpayPartnerConfig,
    private readonly fetchImpl: typeof fetch = fetch,
    private readonly now: () => number = Date.now,
  ) {}

  authorizationUrl(state: string): string {
    this.assertConfigured();
    if (!/^[A-Za-z0-9_-]{32,128}$/u.test(state)) invalidInput();
    const url = new URL("https://auth.razorpay.com/authorize");
    url.search = new URLSearchParams({
      client_id: this.config.clientId, response_type: "code",
      redirect_uri: this.config.redirectUri, scope: "read_write", state,
    }).toString();
    return url.href;
  }

  async exchangeCode(code: string): Promise<RazorpayMerchantToken> {
    this.assertConfigured();
    assertToken(code);
    const body = await this.request("https://auth.razorpay.com/token", {
      method: "POST", body: JSON.stringify({
        client_id: this.config.clientId,
        client_secret: this.config.clientSecret,
        grant_type: "authorization_code", code,
        redirect_uri: this.config.redirectUri, mode: this.config.mode,
      }),
    });
    return this.parseToken(body, providerId(body.razorpay_account_id, "acc_"));
  }

  async refreshToken(token: RazorpayMerchantToken):
    Promise<RazorpayMerchantToken> {
    this.assertConfigured();
    assertToken(token.refreshToken);
    providerId(token.accountId, "acc_");
    const body = await this.request("https://auth.razorpay.com/token", {
      method: "POST", body: JSON.stringify({
        client_id: this.config.clientId,
        client_secret: this.config.clientSecret,
        grant_type: "refresh_token", refresh_token: token.refreshToken,
      }),
    });
    // Refresh responses can omit the account id; never accept a changed one.
    if (body.razorpay_account_id !== undefined &&
        body.razorpay_account_id !== token.accountId) invalidResponse();
    return this.parseToken(body, token.accountId);
  }

  async createOrder(accessToken: string, input: {
    amount: number; receipt: string;
  }): Promise<FormPaymentOrder> {
    assertAmount(input.amount);
    if (!/^[A-Za-z0-9_-]{1,40}$/u.test(input.receipt)) invalidInput();
    const body = await this.api(accessToken, "/v1/orders", "POST", {
      amount: input.amount, currency: "INR", receipt: input.receipt,
      partial_payment: false,
    });
    const order = parseOrder(body);
    if (order.amount !== input.amount || order.receipt !== input.receipt) {
      invalidResponse();
    }
    return order;
  }

  async fetchOrder(accessToken: string, orderId: string):
    Promise<FormPaymentOrder> {
    providerId(orderId, "order_");
    const order = parseOrder(await this.api(accessToken,
      `/v1/orders/${orderId}`, "GET"));
    if (order.id !== orderId) invalidResponse();
    return order;
  }

  /** Read-only recovery after order creation had an uncertain outcome. */
  async findOrderByReceipt(accessToken: string, receipt: string):
    Promise<FormPaymentOrder | null> {
    if (!/^[A-Za-z0-9_-]{1,40}$/u.test(receipt)) invalidInput();
    const query = new URLSearchParams({receipt, count: "2"});
    const body = await this.api(accessToken, `/v1/orders?${query}`, "GET");
    if (body.entity !== "collection" || !Array.isArray(body.items) ||
        body.count !== body.items.length || body.items.length > 1) {
      invalidResponse();
    }
    if (body.items.length === 0) return null;
    const raw: unknown = body.items[0];
    if (!raw || typeof raw !== "object" || Array.isArray(raw)) {
      invalidResponse();
    }
    const order = parseOrder(raw as Record<string, unknown>);
    if (order.receipt !== receipt) invalidResponse();
    return order;
  }

  async fetchOrderPayments(accessToken: string, orderId: string):
    Promise<FormProviderPayment[]> {
    providerId(orderId, "order_");
    const body = await this.api(accessToken,
      `/v1/orders/${orderId}/payments`, "GET");
    if (body.entity !== "collection" || !Array.isArray(body.items) ||
        body.count !== body.items.length || body.items.length > 100) {
      invalidResponse();
    }
    return body.items.map((raw: unknown) => {
      if (!raw || typeof raw !== "object" || Array.isArray(raw)) {
        invalidResponse();
      }
      const payment = parsePayment(raw as Record<string, unknown>);
      if (payment.orderId !== orderId) invalidResponse();
      return payment;
    });
  }

  async fetchPayment(accessToken: string, paymentId: string):
    Promise<FormProviderPayment> {
    providerId(paymentId, "pay_");
    const payment = parsePayment(await this.api(accessToken,
      `/v1/payments/${paymentId}`, "GET"));
    if (payment.id !== paymentId) invalidResponse();
    return payment;
  }

  async capturePayment(accessToken: string, paymentId: string,
    amount: number): Promise<FormProviderPayment> {
    providerId(paymentId, "pay_");
    assertAmount(amount);
    const payment = parsePayment(await this.api(accessToken,
      `/v1/payments/${paymentId}/capture`, "POST", {
        amount, currency: "INR",
      }));
    if (payment.id !== paymentId || payment.amount !== amount) {
      invalidResponse();
    }
    return payment;
  }

  /** Reuses the persisted key and amount after uncertain outcomes. */
  async refundPayment(accessToken: string, input: {
    paymentId: string; amount: number; idempotencyKey: string;
  }): Promise<FormProviderRefund> {
    assertToken(accessToken);
    providerId(input.paymentId, "pay_");
    assertAmount(input.amount);
    if (!/^[A-Za-z0-9_-]{10,100}$/u.test(input.idempotencyKey)) invalidInput();
    const refund = parseRefund(await this.request(
      `https://api.razorpay.com/v1/payments/${input.paymentId}/refund`, {
        method: "POST", headers: {"Authorization": `Bearer ${accessToken}`,
          "X-Refund-Idempotency": input.idempotencyKey},
        body: JSON.stringify({amount: input.amount, speed: "normal"}),
      }));
    if (refund.paymentId !== input.paymentId ||
        refund.amount !== input.amount) {
      invalidResponse();
    }
    return refund;
  }

  async fetchRefund(accessToken: string, refundId: string):
    Promise<FormProviderRefund> {
    providerId(refundId, "rfnd_");
    const refund = parseRefund(await this.api(accessToken,
      `/v1/refunds/${refundId}`, "GET"));
    if (refund.id !== refundId) invalidResponse();
    return refund;
  }

  verifyCheckout(input: {
    serverOrderId: string; paymentId: string; signature: string;
  }): boolean {
    this.assertConfigured();
    return /^order_[A-Za-z0-9]+$/u.test(input.serverOrderId) &&
      /^pay_[A-Za-z0-9]+$/u.test(input.paymentId) &&
      /^[a-fA-F0-9]{64}$/u.test(input.signature) &&
      verifyPaymentSignatureWithSecret({orderId: input.serverOrderId,
        paymentId: input.paymentId, signature: input.signature,
        secret: this.config.clientSecret});
  }

  async createWebhook(input: {
    accessToken: string; accountId: string; url: string; secret: string;
  }): Promise<string> {
    providerId(input.accountId, "acc_");
    assertHttps(input.url, 255);
    if (!/^[A-Za-z0-9_-]{32,128}$/u.test(input.secret)) invalidInput();
    const body = await this.api(input.accessToken,
      `/v2/accounts/${input.accountId}/webhooks`, "POST", {
        url: input.url, secret: input.secret, events: formWebhookEvents,
      });
    const webhookId = providerId(body.id, "");
    assertWebhook(body, input);
    return webhookId;
  }

  async verifyWebhook(input: {
    accessToken: string; accountId: string; webhookId: string; url: string;
  }): Promise<void> {
    providerId(input.accountId, "acc_");
    providerId(input.webhookId, "");
    assertHttps(input.url, 255);
    const body = await this.api(input.accessToken,
      `/v2/accounts/${input.accountId}/webhooks/${input.webhookId}`, "GET");
    if (body.id !== input.webhookId) invalidResponse();
    assertWebhook(body, input);
  }

  private assertConfigured(): void {
    if (!this.config.clientId || !this.config.clientSecret ||
        !["test", "live"].includes(this.config.mode)) {
      throw new FormPaymentProviderError(
        "Razorpay partner connection is not configured.", "requestNotSent");
    }
    assertHttps(this.config.redirectUri, 2048);
  }

  private parseToken(body: Record<string, unknown>, accountId: string):
    RazorpayMerchantToken {
    const accessToken = tokenValue(body.access_token);
    const refreshToken = tokenValue(body.refresh_token);
    const publicToken = tokenValue(body.public_token);
    const expiresIn = body.expires_in;
    const now = this.now();
    if (body.token_type !== "Bearer" ||
        !publicToken.startsWith(`rzp_${this.config.mode}_oauth_`) ||
        typeof expiresIn !== "number" || !Number.isSafeInteger(expiresIn) ||
        expiresIn <= 0 || expiresIn > 366 * 24 * 60 * 60 ||
        !Number.isSafeInteger(now) || now < 0) invalidResponse();
    return {accessToken, refreshToken, publicToken, accountId,
      expiresAt: now + expiresIn * 1000};
  }

  private api(accessToken: string, path: string,
    method: "GET" | "POST", body?: Record<string, unknown>):
    Promise<Record<string, unknown>> {
    assertToken(accessToken);
    return this.request(`https://api.razorpay.com${path}`, {
      method, headers: {Authorization: `Bearer ${accessToken}`},
      ...(body ? {body: JSON.stringify(body)} : {}),
    });
  }

  private async request(url: string, init: RequestInit):
    Promise<Record<string, unknown>> {
    let response: Response;
    try {
      response = await this.fetchImpl(url, {...init,
        headers: {"Content-Type": "application/json", ...init.headers},
        redirect: "error", signal: AbortSignal.timeout(15_000),
      });
    } catch {
      throw new FormPaymentProviderError(
        "Razorpay request outcome is unknown.", "outcomeUnknown");
    }
    // Never include provider error bodies (which may echo credentials or PII).
    if (!response.ok) {
      await response.body?.cancel().catch(() => undefined);
      throw new FormPaymentProviderError("Razorpay request failed.",
        response.status >= 500 ? "outcomeUnknown" : "rejected",
        response.status);
    }
    try {
      const reader = response.body?.getReader();
      if (!reader) invalidResponse();
      const chunks: Uint8Array[] = [];
      let size = 0;
      try {
        for (;;) {
          const {done, value} = await reader.read();
          if (done) break;
          size += value.length;
          if (size > 64 * 1024) invalidResponse();
          chunks.push(value);
        }
      } finally {
        await reader.cancel().catch(() => undefined);
        reader.releaseLock();
      }
      const body: unknown = JSON.parse(Buffer.concat(chunks).toString("utf8"));
      if (!body || typeof body !== "object" || Array.isArray(body)) {
        invalidResponse();
      }
      return body as Record<string, unknown>;
    } catch {
      invalidResponse();
    }
  }
}

/** A signature or an authorized payment alone never completes a submission. */
export function isCapturedFormPayment(payment: FormProviderPayment,
  expected: {orderId: string; amount: number}): boolean {
  return payment.orderId === expected.orderId &&
    payment.amount === expected.amount && payment.currency === "INR" &&
    payment.status === "captured" && payment.captured &&
    payment.amountRefunded === 0;
}

function parseOrder(body: Record<string, unknown>): FormPaymentOrder {
  if (body.entity !== "order" || body.currency !== "INR" ||
      !["created", "attempted", "paid"].includes(String(body.status)) ||
      typeof body.receipt !== "string" || body.receipt.length > 40 ||
      typeof body.amount !== "number" || !Number.isSafeInteger(body.amount) ||
      body.amount < 100) invalidResponse();
  return {id: providerId(body.id, "order_"), amount: body.amount,
    currency: "INR", receipt: body.receipt,
    status: body.status as FormPaymentOrder["status"]};
}

function parsePayment(body: Record<string, unknown>): FormProviderPayment {
  if (body.entity !== "payment" || typeof body.amount !== "number" ||
      !Number.isSafeInteger(body.amount) || body.amount < 0 ||
      typeof body.currency !== "string" ||
      !["created", "authorized", "captured", "refunded", "failed"]
        .includes(String(body.status)) || typeof body.captured !== "boolean" ||
      typeof body.amount_refunded !== "number" ||
      !Number.isSafeInteger(body.amount_refunded) || body.amount_refunded < 0 ||
      body.amount_refunded > body.amount) invalidResponse();
  return {id: providerId(body.id, "pay_"),
    orderId: providerId(body.order_id, "order_"), amount: body.amount,
    currency: body.currency,
    status: body.status as FormProviderPayment["status"],
    captured: body.captured, amountRefunded: body.amount_refunded};
}

function parseRefund(body: Record<string, unknown>): FormProviderRefund {
  if (body.entity !== "refund" || body.currency !== "INR" ||
      typeof body.amount !== "number" || !Number.isSafeInteger(body.amount) ||
      body.amount < 100 ||
      !["pending", "processed", "failed"].includes(String(body.status))) {
    invalidResponse();
  }
  return {id: providerId(body.id, "rfnd_"),
    paymentId: providerId(body.payment_id, "pay_"), amount: body.amount,
    status: body.status as FormProviderRefund["status"]};
}

function assertWebhook(body: Record<string, unknown>,
  expected: {accountId: string; url: string}): void {
  // Some partner responses omit the acc_ prefix on owner_id.
  const account = String(body.owner_id ?? "");
  if (body.entity !== "webhook" || body.active !== true ||
      body.secret_exists !== true || body.owner_type !== "merchant" ||
      ![expected.accountId, expected.accountId.slice(4)].includes(account) ||
      body.url !== expected.url || !Array.isArray(body.events) ||
      !formWebhookEvents.every((event) => body.events instanceof Array &&
        body.events.includes(event))) invalidResponse();
}

function providerId(value: unknown, prefix: string): string {
  if (typeof value !== "string" || value.length > 128 ||
      !value.startsWith(prefix) ||
      !/^[A-Za-z0-9]+$/u.test(value.slice(prefix.length))) invalidResponse();
  return value;
}

function assertAmount(amount: number): void {
  if (!Number.isSafeInteger(amount) || amount < 100 || amount > 100_000_000) {
    invalidInput();
  }
}

function assertHttps(value: string, maxLength: number): void {
  try {
    const url = new URL(value);
    if (value.length > maxLength || url.protocol !== "https:" ||
        url.username || url.password || url.hash) invalidInput();
  } catch {
    invalidInput();
  }
}

function assertToken(value: string): void {
  if (!value || value.length > 16_384 || /\s/u.test(value)) invalidInput();
}

function tokenValue(value: unknown): string {
  if (typeof value !== "string" || !value || value.length > 16_384 ||
      /\s/u.test(value)) invalidResponse();
  return value;
}

function invalidInput(): never {
  throw new FormPaymentProviderError("Invalid Razorpay request.",
    "requestNotSent");
}

function invalidResponse(): never {
  throw new FormPaymentProviderError("Invalid Razorpay response.",
    "outcomeUnknown");
}
