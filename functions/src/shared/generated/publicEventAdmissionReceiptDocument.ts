/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export interface PublicEventAdmissionReceiptDocument {
  organizerId: string;
  eventId: string;
  recipientUid: string;
  attendeeId: string;
  canonicalSeatKey: string;
  identityRevision: number;
  migrationRevision: number;
  registrationRevision: number;
  amountPaise: number;
  currency: "INR";
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
  paymentId: string;
  providerOrderId: string;
  providerPaymentId: string;
  admittedAtMillis: number;
  resultingLedgerRevision: number;
}
