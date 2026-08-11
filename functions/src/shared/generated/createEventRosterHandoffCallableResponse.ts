/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Provider-aware forwarding instructions for one event roster.
 */
export interface CreateEventRosterHandoffCallableResponse {
  eventId: string;
  expiresAtMillis: number;
  emailStatus: "available" | "providerSetupRequired";
  emailAlias: string | null;
  whatsappStatus: "available" | "providerSetupRequired";
  whatsappNumber: string | null;
  whatsappMessage: string | null;
}
