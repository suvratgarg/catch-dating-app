import {getRemoteConfig} from "firebase-admin/remote-config";

// Server-read defaults are release authority. Client Remote Config values and
// request fields cannot attest that the privacy migration has completed.
export const privateEventReleaseKeys = Object.freeze({
  privacy: "CATCH_PRIVATE_EVENT_PRIVACY_READY",
  seatWriters: "CATCH_PRIVATE_EVENT_SEAT_WRITERS_READY",
  offers: "CATCH_EVENT_OFFER_INTEGRATION_READY",
});

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
export async function readPrivateEventReleaseReadiness(
  fetchTemplate: () => Promise<unknown> = () => getRemoteConfig().getTemplate(),
  timeoutMillis = 2000
): Promise<PrivateEventReleaseReadiness> {
  if (!Number.isSafeInteger(timeoutMillis) || timeoutMillis < 1) return closed;
  let timeout: ReturnType<typeof setTimeout> | undefined;
  try {
    const template = await Promise.race([
      fetchTemplate(),
      new Promise<never>((_resolve, reject) => {
        timeout = setTimeout(() => reject(new Error("Remote Config timed out")),
          timeoutMillis);
      }),
    ]);
    return {
      privacy: enabledDefault(template, privateEventReleaseKeys.privacy),
      seatWriters: enabledDefault(template,
        privateEventReleaseKeys.seatWriters),
      offers: enabledDefault(template, privateEventReleaseKeys.offers),
    };
  } catch {
    return closed;
  } finally {
    if (timeout) clearTimeout(timeout);
  }
}
