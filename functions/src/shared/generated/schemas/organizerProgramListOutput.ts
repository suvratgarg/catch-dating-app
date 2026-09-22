/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const organizerProgramListCallableResponseSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callable_responses/organizer_program_list_response.schema.json",
  "title": "OrganizerProgramListCallableResponse",
  "description": "Manager's program inventory: summaries only, no guest or logistics data.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "programs"
  ],
  "properties": {
    "programs": {
      "type": "array",
      "maxItems": 50,
      "items": {
        "type": "object",
        "additionalProperties": false,
        "required": [
          "programId",
          "kind",
          "title",
          "status",
          "startsAtMillis",
          "endsAtMillis",
          "capabilities",
          "revision"
        ],
        "properties": {
          "programId": {
            "type": "string",
            "minLength": 1,
            "maxLength": 180
          },
          "kind": {
            "type": "string",
            "enum": [
              "wedding",
              "corporate",
              "social",
              "other"
            ]
          },
          "title": {
            "type": "string",
            "minLength": 1,
            "maxLength": 140
          },
          "status": {
            "type": "string",
            "enum": [
              "draft",
              "active",
              "completed",
              "archived"
            ]
          },
          "startsAtMillis": {
            "type": "integer",
            "minimum": 0
          },
          "endsAtMillis": {
            "type": "integer",
            "minimum": 0
          },
          "capabilities": {
            "type": "array",
            "items": {
              "type": "string",
              "enum": [
                "arrivalsTransport",
                "accommodation",
                "forms",
                "messaging"
              ]
            }
          },
          "revision": {
            "type": "integer",
            "minimum": 1
          }
        }
      }
    }
  }
} as const;
