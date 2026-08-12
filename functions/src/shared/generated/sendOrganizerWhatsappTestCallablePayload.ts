/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Sends one manager-authorized template message to verify an organizer-owned WhatsApp sender.
 */
export interface SendOrganizerWhatsappTestCallablePayload {
  organizerId: string;
  connectionId: string;
  templateId: string;
  toE164: string;
  templateVariables: {
    [k: string]: string;
  };
}
