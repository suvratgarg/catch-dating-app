/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const organizerEntitlementCallableResponseSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callable_responses/organizer_entitlement_response.schema.json",
  "title": "OrganizerEntitlementCallableResponse",
  "description": "Bounded manager-facing entitlement projection: grants without admin internals, metered usage, and the versioned SKU catalog so clients render limits and prices without a second fetch.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "schemaVersion",
    "organizerId",
    "catalogVersion",
    "revision",
    "grants",
    "meters",
    "skuCatalog"
  ],
  "properties": {
    "schemaVersion": {
      "type": "integer",
      "const": 1
    },
    "organizerId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "catalogVersion": {
      "type": "integer",
      "minimum": 1,
      "maximum": 1000000
    },
    "revision": {
      "type": "integer",
      "minimum": 0,
      "maximum": 9007199254740991
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
          "skuLabel",
          "unit",
          "quantityTotal",
          "quantityConsumed",
          "quantityRemaining",
          "validFromMillis",
          "validUntilMillis",
          "source",
          "active",
          "revoked"
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
          "skuLabel": {
            "type": "string",
            "minLength": 1,
            "maxLength": 120
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
          "quantityRemaining": {
            "type": "integer",
            "minimum": 0,
            "maximum": 1000000
          },
          "validFromMillis": {
            "type": "integer",
            "minimum": 0,
            "maximum": 9007199254740991
          },
          "validUntilMillis": {
            "type": [
              "integer",
              "null"
            ],
            "minimum": 0,
            "maximum": 9007199254740991
          },
          "source": {
            "type": "string",
            "enum": [
              "manualInvoice",
              "checkout",
              "promo"
            ]
          },
          "active": {
            "type": "boolean"
          },
          "revoked": {
            "type": "boolean"
          }
        }
      }
    },
    "meters": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "flightDaysUsed",
        "waConversationsUsed"
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
        }
      }
    },
    "skuCatalog": {
      "type": "object",
      "additionalProperties": false,
      "patternProperties": {
        "^(wedding_essentials|wedding_pro|wedding_signature|wedding_transport_addon|planner_annual)$": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "label",
            "unit",
            "priceMinor",
            "currency",
            "limits",
            "capabilitiesAllowed",
            "includedFlightDays",
            "includedWaConversations",
            "stakeholderSeats"
          ],
          "properties": {
            "label": {
              "type": "string",
              "minLength": 1,
              "maxLength": 120
            },
            "unit": {
              "type": "string",
              "enum": [
                "program",
                "organizerYear"
              ]
            },
            "priceMinor": {
              "type": [
                "integer",
                "null"
              ],
              "minimum": 0,
              "maximum": 100000000
            },
            "currency": {
              "type": "string",
              "const": "INR"
            },
            "limits": {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "guests",
                "functions",
                "staffAssignments",
                "momentsPerFunction"
              ],
              "properties": {
                "guests": {
                  "type": [
                    "integer",
                    "null"
                  ],
                  "minimum": 1,
                  "maximum": 1000000
                },
                "functions": {
                  "type": [
                    "integer",
                    "null"
                  ],
                  "minimum": 1,
                  "maximum": 1000000
                },
                "staffAssignments": {
                  "type": [
                    "integer",
                    "null"
                  ],
                  "minimum": 1,
                  "maximum": 1000000
                },
                "momentsPerFunction": {
                  "type": [
                    "integer",
                    "null"
                  ],
                  "minimum": 1,
                  "maximum": 1000000
                }
              }
            },
            "capabilitiesAllowed": {
              "type": "array",
              "maxItems": 4,
              "uniqueItems": true,
              "items": {
                "type": "string",
                "enum": [
                  "arrivalsTransport",
                  "accommodation",
                  "forms",
                  "messaging"
                ]
              }
            },
            "includedFlightDays": {
              "type": "integer",
              "minimum": 0,
              "maximum": 1000000
            },
            "includedWaConversations": {
              "type": "integer",
              "minimum": 0,
              "maximum": 100000000
            },
            "stakeholderSeats": {
              "type": [
                "integer",
                "null"
              ],
              "minimum": 1,
              "maximum": 1000000
            }
          }
        }
      }
    }
  }
} as const;
