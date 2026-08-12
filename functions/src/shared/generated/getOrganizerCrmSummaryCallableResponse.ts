/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Projected Host CRM counts. No attendee identity or contact field is returned.
 */
export interface GetOrganizerCrmSummaryCallableResponse {
  organizerId: string;
  contactCount: number;
  pastAttendeeCount: number;
  repeatAttendeeCount: number;
  advocateCount: number;
  highImpactAdvocateCount: number;
  linkedAccountCount: number;
  importedContactCount: number;
  whatsappOptInCount: number;
  smsOptInCount: number;
  truncated: boolean;
  readiness: {
    inApp: "currentEventOnly";
    whatsapp: "providerSetupRequired";
    sms: "providerAndDltSetupRequired";
  };
}
