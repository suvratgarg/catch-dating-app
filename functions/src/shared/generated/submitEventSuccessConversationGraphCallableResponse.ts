/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Receipt for an attendee conversation graph submission.
 */
export interface SubmitEventSuccessConversationGraphCallableResponse {
  saved: boolean;
  status: "submitted" | "skipped";
  conversationCount: number;
}
