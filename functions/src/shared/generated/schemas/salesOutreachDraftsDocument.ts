/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const salesOutreachDraftsDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/sales_outreach_drafts.schema.json",
  "title": "SalesOutreachDraftDocument",
  "description": "Private Operations-rendered manual-copy-only draft with frozen source request and exact source hash.",
  "type": "object",
  "additionalProperties": false,
  "x-firestore-collection": "salesOutreachDrafts",
  "x-firestore-path": "salesOutreachDrafts/{draftId}",
  "x-document-id-field": "draftId",
  "x-owner": "private Sales intelligence Operations bridge",
  "required": [
    "schemaVersion",
    "classification",
    "draftId",
    "organizerId",
    "contactId",
    "opportunityId",
    "sourceRequest",
    "sourceMaterialHash",
    "sourceHash",
    "inputHash",
    "draft",
    "status",
    "createdAt",
    "createdBy",
    "reviewedAt",
    "reviewedBy"
  ],
  "properties": {
    "schemaVersion": {
      "const": 1
    },
    "classification": {
      "const": "sales_private"
    },
    "draftId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 160,
      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
    },
    "organizerId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 160,
      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
    },
    "contactId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 160,
      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
    },
    "opportunityId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 160,
      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
    },
    "sourceRequest": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "organizerId",
        "contactId",
        "opportunityId",
        "observationIds",
        "capabilityIds",
        "referenceIds",
        "ctaIds",
        "channel",
        "purpose"
      ],
      "properties": {
        "organizerId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 160,
          "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
        },
        "contactId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 160,
          "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
        },
        "opportunityId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 160,
          "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
        },
        "observationIds": {
          "type": "array",
          "maxItems": 12,
          "uniqueItems": true,
          "items": {
            "type": "string",
            "minLength": 1,
            "maxLength": 160,
            "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
          }
        },
        "capabilityIds": {
          "type": "array",
          "maxItems": 12,
          "uniqueItems": true,
          "items": {
            "type": "string",
            "minLength": 1,
            "maxLength": 160,
            "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
          }
        },
        "referenceIds": {
          "type": "array",
          "maxItems": 12,
          "uniqueItems": true,
          "items": {
            "type": "string",
            "minLength": 1,
            "maxLength": 160,
            "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
          }
        },
        "ctaIds": {
          "type": "array",
          "maxItems": 12,
          "uniqueItems": true,
          "items": {
            "type": "string",
            "minLength": 1,
            "maxLength": 160,
            "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
          }
        },
        "channel": {
          "enum": [
            "email",
            "message"
          ]
        },
        "purpose": {
          "enum": [
            "first_message",
            "follow_up"
          ]
        },
        "priorActivityId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 160,
          "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
        }
      }
    },
    "sourceMaterialHash": {
      "type": "string",
      "pattern": "^[a-f0-9]{64}$"
    },
    "sourceHash": {
      "type": "string",
      "pattern": "^[a-f0-9]{64}$"
    },
    "inputHash": {
      "type": "string",
      "pattern": "^[a-f0-9]{64}$"
    },
    "draft": {
      "title": "OutreachDraft",
      "type": "object",
      "additionalProperties": false,
      "required": [
        "schemaVersion",
        "draftId",
        "organizerId",
        "contactId",
        "opportunityId",
        "language",
        "channel",
        "subject",
        "text",
        "sentences",
        "selection",
        "inputHash",
        "contentHash",
        "sourceRevisions",
        "model",
        "reviewStatus",
        "sendAuthority"
      ],
      "properties": {
        "schemaVersion": {
          "const": 1
        },
        "draftId": {
          "type": "string",
          "minLength": 1
        },
        "organizerId": {
          "type": "string",
          "minLength": 1
        },
        "contactId": {
          "type": "string",
          "minLength": 1
        },
        "opportunityId": {
          "type": "string",
          "minLength": 1
        },
        "language": {
          "const": "en"
        },
        "channel": {
          "enum": [
            "email",
            "message"
          ]
        },
        "subject": {
          "type": [
            "string",
            "null"
          ],
          "maxLength": 160
        },
        "text": {
          "type": "string",
          "minLength": 1,
          "maxLength": 4000
        },
        "sentences": {
          "type": "array",
          "minItems": 2,
          "maxItems": 5,
          "items": {
            "type": "object",
            "additionalProperties": false,
            "required": [
              "text",
              "kind",
              "sourceIds"
            ],
            "properties": {
              "text": {
                "type": "string",
                "minLength": 1
              },
              "kind": {
                "enum": [
                  "observation",
                  "capability",
                  "reference",
                  "cta",
                  "prior_interaction"
                ]
              },
              "sourceIds": {
                "type": "array",
                "minItems": 1,
                "maxItems": 1,
                "items": {
                  "type": "string"
                }
              }
            }
          }
        },
        "selection": {
          "title": "OutreachDraftingSelection",
          "type": "object",
          "additionalProperties": false,
          "required": [
            "organizerId",
            "contactId",
            "opportunityId",
            "language",
            "observationId",
            "capabilityId",
            "referenceId",
            "ctaId",
            "reasonToBlock",
            "omittedIds"
          ],
          "properties": {
            "organizerId": {
              "type": "string",
              "minLength": 1
            },
            "contactId": {
              "type": "string",
              "minLength": 1
            },
            "opportunityId": {
              "type": "string",
              "minLength": 1
            },
            "language": {
              "const": "en"
            },
            "observationId": {
              "type": [
                "string",
                "null"
              ]
            },
            "capabilityId": {
              "type": [
                "string",
                "null"
              ]
            },
            "referenceId": {
              "type": [
                "string",
                "null"
              ]
            },
            "ctaId": {
              "type": [
                "string",
                "null"
              ]
            },
            "reasonToBlock": {
              "type": [
                "string",
                "null"
              ],
              "maxLength": 200
            },
            "omittedIds": {
              "type": "array",
              "maxItems": 20,
              "uniqueItems": true,
              "items": {
                "type": "string",
                "minLength": 1,
                "maxLength": 160
              }
            }
          }
        },
        "inputHash": {
          "type": "string",
          "pattern": "^[a-f0-9]{64}$"
        },
        "contentHash": {
          "type": "string",
          "pattern": "^[a-f0-9]{64}$"
        },
        "sourceRevisions": {
          "type": "object",
          "additionalProperties": {
            "type": "integer",
            "minimum": 0
          }
        },
        "model": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "modelId",
            "promptVersion",
            "playbookVersion",
            "cacheHit",
            "usage"
          ],
          "properties": {
            "modelId": {
              "type": "string"
            },
            "promptVersion": {
              "type": "string"
            },
            "playbookVersion": {
              "type": "string"
            },
            "cacheHit": {
              "type": "boolean"
            },
            "usage": {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "inputTokens",
                "outputTokens",
                "costMicros"
              ],
              "properties": {
                "inputTokens": {
                  "type": "integer",
                  "minimum": 0
                },
                "outputTokens": {
                  "type": "integer",
                  "minimum": 0
                },
                "costMicros": {
                  "type": "integer",
                  "minimum": 0
                }
              }
            }
          }
        },
        "reviewStatus": {
          "const": "pending_review"
        },
        "sendAuthority": {
          "const": false
        }
      }
    },
    "status": {
      "enum": [
        "pending_review",
        "approved"
      ]
    },
    "createdAt": {
      "type": "string",
      "format": "date-time"
    },
    "createdBy": {
      "type": "string",
      "minLength": 1,
      "maxLength": 160,
      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
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
          "maxLength": 160,
          "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
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
      "maxLength": 160,
      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
    },
    "hash": {
      "type": "string",
      "pattern": "^[a-f0-9]{64}$"
    },
    "ids": {
      "type": "array",
      "maxItems": 12,
      "uniqueItems": true,
      "items": {
        "type": "string",
        "minLength": 1,
        "maxLength": 160,
        "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
      }
    }
  }
} as const;
