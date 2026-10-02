/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const decideOrganizerCommunityMembershipCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/decide_organizer_community_membership_payload.schema.json",
  "title": "DecideOrganizerCommunityMembershipCallablePayload",
  "description": "Explicit manager decision bound to an approved organizer-target native application and a reviewed membership revision.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "organizerId",
    "uid",
    "requestId",
    "action",
    "expectedRevision",
    "applicationId",
    "expectedApplicationRevision",
    "reason"
  ],
  "properties": {
    "organizerId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "uid": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "requestId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "action": {
      "enum": [
        "grant",
        "revoke"
      ]
    },
    "expectedRevision": {
      "type": "integer",
      "minimum": 0,
      "maximum": 9007199254740989
    },
    "applicationId": {
      "anyOf": [
        {
          "type": "string",
          "minLength": 1,
          "maxLength": 180
        },
        {
          "type": "null"
        }
      ]
    },
    "expectedApplicationRevision": {
      "anyOf": [
        {
          "type": "integer",
          "minimum": 1,
          "maximum": 9007199254740990
        },
        {
          "type": "null"
        }
      ]
    },
    "reason": {
      "type": "string",
      "minLength": 1,
      "maxLength": 2000
    }
  },
  "allOf": [
    {
      "if": {
        "properties": {
          "action": {
            "const": "grant"
          }
        }
      },
      "then": {
        "properties": {
          "applicationId": {
            "type": "string",
            "minLength": 1,
            "maxLength": 180
          },
          "expectedApplicationRevision": {
            "type": "integer",
            "minimum": 1,
            "maximum": 9007199254740990
          }
        }
      },
      "else": {
        "properties": {
          "applicationId": {
            "type": "null"
          },
          "expectedApplicationRevision": {
            "type": "null"
          }
        }
      }
    }
  ]
} as const;
