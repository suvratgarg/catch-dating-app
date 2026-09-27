/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const salesDemoManagementCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/sales_demo_management.schema.json",
  "title": "SalesDemoManagementCallablePayloads",
  "description": "Admin Owner demo commands and bounded owner reads. A request ID is stable across retries; reads never return grant digests.",
  "anyOf": [
    {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "requestId",
        "blueprintId",
        "expectedRevision",
        "evidenceRevision",
        "preview",
        "formCapabilityReview",
        "fieldMappings"
      ],
      "properties": {
        "requestId": {
          "type": "string",
          "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]{7,95}$"
        },
        "blueprintId": {
          "type": "string",
          "pattern": "^[A-Za-z0-9_-]{3,128}$"
        },
        "expectedRevision": {
          "type": "integer",
          "minimum": 0
        },
        "organizerId": {
          "anyOf": [
            {
              "type": "string",
              "pattern": "^[A-Za-z0-9_-]{3,128}$"
            },
            {
              "type": "null"
            }
          ]
        },
        "candidateId": {
          "anyOf": [
            {
              "type": "string",
              "pattern": "^[A-Za-z0-9_-]{3,128}$"
            },
            {
              "type": "null"
            }
          ]
        },
        "opportunityId": {
          "anyOf": [
            {
              "type": "string",
              "pattern": "^[A-Za-z0-9_-]{3,128}$"
            },
            {
              "type": "null"
            }
          ]
        },
        "evidenceRevision": {
          "type": "string",
          "pattern": "^[A-Za-z0-9_-]{3,128}$"
        },
        "preview": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "brandName",
            "headline",
            "scenario",
            "steps",
            "retainedTools",
            "limitations",
            "cta"
          ],
          "properties": {
            "brandName": {
              "type": "string",
              "minLength": 1,
              "maxLength": 160
            },
            "headline": {
              "type": "string",
              "minLength": 1,
              "maxLength": 160
            },
            "scenario": {
              "type": "string",
              "minLength": 1,
              "maxLength": 160
            },
            "steps": {
              "type": "array",
              "minItems": 3,
              "maxItems": 3,
              "items": {
                "type": "string",
                "minLength": 1,
                "maxLength": 160
              }
            },
            "retainedTools": {
              "type": "array",
              "maxItems": 8,
              "items": {
                "type": "string",
                "minLength": 1,
                "maxLength": 160
              }
            },
            "limitations": {
              "type": "array",
              "minItems": 1,
              "maxItems": 8,
              "items": {
                "type": "string",
                "minLength": 1,
                "maxLength": 160
              }
            },
            "cta": {
              "type": "string",
              "minLength": 1,
              "maxLength": 160
            }
          }
        },
        "formCapabilityReview": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "questionTypes",
            "branching",
            "requiredFields",
            "scoringApproval",
            "uploads"
          ],
          "properties": {
            "questionTypes": {
              "enum": [
                "exact",
                "manual",
                "retained",
                "unsupported"
              ]
            },
            "branching": {
              "enum": [
                "exact",
                "manual",
                "retained",
                "unsupported"
              ]
            },
            "requiredFields": {
              "enum": [
                "exact",
                "manual",
                "retained",
                "unsupported"
              ]
            },
            "scoringApproval": {
              "enum": [
                "exact",
                "manual",
                "retained",
                "unsupported"
              ]
            },
            "uploads": {
              "enum": [
                "exact",
                "manual",
                "retained",
                "unsupported"
              ]
            }
          }
        },
        "fieldMappings": {
          "type": "array",
          "maxItems": 30,
          "items": {
            "type": "object",
            "additionalProperties": false,
            "required": [
              "sourceField",
              "catchField",
              "disposition"
            ],
            "properties": {
              "sourceField": {
                "type": "string",
                "minLength": 1,
                "maxLength": 160
              },
              "catchField": {
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
              "disposition": {
                "enum": [
                  "exact",
                  "manual",
                  "retained",
                  "unsupported"
                ]
              }
            }
          }
        }
      }
    },
    {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "requestId",
        "blueprintId",
        "expectedRevision"
      ],
      "properties": {
        "requestId": {
          "type": "string",
          "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]{7,95}$"
        },
        "blueprintId": {
          "type": "string",
          "pattern": "^[A-Za-z0-9_-]{3,128}$"
        },
        "expectedRevision": {
          "type": "integer",
          "minimum": 1
        }
      }
    },
    {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "requestId",
        "blueprintId",
        "blueprintRevision",
        "expiresAt",
        "sessionCap"
      ],
      "properties": {
        "requestId": {
          "type": "string",
          "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]{7,95}$"
        },
        "blueprintId": {
          "type": "string",
          "pattern": "^[A-Za-z0-9_-]{3,128}$"
        },
        "blueprintRevision": {
          "type": "integer",
          "minimum": 1
        },
        "contactBinding": {
          "anyOf": [
            {
              "type": "null"
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "value"
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
                  "maxLength": 254
                }
              }
            }
          ]
        },
        "expiresAt": {
          "type": "string",
          "format": "date-time"
        },
        "sessionCap": {
          "type": "integer",
          "minimum": 1,
          "maximum": 3
        }
      }
    },
    {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "requestId",
        "invitationId",
        "expectedRevision"
      ],
      "properties": {
        "requestId": {
          "type": "string",
          "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]{7,95}$"
        },
        "invitationId": {
          "type": "string",
          "pattern": "^[A-Za-z0-9_-]{3,128}$"
        },
        "expectedRevision": {
          "type": "integer",
          "minimum": 1
        }
      }
    },
    {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "blueprintId"
      ],
      "properties": {
        "blueprintId": {
          "type": "string",
          "pattern": "^[A-Za-z0-9_-]{3,128}$"
        }
      }
    },
    {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "invitationId"
      ],
      "properties": {
        "invitationId": {
          "type": "string",
          "pattern": "^[A-Za-z0-9_-]{3,128}$"
        }
      }
    },
    {
      "type": "object",
      "additionalProperties": false,
      "maxProperties": 0
    },
    {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "organizerId"
      ],
      "properties": {
        "organizerId": {
          "type": "string",
          "pattern": "^[A-Za-z0-9_-]{3,128}$"
        },
        "cursor": {
          "type": "string",
          "pattern": "^[A-Za-z0-9_-]{3,128}$"
        },
        "limit": {
          "type": "integer",
          "minimum": 1,
          "maximum": 20
        }
      }
    },
    {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "blueprintId"
      ],
      "properties": {
        "blueprintId": {
          "type": "string",
          "pattern": "^[A-Za-z0-9_-]{3,128}$"
        },
        "cursor": {
          "type": "string",
          "pattern": "^[A-Za-z0-9_-]{3,128}$"
        },
        "limit": {
          "type": "integer",
          "minimum": 1,
          "maximum": 20
        }
      }
    }
  ],
  "definitions": {
    "id": {
      "type": "string",
      "pattern": "^[A-Za-z0-9_-]{3,128}$"
    },
    "requestId": {
      "type": "string",
      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]{7,95}$"
    },
    "save": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "requestId",
        "blueprintId",
        "expectedRevision",
        "evidenceRevision",
        "preview",
        "formCapabilityReview",
        "fieldMappings"
      ],
      "properties": {
        "requestId": {
          "type": "string",
          "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]{7,95}$"
        },
        "blueprintId": {
          "type": "string",
          "pattern": "^[A-Za-z0-9_-]{3,128}$"
        },
        "expectedRevision": {
          "type": "integer",
          "minimum": 0
        },
        "organizerId": {
          "anyOf": [
            {
              "type": "string",
              "pattern": "^[A-Za-z0-9_-]{3,128}$"
            },
            {
              "type": "null"
            }
          ]
        },
        "candidateId": {
          "anyOf": [
            {
              "type": "string",
              "pattern": "^[A-Za-z0-9_-]{3,128}$"
            },
            {
              "type": "null"
            }
          ]
        },
        "opportunityId": {
          "anyOf": [
            {
              "type": "string",
              "pattern": "^[A-Za-z0-9_-]{3,128}$"
            },
            {
              "type": "null"
            }
          ]
        },
        "evidenceRevision": {
          "type": "string",
          "pattern": "^[A-Za-z0-9_-]{3,128}$"
        },
        "preview": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "brandName",
            "headline",
            "scenario",
            "steps",
            "retainedTools",
            "limitations",
            "cta"
          ],
          "properties": {
            "brandName": {
              "type": "string",
              "minLength": 1,
              "maxLength": 160
            },
            "headline": {
              "type": "string",
              "minLength": 1,
              "maxLength": 160
            },
            "scenario": {
              "type": "string",
              "minLength": 1,
              "maxLength": 160
            },
            "steps": {
              "type": "array",
              "minItems": 3,
              "maxItems": 3,
              "items": {
                "type": "string",
                "minLength": 1,
                "maxLength": 160
              }
            },
            "retainedTools": {
              "type": "array",
              "maxItems": 8,
              "items": {
                "type": "string",
                "minLength": 1,
                "maxLength": 160
              }
            },
            "limitations": {
              "type": "array",
              "minItems": 1,
              "maxItems": 8,
              "items": {
                "type": "string",
                "minLength": 1,
                "maxLength": 160
              }
            },
            "cta": {
              "type": "string",
              "minLength": 1,
              "maxLength": 160
            }
          }
        },
        "formCapabilityReview": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "questionTypes",
            "branching",
            "requiredFields",
            "scoringApproval",
            "uploads"
          ],
          "properties": {
            "questionTypes": {
              "enum": [
                "exact",
                "manual",
                "retained",
                "unsupported"
              ]
            },
            "branching": {
              "enum": [
                "exact",
                "manual",
                "retained",
                "unsupported"
              ]
            },
            "requiredFields": {
              "enum": [
                "exact",
                "manual",
                "retained",
                "unsupported"
              ]
            },
            "scoringApproval": {
              "enum": [
                "exact",
                "manual",
                "retained",
                "unsupported"
              ]
            },
            "uploads": {
              "enum": [
                "exact",
                "manual",
                "retained",
                "unsupported"
              ]
            }
          }
        },
        "fieldMappings": {
          "type": "array",
          "maxItems": 30,
          "items": {
            "type": "object",
            "additionalProperties": false,
            "required": [
              "sourceField",
              "catchField",
              "disposition"
            ],
            "properties": {
              "sourceField": {
                "type": "string",
                "minLength": 1,
                "maxLength": 160
              },
              "catchField": {
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
              "disposition": {
                "enum": [
                  "exact",
                  "manual",
                  "retained",
                  "unsupported"
                ]
              }
            }
          }
        }
      }
    },
    "blueprintDecision": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "requestId",
        "blueprintId",
        "expectedRevision"
      ],
      "properties": {
        "requestId": {
          "type": "string",
          "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]{7,95}$"
        },
        "blueprintId": {
          "type": "string",
          "pattern": "^[A-Za-z0-9_-]{3,128}$"
        },
        "expectedRevision": {
          "type": "integer",
          "minimum": 1
        }
      }
    },
    "issue": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "requestId",
        "blueprintId",
        "blueprintRevision",
        "expiresAt",
        "sessionCap"
      ],
      "properties": {
        "requestId": {
          "type": "string",
          "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]{7,95}$"
        },
        "blueprintId": {
          "type": "string",
          "pattern": "^[A-Za-z0-9_-]{3,128}$"
        },
        "blueprintRevision": {
          "type": "integer",
          "minimum": 1
        },
        "contactBinding": {
          "anyOf": [
            {
              "type": "null"
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "value"
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
                  "maxLength": 254
                }
              }
            }
          ]
        },
        "expiresAt": {
          "type": "string",
          "format": "date-time"
        },
        "sessionCap": {
          "type": "integer",
          "minimum": 1,
          "maximum": 3
        }
      }
    },
    "revoke": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "requestId",
        "invitationId",
        "expectedRevision"
      ],
      "properties": {
        "requestId": {
          "type": "string",
          "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]{7,95}$"
        },
        "invitationId": {
          "type": "string",
          "pattern": "^[A-Za-z0-9_-]{3,128}$"
        },
        "expectedRevision": {
          "type": "integer",
          "minimum": 1
        }
      }
    },
    "blueprintRead": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "blueprintId"
      ],
      "properties": {
        "blueprintId": {
          "type": "string",
          "pattern": "^[A-Za-z0-9_-]{3,128}$"
        }
      }
    },
    "invitationRead": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "invitationId"
      ],
      "properties": {
        "invitationId": {
          "type": "string",
          "pattern": "^[A-Za-z0-9_-]{3,128}$"
        }
      }
    },
    "capabilityRead": {
      "type": "object",
      "additionalProperties": false,
      "maxProperties": 0
    },
    "page": {
      "type": "integer",
      "minimum": 1,
      "maximum": 20
    },
    "blueprintList": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "organizerId"
      ],
      "properties": {
        "organizerId": {
          "type": "string",
          "pattern": "^[A-Za-z0-9_-]{3,128}$"
        },
        "cursor": {
          "type": "string",
          "pattern": "^[A-Za-z0-9_-]{3,128}$"
        },
        "limit": {
          "type": "integer",
          "minimum": 1,
          "maximum": 20
        }
      }
    },
    "invitationList": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "blueprintId"
      ],
      "properties": {
        "blueprintId": {
          "type": "string",
          "pattern": "^[A-Za-z0-9_-]{3,128}$"
        },
        "cursor": {
          "type": "string",
          "pattern": "^[A-Za-z0-9_-]{3,128}$"
        },
        "limit": {
          "type": "integer",
          "minimum": 1,
          "maximum": 20
        }
      }
    }
  },
  "x-callables": [
    "adminSaveSalesDemoBlueprint",
    "adminReviewSalesDemoBlueprint",
    "adminWithdrawSalesDemoBlueprint",
    "adminIssueSalesDemoInvitation",
    "adminRevokeSalesDemoInvitation",
    "adminGetSalesDemoBlueprint",
    "adminGetSalesDemoInvitation",
    "adminGetSalesDemoCapability",
    "adminListSalesDemoBlueprints",
    "adminListSalesDemoInvitations"
  ]
} as const;
