/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const eventInviteAttributionDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/event_invite_attributions.schema.json",
  "title": "EventInviteAttributionDocument",
  "description": "Immutable evidence assigning or reversing one downstream event fact to one invitation link.",
  "type": "object",
  "additionalProperties": false,
  "x-firestore-collection": "eventInviteAttributions",
  "x-firestore-path": "eventInviteAttributions/{attributionId}",
  "x-document-id-field": "attributionId",
  "x-owner": "event participation and operational attendee attribution triggers",
  "required": [
    "eventId",
    "organizerId",
    "inviteLinkId",
    "linkKind",
    "ownerContactId",
    "intendedRecipientContactId",
    "subjectContactId",
    "subjectUid",
    "factKind",
    "operation",
    "sourceKind",
    "sourceFactId",
    "primaryCredit",
    "confidence",
    "referralCredit",
    "reversalOfAttributionId",
    "occurredAt",
    "createdAt"
  ],
  "properties": {
    "eventId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "organizerId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "inviteLinkId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
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
    "ownerContactId": {
      "type": [
        "string",
        "null"
      ],
      "minLength": 1,
      "maxLength": 180
    },
    "intendedRecipientContactId": {
      "type": [
        "string",
        "null"
      ],
      "minLength": 1,
      "maxLength": 180
    },
    "subjectContactId": {
      "type": [
        "string",
        "null"
      ],
      "minLength": 1,
      "maxLength": 180
    },
    "subjectUid": {
      "type": [
        "string",
        "null"
      ],
      "minLength": 1,
      "maxLength": 180
    },
    "factKind": {
      "type": "string",
      "enum": [
        "registration",
        "booking",
        "checkIn",
        "revenue",
        "refund"
      ]
    },
    "operation": {
      "type": "string",
      "enum": [
        "credit",
        "reversal"
      ]
    },
    "sourceKind": {
      "type": "string",
      "enum": [
        "catchParticipation",
        "eventAttendee",
        "provider",
        "selfReport"
      ]
    },
    "sourceFactId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 240
    },
    "primaryCredit": {
      "type": "boolean"
    },
    "confidence": {
      "type": "string",
      "enum": [
        "exact",
        "reconciled",
        "selfReported"
      ]
    },
    "referralCredit": {
      "type": "boolean"
    },
    "amountMinor": {
      "type": [
        "integer",
        "null"
      ],
      "minimum": 0
    },
    "currency": {
      "type": [
        "string",
        "null"
      ],
      "pattern": "^[A-Z]{3}$"
    },
    "reversalOfAttributionId": {
      "type": [
        "string",
        "null"
      ],
      "minLength": 1,
      "maxLength": 180
    },
    "occurredAt": {
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
    }
  }
} as const;
