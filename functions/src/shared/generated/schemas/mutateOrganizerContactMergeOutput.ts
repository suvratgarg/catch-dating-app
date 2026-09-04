/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const mutateOrganizerContactMergeCallableResponseSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callable_responses/mutate_organizer_contact_merge_response.schema.json",
  "title": "MutateOrganizerContactMergeCallableResponse",
  "description": "Immutable organizer contact merge or reversal receipt projection.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "receiptId",
    "operation",
    "survivorContactId",
    "sourceContactId",
    "movedEdgeCount",
    "movedIdentityEvidenceCount",
    "movedClaimCount",
    "movedOriginCount",
    "replayed"
  ],
  "properties": {
    "receiptId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "operation": {
      "type": "string",
      "enum": [
        "merge",
        "unmerge"
      ]
    },
    "survivorContactId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "sourceContactId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "movedEdgeCount": {
      "type": "integer",
      "minimum": 0,
      "maximum": 400
    },
    "movedIdentityEvidenceCount": {
      "type": "integer",
      "minimum": 0,
      "maximum": 400
    },
    "movedClaimCount": {
      "type": "integer",
      "minimum": 0,
      "maximum": 400
    },
    "movedOriginCount": {
      "type": "integer",
      "minimum": 0,
      "maximum": 400
    },
    "replayed": {
      "type": "boolean"
    }
  }
} as const;
