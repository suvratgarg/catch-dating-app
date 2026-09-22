import * as admin from "firebase-admin";
import {onCall, HttpsError, type CallableRequest} from
  "firebase-functions/v2/https";
import type {PrepareOrganizerFormPaymentCallablePayload} from
  "../../shared/generated/prepareOrganizerFormPaymentCallablePayload";
import type {GetOrganizerFormPaymentCallablePayload} from
  "../../shared/generated/getOrganizerFormPaymentCallablePayload";
import type {ManageOrganizerFormPaymentConnectionCallablePayload} from
  "../../shared/generated/manageOrganizerFormPaymentConnectionCallablePayload";
import type {ManageOrganizerFormPaymentConnectionCallableResponse} from
  "../../shared/generated/manageOrganizerFormPaymentConnectionCallableResponse";
import {validatePrepareOrganizerFormPaymentCallablePayload} from
  "../../shared/generated/validators/prepareOrganizerFormPaymentInput";
import {validateGetOrganizerFormPaymentCallablePayload} from
  "../../shared/generated/validators/getOrganizerFormPaymentInput";
import {validateManageOrganizerFormPaymentConnectionCallablePayload} from
  "../../shared/generated/validators/manageOrganizerFormPaymentConnectionInput";
import type {OrganizerFormResponseDraftDocument as Draft,
  OrganizerFormVersionDocument as Version,
  OrganizerFormPaymentDocument as Payment,
  OrganizerPaymentConnectionDocument as Connection} from
  "../../shared/generated/firestoreAdminTypes";
import {requireAuth} from "../../shared/auth";
import {checkRateLimit} from "../../shared/rateLimit";
import {requireOrganizerManager} from "../../shared/organizerManagerAuthority";
import {appCheckCallableOptionsWithLimits} from "../../shared/callableOptions";
import {requireDoc, validateCallableWithAjv} from "../../shared/validation";
import {reserveFormPayment} from "./formPaymentSubmission";
import {formPaymentRuntime, formPaymentsConfigured} from "./formPaymentRuntime";
import {projectFormPayment} from "./formPaymentProjection";

interface HandlerDeps {
  db: () => FirebaseFirestore.Firestore;
  runtime: typeof formPaymentRuntime;
  configured: typeof formPaymentsConfigured;
  rateLimit: typeof checkRateLimit;
  requireManager: typeof requireOrganizerManager;
}
const defaults: HandlerDeps = {db: () => admin.firestore(),
  runtime: formPaymentRuntime, configured: formPaymentsConfigured,
  rateLimit: checkRateLimit, requireManager: requireOrganizerManager};

export async function prepareOrganizerFormPaymentHandler(
  request: CallableRequest<unknown>, deps: HandlerDeps = defaults) {
  const uid = requireAuth(request);
  const data = validateCallableWithAjv<
    PrepareOrganizerFormPaymentCallablePayload>(request,
      validatePrepareOrganizerFormPaymentCallablePayload);
  const db = deps.db();
  await deps.rateLimit(db, uid, "prepareOrganizerFormPayment");
  const draft = requireDoc<Draft>(await db
    .collection("organizerFormResponseDrafts").doc(data.draftId).get(),
  "OrganizerFormResponseDraftDocument");
  if (draft.respondentUid !== uid) unavailable();
  const version = requireDoc<Version>(await db
    .collection("organizerFormVersions").doc(draft.versionId).get(),
  "OrganizerFormVersionDocument");
  const fee = version.definition.payment;
  if (!fee || version.organizerId !== draft.organizerId ||
      version.formId !== draft.formId) unavailable();
  const runtime = await deps.runtime();
  const connection = requireDoc<Connection>(await db
    .collection("organizerPaymentConnections").doc(fee.connectionId).get(),
  "OrganizerPaymentConnectionDocument");
  if (connection.organizerId !== draft.organizerId ||
      !connection.accountId) unavailable();
  await runtime.credentials.access({organizerId: draft.organizerId,
    connectionId: fee.connectionId, accountId: connection.accountId,
    mode: connection.mode});
  const {paymentId} = await reserveFormPayment({db, request, data,
    now: admin.firestore.Timestamp.now()});
  const payment = await runtime.processor.ensureOrder(paymentId);
  return projectFormPayment({db, paymentId, payment, respondentUid: uid});
}

export async function getOrganizerFormPaymentHandler(
  request: CallableRequest<unknown>, deps: HandlerDeps = defaults) {
  const uid = requireAuth(request);
  const data = validateCallableWithAjv<GetOrganizerFormPaymentCallablePayload>(
    request, validateGetOrganizerFormPaymentCallablePayload);
  const db = deps.db();
  await deps.rateLimit(db, uid, "getOrganizerFormPayment");
  const current = requireDoc<Payment>(await db
    .collection("organizerFormPayments").doc(data.paymentId).get(),
  "OrganizerFormPaymentDocument");
  if (current.respondentUid !== uid) unavailable();
  // Completed receipts do not depend on provider availability. Refund updates
  // continue through signed callbacks and the recovery sweep.
  if (current.responseId) {
    return projectFormPayment({db,
      paymentId: data.paymentId, payment: current, respondentUid: uid});
  }
  const {processor} = await deps.runtime();
  const payment = data.callback ?
    await processor.verifyClientCallback({paymentId: data.paymentId,
      respondentUid: uid, providerPaymentId: data.callback.paymentId,
      signature: data.callback.signature}) :
    await processor.reconcile(data.paymentId);
  return projectFormPayment({db, paymentId: data.paymentId, payment,
    respondentUid: uid});
}

export async function manageOrganizerFormPaymentConnectionHandler(
  request: CallableRequest<unknown>, deps: HandlerDeps = defaults):
  Promise<ManageOrganizerFormPaymentConnectionCallableResponse> {
  const uid = requireAuth(request);
  const data = validateCallableWithAjv<
    ManageOrganizerFormPaymentConnectionCallablePayload>(request,
      validateManageOrganizerFormPaymentConnectionCallablePayload);
  const db = deps.db();
  await deps.rateLimit(db, uid, "manageOrganizerFormPaymentConnection");
  await deps.requireManager({db, organizerId: data.organizerId, actorUid: uid});
  const result: ManageOrganizerFormPaymentConnectionCallableResponse = {
    available: deps.configured(), authorizationUrl: null, connectionId: null,
    expiresAtMillis: null, connections: []};
  if (data.action === "begin") {
    if (data.connectionId !== null) invalidAction();
    const {connections} = await deps.runtime();
    return {...result, ...await connections.begin(data.organizerId, uid)};
  }
  if (data.action === "disconnect") {
    if (!data.connectionId) invalidAction();
    const {connections} = await deps.runtime();
    await connections.disconnect(data.organizerId, uid, data.connectionId);
  } else if (data.connectionId !== null) invalidAction();
  const snaps = await db.collection("organizerPaymentConnections")
    .where("organizerId", "==", data.organizerId)
    .orderBy("createdAt", "desc").limit(100).get();
  result.connections = snaps.docs.map((snap) => {
    const value = requireDoc<Connection>(snap,
      "OrganizerPaymentConnectionDocument");
    return {connectionId: snap.id, status: value.status, mode: value.mode,
      accountId: value.accountId, webhookVerified: !!value.webhookVerifiedAt,
      lastErrorCode: value.lastErrorCode};
  });
  return result;
}

function unavailable(): never {
  throw new HttpsError("permission-denied", "Payment unavailable.");
}
function invalidAction(): never {
  throw new HttpsError("invalid-argument", "Invalid connection action.");
}

const limits = {timeoutSeconds: 120, maxInstances: 20};
export const prepareOrganizerFormPayment = onCall(
  appCheckCallableOptionsWithLimits(limits),
  (request) => prepareOrganizerFormPaymentHandler(request));
export const getOrganizerFormPayment = onCall(
  appCheckCallableOptionsWithLimits(limits),
  (request) => getOrganizerFormPaymentHandler(request));
export const manageOrganizerFormPaymentConnection = onCall(
  appCheckCallableOptionsWithLimits(limits),
  (request) => manageOrganizerFormPaymentConnectionHandler(request));
