/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const adminUpsertSalesContactCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/admin_sales_contacts_upsert_payload.schema.json",
  "title": "Sales contacts.upsert callable payload",
  "description": "Private bounded Sales callable request. Server authorization and transaction policy are enforced separately.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "organizerId",
    "requestId",
    "expectedRevision",
    "contact",
    "relationship"
  ],
  "properties": {
    "organizerId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 96,
      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
    },
    "requestId": {
      "type": "string",
      "minLength": 8,
      "maxLength": 96,
      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
    },
    "expectedRevision": {
      "type": "integer",
      "minimum": 0,
      "maximum": 1000000000
    },
    "contactId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 96,
      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
    },
    "linkExisting": {
      "type": "boolean"
    },
    "contact": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "displayName"
      ],
      "properties": {
        "displayName": {
          "type": "string",
          "minLength": 1,
          "maxLength": 160
        }
      }
    },
    "relationship": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "role",
        "decisionInfluence",
        "primary"
      ],
      "properties": {
        "role": {
          "type": "string",
          "minLength": 1,
          "maxLength": 160
        },
        "decisionInfluence": {
          "enum": [
            "unknown",
            "decision_maker",
            "influencer",
            "operator"
          ]
        },
        "primary": {
          "type": "boolean"
        },
        "endpoints": {
          "type": "array",
          "maxItems": 3,
          "items": {
            "type": "object",
            "additionalProperties": false,
            "required": [
              "kind",
              "value",
              "verificationStatus"
            ],
            "properties": {
              "kind": {
                "enum": [
                  "email",
                  "phone"
                ]
              },
              "value": {
                "type": "string",
                "minLength": 3,
                "maxLength": 160
              },
              "verificationStatus": {
                "enum": [
                  "unverified",
                  "verified"
                ]
              },
              "evidenceId": {
                "anyOf": [
                  {
                    "type": "string",
                    "minLength": 1,
                    "maxLength": 96,
                    "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                  },
                  {
                    "type": "null"
                  }
                ]
              }
            }
          }
        }
      }
    }
  }
} as const;
