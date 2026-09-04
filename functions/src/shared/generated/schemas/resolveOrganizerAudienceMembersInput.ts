/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const resolveOrganizerAudienceMembersCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/resolve_organizer_audience_members_payload.schema.json",
  "title": "ResolveOrganizerAudienceMembersCallablePayload",
  "description": "Resolves the explicitly selected organizer contact ids for a static audience editor.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "organizerId",
    "contactIds"
  ],
  "properties": {
    "organizerId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "contactIds": {
      "type": "array",
      "minItems": 0,
      "maxItems": 2500,
      "uniqueItems": true,
      "items": {
        "type": "string",
        "minLength": 1,
        "maxLength": 180
      }
    }
  }
} as const;
