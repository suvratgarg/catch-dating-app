/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

import {SwipeDocument} from "./swipeDocument";

/**
 * Client-owned Firestore create operation for the current swipes/{userId}/outgoing/{targetId} storage path.
 */
export interface CreateProfileDecisionClientWrite {
  path: {
    userId: string;
    targetId: string;
  };
  data: SwipeDocument;
}
