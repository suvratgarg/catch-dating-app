import {randomUUID, createHash} from "node:crypto";
import {operationContentHash} from "../../operations/durableActions";
import type {RcsConfig} from "./rcsProtocol";
import {rcsEndpointId, rcsMessageId} from "./rcsProtocol";
import {RcsDispatchStore} from "./rcsDispatchStore";
import {RcsCapability, parseRcsCapability, RCS_CAPABILITY_MAX_AGE} from
  "./rcsDispatchRecords";
import type {GoogleRbmProvider} from "./googleRbmProvider";
import {rbmSendBody, rbmTime} from "./googleRbmProtocol";
import type {GoogleRbmSendOutcome} from "./googleRbmProtocol";
import type {PermitResult} from "./messageOutbox";
import type {PreparedMessageChannel, ChannelDispatchResult} from
  "./messageChannel";
import type {FirestoreMessageOutbox} from "./firestoreMessageOutbox";
import type {DeliveryDecision} from "./messagingPolicy";

/** Short-lived OAuth material from a trusted, pinned credential loader. */
export interface RcsCredentials {
  senderId: string;
  agentId: string;
  region: RcsConfig["region"];
  credentialVersion: string;
  accessToken: string;
  expiresAt: number;
}
export type RcsWorkerResult =
  | {kind: "withheld"; reason: "senderUnavailable" | "credentialUnavailable" |
      "permitExpired" | "routeCompositionUnavailable" |
      Extract<PermitResult, {kind: "withheld"}>["reason"]}
  | {kind: "waiting"; decision: DeliveryDecision}
  | {kind: "submitted"; outcome: GoogleRbmSendOutcome};

export function parseRcsCredentials(value: RcsCredentials,
  config: RcsConfig, now: number): RcsCredentials {
  if (!value || value.senderId !== config.senderId ||
      value.agentId !== config.agentId || value.region !== config.region ||
      value.credentialVersion !== config.credentialVersion ||
      typeof value.accessToken !== "string" || !value.accessToken ||
      value.accessToken.length > 4096 || /\s/.test(value.accessToken) ||
      !/^[A-Za-z0-9._~+/-]+=*$/.test(value.accessToken) ||
      !rbmTime(now) || !rbmTime(value.expiresAt) || value.expiresAt <= now) {
    throw new Error("RCS credential unavailable");
  }
  return Object.freeze({...value});
}

/** Shares the SMS/WhatsApp outbox; no public send or activated transport. */
export class EventRcsWorker {
  constructor(private readonly store: RcsDispatchStore,
    private readonly credentials: {
      access(config: RcsConfig): Promise<RcsCredentials>;
    },
    private readonly provider: Pick<GoogleRbmProvider,
      "getCapabilities" | "sendText">,
    private readonly clock: () => number = Date.now) {}

  async prepareChannel(linkId: string):
    Promise<PreparedMessageChannel<GoogleRbmSendOutcome>> {
    const config = await this.store.sender();
    if (!config || config.status !== "ready") {
      return {kind: "unavailable", reason: "senderUnavailable"};
    }
    let credentials: RcsCredentials;
    try {
      credentials = parseRcsCredentials(await this.credentials.access(config),
        config, this.clock());
    } catch {
      return {kind: "unavailable", reason: "credentialUnavailable"};
    }
    const capability = await this.lookupCapability(linkId, config, credentials);
    // An unavailable capability blocks only RCS; the shared composer can still
    // choose an independently consented SMS or WhatsApp route.
    return {kind: "ready", routeId: "catchEventRcs",
      readFacts: (tx, intent, now) => this.store.readFacts(tx, intent, linkId,
        now, config, capability),
      dispatchReserved: (outbox, messageId, attemptId) =>
        this.dispatchReserved(outbox, messageId, attemptId, linkId, config,
          credentials, capability)};
  }

  private async lookupCapability(linkId: string, config: RcsConfig,
    credentials: RcsCredentials): Promise<RcsCapability | null> {
    const checkedAt = this.clock();
    if (!rbmTime(checkedAt)) throw new Error("Invalid RCS capability clock");
    const target = await this.store.capabilityTarget(linkId, config, checkedAt);
    if (!target) return null;
    const now = this.clock();
    const validUntil = Math.min(checkedAt + RCS_CAPABILITY_MAX_AGE,
      credentials.expiresAt, config.activation.validUntil,
      target.permission.expiresAt, target.grant.expiresAt);
    if (!rbmTime(now) || now < checkedAt || now >= validUntil) return null;
    const requestId = randomUUID();
    const result = await this.provider.getCapabilities({
      agentId: config.agentId, region: config.region,
      phoneE164: target.permission.phoneE164,
      accessToken: credentials.accessToken,
      deadline: Math.min(now + 10_000, validUntil), requestId});
    const finishedAt = this.clock();
    if (!rbmTime(finishedAt) || finishedAt < now || finishedAt >= validUntil ||
        result.kind !== "reachable") return null;
    return Object.freeze(parseRcsCapability({requestId,
      senderId: config.senderId, agentId: config.agentId,
      configHash: operationContentHash(config),
      permissionHash: operationContentHash(target.permission),
      recipientEndpointId: target.permission.recipientEndpointId,
      checkedAt, validUntil, supportsOpenUrl: result.supportsOpenUrl}));
  }

  private async dispatchReserved(outbox: FirestoreMessageOutbox,
    messageId: string, attemptId: string, linkId: string, config: RcsConfig,
    credentials: RcsCredentials, capability: RcsCapability | null):
    Promise<ChannelDispatchResult<GoogleRbmSendOutcome>> {
    const record = await outbox.get(messageId);
    const reserved = record?.attempts.find((a) => a.attemptId === attemptId);
    if (!reserved || reserved.mode !== "live" ||
        reserved.binding.routeId !== "catchEventRcs" ||
        reserved.binding.provider !== "googleRbm" ||
        reserved.state.kind !== "reserved") {
      return {kind: "withheld", reason: "notReserved"};
    }
    const claim = await outbox.claimLiveDispatch(messageId, attemptId,
      this.store.prepare(linkId, config, capability));
    if (claim.kind === "withheld") {
      return {kind: "withheld", reason: claim.reason};
    }
    const {permit, resource: material} = claim;
    const {attempt} = permit;
    const {rendered, permission} = material;
    const now = this.clock();
    if (!rbmTime(now) || now < attempt.state.at) {
      throw new Error("Invalid RCS submission clock");
    }
    if (now >= permit.validUntil) {
      await outbox.recordExpiredBeforeSend(permit);
      return {kind: "withheld", reason: "permitExpired"};
    }
    const body = rbmSendBody({messageId: rendered.providerMessageId,
      contentMessage: rendered.contentMessage,
      expiresAt: rendered.expiresAt}, now);
    if (permit.intent.context.mode !== "live" ||
        attempt.binding.senderId !== config.senderId ||
        attempt.binding.bindingRevision !== config.revision ||
        attempt.binding.recipientEndpointId !== rcsEndpointId(
          permit.intent.context, permit.intent.attendeeId,
          permission.phoneE164) ||
        rendered.providerMessageId !== rcsMessageId(attemptId) ||
        rendered.intentHash !== operationContentHash(permit.intent) ||
        rendered.authorityHash !== material.prepared.authorityHash ||
        credentials.expiresAt < permit.validUntil ||
        !body || createHash("sha256").update(body).digest("hex") !==
          rendered.payloadHash) {
      throw new Error("RCS material does not match its dispatch permit");
    }
    const outcome = await this.provider.sendText({agentId: config.agentId,
      region: config.region, accessToken: credentials.accessToken,
      phoneE164: permission.phoneE164, deadline: permit.validUntil,
      messageId: rendered.providerMessageId,
      contentMessage: rendered.contentMessage, expiresAt: rendered.expiresAt});
    if (outcome.kind === "notSent" && outcome.reason === "deadlineExpired") {
      await outbox.recordExpiredBeforeSend(permit);
      return {kind: "withheld", reason: "permitExpired"};
    }
    if (outcome.kind === "accepted" || outcome.kind === "rejected" ||
        outcome.kind === "notSent") {
      const receivedAt = this.clock();
      await outbox.recordReceipt(messageId, {attemptId, ...attempt.binding,
        providerEventId: "submission:" +
          operationContentHash([attemptId, outcome]),
        receivedAt, state: outcome.kind === "accepted" ? {
          kind: "accepted", at: receivedAt,
          providerMessageId: outcome.providerMessageId,
        } : {kind: "failed", at: receivedAt, providerMessageId: null,
          classification: "technical", evidenceId:
            "rcs-" + outcome.kind + ":" + outcome.reason}});
    }
    // Ambiguous network results retain unknown state and both budget charges.
    // Acceptance, queue expiry and DELETE acknowledgements never enable SMS.
    return {kind: "submitted", outcome};
  }
}
