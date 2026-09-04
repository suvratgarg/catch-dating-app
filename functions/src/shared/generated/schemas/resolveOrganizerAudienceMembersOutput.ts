/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const resolveOrganizerAudienceMembersCallableResponseSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callable_responses/resolve_organizer_audience_members_response.schema.json",
  "title": "ResolveOrganizerAudienceMembersCallableResponse",
  "description": "Bounded static selection labels and canonical contact links; unavailable contacts expose no identity.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "members"
  ],
  "properties": {
    "members": {
      "type": "array",
      "maxItems": 2500,
      "items": {
        "type": "object",
        "additionalProperties": false,
        "required": [
          "selectedContactId",
          "contactId",
          "displayName",
          "available"
        ],
        "properties": {
          "selectedContactId": {
            "type": "string",
            "minLength": 1,
            "maxLength": 180
          },
          "contactId": {
            "type": [
              "string",
              "null"
            ],
            "minLength": 1,
            "maxLength": 180
          },
          "displayName": {
            "type": [
              "string",
              "null"
            ],
            "maxLength": 160
          },
          "available": {
            "type": "boolean"
          }
        }
      }
    }
  }
} as const;
