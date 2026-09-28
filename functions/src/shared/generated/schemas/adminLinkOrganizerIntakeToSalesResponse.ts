/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const adminLinkOrganizerIntakeToSalesResponseSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callable_responses/admin_link_organizer_intake_to_sales_response.schema.json",
  "title": "AdminLinkOrganizerIntakeToSalesResponse",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "link",
    "account",
    "accountCreated"
  ],
  "properties": {
    "link": {
      "title": "SalesIntakeLinkDocument",
      "description": "Immutable private join from exact reviewed Supply Intake candidate and canonical identity decision to the Sales companion account.",
      "type": "object",
      "additionalProperties": false,
      "x-firestore-collection": "salesIntakeLinks",
      "x-firestore-path": "salesIntakeLinks/{linkId}",
      "x-document-id-field": "linkId",
      "x-owner": "adminLinkOrganizerIntakeToSales",
      "required": [
        "schemaVersion",
        "classification",
        "linkId",
        "workItemId",
        "candidateId",
        "sourceRunId",
        "sourceWorkItemRevision",
        "sourceCandidateHash",
        "organizerId",
        "curationPath",
        "curationOperationType",
        "curationReviewedByUid",
        "curationReviewedAt",
        "linkedByUid",
        "linkedAt"
      ],
      "properties": {
        "schemaVersion": {
          "const": 1
        },
        "classification": {
          "const": "sales_private"
        },
        "linkId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 96
        },
        "workItemId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 180
        },
        "candidateId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 240
        },
        "sourceRunId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 180
        },
        "sourceWorkItemRevision": {
          "type": "integer",
          "minimum": 0
        },
        "sourceCandidateHash": {
          "type": "string",
          "pattern": "^[a-f0-9]{64}$"
        },
        "organizerId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 96
        },
        "curationPath": {
          "type": "string",
          "minLength": 34,
          "maxLength": 270
        },
        "curationOperationType": {
          "enum": [
            "create_entity_draft",
            "attach_surface"
          ]
        },
        "curationReviewedByUid": {
          "type": "string",
          "minLength": 1,
          "maxLength": 180
        },
        "curationReviewedAt": {
          "type": "string",
          "format": "date-time",
          "maxLength": 48
        },
        "linkedByUid": {
          "type": "string",
          "minLength": 1,
          "maxLength": 180
        },
        "linkedAt": {
          "type": "string",
          "format": "date-time",
          "maxLength": 48
        }
      }
    },
    "account": {
      "title": "OrganizerSalesAccountDocument",
      "description": "Private organizer-linked Sales companion; no canonical ownership, payment, or publication authority.",
      "type": "object",
      "additionalProperties": false,
      "x-firestore-collection": "organizerSalesAccounts",
      "x-firestore-path": "organizerSalesAccounts/{organizerId}",
      "x-owner": "private Sales account service",
      "required": [
        "schemaVersion",
        "classification",
        "organizerId",
        "revision",
        "researchStatus",
        "assignedOwnerUid",
        "summary",
        "nextAction",
        "suppressionStatus",
        "suppressionReason",
        "suppressionAt",
        "suppressionBy",
        "duplicateReviewRequired",
        "qualificationPolicy",
        "name",
        "city",
        "market",
        "marketLabel",
        "eventTypes",
        "cohortIds",
        "searchTokens",
        "createdAt",
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
          "maxLength": 180,
          "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
        },
        "revision": {
          "type": "integer",
          "minimum": 1,
          "maximum": 1000000000
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
        "assignedOwnerUid": {
          "anyOf": [
            {
              "type": "string",
              "minLength": 1,
              "maxLength": 180
            },
            {
              "type": "null"
            }
          ]
        },
        "summary": {
          "anyOf": [
            {
              "type": "string",
              "minLength": 0,
              "maxLength": 1200
            },
            {
              "type": "null"
            }
          ]
        },
        "nextAction": {
          "anyOf": [
            {
              "type": "string",
              "minLength": 0,
              "maxLength": 320
            },
            {
              "type": "null"
            }
          ]
        },
        "suppressionStatus": {
          "enum": [
            "clear",
            "held",
            "suppressed"
          ]
        },
        "suppressionReason": {
          "anyOf": [
            {
              "type": "string",
              "minLength": 0,
              "maxLength": 2000
            },
            {
              "type": "null"
            }
          ]
        },
        "suppressionAt": {
          "anyOf": [
            {
              "type": "string",
              "format": "date-time",
              "maxLength": 48
            },
            {
              "type": "null"
            }
          ]
        },
        "suppressionBy": {
          "anyOf": [
            {
              "type": "string",
              "minLength": 1,
              "maxLength": 180
            },
            {
              "type": "null"
            }
          ]
        },
        "duplicateReviewRequired": {
          "type": "boolean"
        },
        "qualificationPolicy": {
          "anyOf": [
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "policyId",
                "version",
                "policyHash"
              ],
              "properties": {
                "policyId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 180,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "version": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 180,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "policyHash": {
                  "type": "string",
                  "pattern": "^[a-f0-9]{64}$"
                }
              }
            },
            {
              "type": "null"
            }
          ]
        },
        "name": {
          "type": "string",
          "minLength": 1,
          "maxLength": 160
        },
        "city": {
          "anyOf": [
            {
              "type": "string",
              "minLength": 1,
              "maxLength": 160
            },
            {
              "type": "null"
            }
          ]
        },
        "market": {
          "anyOf": [
            {
              "type": "string",
              "minLength": 1,
              "maxLength": 96
            },
            {
              "type": "null"
            }
          ]
        },
        "marketLabel": {
          "anyOf": [
            {
              "type": "string",
              "minLength": 1,
              "maxLength": 160
            },
            {
              "type": "null"
            }
          ]
        },
        "eventTypes": {
          "type": "array",
          "minItems": 0,
          "maxItems": 30,
          "items": {
            "type": "string",
            "minLength": 1,
            "maxLength": 160
          }
        },
        "cohortIds": {
          "type": "array",
          "minItems": 0,
          "maxItems": 30,
          "items": {
            "type": "string",
            "minLength": 1,
            "maxLength": 180,
            "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
          }
        },
        "searchTokens": {
          "type": "array",
          "minItems": 0,
          "maxItems": 40,
          "items": {
            "type": "string",
            "minLength": 2,
            "maxLength": 96
          }
        },
        "createdAt": {
          "type": "string",
          "format": "date-time",
          "maxLength": 48
        },
        "updatedAt": {
          "type": "string",
          "format": "date-time",
          "maxLength": 48
        },
        "updatedBy": {
          "type": "string",
          "minLength": 1,
          "maxLength": 180
        }
      },
      "x-document-id-field": "organizerId"
    },
    "accountCreated": {
      "type": "boolean"
    }
  }
} as const;
