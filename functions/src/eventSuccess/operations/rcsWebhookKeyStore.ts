import {SecretManagerServiceClient} from "@google-cloud/secret-manager";
import {readRcsSecret, RcsSecretClient} from "./rcsCredentialStore";
import {rcsSubscriptionId} from "./rcsSubscriptions";

const versionPattern = new RegExp("^projects/[A-Za-z0-9-]+/secrets/" +
  "EVENT_ASSISTANCE_RCS_WEBHOOK_KEYS/versions/[1-9][0-9]*$");
const unavailable = () => new Error("RCS webhook credential unavailable");
export interface RcsWebhookEndpoint {
  endpointId: string;
  agentId: string;
  clientToken: string;
}
export const validRcsEndpointId = (id: unknown): id is string =>
  typeof id === "string" && id.length <= 80 && !/\s/.test(id) &&
    /^[A-Za-z0-9][A-Za-z0-9_-]*$/.test(id);

/** Retained endpoint bindings accept queued callbacks across agent rotation. */
export function parseRcsWebhookEndpoints(value: unknown):
  ReadonlyArray<Readonly<RcsWebhookEndpoint>> {
  const v = value as {schema?: unknown; endpoints?: unknown} | null;
  if (!v || typeof v !== "object" || Array.isArray(v) ||
      Object.keys(v).sort().join(",") !== "endpoints,schema" ||
      v.schema !== "catch.event-rcs-webhooks/v1" ||
      !Array.isArray(v.endpoints) || v.endpoints.length < 1 ||
      v.endpoints.length > 20) throw unavailable();
  const ids = new Set<string>();
  const endpoints = v.endpoints.map((value: unknown) => {
    const entry = value as Partial<RcsWebhookEndpoint> | null;
    if (!entry || typeof entry !== "object" || Array.isArray(entry) ||
        Object.keys(entry).sort().join(",") !==
          "agentId,clientToken,endpointId" ||
        !validRcsEndpointId(entry.endpointId) || ids.has(entry.endpointId) ||
        typeof entry.agentId !== "string" ||
        typeof entry.clientToken !== "string" ||
        entry.clientToken.length < 32 || entry.clientToken.length > 256 ||
        !/^[\x21-\x7e]+$/.test(entry.clientToken)) throw unavailable();
    rcsSubscriptionId(entry.agentId, "0".repeat(64));
    ids.add(entry.endpointId);
    return Object.freeze({...entry} as RcsWebhookEndpoint);
  });
  return Object.freeze(endpoints);
}

export class RcsWebhookKeyStore {
  constructor(private readonly version: () => string = () =>
    process.env.EVENT_ASSISTANCE_RCS_WEBHOOK_KEY_VERSION ?? "",
  private readonly client: RcsSecretClient =
  new SecretManagerServiceClient()) {}

  async access(endpointId: string): Promise<Readonly<RcsWebhookEndpoint>> {
    try {
      if (!validRcsEndpointId(endpointId)) throw unavailable();
      const name = this.version();
      if (!versionPattern.test(name)) throw unavailable();
      const endpoints = parseRcsWebhookEndpoints(
        await readRcsSecret(this.client, name, 32_768));
      const selected = endpoints.find((e) => e.endpointId === endpointId);
      if (!selected) throw unavailable();
      return selected;
    } catch {
      throw unavailable();
    }
  }
}
