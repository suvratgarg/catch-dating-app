/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const adminGetSalesIntelligenceCatalogResponseSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callable_responses/admin_sales_intelligence_catalog_response.schema.json",
  "title": "AdminGetSalesIntelligenceCatalogResponse",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "policy",
    "assessments",
    "clauses",
    "evaluatedAt"
  ],
  "properties": {
    "policy": {
      "anyOf": [
        {
          "title": "SalesIntelligencePolicyDocument",
          "description": "Private, owner-reviewed, versioned fit and priority policy. No production weights are checked into source.",
          "type": "object",
          "additionalProperties": false,
          "x-firestore-collection": "salesIntelligencePolicies",
          "x-firestore-path": "salesIntelligencePolicies/{policyRecordId}",
          "x-document-id-field": "policyRecordId",
          "x-owner": "private Sales intelligence policy callable",
          "required": [
            "schemaVersion",
            "classification",
            "policyRecordId",
            "policyId",
            "revision",
            "version",
            "status",
            "factors",
            "priorityBands",
            "promptVersion",
            "playbookVersion",
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
            "policyRecordId": {
              "const": "current"
            },
            "policyId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 96,
              "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
            },
            "revision": {
              "type": "integer",
              "minimum": 1
            },
            "version": {
              "type": "string",
              "minLength": 1,
              "maxLength": 96,
              "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
            },
            "status": {
              "enum": [
                "active",
                "paused"
              ]
            },
            "factors": {
              "type": "array",
              "minItems": 7,
              "maxItems": 7,
              "items": {
                "type": "object",
                "additionalProperties": false,
                "required": [
                  "id",
                  "weight",
                  "claimKeys",
                  "maxAgeDays"
                ],
                "properties": {
                  "id": {
                    "type": "string",
                    "minLength": 1,
                    "maxLength": 96,
                    "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                  },
                  "weight": {
                    "type": "integer",
                    "minimum": 1,
                    "maximum": 100
                  },
                  "claimKeys": {
                    "type": "array",
                    "minItems": 1,
                    "maxItems": 5,
                    "uniqueItems": true,
                    "items": {
                      "enum": [
                        "identity",
                        "recurrence",
                        "operation",
                        "stack",
                        "other"
                      ]
                    }
                  },
                  "maxAgeDays": {
                    "type": "integer",
                    "minimum": 1,
                    "maximum": 365
                  }
                }
              }
            },
            "priorityBands": {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "high",
                "medium"
              ],
              "properties": {
                "high": {
                  "type": "number",
                  "minimum": 0,
                  "maximum": 100
                },
                "medium": {
                  "type": "number",
                  "minimum": 0,
                  "maximum": 100
                }
              }
            },
            "promptVersion": {
              "type": "string",
              "minLength": 1,
              "maxLength": 96,
              "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
            },
            "playbookVersion": {
              "type": "string",
              "minLength": 1,
              "maxLength": 96,
              "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
            },
            "updatedAt": {
              "type": "string",
              "format": "date-time"
            },
            "updatedBy": {
              "type": "string",
              "minLength": 1,
              "maxLength": 96,
              "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
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
        },
        {
          "type": "null"
        }
      ]
    },
    "assessments": {
      "type": "array",
      "maxItems": 7,
      "items": {
        "title": "SalesIntelligenceAssessmentDocument",
        "description": "Employee-reviewed factor rating linked to existing reviewed Sales evidence; unknown and disputed ratings cannot score.",
        "type": "object",
        "additionalProperties": false,
        "x-firestore-collection": "salesIntelligenceAssessments",
        "x-firestore-path": "salesIntelligenceAssessments/{assessmentId}",
        "x-document-id-field": "assessmentId",
        "x-owner": "private Sales intelligence assessment callable",
        "required": [
          "schemaVersion",
          "classification",
          "assessmentId",
          "organizerId",
          "factorId",
          "revision",
          "state",
          "value",
          "evidenceIds",
          "reason",
          "reviewedAt",
          "reviewerUid"
        ],
        "properties": {
          "schemaVersion": {
            "const": 1
          },
          "classification": {
            "const": "sales_private"
          },
          "assessmentId": {
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
          "factorId": {
            "type": "string",
            "minLength": 1,
            "maxLength": 96,
            "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
          },
          "revision": {
            "type": "integer",
            "minimum": 1
          },
          "state": {
            "enum": [
              "known",
              "unknown",
              "disputed"
            ]
          },
          "value": {
            "type": [
              "integer",
              "null"
            ],
            "minimum": 0,
            "maximum": 5
          },
          "evidenceIds": {
            "type": "array",
            "maxItems": 8,
            "uniqueItems": true,
            "items": {
              "type": "string",
              "minLength": 1,
              "maxLength": 96,
              "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
            }
          },
          "reason": {
            "type": [
              "string",
              "null"
            ],
            "maxLength": 240
          },
          "reviewedAt": {
            "type": "string",
            "format": "date-time"
          },
          "reviewerUid": {
            "type": "string",
            "minLength": 1,
            "maxLength": 96,
            "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
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
    "clauses": {
      "type": "array",
      "maxItems": 50,
      "items": {
        "title": "SalesIntelligenceClauseDocument",
        "description": "Private exact prose approved for one organizer. Revoked or expired source and reference permission block future use.",
        "type": "object",
        "additionalProperties": false,
        "x-firestore-collection": "salesIntelligenceClauses",
        "x-firestore-path": "salesIntelligenceClauses/{clauseId}",
        "x-document-id-field": "clauseId",
        "x-owner": "private Sales intelligence clause callable",
        "required": [
          "schemaVersion",
          "classification",
          "clauseId",
          "organizerId",
          "revision",
          "kind",
          "text",
          "state",
          "evidenceIds",
          "validUntil",
          "permission",
          "reviewedAt",
          "reviewedBy",
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
          "clauseId": {
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
          "revision": {
            "type": "integer",
            "minimum": 1
          },
          "kind": {
            "enum": [
              "observation",
              "capability",
              "reference",
              "cta"
            ]
          },
          "text": {
            "type": "string",
            "minLength": 1,
            "maxLength": 500
          },
          "state": {
            "enum": [
              "draft",
              "approved",
              "withdrawn"
            ]
          },
          "evidenceIds": {
            "type": "array",
            "maxItems": 8,
            "uniqueItems": true,
            "items": {
              "type": "string",
              "minLength": 1,
              "maxLength": 96,
              "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
            }
          },
          "validUntil": {
            "type": "string",
            "format": "date-time"
          },
          "permission": {
            "enum": [
              "not_required",
              "private_mention",
              "withdrawn"
            ]
          },
          "reviewedAt": {
            "type": [
              "string",
              "null"
            ],
            "format": "date-time"
          },
          "reviewedBy": {
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
            "format": "date-time"
          },
          "updatedBy": {
            "type": "string",
            "minLength": 1,
            "maxLength": 96,
            "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
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
    "evaluatedAt": {
      "type": "string",
      "format": "date-time"
    }
  },
  "x-callable-aliases": [
    "adminGetSalesIntelligenceCatalog"
  ]
} as const;
