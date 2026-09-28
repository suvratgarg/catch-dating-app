/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const adminGetSalesPrivacyCaseResponseSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callable_responses/admin_get_sales_privacy_case_response.schema.json",
  "title": "adminGetSalesPrivacyCaseResponse",
  "anyOf": [
    {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "organizerId",
        "restricted",
        "plan",
        "completeDeletion",
        "policy"
      ],
      "properties": {
        "organizerId": {
          "type": "string",
          "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]{0,179}$"
        },
        "restricted": {
          "const": false
        },
        "plan": {
          "type": "null"
        },
        "completeDeletion": {
          "const": false
        },
        "policy": {
          "anyOf": [
            {
              "type": "null"
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "revision",
                "policyHash",
                "sourceReference",
                "reviewedAt",
                "financeDisposition",
                "auditDisposition",
                "financeReason",
                "auditReason"
              ],
              "properties": {
                "revision": {
                  "type": "integer",
                  "minimum": 1
                },
                "policyHash": {
                  "type": "string",
                  "pattern": "^[a-f0-9]{64}$"
                },
                "sourceReference": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 240
                },
                "reviewedAt": {
                  "type": "string",
                  "format": "date-time"
                },
                "financeDisposition": {
                  "const": "retain_pending_finance_review"
                },
                "auditDisposition": {
                  "const": "retain_pending_audit_review"
                },
                "financeReason": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 500
                },
                "auditReason": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 500
                }
              }
            }
          ]
        }
      }
    },
    {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "organizerId",
        "restricted",
        "restriction",
        "plan",
        "completeDeletion",
        "policy"
      ],
      "properties": {
        "organizerId": {
          "type": "string",
          "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]{0,179}$"
        },
        "restricted": {
          "const": true
        },
        "restriction": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "status",
            "revision",
            "restrictedAt",
            "reason"
          ],
          "properties": {
            "status": {
              "enum": [
                "restricted",
                "processing",
                "internal_processed_with_unresolved"
              ]
            },
            "revision": {
              "type": "integer",
              "minimum": 0
            },
            "restrictedAt": {
              "type": "string",
              "format": "date-time"
            },
            "reason": {
              "type": "string"
            }
          }
        },
        "plan": {
          "anyOf": [
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "planId",
                "organizerId",
                "policyHash",
                "inventoryHash",
                "cursor",
                "itemCount",
                "retainedCount",
                "unresolvedCount",
                "blockers",
                "status"
              ],
              "properties": {
                "planId": {
                  "type": "string",
                  "pattern": "^privacy-[a-f0-9]{40}$"
                },
                "organizerId": {
                  "type": "string",
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]{0,179}$"
                },
                "policyHash": {
                  "type": "string",
                  "pattern": "^[a-f0-9]{64}$"
                },
                "inventoryHash": {
                  "type": "string",
                  "pattern": "^[a-f0-9]{64}$"
                },
                "cursor": {
                  "type": "integer",
                  "minimum": 0
                },
                "itemCount": {
                  "type": "integer",
                  "minimum": 0
                },
                "retainedCount": {
                  "type": "integer",
                  "minimum": 0
                },
                "unresolvedCount": {
                  "type": "integer",
                  "minimum": 0
                },
                "blockers": {
                  "type": "array",
                  "maxItems": 240,
                  "items": {
                    "type": "object",
                    "additionalProperties": false,
                    "required": [
                      "code",
                      "fingerprint"
                    ],
                    "properties": {
                      "code": {
                        "type": "string",
                        "pattern": "^[a-z_]{3,80}$"
                      },
                      "fingerprint": {
                        "type": "string",
                        "pattern": "^[a-f0-9]{16}$"
                      }
                    }
                  }
                },
                "status": {
                  "enum": [
                    "reviewed",
                    "processing",
                    "internal_processed_with_unresolved"
                  ]
                }
              }
            },
            {
              "type": "null"
            }
          ]
        },
        "completeDeletion": {
          "const": false
        },
        "policy": {
          "anyOf": [
            {
              "type": "null"
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "revision",
                "policyHash",
                "sourceReference",
                "reviewedAt",
                "financeDisposition",
                "auditDisposition",
                "financeReason",
                "auditReason"
              ],
              "properties": {
                "revision": {
                  "type": "integer",
                  "minimum": 1
                },
                "policyHash": {
                  "type": "string",
                  "pattern": "^[a-f0-9]{64}$"
                },
                "sourceReference": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 240
                },
                "reviewedAt": {
                  "type": "string",
                  "format": "date-time"
                },
                "financeDisposition": {
                  "const": "retain_pending_finance_review"
                },
                "auditDisposition": {
                  "const": "retain_pending_audit_review"
                },
                "financeReason": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 500
                },
                "auditReason": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 500
                }
              }
            }
          ]
        }
      }
    }
  ],
  "x-callable-aliases": [
    "adminGetSalesPrivacyCase"
  ],
  "definitions": {
    "blocker": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "code",
        "fingerprint"
      ],
      "properties": {
        "code": {
          "type": "string",
          "pattern": "^[a-z_]{3,80}$"
        },
        "fingerprint": {
          "type": "string",
          "pattern": "^[a-f0-9]{16}$"
        }
      }
    },
    "plan": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "planId",
        "organizerId",
        "policyHash",
        "inventoryHash",
        "cursor",
        "itemCount",
        "retainedCount",
        "unresolvedCount",
        "blockers",
        "status"
      ],
      "properties": {
        "planId": {
          "type": "string",
          "pattern": "^privacy-[a-f0-9]{40}$"
        },
        "organizerId": {
          "type": "string",
          "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]{0,179}$"
        },
        "policyHash": {
          "type": "string",
          "pattern": "^[a-f0-9]{64}$"
        },
        "inventoryHash": {
          "type": "string",
          "pattern": "^[a-f0-9]{64}$"
        },
        "cursor": {
          "type": "integer",
          "minimum": 0
        },
        "itemCount": {
          "type": "integer",
          "minimum": 0
        },
        "retainedCount": {
          "type": "integer",
          "minimum": 0
        },
        "unresolvedCount": {
          "type": "integer",
          "minimum": 0
        },
        "blockers": {
          "type": "array",
          "maxItems": 240,
          "items": {
            "type": "object",
            "additionalProperties": false,
            "required": [
              "code",
              "fingerprint"
            ],
            "properties": {
              "code": {
                "type": "string",
                "pattern": "^[a-z_]{3,80}$"
              },
              "fingerprint": {
                "type": "string",
                "pattern": "^[a-f0-9]{16}$"
              }
            }
          }
        },
        "status": {
          "enum": [
            "reviewed",
            "processing",
            "internal_processed_with_unresolved"
          ]
        }
      }
    },
    "batch": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "organizerId",
        "planId",
        "previousCursor",
        "nextCursor",
        "itemCount",
        "deletedCount",
        "retainedCount",
        "unresolvedCount",
        "status",
        "completeDeletion",
        "receiptId"
      ],
      "properties": {
        "organizerId": {
          "type": "string",
          "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]{0,179}$"
        },
        "planId": {
          "type": "string",
          "pattern": "^privacy-[a-f0-9]{40}$"
        },
        "previousCursor": {
          "type": "integer",
          "minimum": 0
        },
        "nextCursor": {
          "type": "integer",
          "minimum": 0
        },
        "itemCount": {
          "type": "integer",
          "minimum": 0
        },
        "deletedCount": {
          "type": "integer",
          "minimum": 0
        },
        "retainedCount": {
          "type": "integer",
          "minimum": 0
        },
        "unresolvedCount": {
          "type": "integer",
          "minimum": 0
        },
        "status": {
          "enum": [
            "processing",
            "internal_processed_with_unresolved"
          ]
        },
        "completeDeletion": {
          "const": false
        },
        "receiptId": {
          "type": "string",
          "pattern": "^privacy-batch-[a-f0-9]{40}$"
        }
      }
    }
  }
} as const;
