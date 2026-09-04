/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const organizerFollowCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/organizer_follow_payload.schema.json",
  "title": "OrganizerFollowCallablePayload",
  "description": "Callable payload accepted by followOrganizer and unfollowOrganizer.",
  "x-callable-aliases": [
    "followOrganizer",
    "unfollowOrganizer"
  ],
  "type": "object",
  "additionalProperties": false,
  "required": [
    "organizerId"
  ],
  "properties": {
    "organizerId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    }
  }
} as const;
