/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const getOrganizerCrmSummaryCallableResponseSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callable_responses/get_organizer_crm_summary_response.schema.json",
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
  }
} as const;
