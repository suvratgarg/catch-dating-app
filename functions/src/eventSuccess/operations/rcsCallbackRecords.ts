import type {EventAssistanceRcsCallbackDocument as Callback} from
  "../../shared/generated/eventAssistanceRcsCallbackDocument";
import type {EventAssistanceRcsCallbackIdentityDocument as Identity} from
  "../../shared/generated/eventAssistanceRcsCallbackIdentity";
import {validateEventAssistanceRcsCallbackDocument} from
  "../../shared/generated/validators/eventAssistanceRcsCallbackDocument";
import {validateEventAssistanceRcsCallbackIdentityDocument} from
  "../../shared/generated/validators/eventAssistanceRcsCallbackIdentity";
import {operationContentHash} from "../../operations/durableActions";

export type {
  Callback as RcsCallbackDocument,
  Identity as RcsCallbackIdentity,
};
export type RcsCallbackEvidence = Callback["evidence"];
export type RcsObservation = RcsCallbackEvidence["observation"];
export const rcsCallbackCollections = {
  callbacks: "eventAssistanceRcsCallbacks",
  identities: "eventAssistanceRcsCallbackIdentities",
} as const;

export function rcsCallbackReceiptKey(
  evidence: Pick<
    RcsCallbackEvidence,
    "agentId" | "endpointHash" | "eventFamily" | "providerEventId"
  >,
): string {
  return (
    "rcs-callback:" +
    operationContentHash([
      evidence.agentId,
      evidence.endpointHash,
      evidence.eventFamily,
      evidence.providerEventId,
    ])
  );
}

export function rcsCallbackId(
  evidence: Pick<RcsCallbackEvidence, "receiptKey" | "payloadHash">,
): string {
  if (
    !fullMatch(/^rcs-callback:[a-f0-9]{64}$/, evidence.receiptKey) ||
    !fullMatch(/^[a-f0-9]{64}$/, evidence.payloadHash)
  ) {
    throw invalid();
  }
  return (
    "rcs-event:" +
    operationContentHash([evidence.receiptKey, evidence.payloadHash])
  );
}

export function requireRcsCallbackId(value: string): string {
  if (!fullMatch(/^rcs-event:[a-f0-9]{64}$/, value)) throw invalid();
  return value;
}

export function parseRcsCallback(value: unknown, id: string): Callback {
  if (!validateEventAssistanceRcsCallbackDocument(value)) throw invalid();
  const e = value.evidence;
  const observation = e.observation;
  if (
    value.callbackId !== id ||
    id !== rcsCallbackId(e) ||
    e.receiptKey !== rcsCallbackReceiptKey(e) ||
    value.storedAt < e.receivedAt ||
    !safeIdentity(e.agentId) ||
    !safeIdentity(e.providerEventId) ||
    (e.providerOccurredAt !== null &&
      !rcsProviderTimestamp(e.providerOccurredAt)) ||
    ("providerMessageId" in observation &&
      !safeIdentity(observation.providerMessageId))
  ) {
    throw invalid();
  }
  if (e.eventFamily !== observationFamily(observation)) throw invalid();
  return value;
}

function observationFamily(
  value: RcsObservation,
): RcsCallbackEvidence["eventFamily"] {
  switch (value.kind) {
  case "expiration":
    return "serverEvent";
  case "delivery":
    return "userEvent";
  case "suggestion":
  case "subscription":
    return value.source === "event" ? "userEvent" : "message";
  case "unstructuredMessage":
    return "message";
  }
  const unhandled: never = value;
  throw new Error("Unsupported RCS observation: " + String(unhandled));
}

export function parseRcsCallbackIdentity(
  value: unknown,
  key: string,
): Identity {
  if (
    !validateEventAssistanceRcsCallbackIdentityDocument(value) ||
    value.receiptKey !== key ||
    !fullMatch(/^rcs-callback:[a-f0-9]{64}$/, value.receiptKey) ||
    !fullMatch(/^rcs-event:[a-f0-9]{64}$/, value.primaryCallbackId) ||
    (value.conflictedAt !== null &&
      value.conflictedAt < value.firstStoredAt)
  ) {
    throw invalid();
  }
  return value;
}

/** Preserve provider precision and unknown time, without Pub/Sub inference. */
export function rcsProviderTimestamp(value: unknown): boolean {
  if (typeof value !== "string" || value.length > 40) return false;
  const pattern = new RegExp(
    "^(\\d{4}-\\d{2}-\\d{2})T([01]\\d|2[0-3]):([0-5]\\d):" +
      "([0-5]\\d)(?:\\.\\d{1,9})?(Z|[+-](?:[01]\\d|2[0-3]):[0-5]\\d)$",
  );
  const m = pattern.exec(value);
  if (!m || m[0] !== value) return false;
  const day = Date.parse(m[1] + "T00:00:00Z");
  return (
    Number.isFinite(day) &&
    new Date(day).toISOString().startsWith(m[1]) &&
    Number.isFinite(Date.parse(value))
  );
}

export function rcsCallbackClock(value: number): number {
  if (!Number.isSafeInteger(value) || value < 0) throw invalid();
  return value;
}

function fullMatch(pattern: RegExp, value: string): boolean {
  return typeof value === "string" && pattern.exec(value)?.[0] === value;
}

function safeIdentity(value: string): boolean {
  return (
    !/\s/u.test(value) &&
    !Array.from(value).some(
      (point) => point.charCodeAt(0) < 32 || point.charCodeAt(0) === 127,
    ) &&
    Buffer.from(value, "utf8").toString("utf8") === value
  );
}

function invalid(): Error {
  return new Error("Invalid stored RCS callback evidence");
}
