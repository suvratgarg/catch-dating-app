/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export interface EventOfferManualPayment {
  status: "none" | "evidenceSubmitted" | "hostAttestedReceived" | "rejected";
  evidenceReference: string | null;
  evidenceRecordedAtMillis: number | null;
  reviewedByUid: string | null;
  reviewedAtMillis: number | null;
  reviewNote: string | null;
  bankReceiptChecked: boolean;
  attestedAmountMinor: number | null;
  attestedCurrency: string | null;
  attestedEventPaymentRevision: number | null;
  attestedEventPaymentHash: string | null;
}
