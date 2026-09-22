/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const programHouseholdDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/program_households.schema.json",
  "title": "ProgramHouseholdDocument",
  "description": "Server-owned household/party grouping for program guests. Carries the invited party's primary contact and delivery preference; member guest ids are bounded.",
  "type": "object",
  "additionalProperties": false,
  "x-firestore-collection": "programHouseholds",
  "x-firestore-path": "programHouseholds/{householdId}",
  "x-document-id-field": "householdId",
  "x-owner": "program guest management callables",
  "required": [
    "programId",
    "organizerId",
    "label",
    "primaryContactName",
    "primaryPhoneE164",
    "primaryEmail",
    "memberGuestIds",
    "deliveryPreference",
    "createdAt",
    "updatedAt",
    "revision"
  ],
  "properties": {
    "programId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "organizerId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "label": {
      "type": "string",
      "minLength": 1,
      "maxLength": 140,
      "description": "Human label such as 'The Sharma family' used on invitations and rosters."
    },
    "primaryContactName": {
      "type": "string",
      "minLength": 1,
      "maxLength": 140
    },
    "primaryPhoneE164": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 20
    },
    "primaryEmail": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 320
    },
    "memberGuestIds": {
      "type": "array",
      "minItems": 1,
      "maxItems": 50,
      "uniqueItems": true,
      "items": {
        "type": "string",
        "minLength": 1,
        "maxLength": 180
      }
    },
    "deliveryPreference": {
      "type": "string",
      "enum": [
        "whatsapp",
        "sms",
        "email",
        "none"
      ],
      "description": "Invitation delivery preference; does not grant messaging consent by itself."
    },
    "createdAt": {
      "type": "object",
      "description": "Serialized Firestore Timestamp fixture shape.",
      "x-firestore-type": "timestamp",
      "additionalProperties": false,
      "required": [
        "_seconds",
        "_nanoseconds"
      ],
      "properties": {
        "_seconds": {
          "type": "integer"
        },
        "_nanoseconds": {
          "type": "integer",
          "minimum": 0,
          "maximum": 999999999
        }
      }
    },
    "updatedAt": {
      "type": "object",
      "description": "Serialized Firestore Timestamp fixture shape.",
      "x-firestore-type": "timestamp",
      "additionalProperties": false,
      "required": [
        "_seconds",
        "_nanoseconds"
      ],
      "properties": {
        "_seconds": {
          "type": "integer"
        },
        "_nanoseconds": {
          "type": "integer",
          "minimum": 0,
          "maximum": 999999999
        }
      }
    },
    "revision": {
      "type": "integer",
      "minimum": 1,
      "maximum": 9007199254740991
    }
  }
} as const;
