import {operationContentHash} from "../../operations/durableActions";
import {MetaProviderError, MetaWhatsappProvider, OrganizerTokenStore} from
  "../../organizers/organizerWhatsappProvider";
import type {PermitResult} from "./messageOutbox";
import type {DeliveryDecision} from "./messagingPolicy";
import {WhatsappDispatchStore} from "./whatsappDispatchStore";
import {whatsappStatusCorrelation} from "./whatsappDeliveryProtocol";

export type WhatsappWorkerResult =
  | {kind: "withheld"; reason: "senderUnavailable" | "credentialUnavailable" |
      "permitExpired" | "routeCompositionUnavailable" |
      Extract<PermitResult, {kind: "withheld"}>["reason"]}
  | {kind: "waiting"; decision: DeliveryDecision}
  | {kind: "submitted"; outcome: {kind: "accepted"; providerMessageId: string} |
      {kind: "unknown"}};

/** Trusted Operations port. Construction does not register a live executor. */
export class EventWhatsappWorker {
  constructor(private readonly store: WhatsappDispatchStore,
    private readonly provider: Pick<MetaWhatsappProvider, "sendTemplate">,
    private readonly credentials: Pick<OrganizerTokenStore, "accessBound"> =
    new OrganizerTokenStore(),
    private readonly clock: () => number = Date.now) {}

  async dispatch(messageId: string, linkId: string):
    Promise<WhatsappWorkerResult> {
    const outbox = this.store.outbox(linkId);
    const message = await outbox.get(messageId);
    if (!message) throw new Error("WhatsApp message unavailable");
    if (message.intent.permittedRoutes.some((r) =>
      r !== "organizerEventWhatsapp")) {
      return {kind: "withheld", reason: "routeCompositionUnavailable"};
    }
    const config = await this.store.sender();
    if (!config) return {kind: "withheld", reason: "senderUnavailable"};
    // Secret I/O precedes the short reservation window. The claim rechecks
    // the complete sender/policy snapshot, including this pinned version.
    let accessToken: string;
    try {
      accessToken = await this.credentials.accessBound({
        versionResource: config.connection.secretVersionResource!,
        organizerId: config.connection.organizerId,
        connectionId: config.policy.senderId,
      });
    } catch {
      return {kind: "withheld", reason: "credentialUnavailable"};
    }
    const reservation = await outbox.reserve(messageId);
    const attempt = reservation.record.attempts.at(-1);
    if (!attempt || attempt.mode !== "live" ||
        attempt.binding.routeId !== "organizerEventWhatsapp" ||
        attempt.binding.provider !== "meta" ||
        attempt.state.kind !== "reserved") {
      return {kind: "waiting", decision: reservation.decision};
    }
    const claim = await outbox.claimLiveDispatch(messageId, attempt.attemptId,
      this.store.prepare(linkId, config));
    if (claim.kind === "withheld") {
      return {kind: "withheld", reason: claim.reason};
    }
    const {connection, permission, rendered, replies} = claim.resource;
    let providerMessageId: string;
    try {
      ({providerMessageId} = await this.provider.sendTemplate({accessToken,
        phoneNumberId: connection.phoneNumberId!,
        toE164: permission.phoneE164, template: rendered.template,
        variables: rendered.variables, quickReplyPayloads: replies,
        callbackData: whatsappStatusCorrelation(attempt.attemptId,
          rendered.payloadHash), deadline: claim.permit.validUntil}));
    } catch (error) {
      // Only an adapter's proof of no request plus actual permit expiry can
      // mark this unsent. Timeouts, HTTP errors and parse failures stay held.
      if (error instanceof MetaProviderError &&
          error.disposition === "requestNotSent" &&
          this.clock() >= claim.permit.validUntil) {
        await outbox.recordExpiredBeforeSend(claim.permit);
        return {kind: "withheld", reason: "permitExpired"};
      }
      return {kind: "submitted", outcome: {kind: "unknown"}};
    }
    const now = this.clock();
    // Keep persistence errors outside the provider catch. A retry observes
    // the claimed unknown attempt and cannot repeat provider I/O.
    await outbox.recordReceipt(messageId, {
      attemptId: attempt.attemptId, ...attempt.binding,
      providerEventId: "wa-submission:" + operationContentHash([
        attempt.attemptId, providerMessageId,
      ]), receivedAt: now,
      state: {kind: "accepted", at: now, providerMessageId},
    });
    return {kind: "submitted", outcome: {kind: "accepted", providerMessageId}};
  }
}
