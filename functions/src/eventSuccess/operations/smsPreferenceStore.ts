import type {Firestore, Transaction} from "firebase-admin/firestore";
import {HttpsError} from "firebase-functions/v2/https";
import type {GetEventAssistanceSmsPreferenceCallablePayload as Scope} from
  "../../shared/generated/getEventAssistanceSmsPreferenceCallablePayload";
import type {SetEventAssistanceSmsPreferenceCallablePayload as Submission} from
  "../../shared/generated/setEventAssistanceSmsPreferenceCallablePayload";
import type {EventAssistanceSmsPreferenceCallableResponse as Response} from
  "../../shared/generated/eventAssistanceSmsPreferenceCallableResponse";
import {operationContentHash} from "../../operations/durableActions";
import {
  GuestSourceFacts, readGuestSourceFacts, requireDocumentId,
} from "./guestRecords";
import {
  Permission, parseSmsPermission, smsCollections, smsPermissionId,
} from "./smsPermissionRecords";
import {parseSmsConfig, SmsConfig, smsEndpointId} from "./smsProtocol";
import {
  CATCH_EVENT_SMS_SENDER_ID, ConsentReceipt, parseSmsConsentReceipt,
  SMS_CONSENT_HASH, SMS_CONSENT_RECEIPTS, SMS_CONSENT_TEXT,
  SMS_CONSENT_VERSION, smsPermissionHasReceipt,
} from "./smsConsent";

/** UID and phone claim are derived from Firebase Auth, never request data. */
export interface SmsPreferenceActor {uid: string; phone: string | null}
interface PreferenceFacts {
  context: Permission["context"];
  source: GuestSourceFacts;
  phone: string | null;
  permission: Permission | null;
  receipt: ConsentReceipt | null;
  sender: SmsConfig | null;
}

export class SmsPreferenceStore {
  constructor(private readonly db: Firestore,
    private readonly clock: () => number = Date.now,
    private readonly senderId = CATCH_EVENT_SMS_SENDER_ID) {
    requireDocumentId(senderId);
  }

  async get(actor: SmsPreferenceActor, scope: Scope): Promise<Response> {
    return this.db.runTransaction(async (tx) => ({outcome: "read",
      view: this.view(actor, scope, await this.read(tx, actor, scope),
        this.now())}));
  }

  async set(actor: SmsPreferenceActor, input: Submission): Promise<Response> {
    requireDocumentId(input.requestId);
    const receiptId = "sms-consent:" + operationContentHash([
      actor.uid, input.eventId, input.attendeeId, input.requestId,
    ]);
    const requestHash = operationContentHash([actor.uid, input]);
    return this.db.runTransaction(async (tx) => {
      const facts = await this.read(tx, actor, input);
      const reference = this.db.collection(SMS_CONSENT_RECEIPTS).doc(receiptId);
      const existingReceipt = await tx.get(reference);
      const now = this.now();
      const currentView = this.view(actor, input, facts, now);
      if (existingReceipt.exists) {
        const prior = parseSmsConsentReceipt(existingReceipt.data());
        if (prior.receiptId !== receiptId ||
            prior.requestHash !== requestHash) {
          throw new HttpsError("invalid-argument",
            "Use a new preference request.");
        }
        // A replay returns current state. It can never restore an old grant.
        return {outcome: "replayed", view: currentView};
      }
      const previous = facts.permission;
      if ((previous?.revision ?? null) !== input.expectedRevision) {
        return {outcome: "conflict", view: currentView};
      }
      const granting = input.decision.kind === "grant";
      if (input.decision.kind === "grant" && (!currentView.canEnable ||
          input.decision.copyVersion !== SMS_CONSENT_VERSION)) {
        throw new HttpsError("failed-precondition",
          "Event text updates cannot be enabled right now.");
      }
      const phone = facts.phone ?? previous?.phoneE164;
      if (!phone) {
        throw new HttpsError("failed-precondition",
          "There is no supported event text number to update.");
      }
      const permissionId = smsPermissionId(facts.context,
        input.attendeeId, this.senderId);
      const evidence = granting ? {receiptId,
        copyVersion: SMS_CONSENT_VERSION, acceptedAt: now,
        // This is when the server checked the signed phone claim, not a
        // claim that a new OTP was sent at the instant of consent.
        phoneVerifiedAt: now, subjectUid: actor.uid} :
        previous?.evidence ?? null;
      const permission = parseSmsPermission({schemaVersion: 1, permissionId,
        currentReceiptId: receiptId, revision: (previous?.revision ?? 0) + 1,
        context: facts.context, attendeeId: input.attendeeId,
        attendeeGeneration: facts.source.attendeeGeneration,
        senderId: this.senderId, routeId: "catchEventSms",
        purpose: "eventService",
        phoneE164: phone,
        recipientEndpointId: smsEndpointId(facts.context,
          input.attendeeId, phone),
        status: granting ? "granted" : "revoked", evidence,
        expiresAt: granting ? facts.source.eventEnd + 86_400_000 :
          previous?.expiresAt ?? Math.max(now, facts.source.eventEnd),
        updatedAt: now});
      const receipt = parseSmsConsentReceipt({schemaVersion: 1, receiptId,
        requestHash, source: "verifiedParticipant", linkId: null,
        context: facts.context, attendeeId: input.attendeeId,
        attendeeGeneration: facts.source.attendeeGeneration,
        senderId: this.senderId, routeId: "catchEventSms", actorUid: actor.uid,
        recipientEndpointId: permission.recipientEndpointId,
        decision: input.decision.kind,
        copyVersion: granting ? SMS_CONSENT_VERSION : null,
        copyHash: granting ? SMS_CONSENT_HASH : null,
        appliedRevision: permission.revision, createdAt: now,
        permissionHash: operationContentHash(permission)});
      tx.create(reference, receipt);
      tx.set(this.db.collection(smsCollections.permissions).doc(permissionId),
        permission);
      return {outcome: "applied", view: this.view(actor, input,
        {...facts, permission, receipt}, now)};
    });
  }

  private async read(tx: Transaction, actor: SmsPreferenceActor,
    scope: Scope): Promise<PreferenceFacts> {
    requireDocumentId(scope.eventId);
    requireDocumentId(scope.attendeeId);
    requireDocumentId(actor.uid);
    const [eventSnap, attendeeSnap, senderSnap] = await Promise.all([
      tx.get(this.db.collection("events").doc(scope.eventId)),
      tx.get(this.db.collection("eventAttendees").doc(scope.attendeeId)),
      tx.get(this.db.collection(smsCollections.senders).doc(this.senderId)),
    ]);
    const event = eventSnap.data();
    const attendee = attendeeSnap.data();
    if (!event || !attendee || attendee.linkedUid !== actor.uid ||
        attendee.eventId !== scope.eventId) {
      throw new HttpsError("permission-denied",
        "Event preference unavailable.");
    }
    const context = {mode: "live" as const, eventId: scope.eventId,
      organizerId: event.organizerId ?? event.clubId};
    const source = await readGuestSourceFacts(this.db, tx, context,
      scope.attendeeId);
    const id = smsPermissionId(context, scope.attendeeId, this.senderId);
    const permissionSnap = await tx.get(this.db
      .collection(smsCollections.permissions).doc(id));
    const permission = permissionSnap.exists ?
      parseSmsPermission(permissionSnap.data()) : null;
    if (permission && permission.permissionId !== id) {
      throw new HttpsError("internal", "Event preference identity mismatch.");
    }
    const receiptSnap = permission ? await tx.get(this.db
      .collection(SMS_CONSENT_RECEIPTS)
      .doc(permission.currentReceiptId)) : null;
    const receipt = receiptSnap?.exists ?
      parseSmsConsentReceipt(receiptSnap.data()) : null;
    const sender = senderSnap.exists ? parseSmsConfig(senderSnap.data()) : null;
    if (sender && sender.senderId !== this.senderId) {
      throw new HttpsError("internal", "Event sender identity mismatch.");
    }
    return {context, source, permission, receipt, sender,
      phone: typeof attendee.phoneE164 === "string" &&
        /^\+91[6-9][0-9]{9}$/.test(attendee.phoneE164) ?
        attendee.phoneE164 : null};
  }

  private view(actor: SmsPreferenceActor, scope: Scope,
    facts: PreferenceFacts, now: number): Response["view"] {
    const {source, sender, permission, receipt, phone} = facts;
    if (now < (permission?.updatedAt ?? 0) ||
        now < (receipt?.createdAt ?? 0)) {
      throw new HttpsError("unavailable", "Event preference clock is behind.");
    }
    const belongs = permission !== null &&
      permission.attendeeGeneration === source.attendeeGeneration &&
      permission.phoneE164 === phone &&
      (permission.evidence === null ||
        permission.evidence.subjectUid === actor.uid);
    const proof = belongs && smsPermissionHasReceipt(permission!, receipt);
    let availability: Response["view"]["availability"] = "ready";
    if (!phone || phone !== actor.phone) availability = "verifyPhone";
    else if (!["registered", "checkedIn"].includes(source.attendeeStatus)) {
      availability = "notAdmitted";
    } else if (source.eventStatus !== "active" ||
        now >= source.eventEnd + 86_400_000) availability = "eventClosed";
    else if (!sender || sender.status !== "ready" ||
        sender.activation.approvedAt > now ||
        sender.activation.validUntil <= now) availability = "senderUnavailable";
    const preference: Response["view"]["preference"] = !belongs ? "notSet" :
      permission!.status === "revoked" ? "disabled" :
        !proof ? "notSet" :
          permission!.expiresAt <= now ? "expired" : "enabled";
    return {eventId: scope.eventId, attendeeId: scope.attendeeId,
      serverTime: now, revision: permission?.revision ?? null, preference,
      canEnable: availability === "ready", availability,
      phoneLastFour: phone?.slice(-4) ?? null,
      expiresAt: belongs ? permission!.expiresAt : null,
      consent: {version: SMS_CONSENT_VERSION, text: SMS_CONSENT_TEXT}};
  }

  private now(): number {
    const now = this.clock();
    if (!Number.isSafeInteger(now) || now < 0) {
      throw new Error("Invalid SMS preference clock");
    }
    return now;
  }
}
