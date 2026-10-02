/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const organizerCommunityMembershipDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/organizer_community_memberships.schema.json",
  "title": "OrganizerCommunityMembershipDocument",
  "description": "Current manager-controlled organizer community entitlement. Following, contact linkage, booking and attendance are separate.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "schemaVersion",
    "organizerId",
    "uid",
    "state",
    "revision",
    "source",
    "lastDecisionId",
    "activatedAtMillis",
    "updatedAtMillis"
  ],
  "properties": {
    "schemaVersion": {
      "const": 1
    },
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
    "state": {
      "enum": [
        "active",
        "revoked"
      ]
    },
    "revision": {
      "type": "integer",
      "minimum": 1,
      "maximum": 9007199254740990
    },
    "source": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "applicationId",
        "responseId",
        "formVersionId",
        "applicationRevision"
      ],
      "properties": {
        "applicationId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 180
        },
        "responseId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 180
        },
        "formVersionId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 180
        },
        "applicationRevision": {
          "type": "integer",
          "minimum": 1,
          "maximum": 9007199254740990
        }
      }
    },
    "lastDecisionId": {
      "type": "string",
      "pattern": "^ocmd_[a-f0-9]{64}$"
    },
    "activatedAtMillis": {
      "type": "integer",
      "minimum": 1,
      "maximum": 9007199254740991
    },
    "updatedAtMillis": {
      "type": "integer",
      "minimum": 1,
      "maximum": 9007199254740991
    }
  },
  "definitions": {
    "approvalSource": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "applicationId",
        "responseId",
        "formVersionId",
        "applicationRevision"
      ],
      "properties": {
        "applicationId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 180
        },
        "responseId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 180
        },
        "formVersionId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 180
        },
        "applicationRevision": {
          "type": "integer",
          "minimum": 1,
          "maximum": 9007199254740990
        }
      }
    }
  },
  "x-firestore-collection": "organizerCommunityMemberships",
  "x-firestore-path": "organizerCommunityMemberships/{membershipId}",
  "x-owner": "decideOrganizerCommunityMembership"
} as const;
