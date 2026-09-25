/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export interface OrganizerEventSetupPreferences {
  usualDurationMinutes?: number;
  preferredVenueId?: string;
  offerValidityMinutes?: number;
  collectionPreference?:
    | "manualInstructions"
    | "reusablePage"
    | "personalRequest"
    | "catchCheckout";
  currency?: string;
  offerMessageTemplate?: string;
  paymentInstructions?: string;
  reusablePaymentPage?: {
    url: string;
    reusableForEvents: true;
  };
  timezone?: string;
}
