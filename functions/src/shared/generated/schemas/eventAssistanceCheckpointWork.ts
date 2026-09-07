/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const eventAssistanceCheckpointWorkSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/operations/event_assistance_checkpoint_work.schema.json",
  "title": "EventAssistanceCheckpointWork",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "schemaVersion",
    "kind",
    "scope",
    "rosterId",
    "rosterHash",
    "request",
    "requestedAt",
    "checkpoint"
  ],
  "properties": {
    "schemaVersion": {
      "const": 1
    },
    "kind": {
      "const": "liveCheckpointReport"
    },
    "scope": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "context",
        "groupId",
        "checkpointId",
        "progressRevision"
      ],
      "properties": {
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
        "groupId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 160,
          "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
        },
        "checkpointId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 2000
        },
        "progressRevision": {
          "type": "integer",
          "minimum": 1,
          "maximum": 9007199254740991
        }
      }
    },
    "rosterId": {
      "type": "string",
      "pattern": "^departure-roster:[a-f0-9]{64}$"
    },
    "rosterHash": {
      "type": "string",
      "pattern": "^[a-f0-9]{64}$"
    },
    "request": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "responsibleOperatorId",
        "dueAt"
      ],
      "properties": {
        "responsibleOperatorId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 128,
          "pattern": "^[^/]+$"
        },
        "dueAt": {
          "type": "integer",
          "minimum": 0,
          "maximum": 9007199254740991
        }
      }
    },
    "requestedAt": {
      "type": "integer",
      "minimum": 0,
      "maximum": 9007199254740991
    },
    "checkpoint": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "dueAt",
        "evaluatedAt",
        "failures",
        "observation"
      ],
      "properties": {
        "dueAt": {
          "anyOf": [
            {
              "type": "integer",
              "minimum": 0,
              "maximum": 9007199254740991
            },
            {
              "type": "null"
            }
          ]
        },
        "evaluatedAt": {
          "anyOf": [
            {
              "type": "integer",
              "minimum": 0,
              "maximum": 9007199254740991
            },
            {
              "type": "null"
            }
          ]
        },
        "failures": {
          "type": "integer",
          "minimum": 0,
          "maximum": 5
        },
        "observation": {
          "anyOf": [
            {
              "oneOf": [
                {
                  "type": "object",
                  "additionalProperties": false,
                  "required": [
                    "kind",
                    "request",
                    "reportRevision",
                    "sourceHash",
                    "ownerValidUntil"
                  ],
                  "properties": {
                    "kind": {
                      "const": "observed"
                    },
                    "request": {
                      "oneOf": [
                        {
                          "type": "object",
                          "additionalProperties": false,
                          "required": [
                            "responsibleOperatorId",
                            "dueAt",
                            "state",
                            "ownerAvailability"
                          ],
                          "properties": {
                            "responsibleOperatorId": {
                              "type": "string",
                              "minLength": 1,
                              "maxLength": 128,
                              "pattern": "^[^/]+$"
                            },
                            "dueAt": {
                              "type": "integer",
                              "minimum": 0,
                              "maximum": 9007199254740991
                            },
                            "state": {
                              "enum": [
                                "awaitingReport",
                                "overdue",
                                "discrepancy",
                                "sourceUnavailable"
                              ]
                            },
                            "ownerAvailability": {
                              "enum": [
                                "current",
                                "needsReassignment"
                              ]
                            }
                          }
                        },
                        {
                          "type": "object",
                          "additionalProperties": false,
                          "required": [
                            "responsibleOperatorId",
                            "dueAt",
                            "state",
                            "ownerAvailability"
                          ],
                          "properties": {
                            "responsibleOperatorId": {
                              "type": "string",
                              "minLength": 1,
                              "maxLength": 128,
                              "pattern": "^[^/]+$"
                            },
                            "dueAt": {
                              "type": "integer",
                              "minimum": 0,
                              "maximum": 9007199254740991
                            },
                            "state": {
                              "const": "complete"
                            },
                            "ownerAvailability": {
                              "const": "notRequired"
                            }
                          }
                        }
                      ]
                    },
                    "reportRevision": {
                      "type": "integer",
                      "minimum": 0,
                      "maximum": 9007199254740991
                    },
                    "sourceHash": {
                      "type": "string",
                      "pattern": "^[a-f0-9]{64}$"
                    },
                    "ownerValidUntil": {
                      "type": "integer",
                      "minimum": 0,
                      "maximum": 9007199254740991
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
                      "const": "unavailable"
                    },
                    "reason": {
                      "const": "factsUnavailable"
                    }
                  }
                }
              ]
            },
            {
              "type": "null"
            }
          ]
        }
      }
    }
  }
} as const;
