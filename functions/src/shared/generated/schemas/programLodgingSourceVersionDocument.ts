/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const programLodgingSourceVersionDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/program_lodging_source_versions.schema.json",
  "title": "ProgramLodgingSourceVersionDocument",
  "description": "Private transactional revision counters backed by complete canonical source fingerprints. Contains no copied guest or property records. Changes invalidate proposals; publication advances its own domain atomically with canonical stays.",
  "type": "object",
  "additionalProperties": false,
  "x-firestore-collection": "programLodgingSourceVersions",
  "x-firestore-path": "programLodgingSourceVersions/{programId}",
  "x-document-id-field": "programId",
  "x-owner": "private program lodging source reader",
  "required": [
    "programId",
    "organizerId",
    "versions"
  ],
  "properties": {
    "programId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "x-catch-ownership": "server-only"
    },
    "organizerId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "x-catch-ownership": "server-only"
    },
    "versions": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "source",
        "inventory",
        "layout",
        "published"
      ],
      "properties": {
        "source": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "revision",
            "fingerprint"
          ],
          "properties": {
            "revision": {
              "type": "integer",
              "minimum": 1,
              "maximum": 9007199254740991
            },
            "fingerprint": {
              "type": "string",
              "pattern": "^[a-f0-9]{64}$"
            }
          }
        },
        "inventory": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "revision",
            "fingerprint"
          ],
          "properties": {
            "revision": {
              "type": "integer",
              "minimum": 1,
              "maximum": 9007199254740991
            },
            "fingerprint": {
              "type": "string",
              "pattern": "^[a-f0-9]{64}$"
            }
          }
        },
        "layout": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "revision",
            "fingerprint"
          ],
          "properties": {
            "revision": {
              "type": "integer",
              "minimum": 1,
              "maximum": 9007199254740991
            },
            "fingerprint": {
              "type": "string",
              "pattern": "^[a-f0-9]{64}$"
            }
          }
        },
        "published": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "revision",
            "fingerprint"
          ],
          "properties": {
            "revision": {
              "type": "integer",
              "minimum": 1,
              "maximum": 9007199254740991
            },
            "fingerprint": {
              "type": "string",
              "pattern": "^[a-f0-9]{64}$"
            }
          }
        }
      },
      "x-catch-ownership": "server-only"
    }
  }
} as const;
