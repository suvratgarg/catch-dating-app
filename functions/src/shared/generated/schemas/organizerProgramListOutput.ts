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
          "timezone",
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
          "timezone": {
            "type": "string",
            "minLength": 1,
            "maxLength": 60,
            "description": "IANA timezone used to recover the Program's civil calendar dates from its stored instants."
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
          "functionCount": {
            "type": "integer",
            "minimum": 0,
            "description": "Exact count of constituent program events for a completely read authorized batch. Omitted when unavailable or the bounded batch is incomplete; absence never means zero."
          },
          "revision": {
            "type": "integer",
            "minimum": 1
          },
          "archivedAtMillis": {
            "type": [
              "integer",
              "null"
            ],
            "minimum": 0,
            "description": "Set when the program is archived; null otherwise."
          },
          "anonymizeAtMillis": {
            "type": [
              "integer",
              "null"
            ],
            "minimum": 0,
            "description": "Grace deadline after which identity fields are scrubbed."
          },
          "anonymizedAtMillis": {
            "type": [
              "integer",
              "null"
            ],
            "minimum": 0,
            "description": "Set once identity/free-text fields were scrubbed."
          }
        }
      }
    },
    "nextCursor": {
      "type": [
        "string",
        "null"
      ],
      "minLength": 1,
      "maxLength": 512,
      "description": "Opaque stable cursor for the last returned startsAt/program-ID tuple when another page exists, otherwise null. Optional for legacy readers."
    }
  }
} as const;
