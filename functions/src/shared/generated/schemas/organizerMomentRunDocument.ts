/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const organizerMomentRunDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/organizer_moment_runs.schema.json",
  "title": "OrganizerMomentRunDocument",
  "description": "Server-owned planned/fired run for a moment. Time-based runId encodes moment + anchor revision + nominal due time; mutable travel wake and deferrals are separate. Triggered/manual identities retain subject/requestKey.",
  "type": "object",
  "additionalProperties": false,
  "x-firestore-collection": "organizerMomentRuns",
  "x-firestore-path": "organizerMomentRuns/{runId}",
  "x-document-id-field": "runId",
  "x-owner": "moment runner",
  "required": [
    "runId",
    "momentId",
    "dueAtMillis",
    "anchorRevision",
    "status"
  ],
  "properties": {
    "runId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 300
    },
    "momentId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "dueAtMillis": {
      "type": "integer",
      "minimum": 0,
      "maximum": 9007199254740991
    },
    "occurrenceVersion": {
      "type": "integer",
      "enum": [
        2
      ]
    },
    "plannedWakeAtMillis": {
      "type": "integer",
      "minimum": 0,
      "maximum": 9007199254740991
    },
    "travelPlanHash": {
      "type": "string",
      "pattern": "^[a-f0-9]{64}$"
    },
    "anchorRevision": {
      "type": "integer",
      "minimum": 0,
      "maximum": 9007199254740991
    },
    "status": {
      "type": "string",
      "enum": [
        "planned",
        "resolving",
        "dispatched",
        "skipped",
        "superseded",
        "failed"
      ]
    },
    "targetFunctionId": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 180
    },
    "subjectId": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 300,
      "description": "Triggered runs: the fact's subject (e.g. travel leg id)."
    },
    "reason": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 120,
      "description": "Skip/failure reason written at run transition."
    },
    "recipients": {
      "type": [
        "integer",
        "null"
      ],
      "minimum": 0
    },
    "sent": {
      "type": [
        "integer",
        "null"
      ],
      "minimum": 0
    },
    "suppressed": {
      "type": [
        "object",
        "null"
      ],
      "additionalProperties": {
        "type": "integer",
        "minimum": 0
      },
      "description": "Suppression reason -> recipient count rollup."
    },
    "suppressedNoEndpoint": {
      "type": [
        "integer",
        "null"
      ],
      "minimum": 0
    }
  }
} as const;
