import {createHash} from "node:crypto";
import {FieldValue, Timestamp} from "firebase-admin/firestore";
import {CallableRequest, HttpsError} from "firebase-functions/v2/https";
import type {OrganizerFormDocument as Form,
  OrganizerFormVersionDocument as Version,
  OrganizerFormResponseDraftDocument as Draft,
  OrganizerFormPaymentDocument as Payment,
  OrganizerPaymentConnectionDocument as Connection} from
  "../../shared/generated/firestoreAdminTypes";
import type {SubmitOrganizerFormResponseCallablePayload} from
  "../../shared/generated/submitOrganizerFormResponseCallablePayload";
import {requireDoc} from "../../shared/validation";
import {answersForSubmission} from "../../organizers/organizerFormLogic";
import {availabilityFor, persistOrganizerFormSubmission, requireReadyAssets,
  requireResponseIdentity, responseIdentitySnapshot, validateAnswerShape} from
  "../../organizers/organizerFormResponses";
import {requireReadyFormPaymentConnection} from "./formPaymentConnectionPolicy";
import {formPaymentId} from "./formPaymentIdentity";

/** Reserves capacity and freezes the draft before any provider side effect. */
export async function reserveFormPayment(params: {
  db: FirebaseFirestore.Firestore;
  request: CallableRequest<unknown>;
  data: SubmitOrganizerFormResponseCallablePayload;
  now: Timestamp;
}): Promise<{paymentId: string; payment: Payment}> {
  const {db, request, data, now} = params;
  const identity = requireResponseIdentity(request, "phoneVerified");
  const uid = identity.uid;
  if (!uid || identity.kind !== "phoneVerified") {
    throw new HttpsError("unauthenticated", "Verify your phone before paying.");
  }
  const paymentId = formPaymentId(data.draftId);
  const paymentRef = db.collection("organizerFormPayments").doc(paymentId);
  const draftRef = db.collection("organizerFormResponseDrafts")
    .doc(data.draftId);
  return db.runTransaction(async (tx) => {
    const [paymentSnap, draftSnap] = await Promise.all([
      tx.get(paymentRef), tx.get(draftRef),
    ]);
    if (paymentSnap.exists) {
      const payment = requireDoc<Payment>(paymentSnap,
        "OrganizerFormPaymentDocument");
      if (payment.respondentUid !== uid || payment.draftId !== data.draftId) {
        throw new HttpsError("permission-denied",
          "Payment unavailable.");
      }
      return {paymentId, payment};
    }
    if (!draftSnap.exists) {
      throw new HttpsError("not-found",
        "Response draft not found.");
    }
    const draft = requireDoc<Draft>(draftSnap,
      "OrganizerFormResponseDraftDocument");
    if (draft.respondentUid !== uid || draft.identityKind !== "phoneVerified") {
      throw new HttpsError("permission-denied",
        "Response draft unavailable.");
    }
    if (draft.status !== "active" || draft.paymentAttemptId ||
        draft.expiresAt.toMillis() <= now.toMillis()) {
      throw new HttpsError("failed-precondition",
        "This response is not editable.");
    }
    if (draft.revision !== data.expectedRevision) {
      throw new HttpsError("aborted",
        "This response changed. Reload it first.");
    }
    const [formSnap, versionSnap] = await Promise.all([
      tx.get(db.collection("organizerForms").doc(draft.formId)),
      tx.get(db.collection("organizerFormVersions").doc(draft.versionId)),
    ]);
    const form = requireDoc<Form>(formSnap, "OrganizerFormDocument");
    const version = requireDoc<Version>(versionSnap,
      "OrganizerFormVersionDocument");
    const fee = version.definition.payment;
    if (!fee || form.activeVersionId !== draft.versionId ||
        form.organizerId !== draft.organizerId ||
        version.organizerId !== draft.organizerId ||
        version.formId !== draft.formId ||
        version.definition.identityPolicy !== "phoneVerified") {
      throw new HttpsError("failed-precondition",
        "Reopen the current paid form.");
    }
    const availability = availabilityFor(form, version, now);
    if (availability.status !== "active") {
      throw new HttpsError("failed-precondition", availability.message);
    }
    if (!draft.consentAccepted ||
        draft.consentVersion !== version.definition.consent.consentVersion) {
      throw new HttpsError("failed-precondition",
        "Accept the form disclosure.");
    }
    const answers = answersForSubmission(version.definition, draft.answers);
    validateAnswerShape(version.definition, answers, true);
    const assets = await requireReadyAssets({tx, db, draftId: data.draftId,
      draft, definition: version.definition, answers});
    const connectionSnap = await tx.get(
      db.collection("organizerPaymentConnections").doc(fee.connectionId));
    const connection = requireReadyFormPaymentConnection(connectionSnap.exists ?
      requireDoc<Connection>(connectionSnap,
        "OrganizerPaymentConnectionDocument") : null,
    draft.organizerId, now.toMillis());
    const frozenIdentity = responseIdentitySnapshot(version.definition,
      answers, request);
    if (!frozenIdentity.phoneE164 ||
        !/^\+[1-9][0-9]{7,14}$/u.test(frozenIdentity.phoneE164)) {
      throw new HttpsError("failed-precondition",
        "Verify your phone number.");
    }
    const payment: Payment = {
      organizerId: draft.organizerId, formId: draft.formId,
      versionId: draft.versionId, draftId: data.draftId, respondentUid: uid,
      connectionId: fee.connectionId, accountId: connection.accountId!,
      mode: connection.mode, draftRevision: draft.revision,
      answersHash: frozenFormContentHash(draft, version),
      identity: frozenIdentity, amountPaise: fee.amountPaise, currency: "INR",
      description: fee.description, refundPolicy: fee.refundPolicy,
      receipt: `cfp_${digest(paymentId).slice(0, 32)}`,
      status: "creatingOrder", providerOrderId: null, providerPaymentId: null,
      providerRefundId: null, refundedAmountPaise: 0, responseId: null,
      reservationReleased: false, leaseUntil: null,
      createdAt: now, updatedAt: now,
      checkoutExpiresAt: Timestamp.fromMillis(now.toMillis() + 30 * 60_000),
      capturedAt: null, submittedAt: null, lastErrorCode: null,
    };
    // Keep uploads and the frozen draft through the reconciliation window.
    const expiresAt = Timestamp.fromMillis(now.toMillis() + 30 * 86400_000);
    tx.create(paymentRef, payment);
    tx.update(draftRef, {paymentAttemptId: paymentId, expiresAt,
      updatedAt: now});
    for (const ref of assets) tx.update(ref, {expiresAt});
    tx.update(formSnap.ref, {
      pendingPaymentCount: (form.pendingPaymentCount ?? 0) + 1,
    });
    return {paymentId, payment};
  });
}

/** No callable auth is fabricated: this consumes a verified server ledger. */
export async function finalizeCapturedFormPayment(params: {
  db: FirebaseFirestore.Firestore; paymentId: string; now: Timestamp;
}): Promise<Payment["status"]> {
  const {db, paymentId, now} = params;
  return db.runTransaction(async (tx) => {
    const ref = db.collection("organizerFormPayments").doc(paymentId);
    const payment = requireDoc<Payment>(await tx.get(ref),
      "OrganizerFormPaymentDocument");
    if (payment.responseId || payment.status !== "captured") {
      return payment.status;
    }
    if (!payment.capturedAt || !payment.providerPaymentId ||
        !payment.providerOrderId || payment.refundedAmountPaise !== 0) {
      throw new HttpsError("failed-precondition",
        "Payment is not finalizable.");
    }
    if (payment.reservationReleased) {
      tx.update(ref, {status: "refundPending", updatedAt: now,
        lastErrorCode: "reservationReleased"});
      return "refundPending";
    }
    const [draftSnap, versionSnap, formSnap] = await Promise.all([
      tx.get(db.collection("organizerFormResponseDrafts").doc(payment.draftId)),
      tx.get(db.collection("organizerFormVersions").doc(payment.versionId)),
      tx.get(db.collection("organizerForms").doc(payment.formId)),
    ]);
    const draft = draftSnap.exists ? requireDoc<Draft>(draftSnap,
      "OrganizerFormResponseDraftDocument") : null;
    const version = versionSnap.exists ? requireDoc<Version>(versionSnap,
      "OrganizerFormVersionDocument") : null;
    const form = formSnap.exists ? requireDoc<Form>(formSnap,
      "OrganizerFormDocument") : null;
    if (!canFinalizeFrozenForm({paymentId, payment, draft, version, form})) {
      tx.update(ref, {status: "refundPending", updatedAt: now,
        lastErrorCode: "frozenSubmissionUnavailable"});
      return "refundPending";
    }
    // Narrow after the predicate so callers cannot replace a frozen snapshot.
    if (!draft || !version || !form) throw new Error("Missing frozen form.");
    const answers = answersForSubmission(version.definition, draft.answers);
    let submittedAssetRefs: FirebaseFirestore.DocumentReference[];
    try {
      submittedAssetRefs = await requireReadyAssets({tx, db,
        draftId: payment.draftId, draft, definition: version.definition,
        answers});
    } catch (error) {
      if (!(error instanceof HttpsError) ||
          !["failed-precondition", "internal"].includes(error.code)) {
        throw error;
      }
      tx.update(ref, {status: "refundPending", updatedAt: now,
        lastErrorCode: "frozenUploadUnavailable"});
      return "refundPending";
    }
    const {responseId} = await persistOrganizerFormSubmission({tx, db,
      draftId: payment.draftId, draft, version, submittedAnswers: answers,
      identity: payment.identity, withdrawalTokenHash: null,
      submittedAssetRefs, now});
    tx.update(formSnap.ref, {
      pendingPaymentCount: FieldValue.increment(-1),
    });
    tx.update(ref, {status: "submitted", responseId, reservationReleased: true,
      submittedAt: now, updatedAt: now, lastErrorCode: null});
    return "submitted";
  });
}

/** Frees an expired checkout slot after provider reconciliation. */
export async function expireFormPaymentReservation(params: {
  db: FirebaseFirestore.Firestore; paymentId: string; now: Timestamp;
}): Promise<void> {
  const {db, paymentId, now} = params;
  await db.runTransaction(async (tx) => {
    const ref = db.collection("organizerFormPayments").doc(paymentId);
    const payment = requireDoc<Payment>(await tx.get(ref),
      "OrganizerFormPaymentDocument");
    if (payment.responseId || payment.reservationReleased ||
        payment.checkoutExpiresAt.toMillis() > now.toMillis()) return;
    const formRef = db.collection("organizerForms").doc(payment.formId);
    const formSnap = await tx.get(formRef);
    const form = formSnap.exists ? requireDoc<Form>(formSnap,
      "OrganizerFormDocument") : null;
    if (form && form.organizerId === payment.organizerId &&
        (form.pendingPaymentCount ?? 0) > 0) {
      tx.update(formRef, {pendingPaymentCount: FieldValue.increment(-1)});
    }
    const status = payment.status === "reviewRequired" ? "reviewRequired" :
      payment.refundedAmountPaise === payment.amountPaise ?
        "refunded" : payment.capturedAt ? "refundPending" : "expired";
    tx.update(ref, {status, reservationReleased: true, updatedAt: now});
  });
}

export function canFinalizeFrozenForm(params: {
  paymentId: string; payment: Payment; draft: Draft | null;
  version: Version | null; form: Form | null;
}): boolean {
  const {paymentId, payment, draft, version, form} = params;
  const fee = version?.definition.payment;
  return !!draft && !!version && !!form && !!fee &&
    draft.status === "active" && draft.paymentAttemptId === paymentId &&
    draft.identityKind === "phoneVerified" &&
    draft.respondentUid === payment.respondentUid &&
    draft.organizerId === payment.organizerId &&
    draft.formId === payment.formId && draft.versionId === payment.versionId &&
    draft.revision === payment.draftRevision && draft.consentAccepted &&
    draft.consentVersion === version.definition.consent.consentVersion &&
    version.formId === payment.formId &&
    version.organizerId === payment.organizerId &&
    form.organizerId === payment.organizerId &&
    (form.pendingPaymentCount ?? 0) > 0 &&
    fee.connectionId === payment.connectionId &&
    fee.amountPaise === payment.amountPaise &&
    fee.currency === payment.currency &&
    frozenFormContentHash(draft, version) === payment.answersHash;
}

export function frozenFormContentHash(draft: Draft, version: Version): string {
  const answers = answersForSubmission(version.definition, draft.answers);
  return digest(JSON.stringify({answers: Object.entries(answers)
    .sort(([left], [right]) => left.localeCompare(right)),
  consentAccepted: draft.consentAccepted,
  consentVersion: draft.consentVersion,
  ...(draft.messagingDecision ?
    {messagingDecision: draft.messagingDecision} : {})}));
}

function digest(value: string): string {
  return createHash("sha256").update(value).digest("hex");
}
