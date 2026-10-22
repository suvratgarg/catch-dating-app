import type {HostAcquisitionConsentHTTPRequest} from "../shared/contracts/generated/hostAcquisitionConsentHttpRequest";
import {acquisitionRoute, type MeasurementConsent} from "./catchMeasurement.ts";

export const hostServerConsentStorageKey = "catch_host_server_consent_v1";
const lifetimeMs = 30 * 24 * 60 * 60 * 1000;
type Choice = NonNullable<HostAcquisitionConsentHTTPRequest["choice"]>;
interface StoredGrant {
  capability: string;
  revision: string;
  choice: Choice;
  withdrawing: boolean;
}
export interface HostConsentInput {
  enabled: boolean;
  path: string;
  consent: MeasurementConsent | null;
}
interface ConsentPort {
  storage: Pick<Storage, "getItem" | "setItem" | "removeItem">;
  request: (request: HostAcquisitionConsentHTTPRequest) => Promise<unknown>;
  randomCapability: () => string;
  now: () => number;
  withLock: (run: () => Promise<void>) => Promise<void>;
  isCurrentChoice: (consent: MeasurementConsent | null) => boolean;
}

const capabilityPattern = /^[a-f0-9]{64}$/u;
function readGrant(storage: ConsentPort["storage"]): StoredGrant | null {
  const raw: unknown = JSON.parse(storage.getItem(hostServerConsentStorageKey) ?? "null");
  if (!raw || typeof raw !== "object") return null;
  const grant = raw as StoredGrant;
  if (!capabilityPattern.test(grant.capability) || typeof grant.revision !== "string" ||
      typeof grant.withdrawing !== "boolean" || grant.choice?.version !== 1 ||
      grant.choice.purpose !== "host_acquisition_measurement" ||
      grant.choice.analytics !== true || typeof grant.choice.advertising !== "boolean" ||
      !Number.isSafeInteger(grant.choice.chosenAt) || grant.choice.chosenAt <= 0) return null;
  return grant;
}

/** This owner only exchanges permission. It never queues business events or
 * blocks a form submission. A withdrawal survives reload and prevents a new
 * grant until the server acknowledges it. The activation caller must supply a
 * fresh notice/mode; legacy analytics consent alone must never enable this. */
export function createHostServerConsent(port: ConsentPort) {
  let revision = 0;
  let acknowledged: {capability: string; revision: string; expiresAt: number} | null = null;
  let work: Promise<void> = Promise.resolve();
  let pendingKey: string | null = null;
  let acknowledgedKey: string | null = null;

  function eligible(input: HostConsentInput) {
    return input.enabled && input.path !== "/" && acquisitionRoute(input.path) !== null &&
      input.consent?.version === 4 && input.consent.analytics === true;
  }
  function current(grant: StoredGrant) {
    const stored = readGrant(port.storage);
    return stored?.capability === grant.capability && !stored.withdrawing &&
      stored.revision === grant.revision;
  }
  async function withdraw(grant: StoredGrant) {
    // Persist before I/O. An interrupted request must resume as withdrawal,
    // never as a grant. Do not erase a sibling tab's newer capability.
    const stored = readGrant(port.storage);
    if (stored?.capability === grant.capability) {
      port.storage.setItem(hostServerConsentStorageKey, JSON.stringify({...grant, withdrawing: true}));
    }
    const response = await port.request({action: "revoke", capability: grant.capability});
    if (!response || typeof response !== "object" ||
        (response as {ok?: unknown}).ok !== true ||
        (response as {status?: unknown}).status !== "revoked") return false;
    if (readGrant(port.storage)?.capability === grant.capability) {
      port.storage.removeItem(hostServerConsentStorageKey);
    }
    return true;
  }
  function sync(input: HostConsentInput): Promise<void> {
    const key = JSON.stringify([eligible(input), input.consent]);
    if (pendingKey === key) return work;
    if (acknowledgedKey === key && eligible(input) && input.consent &&
        snapshot(input.consent.updatedAt)) return work;
    const call = ++revision;
    pendingKey = key;
    acknowledged = null; // Immediate local shutdown, before waiting on I/O.
    acknowledgedKey = null;
    const desired = input.consent ? {...input.consent} : null;
    work = work.catch(() => undefined).then(() => port.withLock(async () => {
      if (call !== revision || !port.isCurrentChoice(desired)) return;
      let grant = readGrant(port.storage);
      const allowed = eligible({...input, consent: desired});
      if (grant && (grant.withdrawing || !allowed || grant.revision !== desired?.updatedAt ||
          grant.choice.advertising !== desired?.marketing ||
          port.now() >= grant.choice.chosenAt + lifetimeMs)) {
        if (!await withdraw(grant)) return;
        grant = null;
      }
      if (call !== revision || !allowed || !desired) return;
      if (!grant) {
        const chosenAt = Date.parse(desired.updatedAt);
        if (!Number.isSafeInteger(chosenAt) || chosenAt <= 0 ||
            chosenAt > port.now() || port.now() - chosenAt > 300_000) return;
        const capability = port.randomCapability();
        if (!capabilityPattern.test(capability)) return;
        grant = {capability, revision: desired.updatedAt, withdrawing: false,
          choice: {version: 1, purpose: "host_acquisition_measurement",
            analytics: true, advertising: desired.marketing, chosenAt}};
        // If storage fails, no grant request is sent.
        port.storage.setItem(hostServerConsentStorageKey, JSON.stringify(grant));
      }
      const response = await port.request({action: "grant",
        capability: grant.capability, choice: grant.choice});
      if (call !== revision || !port.isCurrentChoice(desired)) {
        await withdraw(grant);
        return;
      }
      if (!current(grant) || !response || typeof response !== "object") return;
      const result = response as {ok?: unknown; status?: unknown; expiresAt?: unknown};
      if (result.ok === true && result.status === "active" &&
          result.expiresAt === grant.choice.chosenAt + lifetimeMs && port.now() < result.expiresAt) {
        acknowledged = {capability: grant.capability, revision: grant.revision,
          expiresAt: result.expiresAt};
        acknowledgedKey = key;
      }
    })).catch(() => { acknowledged = null; }).finally(() => {
      if (call === revision) pendingKey = null;
    });
    return work;
  }
  function snapshot(consentRevision: string): string | null {
    try {
      const grant = readGrant(port.storage);
      return acknowledged && acknowledged.revision === consentRevision &&
        port.now() < acknowledged.expiresAt && grant && current(grant) &&
        grant.capability === acknowledged.capability ? acknowledged.capability : null;
    } catch { return null; }
  }
  return {sync, snapshot};
}

/** Same-origin, bounded permission transport. Credentials/capabilities are
 * never URL parameters, diagnostic events or console output. */
export async function postHostServerConsent(request: HostAcquisitionConsentHTTPRequest): Promise<unknown> {
  const response = await fetch("/api/host-acquisition-consent", {
    method: "POST", credentials: "omit", cache: "no-store", referrerPolicy: "no-referrer",
    headers: {"Content-Type": "application/json"},
    body: JSON.stringify(request), signal: AbortSignal.timeout(10_000), keepalive: true,
  });
  return response.ok ? response.json() : null;
}
