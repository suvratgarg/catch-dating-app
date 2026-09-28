/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const reconcilePrivateEventSeatsCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/reconcile_private_event_seats_payload.schema.json",
  "title": "ReconcilePrivateEventSeatsCallablePayload",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "organizerId",
    "eventId",
    "requestId",
    "expectedSetupRevision",
    "reviewedDefaultsHash",
    "details"
  ],
  "properties": {
    "organizerId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "eventId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "requestId": {
      "type": "string",
      "pattern": "^[A-Za-z0-9][A-Za-z0-9_-]{7,127}$"
    },
    "expectedSetupRevision": {
      "type": "integer",
      "minimum": 1,
      "maximum": 999999999
    },
    "reviewedDefaultsHash": {
      "type": "string",
      "pattern": "^[a-f0-9]{64}$"
    },
    "details": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "admissionTerms"
      ],
      "properties": {
        "admissionTerms": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "capacityLimit",
            "priceInPaise",
            "currency",
            "cancellationPolicyId"
          ],
          "properties": {
            "capacityLimit": {
              "type": "integer",
              "minimum": 1,
              "maximum": 1000
            },
            "priceInPaise": {
              "type": "integer",
              "minimum": 0,
              "maximum": 100000000
            },
            "currency": {
              "type": "string",
              "pattern": "^[A-Z]{3}$"
            },
            "cancellationPolicyId": {
              "type": "string",
              "enum": [
                "notApplicable",
                "flexible",
                "standard",
                "strict"
              ]
            }
          }
        }
      }
    },
    "discard": {
      "type": "boolean"
    }
  }
} as const;
