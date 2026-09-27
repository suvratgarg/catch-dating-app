import {HttpsError} from "firebase-functions/v2/https";
import type {GetOrganizerFormPaymentCallableResponse} from
  "../../shared/generated/getOrganizerFormPaymentCallableResponse";
import type {OrganizerFormPaymentDocument as Payment,
  OrganizerPaymentConnectionDocument as Connection,
  OrganizerFormResponseDocument as Response,
  OrganizerFormVersionDocument as Version} from
  "../../shared/generated/firestoreAdminTypes";
import {requireDoc} from "../../shared/validation";
import {assertPaymentRouteSnapshot} from "../paymentRouting";
import {organizerFormResponseReceipt} from
  "../../organizers/organizerFormResponses";

/** Never expose an order unless this caller owns its frozen submission. */
export async function projectFormPayment(input: {
  db: FirebaseFirestore.Firestore; paymentId: string; payment: Payment;
  respondentUid: string; now?: number;
}): Promise<GetOrganizerFormPaymentCallableResponse> {
  const {db, payment, paymentId, respondentUid} = input;
  if (payment.respondentUid !== respondentUid) {
    throw new HttpsError("permission-denied", "Payment unavailable.");
  }
  let receipt: GetOrganizerFormPaymentCallableResponse["receipt"] = null;
  let checkout: GetOrganizerFormPaymentCallableResponse["checkout"] = null;
  if (payment.responseId) {
    const [responseSnap, versionSnap] = await Promise.all([
      db.collection("organizerFormResponses").doc(payment.responseId).get(),
      db.collection("organizerFormVersions").doc(payment.versionId).get(),
    ]);
    const response = requireDoc<Response>(responseSnap,
      "OrganizerFormResponseDocument");
    const version = requireDoc<Version>(versionSnap,
      "OrganizerFormVersionDocument");
    if (response.respondentUid !== respondentUid ||
        response.formId !== payment.formId ||
        response.versionId !== payment.versionId ||
        response.organizerId !== payment.organizerId ||
        version.organizerId !== payment.organizerId ||
        version.formId !== payment.formId) {
      throw new HttpsError("internal", "Payment receipt unavailable.");
    }
    receipt = await organizerFormResponseReceipt(db, payment.responseId,
      response, version, null);
  } else if (["checkoutReady", "failed"].includes(payment.status) &&
      payment.providerOrderId &&
      !payment.reservationReleased &&
      payment.checkoutExpiresAt.toMillis() > (input.now ?? Date.now())) {
    let checkoutKey: string | null = null;
    if (payment.routing) {
      assertPaymentRouteSnapshot(payment.routing, {
        organizerId: payment.organizerId, purpose: "formFee",
        currency: payment.currency, amountMinor: payment.amountPaise});
      if (payment.routing.merchantAccountId !== payment.accountId ||
          payment.routing.selection.mode !== payment.mode) {
        throw new HttpsError("internal", "Payment checkout unavailable.");
      }
      if (payment.routing.selection.route === "razorpayRoute" &&
          payment.connectionId === null) {
        checkoutKey = payment.routing.checkoutKey;
      }
    }
    if (payment.connectionId && (!payment.routing ||
        payment.routing.selection.route === "razorpayOAuth")) {
      const connection = requireDoc<Connection>(await db
        .collection("organizerPaymentConnections").doc(payment.connectionId)
        .get(), "OrganizerPaymentConnectionDocument");
      if (connection.status === "ready" && !connection.disconnectedAt &&
          connection.organizerId === payment.organizerId &&
          connection.accountId === payment.accountId &&
          connection.mode === payment.mode && connection.publicToken &&
          connection.webhookVerifiedAt && !connection.lastErrorCode &&
          connection.tokenExpiresAt &&
          connection.tokenExpiresAt.toMillis() > (input.now ?? Date.now()) &&
          (!payment.routing ||
            payment.routing.bindingId === payment.connectionId &&
            payment.routing.checkoutKey === connection.publicToken)) {
        checkoutKey = payment.routing?.checkoutKey ?? connection.publicToken;
      }
    }
    if (checkoutKey) {
      checkout = {publicToken: checkoutKey,
        orderId: payment.providerOrderId, amountPaise: payment.amountPaise,
        currency: "INR", description: payment.description,
        expiresAtMillis: payment.checkoutExpiresAt.toMillis()};
    }
  }
  return {paymentId, status: payment.status, amountPaise: payment.amountPaise,
    currency: "INR", mode: payment.mode, refundPolicy: payment.refundPolicy,
    refundedAmountPaise: payment.refundedAmountPaise, checkout, receipt};
}
