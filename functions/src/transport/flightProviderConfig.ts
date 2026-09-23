import {defineSecret, defineString} from "firebase-functions/params";

export const flightWebhookSecret = defineSecret("FLIGHT_WEBHOOK_SECRET");
export const flightWebhookBaseUrl =
  defineString("FLIGHT_WEBHOOK_BASE_URL");

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

