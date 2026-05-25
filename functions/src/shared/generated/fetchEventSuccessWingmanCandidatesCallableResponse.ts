/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Callable response returned by fetchEventSuccessWingmanCandidates. Each profile is the persisted publicProfiles/{uid} document shape with `uid` injected at the wire boundary so clients can identify the profile owner. Per-field shape is enforced by PublicProfileDocument (contracts/firestore/public_profiles.schema.json) when the Dart side parses each entry.
 */
export interface FetchEventSuccessWingmanCandidatesCallableResponse {
  profiles: {
    uid: string;
    [k: string]: unknown;
  }[];
}
