/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const adminListSalesFitQueueResponseSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callable_responses/admin_sales_fit_queue_list_response.schema.json",
  "title": "AdminListSalesFitQueueResponse",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "rows",
    "nextCursor",
    "generation",
    "policyRevision",
    "qualificationPolicyHash",
    "omittedExpiredInPage"
  ],
  "properties": {
    "rows": {
      "type": "array",
      "maxItems": 25,
      "items": {
        "title": "SalesFitQueueEntryDocument",
        "description": "Private current-fit projection. Only the source-bound, unexpired row may appear in a queue; this is never send authority.",
        "type": "object",
        "additionalProperties": false,
        "x-firestore-collection": "salesFitQueueEntries",
        "x-firestore-path": "salesFitQueueEntries/{organizerId}",
        "x-document-id-field": "organizerId",
        "x-owner": "private Sales fit queue callables and source mutation invalidation hooks",
        "required": [
          "schemaVersion",
          "classification",
          "organizerId",
          "policyId",
          "policyRevision",
          "policyVersion",
          "sourceHash",
          "accountRevision",
          "qualificationPolicyHash",
          "status",
          "score",
          "priority",
          "eligibleForOutreachReview",
          "suppressionStatus",
          "duplicateReviewRequired",
          "researchStatus",
          "name",
          "city",
          "assignedOwnerUid",
          "expiresAt",
          "evaluatedAt",
          "qualificationExpiresAt"
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
          "policyId": {
            "type": "string",
            "minLength": 1,
            "maxLength": 96,
            "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
          },
          "policyRevision": {
            "type": "integer",
            "minimum": 1
          },
          "policyVersion": {
            "type": "string",
            "minLength": 1,
            "maxLength": 96,
            "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
          },
          "sourceHash": {
            "type": "string",
            "pattern": "^[a-f0-9]{64}$"
          },
          "accountRevision": {
            "type": "integer",
            "minimum": 1
          },
          "qualificationPolicyHash": {
            "type": [
              "string",
              "null"
            ],
            "pattern": "^[a-f0-9]{64}$"
          },
          "status": {
            "enum": [
              "complete",
              "needs_research",
              "review_required"
            ]
          },
          "score": {
            "type": [
              "number",
              "null"
            ],
            "minimum": 0,
            "maximum": 100
          },
          "priority": {
            "enum": [
              "high",
              "medium",
              "low",
              "unranked"
            ]
          },
          "eligibleForOutreachReview": {
            "type": "boolean"
          },
          "suppressionStatus": {
            "enum": [
              "clear",
              "held",
              "suppressed"
            ]
          },
          "duplicateReviewRequired": {
            "type": "boolean"
          },
          "researchStatus": {
            "enum": [
              "new",
              "needs_research",
              "ready_for_review",
              "qualified",
              "benchmark_only",
              "no_fit",
              "archived"
            ]
          },
          "name": {
            "type": "string",
            "minLength": 1,
            "maxLength": 160
          },
          "city": {
            "type": [
              "string",
              "null"
            ],
            "maxLength": 160
          },
          "assignedOwnerUid": {
            "type": [
              "string",
              "null"
            ],
            "minLength": 1,
            "maxLength": 96
          },
          "expiresAt": {
            "type": [
              "string",
              "null"
            ],
            "format": "date-time"
          },
          "evaluatedAt": {
            "type": "string",
            "format": "date-time"
          },
          "qualificationExpiresAt": {
            "anyOf": [
              {
                "type": "string",
                "format": "date-time"
              },
              {
                "type": "null"
              }
            ]
          }
        },
        "definitions": {
          "id": {
            "type": "string",
            "minLength": 1,
            "maxLength": 96,
            "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
          }
        }
      }
    },
    "nextCursor": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 600
    },
    "generation": {
      "type": "integer",
      "minimum": 0
    },
    "policyRevision": {
      "type": "integer",
      "minimum": 1
    },
    "qualificationPolicyHash": {
      "type": [
        "string",
        "null"
      ],
      "pattern": "^[a-f0-9]{64}$"
    },
    "omittedExpiredInPage": {
      "type": "integer",
      "minimum": 0,
      "maximum": 100
    }
  },
  "x-callable-aliases": [
    "adminListSalesFitQueue"
  ]
} as const;
