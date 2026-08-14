/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Attendee-only end-of-event conversation graph form projection.
 */
export interface GetEventSuccessConversationGraphCallableResponse {
  eventId: string;
  consentMode: "optIn" | "optOut";
  prompt: string;
  /**
   * @maxItems 1000
   */
  candidates: {
    uid: string;
    displayName: string;
    assigned: boolean;
  }[];
  /**
   * @maxItems 1000
   */
  selectedUids: string[];
  submissionStatus: "unsubmitted" | "submitted" | "skipped";
}
