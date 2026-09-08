import type {EventWhatsappPreferenceCallableResponse as Response} from "../../shared/contracts/generated/eventWhatsappPreferenceCallableResponse";
import type {ListEventWhatsappPreferencesCallableResponse as Options} from "../../shared/contracts/generated/listEventWhatsappPreferencesOutput";
import {record, keys, integer, string, id, senderPreferenceOptions} from "./senderPreferenceParsing";
import type {SenderPreferenceScope, SenderPreferenceState} from "./senderPreferencePort";

export type WhatsappPreferenceView = Response["view"];
export type WhatsappPreferenceState = SenderPreferenceState<WhatsappPreferenceView>;
const hash = (v: unknown): v is string => typeof v === "string" && /^[a-f0-9]{64}$/.test(v);
const preferences = {notSet: true, enabled: true, disabled: true, expired: true} satisfies Record<WhatsappPreferenceView["preference"], true>;
const availability = {ready: true, senderUnavailable: true, eventClosed: true,
  notAdmitted: true, verifyPhone: true} satisfies Record<WhatsappPreferenceView["availability"], true>;
const outcomes = {read: true, applied: true, replayed: true, conflict: true} satisfies Record<Response["outcome"], true>;
const invalid = () => new Error("Invalid WhatsApp preference response");

export function whatsappPreferenceResponse(value: unknown, scope: SenderPreferenceScope,
  operation: "read" | "mutation"): Response {
  if (!record(value) || !keys(value, "outcome,view") || !record(value.view) ||
      typeof value.outcome !== "string" || !Object.hasOwn(outcomes, value.outcome) ||
      (value.outcome === "read") !== (operation === "read")) throw invalid();
  const v = value.view;
  if (!keys(v, "attendeeId,availability,canEnable,consent,eventId,expiresAt,phoneLastFour,preference,revision,sender,senderId,serverTime,stopRecordHash") ||
      !id(v.eventId) || v.eventId !== scope.eventId || !id(v.attendeeId) || v.attendeeId !== scope.attendeeId ||
      !id(v.senderId) || v.senderId !== scope.senderId || !integer(v.serverTime) ||
      v.revision !== null && !integer(v.revision, 1) || v.expiresAt !== null && !integer(v.expiresAt) ||
      typeof v.preference !== "string" || !Object.hasOwn(preferences, v.preference) ||
      typeof v.availability !== "string" || !Object.hasOwn(availability, v.availability) ||
      typeof v.canEnable !== "boolean" || v.stopRecordHash !== null && !hash(v.stopRecordHash) ||
      v.phoneLastFour !== null && (typeof v.phoneLastFour !== "string" || !/^\d{4}$/.test(v.phoneLastFour)) ||
      !record(v.consent) || !keys(v.consent, "text,version") ||
      v.consent.version !== "catch-event-service-whatsapp-v1" || !string(v.consent.text, 500) ||
      v.sender !== null && (!record(v.sender) || !keys(v.sender, "bindingHash,displayName,displayPhoneNumber") ||
        !string(v.sender.displayName, 160) || !string(v.sender.displayPhoneNumber, 32) || v.sender.displayPhoneNumber.length < 7 ||
        !hash(v.sender.bindingHash))) throw invalid();
  if (v.canEnable && (v.availability !== "ready" || !v.sender || !v.phoneLastFour)) throw invalid();
  return {outcome: value.outcome as Response["outcome"], view: {
    eventId: v.eventId, attendeeId: v.attendeeId, senderId: v.senderId,
    serverTime: v.serverTime, revision: v.revision,
    preference: v.preference as WhatsappPreferenceView["preference"],
    availability: v.availability as WhatsappPreferenceView["availability"],
    canEnable: v.canEnable, phoneLastFour: v.phoneLastFour, expiresAt: v.expiresAt,
    stopRecordHash: v.stopRecordHash, consent: {version: v.consent.version, text: v.consent.text},
    sender: v.sender === null ? null : {displayName: v.sender.displayName as string,
      displayPhoneNumber: v.sender.displayPhoneNumber as string, bindingHash: v.sender.bindingHash as string},
  }};
}

export function whatsappPreferenceOptions(value: unknown,
  scope: Omit<SenderPreferenceScope, "senderId">, after: string | null): Options {
  return senderPreferenceOptions(value, scope, after, "whatsapp");
}

/** STOP can change while the preference revision stays the same. */
export function whatsappReviewKey(view: WhatsappPreferenceView): string {
  return JSON.stringify([view.sender?.bindingHash ?? null, view.stopRecordHash]);
}
