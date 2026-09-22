/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const organizerEntitlementsDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/organizer_entitlements.schema.json",
  "title": "OrganizerEntitlementsDocument",
  "description": "Server-owned entitlement document at organizerEntitlements/{organizerId} holding purchased plan grants and metered usage. Written only by admin grant/revoke callables in the pilot; managers receive a bounded callable projection.",
  "type": "object",
  "additionalProperties": false,
  "x-firestore-collection": "organizerEntitlements",
  "x-firestore-path": "organizerEntitlements/{organizerId}",
  "x-document-id-field": "organizerId",
  "x-owner": "organizer entitlement admin callables",
  "required": [
    "schemaVersion",
    "organizerId",
    "grants",
    "meters",
    "revision",
    "createdAt",
    "updatedAt"
  ],
  "properties": {
    "schemaVersion": {
      "const": 1,
      "x-catch-ownership": "server-only"
    },
    "organizerId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "x-catch-ownership": "server-only"
    },
    "grants": {
      "type": "array",
      "maxItems": 50,
      "items": {
        "type": "object",
        "additionalProperties": false,
        "required": [
          "grantId",
          "sku",
          "unit",
          "quantityTotal",
          "quantityConsumed",
          "validFrom",
          "validUntil",
          "source",
          "receiptRef",
          "note",
          "grantedBy",
          "grantedAt",
          "revokedAt",
          "revokedBy",
          "revokeReason"
        ],
        "properties": {
          "grantId": {
            "type": "string",
            "minLength": 1,
            "maxLength": 180
          },
          "sku": {
            "type": "string",
            "enum": [
              "wedding_essentials",
              "wedding_pro",
              "wedding_signature",
              "wedding_transport_addon",
              "planner_annual"
            ]
          },
          "unit": {
            "type": "string",
            "enum": [
              "program",
              "organizerYear"
            ]
          },
          "quantityTotal": {
            "type": "integer",
            "minimum": 1,
            "maximum": 1000000
          },
          "quantityConsumed": {
            "type": "integer",
            "minimum": 0,
            "maximum": 1000000
          },
          "validFrom": {
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
          "validUntil": {
            "anyOf": [
              {
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
              {
                "type": "null"
              }
            ]
          },
          "source": {
            "type": "string",
            "enum": [
              "manualInvoice",
              "checkout",
              "promo"
            ]
          },
          "receiptRef": {
            "type": [
              "string",
              "null"
            ],
            "maxLength": 180
          },
          "note": {
            "type": [
              "string",
              "null"
            ],
            "maxLength": 500
          },
          "grantedBy": {
            "type": "string",
            "minLength": 1,
            "maxLength": 180
          },
          "grantedAt": {
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
          "revokedAt": {
            "anyOf": [
              {
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
              {
                "type": "null"
              }
            ]
          },
          "revokedBy": {
            "type": [
              "string",
              "null"
            ],
            "maxLength": 180
          },
          "revokeReason": {
            "type": [
              "string",
              "null"
            ],
            "maxLength": 500
          }
        }
      },
      "x-catch-ownership": "server-only"
    },
    "meters": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "flightDaysUsed",
        "waConversationsUsed",
        "periodStartsAt"
      ],
      "properties": {
        "flightDaysUsed": {
          "type": "integer",
          "minimum": 0,
          "maximum": 1000000
        },
        "waConversationsUsed": {
          "type": "integer",
          "minimum": 0,
          "maximum": 100000000
        },
        "periodStartsAt": {
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
        }
      },
      "x-catch-ownership": "server-only"
    },
    "revision": {
      "type": "integer",
      "minimum": 1,
      "maximum": 9007199254740991,
      "x-catch-ownership": "server-only"
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
      },
      "x-catch-ownership": "server-only"
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
      },
      "x-catch-ownership": "server-only"
    }
  }
} as const;
