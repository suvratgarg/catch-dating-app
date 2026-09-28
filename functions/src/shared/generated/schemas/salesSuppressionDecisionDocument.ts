/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const salesSuppressionDecisionDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/sales_suppression_decisions.schema.json",
  "title": "SalesSuppressionDecisionDocument",
  "description": "Append-only human decision. Contact draft review never means send permission.",
  "type": "object",
  "additionalProperties": false,
  "x-firestore-collection": "salesSuppressionDecisions",
  "x-firestore-path": "salesSuppressionDecisions/{decisionId}",
  "x-owner": "private Sales suppression and contactability service",
  "required": [
    "schemaVersion",
    "classification",
    "decisionId",
    "targetType",
    "organizerId",
    "contactId",
    "previousStatus",
    "status",
    "reason",
    "actorUid",
    "recordedAt"
  ],
  "properties": {
    "schemaVersion": {
      "const": 1
    },
    "classification": {
      "const": "sales_private"
    },
    "decisionId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
    },
    "targetType": {
      "enum": [
        "account",
        "contact_relationship"
      ]
    },
    "organizerId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
    },
    "contactId": {
      "anyOf": [
        {
          "type": "string",
          "minLength": 1,
          "maxLength": 180,
          "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
        },
        {
          "type": "null"
        }
      ]
    },
    "previousStatus": {
      "enum": [
        "clear",
        "unknown",
        "draft_reviewed",
        "held",
        "suppressed"
      ]
    },
    "status": {
      "enum": [
        "clear",
        "unknown",
        "draft_reviewed",
        "held",
        "suppressed"
      ]
    },
    "reason": {
      "type": "string",
      "minLength": 1,
      "maxLength": 2000
    },
    "actorUid": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "recordedAt": {
      "type": "string",
      "format": "date-time",
      "maxLength": 48
    },
    "accountRevision": {
      "type": "integer",
      "minimum": 1,
      "maximum": 1000000000
    },
    "relationshipRevision": {
      "type": "integer",
      "minimum": 1,
      "maximum": 1000000000
    },
    "evidenceId": {
      "anyOf": [
        {
          "type": "string",
          "minLength": 1,
          "maxLength": 180,
          "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
        },
        {
          "type": "null"
        }
      ]
    },
    "sendAuthority": {
      "const": false
    }
  },
  "x-document-id-field": "decisionId",
  "allOf": [
    {
      "if": {
        "properties": {
          "targetType": {
            "const": "account"
          }
        }
      },
      "then": {
        "required": [
          "accountRevision"
        ],
        "properties": {
          "contactId": {
            "type": "null"
          }
        },
        "not": {
          "anyOf": [
            {
              "required": [
                "relationshipRevision"
              ]
            },
            {
              "required": [
                "evidenceId"
              ]
            },
            {
              "required": [
                "sendAuthority"
              ]
            }
          ]
        }
      },
      "else": {
        "required": [
          "relationshipRevision",
          "evidenceId",
          "sendAuthority"
        ],
        "properties": {
          "contactId": {
            "type": "string",
            "minLength": 1,
            "maxLength": 180,
            "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
          }
        },
        "not": {
          "required": [
            "accountRevision"
          ]
        }
      }
    }
  ]
} as const;
