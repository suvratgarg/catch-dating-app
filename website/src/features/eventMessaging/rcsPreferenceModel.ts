import {record, keys, integer, string, id, senderPreferenceOptions} from "./senderPreferenceParsing";
import type {EventRcsPreferenceCallableResponse as Response} from "../../shared/contracts/generated/eventRcsPreferenceOutput";
import type {ListEventRcsPreferencesCallableResponse as Options} from "../../shared/contracts/generated/listEventRcsPreferencesOutput";

export type RcsPreferenceScope = {eventId: string; attendeeId: string; senderId: string};
export type RcsPreferenceView = Response["view"];
export type RcsPreferenceState = {kind: "hidden" | "loading" | "error"} | {
  kind: "ready"; view: RcsPreferenceView; pending: boolean; uncertain: boolean;
  notice: string; earlier: boolean;
};
const preferences = {notSet: true, enabled: true, disabled: true, expired: true} satisfies Record<RcsPreferenceView["preference"], true>;
const availability = {ready: true, senderUnavailable: true, subscriptionUnavailable: true,
  eventClosed: true, notAdmitted: true, verifyPhone: true} satisfies Record<RcsPreferenceView["availability"], true>;
const outcomes = {read: true, applied: true, replayed: true, conflict: true} satisfies Record<Response["outcome"], true>;
const invalid = () => new Error("Invalid RCS preference response");

/** Validate and copy the closed server projection before it reaches private cache. */
export function rcsPreferenceResponse(value: unknown, scope: RcsPreferenceScope,
  operation: "read" | "mutation"): Response {
  if (!record(value) || !keys(value, "outcome,view") || !record(value.view) ||
      typeof value.outcome !== "string" || !Object.hasOwn(outcomes, value.outcome) ||
      (value.outcome === "read") !== (operation === "read")) throw invalid();
  const v = value.view;
  if (!keys(v, "attendeeId,availability,canEnable,consent,eventId,eventTitle,expiresAt,phoneLastFour,preference,reviewHash,revision,sender,senderId,serverTime") ||
      !id(v.eventId) || v.eventId !== scope.eventId || !id(v.attendeeId) ||
      v.attendeeId !== scope.attendeeId || !id(v.senderId) || v.senderId !== scope.senderId ||
      !string(v.eventTitle, 160) || !integer(v.serverTime) ||
      v.revision !== null && !integer(v.revision, 1) ||
      v.expiresAt !== null && !integer(v.expiresAt) ||
      typeof v.preference !== "string" || !Object.hasOwn(preferences, v.preference) ||
      typeof v.availability !== "string" || !Object.hasOwn(availability, v.availability) ||
      typeof v.canEnable !== "boolean" ||
      v.phoneLastFour !== null && (typeof v.phoneLastFour !== "string" || !/^\d{4}$/.test(v.phoneLastFour)) ||
      typeof v.reviewHash !== "string" || !/^[a-f0-9]{64}$/.test(v.reviewHash) ||
      !record(v.consent) || !keys(v.consent, "text,version") ||
      v.consent.version !== "catch-event-service-rcs-v1" || !string(v.consent.text, 500) ||
      v.sender !== null && (!record(v.sender) || !keys(v.sender, "displayName") ||
        !string(v.sender.displayName, 160))) throw invalid();
  // A usable offer must contain the identity, verified endpoint and consent shown to the guest.
  if (v.canEnable && (v.availability !== "ready" || !v.sender || !v.phoneLastFour)) throw invalid();
  return {outcome: value.outcome as Response["outcome"], view: {
    eventId: v.eventId, attendeeId: v.attendeeId, senderId: v.senderId,
    eventTitle: v.eventTitle, serverTime: v.serverTime, revision: v.revision,
    preference: v.preference as RcsPreferenceView["preference"], canEnable: v.canEnable,
    availability: v.availability as RcsPreferenceView["availability"],
    phoneLastFour: v.phoneLastFour, expiresAt: v.expiresAt, reviewHash: v.reviewHash,
    consent: {version: v.consent.version, text: v.consent.text},
    sender: v.sender === null ? null : {displayName: v.sender.displayName as string},
  }};
}

export function rcsPreferenceOptions(value: unknown,
  scope: Omit<RcsPreferenceScope, "senderId">, after: string | null): Options {
  return senderPreferenceOptions(value, scope, after, "rcs");
}

export {newerSenderPreference as newerRcsPreference} from "./senderPreferencePort";
