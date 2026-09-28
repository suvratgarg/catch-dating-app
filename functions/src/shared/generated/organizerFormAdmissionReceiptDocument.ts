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
  /**
   * Current native form application approval checked atomically at admission. Absent on legacy receipts.
   */
  applicationApproval?: null | {
    applicationId: string;
    contactId: string;
    revision: number;
    reviewedAtMillis: number;
  };
  /**
   * Frozen server-verified payment authority for automatic admission; absent on manual/free admissions.
   */
  providerPayment?: {
    paymentId: string;
    providerOrderId: string;
    providerPaymentId: string;
    recipientUid: string;
    grantId: string;
    capturedAtMillis: number;
    routing: {
      version: 1;
      amountMinor: number;
      transferAmountMinor: number | null;
      settlementHold: boolean | null;
      purpose: "formFee" | "eventAdmission";
      organizerId: string;
      selection: {
        route:
          | "razorpayRoute"
          | "razorpayOAuth"
          | "stripeConnectDirect"
          | "stripeConnectDestination";
        mode: "test" | "live";
        currency: string;
        merchantCountry: string;
      };
      policySource: "app" | "organizer" | "legacy";
      appRevision: number;
      organizerRevision: number;
      bindingId: string;
      merchantAccountId: string;
      destinationAccountId: string | null;
      configurationVersion: string;
      checkoutKey: string | null;
    };
  };
}
