import {SecretManagerServiceClient} from "@google-cloud/secret-manager";
import {defineString} from "firebase-functions/params";
import {HttpsError} from "firebase-functions/v2/https";
import {RazorpayCredentialVault} from "./razorpayCredentialVault";
import {RazorpayFormProvider, type RazorpayPartnerConfig} from
  "./razorpayFormProvider";

// Empty by default: deploying forms must not require an unconfigured partner
// account or expose a fee option before the operator connects one.
export const formRazorpayPartnerConfigVersion = defineString(
  "FORM_RAZORPAY_PARTNER_CONFIG_VERSION", {default: ""});

interface PartnerSecret {
  schema: "catch.form-razorpay-partner/v1";
  clientId: string;
  clientSecret: string;
  mode: "test" | "live";
  credentialSecretId: string;
}

export interface FormPaymentRuntime {
  provider: RazorpayFormProvider;
  vault: RazorpayCredentialVault;
  mode: "test" | "live";
  webhookBaseUrl: string;
  callbackUrl: string;
}

/** Reads pinned secret versions in the deployment project. */
export class FormPaymentRuntimeConfig {
  private cached: {version: string; until: number;
    config: Promise<PartnerSecret>} | null = null;

  constructor(private readonly projectId: string,
    private readonly readSecret: (version: string) => Promise<string> =
    readGoogleSecret,
    private readonly now: () => number = Date.now) {
    if (!/^[a-z][a-z0-9-]{4,61}[a-z0-9]$/u.test(projectId)) unavailable();
  }

  async load(version: string): Promise<FormPaymentRuntime> {
    const config = await this.loadSecret(version);
    // These endpoints are owned by this deployment, not supplied by a browser
    // or by the connecting organizer. Production OAuth requires HTTPS.
    const origin = `https://asia-south1-${this.projectId}.cloudfunctions.net`;
    const callbackUrl = `${origin}/organizerFormPaymentOauthCallback`;
    const webhookBaseUrl = `${origin}/organizerFormPaymentWebhook`;
    const providerConfig: RazorpayPartnerConfig = {
      clientId: config.clientId, clientSecret: config.clientSecret,
      mode: config.mode, redirectUri: callbackUrl,
    };
    return {provider: new RazorpayFormProvider(providerConfig),
      vault: new RazorpayCredentialVault(this.projectId,
        config.credentialSecretId), mode: config.mode,
      webhookBaseUrl, callbackUrl};
  }

  private async loadSecret(version: string): Promise<PartnerSecret> {
    const prefix = `projects/${this.projectId}/secrets/`;
    if (!version.startsWith(prefix) ||
        !/^[A-Za-z0-9_-]{1,255}\/versions\/[1-9][0-9]*$/u
          .test(version.slice(prefix.length))) unavailable();
    if (this.cached?.version === version && this.cached.until > this.now()) {
      return this.cached.config;
    }
    const promise = this.readSecret(version).then(parsePartnerSecret)
      .catch(() => unavailable());
    this.cached = {version, until: this.now() + 60_000, config: promise};
    try {
      return await promise;
    } catch {
      if (this.cached?.config === promise) this.cached = null;
      unavailable();
    }
  }
}

function parsePartnerSecret(raw: string): PartnerSecret {
  if (Buffer.byteLength(raw, "utf8") > 32 * 1024) unavailable();
  const value: unknown = JSON.parse(raw);
  if (!value || typeof value !== "object" || Array.isArray(value)) {
    unavailable();
  }
  const record = value as Record<string, unknown>;
  if (Object.keys(record).sort().join(",") !==
      "clientId,clientSecret,credentialSecretId,mode,schema" ||
      record.schema !== "catch.form-razorpay-partner/v1" ||
      (record.mode !== "test" && record.mode !== "live") ||
      !secret(record.clientId) || !secret(record.clientSecret) ||
      typeof record.credentialSecretId !== "string" ||
      !/^[A-Za-z0-9_-]{1,255}$/u.test(record.credentialSecretId)) unavailable();
  return record as unknown as PartnerSecret;
}

async function readGoogleSecret(version: string): Promise<string> {
  const [value] = await new SecretManagerServiceClient()
    .accessSecretVersion({name: version});
  if (!value.payload?.data) unavailable();
  return Buffer.from(value.payload.data).toString("utf8");
}

function secret(value: unknown): value is string {
  return typeof value === "string" && value.length > 0 &&
    value.length < 16_384 && !/\s/u.test(value);
}

function unavailable(): never {
  throw new HttpsError("failed-precondition",
    "Form payments are not configured. Complete the Razorpay partner setup.");
}
