import {createHash} from "node:crypto";
import type {EventAssistanceRcsConfig as RcsConfig} from
  "../../shared/generated/eventAssistanceRcsConfig";
import {validateEventAssistanceRcsConfig} from
  "../../shared/generated/validators/eventAssistanceRcsConfig";
import {operationContentHash} from "../../operations/durableActions";
import type {MessageRecord} from "./messageOutbox";
import {parseMessageIntent} from "./messageProtocol";
import {Grant, guestIdentity, parseGrant, threadIdentity} from "./guestRecords";
import {grantSecret, GuestLinkSigningKeys, matchesGuestSecret} from
  "./guestLinkTokens";
import {sameMessageContext} from "./messagingPolicy";

export type {RcsConfig};
export type RcsSuggestion =
  {reply: {text: string; postbackData: string}} |
  {action: {text: string; postbackData: string; openUrlAction: {url: string}}};
export interface RenderedRcs {
  contentMessage: {text: string; suggestions: RcsSuggestion[]};
  messageTrafficType: "TRANSACTION";
  providerMessageId: string;
  expiresAt: number;
  preparedAt: number;
  validUntil: number;
  maxCostMicros: number;
  intentHash: string;
  payloadHash: string;
}

/** Config is reviewed material, not recipient consent or a send permit. */
export function parseRcsConfig(value: unknown): RcsConfig {
  if (!validateEventAssistanceRcsConfig(value) ||
      value.activation.validUntil <= value.activation.approvedAt ||
      value.quote.validUntil <= value.activation.approvedAt ||
      [value.senderId, value.agentId, value.credentialVersion,
        value.activation.approvalId, value.quote.currency,
        ...value.recipientPrefixes].some((s) => /\s/.test(s))) {
    throw new Error("Invalid RCS sender configuration");
  }
  return value;
}

export function rcsEndpointId(context: Grant["context"], attendeeId: string,
  phone: string): string {
  if (!/^\+[1-9][0-9]{7,14}$/.test(phone) || /\s/.test(phone)) {
    throw new Error("Invalid RCS recipient");
  }
  return "rcs-endpoint:" + operationContentHash([
    guestIdentity(context, attendeeId), phone,
  ]);
}

/** RFC 4122 UUIDv5 in the DNS namespace; stable across transport retries. */
export function rcsMessageId(attemptId: string): string {
  if (!/^attempt:[a-f0-9]{64}$/.test(attemptId) || attemptId.length !== 72) {
    throw new Error("Invalid RCS attempt identity");
  }
  const bytes = createHash("sha1")
    .update(Buffer.from("6ba7b8109dad11d180b400c04fd430c8", "hex"))
    .update("catch.app/event-assistance/rcs/" + attemptId)
    .digest().subarray(0, 16);
  bytes[6] = (bytes[6] & 0x0f) | 0x50;
  bytes[8] = (bytes[8] & 0x3f) | 0x80;
  const hex = bytes.toString("hex");
  return [hex.slice(0, 8), hex.slice(8, 12), hex.slice(12, 16),
    hex.slice(16, 20), hex.slice(20)].join("-");
}

export function rcsReplyId(attemptId: string, choiceIndex: number): string {
  rcsMessageId(attemptId);
  if (!Number.isSafeInteger(choiceIndex) || choiceIndex < 0 ||
      choiceIndex > 9) throw new Error("Invalid RCS choice index");
  return "ce-rcs1." + attemptId.slice(8) + "." + choiceIndex;
}

export function rcsMaterialHash(config: RcsConfig,
  material: Omit<RenderedRcs, "payloadHash">): string {
  return operationContentHash([config, material]);
}

/** Native choices are shortcuts; the scoped guest page retains every choice. */
export function renderEventRcs(input: {
  config: RcsConfig; intent: MessageRecord["intent"]; attemptId: string;
  grant: Grant; keys: GuestLinkSigningKeys; eventTitle: string; now: number;
}): RenderedRcs {
  const {config, intent, attemptId, grant, keys, eventTitle, now} = input;
  parseRcsConfig(config);
  parseMessageIntent(intent);
  parseGrant(grant);
  const purpose = intent.kind === "joiningUpdate" ?
    "joiningUpdate" : intent.noticeKind;
  if (!Number.isSafeInteger(now) || now < intent.createdAt ||
      !eventTitle.trim() || eventTitle.length > 200 ||
      config.status !== "ready" || config.activation.approvedAt > now ||
      now >= config.activation.validUntil || now >= config.quote.validUntil ||
      now >= intent.expiresAt || !config.allowedPurposes.includes(purpose) ||
      !intent.permittedRoutes.includes("catchEventRcs") ||
      grant.issuedAt > now || now >= grant.expiresAt ||
      grant.revokedAt !== null ||
      !sameMessageContext(grant.context, intent.context) ||
      grant.attendeeId !== intent.attendeeId ||
      grant.episodeId !== intent.episodeId ||
      grant.threadId !== threadIdentity(intent)) {
    throw new Error("RCS material or guest authority unavailable");
  }
  const secret = grantSecret(grant, keys);
  if (!matchesGuestSecret(grant, secret)) {
    throw new Error("RCS guest link key mismatch");
  }
  const responseUrl = "https://catchdates.com/event-update/" + grant.linkId +
    "#" + secret;
  const instruction = intent.kind === "joiningUpdate" ?
    intent.guidance.text : intent.body;
  const text = eventTitle + "\n\n" + instruction;
  if (text.length > 3072 || !text.isWellFormed()) {
    throw new Error("RCS content exceeds the supported text boundary");
  }
  const suggestions: RcsSuggestion[] = intent.choices.flatMap((choice, i) =>
    i < 10 && choice.label.length <= 25 && choice.label.isWellFormed() ?
      [{reply: {text: choice.label, postbackData: rcsReplyId(attemptId, i)}}] :
      []);
  suggestions.push({action: {text: "Event details", postbackData:
    "ce-rcs-web1." + attemptId.slice(8), openUrlAction: {url: responseUrl}}});
  const validUntil = Math.min(intent.expiresAt, grant.expiresAt,
    config.activation.validUntil, config.quote.validUntil);
  const material: Omit<RenderedRcs, "payloadHash"> = {
    contentMessage: {text, suggestions}, messageTrafficType: "TRANSACTION",
    providerMessageId: rcsMessageId(attemptId), preparedAt: now, validUntil,
    expiresAt: Math.min(validUntil, now + config.maxQueueSeconds * 1000),
    maxCostMicros: config.quote.maxMicrosPerMessage,
    intentHash: operationContentHash(intent),
  };
  return {...material, payloadHash: rcsMaterialHash(config, material)};
}
