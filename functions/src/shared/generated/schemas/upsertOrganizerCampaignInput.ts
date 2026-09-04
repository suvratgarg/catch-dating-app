/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const upsertOrganizerCampaignCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/upsert_organizer_campaign_payload.schema.json",
  "title": "UpsertOrganizerCampaignCallablePayload",
  "description": "Creates or revision-updates one draft WhatsApp organizer campaign that consumes a Customers-owned saved audience id.",
  "x-callable-aliases": [
    "upsertOrganizerCampaign"
  ],
  "type": "object",
  "additionalProperties": false,
  "required": [
    "organizerId",
    "requestId",
    "name",
    "messageClass",
    "savedAudienceId",
    "connectionId",
    "templateId",
    "templateVariables"
  ],
  "properties": {
    "organizerId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "campaignId": {
      "type": [
        "string",
        "null"
      ],
      "minLength": 1,
      "maxLength": 180
    },
    "requestId": {
      "type": "string",
      "minLength": 8,
      "maxLength": 120
    },
    "expectedRevision": {
      "type": [
        "integer",
        "null"
      ],
      "minimum": 1,
      "maximum": 9007199254740991
    },
    "name": {
      "type": "string",
      "minLength": 1,
      "maxLength": 120
    },
    "messageClass": {
      "type": "string",
      "enum": [
        "eventFollowUp",
        "organizerUpdate",
        "organizerPromotion"
      ]
    },
    "savedAudienceId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "connectionId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "templateId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "templateVariables": {
      "type": "object",
      "maxProperties": 20,
      "propertyNames": {
        "pattern": "^[A-Za-z][A-Za-z0-9_]{0,63}$"
      },
      "additionalProperties": {
        "type": "string",
        "minLength": 1,
        "maxLength": 240
      }
    },
    "eventId": {
      "type": [
        "string",
        "null"
      ],
      "minLength": 1,
      "maxLength": 180
    },
    "inviteDestinationKind": {
      "type": [
        "string",
        "null"
      ],
      "enum": [
        null,
        "catchEvent",
        "eventRuntime",
        "externalBooking",
        "marketingLanding"
      ]
    },
    "scheduledAtMillis": {
      "type": [
        "integer",
        "null"
      ],
      "minimum": 0,
      "maximum": 4102444800000
    }
  }
} as const;
