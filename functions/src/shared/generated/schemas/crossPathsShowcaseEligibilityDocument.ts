/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const crossPathsShowcaseEligibilityDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/cross_paths_showcase_eligibility.schema.json",
  "title": "CrossPathsShowcaseEligibilityDocument",
  "description": "Server-only reviewed eligibility record for showing one member in Cross Paths. It stores coarse readiness reasons and a profile fingerprint, never an attractiveness score.",
  "type": "object",
  "additionalProperties": false,
  "x-firestore-collection": "crossPathsShowcaseEligibility",
  "x-firestore-path": "crossPathsShowcaseEligibility/{uid}",
  "x-document-id-field": "uid",
  "x-owner": "adminSetCrossPathsShowcaseEligibility callable",
  "required": [
    "status",
    "reasonCodes",
    "ruleVersion",
    "reviewVersion",
    "profileFingerprint",
    "reviewChecklist",
    "reviewNote",
    "reviewedByUid",
    "reviewedAt",
    "updatedAt"
  ],
  "properties": {
    "status": {
      "type": "string",
      "enum": [
        "eligible",
        "needsReview",
        "paused"
      ],
      "x-catch-ownership": "callable-owned"
    },
    "reasonCodes": {
      "type": "array",
      "maxItems": 12,
      "uniqueItems": true,
      "items": {
        "type": "string",
        "enum": [
          "insufficient_photos",
          "incomplete_prompts",
          "missing_relationship_goal",
          "broken_media",
          "photo_moderation_pending",
          "photo_moderation_rejected",
          "public_profile_missing",
          "profile_changed",
          "reviewer_hold",
          "manual_pause"
        ]
      },
      "x-catch-ownership": "callable-owned"
    },
    "ruleVersion": {
      "type": "integer",
      "minimum": 1,
      "x-catch-ownership": "callable-owned"
    },
    "reviewVersion": {
      "type": "integer",
      "minimum": 1,
      "x-catch-ownership": "callable-owned"
    },
    "profileFingerprint": {
      "type": "string",
      "pattern": "^[a-f0-9]{64}$",
      "x-catch-ownership": "callable-owned"
    },
    "reviewChecklist": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "primaryPortraitClear",
        "profileRepresentsCurrentMember",
        "showcasePolicyReviewed"
      ],
      "properties": {
        "primaryPortraitClear": {
          "type": "boolean"
        },
        "profileRepresentsCurrentMember": {
          "type": "boolean"
        },
        "showcasePolicyReviewed": {
          "type": "boolean"
        }
      },
      "x-catch-ownership": "callable-owned"
    },
    "reviewNote": {
      "type": "string",
      "minLength": 1,
      "maxLength": 1000,
      "x-catch-ownership": "callable-owned"
    },
    "reviewedByUid": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "x-catch-ownership": "callable-owned"
    },
    "reviewedAt": {
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
      },
      "x-catch-ownership": "callable-owned"
    },
    "updatedAt": {
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
      },
      "x-catch-ownership": "callable-owned"
    }
  }
} as const;
