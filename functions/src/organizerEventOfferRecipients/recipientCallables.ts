import * as admin from "firebase-admin";
import {onCall, HttpsError, type CallableRequest} from
  "firebase-functions/v2/https";
import {requireAuth} from "../shared/auth";
import {checkRateLimit} from "../shared/rateLimit";
import {appCheckCallableOptionsWithLimits} from "../shared/callableOptions";
import {validateCallableWithAjv} from "../shared/validation";
import type {ManageEventOfferCheckoutCallablePayload as Input} from
  "../shared/generated/manageEventOfferCheckoutCallablePayload";
import type {ManageEventOfferCheckoutCallableResponse as Response} from
  "../shared/generated/manageEventOfferCheckoutCallableResponse";
import type {PrepareEventOfferInvitationCallablePayload as InvitationInput} from
  "../shared/generated/prepareEventOfferInvitationCallablePayload";
import {validateManageEventOfferCheckoutCallablePayload as validateInput} from
  "../shared/generated/validators/manageEventOfferCheckoutInput";
import {validateManageEventOfferCheckoutCallableResponse as validateResponse}
  from "../shared/generated/validators/manageEventOfferCheckoutOutput";
import {validatePrepareEventOfferInvitationCallablePayload} from
  "../shared/generated/validators/prepareEventOfferInvitationInput";
import {eventOfferIntegrationReady} from
  "../organizerEventOffers/offerIntegration";
import {prepareRazorpayCollectionRouting} from
  "../payments/razorpayCollectionRouting";
import {offerPaymentId, OFFER_PAYMENT_COLLECTION, parseOfferPayment,
  reserveOfferPayment} from "../payments/offerPayments/offerPaymentReservation";
import {offerPaymentExecutionFor} from
  "../payments/offerPayments/offerPaymentRuntime";
import {projectOfferPayment} from
  "../payments/offerPayments/offerPaymentProjection";
import {issueOfferRecipientInvitation, claimOfferRecipientInvitation,
  readVerifiedOfferRecipient, offerRecipientGrantId} from "./recipientGrant";

export const recipientCallableDefaults = {
  db: () => admin.firestore(), rateLimit: checkRateLimit,
  enabled: eventOfferIntegrationReady, now: Date.now,
  issue: issueOfferRecipientInvitation, claim: claimOfferRecipientInvitation,
  readRecipient: readVerifiedOfferRecipient,
  prepareRouting: prepareRazorpayCollectionRouting,
  reserve: reserveOfferPayment, execution: offerPaymentExecutionFor,
  project: projectOfferPayment,
};
type Deps = typeof recipientCallableDefaults;

export async function prepareEventOfferInvitationHandler(
  request: CallableRequest<unknown>, deps: Deps = recipientCallableDefaults) {
  const uid = requireAuth(request);
  const data = validateCallableWithAjv<InvitationInput>(request,
    validatePrepareEventOfferInvitationCallablePayload);
  if (!deps.enabled()) unavailable();
  const db = deps.db();
  await deps.rateLimit(db, uid, "prepareEventOfferInvitation");
  const invitation = await deps.issue({db, actorUid: uid,
    scope: {organizerId: data.organizerId, eventId: data.eventId,
      offerId: data.offerId, responseId: data.responseId},
    expectedOfferGeneration: data.expectedOfferGeneration,
    expectedOfferRevision: data.expectedOfferRevision, nowMillis: deps.now});
  // Link preparation is not delivery. The token never enters a URL query/path.
  return {url: `https://catchdates.com/offer#${invitation.token}`,
    expiresAtMillis: invitation.expiresAtMillis};
}

export async function manageEventOfferCheckoutHandler(
  request: CallableRequest<unknown>, deps: Deps = recipientCallableDefaults):
  Promise<Response> {
  const uid = requireAuth(request);
  const phone = request.auth?.token.phone_number;
  if (typeof phone !== "string" || !/^\+[1-9][0-9]{7,14}$/u.test(phone)) {
    throw new HttpsError("unauthenticated", "Verify your phone to continue.");
  }
  const data = validateCallableWithAjv<Input>(request, validateInput);
  const db = deps.db();
  await deps.rateLimit(db, uid, "manageEventOfferCheckout");
  const result: Response = {grant: null, payment: null,
    serverTimeMillis: deps.now()};
  if (data.action === "claim") {
    // A returning payer can recover history even after the offer expires.
    const grantId = offerRecipientGrantId(data.token);
    result.payment = await findOwnedPayment(db, uid, grantId, deps);
    if (result.payment) return checkedResponse(result, deps.now());
    if (!deps.enabled()) unavailable();
    const claimed = await deps.claim({db, uid, token: data.token,
      authTokenPhoneNumber: phone, nowMillis: deps.now});
    const {source} = await db.runTransaction((tx) => deps.readRecipient({
      db, tx, grantId: claimed.grantId, uid, nowMillis: deps.now()}));
    const terms = source.offer.paymentSnapshot;
    if (terms.collectionMode !== "catchCheckout" || terms.currency !== "INR" ||
        typeof terms.expectedAmountMinor !== "number" ||
        terms.expectedAmountMinor < 100) unavailable();
    result.grant = {grantId: claimed.grantId, eventId: source.offer.eventId,
      eventName: (source.event.name?.trim() || "Your event").slice(0, 200),
      startTimeMillis: source.event.startTime.toMillis(),
      amountPaise: terms.expectedAmountMinor, currency: "INR",
      expiresAtMillis: claimed.expiresAtMillis};
  } else if (data.action === "find") {
    result.payment = await findOwnedPayment(db, uid, data.grantId, deps);
  } else {
    const paymentId = data.action === "prepare" ?
      offerPaymentId(data.grantId, uid, data.requestId) : data.paymentId;
    const snap = await db.collection(OFFER_PAYMENT_COLLECTION)
      .doc(paymentId).get();
    let payment;
    if (snap.exists) {
      payment = parseOfferPayment(snap.data(), paymentId);
      if (payment.recipientUid !== uid || data.action === "prepare" &&
          payment.grantId !== data.grantId) unavailable();
    } else {
      if (data.action !== "prepare" || !deps.enabled()) unavailable();
      const {grant, source} = await db.runTransaction((tx) =>
        deps.readRecipient({db, tx, grantId: data.grantId,
          uid, nowMillis: deps.now()}));
      const terms = source.offer.paymentSnapshot;
      if (terms.collectionMode !== "catchCheckout" ||
          terms.currency !== "INR" ||
          typeof terms.expectedAmountMinor !== "number" ||
          terms.expectedAmountMinor < 100) unavailable();
      const routing = await deps.prepareRouting({db,
        organizerId: grant.organizerId, purpose: "eventAdmission",
        connectionId: null,
        amountMinor: terms.expectedAmountMinor});
      payment = (await deps.reserve({db, grantId: data.grantId,
        uid, requestId: data.requestId, routing,
        nowMillis: deps.now})).payment;
    }
    // Ended history stays readable without provider readiness or activation.
    if (!payment.admissionReceiptId &&
        !["refunded", "reviewRequired"].includes(payment.status) &&
        !(payment.status === "expired" &&
          (data.action !== "status" || !data.callback))) {
      const processor = await deps.execution({db, paymentId});
      payment = data.action === "status" && data.callback ?
        await processor.verifyClientCallback({uid,
          providerPaymentId: data.callback.paymentId,
          signature: data.callback.signature}) :
        data.action === "prepare" ? await processor.ensureOrder() :
          await processor.reconcile();
    }
    result.payment = await deps.project({db, paymentId, payment,
      uid, nowMillis: deps.now()});
  }
  return checkedResponse(result, deps.now());
}

function checkedResponse(result: Response, nowMillis: number): Response {
  result.serverTimeMillis = nowMillis;
  if (!validateResponse(result)) {
    throw new HttpsError("internal", "Invalid checkout result.");
  }
  return result;
}

async function findOwnedPayment(db: FirebaseFirestore.Firestore, uid: string,
  grantId: string, deps: Deps): Promise<Response["payment"]> {
  const candidates = await db.collection(OFFER_PAYMENT_COLLECTION)
    .where("grantId", "==", grantId).where("recipientUid", "==", uid)
    .orderBy("createdAt", "desc").limit(1).get();
  const snap = candidates.docs[0];
  if (!snap) return null;
  const payment = parseOfferPayment(snap.data(), snap.id);
  if (payment.grantId !== grantId || payment.recipientUid !== uid) {
    unavailable();
  }
  return deps.project({db, paymentId: snap.id, payment,
    uid, nowMillis: deps.now()});
}

function unavailable(): never {
  throw new HttpsError("failed-precondition",
    "This invitation is unavailable.");
}
export const prepareEventOfferInvitation = onCall(
  appCheckCallableOptionsWithLimits({timeoutSeconds: 120,
    maxInstances: 10, concurrency: 10}),
  (request) => prepareEventOfferInvitationHandler(request));
export const manageEventOfferCheckout = onCall(
  appCheckCallableOptionsWithLimits({timeoutSeconds: 120,
    maxInstances: 10, concurrency: 10}),
  (request) => manageEventOfferCheckoutHandler(request));
