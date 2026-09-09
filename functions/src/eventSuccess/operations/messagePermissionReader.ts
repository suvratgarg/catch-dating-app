import type {Firestore, Transaction} from "firebase-admin/firestore";
import type {OrganizerSenderConnectionDocument as Connection} from
  "../../shared/generated/organizerSenderConnectionDocument";
import {validateOrganizerContactChannelStateDocument} from
  "../../shared/generated/validators/organizerContactChannelStateDocument";
import {parseWhatsappStop, WHATSAPP_ENDPOINT_STOPS, whatsappStopId} from
  "../../shared/organizerWhatsappStops";
import {GuestSourceFacts, readGuestSourceFacts, requireDocumentId} from
  "./guestRecords";
import {Permission as SmsPermission, parseSmsPermission, smsCollections,
  smsPermissionId} from "./smsPermissionRecords";
import {parseSmsConsentReceipt, SMS_CONSENT_RECEIPTS,
  smsPermissionHasReceipt} from "./smsConsent";
import {Permission as WhatsappPermission, parseWhatsappPermission,
  WHATSAPP_PERMISSIONS, whatsappPermissionId} from
  "./whatsappPermissionRecords";
import {parseWhatsappConsentReceipt, WHATSAPP_CONSENT_RECEIPTS,
  whatsappPermissionHasReceipt} from "./whatsappConsent";
import {whatsappEndpointHash} from "./whatsappReplyProtocol";

export type MessagePermissionScope = {context: SmsPermission["context"];
  attendeeId: string; senderId: string};
type Blocked = {kind: "blocked"; reason: "missingPermission" | "suppressed"};
type Allowed<T> = {kind: "allowed"; permission: T; source: GuestSourceFacts};

/** Exact event-service consent shared by planning and the final SMS claim. */
export async function readSmsMessagePermission(db: Firestore, tx: Transaction,
  scope: MessagePermissionScope, now: number):
  Promise<Blocked | Allowed<SmsPermission>> {
  requireClock(now);
  const {context, attendeeId, senderId} = scope;
  const id = smsPermissionId(context, attendeeId, senderId);
  const [permissionSnap, attendeeSnap] = await tx.getAll(
    db.collection(smsCollections.permissions).doc(id),
    db.collection("eventAttendees").doc(attendeeId));
  if (!permissionSnap.exists) return missing();
  const permission = parseSmsPermission(permissionSnap.data());
  if (permission.status !== "granted") return suppressed();
  const receiptSnap = await tx.get(db.collection(SMS_CONSENT_RECEIPTS)
    .doc(permission.currentReceiptId));
  const receipt = receiptSnap.exists ?
    parseSmsConsentReceipt(receiptSnap.data()) : null;
  if (!smsPermissionHasReceipt(permission, receipt)) return missing();
  const source = await readGuestSourceFacts(db, tx, context, attendeeId);
  const attendee = attendeeSnap.data();
  if (permission.permissionId !== id || permission.senderId !== senderId ||
      permission.attendeeGeneration !== source.attendeeGeneration ||
      permission.phoneE164 !== attendee?.phoneE164 ||
      permission.evidence.subjectUid !== attendee?.linkedUid ||
      permission.updatedAt > now || permission.expiresAt <= now ||
      now >= Math.floor(source.eventEnd) + 86_400_000) return missing();
  return {kind: "allowed", permission, source};
}

/** Sender consent and STOP/CRM suppression, without send rights. */
export async function readWhatsappMessagePermission(db: Firestore,
  tx: Transaction, scope: MessagePermissionScope, connection: Connection,
  now: number): Promise<Blocked | Allowed<WhatsappPermission> & {
    stop: ReturnType<typeof parseWhatsappStop> | null}> {
  requireClock(now);
  const {context, attendeeId, senderId} = scope;
  requireDocumentId(senderId);
  if (connection.organizerId !== context.organizerId ||
      connection.channel !== "whatsapp") return missing();
  const id = whatsappPermissionId(context, attendeeId, senderId);
  const [permissionSnap, attendeeSnap] = await tx.getAll(
    db.collection(WHATSAPP_PERMISSIONS).doc(id),
    db.collection("eventAttendees").doc(attendeeId));
  if (!permissionSnap.exists) return missing();
  const permission = parseWhatsappPermission(permissionSnap.data());
  if (permission.status !== "granted") return suppressed();
  const source = await readGuestSourceFacts(db, tx, context, attendeeId);
  const attendee = attendeeSnap.data();
  if (permission.permissionId !== id ||
      permission.attendeeGeneration !== source.attendeeGeneration ||
      permission.phoneE164 !== attendee?.phoneE164 ||
      permission.evidence.subjectUid !== attendee?.linkedUid ||
      permission.sender.providerAccountId !== connection.wabaId ||
      permission.sender.providerPhoneNumberId !== connection.phoneNumberId ||
      permission.updatedAt > now || permission.expiresAt <= now ||
      now >= Math.floor(source.eventEnd) + 86_400_000) return missing();
  const endpointHash = whatsappEndpointHash(permission.phoneE164)!;
  const stopId = whatsappStopId(context.organizerId, endpointHash);
  const [receiptSnap, stopSnap] = await tx.getAll(
    db.collection(WHATSAPP_CONSENT_RECEIPTS).doc(permission.currentReceiptId),
    db.collection(WHATSAPP_ENDPOINT_STOPS).doc(stopId));
  const receipt = receiptSnap.exists ?
    parseWhatsappConsentReceipt(receiptSnap.data()) : null;
  if (!whatsappPermissionHasReceipt(permission, receipt)) return missing();
  const stop = stopSnap.exists ? parseWhatsappStop(stopSnap.data()) : null;
  if (stop && (stop.stopId !== stopId || stop.observedAt > now ||
      stop.stoppedAt >= permission.evidence.acceptedAt)) return suppressed();
  // A CRM/admin pause remains separate from fresh event-specific consent.
  const states = await tx.get(db.collection("organizerContactChannelStates")
    .where("organizerId", "==", context.organizerId)
    .where("endpointHash", "==", endpointHash).limit(11));
  if (states.docs.length > 10 || states.docs.some((snap) => {
    const state = snap.data();
    return !validateOrganizerContactChannelStateDocument(state) ||
      state.organizerId !== context.organizerId ||
      state.endpointHash !== endpointHash || state.adminSuppressed === true ||
      (state.suppressionStatus !== "none" &&
        !(state.suppressionStatus === "optedOut" &&
          (state.suppressionSource === "preference" ||
            (state.suppressionSource === "inboundStop" && stop &&
              stop.stoppedAt < permission.evidence.acceptedAt))));
  })) return suppressed();
  return {kind: "allowed", permission, source, stop};
}

function missing(): Blocked {
  return {kind: "blocked", reason: "missingPermission"};
}
function suppressed(): Blocked {
  return {kind: "blocked", reason: "suppressed"};
}
function requireClock(now: number) {
  if (!Number.isSafeInteger(now) || now < 0) {
    throw new Error("Invalid communication permission clock");
  }
}
