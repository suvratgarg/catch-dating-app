import {HttpsError} from "firebase-functions/v2/https";
import type {OrganizerEventOfferPaymentDocument as Payment} from
  "../../shared/generated/firestoreAdminTypes";
import {validateOrganizerFormAdmissionReceiptDocument} from
  "../../shared/generated/validators/organizerFormAdmissionReceiptDocument";
import {validateOrganizerFormAdmissionDocument} from
  "../../shared/generated/validators/organizerFormAdmissionDocument";
import {canonicalJson} from "../../events/eventSetupPreferences/resolve";
import {formAdmissionReceiptId} from
  "../../organizerFormAdmission/admissionService";
import {admissionRequestHash} from
  "../../organizerFormAdmission/admissionPolicy";

/** Historical financial proof. Does not grant current roster/seat authority. */
export function assertPaidOfferAdmission(input: {
  payment: Payment; paymentId: string; receipt: unknown; ownership: unknown;
}) {
  const {payment, paymentId, receipt, ownership} = input;
  const {organizerId, eventId, responseId, recipientUid: uid} = payment;
  const requestId = `paid_${paymentId}`;
  const receiptId = formAdmissionReceiptId(organizerId, requestId);
  if (!validateOrganizerFormAdmissionReceiptDocument(receipt) ||
      !validateOrganizerFormAdmissionDocument(ownership) ||
      payment.admissionReceiptId !== receiptId ||
      receipt.receiptId !== receiptId ||
      receipt.requestId !== requestId ||
      receipt.requestHash !== admissionRequestHash(receipt) ||
      canonicalJson(receipt.paymentSnapshot) !==
        canonicalJson(payment.paymentSnapshot) ||
      receipt.providerPayment?.paymentId !== paymentId ||
      receipt.providerPayment.providerPaymentId !==
        payment.providerPaymentId ||
      receipt.providerPayment.providerOrderId !==
        payment.providerOrderId ||
      receipt.providerPayment.grantId !== payment.grantId ||
      receipt.providerPayment.recipientUid !== uid ||
      canonicalJson(receipt.providerPayment.routing) !==
        canonicalJson(payment.routing) ||
      receipt.organizerId !== organizerId ||
      receipt.eventId !== eventId ||
      receipt.responseId !== responseId ||
      receipt.contactId !== payment.contactId ||
      receipt.offerId !== payment.offerId ||
      receipt.expectedOfferRevision !== payment.offerRevision ||
      receipt.expectedOfferGeneration !== payment.offerGeneration ||
      receipt.canonicalSeatKey !== payment.canonicalSeatKey ||
      receipt.actorUid !== uid ||
      ownership.organizerId !== organizerId ||
      ownership.eventId !== eventId ||
      ownership.responseId !== responseId ||
      ownership.offerId !== payment.offerId ||
      ownership.offerRevision !== payment.offerRevision ||
      ownership.offerGeneration !== payment.offerGeneration ||
      ownership.receiptId !== receiptId ||
      ownership.attendeeId !== receipt.attendeeId ||
      ownership.canonicalSeatKey !== payment.canonicalSeatKey) {
    throw new HttpsError("failed-precondition",
      "Paid admission proof is unavailable.");
  }
  return {receipt, ownership};
}
