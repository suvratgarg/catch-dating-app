/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

import type {EventOfferPaymentSnapshot} from "./eventOfferPaymentSnapshot";
import type {EventOfferManualPayment} from "./eventOfferManualPayment";

export interface OrganizerFormAdmissionReceiptDocument {
  organizerId: string;
  eventId: string;
  responseId: string;
  contactId: string;
  offerId: string;
  expectedOfferRevision: number;
  expectedOfferGeneration: number;
  expectedLedgerRevision: number;
  requestId: string;
  receiptId: string;
  attendeeId: string;
  canonicalSeatKey: string;
  requestHash: string;
  resultingLedgerRevision: number;
  admittedAtMillis: number;
  seatAlreadyOccupied: boolean;
  actorUid: string;
  paymentSnapshot: EventOfferPaymentSnapshot;
  manualPayment: EventOfferManualPayment;
}
