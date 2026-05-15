/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/generate_schema_contracts.mjs

/**
 * Client-owned Firestore create operation for matches/{matchId}/messages/{messageId}.
 */
export interface CreateChatMessageClientWrite {
  path: {
    matchId: string;
    messageId: string;
  };
  data:
    | {
        text?: string;
        [k: string]: unknown;
      }
    | {
        imageUrl: string;
        [k: string]: unknown;
      };
}
