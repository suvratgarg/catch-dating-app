/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Authenticated attendee submission for the end-of-event conversation graph.
 */
export interface SubmitEventSuccessConversationGraphCallablePayload {
  eventId: string;
  /**
   * @maxItems 1000
   */
  selectedUids: string[];
  skipped: boolean;
}
