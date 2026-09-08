// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs
// ignore_for_file: constant_identifier_names, use_null_aware_elements

// JSON Schema constant emitted from callable_responses/event_assistance_cases_response.schema.json.

const schemaEventAssistanceCasesCallableResponseSchema = <String, Object?>{
  'type': 'object',
  'additionalProperties': false,
  'required': <Object?>[
    'context',
    'serverTime',
    'coverage',
    'status',
    'cases',
    'nextCursor',
  ],
  'properties': <String, Object?>{
    'context': <String, Object?>{
      'type': 'object',
      'additionalProperties': false,
      'required': <Object?>[
        'mode',
        'eventId',
        'organizerId',
      ],
      'properties': <String, Object?>{
        'mode': <String, Object?>{
          'type': 'string',
          'const': 'live',
        },
        'eventId': <String, Object?>{
          'type': 'string',
          'minLength': 1,
          'maxLength': 160,
          'pattern': '^[A-Za-z0-9][A-Za-z0-9._:-]*\$',
        },
        'organizerId': <String, Object?>{
          'type': 'string',
          'minLength': 1,
          'maxLength': 2000,
        },
      },
    },
    'serverTime': <String, Object?>{
      'type': 'integer',
      'minimum': 0,
      'maximum': 9007199254740991,
    },
    'coverage': <String, Object?>{
      'const': 'page',
    },
    'status': <String, Object?>{
      'enum': <Object?>[
        'open',
        'resolved',
      ],
    },
    'cases': <String, Object?>{
      'type': 'array',
      'maxItems': 50,
      'items': <String, Object?>{
        'oneOf': <Object?>[
          <String, Object?>{
            'type': 'object',
            'additionalProperties': false,
            'required': <Object?>[
              'caseId',
              'revision',
              'sourceHash',
              'availability',
              'attendeeId',
              'category',
              'receivedAt',
              'status',
              'resolution',
              'canChange',
              'assignment',
            ],
            'properties': <String, Object?>{
              'caseId': <String, Object?>{
                'type': 'string',
                'minLength': 1,
                'maxLength': 160,
                'pattern': '^[A-Za-z0-9][A-Za-z0-9._:-]*\$',
              },
              'revision': <String, Object?>{
                'type': 'integer',
                'minimum': 0,
                'maximum': 9007199254740991,
              },
              'sourceHash': <String, Object?>{
                'type': 'string',
                'pattern': '^[a-f0-9]{64}\$',
              },
              'availability': <String, Object?>{
                'const': 'current',
              },
              'attendeeId': <String, Object?>{
                'type': 'string',
                'minLength': 1,
                'maxLength': 160,
                'pattern': '^[A-Za-z0-9][A-Za-z0-9._:-]*\$',
              },
              'category': <String, Object?>{
                'enum': <Object?>[
                  'eventLogistics',
                  'accessibility',
                  'other',
                ],
              },
              'receivedAt': <String, Object?>{
                'type': 'integer',
                'minimum': 0,
                'maximum': 9007199254740991,
              },
              'status': <String, Object?>{
                'const': 'open',
              },
              'resolution': <String, Object?>{
                'type': 'null',
              },
              'canChange': <String, Object?>{
                'const': true,
              },
              'assignment': <String, Object?>{
                'oneOf': <Object?>[
                  <String, Object?>{
                    'type': 'object',
                    'additionalProperties': false,
                    'required': <Object?>[
                      'kind',
                    ],
                    'properties': <String, Object?>{
                      'kind': <String, Object?>{
                        'const': 'unassigned',
                      },
                    },
                  },
                  <String, Object?>{
                    'type': 'object',
                    'additionalProperties': false,
                    'required': <Object?>[
                      'kind',
                      'uid',
                      'authority',
                    ],
                    'properties': <String, Object?>{
                      'kind': <String, Object?>{
                        'const': 'assigned',
                      },
                      'uid': <String, Object?>{
                        'type': 'string',
                        'minLength': 1,
                        'maxLength': 160,
                        'pattern': '^[A-Za-z0-9][A-Za-z0-9._:-]*\$',
                      },
                      'authority': <String, Object?>{
                        'enum': <Object?>[
                          'current',
                          'revoked',
                        ],
                      },
                    },
                  },
                ],
              },
            },
          },
          <String, Object?>{
            'type': 'object',
            'additionalProperties': false,
            'required': <Object?>[
              'caseId',
              'revision',
              'sourceHash',
              'availability',
              'attendeeId',
              'category',
              'receivedAt',
              'status',
              'resolution',
              'canChange',
              'assignment',
            ],
            'properties': <String, Object?>{
              'caseId': <String, Object?>{
                'type': 'string',
                'minLength': 1,
                'maxLength': 160,
                'pattern': '^[A-Za-z0-9][A-Za-z0-9._:-]*\$',
              },
              'revision': <String, Object?>{
                'type': 'integer',
                'minimum': 1,
                'maximum': 9007199254740991,
              },
              'sourceHash': <String, Object?>{
                'type': 'string',
                'pattern': '^[a-f0-9]{64}\$',
              },
              'availability': <String, Object?>{
                'const': 'current',
              },
              'attendeeId': <String, Object?>{
                'type': 'string',
                'minLength': 1,
                'maxLength': 160,
                'pattern': '^[A-Za-z0-9][A-Za-z0-9._:-]*\$',
              },
              'category': <String, Object?>{
                'enum': <Object?>[
                  'eventLogistics',
                  'accessibility',
                  'other',
                ],
              },
              'receivedAt': <String, Object?>{
                'type': 'integer',
                'minimum': 0,
                'maximum': 9007199254740991,
              },
              'status': <String, Object?>{
                'const': 'resolved',
              },
              'resolution': <String, Object?>{
                'type': 'object',
                'additionalProperties': false,
                'required': <Object?>[
                  'outcome',
                  'actorUid',
                  'at',
                ],
                'properties': <String, Object?>{
                  'outcome': <String, Object?>{
                    'enum': <Object?>[
                      'resolved',
                      'declined',
                    ],
                  },
                  'actorUid': <String, Object?>{
                    'type': 'string',
                    'minLength': 1,
                    'maxLength': 160,
                    'pattern': '^[A-Za-z0-9][A-Za-z0-9._:-]*\$',
                  },
                  'at': <String, Object?>{
                    'type': 'integer',
                    'minimum': 0,
                    'maximum': 9007199254740991,
                  },
                },
              },
              'canChange': <String, Object?>{
                'const': false,
              },
              'assignment': <String, Object?>{
                'oneOf': <Object?>[
                  <String, Object?>{
                    'type': 'object',
                    'additionalProperties': false,
                    'required': <Object?>[
                      'kind',
                    ],
                    'properties': <String, Object?>{
                      'kind': <String, Object?>{
                        'const': 'unassigned',
                      },
                    },
                  },
                  <String, Object?>{
                    'type': 'object',
                    'additionalProperties': false,
                    'required': <Object?>[
                      'kind',
                      'uid',
                      'authority',
                    ],
                    'properties': <String, Object?>{
                      'kind': <String, Object?>{
                        'const': 'assigned',
                      },
                      'uid': <String, Object?>{
                        'type': 'string',
                        'minLength': 1,
                        'maxLength': 160,
                        'pattern': '^[A-Za-z0-9][A-Za-z0-9._:-]*\$',
                      },
                      'authority': <String, Object?>{
                        'enum': <Object?>[
                          'current',
                          'revoked',
                        ],
                      },
                    },
                  },
                ],
              },
            },
          },
          <String, Object?>{
            'type': 'object',
            'additionalProperties': false,
            'required': <Object?>[
              'caseId',
              'revision',
              'sourceHash',
              'availability',
              'attendeeId',
              'category',
              'receivedAt',
              'status',
              'resolution',
              'canChange',
              'assignment',
            ],
            'properties': <String, Object?>{
              'caseId': <String, Object?>{
                'type': 'string',
                'minLength': 1,
                'maxLength': 160,
                'pattern': '^[A-Za-z0-9][A-Za-z0-9._:-]*\$',
              },
              'revision': <String, Object?>{
                'type': 'integer',
                'minimum': 0,
                'maximum': 9007199254740991,
              },
              'sourceHash': <String, Object?>{
                'type': 'string',
                'pattern': '^[a-f0-9]{64}\$',
              },
              'availability': <String, Object?>{
                'const': 'sourceChanged',
              },
              'attendeeId': <String, Object?>{
                'type': 'null',
              },
              'category': <String, Object?>{
                'enum': <Object?>[
                  'eventLogistics',
                  'accessibility',
                  'other',
                ],
              },
              'receivedAt': <String, Object?>{
                'type': 'integer',
                'minimum': 0,
                'maximum': 9007199254740991,
              },
              'status': <String, Object?>{
                'enum': <Object?>[
                  'open',
                  'resolved',
                ],
              },
              'resolution': <String, Object?>{
                'type': 'null',
              },
              'canChange': <String, Object?>{
                'const': false,
              },
              'assignment': <String, Object?>{
                'type': 'object',
                'additionalProperties': false,
                'required': <Object?>[
                  'kind',
                ],
                'properties': <String, Object?>{
                  'kind': <String, Object?>{
                    'const': 'unavailable',
                  },
                },
              },
            },
          },
          <String, Object?>{
            'type': 'object',
            'additionalProperties': false,
            'required': <Object?>[
              'caseId',
              'revision',
              'sourceHash',
              'availability',
              'attendeeId',
              'category',
              'receivedAt',
              'status',
              'resolution',
              'canChange',
              'assignment',
            ],
            'properties': <String, Object?>{
              'caseId': <String, Object?>{
                'type': 'string',
                'minLength': 1,
                'maxLength': 160,
                'pattern': '^[A-Za-z0-9][A-Za-z0-9._:-]*\$',
              },
              'revision': <String, Object?>{
                'type': 'null',
              },
              'sourceHash': <String, Object?>{
                'type': 'string',
                'pattern': '^[a-f0-9]{64}\$',
              },
              'availability': <String, Object?>{
                'const': 'legacy',
              },
              'attendeeId': <String, Object?>{
                'type': 'null',
              },
              'category': <String, Object?>{
                'enum': <Object?>[
                  'eventLogistics',
                  'accessibility',
                  'other',
                ],
              },
              'receivedAt': <String, Object?>{
                'type': 'integer',
                'minimum': 0,
                'maximum': 9007199254740991,
              },
              'status': <String, Object?>{
                'enum': <Object?>[
                  'open',
                  'resolved',
                ],
              },
              'resolution': <String, Object?>{
                'type': 'null',
              },
              'canChange': <String, Object?>{
                'const': false,
              },
              'assignment': <String, Object?>{
                'type': 'object',
                'additionalProperties': false,
                'required': <Object?>[
                  'kind',
                ],
                'properties': <String, Object?>{
                  'kind': <String, Object?>{
                    'const': 'unavailable',
                  },
                },
              },
            },
          },
        ],
      },
    },
    'nextCursor': <String, Object?>{
      'anyOf': <Object?>[
        <String, Object?>{
          'type': 'string',
          'minLength': 1,
          'maxLength': 160,
          'pattern': '^[A-Za-z0-9][A-Za-z0-9._:-]*\$',
        },
        <String, Object?>{
          'type': 'null',
        },
      ],
    },
  },
  'title': 'EventAssistanceCasesCallableResponse',
};
