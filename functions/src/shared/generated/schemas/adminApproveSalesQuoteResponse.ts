/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const adminApproveSalesQuoteResponseSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callable_responses/admin_approve_sales_quote_response.schema.json",
  "title": "admin_approve_sales_quote_response response",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "quote",
    "decision",
    "receipt"
  ],
  "properties": {
    "quote": {
      "title": "salesQuotes document",
      "description": "Current quote head; accepted terms do not prove collection.",
      "type": "object",
      "additionalProperties": false,
      "x-firestore-collection": "salesQuotes",
      "x-firestore-path": "salesQuotes/{quoteId}",
      "x-owner": "private Sales commercial service",
      "required": [
        "schemaVersion",
        "classification",
        "organizerId",
        "opportunityId",
        "quoteId",
        "revision",
        "termVersion",
        "status",
        "approvedDecisionId",
        "acceptedDecisionId",
        "updatedAt",
        "updatedBy"
      ],
      "properties": {
        "schemaVersion": {
          "const": 1
        },
        "classification": {
          "const": "sales_private"
        },
        "organizerId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 96,
          "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
        },
        "opportunityId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 96,
          "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
        },
        "quoteId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 96,
          "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
        },
        "revision": {
          "type": "integer",
          "minimum": 1
        },
        "termVersion": {
          "type": "integer",
          "minimum": 1
        },
        "status": {
          "enum": [
            "draft",
            "approved",
            "accepted_reviewed"
          ]
        },
        "approvedDecisionId": {
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
        },
        "acceptedDecisionId": {
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
        },
        "updatedAt": {
          "type": "string",
          "format": "date-time",
          "maxLength": 48
        },
        "updatedBy": {
          "type": "string",
          "minLength": 1,
          "maxLength": 96,
          "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
        }
      },
      "x-document-id-field": "quoteId"
    },
    "decision": {
      "title": "salesCommercialDecisions document",
      "description": "Append-only exact-version approval or reviewed terms acceptance; not a receipt.",
      "type": "object",
      "additionalProperties": false,
      "x-firestore-collection": "salesCommercialDecisions",
      "x-firestore-path": "salesCommercialDecisions/{decisionId}",
      "x-owner": "private Sales commercial service",
      "required": [
        "schemaVersion",
        "classification",
        "decisionId",
        "organizerId",
        "opportunityId",
        "quoteId",
        "termVersion",
        "termsHash",
        "kind",
        "evidence",
        "approvedDecisionId",
        "actorUid",
        "decidedAt",
        "paymentStatus"
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
          "maxLength": 96,
          "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
        },
        "organizerId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 96,
          "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
        },
        "opportunityId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 96,
          "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
        },
        "quoteId": {
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
        },
        "termVersion": {
          "anyOf": [
            {
              "type": "integer",
              "minimum": 1
            },
            {
              "type": "null"
            }
          ]
        },
        "termsHash": {
          "type": "string",
          "pattern": "^[a-f0-9]{64}$"
        },
        "kind": {
          "enum": [
            "quote_approved",
            "terms_acceptance_reviewed"
          ]
        },
        "evidence": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "evidenceId",
            "sourceRef",
            "contentHash",
            "observedAt"
          ],
          "properties": {
            "evidenceId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 96,
              "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
            },
            "sourceRef": {
              "type": "string",
              "minLength": 1,
              "maxLength": 512
            },
            "contentHash": {
              "type": "string",
              "pattern": "^[a-f0-9]{64}$"
            },
            "observedAt": {
              "type": "string",
              "format": "date-time",
              "maxLength": 48
            }
          }
        },
        "approvedDecisionId": {
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
        },
        "actorUid": {
          "type": "string",
          "minLength": 1,
          "maxLength": 96,
          "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
        },
        "decidedAt": {
          "type": "string",
          "format": "date-time",
          "maxLength": 48
        },
        "paymentStatus": {
          "const": "unknown"
        }
      },
      "x-document-id-field": "decisionId"
    },
    "receipt": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "requestId",
        "revision"
      ],
      "properties": {
        "requestId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 96,
          "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
        },
        "revision": {
          "anyOf": [
            {
              "type": "integer",
              "minimum": 1
            },
            {
              "type": "null"
            }
          ]
        }
      }
    }
  }
} as const;
