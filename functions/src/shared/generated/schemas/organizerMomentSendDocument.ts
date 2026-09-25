/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const organizerMomentSendDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/organizer_moment_sends.schema.json",
  "title": "OrganizerMomentSendDocument",
  "description": "Per-recipient send decision for a moment run; document id is {runId}_{recipientKey} so retries never double-send and every suppression carries its audited reason.",
  "type": "object",
  "additionalProperties": false,
  "x-firestore-collection": "organizerMomentSends",
  "x-firestore-path": "organizerMomentSends/{sendId}",
  "x-document-id-field": "sendId",
  "x-owner": "moment runner",
  "required": [
    "momentId",
    "recipientKey",
    "decision",
    "dayKey",
    "createdAtMillis"
  ],
  "properties": {
    "momentId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "recipientKey": {
      "type": "string",
      "minLength": 1,
      "maxLength": 220,
      "description": "Stable recipient idempotency key: household:|guest:|uid:|contact: prefixed."
    },
    "decision": {
      "type": "string",
      "enum": [
        "sent",
        "suppressed"
      ]
    },
    "reason": {
      "type": [
        "string",
        "null"
      ],
      "enum": [
        "noEndpoint",
        "preferenceOff",
        "noConsent",
        "optedOut",
        "endpointSuppressed",
        "dailyCap",
        null
      ],
      "description": "Suppression reason; null on sent."
    },
    "dayKey": {
      "type": "string",
      "minLength": 1,
      "maxLength": 40,
      "description": "Scope-local calendar day (YYYY-MM-DD) for per-endpoint daily caps."
    },
    "createdAtMillis": {
      "type": "integer",
      "minimum": 0,
      "maximum": 9007199254740991
    },
    "runId": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 260,
      "description": "Run that produced this send; set on staffAttention sends so the attention projection can group recipients per run."
    },
    "actionKind": {
      "type": [
        "string",
        "null"
      ],
      "enum": [
        "sendTemplate",
        "push",
        "staffAttention",
        null
      ],
      "description": "Moment action kind; staffAttention rows feed the organizer attention projection."
    },
    "organizerId": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 200,
      "description": "Owning organizer for attention projection queries."
    },
    "scopeKind": {
      "type": [
        "string",
        "null"
      ],
      "enum": [
        "event",
        "program",
        null
      ]
    },
    "scopeId": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 200
    },
    "duty": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 80,
      "description": "staffAttention: duty the alert targeted."
    },
    "severity": {
      "type": [
        "string",
        "null"
      ],
      "enum": [
        "info",
        "warning",
        "urgent",
        null
      ],
      "description": "staffAttention: alert severity."
    },
    "title": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 240,
      "description": "staffAttention: rendered alert title."
    }
  }
} as const;
