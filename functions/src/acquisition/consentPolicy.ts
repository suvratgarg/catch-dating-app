import {createHash} from "node:crypto";
import type {HostAcquisitionConsentDocument} from
  "../shared/generated/hostAcquisitionConsentDocument";
import type {HostAcquisitionConsentHTTPRequest} from
  "../shared/generated/hostAcquisitionConsentHttpRequest";

/** A new purpose/version is intentional: old intake metadata is not permission
 * for server delivery. Operational lead intake remains independent. */
export const HOST_CONSENT_VERSION = 1;
export const HOST_CONSENT_PURPOSE = "host_acquisition_measurement";
export const HOST_ATTRIBUTION_LIFETIME_MS = 30 * 24 * 60 * 60 * 1000;
export const HOST_CHOICE_CLOCK_TOLERANCE_MS = 5 * 60 * 1000;
export const HOST_META_DELIVERY_LIFETIME_MS = 24 * 60 * 60 * 1000;
export const HOST_META_MAX_ATTEMPTS = 5;

export type HostConsentChoice =
  NonNullable<HostAcquisitionConsentHTTPRequest["choice"]>;
export type HostConsentAuthority =
  NonNullable<HostAcquisitionConsentDocument["authority"]>;

const isMillis = (value: unknown): value is number =>
  Number.isSafeInteger(value) && Number(value) > 0;

/** Capability values never become document ids, logs or provider fields.
 * Callers generate 32 random bytes; this checks only their wire shape. */
export function hostConsentKey(capability: unknown): string | null {
  if (typeof capability !== "string" ||
      !/^[a-f0-9]{64}$/u.test(capability)) return null;
  return createHash("sha256")
    .update(`catch-host-consent-v1:${capability}`).digest("hex");
}

/** Reject arbitrary fields, legacy consent and future grants.
 * Lifetime starts at the choice, not a later retry or server visit. */
export function parseHostConsentChoice(
  value: unknown, now: number,
): HostConsentChoice | null {
  if (!value || typeof value !== "object" || Array.isArray(value) ||
      !isMillis(now)) return null;
  const row = value as Record<string, unknown>;
  const keys = ["version", "purpose", "analytics", "advertising", "chosenAt"];
  if (Object.keys(row).length !== keys.length ||
      keys.some((key) => !Object.hasOwn(row, key)) ||
      row.version !== HOST_CONSENT_VERSION ||
      row.purpose !== HOST_CONSENT_PURPOSE ||
      row.analytics !== true || typeof row.advertising !== "boolean" ||
      !isMillis(row.chosenAt) || row.chosenAt > now ||
      now - row.chosenAt > HOST_CHOICE_CLOCK_TOLERANCE_MS) return null;
  return {version: 1, purpose: HOST_CONSENT_PURPOSE,
    analytics: true, advertising: row.advertising, chosenAt: row.chosenAt};
}

/** Used only for a previously absent capability. A revoked capability is a
 * tombstone; re-consent must use a new capability, never overwrite that row. */
export function newHostConsentAuthority(
  choice: HostConsentChoice, now: number,
): HostConsentAuthority {
  const parsed = parseHostConsentChoice(choice, now);
  if (!parsed) throw new Error("Invalid Host measurement choice.");
  return {...parsed, acceptedAt: now,
    expiresAt: parsed.chosenAt + HOST_ATTRIBUTION_LIFETIME_MS, revokedAt: null};
}

/** Recheck the current server row at each reservation AND dispatch. Neither an
 * old request snapshot nor a queued permission revision grants authority. */
export function hasCurrentHostConsent(
  value: unknown, now: number, purpose: "analytics" | "advertising",
): value is HostConsentAuthority {
  if (!value || typeof value !== "object" || Array.isArray(value) ||
      !isMillis(now)) return false;
  const row = value as Record<string, unknown>;
  return row.version === HOST_CONSENT_VERSION &&
    row.purpose === HOST_CONSENT_PURPOSE &&
    row.analytics === true && typeof row.advertising === "boolean" &&
    (purpose === "analytics" || row.advertising === true) &&
    row.revokedAt === null &&
    isMillis(row.chosenAt) && isMillis(row.acceptedAt) &&
    row.chosenAt <= row.acceptedAt && row.acceptedAt <= now &&
    row.acceptedAt - row.chosenAt <= HOST_CHOICE_CLOCK_TOLERANCE_MS &&
    row.expiresAt === row.chosenAt + HOST_ATTRIBUTION_LIFETIME_MS &&
    now < row.expiresAt;
}

export interface HostMetaDispatchState {
  eventId: string;
  acceptedAt: number;
  attempts: number;
  nextAttemptAt: number;
  status: "pending" | "sending" | "accepted" | "unknown" | "stopped";
}

export type HostMetaDispatchDecision =
  | {kind: "dispatch"}
  | {kind: "wait"}
  | {kind: "stop"; reason: "disabled" | "invalid" | "consent" |
      "expired" | "attempt_limit" | "terminal_or_inflight"};

const hostLeadId = new RegExp(
  "^host_lead_[0-9]{13}_[a-f0-9]{8}(?:-[a-f0-9]{4}){3}-[a-f0-9]{12}$", "u");

/** Twenty-four hours leaves margin inside Meta's 48-hour browser/server
 * deduplication window. Unknown transport outcomes require reconciliation;
 * ordinary retry must never turn them into a second provider submission. */
export function hostMetaDispatchDecision(input: {
  enabled: boolean;
  consent: unknown;
  state: HostMetaDispatchState;
  now: number;
}): HostMetaDispatchDecision {
  if (!input.enabled) return {kind: "stop", reason: "disabled"};
  const {state, now} = input;
  if (!state || !isMillis(now) || !isMillis(state.acceptedAt) ||
      !isMillis(state.nextAttemptAt) || state.acceptedAt > now ||
      typeof state.eventId !== "string" ||
      !hostLeadId.test(state.eventId) ||
      Number(state.eventId.split("_")[2]) !== state.acceptedAt ||
      !Number.isSafeInteger(state.attempts) || state.attempts < 0) {
    return {kind: "stop", reason: "invalid"};
  }
  if (!hasCurrentHostConsent(input.consent, now, "advertising")) {
    return {kind: "stop", reason: "consent"};
  }
  if (now - state.acceptedAt >= HOST_META_DELIVERY_LIFETIME_MS) {
    return {kind: "stop", reason: "expired"};
  }
  if (state.attempts >= HOST_META_MAX_ATTEMPTS) {
    return {kind: "stop", reason: "attempt_limit"};
  }
  if (state.status !== "pending") {
    return {kind: "stop", reason: "terminal_or_inflight"};
  }
  return state.nextAttemptAt > now ? {kind: "wait"} : {kind: "dispatch"};
}
