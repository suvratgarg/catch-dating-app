/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const hostDirectorySummaryDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/host_directory_summaries.schema.json",
  "title": "HostDirectorySummaryDocument",
  "description": "Server-maintained organizer-scoped Host read view. Never identity, permission or mutation authority.",
  "type": "object",
  "additionalProperties": false,
  "x-firestore-collection": "hostDirectorySummaries",
  "x-firestore-path": "hostDirectorySummaries/{organizerId}",
  "x-document-id-field": "organizerId",
  "x-owner": "Host read model projector",
  "required": [
    "organizerId",
    "contactSummaryVersion",
    "segmentCounts",
    "summary",
    "manualTagVocabulary",
    "sourceCoverage",
    "projectionVersion"
  ],
  "properties": {
    "organizerId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "x-catch-ownership": "server-only"
    },
    "contactSummaryVersion": {
      "type": "integer",
      "minimum": 0,
      "maximum": 1,
      "x-catch-ownership": "server-only"
    },
    "segmentCounts": {
      "type": "object",
      "additionalProperties": {
        "type": "integer",
        "minimum": 0,
        "maximum": 9007199254740991
      },
      "x-catch-ownership": "server-only"
    },
    "summary": {
      "title": "GetOrganizerCrmSummaryCallableResponse",
      "description": "Projected Host CRM counts. No attendee identity or contact field is returned.",
      "type": "object",
      "additionalProperties": false,
      "required": [
        "organizerId",
        "contactCount",
        "pastAttendeeCount",
        "repeatAttendeeCount",
        "advocateCount",
        "highImpactAdvocateCount",
        "linkedAccountCount",
        "importedContactCount",
        "whatsappOptInCount",
        "smsOptInCount",
        "truncated",
        "readiness"
      ],
      "properties": {
        "organizerId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 180
        },
        "contactCount": {
          "type": "integer",
          "minimum": 0,
          "maximum": 2147483647
        },
        "pastAttendeeCount": {
          "type": "integer",
          "minimum": 0,
          "maximum": 2147483647
        },
        "repeatAttendeeCount": {
          "type": "integer",
          "minimum": 0,
          "maximum": 2147483647
        },
        "advocateCount": {
          "type": "integer",
          "minimum": 0,
          "maximum": 2147483647
        },
        "highImpactAdvocateCount": {
          "type": "integer",
          "minimum": 0,
          "maximum": 2147483647
        },
        "linkedAccountCount": {
          "type": "integer",
          "minimum": 0,
          "maximum": 2147483647
        },
        "importedContactCount": {
          "type": "integer",
          "minimum": 0,
          "maximum": 2147483647
        },
        "whatsappOptInCount": {
          "type": "integer",
          "minimum": 0,
          "maximum": 2147483647
        },
        "smsOptInCount": {
          "type": "integer",
          "minimum": 0,
          "maximum": 2147483647
        },
        "truncated": {
          "type": "boolean"
        },
        "readiness": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "inApp",
            "whatsapp",
            "sms"
          ],
          "properties": {
            "inApp": {
              "type": "string",
              "enum": [
                "currentEventOnly"
              ]
            },
            "whatsapp": {
              "type": "string",
              "enum": [
                "providerSetupRequired"
              ]
            },
            "sms": {
              "type": "string",
              "enum": [
                "providerAndDltSetupRequired"
              ]
            }
          }
        }
      },
      "x-catch-ownership": "server-only"
    },
    "manualTagVocabulary": {
      "type": "array",
      "maxItems": 20,
      "items": {
        "type": "object",
        "additionalProperties": false,
        "required": [
          "tagId",
          "label"
        ],
        "properties": {
          "tagId": {
            "type": "string",
            "pattern": "^[a-f0-9]{32}$"
          },
          "label": {
            "type": "string",
            "minLength": 1,
            "maxLength": 40
          }
        }
      },
      "x-catch-ownership": "server-only"
    },
    "sourceCoverage": {
      "type": "string",
      "enum": [
        "exact",
        "partial"
      ],
      "x-catch-ownership": "server-only"
    },
    "projectionVersion": {
      "type": "integer",
      "minimum": 1,
      "maximum": 1000,
      "x-catch-ownership": "server-only"
    },
    "formSummaryVersion": {
      "type": "integer",
      "minimum": 0,
      "maximum": 1,
      "x-catch-ownership": "server-only"
    },
    "eventSummaryVersion": {
      "type": "integer",
      "minimum": 0,
      "maximum": 1,
      "x-catch-ownership": "server-only"
    },
    "groupSummaryVersion": {
      "type": "integer",
      "minimum": 0,
      "maximum": 1,
      "x-catch-ownership": "server-only"
    },
    "responseSummaryVersion": {
      "type": "integer",
      "minimum": 0,
      "maximum": 1,
      "x-catch-ownership": "server-only"
    }
  }
} as const;
