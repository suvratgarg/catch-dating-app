import {SecretManagerServiceClient} from "@google-cloud/secret-manager";
import {defineString} from "firebase-functions/params";
import {HttpsError} from "firebase-functions/v2/https";

export const flightProviderConfigVersion = defineString(
  "FLIGHT_PROVIDER_CONFIG_VERSION", {default: ""});
export const flightWebhookBaseUrl =
  defineString("FLIGHT_WEBHOOK_BASE_URL", {default: ""});

export interface FlightProviderConfig {
  apiKey: string;
  webhookSecret: string;
}

export async function readFlightProviderConfig({
  version, projectId, readSecret,
}: {
  version: string;
  projectId: string | undefined;
  readSecret: (version: string) => Promise<string>;
}): Promise<FlightProviderConfig | null> {
  const configured = version.trim();
  if (!configured) return null;
  const prefix = `projects/${projectId}/secrets/`;
  if (!projectId || !/^[a-z][a-z0-9-]{4,61}[a-z0-9]$/u.test(projectId) ||
      !configured.startsWith(prefix) ||
      !/^[A-Za-z0-9_-]{1,255}\/versions\/[1-9][0-9]*$/u.test(
        configured.slice(prefix.length))) {
    return flightProviderUnavailable();
  }
  try {
    const raw = await readSecret(configured);
    if (Buffer.byteLength(raw, "utf8") > 32 * 1024) {
      return flightProviderUnavailable();
    }
    const value = JSON.parse(raw) as Record<string, unknown>;
    if (!value || typeof value !== "object" || Array.isArray(value) ||
        Object.keys(value).sort().join(",") !== "apiKey,schema,webhookSecret" ||
        value.schema !== "catch.flight-provider/v1" ||
        !secret(value.apiKey, 1) || !secret(value.webhookSecret, 32)) {
      return flightProviderUnavailable();
    }
    return {apiKey: value.apiKey, webhookSecret: value.webhookSecret};
  } catch {
    return flightProviderUnavailable();
  }
}

export function loadFlightProviderConfig():
  Promise<FlightProviderConfig | null> {
  return readFlightProviderConfig({
    version: flightProviderConfigVersion.value(),
    projectId: process.env.GCLOUD_PROJECT,
    readSecret: async (name) => {
      const [value] = await new SecretManagerServiceClient()
        .accessSecretVersion({name});
      if (!value.payload?.data) return flightProviderUnavailable();
      return Buffer.from(value.payload.data).toString("utf8");
    },
  });
}

export function flightProviderUnavailable(): never {
  throw new HttpsError("failed-precondition",
    "Flight sync is not configured. Use manual arrival updates.");
}

function secret(value: unknown, minimum: number): value is string {
  return typeof value === "string" && value.length >= minimum &&
    value.length < 16_384 && !/\s/u.test(value);
}

export function defaultAlertBaseUrl(): string {
  const configured = flightWebhookBaseUrl.value().trim();
  if (configured) return configured.replace(/\/$/, "");
  const project = process.env.GCLOUD_PROJECT;
  if (!project) {
    throw new Error(
      "FLIGHT_WEBHOOK_BASE_URL is unset and GCLOUD_PROJECT is unavailable.");
  }
  return `https://asia-south1-${project}.cloudfunctions.net/` +
    "flightAlertWebhook";
}
