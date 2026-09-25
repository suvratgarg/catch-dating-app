/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export interface EventOfferPaymentSnapshot {
  eventPaymentRevision: number;
  eventPaymentHash: string;
  expectedAmountMinor: number;
  currency: string | null;
  reusablePaymentPageUrl: string | null;
  paymentInstructions: string | null;
  messageTemplate: string | null;
  expiresAtMillis: number;
  collectionMode:
    | (
        | "manualInstructions"
        | "reusablePage"
        | "personalRequest"
        | "catchCheckout"
      )
    | null;
  personalPaymentLink: string | null;
}
