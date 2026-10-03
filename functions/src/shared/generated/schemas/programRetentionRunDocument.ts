/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const programRetentionRunDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/program_retention_runs.schema.json",
  "title": "ProgramRetentionRunDocument",
  "description": "Durable journal for one program's archive-anonymization run. Document id equals the program id (a program anonymizes at most once). Phases record per-collection progress so a crashed or chunked run resumes idempotently.",
  "type": "object",
  "additionalProperties": false,
  "x-firestore-collection": "programRetentionRuns",
  "x-firestore-path": "programRetentionRuns/{programId}",
  "x-document-id-field": "programId",
  "x-owner": "program retention sweep",
  "required": [
    "programId",
    "organizerId",
    "status",
    "phases",
    "startedAt",
    "updatedAt",
    "leaseUntil",
    "leaseToken",
    "error",
    "revision"
  ],
  "properties": {
    "programId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "organizerId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "status": {
      "type": "string",
      "enum": [
        "running",
        "completed",
        "failed"
      ]
    },
    "phases": {
      "type": "array",
      "maxItems": 22,
      "description": "Per-collection progress journal; one entry per scrubbed collection, appended in order as phases complete.",
      "items": {
        "type": "object",
        "additionalProperties": false,
        "required": [
          "collection",
          "processed",
          "cursor"
        ],
        "properties": {
          "collection": {
            "type": "string",
            "minLength": 1,
            "maxLength": 80
          },
          "processed": {
            "type": "integer",
            "minimum": 0
          },
          "cursor": {
            "type": [
              "string",
              "null"
            ],
            "maxLength": 180,
            "description": "Last document id processed in this phase; resume token for chunked sweeps."
          },
          "completedAtMillis": {
            "type": [
              "integer",
              "null"
            ],
            "minimum": 0
          }
        }
      }
    },
    "startedAt": {
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
    "completedAt": {
      "anyOf": [
        {
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
        {
          "type": "null"
        }
      ]
    },
    "leaseUntil": {
      "anyOf": [
        {
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
        {
          "type": "null"
        }
      ]
    },
    "leaseToken": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 120,
      "description": "Fencing token for the worker currently holding the run lease."
    },
    "error": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 2000
    },
    "revision": {
      "type": "integer",
      "minimum": 1,
      "maximum": 9007199254740991
    }
  }
} as const;
