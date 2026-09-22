import {SecretManagerServiceClient} from "@google-cloud/secret-manager";
import type {RazorpayMerchantToken} from "./razorpayFormProvider";

export interface RazorpayCredentialBinding {
  organizerId: string;
  connectionId: string;
  accountId: string;
  mode: "test" | "live";
}

export interface RazorpayStoredCredential extends RazorpayCredentialBinding {
  token: RazorpayMerchantToken;
  webhookSecret: string;
}

export interface FormCredentialSecretStore {
  add(parent: string, value: string): Promise<string>;
  read(version: string): Promise<string>;
  disable(version: string): Promise<void>;
}

/** Only a pinned, project-local secret version can supply a merchant token. */
export class RazorpayCredentialVault {
  private readonly parent: string;

  constructor(projectId: string, secretId: string,
    private readonly store: FormCredentialSecretStore
    = new GoogleSecretStore()) {
    if (!/^[a-z][a-z0-9-]{4,61}[a-z0-9]$/u.test(projectId) ||
        !/^[A-Za-z0-9_-]{1,255}$/u.test(secretId)) {
      throw new Error("Invalid Razorpay credential vault configuration.");
    }
    this.parent = `projects/${projectId}/secrets/${secretId}`;
  }

  async save(credential: RazorpayStoredCredential): Promise<string> {
    validateCredential(credential, credential);
    const version = await this.store.add(this.parent, JSON.stringify({
      schema: "catch.organizer-razorpay/v1", ...credential,
    }));
    this.assertVersion(version);
    return version;
  }

  async access(version: string, binding: RazorpayCredentialBinding):
    Promise<RazorpayStoredCredential> {
    try {
      this.assertVersion(version);
      const raw = await this.store.read(version);
      if (Buffer.byteLength(raw, "utf8") > 60 * 1024) unavailable();
      const envelope: unknown = JSON.parse(raw);
      if (!record(envelope) ||
          envelope.schema !== "catch.organizer-razorpay/v1") unavailable();
      const credential = {...envelope};
      delete credential.schema;
      validateCredential(credential, binding);
      return credential;
    } catch {
      unavailable();
    }
  }

  async disable(version: string): Promise<void> {
    this.assertVersion(version);
    await this.store.disable(version);
  }

  private assertVersion(version: string): void {
    const prefix = `${this.parent}/versions/`;
    if (!version.startsWith(prefix) ||
        !/^[1-9][0-9]*$/u.test(version.slice(prefix.length))) unavailable();
  }
}

class GoogleSecretStore implements FormCredentialSecretStore {
  constructor(private readonly client = new SecretManagerServiceClient()) {}

  async add(parent: string, value: string): Promise<string> {
    const [version] = await this.client.addSecretVersion({parent,
      payload: {data: Buffer.from(value, "utf8")}});
    if (!version.name) unavailable();
    return version.name;
  }

  async read(version: string): Promise<string> {
    const [result] = await this.client.accessSecretVersion({name: version});
    const bytes = result.payload?.data;
    if (!bytes) unavailable();
    return Buffer.from(bytes).toString("utf8");
  }

  async disable(version: string): Promise<void> {
    await this.client.disableSecretVersion({name: version});
  }
}

function validateCredential(value: unknown, binding: RazorpayCredentialBinding):
  asserts value is RazorpayStoredCredential {
  if (!record(value) || Object.keys(value).sort().join(",") !==
      "accountId,connectionId,mode,organizerId,token,webhookSecret" ||
      value.organizerId !== binding.organizerId ||
      value.connectionId !== binding.connectionId ||
      value.accountId !== binding.accountId || value.mode !== binding.mode ||
      !id(value.organizerId) || !id(value.connectionId) ||
      typeof value.accountId !== "string" ||
      !/^acc_[A-Za-z0-9]+$/u.test(value.accountId) ||
      (value.mode !== "test" && value.mode !== "live") ||
      typeof value.webhookSecret !== "string" ||
      !/^[A-Za-z0-9_-]{32,128}$/u.test(value.webhookSecret) ||
      !record(value.token)) unavailable();
  const token = value.token;
  if (Object.keys(token).sort().join(",") !==
      "accessToken,accountId,expiresAt,publicToken,refreshToken" ||
      token.accountId !== value.accountId || !secret(token.accessToken) ||
      !secret(token.refreshToken) || !secret(token.publicToken) ||
      !token.publicToken.startsWith(`rzp_${value.mode}_oauth_`) ||
      typeof token.expiresAt !== "number" ||
      !Number.isSafeInteger(token.expiresAt) || token.expiresAt <= 0) {
    unavailable();
  }
}

function id(value: unknown): value is string {
  return typeof value === "string" && /^[A-Za-z0-9_-]{1,128}$/u.test(value);
}

function secret(value: unknown): value is string {
  return typeof value === "string" && value.length > 0 &&
    value.length <= 16384 && !/\s/u.test(value);
}

function record(value: unknown): value is Record<string, unknown> {
  return !!value && typeof value === "object" && !Array.isArray(value);
}

function unavailable(): never {
  throw new Error("Organizer payment credential unavailable.");
}
