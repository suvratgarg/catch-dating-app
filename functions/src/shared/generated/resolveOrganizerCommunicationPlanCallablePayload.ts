/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Manager-authorized request for one intent-aware organizer communication plan.
 */
export interface ResolveOrganizerCommunicationPlanCallablePayload {
  organizerId: string;
  intent: "individualConversation";
  target: {
    kind: "contact";
    contactId: string;
  };
}
