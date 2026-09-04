/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const fetchSwipeCandidatesCallableResponseSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callable_responses/fetch_swipe_candidates_response.schema.json",
  "title": "FetchSwipeCandidatesCallableResponse",
  "description": "Roster-private post-event candidate response returned by fetchSwipeCandidates. Each profile is the persisted publicProfiles/{uid} document shape with uid injected at the wire boundary. Attendee-roster documents and rejected candidate identities are never returned. Cross Paths Explore consent remains a separate Phase 0 contract.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "profiles"
  ],
  "properties": {
    "profiles": {
      "type": "array",
      "maxItems": 1000,
      "items": {
        "x-wire-shape-extends": "contracts/firestore/public_profiles.schema.json",
        "x-wire-shape-injects": [
          "uid"
        ],
        "type": "object",
        "required": [
          "uid"
        ],
        "properties": {
          "uid": {
            "type": "string",
            "minLength": 1,
            "maxLength": 180
          }
        }
      }
    }
  }
} as const;
