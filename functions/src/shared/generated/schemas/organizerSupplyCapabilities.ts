/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const organizerSupplyCapabilitiesSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/embedded/organizer_supply_capabilities.schema.json",
  "title": "OrganizerSupplyCapabilities",
  "description": "Canonical organizer-level ceiling for member affordances. Event policy may narrow these capabilities but may never widen them.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "mode",
    "bookable",
    "paymentsEnabled",
    "waitlistEnabled",
    "hostContactEnabled",
    "claimable",
    "reviewPolicy"
  ],
  "properties": {
    "mode": {
      "type": "string",
      "enum": [
        "unclaimed_read_only",
        "claimed_managed"
      ]
    },
    "bookable": {
      "type": "boolean"
    },
    "paymentsEnabled": {
      "type": "boolean"
    },
    "waitlistEnabled": {
      "type": "boolean"
    },
    "hostContactEnabled": {
      "type": "boolean"
    },
    "claimable": {
      "type": "boolean"
    },
    "reviewPolicy": {
      "type": "string",
      "enum": [
        "after_event_end",
        "attended_event_only"
      ]
    }
  },
  "oneOf": [
    {
      "properties": {
        "mode": {
          "const": "unclaimed_read_only"
        },
        "bookable": {
          "const": false
        },
        "paymentsEnabled": {
          "const": false
        },
        "waitlistEnabled": {
          "const": false
        },
        "hostContactEnabled": {
          "const": false
        },
        "reviewPolicy": {
          "const": "after_event_end"
        }
      },
      "required": [
        "mode",
        "bookable",
        "paymentsEnabled",
        "waitlistEnabled",
        "hostContactEnabled",
        "reviewPolicy"
      ]
    },
    {
      "properties": {
        "mode": {
          "const": "claimed_managed"
        },
        "bookable": {
          "const": true
        },
        "paymentsEnabled": {
          "const": true
        },
        "waitlistEnabled": {
          "const": true
        },
        "hostContactEnabled": {
          "const": true
        },
        "claimable": {
          "const": false
        },
        "reviewPolicy": {
          "const": "attended_event_only"
        }
      },
      "required": [
        "mode",
        "bookable",
        "paymentsEnabled",
        "waitlistEnabled",
        "hostContactEnabled",
        "claimable",
        "reviewPolicy"
      ]
    }
  ]
} as const;
