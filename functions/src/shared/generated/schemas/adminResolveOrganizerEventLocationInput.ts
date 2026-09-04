/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const adminResolveOrganizerEventLocationCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/admin_resolve_organizer_event_location_payload.schema.json",
  "title": "AdminResolveOrganizerEventLocationCallablePayload",
  "description": "Callable payload accepted by adminResolveOrganizerEventLocation. This records reviewed coordinates for a private external event candidate without importing the event.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "candidateId",
    "location",
    "checklist",
    "note"
  ],
  "properties": {
    "candidateId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 240
    },
    "location": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "name",
        "latitude",
        "longitude"
      ],
      "properties": {
        "name": {
          "type": "string",
          "minLength": 1,
          "maxLength": 240
        },
        "address": {
          "type": [
            "string",
            "null"
          ],
          "maxLength": 500
        },
        "placeId": {
          "type": [
            "string",
            "null"
          ],
          "minLength": 1,
          "maxLength": 256
        },
        "latitude": {
          "type": [
            "number",
            "null"
          ],
          "minimum": -90,
          "maximum": 90
        },
        "longitude": {
          "type": [
            "number",
            "null"
          ],
          "minimum": -180,
          "maximum": 180
        },
        "notes": {
          "type": [
            "string",
            "null"
          ],
          "maxLength": 1000
        }
      }
    },
    "checklist": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "sourceLocationReviewed",
        "coordinatesReviewed",
        "placeIdentityReviewed",
        "importSafetyReviewed"
      ],
      "properties": {
        "sourceLocationReviewed": {
          "type": "boolean"
        },
        "coordinatesReviewed": {
          "type": "boolean"
        },
        "placeIdentityReviewed": {
          "type": "boolean"
        },
        "importSafetyReviewed": {
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
