/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const workspaceMembershipAssertionDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/workspace_membership_assertions.schema.json",
  "title": "WorkspaceMembershipAssertionDocument",
  "description": "Immutable source-labelled suggestion or manual membership evidence. Exact program/guest/group scope and program retention index are checked by the server. Import suggestions cannot overwrite selected manual inclusion or exclusion.",
  "x-firestore-collection": "workspaceMembershipAssertions",
  "x-firestore-path": "workspaceMembershipAssertions/{assertionId}",
  "x-document-id-field": "assertionId",
  "x-owner": "private program lodging server operations",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "schemaVersion",
    "organizerId",
    "programId",
    "workspaceRef",
    "relationshipRef",
    "groupId",
    "included",
    "sourceKind",
    "sourceId",
    "sourceVersion",
    "sourceLabel",
    "actorUid",
    "observedAtMillis"
  ],
  "properties": {
    "schemaVersion": {
      "const": 1,
      "x-catch-ownership": "server-only"
    },
    "organizerId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "x-catch-ownership": "server-only"
    },
    "programId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "x-catch-ownership": "server-only"
    },
    "workspaceRef": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "kind",
        "id"
      ],
      "properties": {
        "kind": {
          "const": "program"
        },
        "id": {
          "type": "string",
          "minLength": 1,
          "maxLength": 180,
          "x-catch-ownership": "server-only"
        }
      },
      "x-catch-ownership": "server-only"
    },
    "relationshipRef": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "kind",
        "id"
      ],
      "properties": {
        "kind": {
          "const": "programGuest"
        },
        "id": {
          "type": "string",
          "minLength": 1,
          "maxLength": 180,
          "x-catch-ownership": "server-only"
        }
      },
      "x-catch-ownership": "server-only"
    },
    "groupId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "x-catch-ownership": "server-only"
    },
    "included": {
      "type": "boolean",
      "x-catch-ownership": "server-only"
    },
    "sourceKind": {
      "enum": [
        "manualEntry",
        "manifestRow",
        "contributorList"
      ],
      "x-catch-ownership": "server-only"
    },
    "sourceId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 240,
      "x-catch-ownership": "server-only"
    },
    "sourceVersion": {
      "type": "integer",
      "minimum": 1,
      "maximum": 9007199254740991,
      "x-catch-ownership": "server-only"
    },
    "sourceLabel": {
      "type": "string",
      "minLength": 1,
      "maxLength": 140,
      "x-catch-ownership": "server-only"
    },
    "actorUid": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "x-catch-ownership": "server-only"
    },
    "observedAtMillis": {
      "type": "integer",
      "minimum": 1,
      "maximum": 9007199254740991,
      "x-catch-ownership": "server-only"
    }
  }
} as const;
