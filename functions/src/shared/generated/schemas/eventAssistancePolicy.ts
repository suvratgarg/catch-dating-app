/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const eventAssistancePolicySchema: Record<string, unknown> = {
  "oneOf": [
    {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "kind",
        "version",
        "scope",
        "config",
        "setting"
      ],
      "properties": {
        "kind": {
          "const": "venueReadiness",
          "type": "string"
        },
        "version": {
          "const": 1,
          "type": "integer"
        },
        "scope": {
          "anyOf": [
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "eventId"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "event"
                },
                "eventId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "eventId",
                "attendeeId",
                "episodeId"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "guest"
                },
                "eventId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "attendeeId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "episodeId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "eventId",
                "groupId"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "group"
                },
                "eventId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "groupId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "eventId",
                "resourceId"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "resource"
                },
                "eventId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "resourceId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "eventId",
                "unitId",
                "round"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "unit"
                },
                "eventId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "unitId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 2000
                },
                "round": {
                  "type": "integer",
                  "minimum": 0,
                  "maximum": 10000
                }
              }
            }
          ]
        },
        "config": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "requirement",
            "dueBeforeStartMinutes",
            "disposition"
          ],
          "properties": {
            "requirement": {
              "type": "string",
              "const": "meetingPlace"
            },
            "dueBeforeStartMinutes": {
              "type": "integer",
              "minimum": 0,
              "maximum": 10080
            },
            "disposition": {
              "type": "string",
              "enum": [
                "blockSelectedOperation",
                "hostMayAcceptException"
              ]
            }
          }
        },
        "setting": {
          "anyOf": [
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "authority",
                "policyVersion"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "enabled"
                },
                "authority": {
                  "type": "string",
                  "enum": [
                    "observe",
                    "prepare",
                    "executeWithinPolicy"
                  ]
                },
                "policyVersion": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 2000
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
                  "type": "string",
                  "const": "disabled"
                },
                "reason": {
                  "type": "string",
                  "enum": [
                    "hostChoice",
                    "organizerDefault"
                  ]
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
        "version",
        "scope",
        "config",
        "setting"
      ],
      "properties": {
        "kind": {
          "const": "routeReadiness",
          "type": "string"
        },
        "version": {
          "const": 1,
          "type": "integer"
        },
        "scope": {
          "anyOf": [
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "eventId"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "event"
                },
                "eventId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "eventId",
                "attendeeId",
                "episodeId"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "guest"
                },
                "eventId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "attendeeId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "episodeId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "eventId",
                "groupId"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "group"
                },
                "eventId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "groupId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "eventId",
                "resourceId"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "resource"
                },
                "eventId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "resourceId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "eventId",
                "unitId",
                "round"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "unit"
                },
                "eventId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "unitId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 2000
                },
                "round": {
                  "type": "integer",
                  "minimum": 0,
                  "maximum": 10000
                }
              }
            }
          ]
        },
        "config": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "requirement",
            "dueBeforeStartMinutes",
            "disposition"
          ],
          "properties": {
            "requirement": {
              "type": "string",
              "const": "route"
            },
            "dueBeforeStartMinutes": {
              "type": "integer",
              "minimum": 0,
              "maximum": 10080
            },
            "disposition": {
              "type": "string",
              "enum": [
                "blockSelectedOperation",
                "hostMayAcceptException"
              ]
            }
          }
        },
        "setting": {
          "anyOf": [
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "authority",
                "policyVersion"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "enabled"
                },
                "authority": {
                  "type": "string",
                  "enum": [
                    "observe",
                    "prepare",
                    "executeWithinPolicy"
                  ]
                },
                "policyVersion": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 2000
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
                  "type": "string",
                  "const": "disabled"
                },
                "reason": {
                  "type": "string",
                  "enum": [
                    "hostChoice",
                    "organizerDefault"
                  ]
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
        "version",
        "scope",
        "config",
        "setting"
      ],
      "properties": {
        "kind": {
          "const": "formatReadiness",
          "type": "string"
        },
        "version": {
          "const": 1,
          "type": "integer"
        },
        "scope": {
          "anyOf": [
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "eventId"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "event"
                },
                "eventId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "eventId",
                "attendeeId",
                "episodeId"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "guest"
                },
                "eventId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "attendeeId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "episodeId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "eventId",
                "groupId"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "group"
                },
                "eventId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "groupId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "eventId",
                "resourceId"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "resource"
                },
                "eventId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "resourceId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "eventId",
                "unitId",
                "round"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "unit"
                },
                "eventId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "unitId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 2000
                },
                "round": {
                  "type": "integer",
                  "minimum": 0,
                  "maximum": 10000
                }
              }
            }
          ]
        },
        "config": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "requirement",
            "dueBeforeStartMinutes",
            "disposition"
          ],
          "properties": {
            "requirement": {
              "type": "string",
              "const": "format"
            },
            "dueBeforeStartMinutes": {
              "type": "integer",
              "minimum": 0,
              "maximum": 10080
            },
            "disposition": {
              "type": "string",
              "enum": [
                "blockSelectedOperation",
                "hostMayAcceptException"
              ]
            }
          }
        },
        "setting": {
          "anyOf": [
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "authority",
                "policyVersion"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "enabled"
                },
                "authority": {
                  "type": "string",
                  "enum": [
                    "observe",
                    "prepare",
                    "executeWithinPolicy"
                  ]
                },
                "policyVersion": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 2000
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
                  "type": "string",
                  "const": "disabled"
                },
                "reason": {
                  "type": "string",
                  "enum": [
                    "hostChoice",
                    "organizerDefault"
                  ]
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
        "version",
        "scope",
        "config",
        "setting"
      ],
      "properties": {
        "kind": {
          "const": "rosterReadiness",
          "type": "string"
        },
        "version": {
          "const": 1,
          "type": "integer"
        },
        "scope": {
          "anyOf": [
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "eventId"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "event"
                },
                "eventId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "eventId",
                "attendeeId",
                "episodeId"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "guest"
                },
                "eventId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "attendeeId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "episodeId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "eventId",
                "groupId"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "group"
                },
                "eventId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "groupId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "eventId",
                "resourceId"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "resource"
                },
                "eventId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "resourceId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "eventId",
                "unitId",
                "round"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "unit"
                },
                "eventId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "unitId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 2000
                },
                "round": {
                  "type": "integer",
                  "minimum": 0,
                  "maximum": 10000
                }
              }
            }
          ]
        },
        "config": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "requirement",
            "dueBeforeStartMinutes",
            "disposition"
          ],
          "properties": {
            "requirement": {
              "type": "string",
              "const": "roster"
            },
            "dueBeforeStartMinutes": {
              "type": "integer",
              "minimum": 0,
              "maximum": 10080
            },
            "disposition": {
              "type": "string",
              "enum": [
                "blockSelectedOperation",
                "hostMayAcceptException"
              ]
            }
          }
        },
        "setting": {
          "anyOf": [
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "authority",
                "policyVersion"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "enabled"
                },
                "authority": {
                  "type": "string",
                  "enum": [
                    "observe",
                    "prepare",
                    "executeWithinPolicy"
                  ]
                },
                "policyVersion": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 2000
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
                  "type": "string",
                  "const": "disabled"
                },
                "reason": {
                  "type": "string",
                  "enum": [
                    "hostChoice",
                    "organizerDefault"
                  ]
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
        "version",
        "scope",
        "config",
        "setting"
      ],
      "properties": {
        "kind": {
          "const": "requiredGuestData",
          "type": "string"
        },
        "version": {
          "const": 1,
          "type": "integer"
        },
        "scope": {
          "anyOf": [
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "eventId"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "event"
                },
                "eventId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "eventId",
                "attendeeId",
                "episodeId"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "guest"
                },
                "eventId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "attendeeId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "episodeId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "eventId",
                "groupId"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "group"
                },
                "eventId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "groupId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "eventId",
                "resourceId"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "resource"
                },
                "eventId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "resourceId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "eventId",
                "unitId",
                "round"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "unit"
                },
                "eventId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "unitId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 2000
                },
                "round": {
                  "type": "integer",
                  "minimum": 0,
                  "maximum": 10000
                }
              }
            }
          ]
        },
        "config": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "requirement",
            "dueBeforeStartMinutes",
            "disposition"
          ],
          "properties": {
            "requirement": {
              "type": "string",
              "const": "guestData"
            },
            "dueBeforeStartMinutes": {
              "type": "integer",
              "minimum": 0,
              "maximum": 10080
            },
            "disposition": {
              "type": "string",
              "enum": [
                "blockSelectedOperation",
                "hostMayAcceptException"
              ]
            }
          }
        },
        "setting": {
          "anyOf": [
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "authority",
                "policyVersion"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "enabled"
                },
                "authority": {
                  "type": "string",
                  "enum": [
                    "observe",
                    "prepare",
                    "executeWithinPolicy"
                  ]
                },
                "policyVersion": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 2000
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
                  "type": "string",
                  "const": "disabled"
                },
                "reason": {
                  "type": "string",
                  "enum": [
                    "hostChoice",
                    "organizerDefault"
                  ]
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
        "version",
        "scope",
        "config",
        "setting"
      ],
      "properties": {
        "kind": {
          "const": "resourceReadiness",
          "type": "string"
        },
        "version": {
          "const": 1,
          "type": "integer"
        },
        "scope": {
          "anyOf": [
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "eventId"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "event"
                },
                "eventId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "eventId",
                "attendeeId",
                "episodeId"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "guest"
                },
                "eventId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "attendeeId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "episodeId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "eventId",
                "groupId"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "group"
                },
                "eventId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "groupId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "eventId",
                "resourceId"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "resource"
                },
                "eventId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "resourceId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "eventId",
                "unitId",
                "round"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "unit"
                },
                "eventId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "unitId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 2000
                },
                "round": {
                  "type": "integer",
                  "minimum": 0,
                  "maximum": 10000
                }
              }
            }
          ]
        },
        "config": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "requirement",
            "dueBeforeStartMinutes",
            "disposition"
          ],
          "properties": {
            "requirement": {
              "type": "string",
              "const": "resources"
            },
            "dueBeforeStartMinutes": {
              "type": "integer",
              "minimum": 0,
              "maximum": 10080
            },
            "disposition": {
              "type": "string",
              "enum": [
                "blockSelectedOperation",
                "hostMayAcceptException"
              ]
            }
          }
        },
        "setting": {
          "anyOf": [
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "authority",
                "policyVersion"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "enabled"
                },
                "authority": {
                  "type": "string",
                  "enum": [
                    "observe",
                    "prepare",
                    "executeWithinPolicy"
                  ]
                },
                "policyVersion": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 2000
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
                  "type": "string",
                  "const": "disabled"
                },
                "reason": {
                  "type": "string",
                  "enum": [
                    "hostChoice",
                    "organizerDefault"
                  ]
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
        "version",
        "scope",
        "config",
        "setting"
      ],
      "properties": {
        "kind": {
          "const": "staffingReadiness",
          "type": "string"
        },
        "version": {
          "const": 1,
          "type": "integer"
        },
        "scope": {
          "anyOf": [
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "eventId"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "event"
                },
                "eventId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "eventId",
                "attendeeId",
                "episodeId"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "guest"
                },
                "eventId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "attendeeId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "episodeId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "eventId",
                "groupId"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "group"
                },
                "eventId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "groupId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "eventId",
                "resourceId"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "resource"
                },
                "eventId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "resourceId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "eventId",
                "unitId",
                "round"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "unit"
                },
                "eventId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "unitId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 2000
                },
                "round": {
                  "type": "integer",
                  "minimum": 0,
                  "maximum": 10000
                }
              }
            }
          ]
        },
        "config": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "requirement",
            "dueBeforeStartMinutes",
            "disposition"
          ],
          "properties": {
            "requirement": {
              "type": "string",
              "const": "responsibilities"
            },
            "dueBeforeStartMinutes": {
              "type": "integer",
              "minimum": 0,
              "maximum": 10080
            },
            "disposition": {
              "type": "string",
              "enum": [
                "blockSelectedOperation",
                "hostMayAcceptException"
              ]
            }
          }
        },
        "setting": {
          "anyOf": [
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "authority",
                "policyVersion"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "enabled"
                },
                "authority": {
                  "type": "string",
                  "enum": [
                    "observe",
                    "prepare",
                    "executeWithinPolicy"
                  ]
                },
                "policyVersion": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 2000
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
                  "type": "string",
                  "const": "disabled"
                },
                "reason": {
                  "type": "string",
                  "enum": [
                    "hostChoice",
                    "organizerDefault"
                  ]
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
        "version",
        "scope",
        "config",
        "setting"
      ],
      "properties": {
        "kind": {
          "const": "messagingReadiness",
          "type": "string"
        },
        "version": {
          "const": 1,
          "type": "integer"
        },
        "scope": {
          "anyOf": [
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "eventId"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "event"
                },
                "eventId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "eventId",
                "attendeeId",
                "episodeId"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "guest"
                },
                "eventId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "attendeeId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "episodeId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "eventId",
                "groupId"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "group"
                },
                "eventId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "groupId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "eventId",
                "resourceId"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "resource"
                },
                "eventId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "resourceId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "eventId",
                "unitId",
                "round"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "unit"
                },
                "eventId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "unitId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 2000
                },
                "round": {
                  "type": "integer",
                  "minimum": 0,
                  "maximum": 10000
                }
              }
            }
          ]
        },
        "config": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "requirement",
            "dueBeforeStartMinutes",
            "disposition"
          ],
          "properties": {
            "requirement": {
              "type": "string",
              "const": "messaging"
            },
            "dueBeforeStartMinutes": {
              "type": "integer",
              "minimum": 0,
              "maximum": 10080
            },
            "disposition": {
              "type": "string",
              "enum": [
                "blockSelectedOperation",
                "hostMayAcceptException"
              ]
            }
          }
        },
        "setting": {
          "anyOf": [
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "authority",
                "policyVersion"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "enabled"
                },
                "authority": {
                  "type": "string",
                  "enum": [
                    "observe",
                    "prepare",
                    "executeWithinPolicy"
                  ]
                },
                "policyVersion": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 2000
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
                  "type": "string",
                  "const": "disabled"
                },
                "reason": {
                  "type": "string",
                  "enum": [
                    "hostChoice",
                    "organizerDefault"
                  ]
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
        "version",
        "scope",
        "config",
        "setting"
      ],
      "properties": {
        "kind": {
          "const": "admissionReview",
          "type": "string"
        },
        "version": {
          "const": 1,
          "type": "integer"
        },
        "scope": {
          "anyOf": [
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "eventId"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "event"
                },
                "eventId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "eventId",
                "attendeeId",
                "episodeId"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "guest"
                },
                "eventId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "attendeeId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "episodeId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "eventId",
                "groupId"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "group"
                },
                "eventId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "groupId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "eventId",
                "resourceId"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "resource"
                },
                "eventId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "resourceId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "eventId",
                "unitId",
                "round"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "unit"
                },
                "eventId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "unitId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 2000
                },
                "round": {
                  "type": "integer",
                  "minimum": 0,
                  "maximum": 10000
                }
              }
            }
          ]
        },
        "config": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "offerExpiryMinutes",
            "admission",
            "releaseCapacity"
          ],
          "properties": {
            "offerExpiryMinutes": {
              "type": "integer",
              "minimum": 0,
              "maximum": 10080
            },
            "admission": {
              "type": "string",
              "const": "existingEntitlementPolicy"
            },
            "releaseCapacity": {
              "type": "string",
              "const": "confirmedOnly"
            }
          }
        },
        "setting": {
          "anyOf": [
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "authority",
                "policyVersion"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "enabled"
                },
                "authority": {
                  "type": "string",
                  "enum": [
                    "observe",
                    "prepare",
                    "executeWithinPolicy"
                  ]
                },
                "policyVersion": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 2000
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
                  "type": "string",
                  "const": "disabled"
                },
                "reason": {
                  "type": "string",
                  "enum": [
                    "hostChoice",
                    "organizerDefault"
                  ]
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
        "version",
        "scope",
        "config",
        "setting"
      ],
      "properties": {
        "kind": {
          "const": "financialReadiness",
          "type": "string"
        },
        "version": {
          "const": 1,
          "type": "integer"
        },
        "scope": {
          "anyOf": [
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "eventId"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "event"
                },
                "eventId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "eventId",
                "attendeeId",
                "episodeId"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "guest"
                },
                "eventId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "attendeeId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "episodeId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "eventId",
                "groupId"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "group"
                },
                "eventId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "groupId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "eventId",
                "resourceId"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "resource"
                },
                "eventId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "resourceId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "eventId",
                "unitId",
                "round"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "unit"
                },
                "eventId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "unitId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 2000
                },
                "round": {
                  "type": "integer",
                  "minimum": 0,
                  "maximum": 10000
                }
              }
            }
          ]
        },
        "config": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "requirement",
            "dueBeforeStartMinutes",
            "disposition"
          ],
          "properties": {
            "requirement": {
              "type": "string",
              "const": "paymentProvider"
            },
            "dueBeforeStartMinutes": {
              "type": "integer",
              "minimum": 0,
              "maximum": 10080
            },
            "disposition": {
              "type": "string",
              "enum": [
                "blockSelectedOperation",
                "hostMayAcceptException"
              ]
            }
          }
        },
        "setting": {
          "anyOf": [
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "authority",
                "policyVersion"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "enabled"
                },
                "authority": {
                  "type": "string",
                  "enum": [
                    "observe",
                    "prepare",
                    "executeWithinPolicy"
                  ]
                },
                "policyVersion": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 2000
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
                  "type": "string",
                  "const": "disabled"
                },
                "reason": {
                  "type": "string",
                  "enum": [
                    "hostChoice",
                    "organizerDefault"
                  ]
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
        "version",
        "scope",
        "config",
        "setting"
      ],
      "properties": {
        "kind": {
          "const": "joiningInstructions",
          "type": "string"
        },
        "version": {
          "const": 1,
          "type": "integer"
        },
        "scope": {
          "anyOf": [
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "eventId"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "event"
                },
                "eventId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "eventId",
                "attendeeId",
                "episodeId"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "guest"
                },
                "eventId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "attendeeId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "episodeId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "eventId",
                "groupId"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "group"
                },
                "eventId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "groupId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "eventId",
                "resourceId"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "resource"
                },
                "eventId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "resourceId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "eventId",
                "unitId",
                "round"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "unit"
                },
                "eventId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "unitId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 2000
                },
                "round": {
                  "type": "integer",
                  "minimum": 0,
                  "maximum": 10000
                }
              }
            }
          ]
        },
        "config": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "templateIntent",
            "audience",
            "maximumPerGuest",
            "expiryMinutes"
          ],
          "properties": {
            "templateIntent": {
              "type": "string",
              "const": "joining"
            },
            "audience": {
              "type": "string",
              "const": "affectedGuests"
            },
            "maximumPerGuest": {
              "type": "integer",
              "minimum": 0,
              "maximum": 10080
            },
            "expiryMinutes": {
              "type": "integer",
              "minimum": 0,
              "maximum": 10080
            }
          }
        },
        "setting": {
          "anyOf": [
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "authority",
                "policyVersion"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "enabled"
                },
                "authority": {
                  "type": "string",
                  "enum": [
                    "observe",
                    "prepare",
                    "executeWithinPolicy"
                  ]
                },
                "policyVersion": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 2000
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
                  "type": "string",
                  "const": "disabled"
                },
                "reason": {
                  "type": "string",
                  "enum": [
                    "hostChoice",
                    "organizerDefault"
                  ]
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
        "version",
        "scope",
        "config",
        "setting"
      ],
      "properties": {
        "kind": {
          "const": "identityResolution",
          "type": "string"
        },
        "version": {
          "const": 1,
          "type": "integer"
        },
        "scope": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "kind",
            "eventId",
            "attendeeId",
            "episodeId"
          ],
          "properties": {
            "kind": {
              "type": "string",
              "const": "guest"
            },
            "eventId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 160,
              "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
            },
            "attendeeId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 160,
              "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
            },
            "episodeId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 160,
              "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
            }
          }
        },
        "config": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "ambiguousIdentity",
            "fallback"
          ],
          "properties": {
            "ambiguousIdentity": {
              "type": "string",
              "const": "humanResolution"
            },
            "fallback": {
              "type": "string",
              "const": "hostAssistedOperationalOnly"
            }
          }
        },
        "setting": {
          "anyOf": [
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "authority",
                "policyVersion"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "enabled"
                },
                "authority": {
                  "type": "string",
                  "enum": [
                    "observe",
                    "prepare",
                    "executeWithinPolicy"
                  ]
                },
                "policyVersion": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 2000
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
                  "type": "string",
                  "const": "disabled"
                },
                "reason": {
                  "type": "string",
                  "enum": [
                    "hostChoice",
                    "organizerDefault"
                  ]
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
        "version",
        "scope",
        "config",
        "setting"
      ],
      "properties": {
        "kind": {
          "const": "guestAdmission",
          "type": "string"
        },
        "version": {
          "const": 1,
          "type": "integer"
        },
        "scope": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "kind",
            "eventId",
            "attendeeId",
            "episodeId"
          ],
          "properties": {
            "kind": {
              "type": "string",
              "const": "guest"
            },
            "eventId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 160,
              "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
            },
            "attendeeId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 160,
              "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
            },
            "episodeId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 160,
              "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
            }
          }
        },
        "config": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "admission",
            "overCapacity",
            "exception"
          ],
          "properties": {
            "admission": {
              "type": "string",
              "const": "existingEntitlementPolicy"
            },
            "overCapacity": {
              "type": "string",
              "const": "deny"
            },
            "exception": {
              "type": "string",
              "const": "authorizedHost"
            }
          }
        },
        "setting": {
          "anyOf": [
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "authority",
                "policyVersion"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "enabled"
                },
                "authority": {
                  "type": "string",
                  "enum": [
                    "observe",
                    "prepare",
                    "executeWithinPolicy"
                  ]
                },
                "policyVersion": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 2000
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
                  "type": "string",
                  "const": "disabled"
                },
                "reason": {
                  "type": "string",
                  "enum": [
                    "hostChoice",
                    "organizerDefault"
                  ]
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
        "version",
        "scope",
        "config",
        "setting"
      ],
      "properties": {
        "kind": {
          "const": "guestCheckIn",
          "type": "string"
        },
        "version": {
          "const": 1,
          "type": "integer"
        },
        "scope": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "kind",
            "eventId",
            "attendeeId",
            "episodeId"
          ],
          "properties": {
            "kind": {
              "type": "string",
              "const": "guest"
            },
            "eventId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 160,
              "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
            },
            "attendeeId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 160,
              "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
            },
            "episodeId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 160,
              "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
            }
          }
        },
        "config": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "operation",
            "conflict",
            "attendanceProof"
          ],
          "properties": {
            "operation": {
              "type": "string",
              "const": "absolute"
            },
            "conflict": {
              "type": "string",
              "const": "revisionFence"
            },
            "attendanceProof": {
              "type": "string",
              "const": "configuredEventPolicy"
            }
          }
        },
        "setting": {
          "anyOf": [
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "authority",
                "policyVersion"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "enabled"
                },
                "authority": {
                  "type": "string",
                  "enum": [
                    "observe",
                    "prepare",
                    "executeWithinPolicy"
                  ]
                },
                "policyVersion": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 2000
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
                  "type": "string",
                  "const": "disabled"
                },
                "reason": {
                  "type": "string",
                  "enum": [
                    "hostChoice",
                    "organizerDefault"
                  ]
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
        "version",
        "scope",
        "config",
        "setting"
      ],
      "properties": {
        "kind": {
          "const": "lateJoin",
          "type": "string"
        },
        "version": {
          "const": 1,
          "type": "integer"
        },
        "scope": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "kind",
            "eventId",
            "attendeeId",
            "episodeId"
          ],
          "properties": {
            "kind": {
              "type": "string",
              "const": "guest"
            },
            "eventId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 160,
              "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
            },
            "attendeeId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 160,
              "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
            },
            "episodeId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 160,
              "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
            }
          }
        },
        "config": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "destination",
            "cutoff",
            "maxMessagesPerEpisode",
            "minimumMinutesBetweenMessages",
            "updateOn",
            "unanswered"
          ],
          "properties": {
            "destination": {
              "anyOf": [
                {
                  "type": "object",
                  "additionalProperties": false,
                  "required": [
                    "kind",
                    "placeId",
                    "lateEntry"
                  ],
                  "properties": {
                    "kind": {
                      "type": "string",
                      "const": "fixedPlace"
                    },
                    "placeId": {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 160,
                      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                    },
                    "lateEntry": {
                      "type": "string",
                      "enum": [
                        "allowed",
                        "hostDecision",
                        "closed"
                      ]
                    }
                  }
                },
                {
                  "type": "object",
                  "additionalProperties": false,
                  "required": [
                    "kind",
                    "itineraryId",
                    "permittedStopIds"
                  ],
                  "properties": {
                    "kind": {
                      "type": "string",
                      "const": "itineraryStop"
                    },
                    "itineraryId": {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 2000
                    },
                    "permittedStopIds": {
                      "type": "array",
                      "minItems": 1,
                      "maxItems": 1000,
                      "items": {
                        "type": "string",
                        "minLength": 1,
                        "maxLength": 2000
                      },
                      "uniqueItems": true
                    }
                  }
                },
                {
                  "type": "object",
                  "additionalProperties": false,
                  "required": [
                    "kind",
                    "routeId",
                    "groupId",
                    "permittedCheckpointIds"
                  ],
                  "properties": {
                    "kind": {
                      "type": "string",
                      "const": "groupCheckpoint"
                    },
                    "routeId": {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 2000
                    },
                    "groupId": {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 160,
                      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                    },
                    "permittedCheckpointIds": {
                      "type": "array",
                      "minItems": 1,
                      "maxItems": 1000,
                      "items": {
                        "type": "string",
                        "minLength": 1,
                        "maxLength": 2000
                      },
                      "uniqueItems": true
                    }
                  }
                }
              ]
            },
            "cutoff": {
              "anyOf": [
                {
                  "type": "object",
                  "additionalProperties": false,
                  "required": [
                    "kind"
                  ],
                  "properties": {
                    "kind": {
                      "type": "string",
                      "const": "eventEnd"
                    }
                  }
                },
                {
                  "type": "object",
                  "additionalProperties": false,
                  "required": [
                    "kind",
                    "at"
                  ],
                  "properties": {
                    "kind": {
                      "type": "string",
                      "const": "time"
                    },
                    "at": {
                      "type": "integer",
                      "minimum": 0,
                      "maximum": 9007199254740991,
                      "description": "UTC milliseconds."
                    }
                  }
                }
              ]
            },
            "maxMessagesPerEpisode": {
              "type": "integer",
              "minimum": 0,
              "maximum": 100
            },
            "minimumMinutesBetweenMessages": {
              "type": "integer",
              "minimum": 0,
              "maximum": 1440
            },
            "updateOn": {
              "type": "string",
              "const": "materialGuidanceChange"
            },
            "unanswered": {
              "type": "string",
              "enum": [
                "keepUnknownUntilCutoff",
                "hostReviewAtDeadline"
              ]
            }
          }
        },
        "setting": {
          "anyOf": [
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "authority",
                "policyVersion"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "enabled"
                },
                "authority": {
                  "type": "string",
                  "enum": [
                    "observe",
                    "prepare",
                    "executeWithinPolicy"
                  ]
                },
                "policyVersion": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 2000
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
                  "type": "string",
                  "const": "disabled"
                },
                "reason": {
                  "type": "string",
                  "enum": [
                    "hostChoice",
                    "organizerDefault"
                  ]
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
        "version",
        "scope",
        "config",
        "setting"
      ],
      "properties": {
        "kind": {
          "const": "participationChange",
          "type": "string"
        },
        "version": {
          "const": 1,
          "type": "integer"
        },
        "scope": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "kind",
            "eventId",
            "attendeeId",
            "episodeId"
          ],
          "properties": {
            "kind": {
              "type": "string",
              "const": "guest"
            },
            "eventId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 160,
              "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
            },
            "attendeeId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 160,
              "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
            },
            "episodeId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 160,
              "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
            }
          }
        },
        "config": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "eligibility",
            "reentry",
            "guestOptOut"
          ],
          "properties": {
            "eligibility": {
              "type": "string",
              "const": "explicitParticipation"
            },
            "reentry": {
              "type": "string",
              "const": "newEpisode"
            },
            "guestOptOut": {
              "type": "string",
              "const": "honor"
            }
          }
        },
        "setting": {
          "anyOf": [
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "authority",
                "policyVersion"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "enabled"
                },
                "authority": {
                  "type": "string",
                  "enum": [
                    "observe",
                    "prepare",
                    "executeWithinPolicy"
                  ]
                },
                "policyVersion": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 2000
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
                  "type": "string",
                  "const": "disabled"
                },
                "reason": {
                  "type": "string",
                  "enum": [
                    "hostChoice",
                    "organizerDefault"
                  ]
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
        "version",
        "scope",
        "config",
        "setting"
      ],
      "properties": {
        "kind": {
          "const": "guestPrerequisite",
          "type": "string"
        },
        "version": {
          "const": 1,
          "type": "integer"
        },
        "scope": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "kind",
            "eventId",
            "attendeeId",
            "episodeId"
          ],
          "properties": {
            "kind": {
              "type": "string",
              "const": "guest"
            },
            "eventId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 160,
              "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
            },
            "attendeeId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 160,
              "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
            },
            "episodeId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 160,
              "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
            }
          }
        },
        "config": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "requirementsFrom",
            "fallback"
          ],
          "properties": {
            "requirementsFrom": {
              "type": "string",
              "const": "selectedCapabilities"
            },
            "fallback": {
              "type": "string",
              "const": "explicitlySupportedOnly"
            }
          }
        },
        "setting": {
          "anyOf": [
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "authority",
                "policyVersion"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "enabled"
                },
                "authority": {
                  "type": "string",
                  "enum": [
                    "observe",
                    "prepare",
                    "executeWithinPolicy"
                  ]
                },
                "policyVersion": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 2000
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
                  "type": "string",
                  "const": "disabled"
                },
                "reason": {
                  "type": "string",
                  "enum": [
                    "hostChoice",
                    "organizerDefault"
                  ]
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
        "version",
        "scope",
        "config",
        "setting"
      ],
      "properties": {
        "kind": {
          "const": "allocationRepair",
          "type": "string"
        },
        "version": {
          "const": 1,
          "type": "integer"
        },
        "scope": {
          "anyOf": [
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "eventId"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "event"
                },
                "eventId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "eventId",
                "attendeeId",
                "episodeId"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "guest"
                },
                "eventId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "attendeeId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "episodeId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "eventId",
                "groupId"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "group"
                },
                "eventId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "groupId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "eventId",
                "resourceId"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "resource"
                },
                "eventId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "resourceId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "eventId",
                "unitId",
                "round"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "unit"
                },
                "eventId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "unitId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 2000
                },
                "round": {
                  "type": "integer",
                  "minimum": 0,
                  "maximum": 10000
                }
              }
            }
          ]
        },
        "config": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "scope",
            "publication",
            "preserveCompleted",
            "hardConstraints"
          ],
          "properties": {
            "scope": {
              "type": "string",
              "const": "futureOnly"
            },
            "publication": {
              "type": "string",
              "const": "hostConfirmed"
            },
            "preserveCompleted": {
              "type": "boolean",
              "const": true
            },
            "hardConstraints": {
              "type": "string",
              "const": "neverRelax"
            }
          }
        },
        "setting": {
          "anyOf": [
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "authority",
                "policyVersion"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "enabled"
                },
                "authority": {
                  "type": "string",
                  "enum": [
                    "observe",
                    "prepare",
                    "executeWithinPolicy"
                  ]
                },
                "policyVersion": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 2000
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
                  "type": "string",
                  "const": "disabled"
                },
                "reason": {
                  "type": "string",
                  "enum": [
                    "hostChoice",
                    "organizerDefault"
                  ]
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
        "version",
        "scope",
        "config",
        "setting"
      ],
      "properties": {
        "kind": {
          "const": "placementConfirmation",
          "type": "string"
        },
        "version": {
          "const": 1,
          "type": "integer"
        },
        "scope": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "kind",
            "eventId",
            "attendeeId",
            "episodeId"
          ],
          "properties": {
            "kind": {
              "type": "string",
              "const": "guest"
            },
            "eventId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 160,
              "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
            },
            "attendeeId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 160,
              "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
            },
            "episodeId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 160,
              "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
            }
          }
        },
        "config": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "observation",
            "assignmentIsNotObservation"
          ],
          "properties": {
            "observation": {
              "type": "string",
              "const": "explicitHost"
            },
            "assignmentIsNotObservation": {
              "type": "boolean",
              "const": true
            }
          }
        },
        "setting": {
          "anyOf": [
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "authority",
                "policyVersion"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "enabled"
                },
                "authority": {
                  "type": "string",
                  "enum": [
                    "observe",
                    "prepare",
                    "executeWithinPolicy"
                  ]
                },
                "policyVersion": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 2000
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
                  "type": "string",
                  "const": "disabled"
                },
                "reason": {
                  "type": "string",
                  "enum": [
                    "hostChoice",
                    "organizerDefault"
                  ]
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
        "version",
        "scope",
        "config",
        "setting"
      ],
      "properties": {
        "kind": {
          "const": "resourceRecovery",
          "type": "string"
        },
        "version": {
          "const": 1,
          "type": "integer"
        },
        "scope": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "kind",
            "eventId",
            "resourceId"
          ],
          "properties": {
            "kind": {
              "type": "string",
              "const": "resource"
            },
            "eventId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 160,
              "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
            },
            "resourceId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 160,
              "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
            }
          }
        },
        "config": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "scope",
            "publication",
            "preserveCompleted",
            "hardConstraints",
            "resourceChange"
          ],
          "properties": {
            "scope": {
              "type": "string",
              "const": "futureOnly"
            },
            "publication": {
              "type": "string",
              "const": "hostConfirmed"
            },
            "preserveCompleted": {
              "type": "boolean",
              "const": true
            },
            "hardConstraints": {
              "type": "string",
              "const": "neverRelax"
            },
            "resourceChange": {
              "type": "string",
              "const": "hostConfirmed"
            }
          }
        },
        "setting": {
          "anyOf": [
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "authority",
                "policyVersion"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "enabled"
                },
                "authority": {
                  "type": "string",
                  "enum": [
                    "observe",
                    "prepare",
                    "executeWithinPolicy"
                  ]
                },
                "policyVersion": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 2000
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
                  "type": "string",
                  "const": "disabled"
                },
                "reason": {
                  "type": "string",
                  "enum": [
                    "hostChoice",
                    "organizerDefault"
                  ]
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
        "version",
        "scope",
        "config",
        "setting"
      ],
      "properties": {
        "kind": {
          "const": "fairParticipation",
          "type": "string"
        },
        "version": {
          "const": 1,
          "type": "integer"
        },
        "scope": {
          "anyOf": [
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "eventId"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "event"
                },
                "eventId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "eventId",
                "attendeeId",
                "episodeId"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "guest"
                },
                "eventId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "attendeeId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "episodeId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "eventId",
                "groupId"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "group"
                },
                "eventId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "groupId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "eventId",
                "resourceId"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "resource"
                },
                "eventId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "resourceId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "eventId",
                "unitId",
                "round"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "unit"
                },
                "eventId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "unitId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 2000
                },
                "round": {
                  "type": "integer",
                  "minimum": 0,
                  "maximum": 10000
                }
              }
            }
          ]
        },
        "config": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "objective",
            "hardConstraints",
            "publication"
          ],
          "properties": {
            "objective": {
              "type": "string",
              "const": "minimizeRepeatedExclusion"
            },
            "hardConstraints": {
              "type": "string",
              "const": "neverRelax"
            },
            "publication": {
              "type": "string",
              "const": "hostConfirmed"
            }
          }
        },
        "setting": {
          "anyOf": [
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "authority",
                "policyVersion"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "enabled"
                },
                "authority": {
                  "type": "string",
                  "enum": [
                    "observe",
                    "prepare",
                    "executeWithinPolicy"
                  ]
                },
                "policyVersion": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 2000
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
                  "type": "string",
                  "const": "disabled"
                },
                "reason": {
                  "type": "string",
                  "enum": [
                    "hostChoice",
                    "organizerDefault"
                  ]
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
        "version",
        "scope",
        "config",
        "setting"
      ],
      "properties": {
        "kind": {
          "const": "roundPublication",
          "type": "string"
        },
        "version": {
          "const": 1,
          "type": "integer"
        },
        "scope": {
          "anyOf": [
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "eventId"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "event"
                },
                "eventId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "eventId",
                "attendeeId",
                "episodeId"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "guest"
                },
                "eventId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "attendeeId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "episodeId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "eventId",
                "groupId"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "group"
                },
                "eventId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "groupId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "eventId",
                "resourceId"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "resource"
                },
                "eventId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "resourceId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "eventId",
                "unitId",
                "round"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "unit"
                },
                "eventId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "unitId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 2000
                },
                "round": {
                  "type": "integer",
                  "minimum": 0,
                  "maximum": 10000
                }
              }
            }
          ]
        },
        "config": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "futureDrafts",
            "publication",
            "publishedHistory"
          ],
          "properties": {
            "futureDrafts": {
              "type": "string",
              "const": "private"
            },
            "publication": {
              "type": "string",
              "const": "hostConfirmed"
            },
            "publishedHistory": {
              "type": "string",
              "const": "immutableWithCorrections"
            }
          }
        },
        "setting": {
          "anyOf": [
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "authority",
                "policyVersion"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "enabled"
                },
                "authority": {
                  "type": "string",
                  "enum": [
                    "observe",
                    "prepare",
                    "executeWithinPolicy"
                  ]
                },
                "policyVersion": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 2000
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
                  "type": "string",
                  "const": "disabled"
                },
                "reason": {
                  "type": "string",
                  "enum": [
                    "hostChoice",
                    "organizerDefault"
                  ]
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
        "version",
        "scope",
        "config",
        "setting"
      ],
      "properties": {
        "kind": {
          "const": "unitProgress",
          "type": "string"
        },
        "version": {
          "const": 1,
          "type": "integer"
        },
        "scope": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "kind",
            "eventId",
            "unitId",
            "round"
          ],
          "properties": {
            "kind": {
              "type": "string",
              "const": "unit"
            },
            "eventId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 160,
              "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
            },
            "unitId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 2000
            },
            "round": {
              "type": "integer",
              "minimum": 0,
              "maximum": 10000
            }
          }
        },
        "config": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "clock",
            "progress",
            "completedResults"
          ],
          "properties": {
            "clock": {
              "type": "string",
              "const": "perUnit"
            },
            "progress": {
              "type": "string",
              "const": "hostConfirmed"
            },
            "completedResults": {
              "type": "string",
              "const": "preserve"
            }
          }
        },
        "setting": {
          "anyOf": [
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "authority",
                "policyVersion"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "enabled"
                },
                "authority": {
                  "type": "string",
                  "enum": [
                    "observe",
                    "prepare",
                    "executeWithinPolicy"
                  ]
                },
                "policyVersion": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 2000
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
                  "type": "string",
                  "const": "disabled"
                },
                "reason": {
                  "type": "string",
                  "enum": [
                    "hostChoice",
                    "organizerDefault"
                  ]
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
        "version",
        "scope",
        "config",
        "setting"
      ],
      "properties": {
        "kind": {
          "const": "outcomeRecording",
          "type": "string"
        },
        "version": {
          "const": 1,
          "type": "integer"
        },
        "scope": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "kind",
            "eventId",
            "unitId",
            "round"
          ],
          "properties": {
            "kind": {
              "type": "string",
              "const": "unit"
            },
            "eventId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 160,
              "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
            },
            "unitId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 2000
            },
            "round": {
              "type": "integer",
              "minimum": 0,
              "maximum": 10000
            }
          }
        },
        "config": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "kind",
            "correction",
            "publication"
          ],
          "properties": {
            "kind": {
              "type": "string",
              "enum": [
                "completion",
                "score",
                "rank"
              ]
            },
            "correction": {
              "type": "string",
              "const": "revisionedFullRound"
            },
            "publication": {
              "type": "string",
              "const": "existingRevealGate"
            }
          }
        },
        "setting": {
          "anyOf": [
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "authority",
                "policyVersion"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "enabled"
                },
                "authority": {
                  "type": "string",
                  "enum": [
                    "observe",
                    "prepare",
                    "executeWithinPolicy"
                  ]
                },
                "policyVersion": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 2000
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
                  "type": "string",
                  "const": "disabled"
                },
                "reason": {
                  "type": "string",
                  "enum": [
                    "hostChoice",
                    "organizerDefault"
                  ]
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
        "version",
        "scope",
        "config",
        "setting"
      ],
      "properties": {
        "kind": {
          "const": "programmeRecovery",
          "type": "string"
        },
        "version": {
          "const": 1,
          "type": "integer"
        },
        "scope": {
          "anyOf": [
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "eventId"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "event"
                },
                "eventId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "eventId",
                "attendeeId",
                "episodeId"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "guest"
                },
                "eventId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "attendeeId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "episodeId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "eventId",
                "groupId"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "group"
                },
                "eventId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "groupId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "eventId",
                "resourceId"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "resource"
                },
                "eventId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "resourceId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "eventId",
                "unitId",
                "round"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "unit"
                },
                "eventId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "unitId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 2000
                },
                "round": {
                  "type": "integer",
                  "minimum": 0,
                  "maximum": 10000
                }
              }
            }
          ]
        },
        "config": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "scope",
            "publication",
            "alreadyPublished"
          ],
          "properties": {
            "scope": {
              "type": "string",
              "const": "remainingProgramme"
            },
            "publication": {
              "type": "string",
              "const": "hostConfirmed"
            },
            "alreadyPublished": {
              "type": "string",
              "const": "correctExplicitly"
            }
          }
        },
        "setting": {
          "anyOf": [
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "authority",
                "policyVersion"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "enabled"
                },
                "authority": {
                  "type": "string",
                  "enum": [
                    "observe",
                    "prepare",
                    "executeWithinPolicy"
                  ]
                },
                "policyVersion": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 2000
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
                  "type": "string",
                  "const": "disabled"
                },
                "reason": {
                  "type": "string",
                  "enum": [
                    "hostChoice",
                    "organizerDefault"
                  ]
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
        "version",
        "scope",
        "config",
        "setting"
      ],
      "properties": {
        "kind": {
          "const": "departure",
          "type": "string"
        },
        "version": {
          "const": 1,
          "type": "integer"
        },
        "scope": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "kind",
            "eventId",
            "groupId"
          ],
          "properties": {
            "kind": {
              "type": "string",
              "const": "group"
            },
            "eventId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 160,
              "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
            },
            "groupId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 160,
              "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
            }
          }
        },
        "config": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "confirmation",
            "scope",
            "plannedTimeIsNotProof"
          ],
          "properties": {
            "confirmation": {
              "type": "string",
              "const": "responsibleOperator"
            },
            "scope": {
              "type": "string",
              "const": "perMovingGroup"
            },
            "plannedTimeIsNotProof": {
              "type": "boolean",
              "const": true
            }
          }
        },
        "setting": {
          "anyOf": [
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "authority",
                "policyVersion"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "enabled"
                },
                "authority": {
                  "type": "string",
                  "enum": [
                    "observe",
                    "prepare",
                    "executeWithinPolicy"
                  ]
                },
                "policyVersion": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 2000
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
                  "type": "string",
                  "const": "disabled"
                },
                "reason": {
                  "type": "string",
                  "enum": [
                    "hostChoice",
                    "organizerDefault"
                  ]
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
        "version",
        "scope",
        "config",
        "setting"
      ],
      "properties": {
        "kind": {
          "const": "checkpoint",
          "type": "string"
        },
        "version": {
          "const": 1,
          "type": "integer"
        },
        "scope": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "kind",
            "eventId",
            "groupId"
          ],
          "properties": {
            "kind": {
              "type": "string",
              "const": "group"
            },
            "eventId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 160,
              "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
            },
            "groupId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 160,
              "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
            }
          }
        },
        "config": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "reportBy",
            "scope",
            "reportDeadlineMinutes"
          ],
          "properties": {
            "reportBy": {
              "type": "string",
              "const": "responsibleOperator"
            },
            "scope": {
              "type": "string",
              "const": "departureRoster"
            },
            "reportDeadlineMinutes": {
              "type": "integer",
              "minimum": 0,
              "maximum": 10080
            }
          }
        },
        "setting": {
          "anyOf": [
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "authority",
                "policyVersion"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "enabled"
                },
                "authority": {
                  "type": "string",
                  "enum": [
                    "observe",
                    "prepare",
                    "executeWithinPolicy"
                  ]
                },
                "policyVersion": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 2000
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
                  "type": "string",
                  "const": "disabled"
                },
                "reason": {
                  "type": "string",
                  "enum": [
                    "hostChoice",
                    "organizerDefault"
                  ]
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
        "version",
        "scope",
        "config",
        "setting"
      ],
      "properties": {
        "kind": {
          "const": "groupTransfer",
          "type": "string"
        },
        "version": {
          "const": 1,
          "type": "integer"
        },
        "scope": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "kind",
            "eventId",
            "groupId"
          ],
          "properties": {
            "kind": {
              "type": "string",
              "const": "group"
            },
            "eventId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 160,
              "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
            },
            "groupId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 160,
              "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
            }
          }
        },
        "config": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "handover",
            "membership"
          ],
          "properties": {
            "handover": {
              "type": "string",
              "const": "receivingOperatorAcknowledges"
            },
            "membership": {
              "type": "string",
              "const": "singleActiveGroup"
            }
          }
        },
        "setting": {
          "anyOf": [
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "authority",
                "policyVersion"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "enabled"
                },
                "authority": {
                  "type": "string",
                  "enum": [
                    "observe",
                    "prepare",
                    "executeWithinPolicy"
                  ]
                },
                "policyVersion": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 2000
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
                  "type": "string",
                  "const": "disabled"
                },
                "reason": {
                  "type": "string",
                  "enum": [
                    "hostChoice",
                    "organizerDefault"
                  ]
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
        "version",
        "scope",
        "config",
        "setting"
      ],
      "properties": {
        "kind": {
          "const": "routeRecovery",
          "type": "string"
        },
        "version": {
          "const": 1,
          "type": "integer"
        },
        "scope": {
          "anyOf": [
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "eventId"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "event"
                },
                "eventId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "eventId",
                "attendeeId",
                "episodeId"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "guest"
                },
                "eventId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "attendeeId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "episodeId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "eventId",
                "groupId"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "group"
                },
                "eventId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "groupId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "eventId",
                "resourceId"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "resource"
                },
                "eventId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "resourceId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "eventId",
                "unitId",
                "round"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "unit"
                },
                "eventId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "unitId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 2000
                },
                "round": {
                  "type": "integer",
                  "minimum": 0,
                  "maximum": 10000
                }
              }
            }
          ]
        },
        "config": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "scope",
            "publication",
            "alreadyPublished",
            "alternative"
          ],
          "properties": {
            "scope": {
              "type": "string",
              "const": "remainingProgramme"
            },
            "publication": {
              "type": "string",
              "const": "hostConfirmed"
            },
            "alreadyPublished": {
              "type": "string",
              "const": "correctExplicitly"
            },
            "alternative": {
              "type": "string",
              "const": "hostApproved"
            }
          }
        },
        "setting": {
          "anyOf": [
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "authority",
                "policyVersion"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "enabled"
                },
                "authority": {
                  "type": "string",
                  "enum": [
                    "observe",
                    "prepare",
                    "executeWithinPolicy"
                  ]
                },
                "policyVersion": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 2000
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
                  "type": "string",
                  "const": "disabled"
                },
                "reason": {
                  "type": "string",
                  "enum": [
                    "hostChoice",
                    "organizerDefault"
                  ]
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
        "version",
        "scope",
        "config",
        "setting"
      ],
      "properties": {
        "kind": {
          "const": "locationFreshness",
          "type": "string"
        },
        "version": {
          "const": 1,
          "type": "integer"
        },
        "scope": {
          "anyOf": [
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "eventId"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "event"
                },
                "eventId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "eventId",
                "attendeeId",
                "episodeId"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "guest"
                },
                "eventId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "attendeeId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "episodeId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "eventId",
                "groupId"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "group"
                },
                "eventId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "groupId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "eventId",
                "resourceId"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "resource"
                },
                "eventId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "resourceId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "eventId",
                "unitId",
                "round"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "unit"
                },
                "eventId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "unitId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 2000
                },
                "round": {
                  "type": "integer",
                  "minimum": 0,
                  "maximum": 10000
                }
              }
            }
          ]
        },
        "config": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "staleAfterSeconds",
            "fallback",
            "tracking"
          ],
          "properties": {
            "staleAfterSeconds": {
              "type": "integer",
              "minimum": 0,
              "maximum": 10080
            },
            "fallback": {
              "type": "string",
              "const": "confirmedJoiningPoint"
            },
            "tracking": {
              "type": "string",
              "const": "authorizedOperatorOnly"
            }
          }
        },
        "setting": {
          "anyOf": [
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "authority",
                "policyVersion"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "enabled"
                },
                "authority": {
                  "type": "string",
                  "enum": [
                    "observe",
                    "prepare",
                    "executeWithinPolicy"
                  ]
                },
                "policyVersion": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 2000
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
                  "type": "string",
                  "const": "disabled"
                },
                "reason": {
                  "type": "string",
                  "enum": [
                    "hostChoice",
                    "organizerDefault"
                  ]
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
        "version",
        "scope",
        "config",
        "setting"
      ],
      "properties": {
        "kind": {
          "const": "accountability",
          "type": "string"
        },
        "version": {
          "const": 1,
          "type": "integer"
        },
        "scope": {
          "anyOf": [
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "eventId"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "event"
                },
                "eventId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "eventId",
                "attendeeId",
                "episodeId"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "guest"
                },
                "eventId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "attendeeId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "episodeId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "eventId",
                "groupId"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "group"
                },
                "eventId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "groupId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "eventId",
                "resourceId"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "resource"
                },
                "eventId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "resourceId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "eventId",
                "unitId",
                "round"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "unit"
                },
                "eventId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "unitId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 2000
                },
                "round": {
                  "type": "integer",
                  "minimum": 0,
                  "maximum": 10000
                }
              }
            }
          ]
        },
        "config": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "mode",
            "evidence",
            "unknownIsNotIncident"
          ],
          "properties": {
            "mode": {
              "type": "string",
              "enum": [
                "rollCall",
                "sweep"
              ]
            },
            "evidence": {
              "type": "string",
              "const": "explicitDisposition"
            },
            "unknownIsNotIncident": {
              "type": "boolean",
              "const": true
            }
          }
        },
        "setting": {
          "anyOf": [
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "authority",
                "policyVersion"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "enabled"
                },
                "authority": {
                  "type": "string",
                  "enum": [
                    "observe",
                    "prepare",
                    "executeWithinPolicy"
                  ]
                },
                "policyVersion": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 2000
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
                  "type": "string",
                  "const": "disabled"
                },
                "reason": {
                  "type": "string",
                  "enum": [
                    "hostChoice",
                    "organizerDefault"
                  ]
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
        "version",
        "scope",
        "config",
        "setting"
      ],
      "properties": {
        "kind": {
          "const": "planChangeCommunication",
          "type": "string"
        },
        "version": {
          "const": 1,
          "type": "integer"
        },
        "scope": {
          "anyOf": [
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "eventId"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "event"
                },
                "eventId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "eventId",
                "attendeeId",
                "episodeId"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "guest"
                },
                "eventId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "attendeeId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "episodeId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "eventId",
                "groupId"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "group"
                },
                "eventId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "groupId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "eventId",
                "resourceId"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "resource"
                },
                "eventId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "resourceId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "eventId",
                "unitId",
                "round"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "unit"
                },
                "eventId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "unitId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 2000
                },
                "round": {
                  "type": "integer",
                  "minimum": 0,
                  "maximum": 10000
                }
              }
            }
          ]
        },
        "config": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "templateIntent",
            "audience",
            "maximumPerGuest",
            "expiryMinutes"
          ],
          "properties": {
            "templateIntent": {
              "type": "string",
              "const": "planChange"
            },
            "audience": {
              "type": "string",
              "const": "affectedGuests"
            },
            "maximumPerGuest": {
              "type": "integer",
              "minimum": 0,
              "maximum": 10080
            },
            "expiryMinutes": {
              "type": "integer",
              "minimum": 0,
              "maximum": 10080
            }
          }
        },
        "setting": {
          "anyOf": [
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "authority",
                "policyVersion"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "enabled"
                },
                "authority": {
                  "type": "string",
                  "enum": [
                    "observe",
                    "prepare",
                    "executeWithinPolicy"
                  ]
                },
                "policyVersion": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 2000
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
                  "type": "string",
                  "const": "disabled"
                },
                "reason": {
                  "type": "string",
                  "enum": [
                    "hostChoice",
                    "organizerDefault"
                  ]
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
        "version",
        "scope",
        "config",
        "setting"
      ],
      "properties": {
        "kind": {
          "const": "deliveryRecovery",
          "type": "string"
        },
        "version": {
          "const": 1,
          "type": "integer"
        },
        "scope": {
          "anyOf": [
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "eventId"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "event"
                },
                "eventId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "eventId",
                "attendeeId",
                "episodeId"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "guest"
                },
                "eventId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "attendeeId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "episodeId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "eventId",
                "groupId"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "group"
                },
                "eventId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "groupId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "eventId",
                "resourceId"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "resource"
                },
                "eventId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "resourceId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "eventId",
                "unitId",
                "round"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "unit"
                },
                "eventId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "unitId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 2000
                },
                "round": {
                  "type": "integer",
                  "minimum": 0,
                  "maximum": 10000
                }
              }
            }
          ]
        },
        "config": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "maximumAttempts",
            "onUnknown",
            "expiresAfterMinutes"
          ],
          "properties": {
            "maximumAttempts": {
              "type": "integer",
              "minimum": 0,
              "maximum": 10080
            },
            "onUnknown": {
              "type": "string",
              "const": "reconcileBeforeRetry"
            },
            "expiresAfterMinutes": {
              "type": "integer",
              "minimum": 0,
              "maximum": 10080
            }
          }
        },
        "setting": {
          "anyOf": [
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "authority",
                "policyVersion"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "enabled"
                },
                "authority": {
                  "type": "string",
                  "enum": [
                    "observe",
                    "prepare",
                    "executeWithinPolicy"
                  ]
                },
                "policyVersion": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 2000
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
                  "type": "string",
                  "const": "disabled"
                },
                "reason": {
                  "type": "string",
                  "enum": [
                    "hostChoice",
                    "organizerDefault"
                  ]
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
        "version",
        "scope",
        "config",
        "setting"
      ],
      "properties": {
        "kind": {
          "const": "replyOwnership",
          "type": "string"
        },
        "version": {
          "const": 1,
          "type": "integer"
        },
        "scope": {
          "anyOf": [
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "eventId"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "event"
                },
                "eventId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "eventId",
                "attendeeId",
                "episodeId"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "guest"
                },
                "eventId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "attendeeId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "episodeId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "eventId",
                "groupId"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "group"
                },
                "eventId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "groupId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "eventId",
                "resourceId"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "resource"
                },
                "eventId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "resourceId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "eventId",
                "unitId",
                "round"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "unit"
                },
                "eventId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "unitId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 2000
                },
                "round": {
                  "type": "integer",
                  "minimum": 0,
                  "maximum": 10000
                }
              }
            }
          ]
        },
        "config": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "owner",
            "visibility",
            "dueMinutes"
          ],
          "properties": {
            "owner": {
              "type": "string",
              "enum": [
                "eventLead",
                "groupLead",
                "sweep",
                "checkIn",
                "specialist"
              ]
            },
            "visibility": {
              "type": "string",
              "enum": [
                "operational",
                "restricted"
              ]
            },
            "dueMinutes": {
              "type": "integer",
              "minimum": 0,
              "maximum": 10080
            }
          }
        },
        "setting": {
          "anyOf": [
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "authority",
                "policyVersion"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "enabled"
                },
                "authority": {
                  "type": "string",
                  "enum": [
                    "observe",
                    "prepare",
                    "executeWithinPolicy"
                  ]
                },
                "policyVersion": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 2000
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
                  "type": "string",
                  "const": "disabled"
                },
                "reason": {
                  "type": "string",
                  "enum": [
                    "hostChoice",
                    "organizerDefault"
                  ]
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
        "version",
        "scope",
        "config",
        "setting"
      ],
      "properties": {
        "kind": {
          "const": "guestAssistance",
          "type": "string"
        },
        "version": {
          "const": 1,
          "type": "integer"
        },
        "scope": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "kind",
            "eventId",
            "attendeeId",
            "episodeId"
          ],
          "properties": {
            "kind": {
              "type": "string",
              "const": "guest"
            },
            "eventId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 160,
              "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
            },
            "attendeeId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 160,
              "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
            },
            "episodeId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 160,
              "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
            }
          }
        },
        "config": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "owner",
            "visibility",
            "dueMinutes"
          ],
          "properties": {
            "owner": {
              "type": "string",
              "enum": [
                "eventLead",
                "groupLead",
                "sweep",
                "checkIn",
                "specialist"
              ]
            },
            "visibility": {
              "type": "string",
              "enum": [
                "operational",
                "restricted"
              ]
            },
            "dueMinutes": {
              "type": "integer",
              "minimum": 0,
              "maximum": 10080
            }
          }
        },
        "setting": {
          "anyOf": [
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "authority",
                "policyVersion"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "enabled"
                },
                "authority": {
                  "type": "string",
                  "enum": [
                    "observe",
                    "prepare",
                    "executeWithinPolicy"
                  ]
                },
                "policyVersion": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 2000
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
                  "type": "string",
                  "const": "disabled"
                },
                "reason": {
                  "type": "string",
                  "enum": [
                    "hostChoice",
                    "organizerDefault"
                  ]
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
        "version",
        "scope",
        "config",
        "setting"
      ],
      "properties": {
        "kind": {
          "const": "comfortSafety",
          "type": "string"
        },
        "version": {
          "const": 1,
          "type": "integer"
        },
        "scope": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "kind",
            "eventId",
            "attendeeId",
            "episodeId"
          ],
          "properties": {
            "kind": {
              "type": "string",
              "const": "guest"
            },
            "eventId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 160,
              "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
            },
            "attendeeId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 160,
              "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
            },
            "episodeId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 160,
              "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
            }
          }
        },
        "config": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "owner",
            "visibility",
            "dueMinutes"
          ],
          "properties": {
            "owner": {
              "type": "string",
              "enum": [
                "eventLead",
                "groupLead",
                "sweep",
                "checkIn",
                "specialist"
              ]
            },
            "visibility": {
              "type": "string",
              "const": "restricted"
            },
            "dueMinutes": {
              "type": "integer",
              "minimum": 0,
              "maximum": 10080
            }
          }
        },
        "setting": {
          "anyOf": [
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "authority",
                "policyVersion"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "enabled"
                },
                "authority": {
                  "type": "string",
                  "enum": [
                    "observe",
                    "prepare",
                    "executeWithinPolicy"
                  ]
                },
                "policyVersion": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 2000
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
                  "type": "string",
                  "const": "disabled"
                },
                "reason": {
                  "type": "string",
                  "enum": [
                    "hostChoice",
                    "organizerDefault"
                  ]
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
        "version",
        "scope",
        "config",
        "setting"
      ],
      "properties": {
        "kind": {
          "const": "attendanceSync",
          "type": "string"
        },
        "version": {
          "const": 1,
          "type": "integer"
        },
        "scope": {
          "anyOf": [
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "eventId"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "event"
                },
                "eventId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "eventId",
                "attendeeId",
                "episodeId"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "guest"
                },
                "eventId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "attendeeId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "episodeId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "eventId",
                "groupId"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "group"
                },
                "eventId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "groupId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "eventId",
                "resourceId"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "resource"
                },
                "eventId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "resourceId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "eventId",
                "unitId",
                "round"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "unit"
                },
                "eventId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "unitId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 2000
                },
                "round": {
                  "type": "integer",
                  "minimum": 0,
                  "maximum": 10000
                }
              }
            }
          ]
        },
        "config": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "maximumAttempts",
            "onUnknown",
            "expiresAfterMinutes"
          ],
          "properties": {
            "maximumAttempts": {
              "type": "integer",
              "minimum": 0,
              "maximum": 10080
            },
            "onUnknown": {
              "type": "string",
              "const": "reconcileBeforeRetry"
            },
            "expiresAfterMinutes": {
              "type": "integer",
              "minimum": 0,
              "maximum": 10080
            }
          }
        },
        "setting": {
          "anyOf": [
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "authority",
                "policyVersion"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "enabled"
                },
                "authority": {
                  "type": "string",
                  "enum": [
                    "observe",
                    "prepare",
                    "executeWithinPolicy"
                  ]
                },
                "policyVersion": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 2000
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
                  "type": "string",
                  "const": "disabled"
                },
                "reason": {
                  "type": "string",
                  "enum": [
                    "hostChoice",
                    "organizerDefault"
                  ]
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
        "version",
        "scope",
        "config",
        "setting"
      ],
      "properties": {
        "kind": {
          "const": "concurrencyRecovery",
          "type": "string"
        },
        "version": {
          "const": 1,
          "type": "integer"
        },
        "scope": {
          "anyOf": [
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "eventId"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "event"
                },
                "eventId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "eventId",
                "attendeeId",
                "episodeId"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "guest"
                },
                "eventId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "attendeeId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "episodeId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "eventId",
                "groupId"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "group"
                },
                "eventId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "groupId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "eventId",
                "resourceId"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "resource"
                },
                "eventId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "resourceId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "eventId",
                "unitId",
                "round"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "unit"
                },
                "eventId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "unitId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 2000
                },
                "round": {
                  "type": "integer",
                  "minimum": 0,
                  "maximum": 10000
                }
              }
            }
          ]
        },
        "config": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "staleWrite",
            "retry"
          ],
          "properties": {
            "staleWrite": {
              "type": "string",
              "const": "reject"
            },
            "retry": {
              "type": "string",
              "const": "revalidateIntent"
            }
          }
        },
        "setting": {
          "anyOf": [
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "authority",
                "policyVersion"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "enabled"
                },
                "authority": {
                  "type": "string",
                  "enum": [
                    "observe",
                    "prepare",
                    "executeWithinPolicy"
                  ]
                },
                "policyVersion": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 2000
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
                  "type": "string",
                  "const": "disabled"
                },
                "reason": {
                  "type": "string",
                  "enum": [
                    "hostChoice",
                    "organizerDefault"
                  ]
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
        "version",
        "scope",
        "config",
        "setting"
      ],
      "properties": {
        "kind": {
          "const": "operationRecovery",
          "type": "string"
        },
        "version": {
          "const": 1,
          "type": "integer"
        },
        "scope": {
          "anyOf": [
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "eventId"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "event"
                },
                "eventId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "eventId",
                "attendeeId",
                "episodeId"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "guest"
                },
                "eventId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "attendeeId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "episodeId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "eventId",
                "groupId"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "group"
                },
                "eventId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "groupId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "eventId",
                "resourceId"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "resource"
                },
                "eventId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "resourceId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "eventId",
                "unitId",
                "round"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "unit"
                },
                "eventId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "unitId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 2000
                },
                "round": {
                  "type": "integer",
                  "minimum": 0,
                  "maximum": 10000
                }
              }
            }
          ]
        },
        "config": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "maximumAttempts",
            "onUnknown",
            "expiresAfterMinutes"
          ],
          "properties": {
            "maximumAttempts": {
              "type": "integer",
              "minimum": 0,
              "maximum": 10080
            },
            "onUnknown": {
              "type": "string",
              "const": "reconcileBeforeRetry"
            },
            "expiresAfterMinutes": {
              "type": "integer",
              "minimum": 0,
              "maximum": 10080
            }
          }
        },
        "setting": {
          "anyOf": [
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "authority",
                "policyVersion"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "enabled"
                },
                "authority": {
                  "type": "string",
                  "enum": [
                    "observe",
                    "prepare",
                    "executeWithinPolicy"
                  ]
                },
                "policyVersion": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 2000
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
                  "type": "string",
                  "const": "disabled"
                },
                "reason": {
                  "type": "string",
                  "enum": [
                    "hostChoice",
                    "organizerDefault"
                  ]
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
        "version",
        "scope",
        "config",
        "setting"
      ],
      "properties": {
        "kind": {
          "const": "contextBoundary",
          "type": "string"
        },
        "version": {
          "const": 1,
          "type": "integer"
        },
        "scope": {
          "anyOf": [
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "eventId"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "event"
                },
                "eventId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "eventId",
                "attendeeId",
                "episodeId"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "guest"
                },
                "eventId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "attendeeId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "episodeId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "eventId",
                "groupId"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "group"
                },
                "eventId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "groupId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "eventId",
                "resourceId"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "resource"
                },
                "eventId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "resourceId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "eventId",
                "unitId",
                "round"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "unit"
                },
                "eventId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "unitId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 2000
                },
                "round": {
                  "type": "integer",
                  "minimum": 0,
                  "maximum": 10000
                }
              }
            }
          ]
        },
        "config": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "context",
            "crossContext"
          ],
          "properties": {
            "context": {
              "type": "string",
              "const": "eventAndModeBound"
            },
            "crossContext": {
              "type": "string",
              "const": "deny"
            }
          }
        },
        "setting": {
          "anyOf": [
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "authority",
                "policyVersion"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "enabled"
                },
                "authority": {
                  "type": "string",
                  "enum": [
                    "observe",
                    "prepare",
                    "executeWithinPolicy"
                  ]
                },
                "policyVersion": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 2000
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
                  "type": "string",
                  "const": "disabled"
                },
                "reason": {
                  "type": "string",
                  "enum": [
                    "hostChoice",
                    "organizerDefault"
                  ]
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
        "version",
        "scope",
        "config",
        "setting"
      ],
      "properties": {
        "kind": {
          "const": "overrideReview",
          "type": "string"
        },
        "version": {
          "const": 1,
          "type": "integer"
        },
        "scope": {
          "anyOf": [
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "eventId"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "event"
                },
                "eventId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "eventId",
                "attendeeId",
                "episodeId"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "guest"
                },
                "eventId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "attendeeId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "episodeId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "eventId",
                "groupId"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "group"
                },
                "eventId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "groupId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "eventId",
                "resourceId"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "resource"
                },
                "eventId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "resourceId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "eventId",
                "unitId",
                "round"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "unit"
                },
                "eventId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "unitId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 2000
                },
                "round": {
                  "type": "integer",
                  "minimum": 0,
                  "maximum": 10000
                }
              }
            }
          ]
        },
        "config": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "hardLimits",
            "permittedOverride"
          ],
          "properties": {
            "hardLimits": {
              "type": "string",
              "const": "neverOverride"
            },
            "permittedOverride": {
              "type": "string",
              "const": "scopedReasonedExpiring"
            }
          }
        },
        "setting": {
          "anyOf": [
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "authority",
                "policyVersion"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "enabled"
                },
                "authority": {
                  "type": "string",
                  "enum": [
                    "observe",
                    "prepare",
                    "executeWithinPolicy"
                  ]
                },
                "policyVersion": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 2000
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
                  "type": "string",
                  "const": "disabled"
                },
                "reason": {
                  "type": "string",
                  "enum": [
                    "hostChoice",
                    "organizerDefault"
                  ]
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
        "version",
        "scope",
        "config",
        "setting"
      ],
      "properties": {
        "kind": {
          "const": "eventClosure",
          "type": "string"
        },
        "version": {
          "const": 1,
          "type": "integer"
        },
        "scope": {
          "anyOf": [
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "eventId"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "event"
                },
                "eventId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "eventId",
                "attendeeId",
                "episodeId"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "guest"
                },
                "eventId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "attendeeId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "episodeId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "eventId",
                "groupId"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "group"
                },
                "eventId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "groupId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "eventId",
                "resourceId"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "resource"
                },
                "eventId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "resourceId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "eventId",
                "unitId",
                "round"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "unit"
                },
                "eventId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "unitId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 2000
                },
                "round": {
                  "type": "integer",
                  "minimum": 0,
                  "maximum": 10000
                }
              }
            }
          ]
        },
        "config": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "pendingLiveWork",
            "survivingObligations",
            "unresolvedAccountability"
          ],
          "properties": {
            "pendingLiveWork": {
              "type": "string",
              "const": "cancel"
            },
            "survivingObligations": {
              "type": "string",
              "const": "handoff"
            },
            "unresolvedAccountability": {
              "type": "string",
              "const": "explicitPolicy"
            }
          }
        },
        "setting": {
          "anyOf": [
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "authority",
                "policyVersion"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "enabled"
                },
                "authority": {
                  "type": "string",
                  "enum": [
                    "observe",
                    "prepare",
                    "executeWithinPolicy"
                  ]
                },
                "policyVersion": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 2000
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
                  "type": "string",
                  "const": "disabled"
                },
                "reason": {
                  "type": "string",
                  "enum": [
                    "hostChoice",
                    "organizerDefault"
                  ]
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
        "version",
        "scope",
        "config",
        "setting"
      ],
      "properties": {
        "kind": {
          "const": "attendanceReconciliation",
          "type": "string"
        },
        "version": {
          "const": 1,
          "type": "integer"
        },
        "scope": {
          "anyOf": [
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "eventId"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "event"
                },
                "eventId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "eventId",
                "attendeeId",
                "episodeId"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "guest"
                },
                "eventId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "attendeeId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "episodeId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "eventId",
                "groupId"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "group"
                },
                "eventId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "groupId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "eventId",
                "resourceId"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "resource"
                },
                "eventId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "resourceId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "eventId",
                "unitId",
                "round"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "unit"
                },
                "eventId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "unitId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 2000
                },
                "round": {
                  "type": "integer",
                  "minimum": 0,
                  "maximum": 10000
                }
              }
            }
          ]
        },
        "config": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "silence",
            "corrections",
            "pendingSync"
          ],
          "properties": {
            "silence": {
              "type": "string",
              "const": "notEvidence"
            },
            "corrections": {
              "type": "string",
              "const": "revisioned"
            },
            "pendingSync": {
              "type": "string",
              "const": "retain"
            }
          }
        },
        "setting": {
          "anyOf": [
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "authority",
                "policyVersion"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "enabled"
                },
                "authority": {
                  "type": "string",
                  "enum": [
                    "observe",
                    "prepare",
                    "executeWithinPolicy"
                  ]
                },
                "policyVersion": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 2000
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
                  "type": "string",
                  "const": "disabled"
                },
                "reason": {
                  "type": "string",
                  "enum": [
                    "hostChoice",
                    "organizerDefault"
                  ]
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
        "version",
        "scope",
        "config",
        "setting"
      ],
      "properties": {
        "kind": {
          "const": "financialReconciliation",
          "type": "string"
        },
        "version": {
          "const": 1,
          "type": "integer"
        },
        "scope": {
          "anyOf": [
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "eventId"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "event"
                },
                "eventId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "eventId",
                "attendeeId",
                "episodeId"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "guest"
                },
                "eventId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "attendeeId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "episodeId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "eventId",
                "groupId"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "group"
                },
                "eventId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "groupId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "eventId",
                "resourceId"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "resource"
                },
                "eventId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "resourceId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "eventId",
                "unitId",
                "round"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "unit"
                },
                "eventId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "unitId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 2000
                },
                "round": {
                  "type": "integer",
                  "minimum": 0,
                  "maximum": 10000
                }
              }
            }
          ]
        },
        "config": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "owner",
            "moneyMovement"
          ],
          "properties": {
            "owner": {
              "type": "string",
              "const": "paymentProviderWorkflow"
            },
            "moneyMovement": {
              "type": "string",
              "const": "separatelyAuthorized"
            }
          }
        },
        "setting": {
          "anyOf": [
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "authority",
                "policyVersion"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "enabled"
                },
                "authority": {
                  "type": "string",
                  "enum": [
                    "observe",
                    "prepare",
                    "executeWithinPolicy"
                  ]
                },
                "policyVersion": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 2000
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
                  "type": "string",
                  "const": "disabled"
                },
                "reason": {
                  "type": "string",
                  "enum": [
                    "hostChoice",
                    "organizerDefault"
                  ]
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
        "version",
        "scope",
        "config",
        "setting"
      ],
      "properties": {
        "kind": {
          "const": "postEventFollowUp",
          "type": "string"
        },
        "version": {
          "const": 1,
          "type": "integer"
        },
        "scope": {
          "anyOf": [
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "eventId"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "event"
                },
                "eventId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "eventId",
                "attendeeId",
                "episodeId"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "guest"
                },
                "eventId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "attendeeId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "episodeId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "eventId",
                "groupId"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "group"
                },
                "eventId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "groupId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "eventId",
                "resourceId"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "resource"
                },
                "eventId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "resourceId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "eventId",
                "unitId",
                "round"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "unit"
                },
                "eventId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "unitId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 2000
                },
                "round": {
                  "type": "integer",
                  "minimum": 0,
                  "maximum": 10000
                }
              }
            }
          ]
        },
        "config": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "templateIntent",
            "audience",
            "maximumPerGuest",
            "expiryMinutes"
          ],
          "properties": {
            "templateIntent": {
              "type": "string",
              "const": "followUp"
            },
            "audience": {
              "type": "string",
              "const": "affectedGuests"
            },
            "maximumPerGuest": {
              "type": "integer",
              "minimum": 0,
              "maximum": 10080
            },
            "expiryMinutes": {
              "type": "integer",
              "minimum": 0,
              "maximum": 10080
            }
          }
        },
        "setting": {
          "anyOf": [
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "authority",
                "policyVersion"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "enabled"
                },
                "authority": {
                  "type": "string",
                  "enum": [
                    "observe",
                    "prepare",
                    "executeWithinPolicy"
                  ]
                },
                "policyVersion": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 2000
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
                  "type": "string",
                  "const": "disabled"
                },
                "reason": {
                  "type": "string",
                  "enum": [
                    "hostChoice",
                    "organizerDefault"
                  ]
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
        "version",
        "scope",
        "config",
        "setting"
      ],
      "properties": {
        "kind": {
          "const": "eventLearning",
          "type": "string"
        },
        "version": {
          "const": 1,
          "type": "integer"
        },
        "scope": {
          "anyOf": [
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "eventId"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "event"
                },
                "eventId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "eventId",
                "attendeeId",
                "episodeId"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "guest"
                },
                "eventId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "attendeeId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "episodeId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "eventId",
                "groupId"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "group"
                },
                "eventId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "groupId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "eventId",
                "resourceId"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "resource"
                },
                "eventId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "resourceId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "eventId",
                "unitId",
                "round"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "unit"
                },
                "eventId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "unitId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 2000
                },
                "round": {
                  "type": "integer",
                  "minimum": 0,
                  "maximum": 10000
                }
              }
            }
          ]
        },
        "config": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "metrics",
            "missingCoverage",
            "sensitiveDetails"
          ],
          "properties": {
            "metrics": {
              "type": "string",
              "const": "observedOutcomes"
            },
            "missingCoverage": {
              "type": "string",
              "const": "explicit"
            },
            "sensitiveDetails": {
              "type": "string",
              "const": "excluded"
            }
          }
        },
        "setting": {
          "anyOf": [
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "authority",
                "policyVersion"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "enabled"
                },
                "authority": {
                  "type": "string",
                  "enum": [
                    "observe",
                    "prepare",
                    "executeWithinPolicy"
                  ]
                },
                "policyVersion": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 2000
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
                  "type": "string",
                  "const": "disabled"
                },
                "reason": {
                  "type": "string",
                  "enum": [
                    "hostChoice",
                    "organizerDefault"
                  ]
                }
              }
            }
          ]
        }
      }
    }
  ],
  "title": "EventAssistancePolicy"
} as const;
