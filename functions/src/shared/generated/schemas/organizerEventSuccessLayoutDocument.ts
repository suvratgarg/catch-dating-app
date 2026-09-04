/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const organizerEventSuccessLayoutDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/organizer_event_success_layouts.schema.json",
  "title": "OrganizerEventSuccessLayoutDocument",
  "description": "Reusable organizer-owned parametric room layout stored at organizerEventSuccessLayouts/{organizerId_layoutId}. Derived coordinates and proximity edges are never persisted.",
  "type": "object",
  "additionalProperties": false,
  "x-firestore-collection": "organizerEventSuccessLayouts",
  "x-firestore-path": "organizerEventSuccessLayouts/{layoutDocumentId}",
  "x-document-id-field": "id",
  "x-owner": "organizer manager through upsertEventSuccessLayout",
  "required": [
    "organizerId",
    "layoutId",
    "label",
    "units",
    "createdAt",
    "updatedAt"
  ],
  "properties": {
    "organizerId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "x-catch-ownership": "callable-owned"
    },
    "layoutId": {
      "type": "string",
      "pattern": "^[A-Za-z0-9][A-Za-z0-9_-]{0,119}$",
      "x-catch-ownership": "callable-owned"
    },
    "label": {
      "type": "string",
      "minLength": 1,
      "maxLength": 120,
      "x-catch-ownership": "callable-owned"
    },
    "units": {
      "type": "array",
      "minItems": 1,
      "maxItems": 200,
      "items": {
        "type": "object",
        "additionalProperties": false,
        "required": [
          "id",
          "label",
          "shape",
          "capacity",
          "gridX",
          "gridY",
          "order"
        ],
        "properties": {
          "id": {
            "type": "string",
            "pattern": "^[A-Za-z0-9][A-Za-z0-9_-]{0,79}$"
          },
          "label": {
            "type": "string",
            "minLength": 1,
            "maxLength": 80
          },
          "shape": {
            "type": "string",
            "enum": [
              "round",
              "rect",
              "row",
              "court",
              "zone"
            ]
          },
          "capacity": {
            "type": "integer",
            "minimum": 1,
            "maximum": 1000
          },
          "gridX": {
            "type": "integer",
            "minimum": 0,
            "maximum": 199
          },
          "gridY": {
            "type": "integer",
            "minimum": 0,
            "maximum": 199
          },
          "order": {
            "type": "integer",
            "minimum": 1,
            "maximum": 200
          }
        }
      },
      "x-catch-ownership": "callable-owned"
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
