/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const activityPreferencesSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/embedded/activity_preferences.schema.json",
  "title": "ActivityPreferences",
  "description": "Per-activity user preferences. Running is the first migrated activity-specific preference object; other activity kinds can be added without new root profile fields.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "running"
  ],
  "properties": {
    "running": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "paceMinSecsPerKm",
        "paceMaxSecsPerKm",
        "preferredDistances",
        "runningReasons",
        "preferredRunTimes",
        "version"
      ],
      "properties": {
        "paceMinSecsPerKm": {
          "type": "integer",
          "minimum": 1
        },
        "paceMaxSecsPerKm": {
          "type": "integer",
          "minimum": 1
        },
        "preferredDistances": {
          "type": "array",
          "maxItems": 12,
          "uniqueItems": true,
          "items": {
            "type": "string",
            "enum": [
              "fiveK",
              "tenK",
              "halfMarathon",
              "marathon"
            ]
          }
        },
        "runningReasons": {
          "type": "array",
          "maxItems": 12,
          "uniqueItems": true,
          "items": {
            "type": "string",
            "enum": [
              "fitness",
              "community",
              "mindfulness",
              "challenge",
              "weightLoss",
              "raceTraining",
              "social"
            ]
          }
        },
        "preferredRunTimes": {
          "type": "array",
          "maxItems": 8,
          "uniqueItems": true,
          "items": {
            "type": "string",
            "enum": [
              "earlyMorning",
              "morning",
              "afternoon",
              "evening",
              "night"
            ]
          }
        },
        "version": {
          "type": "integer",
          "minimum": 0
        }
      }
    }
  }
} as const;
