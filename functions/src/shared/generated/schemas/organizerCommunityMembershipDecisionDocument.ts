/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const organizerCommunityMembershipDecisionDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/organizer_community_membership_decisions.schema.json",
  "title": "OrganizerCommunityMembershipDecisionDocument",
  "description": "Immutable exact-request membership decision; replay never restores an older current entitlement.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "schemaVersion",
    "organizerId",
    "uid",
    "membershipId",
    "requestId",
    "requestHash",
    "actorUid",
    "action",
    "reason",
    "previousState",
    "expectedRevision",
    "resultingRevision",
    "source",
    "decidedAtMillis"
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
    "membershipId": {
      "type": "string",
      "pattern": "^ocm_[a-f0-9]{64}$"
    },
    "requestId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "requestHash": {
      "type": "string",
      "pattern": "^[a-f0-9]{64}$"
    },
    "actorUid": {
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
    "reason": {
      "type": "string",
      "minLength": 1,
      "maxLength": 2000
    },
    "previousState": {
      "enum": [
        "none",
        "active",
        "revoked"
      ]
    },
    "expectedRevision": {
      "type": "integer",
      "minimum": 0,
      "maximum": 9007199254740989
    },
    "resultingRevision": {
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
    "decidedAtMillis": {
      "type": "integer",
      "minimum": 1,
      "maximum": 9007199254740991
    }
  },
  "x-firestore-collection": "organizerCommunityMembershipDecisions",
  "x-firestore-path": "organizerCommunityMembershipDecisions/{decisionId}",
  "x-owner": "decideOrganizerCommunityMembership"
} as const;
