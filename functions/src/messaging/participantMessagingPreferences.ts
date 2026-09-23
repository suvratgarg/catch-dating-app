import {createHash} from "node:crypto";
import * as admin from "firebase-admin";
import {FieldPath, Timestamp} from "firebase-admin/firestore";
import {HttpsError, onCall, type CallableRequest} from
  "firebase-functions/v2/https";
import {requireAuth} from "../shared/auth";
import {appCheckCallableOptionsWithLimits} from "../shared/callableOptions";
import {checkRateLimit} from "../shared/rateLimit";
import {requireDoc, validateCallableWithAjv} from "../shared/validation";
import {organizerCommunicationPreferenceId,
  unknownOrganizerCommunicationChannel} from
  "../shared/organizerCommunicationPreferences";
import type {CatchCommunicationPreferenceDocument as CatchPreference,
  OrganizerCommunicationPreferenceDocument as OrganizerPreference,
  CatchCommunicationPermissionReceiptDocument as CatchReceipt,
  OrganizerCommunicationPermissionReceiptDocument as OrganizerReceipt} from
  "../shared/generated/firestoreAdminTypes";
import type {ListParticipantMessagingPreferencesCallableResponse as Page} from
  "../shared/generated/listParticipantMessagingPreferencesCallableResponse";
import type {WithdrawParticipantMessagingPermissionCallableResponse as Result}
  from
  "../shared/generated/withdrawParticipantMessagingPermissionCallableResponse";
import {validateListParticipantMessagingPreferencesCallablePayload} from
  "../shared/generated/validators/listParticipantMessagingPreferencesInput";
import {validateWithdrawParticipantMessagingPermissionCallablePayload} from
  "../shared/generated/validators/withdrawParticipantMessagingPermissionInput";

type Preference = CatchPreference | OrganizerPreference;
type Scope = "catch" | "organizer";
interface Deps {
  db: () => FirebaseFirestore.Firestore;
  now: () => Timestamp;
  rateLimit: typeof checkRateLimit;
}
const defaults: Deps = {db: () => admin.firestore(), now: () => Timestamp.now(),
  rateLimit: checkRateLimit};

function readPreference(snap: FirebaseFirestore.DocumentSnapshot, uid: string,
  scope: Scope, organizerId: string | null): Preference | null {
  if (!snap.exists) return null;
  const value = scope === "catch" ?
    requireDoc<CatchPreference>(snap, "CatchCommunicationPreferenceDocument") :
    requireDoc<OrganizerPreference>(snap,
      "OrganizerCommunicationPreferenceDocument");
  if (value.uid !== uid || (scope === "organizer" &&
      (value as OrganizerPreference).organizerId !== organizerId)) {
    throw new HttpsError("failed-precondition",
      "Messaging permission ownership is inconsistent.");
  }
  return value;
}

async function summarize(db: FirebaseFirestore.Firestore,
  tx: FirebaseFirestore.Transaction, value: Preference | null, scope: Scope):
  Promise<Page["catchPreference"]> {
  const channel = value?.whatsapp;
  const receiptId = channel?.currentReceiptId ?? null;
  if (channel?.status === "optedOut") return {status: "optedOut", receiptId};
  if (!value || channel?.status !== "optedIn" ||
      channel.evidenceStatus !== "complete" || !receiptId) {
    return {status: "unknown", receiptId};
  }
  const receipt = (await tx.get(db.collection(scope === "catch" ?
    "catchCommunicationPermissionReceipts" :
    "organizerCommunicationPermissionReceipts").doc(receiptId)))
    .data() as CatchReceipt | OrganizerReceipt | undefined;
  const complete = receipt?.uid === value.uid &&
    receipt.channel === "whatsapp" && receipt.decision === "optedIn" &&
    receipt.evidenceStatus === "complete" &&
    receipt.termsVersion === channel.termsVersion &&
    typeof receipt.consentCopyHash === "string" &&
    /^[a-f0-9]{64}$/u.test(receipt.consentCopyHash) &&
    receipt.grantedAt != null && receipt.revokedAt === null &&
    (scope === "catch" || (receipt as OrganizerReceipt).organizerId ===
      (value as OrganizerPreference).organizerId);
  return {status: complete ? "optedIn" : "unknown", receiptId};
}

async function assertActiveAccount(db: FirebaseFirestore.Firestore,
  tx: FirebaseFirestore.Transaction, uid: string): Promise<void> {
  if ((await tx.get(db.collection("deletedUsers").doc(uid))).exists) {
    throw new HttpsError("not-found",
      "These messaging settings are unavailable.");
  }
}

export async function listParticipantMessagingPreferencesHandler(
  request: CallableRequest<unknown>, deps: Deps = defaults): Promise<Page> {
  const uid = requireAuth(request);
  const data = validateCallableWithAjv(request,
    validateListParticipantMessagingPreferencesCallablePayload);
  const db = deps.db();
  await deps.rateLimit(db, uid, "listParticipantMessagingPreferences");
  const catchPreference = await db.runTransaction(async (tx) => {
    await assertActiveAccount(db, tx, uid);
    const value = readPreference(await tx.get(db.collection(
      "catchCommunicationPreferences").doc(uid)), uid, "catch", null);
    return summarize(db, tx, value, "catch");
  });
  let query = db.collection("organizerCommunicationPreferences")
    .where("uid", "==", uid).orderBy(FieldPath.documentId())
    .limit(data.limit + 1);
  if (data.cursor) query = query.startAfter(data.cursor);
  const result = await query.get();
  const page = result.docs.slice(0, data.limit);
  const organizers: Page["organizers"] = [];
  for (const row of page) {
    const projected = await db.runTransaction(async (tx) => {
      await assertActiveAccount(db, tx, uid);
      const snap = await tx.get(row.ref);
      if (!snap.exists) return null;
      const organizerId = snap.data()?.organizerId;
      if (typeof organizerId !== "string" || row.id !==
          organizerCommunicationPreferenceId(organizerId, uid)) {
        throw new HttpsError("failed-precondition",
          "Messaging permission ownership is inconsistent.");
      }
      const value = readPreference(snap, uid, "organizer", organizerId)!;
      const organizer = await
      tx.get(db.collection("organizers").doc(organizerId));
      const name = organizer.data()?.name;
      return {organizerId, organizerName: typeof name === "string" ? name :
        null,
      preference: await summarize(db, tx, value, "organizer")};
    });
    if (projected) organizers.push(projected);
  }
  return {catchPreference, organizers, nextCursor:
    result.docs.length > data.limit ? page.at(-1)!.id : null};
}

export async function withdrawParticipantMessagingPermissionHandler(
  request: CallableRequest<unknown>, deps: Deps = defaults): Promise<Result> {
  const uid = requireAuth(request);
  const data = validateCallableWithAjv(request,
    validateWithdrawParticipantMessagingPermissionCallablePayload);
  if ((data.scope === "catch") !== (data.organizerId === null)) {
    throw new HttpsError("invalid-argument", "Choose one messaging sender.");
  }
  const db = deps.db();
  await deps.rateLimit(db, uid, "withdrawParticipantMessagingPermission");
  const scope = data.scope;
  const receiptId = "pmpr_" + createHash("sha256").update(JSON.stringify([
    uid, scope, data.organizerId, data.requestId])).digest("hex").slice(0, 48);
  const preferenceRef = scope === "catch" ?
    db.collection("catchCommunicationPreferences").doc(uid) :
    db.collection("organizerCommunicationPreferences").doc(
      organizerCommunicationPreferenceId(data.organizerId!, uid));
  const receiptRef = db.collection(scope === "catch" ?
    "catchCommunicationPermissionReceipts" :
    "organizerCommunicationPermissionReceipts").doc(receiptId);
  return db.runTransaction(async (tx) => {
    await assertActiveAccount(db, tx, uid);
    const [snap, replay] = await Promise.all([
      tx.get(preferenceRef), tx.get(receiptRef),
    ]);
    const previous = readPreference(snap, uid, scope, data.organizerId);
    if (replay.exists) {
      const receipt = replay.data() as CatchReceipt | OrganizerReceipt;
      if (receipt.uid !== uid || receipt.source !== "participantSettings" ||
          receipt.decision !== "optedOut" ||
          receipt.supersedesReceiptId !== data.expectedReceiptId) {
        throw new HttpsError("already-exists",
          "This request was used with different messaging settings.");
      }
      return {preference: await summarize(db, tx, previous, scope), replayed:
        true};
    }
    if ((previous?.whatsapp.currentReceiptId ?? null) !==
      data.expectedReceiptId) {
      throw new HttpsError("aborted",
        "Your messaging settings changed. Review them again.");
    }
    if (scope === "organizer" && !previous && !(await tx.get(
      db.collection("organizers").doc(data.organizerId!))).exists) {
      throw new HttpsError("not-found", "This organizer is unavailable.");
    }
    const now = deps.now();
    // Server ordering, including same-millisecond decisions, fences old drafts.
    const decidedAt = Timestamp.fromMillis(Math.max(now.toMillis(),
      (previous?.whatsapp.updatedAt?.toMillis() ?? -1) + 1));
    const channel: CatchPreference["whatsapp"] = {
      status: "optedOut", evidenceStatus: "complete", currentReceiptId:
        receiptId,
      termsVersion: null, source: "participantSettings", sourceEventId: null,
      updatedAt: decidedAt,
    };
    const receipt = {uid, channel: "whatsapp" as const,
      decision: "optedOut" as const, evidenceStatus: "complete" as const,
      termsVersion: null, consentCopyHash: null, source:
        "participantSettings" as const,
      sourceEventId: null, sourceFormId: null, sourceResponseId: null,
      sourceProviderEventId: null, actorClass: "participant" as const,
      actorUid: uid, identityStrength: "catchAccount" as const, grantedAt: null,
      revokedAt: decidedAt, supersedesReceiptId: data.expectedReceiptId,
      createdAt: now};
    if (scope === "catch") {
      const document: CatchPreference = {uid, whatsapp: channel,
        createdAt: previous?.createdAt ?? now, updatedAt: now};
      const evidence: CatchReceipt = {...receipt, sourceOrganizerId: null};
      tx.create(receiptRef, evidence);
      tx.set(preferenceRef, document);
    } else {
      const document: OrganizerPreference = {uid, organizerId:
        data.organizerId!,
      whatsapp: channel, sms: (previous as OrganizerPreference | null)?.sms ??
          unknownOrganizerCommunicationChannel(), createdAt:
            previous?.createdAt ?? now,
      updatedAt: now};
      const evidence: OrganizerReceipt = {...receipt, organizerId:
        data.organizerId!};
      tx.create(receiptRef, evidence);
      tx.set(preferenceRef, document);
    }
    return {preference: {status: "optedOut", receiptId}, replayed: false};
  });
}

export const listParticipantMessagingPreferences = onCall(
  appCheckCallableOptionsWithLimits({timeoutSeconds: 30, maxInstances: 20}),
  (request) => listParticipantMessagingPreferencesHandler(request));
export const withdrawParticipantMessagingPermission = onCall(
  appCheckCallableOptionsWithLimits({timeoutSeconds: 30, maxInstances: 20}),
  (request) => withdrawParticipantMessagingPermissionHandler(request));
