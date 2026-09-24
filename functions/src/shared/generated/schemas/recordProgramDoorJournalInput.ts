/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const recordProgramDoorJournalCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/record_program_door_journal_payload.schema.json",
  "title": "RecordProgramDoorJournalCallablePayload",
  "description": "Batch of door actions one function-scoped staff device recorded. The server derives journal ids, so retries and offline outbox replays are idempotent; every operation reports its own outcome.",
  "type": "object",
  "additionalProperties": false,
  "x-callable-aliases": [
    "recordProgramDoorJournal"
  ],
  "required": [
    "programId",
    "functionId",
    "operations"
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
      "maxLength": 180
    },
    "operations": {
      "type": "array",
      "minItems": 1,
      "maxItems": 50,
      "items": {
        "type": "object",
        "additionalProperties": false,
        "required": [
          "guestId",
          "action",
          "occurredAtMillis"
        ],
        "properties": {
          "guestId": {
            "type": "string",
            "minLength": 1,
            "maxLength": 180
          },
          "action": {
            "type": "string",
            "enum": [
              "checkIn",
              "undoCheckIn",
              "markNoShow",
              "walkInCreate",
              "partySizeAdjust"
            ]
          },
          "occurredAtMillis": {
            "type": "integer",
            "minimum": 1,
            "maximum": 9007199254740991
          },
          "deviceId": {
            "type": [
              "string",
              "null"
            ],
            "maxLength": 180
          },
          "partySize": {
            "type": [
              "integer",
              "null"
            ],
            "minimum": 1,
            "maximum": 20,
            "description": "Optional initial party size for walkInCreate; required for partySizeAdjust; must be null or omitted on every other action."
          },
          "note": {
            "type": [
              "string",
              "null"
            ],
            "maxLength": 500
          }
        }
      }
    }
  }
} as const;
