/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const createEventInviteLinkCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/create_event_invite_link_payload.schema.json",
  "title": "CreateEventInviteLinkCallablePayload",
  "description": "Callable payload accepted by createEventInviteLink for Host channels, direct recipients, partners, promoters, or eligible attendee referrers.",
  "x-callable-aliases": [
    "createEventInviteLink",
    "createAttendeeInviteLink"
  ],
  "type": "object",
  "additionalProperties": false,
  "required": [
    "eventId",
    "label"
  ],
  "properties": {
    "eventId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "label": {
      "type": "string",
      "minLength": 1,
      "maxLength": 80
    },
    "source": {
      "type": [
        "string",
        "null"
      ],
      "minLength": 1,
      "maxLength": 80
    },
    "linkKind": {
      "type": "string",
      "enum": [
        "hostChannel",
        "directRecipient",
        "attendeeReferrer",
        "promoter",
        "partner"
      ]
    },
    "intendedRecipientContactId": {
      "type": [
        "string",
        "null"
      ],
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
    "destinationKind": {
      "type": "string",
      "enum": [
        "catchEvent",
        "eventRuntime",
        "externalBooking",
        "marketingLanding"
      ]
    },
    "attributionWindowDays": {
      "type": [
        "integer",
        "null"
      ],
      "minimum": 1,
      "maximum": 90
    }
  }
} as const;
