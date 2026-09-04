/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const fetchEventSuccessWingmanCandidatesCallableResponseSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callable_responses/fetch_event_success_wingman_candidates_response.schema.json",
  "title": "FetchEventSuccessWingmanCandidatesCallableResponse",
  "description": "Callable response returned by fetchEventSuccessWingmanCandidates. Each profile is the persisted publicProfiles/{uid} document shape with `uid` injected at the wire boundary so clients can identify the profile owner. Per-field shape is enforced by PublicProfileDocument (contracts/firestore/public_profiles.schema.json) when the Dart side parses each entry.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "profiles"
  ],
  "properties": {
    "profiles": {
      "type": "array",
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
    },
    "candidates": {
      "description": "Runtime-safe candidate cards for no-download attendees. Existing app clients may continue using profiles.",
      "type": "array",
      "maxItems": 1000,
      "items": {
        "type": "object",
        "additionalProperties": false,
        "required": [
          "uid",
          "displayName",
          "gender",
          "source"
        ],
        "properties": {
          "uid": {
            "type": "string",
            "minLength": 1,
            "maxLength": 180
          },
          "displayName": {
            "type": "string",
            "minLength": 1,
            "maxLength": 120
          },
          "gender": {
            "type": [
              "string",
              "null"
            ],
            "enum": [
              "man",
              "woman",
              "nonBinary",
              "other",
              null
            ]
          },
          "source": {
            "type": "string",
            "enum": [
              "catchParticipation",
              "externalRuntime"
            ]
          }
        }
      }
    }
  }
} as const;
