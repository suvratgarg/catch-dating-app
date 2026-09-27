/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const createProgramWalkInCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/create_program_walk_in_payload.schema.json",
  "title": "CreateProgramWalkInCallablePayload",
  "description": "Create a minimal programGuests record for a door walk-in and check it in through the durable door journal in one transaction. The derived guest id is deterministic for the clientOperationId, so retries replay idempotently.",
  "type": "object",
  "additionalProperties": false,
  "x-callable-aliases": [
    "createProgramWalkIn"
  ],
  "required": [
    "programId",
    "functionId",
    "displayName",
    "occurredAtMillis",
    "clientOperationId"
  ],
  "properties": {
    "programId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "functionId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "description": "The function the walk-in is checking into. Staff must hold functionCheckIn or functionLead covering this function."
    },
    "displayName": {
      "type": "string",
      "minLength": 1,
      "maxLength": 140
    },
    "occurredAtMillis": {
      "type": "integer",
      "minimum": 1,
      "maximum": 9007199254740991,
      "description": "Device-observed check-in time; joins the journal idempotency key like every other door action."
    },
    "partySize": {
      "type": [
        "integer",
        "null"
      ],
      "minimum": 1,
      "maximum": 20,
      "description": "Attending party size for the walk-in; null reads as 1."
    },
    "note": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 500
    },
    "deviceId": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 180
    },
    "clientOperationId": {
      "type": "string",
      "minLength": 8,
      "maxLength": 120
    }
  }
} as const;
