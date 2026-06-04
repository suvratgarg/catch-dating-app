/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Callable payload accepted by createEventWaitlistOffers.
 */
export interface CreateEventWaitlistOffersCallablePayload {
  eventId: string;
  /**
   * @minItems 1
   * @maxItems 25
   */
  userIds: string[];
  expiresInMinutes?: number | null;
}
