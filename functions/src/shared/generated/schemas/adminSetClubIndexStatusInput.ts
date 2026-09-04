/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const adminSetClubIndexStatusCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/admin_set_club_index_status_payload.schema.json",
  "title": "AdminSetClubIndexStatusCallablePayload",
  "description": "Callable payload accepted by adminSetClubIndexStatus.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "clubId",
    "indexStatus",
    "checklist"
  ],
  "properties": {
    "clubId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "indexStatus": {
      "type": "string",
      "enum": [
        "noindex",
        "indexReady",
        "indexed"
      ]
    },
    "checklist": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "sourceEvidenceVerified",
        "mediaRightsVerified",
        "cadenceVerified",
        "ownerContactVerified"
      ],
      "properties": {
        "sourceEvidenceVerified": {
          "type": "boolean"
        },
        "mediaRightsVerified": {
          "type": "boolean"
        },
        "cadenceVerified": {
          "type": "boolean"
        },
        "ownerContactVerified": {
          "type": "boolean"
        }
      }
    },
    "reviewNote": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 1000
    }
  }
} as const;
