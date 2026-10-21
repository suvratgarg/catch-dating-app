/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const hostOrganizerActivationDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/host_organizer_activations.schema.json",
  "title": "HostOrganizerActivationDocument",
  "description": "Private Host pilot review and operational activation evidence. No attendee identity or advertising permission.",
  "type": "object",
  "additionalProperties": false,
  "x-firestore-collection": "hostOrganizerActivations",
  "x-firestore-path": "hostOrganizerActivations/{organizerId}",
  "x-document-id-field": "organizerId",
  "x-owner": "Host acquisition reviewed pilot workflow",
  "required": [
    "schemaVersion",
    "classification",
    "organizerId",
    "eventId",
    "receiptId",
    "activatedAt",
    "recordedAt",
    "reviewRevision"
  ],
  "properties": {
    "schemaVersion": {
      "const": 1
    },
    "classification": {
      "const": "sales_private"
    },
    "organizerId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 160,
      "pattern": "^[A-Za-z0-9_-]+$"
    },
    "eventId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 160,
      "pattern": "^[A-Za-z0-9_-]+$"
    },
    "receiptId": {
      "type": "string",
      "pattern": "^host_activation_[a-f0-9-]{36}$"
    },
    "activatedAt": {
      "type": "integer",
      "minimum": 1
    },
    "recordedAt": {
      "type": "integer",
      "minimum": 1
    },
    "reviewRevision": {
      "type": "integer",
      "minimum": 1
    }
  }
} as const;
