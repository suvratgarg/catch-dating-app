import {operationContentHash} from "../../operations/durableActions";
import type {SmsConfig} from "./smsProtocol";
import {SmsDispatchStore} from "./smsDispatchStore";
import {
  GupshupSmsProvider, SmsCredentials, SmsCredentialStore,
  SmsSubmissionOutcome, parseSmsCredentials,
} from "./gupshupSmsProvider";
import type {PermitResult} from "./messageOutbox";
import type {PreparedMessageChannel, ChannelDispatchResult} from
  "./messageChannel";
import type {FirestoreMessageOutbox} from "./firestoreMessageOutbox";
import type {DeliveryDecision} from "./messagingPolicy";

export type SmsWorkerResult =
  | {kind: "withheld"; reason: "senderUnavailable" | "credentialUnavailable" |
      "permitExpired" | "routeCompositionUnavailable" |
      Extract<PermitResult, {kind: "withheld"}>["reason"]}
  | {kind: "waiting"; decision: DeliveryDecision}
  | {kind: "submitted"; outcome: SmsSubmissionOutcome};

/** Invoked by a trusted Operations executor, never a client-supplied send. */
export class EventSmsWorker {
  constructor(private readonly store: SmsDispatchStore,
    private readonly credentials: {
      access(config: SmsConfig): Promise<SmsCredentials>;
    } = new SmsCredentialStore(),
    private readonly provider = new GupshupSmsProvider(),
    private readonly clock: () => number = Date.now) {}

  async dispatch(messageId: string, linkId: string): Promise<SmsWorkerResult> {
    const outbox = this.store.outbox(linkId);
    const message = await outbox.get(messageId);
    if (!message) throw new Error("SMS message unavailable");
    // This bounded worker reads SMS authority only. The shared channel
    // composer must own multi-route selection before those intents can run.
    if (message.intent.permittedRoutes.some((r) => r !== "catchEventSms")) {
      return {kind: "withheld", reason: "routeCompositionUnavailable"};
    }
    const channel = await this.prepareChannel(linkId);
    if (channel.kind === "unavailable") {
      return {kind: "withheld", reason: channel.reason};
    }
    const reservation = await outbox.reserve(messageId);
    const attempt = reservation.record.attempts.at(-1);
    if (!attempt || attempt.state.kind !== "reserved") {
      return {kind: "waiting", decision: reservation.decision};
    }
    return channel.dispatchReserved(outbox, messageId, attempt.attemptId);
  }

  /** All slow secret I/O finishes before the shared route reservation. */
  async prepareChannel(linkId: string):
    Promise<PreparedMessageChannel<SmsSubmissionOutcome>> {
    const config = await this.store.sender();
    if (!config || config.status !== "ready") {
      return {kind: "unavailable", reason: "senderUnavailable"};
    }
    // Slow secret I/O precedes the reservation's short authorization window.
    let credentials: SmsCredentials;
    try {
      credentials = parseSmsCredentials(
        await this.credentials.access(config), config.senderId);
    } catch {
      return {kind: "unavailable", reason: "credentialUnavailable"};
    }
    return {kind: "ready", routeId: "catchEventSms",
      readFacts: (tx, intent, now) =>
        this.store.readFacts(tx, intent, linkId, now, config),
      dispatchReserved: (outbox, messageId, attemptId) =>
        this.dispatchReserved(outbox, messageId, attemptId, linkId, config,
          credentials)};
  }

  private async dispatchReserved(outbox: FirestoreMessageOutbox,
    messageId: string, attemptId: string, linkId: string,
    config: SmsConfig, credentials: SmsCredentials):
    Promise<ChannelDispatchResult<SmsSubmissionOutcome>> {
    const record = await outbox.get(messageId);
    const reserved = record?.attempts.find((a) => a.attemptId === attemptId);
    if (!reserved || reserved.mode !== "live" ||
        reserved.binding.routeId !== "catchEventSms" ||
        reserved.binding.provider !== "gupshup" ||
        reserved.state.kind !== "reserved") {
      return {kind: "withheld", reason: "notReserved"};
    }
    const claim = await outbox.claimLiveDispatch(messageId, attemptId,
      this.store.prepare(linkId, config));
    if (claim.kind === "withheld") {
      return {kind: "withheld", reason: claim.reason};
    }
    const attempt = claim.permit.attempt;
    const material = claim.resource;
    const outcome = await this.provider.send({permit: claim.permit,
      config: material.config, credentials,
      reportToken: material.reportToken,
      phoneE164: material.permission.phoneE164, rendered: material.rendered});
    if (outcome.kind === "withheld") {
      await outbox.recordExpiredBeforeSend(claim.permit);
      return {kind: "withheld", reason: outcome.reason};
    }
    if (outcome.kind === "accepted" || outcome.kind === "rejected") {
      const now = this.clock();
      await outbox.recordReceipt(messageId, {
        attemptId: attempt.attemptId, ...attempt.binding,
        providerEventId: "submission:" + operationContentHash([
          attempt.attemptId, outcome,
        ]), receivedAt: now,
        state: outcome.kind === "accepted" ? {
          kind: "accepted", at: now,
          providerMessageId: outcome.providerMessageId,
        } : {kind: "failed", at: now, providerMessageId: null,
          classification: outcome.classification,
          evidenceId: "sms-rejection:" + outcome.code},
      });
    }
    // Uncertain attempts keep their debit and unknown state. Reconciliation
    // owns that conservative hold; accepted is not proof of delivery.
    return {kind: "submitted", outcome};
  }
}
