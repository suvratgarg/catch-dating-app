/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const getCrossPathsSuggestionsCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/get_cross_paths_suggestions_payload.schema.json",
  "title": "GetCrossPathsSuggestionsCallablePayload",
  "description": "Bounded Explore context accepted by getCrossPathsSuggestions. Event ids must come from the caller's current Explore result set; the server revalidates every event.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "eventIds",
    "sessionId"
  ],
  "properties": {
    "eventIds": {
      "type": "array",
      "minItems": 1,
      "maxItems": 12,
      "uniqueItems": true,
      "items": {
        "type": "string",
        "minLength": 1,
        "maxLength": 180
      }
    },
    "sessionId": {
      "type": "string",
      "minLength": 16,
      "maxLength": 128,
      "pattern": "^[A-Za-z0-9._~-]+$"
    }
  }
} as const;
