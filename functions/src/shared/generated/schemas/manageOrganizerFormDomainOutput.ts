/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const manageOrganizerFormDomainCallableResponseSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callable_responses/manage_organizer_form_domain_response.schema.json",
  "title": "ManageOrganizerFormDomainCallableResponse",
  "description": "Manager-visible hostname state without a certificate operation or private form data.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "hostname",
    "status"
  ],
  "properties": {
    "hostname": {
      "type": "string",
      "minLength": 4,
      "maxLength": 253
    },
    "status": {
      "enum": [
        "pending",
        "verified",
        "revoked"
      ]
    },
    "ownershipChallenge": {
      "type": "string",
      "pattern": "^catch-verification=[A-Za-z0-9_-]{32}$"
    },
    "expectedCname": {
      "type": "string",
      "minLength": 4,
      "maxLength": 253
    }
  }
} as const;
