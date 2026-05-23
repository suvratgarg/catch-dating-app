/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Client-owned Firestore update operation for a participant resetting only their own unread counter on matches/{matchId}.
 */
export interface ResetMatchUnreadCountClientWrite {
  path: {
    matchId: string;
  };
  data: {
    unreadCounts: {
      [k: string]: number;
    };
  };
}
