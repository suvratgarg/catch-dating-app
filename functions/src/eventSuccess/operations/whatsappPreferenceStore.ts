import type {Firestore, Transaction} from "firebase-admin/firestore";
import {HttpsError} from "firebase-functions/v2/https";
import type {GetEventWhatsappPreferenceCallablePayload as Scope} from
  "../../shared/generated/getEventWhatsappPreferenceCallablePayload";
import type {SetEventWhatsappPreferenceCallablePayload as Submission} from
  "../../shared/generated/setEventWhatsappPreferenceCallablePayload";
import type {EventWhatsappPreferenceCallableResponse as Response} from
  "../../shared/generated/eventWhatsappPreferenceCallableResponse";
import {operationContentHash} from "../../operations/durableActions";
import {
  GuestSourceFacts, readGuestSourceFacts, requireDocumentId,
} from "./guestRecords";
import {
  Permission, parseWhatsappPermission, WHATSAPP_PERMISSIONS,
  whatsappPermissionId, whatsappSenderHash,
} from "./whatsappPermissionRecords";
import {
  ConsentReceipt, parseWhatsappConsentReceipt, WHATSAPP_CONSENT_HASH,
  WHATSAPP_CONSENT_RECEIPTS, WHATSAPP_CONSENT_TEXT, WHATSAPP_CONSENT_VERSION,
  whatsappPermissionHasReceipt,
} from "./whatsappConsent";
import {whatsappEndpointHash, whatsappEndpointId} from
  "./whatsappReplyProtocol";
import {ConsentSender, whatsappConsentSender} from "./whatsappConsentSender";
import {WHATSAPP_POLICIES} from "./whatsappTemplate";
import {runPreferenceTransaction} from "./preferenceTransaction";
import {EndpointStop, parseWhatsappStop, WHATSAPP_ENDPOINT_STOPS,
  whatsappStopId} from "../../shared/organizerWhatsappStops";

/** UID and phone are derived from Firebase Auth, never request data. */
export interface WhatsappPreferenceActor {uid: string; phone: string | null}
interface PreferenceFacts {
  context: Permission["context"];
  source: GuestSourceFacts;
  phone: string | null;
  permission: Permission | null;
  receipt: ConsentReceipt | null;
  sender: ConsentSender | null;
  stop: EndpointStop | null;
  stopInvalid: boolean;
}

export class WhatsappPreferenceStore {
  constructor(private readonly db: Firestore,
    private readonly clock: () => number = Date.now) {}

  async get(actor: WhatsappPreferenceActor, scope: Scope): Promise<Response> {
    return runPreferenceTransaction(this.db, async (tx) => ({outcome: "read",
      view: this.view(actor, scope, await this.read(tx, actor, scope),
        this.now())}));
  }

  async set(actor: WhatsappPreferenceActor,
    input: Submission): Promise<Response> {
    requireDocumentId(input.requestId);
    const receiptId = "wa-consent:" + operationContentHash([
      actor.uid, input.eventId, input.attendeeId,
      input.senderId, input.requestId,
    ]);
    const requestHash = operationContentHash([actor.uid, input]);
    return runPreferenceTransaction(this.db, async (tx) => {
      const facts = await this.read(tx, actor, input);
      const ref = this.db.collection(WHATSAPP_CONSENT_RECEIPTS)
        .doc(receiptId);
      const existing = await tx.get(ref);
      const now = this.now();
      const currentView = this.view(actor, input, facts, now);
      if (existing.exists) {
        const prior = parseWhatsappConsentReceipt(existing.data());
        if (prior.receiptId !== receiptId ||
            prior.requestHash !== requestHash) {
          throw new HttpsError("invalid-argument",
            "Use a new preference request.");
        }
        // Replays cannot restore a withdrawn grant.
        return {outcome: "replayed", view: currentView};
      }
      const previous = facts.permission;
      if ((previous?.revision ?? null) !== input.expectedRevision) {
        return {outcome: "conflict", view: currentView};
      }
      const granting = input.decision.kind === "grant";
      if (input.decision.kind === "grant" && (!currentView.canEnable ||
          input.decision.copyVersion !== WHATSAPP_CONSENT_VERSION ||
          input.decision.senderHash !== currentView.sender?.bindingHash ||
          input.decision.stopRecordHash !== currentView.stopRecordHash ||
          now <= (facts.stop?.stoppedAt ?? -1))) {
        throw new HttpsError("failed-precondition",
          "Event WhatsApp updates cannot be enabled right now.");
      }
      // Withdrawal preserves the original binding even after number, sender
      // or roster changes. It never rewrites old evidence onto a new identity.
      const phone = granting ? facts.phone :
        previous?.phoneE164 ?? facts.phone;
      const sender = granting ? facts.sender?.identity :
        previous?.sender ?? facts.sender?.identity;
      if (!phone || !sender) {
        throw new HttpsError("failed-precondition",
          "There is no event WhatsApp preference to update.");
      }
      const senderHash = whatsappSenderHash(facts.context.organizerId,
        input.senderId, sender);
      const permissionId = whatsappPermissionId(facts.context,
        input.attendeeId, input.senderId);
      const evidence = granting ? {receiptId, senderHash,
        copyVersion: WHATSAPP_CONSENT_VERSION, acceptedAt: now,
        // Time the signed phone claim was checked, not a claim of a new OTP.
        phoneVerifiedAt: now, subjectUid: actor.uid} :
        previous?.evidence ?? null;
      const permission = parseWhatsappPermission({schemaVersion: 1,
        permissionId, currentReceiptId: receiptId,
        revision: (previous?.revision ?? 0) + 1,
        context: facts.context, attendeeId: input.attendeeId,
        attendeeGeneration: granting ? facts.source.attendeeGeneration :
          previous?.attendeeGeneration ?? facts.source.attendeeGeneration,
        senderId: input.senderId, sender, routeId: "organizerEventWhatsapp",
        purpose: "eventService", phoneE164: phone,
        recipientEndpointId: whatsappEndpointId(phone),
        status: granting ? "granted" : "revoked", evidence,
        expiresAt: granting ? Math.floor(facts.source.eventEnd) + 86_400_000 :
          previous?.expiresAt ??
          Math.max(now, Math.floor(facts.source.eventEnd)),
        updatedAt: now});
      const receipt = parseWhatsappConsentReceipt({schemaVersion: 1, receiptId,
        requestHash, source: "verifiedParticipant", linkId: null,
        context: facts.context, attendeeId: input.attendeeId,
        attendeeGeneration: permission.attendeeGeneration,
        senderId: input.senderId, senderHash, routeId: "organizerEventWhatsapp",
        actorUid: actor.uid,
        recipientEndpointId: permission.recipientEndpointId,
        decision: input.decision.kind,
        copyVersion: granting ? WHATSAPP_CONSENT_VERSION : null,
        copyHash: granting ? WHATSAPP_CONSENT_HASH : null,
        appliedRevision: permission.revision, createdAt: now,
        permissionHash: operationContentHash(permission)});
      tx.create(ref, receipt);
      tx.set(this.db.collection(WHATSAPP_PERMISSIONS).doc(permissionId),
        permission);
      return {outcome: "applied", view: this.view(actor, input,
        {...facts, permission, receipt}, now)};
    });
  }

  private async read(tx: Transaction, actor: WhatsappPreferenceActor,
    scope: Scope): Promise<PreferenceFacts> {
    [scope.eventId, scope.attendeeId, scope.senderId, actor.uid]
      .forEach(requireDocumentId);
    const [eventSnap, attendeeSnap, senderSnap, policySnap] = await tx.getAll(
      this.db.collection("events").doc(scope.eventId),
      this.db.collection("eventAttendees").doc(scope.attendeeId),
      this.db.collection("organizerSenderConnections").doc(scope.senderId),
      this.db.collection(WHATSAPP_POLICIES).doc(scope.senderId),
    );
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
    const id = whatsappPermissionId(context, scope.attendeeId, scope.senderId);
    const permissionSnap = await tx.get(this.db
      .collection(WHATSAPP_PERMISSIONS).doc(id));
    const permission = permissionSnap.exists ?
      parseWhatsappPermission(permissionSnap.data()) : null;
    if (permission && permission.permissionId !== id) {
      throw new HttpsError("internal", "Event preference identity mismatch.");
    }
    const receiptSnap = permission ? await tx.get(this.db
      .collection(WHATSAPP_CONSENT_RECEIPTS)
      .doc(permission.currentReceiptId)) : null;
    const receipt = receiptSnap?.exists ?
      parseWhatsappConsentReceipt(receiptSnap.data()) : null;
    const endpoint = whatsappEndpointHash(attendee.phoneE164);
    let stop: EndpointStop | null = null;
    let stopInvalid = false;
    if (endpoint) {
      const stopId = whatsappStopId(context.organizerId, endpoint);
      const stopSnap = await tx.get(this.db
        .collection(WHATSAPP_ENDPOINT_STOPS).doc(stopId));
      if (stopSnap.exists) {
        try {
          stop = parseWhatsappStop(stopSnap.data());
          if (stop.stopId !== stopId) throw new Error("Stop identity mismatch");
        } catch {
          stop = null;
          stopInvalid = true;
        }
      }
    }
    return {context, source, permission, receipt, stop, stopInvalid,
      sender: whatsappConsentSender(scope.senderId, context.organizerId,
        senderSnap.data(), policySnap.data()),
      phone: whatsappEndpointHash(attendee.phoneE164) ?
        attendee.phoneE164 : null};
  }

  private view(actor: WhatsappPreferenceActor, scope: Scope,
    facts: PreferenceFacts, now: number): Response["view"] {
    const {source, sender, permission, receipt, phone, stop} = facts;
    if (now < (permission?.updatedAt ?? 0) || now < (receipt?.createdAt ?? 0)) {
      throw new HttpsError("unavailable", "Event preference clock is behind.");
    }
    const belongs = permission !== null &&
      permission.attendeeGeneration === source.attendeeGeneration &&
      permission.phoneE164 === phone &&
      (permission.evidence === null ||
        permission.evidence.subjectUid === actor.uid) &&
      (!sender || (permission.sender.providerAccountId ===
        sender.identity.providerAccountId &&
        permission.sender.providerPhoneNumberId ===
        sender.identity.providerPhoneNumberId));
    const proof = belongs && whatsappPermissionHasReceipt(permission!, receipt);
    let availability: Response["view"]["availability"] = "ready";
    if (!phone || phone !== actor.phone) availability = "verifyPhone";
    else if (!["registered", "checkedIn"].includes(source.attendeeStatus)) {
      availability = "notAdmitted";
    } else if (source.eventStatus !== "active" ||
        now >= source.eventEnd + 86_400_000) availability = "eventClosed";
    else if (facts.stopInvalid || (stop?.observedAt ?? 0) > now ||
        !sender?.connectionReady || !sender.policy ||
        sender.policy.status !== "ready" ||
        sender.policy.activation.approvedAt > now ||
        sender.policy.activation.validUntil <= now ||
        !sender.policy.quote.recipientPrefixes.some((p) =>
          phone.startsWith(p))) {
      availability = "senderUnavailable";
    }
    const stopped = stop !== null && permission?.evidence !== null &&
      stop.stoppedAt >= (permission?.evidence?.acceptedAt ?? 0);
    const preference: Response["view"]["preference"] = !belongs ? "notSet" :
      permission!.status === "revoked" ? "disabled" :
        stopped ? "disabled" :
          !proof ? "notSet" :
          permission!.expiresAt <= now ? "expired" : "enabled";
    const identity = sender?.identity ?? permission?.sender;
    return {eventId: scope.eventId, attendeeId: scope.attendeeId,
      senderId: scope.senderId, serverTime: now,
      revision: permission?.revision ?? null, preference,
      stopRecordHash: stop ? operationContentHash(stop) : null,
      canEnable: availability === "ready", availability,
      phoneLastFour: phone?.slice(-4) ?? null,
      expiresAt: belongs ? permission!.expiresAt : null,
      sender: identity ? {displayName: identity.displayName,
        displayPhoneNumber: identity.displayPhoneNumber,
        bindingHash: whatsappSenderHash(facts.context.organizerId,
          scope.senderId, identity)} : null,
      consent: {version: WHATSAPP_CONSENT_VERSION,
        text: WHATSAPP_CONSENT_TEXT}};
  }

  private now(): number {
    const now = this.clock();
    if (!Number.isSafeInteger(now) || now < 0) {
      throw new Error("Invalid WhatsApp preference clock");
    }
    return now;
  }
}
