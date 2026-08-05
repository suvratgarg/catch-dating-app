/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Roster-private post-event candidate response returned by fetchSwipeCandidates. Each profile is the persisted publicProfiles/{uid} document shape with uid injected at the wire boundary. Attendee-roster documents and rejected candidate identities are never returned. Cross Paths Explore consent remains a separate Phase 0 contract.
 */
export interface FetchSwipeCandidatesCallableResponse {
  /**
   * @maxItems 1000
   */
  profiles: {
    uid: string;
    [k: string]: unknown;
  }[];
}
