import type {Firestore, Transaction} from "firebase-admin/firestore";
import {operationContentHash} from "../operations/durableActions";
import type {
  DeliveryDispatchGate, DeliveryRouteReadiness,
} from "../delivery/deliveryCore";
import {FirestoreDeliveryOutbox, ReadDeliveryFacts} from
  "../delivery/firestoreDeliveryOutbox";
import type {
  DeliveryAttempt, LiveAttempt, MessageRecord, ProviderBinding,
} from "./programDelivery";
import {programDeliveryAdapter} from "./programDelivery";
import type {ProgramDeliveryMessageIntent as MessageIntent} from
  "../shared/generated/programDeliveryMessageIntent";
import type {
  OrganizerMessageTemplateDocument,
  OrganizerSenderConnectionDocument,
  ProgramGuestDocument, ProgramHouseholdDocument,
  OrganizerProgramDocument,
} from "../shared/generated/firestoreAdminTypes";
import {
  MetaProviderError, MetaWhatsappProvider, OrganizerTokenStore,
  metaTemplateFromDocument,
} from "../organizers/organizerWhatsappProvider";

export type ProgramDeliveryOutbox = FirestoreDeliveryOutbox<
  MessageIntent["context"], ProviderBinding, MessageIntent, DeliveryAttempt,
  MessageRecord>;

export type WhatsappSubmissionOutcome =
  {kind: "accepted"; providerMessageId: string} | {kind: "unknown"};

export type ProgramChannelDispatchResult =
  | {kind: "withheld"; reason: "permitExpired" | "notReserved" |
    "rehearsal" | "authorityChanged" | "authorizationExpired" |
    "deliveryConflict" | "resourceUnavailable" | "endpointChanged"}
  | {kind: "submitted"; outcome: WhatsappSubmissionOutcome};

export type PreparedProgramChannel = {
  kind: "ready";
  routeId: MessageIntent["permittedRoutes"][number];
  readFacts: ReadDeliveryFacts<MessageIntent, ProviderBinding>;
  dispatchReserved(outbox: ProgramDeliveryOutbox, messageId: string,
    attemptId: string): Promise<ProgramChannelDispatchResult>;
} | {kind: "unavailable"; reason: "senderUnavailable" |
  "credentialUnavailable"};

export type ProgramDeliveryWorkerResult =
  | {kind: "withheld"; reason: "senderUnavailable" |
    "credentialUnavailable" |
    Extract<ProgramChannelDispatchResult,
      {kind: "withheld"}>["reason"]}
  | {kind: "waiting"; decision: import("../delivery/deliveryCore")
      .DeliveryDecision<ProviderBinding>}
  | {kind: "submitted"; routeId: string;
    outcome: WhatsappSubmissionOutcome};

const FACT_SNAPSHOT_MS = 120_000;

interface RecipientEndpointFacts {
  /** Raw endpoint the channel dispatches to; never persisted on records. */
  e164: string | null;
  /** Deterministic endpoint reference frozen into the attempt binding. */
  endpointId: string | null;
  /** Consent triple from the messaging-consent holder, if any. */
  consent: {granted: boolean; revision: number} | null;
  withdrawn: boolean;
}

function endpointRef(e164: string): string {
  return "e164:" + operationContentHash(e164).slice(0, 48);
}

/**
 * Resolve the intent's recipient inside the transaction. Households carry
 * their own consent; guests defer to their household's consent row; a
 * missing document means the recipient was withdrawn from the program.
 */
async function readRecipientEndpoint(
  tx: Transaction, db: Firestore, intent: MessageIntent
): Promise<RecipientEndpointFacts> {
  const {kind, recipientKey} = intent.recipient;
  const readHousehold = async (id: string) =>
    (await tx.get(db.collection("programHouseholds").doc(id)))
      .data() as ProgramHouseholdDocument | undefined;
  if (kind === "household") {
    const household = await readHousehold(recipientKey);
    if (!household || household.programId !== intent.programId) {
      return {e164: null, endpointId: null, consent: null,
        withdrawn: true};
    }
    return {e164: household.primaryPhoneE164,
      endpointId: household.primaryPhoneE164 ?
        endpointRef(household.primaryPhoneE164) : null,
      consent: household.messagingConsent ?
        {granted: household.messagingConsent.granted,
          revision: household.revision} : null,
      withdrawn: false};
  }
  if (kind === "guest") {
    const guest = (await tx.get(db.collection("programGuests")
      .doc(recipientKey))).data() as ProgramGuestDocument | undefined;
    if (!guest || guest.programId !== intent.programId) {
      return {e164: null, endpointId: null, consent: null,
        withdrawn: true};
    }
    const household = guest.householdId ?
      await readHousehold(guest.householdId) : undefined;
    return {e164: guest.phoneE164,
      endpointId: guest.phoneE164 ? endpointRef(guest.phoneE164) : null,
      consent: household?.messagingConsent ?
        {granted: household.messagingConsent.granted,
          revision: household.revision} : null,
      withdrawn: false};
  }
  // staff endpoints are uid-based; the reminder worker only provisions
  // phone routes today.
  return {e164: null, endpointId: null, consent: null, withdrawn: true};
}

/**
 * The domain gate for program reminders: the program must still be live,
 * the producing moment's revision must still match the intent's frozen
 * instruction revision, and the recipient must still exist.
 */
async function readProgramGate(
  tx: Transaction, db: Firestore, intent: MessageIntent, now: number
): Promise<{gate: DeliveryDispatchGate;
  recipient: RecipientEndpointFacts | null}> {
  const programRef = db.collection("organizerPrograms").doc(intent.programId);
  const momentRef = db.collection("organizerMoments")
    .doc(intent.workflow.momentId);
  const [programSnap, momentSnap] =
    await Promise.all([tx.get(programRef), tx.get(momentRef)]);
  const program = programSnap.data() as
    OrganizerProgramDocument | undefined;
  if (!program) {
    return {gate: {kind: "stop", reason: "programEnded"}, recipient: null};
  }
  if (program.organizerId !== intent.context.organizerId) {
    throw new Error("Program delivery context mismatch");
  }
  if (program.status !== "active" && program.status !== "draft") {
    return {gate: {kind: "stop", reason: "programEnded"}, recipient: null};
  }
  const recipient = await readRecipientEndpoint(tx, db, intent);
  if (recipient.withdrawn) {
    return {gate: {kind: "stop", reason: "recipientWithdrawn"},
      recipient: null};
  }
  const moment = momentSnap.data() as {revision?: number} | undefined;
  return {gate: {kind: "allow", checkedAt: now,
    validUntil: Math.min(now + FACT_SNAPSHOT_MS, intent.expiresAt),
    instructionRevision: moment?.revision ?? -1}, recipient};
}

interface PreparedWhatsappSender {
  connection: OrganizerSenderConnectionDocument;
  template: OrganizerMessageTemplateDocument;
  accessToken: string;
}

/**
 * Slow credential reads finish before the shared route reservation; the
 * claim transaction re-reads the complete sender/consent snapshot.
 */
export async function prepareProgramWhatsappChannel(
  db: Firestore, intent: MessageIntent,
  provider: Pick<MetaWhatsappProvider, "sendTemplate">,
  credentials: Pick<OrganizerTokenStore, "accessBound">,
  clock: () => number = Date.now
): Promise<PreparedProgramChannel> {
  const whatsapp = intent.whatsapp;
  if (!whatsapp) {
    return {kind: "unavailable", reason: "senderUnavailable"};
  }
  const [connSnap, templateSnap] = await Promise.all([
    db.collection("organizerSenderConnections").doc(whatsapp.connectionId)
      .get(),
    db.collection("organizerMessageTemplates").doc(whatsapp.templateId).get(),
  ]);
  const connection = connSnap.data() as
    OrganizerSenderConnectionDocument | undefined;
  const template = templateSnap.data() as
    OrganizerMessageTemplateDocument | undefined;
  if (!connection || connection.status !== "active" ||
      !connection.phoneNumberId || !connection.secretVersionResource ||
      connection.organizerId !== intent.context.organizerId ||
      !template || template.status !== "APPROVED") {
    return {kind: "unavailable", reason: "senderUnavailable"};
  }
  let accessToken: string;
  try {
    accessToken = await credentials.accessBound({
      versionResource: connection.secretVersionResource,
      organizerId: connection.organizerId,
      connectionId: whatsapp.connectionId,
    });
  } catch {
    return {kind: "unavailable", reason: "credentialUnavailable"};
  }
  const sender: PreparedWhatsappSender = {connection, template, accessToken};

  const readFacts: ReadDeliveryFacts<MessageIntent, ProviderBinding> =
    async (tx, liveIntent, now) => {
      const {gate, recipient} = await readProgramGate(tx, db, liveIntent, now);
      const routes: DeliveryRouteReadiness<ProviderBinding>[] = [];
      if (gate.kind === "stop" || !recipient) {
        routes.push({routeId: "organizerProgramWhatsapp",
          state: {kind: "blocked", reason: "policyBlocked"}});
        return {gate, routes};
      }
      // Re-read sender/template inside the same transaction snapshot.
      const [liveConnSnap, liveTemplateSnap] = await Promise.all([
        tx.get(db.collection("organizerSenderConnections")
          .doc(whatsapp.connectionId)),
        tx.get(db.collection("organizerMessageTemplates")
          .doc(whatsapp.templateId)),
      ]);
      const conn = liveConnSnap.data() as
        OrganizerSenderConnectionDocument | undefined;
      const tpl = liveTemplateSnap.data() as
        OrganizerMessageTemplateDocument | undefined;
      // Explicit decline suppresses the route; an absent consent record
      // does not — service messages precede the first consent opportunity
      // (mirrors the shipped campaign/policy semantics).
      if (recipient.consent !== null && !recipient.consent.granted) {
        routes.push({routeId: "organizerProgramWhatsapp",
          state: {kind: "blocked", reason: "suppressed"}});
        return {gate, routes};
      }
      if (!conn || conn.status !== "active" || !conn.phoneNumberId ||
          !conn.secretVersionResource) {
        routes.push({routeId: "organizerProgramWhatsapp",
          state: {kind: "blocked", reason: "channelUnavailable"}});
        return {gate, routes};
      }
      if (!tpl || tpl.status !== "APPROVED") {
        routes.push({routeId: "organizerProgramWhatsapp",
          state: {kind: "blocked", reason: "templateUnavailable"}});
        return {gate, routes};
      }
      if (!recipient.endpointId) {
        routes.push({routeId: "organizerProgramWhatsapp",
          state: {kind: "blocked", reason: "notProvisioned"}});
        return {gate, routes};
      }
      routes.push({routeId: "organizerProgramWhatsapp",
        state: {kind: "eligible", checkedAt: now,
          validUntil: Math.min(now + FACT_SNAPSHOT_MS,
            liveIntent.expiresAt),
          permissionRevision: "progperm:" + operationContentHash([
            conn.revision, tpl.contentHash ?? tpl.providerUpdatedAt ?? 0,
            recipient.consent?.granted ?? null,
            recipient.consent?.revision ?? 0,
          ]),
          candidate: {mode: "live", binding: {
            routeId: "organizerProgramWhatsapp", transport: "whatsapp",
            senderIdentity: "organizerManaged", provider: "meta",
            senderId: conn.phoneNumberId, bindingRevision: conn.revision,
            recipientEndpointId: recipient.endpointId,
            fallbackOwner: "catch",
          } satisfies ProviderBinding}}});
      return {gate, routes};
    };

  return {kind: "ready", routeId: "organizerProgramWhatsapp", readFacts,
    dispatchReserved: (outbox, messageId, attemptId) =>
      dispatchProgramWhatsapp(db, outbox, messageId, attemptId, intent,
        sender, provider, clock)};
}

async function dispatchProgramWhatsapp(
  db: Firestore, outbox: ProgramDeliveryOutbox,
  messageId: string, attemptId: string, intent: MessageIntent,
  sender: PreparedWhatsappSender,
  provider: Pick<MetaWhatsappProvider, "sendTemplate">,
  clock: () => number
): Promise<ProgramChannelDispatchResult> {
  const record = await outbox.get(messageId);
  const reserved = record?.attempts.find((a) => a.attemptId === attemptId);
  if (!reserved || reserved.state.kind !== "reserved" ||
      reserved.binding.routeId !== "organizerProgramWhatsapp" ||
      reserved.binding.provider !== "meta") {
    return {kind: "withheld", reason: "notReserved"};
  }
  const claim = await outbox.claimLiveDispatch<{e164: string}>(
    messageId, attemptId,
    // The claim transaction re-reads the endpoint so the number dialed is
    // exactly the one the reservation authorized.
    async (tx, _record, _attempt, _now) => {
      const recipient = await readRecipientEndpoint(tx, db, intent);
      if (!recipient.e164 || recipient.endpointId !==
          _attempt.binding.recipientEndpointId) {
        return {kind: "withheld"};
      }
      return {kind: "ready", value: {e164: recipient.e164},
        validUntil: Math.min(_now + FACT_SNAPSHOT_MS, intent.expiresAt),
        commit: () => undefined};
    });
  if (claim.kind === "withheld") {
    return {kind: "withheld", reason: claim.reason};
  }
  const attempt = claim.permit.attempt as LiveAttempt;
  let providerMessageId: string;
  try {
    ({providerMessageId} = await provider.sendTemplate({
      accessToken: sender.accessToken,
      phoneNumberId: sender.connection.phoneNumberId!,
      toE164: claim.resource.e164,
      template: metaTemplateFromDocument(sender.template),
      variables: {...intent.whatsapp!.variables},
      callbackData: `programDelivery:${attempt.attemptId}`,
      deadline: claim.permit.validUntil}));
  } catch (error) {
    // Only a proven unsent request plus actual permit expiry can mark this
    // unsent. Timeouts, HTTP errors and parse failures stay held unknown.
    if (error instanceof MetaProviderError &&
        error.disposition === "requestNotSent" &&
        clock() >= claim.permit.validUntil) {
      await outbox.recordExpiredBeforeSend(claim.permit);
      return {kind: "withheld", reason: "permitExpired"};
    }
    return {kind: "submitted", outcome: {kind: "unknown"}};
  }
  const now = clock();
  await outbox.recordReceipt(messageId, {
    attemptId: attempt.attemptId, ...attempt.binding,
    providerEventId: "program-wa-submission:" + operationContentHash([
      attempt.attemptId, providerMessageId,
    ]),
    receivedAt: now,
    state: {kind: "accepted", at: now, providerMessageId},
  });
  return {kind: "submitted", outcome: {kind: "accepted", providerMessageId}};
}

/**
 * Dispatches one program delivery intent through the shared core: prepare
 * permitted channels (credential I/O outside the transaction), reserve,
 * claim, submit, and record the provider outcome.
 */
export class ProgramDeliveryWorker {
  constructor(private readonly db: Firestore,
    private readonly provider: Pick<MetaWhatsappProvider, "sendTemplate">,
    private readonly credentials: Pick<OrganizerTokenStore, "accessBound">,
    private readonly clock: () => number = Date.now) {}

  async dispatch(messageId: string,
    executionDeadline = Number.MAX_SAFE_INTEGER):
    Promise<ProgramDeliveryWorkerResult> {
    const requireWindow = () => {
      const now = this.clock();
      if (!Number.isSafeInteger(executionDeadline) ||
          !Number.isSafeInteger(now) || now < 0 ||
          now >= executionDeadline) {
        throw new Error("Program delivery worker window expired");
      }
    };
    requireWindow();
    const lookup: ProgramDeliveryOutbox = new FirestoreDeliveryOutbox(
      this.db, programDeliveryAdapter, async () => {
        throw new Error("Program delivery lookup cannot reserve dispatch");
      }, this.clock);
    const message = await lookup.get(messageId);
    if (!message) throw new Error("Program delivery message unavailable");
    if (message.lifecycle !== "active") {
      return {kind: "waiting", decision: {kind: "stop",
        reason: message.lifecycle}};
    }
    const channels = new Map<string, PreparedProgramChannel>();
    await Promise.all(message.intent.permittedRoutes.map(async (routeId) => {
      const channel = routeId === "organizerProgramWhatsapp" ?
        await prepareProgramWhatsappChannel(this.db, message.intent,
          this.provider, this.credentials, this.clock) :
        {kind: "unavailable" as const,
          reason: "senderUnavailable" as const};
      if (channel.kind === "ready" && channel.routeId !== routeId) {
        throw new Error("Prepared program channel has the wrong route");
      }
      channels.set(routeId, channel);
    }));
    requireWindow();
    const outbox: ProgramDeliveryOutbox = new FirestoreDeliveryOutbox(
      this.db, programDeliveryAdapter,
      async (tx, intent, now) => {
        const gate = (await readProgramGate(tx, this.db, intent, now)).gate;
        const routes: DeliveryRouteReadiness<ProviderBinding>[] = [];
        for (const routeId of intent.permittedRoutes) {
          const channel = channels.get(routeId);
          if (gate.kind === "stop" || !channel ||
              channel.kind === "unavailable") {
            routes.push({routeId, state: {kind: "blocked",
              reason: gate.kind === "stop" ? "policyBlocked" :
                "notProvisioned"}});
            continue;
          }
          // Sequential readers share the transaction snapshot; a channel
          // cannot hide a revoked permission behind a cached check.
          const facts = await channel.readFacts(tx, intent, now);
          if (operationContentHash(facts.gate) !==
              operationContentHash(gate) ||
              facts.routes.length !== 1 ||
              facts.routes[0].routeId !== routeId) {
            throw new Error("Program channel facts disagree with scope");
          }
          routes.push(facts.routes[0]);
        }
        return {gate, routes};
      }, this.clock);
    const reservation = await outbox.reserve(messageId);
    const attempt = reservation.record.attempts.at(-1);
    if (!attempt || attempt.state.kind !== "reserved") {
      return {kind: "waiting", decision: reservation.decision};
    }
    const channel = channels.get(attempt.binding.routeId);
    if (!channel || channel.kind !== "ready") {
      return {kind: "waiting", decision: reservation.decision};
    }
    requireWindow();
    const result = await channel.dispatchReserved(outbox, messageId,
      attempt.attemptId);
    return result.kind === "submitted" ? {...result,
      routeId: attempt.binding.routeId} : result;
  }
}
