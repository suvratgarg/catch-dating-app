import type {Firestore} from "firebase-admin/firestore";
import {operationContentHash} from "../../operations/durableActions";
import {FirestoreMessageOutbox, ReadOutboxFacts} from
  "./firestoreMessageOutbox";
import {readEventAssistanceMessageGate} from "./guestMessageGate";
import type {PreparedMessageChannel} from "./messageChannel";
import type {EventServiceRouteId, RouteReadiness} from "./messagingPolicy";
import type {EventSmsWorker, SmsWorkerResult} from "./smsWorker";
import type {EventWhatsappWorker, WhatsappWorkerResult} from
  "./whatsappWorker";

type Workers = {
  sms?: Pick<EventSmsWorker, "prepareChannel">;
  whatsapp?: Pick<EventWhatsappWorker, "prepareChannel">;
};
type WorkerResult = SmsWorkerResult | WhatsappWorkerResult;
type Outcome = Extract<WorkerResult, {kind: "submitted"}>["outcome"];
type Channel = PreparedMessageChannel<Outcome>;
export type EventMessageWorkerResult =
  | Exclude<WorkerResult, {kind: "submitted"}>
  | {kind: "submitted"; routeId: EventServiceRouteId; outcome: Outcome};

/** One immutable intent and attempt history across independent channels. */
export class EventMessageWorker {
  constructor(private readonly db: Firestore,
    private readonly workers: Workers,
    private readonly clock: () => number = Date.now) {}

  async dispatch(messageId: string, linkId: string):
    Promise<EventMessageWorkerResult> {
    if (!/^[a-f0-9]{32}$/.test(linkId)) {
      throw new Error("Invalid message guest grant id");
    }
    // The initial read grants no send authority. Every mutable fact is read
    // again in the shared reservation and claim transactions.
    const lookup = new FirestoreMessageOutbox(this.db, async () => {
      throw new Error("Message lookup cannot reserve a dispatch");
    }, this.clock);
    const message = await lookup.get(messageId);
    if (!message) throw new Error("Event message unavailable");
    if (message.intent.context.mode !== "live") {
      return {kind: "withheld", reason: "rehearsal"};
    }
    if (message.lifecycle !== "active") {
      return {kind: "waiting", decision: {kind: "stop",
        reason: message.lifecycle}};
    }
    const channels = new Map<EventServiceRouteId, Channel>();
    // Only explicitly permitted routes can load a credential. Preparing all
    // bounded routes first keeps secret latency outside short-lived permits.
    await Promise.all(message.intent.permittedRoutes.map(async (routeId) => {
      const worker = routeId === "catchEventSms" ? this.workers.sms :
        routeId === "organizerEventWhatsapp" ? this.workers.whatsapp : null;
      const channel = worker ? await worker.prepareChannel(linkId) :
        {kind: "unavailable" as const, reason: "senderUnavailable" as const};
      if (channel.kind === "ready" && channel.routeId !== routeId) {
        throw new Error("Prepared message channel has the wrong route");
      }
      channels.set(routeId, channel);
    }));
    const outbox = new FirestoreMessageOutbox(this.db,
      this.readFacts(channels), this.clock);
    const reservation = await outbox.reserve(messageId);
    const attempt = reservation.record.attempts.at(-1);
    if (!attempt || attempt.mode !== "live" ||
        attempt.state.kind !== "reserved") {
      return {kind: "waiting", decision: reservation.decision};
    }
    const channel = channels.get(attempt.binding.routeId);
    if (!channel || channel.kind !== "ready") {
      // A previously reserved attempt is never reassigned to a new channel.
      return {kind: "waiting", decision: reservation.decision};
    }
    const result = await channel.dispatchReserved(outbox, messageId,
      attempt.attemptId);
    return result.kind === "submitted" ? {...result,
      routeId: attempt.binding.routeId} : result;
  }

  private readFacts(channels: ReadonlyMap<EventServiceRouteId, Channel>):
    ReadOutboxFacts {
    return async (tx, intent, now) => {
      const gate = await readEventAssistanceMessageGate(this.db, tx, intent,
        now);
      const routes: RouteReadiness[] = [];
      for (const routeId of intent.permittedRoutes) {
        const channel = channels.get(routeId);
        if (gate.kind === "stop" || !channel ||
            channel.kind === "unavailable") {
          routes.push({routeId, state: {kind: "blocked", reason:
            gate.kind === "stop" ? "policyBlocked" :
              channel?.kind === "unavailable" &&
              channel.reason === "credentialUnavailable" ?
                "channelUnavailable" : "notProvisioned"}});
          continue;
        }
        // Sequential readers share the same transaction and clock snapshot;
        // they cannot hide a revoked permission behind a prior cached check.
        const facts = await channel.readFacts(tx, intent, now);
        if (operationContentHash(facts.gate) !== operationContentHash(gate) ||
            facts.routes.length !== 1 ||
            facts.routes[0].routeId !== routeId) {
          throw new Error("Message channel facts disagree with shared scope");
        }
        routes.push(facts.routes[0]);
      }
      return {gate, routes};
    };
  }
}
