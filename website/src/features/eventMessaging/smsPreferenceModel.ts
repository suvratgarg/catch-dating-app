import {record, keys, integer, string, id, senderPreferenceOptions} from "./senderPreferenceParsing";
import type {EventAssistanceSmsPreferenceCallableResponse as Response} from "../../shared/contracts/generated/eventAssistanceSmsPreferenceCallableResponse";
import type {ListEventSmsPreferencesCallableResponse as Options} from "../../shared/contracts/generated/listEventSmsPreferencesOutput";

export type SmsPreferenceScope = {eventId: string; attendeeId: string; senderId: string};
export type SmsPreferenceView = Response["view"];
export type SmsPreferenceState = {kind: "hidden" | "loading" | "error"} | {
  kind: "ready"; view: SmsPreferenceView; pending: boolean; uncertain: boolean;
  notice: string; earlier: boolean;
};
const preferences = {notSet: true, enabled: true, disabled: true, expired: true} satisfies Record<SmsPreferenceView["preference"], true>;
const availability = {ready: true, senderUnavailable: true,
  eventClosed: true, notAdmitted: true, verifyPhone: true} satisfies Record<SmsPreferenceView["availability"], true>;
const outcomes = {read: true, applied: true, replayed: true, conflict: true} satisfies Record<Response["outcome"], true>;
const invalid = () => new Error("Invalid SMS preference response");

/** Validate and copy the closed server projection before it reaches private cache. */
export function smsPreferenceResponse(value: unknown, scope: SmsPreferenceScope,
  operation: "read" | "mutation"): Response {
  if (!record(value) || !keys(value, "outcome,view") || !record(value.view) ||
      typeof value.outcome !== "string" || !Object.hasOwn(outcomes, value.outcome) ||
      (value.outcome === "read") !== (operation === "read")) throw invalid();
  const v = value.view;
  if (!keys(v, "attendeeId,availability,canEnable,consent,eventId,expiresAt,phoneLastFour,preference,reviewHash,revision,senderId,serverTime") ||
      !id(v.eventId) || v.eventId !== scope.eventId || !id(v.attendeeId) ||
      v.attendeeId !== scope.attendeeId || !id(v.senderId) || v.senderId !== scope.senderId ||
      !integer(v.serverTime) ||
      v.revision !== null && !integer(v.revision, 1) ||
      v.expiresAt !== null && !integer(v.expiresAt) ||
      typeof v.preference !== "string" || !Object.hasOwn(preferences, v.preference) ||
      typeof v.availability !== "string" || !Object.hasOwn(availability, v.availability) ||
      typeof v.canEnable !== "boolean" ||
      v.phoneLastFour !== null && (typeof v.phoneLastFour !== "string" || !/^\d{4}$/.test(v.phoneLastFour)) ||
      typeof v.reviewHash !== "string" || !/^[a-f0-9]{64}$/.test(v.reviewHash) ||
      !record(v.consent) || !keys(v.consent, "text,version") ||
      v.consent.version !== "catch-event-service-sms-v1" || !string(v.consent.text, 500)) throw invalid();
  // A usable offer must contain the identity, verified endpoint and consent shown to the guest.
  if (v.canEnable !== (v.availability === "ready") ||
      v.availability === "ready" && !v.phoneLastFour ||
      v.revision === null && (v.preference !== "notSet" || v.expiresAt !== null) ||
      v.preference !== "notSet" && (v.revision === null || v.expiresAt === null || !v.phoneLastFour) ||
      v.preference === "enabled" && (v.expiresAt as number) <= v.serverTime ||
      v.preference === "expired" && (v.expiresAt as number) > v.serverTime) throw invalid();
  return {outcome: value.outcome as Response["outcome"], view: {
    eventId: v.eventId, attendeeId: v.attendeeId, senderId: v.senderId,
    serverTime: v.serverTime, revision: v.revision,
    preference: v.preference as SmsPreferenceView["preference"], canEnable: v.canEnable,
    availability: v.availability as SmsPreferenceView["availability"],
    phoneLastFour: v.phoneLastFour, expiresAt: v.expiresAt, reviewHash: v.reviewHash,
    consent: {version: v.consent.version, text: v.consent.text},
  }};
}

export function smsPreferenceOptions(value: unknown,
  scope: Omit<SmsPreferenceScope, "senderId">, after: string | null): Options {
  return senderPreferenceOptions(value, scope, after, "sms");
}

export {newerSenderPreference as newerSmsPreference} from "./senderPreferencePort";
