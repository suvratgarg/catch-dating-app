import {createHash, createHmac, timingSafeEqual} from "node:crypto";
import {rcsCallbackReceiptKey, rcsProviderTimestamp,
  RcsCallbackEvidence, RcsObservation} from "./rcsCallbackRecords";

export type {RcsCallbackEvidence, RcsObservation} from "./rcsCallbackRecords";

export const RCS_CALLBACK_MAX_BYTES = 64 * 1024;
const maxPayloadBytes = 40 * 1024;
type JsonObject = Record<string, unknown>;

type SuggestionCorrelation = Extract<RcsObservation,
  {kind: "suggestion"}>["correlation"];

// A successful parse proves this invocation checked the signed bytes. It does
// not grant attendance, consent, sender, spending or fallback authority.
export class VerifiedRcsCallback {
  readonly #value: Readonly<RcsCallbackEvidence>;

  private constructor(value: Readonly<RcsCallbackEvidence>) {
    this.#value = value;
  }

  get evidence(): Readonly<RcsCallbackEvidence> {
    return this.#value;
  }

  static receive(input: {
    rawBody: Buffer; signature: unknown; clientToken: string;
    expectedAgentId: string; receivedAt: number;
  }): RcsCallbackResult {
    requireConfiguration(input.clientToken, input.expectedAgentId);
    if (!Number.isSafeInteger(input.receivedAt) || input.receivedAt < 0) {
      throw new Error("Invalid RCS reception clock");
    }
    const envelope = parseJson(input.rawBody, RCS_CALLBACK_MAX_BYTES);
    const message = object(envelope?.message);
    const payload = decodeBase64(message?.data, maxPayloadBytes);
    const signature = decodeBase64(input.signature, 64);
    if (!payload || !signature || signature.length !== 64 ||
        !timingSafeEqual(signature,
          createHmac("sha512", input.clientToken).update(payload).digest())) {
      return {kind: "rejected", reason: "authentication"};
    }
    const event = parseJson(payload, maxPayloadBytes);
    if (!event) return {kind: "rejected", reason: "payload"};
    if (event.agentId !== input.expectedAgentId) {
      return {kind: "rejected", reason: "agent"};
    }
    // Headers, attributes, Pub/Sub ids and publishTime are outside the HMAC.
    // Only the decoded, authenticated object can select a supported variant.
    const parsed = observation(event);
    if (parsed.kind !== "parsed") return parsed;
    const {phone, ...value} = parsed.value;
    const endpointHash = createHash("sha256").update(phone).digest("hex");
    const evidence: RcsCallbackEvidence = {...value, endpointHash,
      agentId: input.expectedAgentId, receivedAt: input.receivedAt,
      payloadHash: createHash("sha256").update(payload).digest("hex"),
      receiptKey: rcsCallbackReceiptKey({agentId: input.expectedAgentId,
        endpointHash, eventFamily: value.eventFamily,
        providerEventId: value.providerEventId})};
    Object.freeze(evidence.observation);
    if (evidence.observation.kind === "suggestion") {
      Object.freeze(evidence.observation.correlation);
    }
    const callback = new VerifiedRcsCallback(Object.freeze(evidence));
    Object.freeze(callback);
    return {kind: "verified", callback};
  }
}

export type RcsCallbackResult =
  | {kind: "verified"; callback: VerifiedRcsCallback}
  | {kind: "ignored"; reason: "unsupported"}
  | {kind: "rejected"; reason: "authentication" | "agent" | "payload"};

/** Echo the initial challenge secret only after its token matches. */
export function verifyRcsWebhookChallenge(rawBody: Buffer,
  clientToken: string): string | null {
  requireConfiguration(clientToken, "challenge");
  const body = parseJson(rawBody, 4096);
  if (!body || Object.keys(body).sort().join(",") !== "clientToken,secret" ||
      typeof body.clientToken !== "string" ||
      typeof body.secret !== "string" || !identity(body.secret, 1024)) {
    return null;
  }
  const expected = Buffer.from(clientToken, "utf8");
  const supplied = Buffer.from(body.clientToken, "utf8");
  return supplied.length === expected.length &&
    timingSafeEqual(supplied, expected) ? body.secret : null;
}

/** Correlation only; requires a stored attempt/recipient/episode binding. */
export function rcsNativeReplyId(attemptId: string, choiceIndex: number) {
  if (!/^attempt:[a-f0-9]{64}$/.test(attemptId) || attemptId.length !== 72 ||
      !Number.isSafeInteger(choiceIndex) ||
      choiceIndex < 0 || choiceIndex > 9) {
    throw new Error("Invalid RCS reply correlation");
  }
  return "ce-rcs1." + attemptId.slice(8) + "." + choiceIndex;
}

type Parsed = {kind: "parsed"; value: Pick<RcsCallbackEvidence,
  "providerEventId" | "eventFamily" | "providerOccurredAt" | "observation"> &
  {phone: string}};
type ParseResult = Parsed | Exclude<RcsCallbackResult, {kind: "verified"}>;
const invalid = (): ParseResult => ({kind: "rejected", reason: "payload"});
const unsupported = (): ParseResult =>
  ({kind: "ignored", reason: "unsupported"});

function observation(event: JsonObject): ParseResult {
  const contents = ["text", "suggestionResponse", "userFile", "location"]
    .filter((key) => Object.hasOwn(event, key));
  if (contents.length > 1 ||
      contents.length > 0 && Object.hasOwn(event, "eventType")) {
    return invalid();
  }
  const type = event.eventType;
  const serverEvent = type === "TTL_EXPIRATION_REVOKED" ||
    type === "TTL_EXPIRATION_REVOKE_FAILED";
  const phone = serverEvent ? event.phoneNumber : event.senderPhoneNumber;
  if (serverEvent && Object.hasOwn(event, "senderPhoneNumber") ||
      !serverEvent && Object.hasOwn(event, "phoneNumber")) return invalid();
  if (typeof phone !== "string" || !/^\+[1-9][0-9]{7,14}$/.test(phone) ||
      phone.trim() !== phone) {
    // Administrative/future events have no recipient and no assistance effect.
    return contents.length === 0 && type === undefined ?
      unsupported() : invalid();
  }
  let occurredAt: string | null = null;
  if (Object.hasOwn(event, "sendTime")) {
    if (!rcsProviderTimestamp(event.sendTime)) return invalid();
    occurredAt = event.sendTime as string;
  }
  const eventId = identity(event.eventId, 512);
  const messageId = identity(event.messageId, 512);
  if (Object.hasOwn(event, "eventId") && !eventId ||
      Object.hasOwn(event, "messageId") && !messageId) return invalid();
  const eventFamily = serverEvent ? "serverEvent" :
    eventId ? "userEvent" : "message";
  const providerEventId = eventId ?? messageId;
  if (!providerEventId) return invalid();
  const parsed = (value: RcsObservation): Parsed => ({kind: "parsed", value: {
    phone, providerEventId, eventFamily, providerOccurredAt: occurredAt,
    observation: value,
  }});
  if (type !== undefined) {
    if (!eventId) return invalid();
    switch (type) {
    case "DELIVERED":
    case "READ":
      return messageId ? parsed({kind: "delivery", providerMessageId: messageId,
        status: type === "DELIVERED" ? "delivered" : "read"}) : invalid();
    case "TTL_EXPIRATION_REVOKED":
    case "TTL_EXPIRATION_REVOKE_FAILED":
      return messageId ? parsed({kind: "expiration",
        providerMessageId: messageId,
        revocation: type === "TTL_EXPIRATION_REVOKED" ?
          "confirmed" : "unconfirmed"}) : invalid();
    case "UNSUBSCRIBE":
    case "SUBSCRIBE":
      return parsed({kind: "subscription", source: "event",
        requested: type === "UNSUBSCRIBE" ? "unsubscribe" : "subscribe"});
    default: return unsupported();
    }
  }
  if (contents.length !== 1) return unsupported();
  if (contents[0] === "suggestionResponse") {
    const suggestion = object(event.suggestionResponse);
    const postback = identity(suggestion?.postbackData, 2048);
    if (!suggestion || !postback) return invalid();
    const suggestionType = suggestion.type === "REPLY" ? "reply" :
      suggestion.type === "ACTION" ? "action" :
        suggestion.type === undefined || suggestion.type === "UNKNOWN" ?
          "unspecified" : null;
    if (!suggestionType) return unsupported();
    const choice = /^ce-rcs1\.([a-f0-9]{64})\.([0-9])$/.exec(postback);
    const page = /^ce-rcs-web1\.([a-f0-9]{64})$/.exec(postback);
    const correlation: SuggestionCorrelation = choice?.[0] === postback ? {
      kind: "choice", attemptId: "attempt:" + choice[1],
      choiceIndex: Number(choice[2]),
    } : page?.[0] === postback ? {
      kind: "guestPage", attemptId: "attempt:" + page[1],
    } : {kind: "unrecognized"};
    return parsed({kind: "suggestion", source: eventId ? "event" : "message",
      suggestionType, correlation});
  }
  if (eventId || !messageId) return invalid();
  if (contents[0] === "text") {
    if (typeof event.text !== "string" || !wellFormed(event.text)) {
      return invalid();
    }
    const keyword = event.text.trim().normalize("NFC").toUpperCase();
    if (["STOP", "BAJA", "PARAR"].includes(keyword)) {
      return parsed({kind: "subscription", requested: "unsubscribe",
        source: "keyword"});
    }
    if (["START", "ALTA", "DÉMARRER", "COMEÇAR"].includes(keyword)) {
      return parsed({kind: "subscription", requested: "subscribe",
        source: "keyword"});
    }
    return parsed({kind: "unstructuredMessage", content: "text"});
  }
  if (!object(event[contents[0]])) return invalid();
  return parsed({kind: "unstructuredMessage",
    content: contents[0] === "location" ? "location" : "file"});
}

function requireConfiguration(token: string, agentId: string) {
  if (!identity(token, 1024) || Buffer.byteLength(token) < 32 ||
      !identity(agentId, 512)) {
    throw new Error("RCS webhook credentials unavailable");
  }
}

function object(value: unknown): JsonObject | null {
  return value !== null && typeof value === "object" && !Array.isArray(value) ?
    value as JsonObject : null;
}

function identity(value: unknown, max: number): string | null {
  return typeof value === "string" && value.length > 0 && value.length <= max &&
    !/\s/u.test(value) && ![...value].some((c) =>
    c.charCodeAt(0) < 32 || c.charCodeAt(0) === 127) &&
    wellFormed(value) ? value : null;
}

function wellFormed(value: string): boolean {
  return Buffer.from(value, "utf8").toString("utf8") === value;
}

function decodeBase64(value: unknown, max: number): Buffer | null {
  if (typeof value !== "string" || value.length > 4 * Math.ceil(max / 3) ||
      value.length === 0) return null;
  const bytes = Buffer.from(value, "base64");
  return bytes.length <= max && bytes.toString("base64") === value ?
    bytes : null;
}

function parseJson(bytes: Buffer, max: number): JsonObject | null {
  if (!Buffer.isBuffer(bytes) || bytes.length === 0 || bytes.length > max) {
    return null;
  }
  try {
    const text = new TextDecoder("utf-8", {fatal: true}).decode(bytes);
    return object(JSON.parse(text));
  } catch {
    return null;
  }
}
