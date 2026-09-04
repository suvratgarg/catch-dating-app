/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const organizerProviderSetupCallableResponseSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callable_responses/organizer_provider_setup_response.schema.json",
  "title": "OrganizerProviderSetupCallableResponse",
  "description": "Safe provider capability catalog, organizer connections and event mapping projection.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "organizerId",
    "eventId",
    "providers",
    "connections",
    "mapping"
  ],
  "properties": {
    "organizerId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "eventId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "providers": {
      "type": "array",
      "minItems": 9,
      "maxItems": 9,
      "items": {
        "type": "object",
        "additionalProperties": false,
        "required": [
          "provider",
          "displayName",
          "adapterClass",
          "availability",
          "importSupport",
          "connectionMethod",
          "capabilities",
          "requirement"
        ],
        "properties": {
          "provider": {
            "type": "string",
            "enum": [
              "generic",
              "luma",
              "eventbrite",
              "partiful",
              "posh",
              "bookmyshow",
              "district",
              "sortmyscene",
              "airbnb"
            ]
          },
          "displayName": {
            "type": "string",
            "minLength": 1,
            "maxLength": 80
          },
          "adapterClass": {
            "type": "string",
            "enum": [
              "A",
              "C",
              "D",
              "E",
              "unclassified"
            ]
          },
          "availability": {
            "type": "string",
            "enum": [
              "available",
              "exportOnly",
              "configurationRequired",
              "partnerAccessRequired",
              "sampleRequired",
              "manualOnly"
            ]
          },
          "importSupport": {
            "type": "string",
            "enum": [
              "verified",
              "generic",
              "sampleRequired"
            ]
          },
          "connectionMethod": {
            "type": "string",
            "enum": [
              "apiKey",
              "oauth",
              "partner",
              "none"
            ]
          },
          "capabilities": {
            "type": "object",
            "additionalProperties": false,
            "required": [
              "fileImport",
              "eventList",
              "rosterIdentity",
              "registrationStatus",
              "providerCheckIn",
              "orderAmount",
              "refundStatus",
              "referralCode",
              "webhooks",
              "writeBookings"
            ],
            "properties": {
              "fileImport": {
                "type": "boolean"
              },
              "eventList": {
                "type": "boolean"
              },
              "rosterIdentity": {
                "type": "boolean"
              },
              "registrationStatus": {
                "type": "boolean"
              },
              "providerCheckIn": {
                "type": "boolean"
              },
              "orderAmount": {
                "type": "boolean"
              },
              "refundStatus": {
                "type": "boolean"
              },
              "referralCode": {
                "type": "boolean"
              },
              "webhooks": {
                "type": "boolean"
              },
              "writeBookings": {
                "type": "boolean"
              }
            }
          },
          "requirement": {
            "type": "string",
            "minLength": 1,
            "maxLength": 240
          }
        }
      }
    },
    "connections": {
      "type": "array",
      "maxItems": 20,
      "items": {
        "type": "object",
        "additionalProperties": false,
        "required": [
          "connectionId",
          "provider",
          "status",
          "externalAccountId",
          "externalAccountName",
          "syncMode",
          "capabilities",
          "revision",
          "lastHealthSyncAtMillis",
          "lastSuccessfulSyncAtMillis"
        ],
        "properties": {
          "connectionId": {
            "type": "string",
            "minLength": 1,
            "maxLength": 180
          },
          "provider": {
            "const": "luma"
          },
          "status": {
            "type": "string",
            "enum": [
              "active",
              "degraded",
              "credentialRevoked",
              "disconnected"
            ]
          },
          "externalAccountId": {
            "type": "string"
          },
          "externalAccountName": {
            "type": "string"
          },
          "syncMode": {
            "const": "manualPoll"
          },
          "capabilities": {
            "type": "object",
            "additionalProperties": false,
            "required": [
              "eventList",
              "rosterIdentity",
              "registrationStatus",
              "providerCheckIn",
              "orderAmount",
              "refundStatus",
              "referralCode",
              "webhooks",
              "writeBookings"
            ],
            "properties": {
              "eventList": {
                "type": "boolean"
              },
              "rosterIdentity": {
                "type": "boolean"
              },
              "registrationStatus": {
                "type": "boolean"
              },
              "providerCheckIn": {
                "type": "boolean"
              },
              "orderAmount": {
                "type": "boolean"
              },
              "refundStatus": {
                "type": "boolean"
              },
              "referralCode": {
                "type": "boolean"
              },
              "webhooks": {
                "type": "boolean"
              },
              "writeBookings": {
                "type": "boolean"
              }
            }
          },
          "revision": {
            "type": "integer",
            "minimum": 1
          },
          "lastHealthSyncAtMillis": {
            "type": [
              "integer",
              "null"
            ]
          },
          "lastSuccessfulSyncAtMillis": {
            "type": [
              "integer",
              "null"
            ]
          }
        }
      }
    },
    "mapping": {
      "type": [
        "object",
        "null"
      ],
      "additionalProperties": false,
      "required": [
        "mappingId",
        "connectionId",
        "provider",
        "externalEventId",
        "status",
        "fieldAuthority",
        "revision",
        "lastSyncAtMillis",
        "lastSuccessfulSyncAtMillis",
        "lastSyncStatus",
        "lastSyncRunId"
      ],
      "properties": {
        "mappingId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 180
        },
        "connectionId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 180
        },
        "provider": {
          "const": "luma"
        },
        "externalEventId": {
          "type": "string"
        },
        "status": {
          "type": "string",
          "enum": [
            "active",
            "paused",
            "disconnected"
          ]
        },
        "fieldAuthority": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "rosterIdentity",
            "registrationStatus",
            "checkIn",
            "orderAmount",
            "refundStatus",
            "referralCode"
          ],
          "properties": {
            "rosterIdentity": {
              "const": "provider"
            },
            "registrationStatus": {
              "const": "provider"
            },
            "checkIn": {
              "const": "providerWhenPresent"
            },
            "orderAmount": {
              "const": "unavailable"
            },
            "refundStatus": {
              "const": "unavailable"
            },
            "referralCode": {
              "const": "unavailable"
            }
          }
        },
        "revision": {
          "type": "integer",
          "minimum": 1
        },
        "lastSyncAtMillis": {
          "type": [
            "integer",
            "null"
          ]
        },
        "lastSuccessfulSyncAtMillis": {
          "type": [
            "integer",
            "null"
          ]
        },
        "lastSyncStatus": {
          "type": "string",
          "enum": [
            "never",
            "running",
            "completed",
            "partial",
            "failed"
          ]
        },
        "lastSyncRunId": {
          "type": [
            "string",
            "null"
          ]
        }
      }
    }
  }
} as const;
