import {RazorpayPaymentProvider, providerId, assertToken, assertHttps,
  tokenValue, invalidInput, invalidResponse, FormPaymentProviderError} from
  "./razorpayPaymentProvider";
export {FormPaymentProviderError, isCapturedFormPayment} from
  "./razorpayPaymentProvider";
export type {FormPaymentOrder, FormProviderPayment, FormProviderRefund} from
  "./razorpayPaymentProvider";

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

export const formWebhookEvents = [
  "payment.authorized", "payment.captured", "payment.failed",
  "refund.created", "refund.failed", "refund.processed",
] as const;

/** Merchant OAuth adapter. It never uses Catch's event payment credentials. */
export class RazorpayFormProvider extends RazorpayPaymentProvider {
  constructor(
    private readonly config: RazorpayPartnerConfig,
    fetchImpl: typeof fetch = fetch,
    private readonly now: () => number = Date.now,
  ) {
    super({authorization: (token) => `Bearer ${token}`,
      signatureSecret: config.clientSecret}, fetchImpl);
  }

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
