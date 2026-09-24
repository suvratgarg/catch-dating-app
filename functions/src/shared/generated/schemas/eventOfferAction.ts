/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const eventOfferActionSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/embedded/event_offer_action.schema.json",
  "title": "EventOfferAction",
  "oneOf": [
    {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "requestId",
        "expectedRevision",
        "kind",
        "terms"
      ],
      "properties": {
        "requestId": {
          "type": "string",
          "minLength": 8,
          "maxLength": 100,
          "pattern": "^[A-Za-z0-9][A-Za-z0-9_-]{7,99}$"
        },
        "expectedRevision": {
          "type": "integer",
          "minimum": 0,
          "maximum": 9007199254740991
        },
        "kind": {
          "const": "createDraft",
          "type": "string"
        },
        "terms": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "expiresAtMillis",
            "organizerPaymentLink"
          ],
          "properties": {
            "expiresAtMillis": {
              "type": "integer",
              "minimum": 1,
              "maximum": 9007199254740991
            },
            "organizerPaymentLink": {
              "anyOf": [
                {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 2048,
                  "format": "uri",
                  "pattern": "^https://"
                },
                {
                  "type": "null"
                }
              ]
            }
          }
        }
      }
    },
    {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "requestId",
        "expectedRevision",
        "kind",
        "expectedGeneration",
        "terms"
      ],
      "properties": {
        "requestId": {
          "type": "string",
          "minLength": 8,
          "maxLength": 100,
          "pattern": "^[A-Za-z0-9][A-Za-z0-9_-]{7,99}$"
        },
        "expectedRevision": {
          "type": "integer",
          "minimum": 0,
          "maximum": 9007199254740991
        },
        "kind": {
          "const": "reissueDraft",
          "type": "string"
        },
        "expectedGeneration": {
          "type": "integer",
          "minimum": 1,
          "maximum": 9007199254740991
        },
        "terms": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "expiresAtMillis",
            "organizerPaymentLink"
          ],
          "properties": {
            "expiresAtMillis": {
              "type": "integer",
              "minimum": 1,
              "maximum": 9007199254740991
            },
            "organizerPaymentLink": {
              "anyOf": [
                {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 2048,
                  "format": "uri",
                  "pattern": "^https://"
                },
                {
                  "type": "null"
                }
              ]
            }
          }
        }
      }
    },
    {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "requestId",
        "expectedRevision",
        "kind",
        "expectedGeneration"
      ],
      "properties": {
        "requestId": {
          "type": "string",
          "minLength": 8,
          "maxLength": 100,
          "pattern": "^[A-Za-z0-9][A-Za-z0-9_-]{7,99}$"
        },
        "expectedRevision": {
          "type": "integer",
          "minimum": 0,
          "maximum": 9007199254740991
        },
        "kind": {
          "const": "offer",
          "type": "string"
        },
        "expectedGeneration": {
          "type": "integer",
          "minimum": 1,
          "maximum": 9007199254740991
        }
      }
    },
    {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "requestId",
        "expectedRevision",
        "kind",
        "expectedGeneration"
      ],
      "properties": {
        "requestId": {
          "type": "string",
          "minLength": 8,
          "maxLength": 100,
          "pattern": "^[A-Za-z0-9][A-Za-z0-9_-]{7,99}$"
        },
        "expectedRevision": {
          "type": "integer",
          "minimum": 0,
          "maximum": 9007199254740991
        },
        "kind": {
          "const": "withdraw",
          "type": "string"
        },
        "expectedGeneration": {
          "type": "integer",
          "minimum": 1,
          "maximum": 9007199254740991
        }
      }
    },
    {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "requestId",
        "expectedRevision",
        "kind",
        "expectedGeneration"
      ],
      "properties": {
        "requestId": {
          "type": "string",
          "minLength": 8,
          "maxLength": 100,
          "pattern": "^[A-Za-z0-9][A-Za-z0-9_-]{7,99}$"
        },
        "expectedRevision": {
          "type": "integer",
          "minimum": 0,
          "maximum": 9007199254740991
        },
        "kind": {
          "const": "expire",
          "type": "string"
        },
        "expectedGeneration": {
          "type": "integer",
          "minimum": 1,
          "maximum": 9007199254740991
        }
      }
    },
    {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "requestId",
        "expectedRevision",
        "kind",
        "expectedGeneration",
        "evidenceReference"
      ],
      "properties": {
        "requestId": {
          "type": "string",
          "minLength": 8,
          "maxLength": 100,
          "pattern": "^[A-Za-z0-9][A-Za-z0-9_-]{7,99}$"
        },
        "expectedRevision": {
          "type": "integer",
          "minimum": 0,
          "maximum": 9007199254740991
        },
        "kind": {
          "const": "recordEvidence",
          "type": "string"
        },
        "expectedGeneration": {
          "type": "integer",
          "minimum": 1,
          "maximum": 9007199254740991
        },
        "evidenceReference": {
          "type": "string",
          "minLength": 3,
          "maxLength": 240
        }
      }
    },
    {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "requestId",
        "expectedRevision",
        "kind",
        "expectedGeneration",
        "decision",
        "reviewNote",
        "bankReceiptChecked"
      ],
      "properties": {
        "requestId": {
          "type": "string",
          "minLength": 8,
          "maxLength": 100,
          "pattern": "^[A-Za-z0-9][A-Za-z0-9_-]{7,99}$"
        },
        "expectedRevision": {
          "type": "integer",
          "minimum": 0,
          "maximum": 9007199254740991
        },
        "kind": {
          "const": "reconcileEvidence",
          "type": "string"
        },
        "expectedGeneration": {
          "type": "integer",
          "minimum": 1,
          "maximum": 9007199254740991
        },
        "decision": {
          "type": "string",
          "enum": [
            "hostAttestedReceived",
            "rejected"
          ]
        },
        "reviewNote": {
          "type": "string",
          "minLength": 3,
          "maxLength": 240
        },
        "bankReceiptChecked": {
          "type": "boolean"
        }
      }
    }
  ]
} as const;
