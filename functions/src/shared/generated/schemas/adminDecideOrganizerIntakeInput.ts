/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const adminDecideOrganizerIntakeCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/admin_decide_organizer_intake_payload.schema.json",
  "title": "AdminDecideOrganizerIntakeCallablePayload",
  "description": "Callable payload accepted by adminDecideOrganizerIntake. This records a manual admin review decision for a private organizer-intake candidate.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "entityId",
    "decision",
    "publishStatus",
    "indexStatus",
    "appVisibility",
    "checklist",
    "note"
  ],
  "properties": {
    "entityId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "decision": {
      "type": "string",
      "enum": [
        "approve_public",
        "hold",
        "suppress"
      ]
    },
    "publishStatus": {
      "type": "string",
      "enum": [
        "draft",
        "published",
        "suppressed"
      ],
      "description": "Explicit public-web publication switch. Approval does not imply publication."
    },
    "indexStatus": {
      "type": "string",
      "enum": [
        "noindex",
        "indexed"
      ],
      "description": "Explicit search-indexing switch. Indexed requires a published web page."
    },
    "appVisibility": {
      "type": "string",
      "enum": [
        "hidden",
        "discoverable"
      ]
    },
    "checklist": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "identityReviewed",
        "surfaceInventoryReviewed",
        "ownerSafeCopyReviewed",
        "marketScopeReviewed",
        "mediaRightsReviewed",
        "crawlDisabledReviewed"
      ],
      "properties": {
        "identityReviewed": {
          "type": "boolean"
        },
        "surfaceInventoryReviewed": {
          "type": "boolean"
        },
        "ownerSafeCopyReviewed": {
          "type": "boolean"
        },
        "marketScopeReviewed": {
          "type": "boolean"
        },
        "mediaRightsReviewed": {
          "type": "boolean"
        },
        "crawlDisabledReviewed": {
          "type": "boolean"
        },
        "manualReportsReviewed": {
          "type": "boolean",
          "description": "True when the reviewer explicitly inspected manual reports that have no local raw artifact. Raw evidence remains outside Firestore; replay validation decides when this acknowledgement is required."
        },
        "claimTargetReviewed": {
          "type": "boolean"
        },
        "takedownPathReviewed": {
          "type": "boolean"
        },
        "impersonationReviewed": {
          "type": "boolean"
        },
        "operatingStatusReviewed": {
          "type": "boolean"
        },
        "eventAccuracyReviewed": {
          "type": "boolean"
        },
        "unclaimedAffordancesReviewed": {
          "type": "boolean"
        }
      }
    },
    "note": {
      "type": "string",
      "minLength": 1,
      "maxLength": 1000
    }
  }
} as const;
