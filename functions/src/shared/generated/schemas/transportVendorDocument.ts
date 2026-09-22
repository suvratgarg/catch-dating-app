/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const transportVendorDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/transport_vendors.schema.json",
  "title": "TransportVendorDocument",
  "description": "Server-owned organizer-level taxi/coach subcontractor identity. Program use requires an explicit binding; rate cards and commercial terms ship with the reconciliation slice.",
  "type": "object",
  "additionalProperties": false,
  "x-firestore-collection": "transportVendors",
  "x-firestore-path": "transportVendors/{vendorId}",
  "x-document-id-field": "vendorId",
  "x-owner": "organizer transport vendor callables",
  "required": [
    "organizerId",
    "name",
    "contactName",
    "phoneE164",
    "programIds",
    "active",
    "notes",
    "createdAt",
    "updatedAt",
    "revision"
  ],
  "properties": {
    "organizerId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "name": {
      "type": "string",
      "minLength": 1,
      "maxLength": 140
    },
    "contactName": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 140
    },
    "phoneE164": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 20
    },
    "programIds": {
      "type": "array",
      "maxItems": 100,
      "uniqueItems": true,
      "items": {
        "type": "string",
        "minLength": 1,
        "maxLength": 180
      },
      "description": "Programs this vendor is bound to; dispatch may only snapshot bound vendors."
    },
    "active": {
      "type": "boolean"
    },
    "notes": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 500
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
      }
    },
    "revision": {
      "type": "integer",
      "minimum": 1,
      "maximum": 9007199254740991
    }
  }
} as const;
