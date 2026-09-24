/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export interface EventPaymentTerms {
  revision: number;
  preferredCollection:
    | (
        | "manualInstructions"
        | "reusablePage"
        | "personalRequest"
        | "catchCheckout"
      )
    | null;
  reusablePaymentPage: {
    url: string;
    reusableForEvents: true;
  } | null;
  paymentInstructions: string | null;
  expectedAmountMinor: number | null;
  currency: string | null;
  offerValidityMinutes: number | null;
  offerMessageTemplate: string | null;
  sourceDefaultsRevision: number;
  sourceDefaultsHash: string;
  fieldSources: {
    preferredCollection: "organizer" | "event" | "cleared";
    reusablePaymentPage: "organizer" | "event" | "cleared";
    paymentInstructions: "organizer" | "event" | "cleared";
    expectedAmountMinor: "organizer" | "event" | "cleared";
    currency: "organizer" | "event" | "cleared";
    offerValidityMinutes: "organizer" | "event" | "cleared";
    offerMessageTemplate: "organizer" | "event" | "cleared";
  };
}
