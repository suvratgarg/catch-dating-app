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
      "anyOf": [
        {
          "type": "string",
          "minLength": 1,
          "maxLength": 180
        },
        {
          "type": "null"
        }
      ],
      "description": "Active CRM saved audience. Required for recipientSource.kind=savedAudience (the default); must be null for programSelection."
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
    },
    "recipientSource": {
      "type": [
        "object",
        "null"
      ],
      "additionalProperties": false,
      "required": [
        "kind"
      ],
      "description": "Recipient resolution. Absent reads as savedAudience backed by savedAudienceId. programSelection resolves program guests/households instead of CRM contacts.",
      "properties": {
        "kind": {
          "type": "string",
          "enum": [
            "savedAudience",
            "programSelection"
          ]
        },
        "programId": {
          "type": [
            "string",
            "null"
          ],
          "minLength": 1,
          "maxLength": 180,
          "description": "Required when kind=programSelection; ignored otherwise."
        },
        "functionIds": {
          "type": [
            "array",
            "null"
          ],
          "maxItems": 32,
          "uniqueItems": true,
          "items": {
            "type": "string",
            "minLength": 1,
            "maxLength": 180
          },
          "description": "Restricts to guests invited to these functions; null or empty means every function in the program."
        },
        "rsvpStatuses": {
          "type": [
            "array",
            "null"
          ],
          "maxItems": 4,
          "uniqueItems": true,
          "items": {
            "type": "string",
            "enum": [
              "pending",
              "attending",
              "declined",
              "maybe"
            ]
          },
          "description": "Restricts to matching per-function RSVP statuses; null or empty means every effective status."
        },
        "householdDedupe": {
          "type": [
            "boolean",
            "null"
          ],
          "description": "When true, guests sharing a household collapse into one recipient. Default true."
        }
      }
    }
  }
} as const;
