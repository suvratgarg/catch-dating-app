import type {ListEventRcsPreferencesCallableResponse as Options} from "../../shared/contracts/generated/listEventRcsPreferencesOutput";
import type {PreferenceChannel, SenderPreferenceScope} from "./senderPreferencePort";

export const record = (v: unknown): v is Record<string, unknown> =>
  typeof v === "object" && v !== null && !Array.isArray(v);
export const keys = (v: Record<string, unknown>, expected: string) =>
  Object.keys(v).sort().join(",") === expected;
export const integer = (v: unknown, min = 0): v is number =>
  typeof v === "number" && Number.isSafeInteger(v) && v >= min;
export const string = (v: unknown, max: number): v is string =>
  typeof v === "string" && v.length > 0 && v.length <= max;
export const id = (v: unknown): v is string =>
  typeof v === "string" && /^[A-Za-z0-9][A-Za-z0-9._:-]{0,159}$/.test(v);
const cursor = (v: unknown, channel: PreferenceChannel): v is string =>
  typeof v === "string" && (channel === "rcs" ? /^rcs-permission:[a-f0-9]{64}$/ :
    /^wa-permission:[a-f0-9]{64}$/).test(v);
const invalid = () => new Error("Invalid sender preference discovery response");

export function senderPreferenceOptions(value: unknown,
  scope: Omit<SenderPreferenceScope, "senderId">, after: string | null, channel: PreferenceChannel): Options {
  if (!record(value) || !keys(value, "attendeeId,configuredSenderId,eventId,nextCursor,previousSenderIds,serverTime") ||
      !id(value.eventId) || value.eventId !== scope.eventId || !id(value.attendeeId) ||
      value.attendeeId !== scope.attendeeId || !integer(value.serverTime) ||
      value.configuredSenderId !== null && !id(value.configuredSenderId) ||
      !Array.isArray(value.previousSenderIds) || value.previousSenderIds.length > 50 ||
      !value.previousSenderIds.every(id) ||
      new Set(value.previousSenderIds).size !== value.previousSenderIds.length ||
      value.configuredSenderId !== null && value.previousSenderIds.includes(value.configuredSenderId) ||
      value.nextCursor !== null && (!cursor(value.nextCursor, channel) ||
        after !== null && value.nextCursor <= after)) throw invalid();
  return {eventId: value.eventId, attendeeId: value.attendeeId, serverTime: value.serverTime,
    configuredSenderId: value.configuredSenderId,
    previousSenderIds: [...value.previousSenderIds], nextCursor: value.nextCursor};
}
