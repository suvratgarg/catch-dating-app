/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export interface EventOfferRow {
  organizerId: string;
  eventId: string;
  contactId: string;
  applicationId: string;
  sourceKind: "application" | "formResponse";
  expiresAtMillis: number;
  organizerPaymentLink: string | null;
}
