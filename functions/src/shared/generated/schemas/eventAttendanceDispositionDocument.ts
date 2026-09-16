/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const eventAttendanceDispositionDocumentSchema: Record<string, unknown> = {
  "type": "object",
  "additionalProperties": false,
  "required": [
    "dispositionId",
    "context",
    "attendeeId",
    "revision",
    "binding",
    "decision",
    "actorUid",
    "recordedAt"
  ],
  "properties": {
    "dispositionId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 160,
      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
    },
    "context": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "mode",
        "eventId",
        "organizerId"
      ],
      "properties": {
        "mode": {
          "type": "string",
          "const": "live"
        },
        "eventId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 160,
          "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
        },
        "organizerId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 2000
        }
      }
    },
    "attendeeId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 160,
      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
    },
    "revision": {
      "type": "integer",
      "minimum": 1,
      "maximum": 9007199254740991
    },
    "binding": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "sourceGeneration",
        "attendeeGeneration",
        "identityHash",
        "attendanceHash",
        "closureHash"
      ],
      "properties": {
        "sourceGeneration": {
          "type": "string",
          "pattern": "^[a-f0-9]{64}$"
        },
        "attendeeGeneration": {
          "type": "string",
          "pattern": "^[a-f0-9]{64}$"
        },
        "identityHash": {
          "type": "string",
          "pattern": "^[a-f0-9]{64}$"
        },
        "attendanceHash": {
          "type": "string",
          "pattern": "^[a-f0-9]{64}$"
        },
        "closureHash": {
          "type": "string",
          "pattern": "^[a-f0-9]{64}$"
        }
      }
    },
    "decision": {
      "oneOf": [
        {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "kind",
            "evidence"
          ],
          "properties": {
            "kind": {
              "const": "record"
            },
            "evidence": {
              "oneOf": [
                {
                  "type": "object",
                  "additionalProperties": false,
                  "required": [
                    "kind"
                  ],
                  "properties": {
                    "kind": {
                      "const": "hostConfirmed"
                    }
                  }
                },
                {
                  "type": "object",
                  "additionalProperties": false,
                  "required": [
                    "kind",
                    "guestRevision",
                    "episodeId"
                  ],
                  "properties": {
                    "kind": {
                      "const": "guestDeclined"
                    },
                    "guestRevision": {
                      "type": "integer",
                      "minimum": 0,
                      "maximum": 9007199254740991
                    },
                    "episodeId": {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 160,
                      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                    }
                  }
                }
              ]
            }
          }
        },
        {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "kind",
            "reason"
          ],
          "properties": {
            "kind": {
              "const": "clear"
            },
            "reason": {
              "enum": [
                "recordingMistake",
                "attendanceCorrected",
                "noLongerApplicable"
              ]
            }
          }
        }
      ]
    },
    "actorUid": {
      "type": "string",
      "minLength": 1,
      "maxLength": 160,
      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
    },
    "recordedAt": {
      "type": "integer",
      "minimum": 0,
      "maximum": 9007199254740991
    }
  },
  "title": "EventAttendanceDispositionDocument",
  "x-firestore-collection": "eventAttendanceDispositions",
  "x-firestore-path": "eventAttendanceDispositions/{dispositionId}",
  "x-document-id-field": "dispositionId",
  "x-owner": "event attendance callables"
} as const;
