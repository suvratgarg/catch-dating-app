/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Bounded Explore context accepted by getCrossPathsSuggestions. Event ids must come from the caller's current Explore result set; the server revalidates every event.
 */
export interface GetCrossPathsSuggestionsCallablePayload {
  /**
   * @minItems 1
   * @maxItems 12
   */
  eventIds: string[];
  sessionId: string;
}
