import {createHash, createPrivateKey} from "node:crypto";
import {SecretManagerServiceClient} from "@google-cloud/secret-manager";
import {JWT} from "google-auth-library";
import {RcsConfig, parseRcsConfig} from "./rcsProtocol";
import type {RcsCredentials} from "./rcsWorker";
import {rbmTime} from "./googleRbmProtocol";

export const RCS_OAUTH_SCOPE =
  "https://www.googleapis.com/auth/rcsbusinessmessaging";
const TOKEN_URL = "https://oauth2.googleapis.com/token";
const versionPattern = new RegExp("^projects/[A-Za-z0-9-]+/secrets/" +
  "[A-Za-z0-9_-]+/versions/[1-9][0-9]*$");
const keyPattern = new RegExp("^-----BEGIN PRIVATE KEY-----\\n" +
  "[A-Za-z0-9+/=\\n]+\\n-----END PRIVATE KEY-----\\n?$");
const unavailable = () => new Error("RCS sender credential unavailable");
export type RcsSecretClient = Pick<SecretManagerServiceClient,
  "accessSecretVersion">;
export interface RcsServiceAccount {
  schema: "catch.event-rcs-credential/v1";
  senderId: string;
  agentId: string;
  region: RcsConfig["region"];
  clientEmail: string;
  privateKey: string;
}
interface OAuthClient {
  credentials: {expiry_date?: number | null};
  getAccessToken(): Promise<{token?: string | null}>;
}

/** Only numbered versions; no request body or ambient credential discovery. */
export async function readRcsSecret(client: RcsSecretClient, name: string,
  maxBytes: number): Promise<unknown> {
  if (typeof name !== "string" || name.length > 240 || /\s/.test(name) ||
      !versionPattern.test(name)) throw unavailable();
  const [version] = await client.accessSecretVersion({name},
    {timeout: 3000, retry: null});
  const data = version.payload?.data;
  if (!(data instanceof Uint8Array) || !data.length || data.length > maxBytes) {
    throw unavailable();
  }
  return JSON.parse(new TextDecoder("utf-8", {fatal: true}).decode(data));
}

/** Only the reviewed service-account fields can reach GoogleAuth. */
export function parseRcsServiceAccount(value: unknown,
  config: RcsConfig): Readonly<RcsServiceAccount> {
  parseRcsConfig(config);
  const v = value as Partial<RcsServiceAccount> | null;
  if (!v || typeof v !== "object" || Array.isArray(v) ||
      Object.keys(v).sort().join(",") !==
        "agentId,clientEmail,privateKey,region,schema,senderId" ||
      v.schema !== "catch.event-rcs-credential/v1" ||
      v.senderId !== config.senderId || v.agentId !== config.agentId ||
      v.region !== config.region || typeof v.clientEmail !== "string" ||
      v.clientEmail.length > 254 || /\s/.test(v.clientEmail) ||
      !/^[a-z0-9][a-z0-9._-]*@[a-z0-9-]+\.iam\.gserviceaccount\.com$/
        .test(v.clientEmail) || typeof v.privateKey !== "string" ||
      v.privateKey.length > 8192 ||
      !keyPattern.test(v.privateKey)) throw unavailable();
  try {
    const key = createPrivateKey(v.privateKey);
    const bits = key.asymmetricKeyDetails?.modulusLength ?? 0;
    if (key.asymmetricKeyType !== "rsa" || bits < 2048 || bits > 8192) {
      throw unavailable();
    }
  } catch {
    throw unavailable();
  }
  return Object.freeze({...v} as RcsServiceAccount);
}

/** Google owns signing, token refresh and concurrent refresh deduplication. */
export function createRcsOAuthClient(account: Readonly<RcsServiceAccount>) {
  const client = new JWT({email: account.clientEmail, key: account.privateKey,
    scopes: [RCS_OAUTH_SCOPE], eagerRefreshThresholdMillis: 60_000,
    forceRefreshOnFailure: false, useAuthRequestParameters: false,
    transporterOptions: {timeout: 8000, maxRedirects: 0, retry: false,
      maxContentLength: 8192}});
  client.transporter.interceptors.request.add({resolved: async (request) => {
    if (request.url.href !== TOKEN_URL || request.method !== "POST") {
      throw unavailable();
    }
    // The library supplies retry options of its own. A bounded exchange cannot
    // silently inherit retries or follow credentials to another endpoint.
    request.retry = false;
    request.retryConfig = {retry: 0};
    request.maxRedirects = 0;
    return request;
  }});
  return client;
}

/** Secret availability is checked even when the OAuth client has a token. */
export class RcsCredentialStore {
  private readonly clients = new Map<string, OAuthClient>();
  constructor(private readonly secrets: RcsSecretClient =
  new SecretManagerServiceClient(),
  private readonly createClient: (value: Readonly<RcsServiceAccount>) =>
    OAuthClient = createRcsOAuthClient,
  private readonly clock: () => number = Date.now) {}

  async access(config: RcsConfig): Promise<RcsCredentials> {
    let cacheKey: string | undefined;
    try {
      parseRcsConfig(config);
      const startedAt = this.clock();
      if (!rbmTime(startedAt)) throw unavailable();
      const account = parseRcsServiceAccount(await readRcsSecret(this.secrets,
        config.credentialVersion, 16_384), config);
      cacheKey = createHash("sha256").update(JSON.stringify([
        config.credentialVersion, account])).digest("hex");
      let client = this.clients.get(cacheKey);
      if (!client) {
        client = this.createClient(account);
        if (this.clients.size >= 32) {
          this.clients.delete(this.clients.keys().next().value!);
        }
        this.clients.set(cacheKey, client);
      }
      const {token} = await client.getAccessToken();
      const now = this.clock();
      const expiresAt = client.credentials.expiry_date;
      if (!rbmTime(now) || now < startedAt || !rbmTime(expiresAt) ||
          expiresAt <= now + 30_000 || expiresAt > now + 3_660_000 ||
          typeof token !== "string" || !token || token.length > 4096 ||
          /\s/.test(token) || !/^[A-Za-z0-9._~+/-]+=*$/.test(token)) {
        throw unavailable();
      }
      return Object.freeze({senderId: config.senderId, agentId: config.agentId,
        region: config.region, credentialVersion: config.credentialVersion,
        accessToken: token, expiresAt});
    } catch {
      if (cacheKey) this.clients.delete(cacheKey);
      // Do not attach a cause: SDK errors can retain assertions and keys.
      throw unavailable();
    }
  }
}
