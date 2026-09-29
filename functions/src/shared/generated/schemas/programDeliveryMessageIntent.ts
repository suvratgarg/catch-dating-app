/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const programDeliveryMessageIntentSchema: Record<string, unknown> = {
  "type": "object",
  "additionalProperties": false,
  "required": [
    "schemaVersion",
    "intentId",
    "revision",
    "context",
    "programId",
    "recipient",
    "workflow",
    "createdAt",
    "expiresAt",
    "permittedRoutes",
    "deliveryPolicy",
    "kind",
    "title",
    "body",
    "instructionRevision"
  ],
  "properties": {
    "schemaVersion": {
      "const": 1,
      "type": "integer"
    },
    "intentId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 160,
      "pattern": "^[a-zA-Z0-9][a-zA-Z0-9._:-]*$"
    },
    "revision": {
      "type": "integer",
      "minimum": 1,
      "maximum": 1000000
    },
    "context": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "mode",
        "programId",
        "organizerId"
      ],
      "properties": {
        "mode": {
          "type": "string",
          "const": "live"
        },
        "programId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 160,
          "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
        },
        "organizerId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 2000
        }
      }
    },
    "programId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 160,
      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
    },
    "recipient": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "kind",
        "recipientKey"
      ],
      "properties": {
        "kind": {
          "type": "string",
          "enum": [
            "guest",
            "household",
            "staff"
          ]
        },
        "recipientKey": {
          "type": "string",
          "minLength": 1,
          "maxLength": 2000,
          "description": "Stable recipient identity inside the program (guest id, household id, or staff uid). Endpoint resolution lives in the facts reader, never in the intent."
        }
      }
    },
    "workflow": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "kind",
        "momentId",
        "runId"
      ],
      "properties": {
        "kind": {
          "type": "string",
          "const": "programMoment"
        },
        "momentId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 160,
          "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
        },
        "runId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 2000,
          "description": "Moment-run occurrence identity. Phase 3 refines this into an explicit occurrence key once anchor revisions exist."
        }
      }
    },
    "createdAt": {
      "type": "integer",
      "minimum": 0,
      "maximum": 9007199254740991
    },
    "expiresAt": {
      "type": "integer",
      "minimum": 0,
      "maximum": 9007199254740991
    },
    "permittedRoutes": {
      "type": "array",
      "minItems": 1,
      "maxItems": 3,
      "items": {
        "type": "string",
        "enum": [
          "organizerProgramWhatsapp",
          "catchProgramActivity"
        ]
      }
    },
    "deliveryPolicy": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "maxAttempts",
        "maxAttemptsPerRoute",
        "minimumRetrySeconds"
      ],
      "properties": {
        "maxAttempts": {
          "type": "integer",
          "minimum": 1,
          "maximum": 6
        },
        "maxAttemptsPerRoute": {
          "type": "integer",
          "minimum": 1,
          "maximum": 6
        },
        "minimumRetrySeconds": {
          "type": "integer",
          "minimum": 0,
          "maximum": 86400
        }
      }
    },
    "kind": {
      "type": "string",
      "const": "programReminder"
    },
    "title": {
      "type": "string",
      "minLength": 1,
      "maxLength": 2000
    },
    "body": {
      "type": "string",
      "minLength": 1,
      "maxLength": 8000
    },
    "instructionRevision": {
      "type": "integer",
      "minimum": 0,
      "maximum": 9007199254740991,
      "description": "The program/moment fact revision this intent was issued under. Reservation authority expires with it."
    }
  },
  "title": "ProgramDeliveryMessageIntent"
} as const;
