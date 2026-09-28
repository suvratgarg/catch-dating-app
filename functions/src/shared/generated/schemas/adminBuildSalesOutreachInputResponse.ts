/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const adminBuildSalesOutreachInputResponseSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callable_responses/admin_sales_outreach_input_response.schema.json",
  "title": "AdminBuildSalesOutreachInputResponse",
  "x-callable-aliases": [
    "adminBuildSalesOutreachInput"
  ],
  "type": "object",
  "additionalProperties": false,
  "required": [
    "bundle",
    "sourceHash",
    "sendAuthority"
  ],
  "properties": {
    "bundle": {
      "title": "OutreachDraftingInput",
      "type": "object",
      "additionalProperties": false,
      "required": [
        "schemaVersion",
        "organizer",
        "contact",
        "opportunity",
        "language",
        "channel",
        "purpose",
        "evaluatedAt",
        "policy",
        "observations",
        "capabilities",
        "references",
        "ctas",
        "priorInteraction",
        "evidenceConflictStatus"
      ],
      "properties": {
        "schemaVersion": {
          "const": 1
        },
        "organizer": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "organizerId",
            "name",
            "revision",
            "identityStatus"
          ],
          "properties": {
            "organizerId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 160,
              "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
            },
            "name": {
              "type": "string",
              "minLength": 1,
              "maxLength": 500
            },
            "revision": {
              "type": "integer",
              "minimum": 0
            },
            "identityStatus": {
              "const": "verified"
            }
          }
        },
        "contact": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "contactId",
            "revision",
            "role",
            "eligibility",
            "suppressionStatus",
            "claimStatus"
          ],
          "properties": {
            "contactId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 160,
              "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
            },
            "revision": {
              "type": "integer",
              "minimum": 0
            },
            "role": {
              "type": "string",
              "minLength": 1,
              "maxLength": 500
            },
            "eligibility": {
              "const": "eligible"
            },
            "suppressionStatus": {
              "const": "clear"
            },
            "claimStatus": {
              "enum": [
                "verified",
                "not_required"
              ]
            }
          }
        },
        "opportunity": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "opportunityId",
            "revision",
            "stage",
            "motion"
          ],
          "properties": {
            "opportunityId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 160,
              "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
            },
            "revision": {
              "type": "integer",
              "minimum": 0
            },
            "stage": {
              "type": "string",
              "minLength": 1,
              "maxLength": 160,
              "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
            },
            "motion": {
              "type": "string",
              "minLength": 1,
              "maxLength": 160,
              "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
            }
          }
        },
        "language": {
          "type": "string",
          "enum": [
            "en"
          ]
        },
        "channel": {
          "type": "string",
          "enum": [
            "email",
            "message"
          ]
        },
        "purpose": {
          "type": "string",
          "enum": [
            "first_message",
            "follow_up"
          ]
        },
        "evaluatedAt": {
          "type": "string",
          "format": "date-time"
        },
        "policy": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "promptVersion",
            "playbookVersion",
            "modelId"
          ],
          "properties": {
            "promptVersion": {
              "type": "string",
              "minLength": 1,
              "maxLength": 160,
              "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
            },
            "playbookVersion": {
              "type": "string",
              "minLength": 1,
              "maxLength": 160,
              "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
            },
            "modelId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 160,
              "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
            }
          }
        },
        "observations": {
          "type": "array",
          "maxItems": 12,
          "items": {
            "type": "object",
            "additionalProperties": false,
            "required": [
              "id",
              "text",
              "revision",
              "organizerId",
              "approved",
              "validUntil"
            ],
            "properties": {
              "id": {
                "type": "string",
                "minLength": 1,
                "maxLength": 160,
                "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
              },
              "text": {
                "type": "string",
                "minLength": 1,
                "maxLength": 500
              },
              "revision": {
                "type": "integer",
                "minimum": 0
              },
              "organizerId": {
                "type": "string",
                "minLength": 1,
                "maxLength": 160,
                "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
              },
              "approved": {
                "const": true
              },
              "validUntil": {
                "type": "string",
                "format": "date-time"
              }
            }
          }
        },
        "capabilities": {
          "type": "array",
          "maxItems": 12,
          "items": {
            "type": "object",
            "additionalProperties": false,
            "required": [
              "id",
              "text",
              "revision",
              "organizerId",
              "approved",
              "validUntil"
            ],
            "properties": {
              "id": {
                "type": "string",
                "minLength": 1,
                "maxLength": 160,
                "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
              },
              "text": {
                "type": "string",
                "minLength": 1,
                "maxLength": 500
              },
              "revision": {
                "type": "integer",
                "minimum": 0
              },
              "organizerId": {
                "type": "string",
                "minLength": 1,
                "maxLength": 160,
                "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
              },
              "approved": {
                "const": true
              },
              "validUntil": {
                "type": "string",
                "format": "date-time"
              }
            }
          }
        },
        "references": {
          "type": "array",
          "maxItems": 8,
          "items": {
            "type": "object",
            "additionalProperties": false,
            "required": [
              "id",
              "text",
              "revision",
              "organizerId",
              "approved",
              "validUntil"
            ],
            "properties": {
              "id": {
                "type": "string",
                "minLength": 1,
                "maxLength": 160,
                "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
              },
              "text": {
                "type": "string",
                "minLength": 1,
                "maxLength": 500
              },
              "revision": {
                "type": "integer",
                "minimum": 0
              },
              "organizerId": {
                "type": "string",
                "minLength": 1,
                "maxLength": 160,
                "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
              },
              "approved": {
                "const": true
              },
              "validUntil": {
                "type": "string",
                "format": "date-time"
              }
            }
          }
        },
        "ctas": {
          "type": "array",
          "minItems": 1,
          "maxItems": 8,
          "items": {
            "type": "object",
            "additionalProperties": false,
            "required": [
              "id",
              "text",
              "revision"
            ],
            "properties": {
              "id": {
                "type": "string",
                "minLength": 1,
                "maxLength": 160,
                "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
              },
              "text": {
                "type": "string",
                "minLength": 1,
                "maxLength": 500
              },
              "revision": {
                "type": "integer",
                "minimum": 0
              }
            }
          }
        },
        "priorInteraction": {
          "anyOf": [
            {
              "type": "null"
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "activityId",
                "summary",
                "revision"
              ],
              "properties": {
                "activityId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "summary": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 500
                },
                "revision": {
                  "type": "integer",
                  "minimum": 0
                }
              }
            }
          ]
        },
        "evidenceConflictStatus": {
          "enum": [
            "clear",
            "needs_review"
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
        "text": {
          "type": "string",
          "minLength": 1,
          "maxLength": 500
        },
        "organizer": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "organizerId",
            "name",
            "revision",
            "identityStatus"
          ],
          "properties": {
            "organizerId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 160,
              "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
            },
            "name": {
              "type": "string",
              "minLength": 1,
              "maxLength": 500
            },
            "revision": {
              "type": "integer",
              "minimum": 0
            },
            "identityStatus": {
              "const": "verified"
            }
          }
        },
        "contact": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "contactId",
            "revision",
            "role",
            "eligibility",
            "suppressionStatus",
            "claimStatus"
          ],
          "properties": {
            "contactId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 160,
              "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
            },
            "revision": {
              "type": "integer",
              "minimum": 0
            },
            "role": {
              "type": "string",
              "minLength": 1,
              "maxLength": 500
            },
            "eligibility": {
              "const": "eligible"
            },
            "suppressionStatus": {
              "const": "clear"
            },
            "claimStatus": {
              "enum": [
                "verified",
                "not_required"
              ]
            }
          }
        },
        "opportunity": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "opportunityId",
            "revision",
            "stage",
            "motion"
          ],
          "properties": {
            "opportunityId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 160,
              "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
            },
            "revision": {
              "type": "integer",
              "minimum": 0
            },
            "stage": {
              "type": "string",
              "minLength": 1,
              "maxLength": 160,
              "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
            },
            "motion": {
              "type": "string",
              "minLength": 1,
              "maxLength": 160,
              "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
            }
          }
        },
        "clause": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "id",
            "text",
            "revision",
            "organizerId",
            "approved",
            "validUntil"
          ],
          "properties": {
            "id": {
              "type": "string",
              "minLength": 1,
              "maxLength": 160,
              "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
            },
            "text": {
              "type": "string",
              "minLength": 1,
              "maxLength": 500
            },
            "revision": {
              "type": "integer",
              "minimum": 0
            },
            "organizerId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 160,
              "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
            },
            "approved": {
              "const": true
            },
            "validUntil": {
              "type": "string",
              "format": "date-time"
            }
          }
        }
      }
    },
    "sourceHash": {
      "type": "string",
      "pattern": "^[a-f0-9]{64}$"
    },
    "sendAuthority": {
      "const": false
    }
  }
} as const;
