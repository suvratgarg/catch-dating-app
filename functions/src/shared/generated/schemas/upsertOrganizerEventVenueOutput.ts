/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const upsertOrganizerEventVenueCallableResponseSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callable_responses/upsert_organizer_event_venue_response.schema.json",
  "title": "UpsertOrganizerEventVenueCallableResponse",
  "description": "Canonical reusable venue returned after an organizer venue upsert.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "venue"
  ],
  "properties": {
    "venue": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "organizerId",
        "venueId",
        "label",
        "meetingLocation",
        "status"
      ],
      "properties": {
        "organizerId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 180
        },
        "venueId": {
          "type": "string",
          "pattern": "^[A-Za-z0-9][A-Za-z0-9_-]{0,119}$"
        },
        "label": {
          "type": "string",
          "minLength": 1,
          "maxLength": 120
        },
        "meetingLocation": {
          "type": "object",
          "additionalProperties": false,
          "description": "Canonical meeting location selected from Google Places or a manually pinned map coordinate.",
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
              "type": "number",
              "minimum": -90,
              "maximum": 90
            },
            "longitude": {
              "type": "number",
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
        "defaultEventCapacity": {
          "type": [
            "integer",
            "null"
          ],
          "minimum": 1,
          "maximum": 1000
        },
        "status": {
          "type": "string",
          "enum": [
            "active",
            "archived"
          ]
        }
      }
    }
  }
} as const;
