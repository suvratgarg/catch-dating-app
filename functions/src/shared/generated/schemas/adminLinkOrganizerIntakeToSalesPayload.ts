/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const adminLinkOrganizerIntakeToSalesPayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/admin_link_organizer_intake_to_sales_payload.schema.json",
  "title": "AdminLinkOrganizerIntakeToSalesPayload",
  "description": "Links an employee-reviewed Supply Intake canonical organizer decision to its private Sales account; no organizer, publication or ownership mutation.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "workItemId",
    "candidateId",
    "expectedWorkItemRevision",
    "expectedCandidateHash",
    "organizerId",
    "curationPath",
    "requestId"
  ],
  "properties": {
    "workItemId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
    },
    "candidateId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 240
    },
    "expectedWorkItemRevision": {
      "type": "integer",
      "minimum": 0
    },
    "expectedCandidateHash": {
      "type": "string",
      "pattern": "^[a-f0-9]{64}$"
    },
    "organizerId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 96,
      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
    },
    "curationPath": {
      "type": "string",
      "minLength": 34,
      "maxLength": 270,
      "pattern": "^organizerIntakeCurationDecisions/[A-Za-z0-9][A-Za-z0-9._:-]*$"
    },
    "requestId": {
      "type": "string",
      "minLength": 8,
      "maxLength": 96,
      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
    }
  }
} as const;
