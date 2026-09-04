/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const adminCreateOrganizerDraftFromCandidateCallableResponseSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callable_responses/admin_create_organizer_draft_from_candidate_response.schema.json",
  "title": "AdminCreateOrganizerDraftFromCandidateCallableResponse",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "organizerId",
    "organizerPath",
    "curationPath",
    "created",
    "appVisibility",
    "ownershipState",
    "claimState",
    "publishStatus",
    "indexStatus",
    "crawlStatus"
  ],
  "properties": {
    "organizerId": {
      "type": "string",
      "minLength": 3,
      "maxLength": 64
    },
    "organizerPath": {
      "type": "string",
      "pattern": "^organizers/[^/]+$"
    },
    "curationPath": {
      "type": "string",
      "pattern": "^organizerIntakeCurationDecisions/[^/]+$"
    },
    "created": {
      "type": "boolean"
    },
    "appVisibility": {
      "const": "hidden"
    },
    "ownershipState": {
      "const": "programmatic"
    },
    "claimState": {
      "const": "unclaimed"
    },
    "publishStatus": {
      "const": "draft"
    },
    "indexStatus": {
      "const": "noindex"
    },
    "crawlStatus": {
      "const": "disabled"
    }
  }
} as const;
