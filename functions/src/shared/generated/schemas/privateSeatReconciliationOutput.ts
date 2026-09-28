/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const privateSeatReconciliationCallableResponseSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callable_responses/private_seat_reconciliation_response.schema.json",
  "title": "PrivateSeatReconciliationCallableResponse",
  "oneOf": [
    {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "kind",
        "progress"
      ],
      "properties": {
        "kind": {
          "type": "string",
          "const": "progress"
        },
        "progress": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "eventId",
            "migrationRevision",
            "phase",
            "scannedRows",
            "appliedRows",
            "outputRows",
            "occupied"
          ],
          "properties": {
            "eventId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 180
            },
            "migrationRevision": {
              "type": "integer",
              "minimum": 1
            },
            "phase": {
              "type": "string",
              "enum": [
                "scan",
                "plan",
                "apply",
                "cleanup",
                "discard"
              ]
            },
            "scannedRows": {
              "type": "integer",
              "minimum": 0,
              "maximum": 750
            },
            "appliedRows": {
              "type": "integer",
              "minimum": 0,
              "maximum": 1500
            },
            "outputRows": {
              "type": "integer",
              "minimum": 0,
              "maximum": 1500
            },
            "occupied": {
              "type": "null"
            }
          }
        }
      }
    },
    {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "kind",
        "receipt"
      ],
      "properties": {
        "kind": {
          "type": "string",
          "const": "complete"
        },
        "receipt": {
          "title": "PrivateEventSetupMutationCallableResponse",
          "type": "object",
          "additionalProperties": false,
          "required": [
            "eventId",
            "setupRevision",
            "replayed"
          ],
          "properties": {
            "eventId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 180
            },
            "setupRevision": {
              "type": "integer",
              "minimum": 1
            },
            "replayed": {
              "type": "boolean"
            }
          }
        }
      }
    },
    {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "kind",
        "eventId",
        "requestId"
      ],
      "properties": {
        "kind": {
          "type": "string",
          "const": "discarded"
        },
        "eventId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 180
        },
        "requestId": {
          "type": "string",
          "pattern": "^[A-Za-z0-9][A-Za-z0-9_-]{7,127}$"
        }
      }
    }
  ]
} as const;
