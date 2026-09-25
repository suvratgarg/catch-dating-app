/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export interface ResolvedEventPreferences {
  defaultsRevision: number;
  defaultsHash: string;
  usualDurationMinutes: {
    value: number | null;
    source: "organizer" | "event" | "cleared";
  };
  preferredVenueId: {
    value: string | null;
    source: "organizer" | "event" | "cleared";
  };
  offerValidityMinutes: {
    value: number | null;
    source: "organizer" | "event" | "cleared";
  };
  collectionPreference: {
    value:
      | (
          | "manualInstructions"
          | "reusablePage"
          | "personalRequest"
          | "catchCheckout"
        )
      | null;
    source: "organizer" | "event" | "cleared";
  };
  currency: {
    value: string | null;
    source: "organizer" | "event" | "cleared";
  };
  offerMessageTemplate: {
    value: string | null;
    source: "organizer" | "event" | "cleared";
  };
  paymentInstructions: {
    value: string | null;
    source: "organizer" | "event" | "cleared";
  };
  reusablePaymentPage: {
    value: {
      url: string;
      reusableForEvents: true;
    } | null;
    source: "organizer" | "event" | "cleared";
  };
  admissionPreset: {
    value:
      | ("openCapacity" | "inviteOnly" | "balancedSingles" | "fixedCohortCaps")
      | null;
    source: "organizer" | "event" | "cleared";
  };
  expectedAmountMinor: {
    value: number | null;
    source: "organizer" | "event" | "cleared";
  };
}
