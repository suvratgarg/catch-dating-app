import {getRemoteConfig} from "firebase-admin/remote-config";

// Server-read defaults are release authority. Client Remote Config values and
// request fields cannot attest that the privacy migration has completed.
export const privateEventReleaseKeys = Object.freeze({
  privacy: "CATCH_PRIVATE_EVENT_PRIVACY_READY",
  seatWriters: "CATCH_PRIVATE_EVENT_SEAT_WRITERS_READY",
  offers: "CATCH_EVENT_OFFER_INTEGRATION_READY",
});
export const weddingPhoneImportReadyKey =
  "CATCH_WEDDING_PHONE_IMPORT_READY";

export interface PrivateEventReleaseReadiness {
  privacy: boolean;
  seatWriters: boolean;
  offers: boolean;
}

const closed: PrivateEventReleaseReadiness = Object.freeze({
  privacy: false, seatWriters: false, offers: false,
});

function enabledDefault(template: unknown, key: string): boolean {
  if (!template || typeof template !== "object") return false;
  const parameters = (template as Record<string, unknown>).parameters;
  if (!parameters || typeof parameters !== "object") return false;
  const parameter = (parameters as Record<string, unknown>)[key];
  if (!parameter || typeof parameter !== "object") return false;
  const defaultValue = (parameter as Record<string, unknown>).defaultValue;
  return !!defaultValue && typeof defaultValue === "object" &&
    (defaultValue as Record<string, unknown>).value === "true";
}

/** A fresh Admin read per request; failed or late reads stay closed. */
async function readReleaseTemplate(
  fetchTemplate: () => Promise<unknown> = () => getRemoteConfig().getTemplate(),
  timeoutMillis = 2000
): Promise<unknown | null> {
  if (!Number.isSafeInteger(timeoutMillis) || timeoutMillis < 1) return null;
  let timeout: ReturnType<typeof setTimeout> | undefined;
  try {
    return await Promise.race([
      fetchTemplate(),
      new Promise<never>((_resolve, reject) => {
        timeout = setTimeout(() => reject(new Error("Remote Config timed out")),
          timeoutMillis);
      }),
    ]);
  } catch {
    return null;
  } finally {
    if (timeout) clearTimeout(timeout);
  }
}

export async function readPrivateEventReleaseReadiness(
  fetchTemplate: () => Promise<unknown> = () => getRemoteConfig().getTemplate(),
  timeoutMillis = 2000
): Promise<PrivateEventReleaseReadiness> {
  const template = await readReleaseTemplate(fetchTemplate, timeoutMillis);
  if (template === null) return closed;
  return {
    privacy: enabledDefault(template, privateEventReleaseKeys.privacy),
    seatWriters: enabledDefault(template, privateEventReleaseKeys.seatWriters),
    offers: enabledDefault(template, privateEventReleaseKeys.offers),
  };
}

/** Server release authority; client Remote Config cannot grant access. */
export async function readWeddingPhoneImportReady(
  fetchTemplate: () => Promise<unknown> = () => getRemoteConfig().getTemplate(),
  timeoutMillis = 2000
): Promise<boolean> {
  const template = await readReleaseTemplate(fetchTemplate, timeoutMillis);
  return template !== null && enabledDefault(template,
    weddingPhoneImportReadyKey);
}
