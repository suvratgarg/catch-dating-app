/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const salesInboundIntentsDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/sales_inbound_intents.schema.json",
  "title": "SalesInboundIntentDocument",
  "description": "Private self-reported host submission, immutable at capture and linked only after identity review.",
  "type": "object",
  "additionalProperties": false,
  "x-firestore-collection": "salesInboundIntents",
  "x-firestore-path": "salesInboundIntents/{intentId}",
  "x-document-id-field": "intentId",
  "x-owner": "joinWaitlist and adminLinkSalesInboundIntent",
  "required": [
    "schemaVersion",
    "revision",
    "classification",
    "intentId",
    "source",
    "submissionId",
    "requestHash",
    "waitlistId",
    "status",
    "organizerId",
    "evidenceStatus",
    "fullName",
    "email",
    "city",
    "entryRoute",
    "alreadyJoined",
    "hostApplication",
    "createdAt",
    "updatedAt"
  ],
  "properties": {
    "schemaVersion": {
      "const": 1
    },
    "revision": {
      "type": "integer",
      "minimum": 1
    },
    "classification": {
      "const": "sales_private"
    },
    "intentId": {
      "type": "string",
      "pattern": "^[a-f0-9]{64}$"
    },
    "source": {
      "const": "website"
    },
    "submissionId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 160
    },
    "requestHash": {
      "type": "string",
      "pattern": "^[a-f0-9]{64}$"
    },
    "waitlistId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 512
    },
    "status": {
      "enum": [
        "needs_identity_review",
        "linked",
        "dismissed"
      ]
    },
    "organizerId": {
      "anyOf": [
        {
          "type": "string",
          "minLength": 1,
          "maxLength": 128
        },
        {
          "type": "null"
        }
      ]
    },
    "evidenceStatus": {
      "const": "self_reported"
    },
    "fullName": {
      "type": "string",
      "minLength": 1,
      "maxLength": 100
    },
    "email": {
      "type": "string",
      "format": "email",
      "maxLength": 320
    },
    "city": {
      "type": "string",
      "minLength": 1,
      "maxLength": 80
    },
    "entryRoute": {
      "anyOf": [
        {
          "type": "string",
          "maxLength": 512
        },
        {
          "type": "null"
        }
      ]
    },
    "alreadyJoined": {
      "type": "boolean"
    },
    "hostApplication": {
      "anyOf": [
        {
          "type": "object",
          "additionalProperties": false,
          "properties": {
            "organizationName": {
              "anyOf": [
                {
                  "type": "string",
                  "maxLength": 140
                },
                {
                  "type": "null"
                }
              ]
            },
            "organizationType": {
              "anyOf": [
                {
                  "type": "string",
                  "maxLength": 80
                },
                {
                  "type": "null"
                }
              ]
            },
            "operatingCity": {
              "anyOf": [
                {
                  "type": "string",
                  "maxLength": 80
                },
                {
                  "type": "null"
                }
              ]
            },
            "communityLink": {
              "anyOf": [
                {
                  "type": "string",
                  "maxLength": 512
                },
                {
                  "type": "null"
                }
              ]
            },
            "formats": {
              "type": "array",
              "maxItems": 10,
              "uniqueItems": true,
              "items": {
                "type": "string",
                "maxLength": 80
              }
            },
            "eventCadence": {
              "anyOf": [
                {
                  "type": "string",
                  "maxLength": 80
                },
                {
                  "type": "null"
                }
              ]
            },
            "nextEventName": {
              "anyOf": [
                {
                  "type": "string",
                  "maxLength": 160
                },
                {
                  "type": "null"
                }
              ]
            },
            "nextEventDate": {
              "anyOf": [
                {
                  "type": "string",
                  "maxLength": 80
                },
                {
                  "type": "null"
                }
              ]
            },
            "eventLocation": {
              "anyOf": [
                {
                  "type": "string",
                  "maxLength": 180
                },
                {
                  "type": "null"
                }
              ]
            },
            "expectedCapacity": {
              "anyOf": [
                {
                  "type": "string",
                  "maxLength": 40
                },
                {
                  "type": "null"
                }
              ]
            },
            "bookingPlatform": {
              "anyOf": [
                {
                  "type": "string",
                  "maxLength": 120
                },
                {
                  "type": "null"
                }
              ]
            },
            "guestListFormat": {
              "anyOf": [
                {
                  "type": "string",
                  "maxLength": 120
                },
                {
                  "type": "null"
                }
              ]
            },
            "priceRange": {
              "anyOf": [
                {
                  "type": "string",
                  "maxLength": 80
                },
                {
                  "type": "null"
                }
              ]
            },
            "admissionModel": {
              "anyOf": [
                {
                  "type": "string",
                  "maxLength": 80
                },
                {
                  "type": "null"
                }
              ]
            },
            "waitlistPlan": {
              "anyOf": [
                {
                  "type": "string",
                  "maxLength": 80
                },
                {
                  "type": "null"
                }
              ]
            },
            "paymentReadiness": {
              "anyOf": [
                {
                  "type": "string",
                  "maxLength": 120
                },
                {
                  "type": "null"
                }
              ]
            },
            "eventSuccessModules": {
              "type": "array",
              "maxItems": 16,
              "uniqueItems": true,
              "items": {
                "type": "string",
                "maxLength": 120
              }
            },
            "hostGoals": {
              "anyOf": [
                {
                  "type": "string",
                  "maxLength": 1000
                },
                {
                  "type": "null"
                }
              ]
            },
            "operatingNotes": {
              "anyOf": [
                {
                  "type": "string",
                  "maxLength": 1000
                },
                {
                  "type": "null"
                }
              ]
            }
          }
        },
        {
          "type": "null"
        }
      ]
    },
    "createdAt": {
      "type": "object",
      "description": "Serialized Firestore Timestamp fixture shape.",
      "x-firestore-type": "timestamp",
      "additionalProperties": false,
      "required": [
        "_seconds",
        "_nanoseconds"
      ],
      "properties": {
        "_seconds": {
          "type": "integer"
        },
        "_nanoseconds": {
          "type": "integer",
          "minimum": 0,
          "maximum": 999999999
        }
      }
    },
    "updatedAt": {
      "type": "object",
      "description": "Serialized Firestore Timestamp fixture shape.",
      "x-firestore-type": "timestamp",
      "additionalProperties": false,
      "required": [
        "_seconds",
        "_nanoseconds"
      ],
      "properties": {
        "_seconds": {
          "type": "integer"
        },
        "_nanoseconds": {
          "type": "integer",
          "minimum": 0,
          "maximum": 999999999
        }
      }
    },
    "linkedAt": {
      "type": "object",
      "description": "Serialized Firestore Timestamp fixture shape.",
      "x-firestore-type": "timestamp",
      "additionalProperties": false,
      "required": [
        "_seconds",
        "_nanoseconds"
      ],
      "properties": {
        "_seconds": {
          "type": "integer"
        },
        "_nanoseconds": {
          "type": "integer",
          "minimum": 0,
          "maximum": 999999999
        }
      }
    },
    "linkedBy": {
      "type": "string",
      "minLength": 1,
      "maxLength": 128
    },
    "linkRequestId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 128
    }
  },
  "allOf": [
    {
      "if": {
        "properties": {
          "status": {
            "const": "linked"
          }
        }
      },
      "then": {
        "required": [
          "linkedAt",
          "linkedBy",
          "linkRequestId"
        ],
        "properties": {
          "organizerId": {
            "type": "string",
            "minLength": 1,
            "maxLength": 128
          }
        }
      },
      "else": {
        "properties": {
          "organizerId": {
            "type": "null"
          }
        }
      }
    }
  ]
} as const;
