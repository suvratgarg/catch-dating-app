import type {Firestore, Transaction} from "firebase-admin/firestore";
import type {EventAssistanceSmsPermissionDocument as Permission} from
  "../../shared/generated/eventAssistanceSmsPermissionDocument";
import type {EventAssistanceSmsBudgetDocument as Budget} from
  "../../shared/generated/eventAssistanceSmsBudgetDocument";
import {validateEventAssistanceSmsPermissionDocument} from
  "../../shared/generated/validators/eventAssistanceSmsPermissionDocument";
import {validateEventAssistanceSmsBudgetDocument} from
  "../../shared/generated/validators/eventAssistanceSmsBudgetDocument";
import {validateEventAssistanceSmsDispatchDocument} from
  "../../shared/generated/validators/eventAssistanceSmsDispatchDocument";
import {operationContentHash} from "../../operations/durableActions";
import {
  FirestoreMessageOutbox, PrepareDispatchResource,
} from "./firestoreMessageOutbox";
import {readEventAssistanceMessageGate} from "./guestMessageGate";
import type {GuestLinkSigningKeys} from "./guestLinkTokens";
import {
  guestCollections, guestIdentity, parseGrant, readGuestSourceFacts,
  requireDocumentId,
} from "./guestRecords";
import type {MessageRecord, OutboxFacts} from "./messageOutbox";
import type {RouteReadiness} from "./messagingPolicy";
import {
  parseSmsConfig, renderEventSms, RenderedSms, SmsConfig, smsEndpointId,
} from "./smsProtocol";
export {smsEndpointId} from "./smsProtocol";

import {
  parseSmsConsentReceipt, SMS_CONSENT_RECEIPTS, smsPermissionHasReceipt,
} from "./smsConsent";

export type {Permission, Budget};
export const smsCollections = {
  senders: "eventAssistanceSmsSenders",
  permissions: "eventAssistanceSmsPermissions",
  budgets: "eventAssistanceSmsBudgets",
  dispatches: "eventAssistanceSmsDispatches",
} as const;
type Intent = MessageRecord["intent"];
export interface SmsMaterial {
  config: SmsConfig;
  permission: Permission;
  rendered: RenderedSms;
  grantId: string;
  budgets: [Budget, Budget];
}
type MaterialResult = {facts: OutboxFacts; material: SmsMaterial | null};
type BlockReason = Extract<RouteReadiness["state"], {kind: "blocked"}>[
  "reason"];

export function smsPermissionId(context: Permission["context"],
  attendeeId: string, senderId: string): string {
  requireDocumentId(senderId);
  return "sms-permission:" + operationContentHash([
    guestIdentity(context, attendeeId), senderId, "catchEventSms",
  ]);
}

export function smsBudgetScopes(context: Permission["context"], now: number):
  [Budget["scope"], Budget["scope"]] {
  // India sender-day budget uses Asia/Kolkata's fixed UTC+05:30 offset.
  const day = new Date(now + 19_800_000).toISOString().slice(0, 10);
  return [{kind: "event", context}, {kind: "senderDay", day}];
}

export function smsBudgetId(senderId: string, scope: Budget["scope"]): string {
  return "sms-budget:" + operationContentHash([senderId, scope]);
}

export function parseSmsPermission(value: unknown): Permission {
  if (!validateEventAssistanceSmsPermissionDocument(value) ||
      value.permissionId !== smsPermissionId(value.context,
        value.attendeeId, value.senderId) ||
      value.recipientEndpointId !== smsEndpointId(value.context,
        value.attendeeId, value.phoneE164) ||
      (value.evidence !== null &&
        (value.expiresAt <= value.evidence.acceptedAt ||
         value.updatedAt < Math.max(value.evidence.acceptedAt,
           value.evidence.phoneVerifiedAt)))) {
    throw new Error("Invalid event-service SMS permission");
  }
  return value;
}

export function parseSmsBudget(value: unknown): Budget {
  if (!validateEventAssistanceSmsBudgetDocument(value) ||
      value.budgetId !== smsBudgetId(value.senderId, value.scope) ||
      value.endsAt <= value.startsAt || value.updatedAt < value.startsAt ||
      value.chargedMicros > value.limitMicros) {
    throw new Error("Invalid SMS spending authority");
  }
  if (value.scope.kind === "senderDay") {
    const start = Date.parse(value.scope.day + "T00:00:00+05:30");
    if (!Number.isSafeInteger(start) || value.startsAt !== start ||
        value.endsAt !== start + 86_400_000) {
      throw new Error("SMS sender-day budget has the wrong window");
    }
  }
  return value;
}

/** Concrete sender/permission/roster/template and spend reader for SMS. */
export class SmsDispatchStore {
  constructor(private readonly db: Firestore,
    private readonly senderId: string,
    private readonly keys: GuestLinkSigningKeys,
    private readonly clock: () => number = Date.now) {
    requireDocumentId(senderId);
  }

  async sender(): Promise<SmsConfig | null> {
    const snap = await this.db.collection(smsCollections.senders)
      .doc(this.senderId).get();
    if (!snap.exists) return null;
    const config = parseSmsConfig(snap.data());
    if (config.senderId !== this.senderId) {
      throw new Error("SMS sender mismatch");
    }
    return config;
  }

  outbox(linkId: string): FirestoreMessageOutbox {
    if (!/^[a-f0-9]{32}$/.test(linkId)) throw new Error("Invalid SMS grant id");
    return new FirestoreMessageOutbox(this.db, async (tx, intent, now) =>
      (await this.read(tx, intent, linkId, now)).facts, this.clock);
  }

  /** Exact material and both budget debits commit with the outbox claim. */
  prepare(linkId: string, expectedConfig: SmsConfig):
    PrepareDispatchResource<SmsMaterial> {
    return async (tx, record, attempt, now) => {
      const result = await this.read(tx, record.intent, linkId, now);
      const material = result.material;
      if (!material || operationContentHash(material.config) !==
          operationContentHash(expectedConfig)) {
        return {kind: "withheld"};
      }
      const route = result.facts.routes[0];
      if (route?.state.kind !== "eligible" ||
          route.state.permissionRevision !==
            attempt.authorization.permissionRevision ||
          route.state.candidate.mode !== "live" ||
          operationContentHash(route.state.candidate.binding) !==
            operationContentHash(attempt.binding)) return {kind: "withheld"};
      const dispatchRef = this.db.collection(smsCollections.dispatches)
        .doc(attempt.attemptId);
      if ((await tx.get(dispatchRef)).exists) return {kind: "withheld"};
      const {config, permission, rendered, budgets} = material;
      const dispatch = {schemaVersion: 1, attemptId: attempt.attemptId,
        messageId: record.messageId, senderId: config.senderId,
        bindingRevision: config.revision,
        configHash: operationContentHash(config),
        permissionId: permission.permissionId,
        permissionRevision: permission.revision,
        recipientEndpointId: permission.recipientEndpointId,
        payloadHash: rendered.payloadHash,
        templateId: rendered.template.templateId,
        templateRevision: rendered.template.revision,
        quoteRevision: config.quote.revision, grantId: material.grantId,
        encoding: rendered.encoding, segments: rendered.segments,
        maxCostMicros: rendered.maxCostMicros,
        budgetIds: budgets.map((b) => b.budgetId), createdAt: now};
      if (!validateEventAssistanceSmsDispatchDocument(dispatch)) {
        throw new Error("Invalid SMS debit evidence");
      }
      const debited = budgets.map((budget) => parseSmsBudget({...budget,
        chargedMicros: budget.chargedMicros + rendered.maxCostMicros,
        revision: budget.revision + 1, updatedAt: now}));
      return {kind: "ready", value: material,
        validUntil: route.state.validUntil, commit: () => {
          tx.create(dispatchRef, dispatch);
          for (const budget of debited) {
            tx.set(this.db.collection(smsCollections.budgets)
              .doc(budget.budgetId), budget);
          }
        }};
    };
  }

  private async read(tx: Transaction, intent: Intent, linkId: string,
    now: number): Promise<MaterialResult> {
    const gate = await readEventAssistanceMessageGate(this.db, tx, intent, now);
    const blocked = (reason: BlockReason): MaterialResult => ({
      facts: {gate, routes: [{routeId: "catchEventSms",
        state: {kind: "blocked", reason}}]}, material: null,
    });
    if (gate.kind === "stop" || intent.context.mode !== "live") {
      return blocked("policyBlocked");
    }
    const context = intent.context;
    const permissionId = smsPermissionId(context, intent.attendeeId,
      this.senderId);
    const scopes = smsBudgetScopes(context, now);
    const [senderSnap, permissionSnap, grantSnap, attendeeSnap,
      ...budgetSnaps] =
      await Promise.all([
        tx.get(this.db.collection(smsCollections.senders).doc(this.senderId)),
        tx.get(this.db.collection(smsCollections.permissions)
          .doc(permissionId)),
        tx.get(this.db.collection(guestCollections.grants).doc(linkId)),
        tx.get(this.db.collection("eventAttendees").doc(intent.attendeeId)),
        ...scopes.map((scope) => tx.get(this.db
          .collection(smsCollections.budgets)
          .doc(smsBudgetId(this.senderId, scope)))),
      ]);
    if (!senderSnap.exists) return blocked("notProvisioned");
    const config = parseSmsConfig(senderSnap.data());
    if (config.senderId !== this.senderId || config.status !== "ready" ||
        config.activation.approvedAt > now ||
        now >= config.activation.validUntil) {
      return blocked("notProvisioned");
    }
    if (!permissionSnap.exists) return blocked("missingPermission");
    const permission = parseSmsPermission(permissionSnap.data());
    if (permission.status !== "granted") return blocked("suppressed");
    const consentSnap = await tx.get(this.db.collection(SMS_CONSENT_RECEIPTS)
      .doc(permission.currentReceiptId));
    const consent = consentSnap.exists ?
      parseSmsConsentReceipt(consentSnap.data()) : null;
    if (!smsPermissionHasReceipt(permission, consent)) {
      return blocked("missingPermission");
    }
    const source = await readGuestSourceFacts(this.db, tx, context,
      intent.attendeeId);
    const attendee = attendeeSnap.data();
    if (permission.permissionId !== permissionId ||
        permission.senderId !== this.senderId ||
        permission.attendeeGeneration !== source.attendeeGeneration ||
        permission.phoneE164 !== attendee?.phoneE164 ||
        permission.evidence.subjectUid !== attendee?.linkedUid ||
        permission.updatedAt > now || permission.expiresAt <= now) {
      return blocked("missingPermission");
    }
    if (!grantSnap.exists) return blocked("templateUnavailable");
    const grant = parseGrant(grantSnap.data());
    if (grant.linkId !== linkId) return blocked("templateUnavailable");
    let rendered: RenderedSms;
    try {
      rendered = renderEventSms({config, intent, grant, keys: this.keys,
        eventTitle: source.eventTitle, now});
    } catch {
      return blocked("templateUnavailable");
    }
    if (budgetSnaps.some((snap) => !snap.exists)) {
      return blocked("budgetExceeded");
    }
    const budgets = budgetSnaps.map((snap) => parseSmsBudget(snap.data())) as
      [Budget, Budget];
    if (budgets.some((budget, i) =>
      budget.budgetId !== smsBudgetId(this.senderId, scopes[i]) ||
      budget.status !== "active" || budget.startsAt > now ||
      budget.endsAt <= now || budget.updatedAt > now ||
      budget.limitMicros - budget.chargedMicros < rendered.maxCostMicros)) {
      return blocked("budgetExceeded");
    }
    const validUntil = Math.min(now + 30_000, gate.validUntil,
      permission.expiresAt, rendered.validUntil,
      ...budgets.map((b) => b.endsAt));
    return {material: {config, permission, rendered, grantId: linkId, budgets},
      facts: {gate, routes: [{routeId: "catchEventSms", state: {
        kind: "eligible", checkedAt: now, validUntil,
        permissionRevision: "sms-authority:" + operationContentHash([
          config, permission, grant, rendered.payloadHash,
        ]), candidate: {mode: "live", binding: {
          routeId: "catchEventSms", transport: "sms", provider: "gupshup",
          senderIdentity: "catchPlatform", senderId: this.senderId,
          bindingRevision: config.revision,
          recipientEndpointId: permission.recipientEndpointId,
          fallbackOwner: "catch",
        }},
      }}]}};
  }
}
