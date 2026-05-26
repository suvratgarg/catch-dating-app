// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs
// ignore_for_file: constant_identifier_names, use_null_aware_elements

// JSON Schema constant emitted from firestore/event_success_assignments.schema.json.

const schemaEventSuccessAssignmentDocumentSchema = <String, Object?>{
  '\$schema': 'http://json-schema.org/draft-07/schema#',
  '\$id': 'https://catch.app/contracts/firestore/event_success_assignments.schema.json',
  'title': 'EventSuccessAssignmentDocument',
  'description': 'Server-owned live guidance assignment stored at eventSuccessAssignments/{eventId_moduleId_uid}.',
  'type': 'object',
  'additionalProperties': false,
  'x-firestore-collection': 'eventSuccessAssignments',
  'x-firestore-path': 'eventSuccessAssignments/{assignmentId}',
  'x-document-id-field': 'id',
  'x-owner': 'event-success assignment callables',
  'x-internal-demo-fields': <Object?>[
    'synthetic',
    'seedPrefix',
    'scenario',
    'demoOps',
    'demoOpsId',
    'demoOpsCommand',
  ],
  'required': <Object?>[
    'eventId',
    'clubId',
    'uid',
    'moduleId',
    'label',
    'displayTitle',
    'peerUids',
    'source',
    'createdAt',
    'updatedAt',
  ],
  'properties': <String, Object?>{
    'eventId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
      'x-catch-ownership': 'callable-owned',
    },
    'clubId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
      'x-catch-ownership': 'callable-owned',
    },
    'uid': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
      'x-catch-ownership': 'callable-owned',
    },
    'moduleId': <String, Object?>{
      'type': 'string',
      'enum': <Object?>[
        'micro_pods',
        'guided_rotations',
      ],
      'x-catch-ownership': 'callable-owned',
    },
    'label': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 80,
      'x-catch-ownership': 'callable-owned',
    },
    'displayTitle': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 120,
      'x-catch-ownership': 'callable-owned',
    },
    'displaySubtitle': <String, Object?>{
      'type': <Object?>[
        'string',
        'null',
      ],
      'maxLength': 240,
      'x-catch-ownership': 'callable-owned',
    },
    'peerUids': <String, Object?>{
      'type': 'array',
      'maxItems': 20,
      'items': <String, Object?>{
        'type': 'string',
        'minLength': 1,
        'maxLength': 180,
      },
      'x-catch-ownership': 'callable-owned',
    },
    'rotationSlots': <String, Object?>{
      'type': 'array',
      'maxItems': 24,
      'items': <String, Object?>{
        'type': 'object',
        'additionalProperties': false,
        'required': <Object?>[
          'roundIndex',
          'label',
          'startsAt',
          'endsAt',
          'peerUid',
          'compatibility',
        ],
        'properties': <String, Object?>{
          'roundIndex': <String, Object?>{
            'type': 'integer',
            'minimum': 0,
            'maximum': 100,
          },
          'label': <String, Object?>{
            'type': 'string',
            'minLength': 1,
            'maxLength': 80,
          },
          'startsAt': <String, Object?>{
            'type': 'object',
            'description': 'Serialized Firestore Timestamp fixture shape.',
            'x-firestore-type': 'timestamp',
            'additionalProperties': false,
            'required': <Object?>[
              '_seconds',
              '_nanoseconds',
            ],
            'properties': <String, Object?>{
              '_seconds': <String, Object?>{
                'type': 'integer',
              },
              '_nanoseconds': <String, Object?>{
                'type': 'integer',
                'minimum': 0,
                'maximum': 999999999,
              },
            },
          },
          'endsAt': <String, Object?>{
            'type': 'object',
            'description': 'Serialized Firestore Timestamp fixture shape.',
            'x-firestore-type': 'timestamp',
            'additionalProperties': false,
            'required': <Object?>[
              '_seconds',
              '_nanoseconds',
            ],
            'properties': <String, Object?>{
              '_seconds': <String, Object?>{
                'type': 'integer',
              },
              '_nanoseconds': <String, Object?>{
                'type': 'integer',
                'minimum': 0,
                'maximum': 999999999,
              },
            },
          },
          'peerUid': <String, Object?>{
            'type': 'string',
            'minLength': 1,
            'maxLength': 180,
          },
          'compatibility': <String, Object?>{
            'type': 'string',
            'enum': <Object?>[
              'mutual_interest',
              'one_way_interest',
              'questionnaire_match',
              'social',
              'host_override',
            ],
          },
        },
      },
      'x-catch-ownership': 'callable-owned',
    },
    'groupRotationSlots': <String, Object?>{
      'type': 'array',
      'maxItems': 24,
      'items': <String, Object?>{
        'type': 'object',
        'additionalProperties': false,
        'required': <Object?>[
          'roundIndex',
          'label',
          'unitLabel',
          'startsAt',
          'endsAt',
          'peerUids',
          'compatibility',
        ],
        'properties': <String, Object?>{
          'roundIndex': <String, Object?>{
            'type': 'integer',
            'minimum': 0,
            'maximum': 100,
          },
          'label': <String, Object?>{
            'type': 'string',
            'minLength': 1,
            'maxLength': 80,
          },
          'unitLabel': <String, Object?>{
            'type': 'string',
            'minLength': 1,
            'maxLength': 80,
          },
          'startsAt': <String, Object?>{
            'type': 'object',
            'description': 'Serialized Firestore Timestamp fixture shape.',
            'x-firestore-type': 'timestamp',
            'additionalProperties': false,
            'required': <Object?>[
              '_seconds',
              '_nanoseconds',
            ],
            'properties': <String, Object?>{
              '_seconds': <String, Object?>{
                'type': 'integer',
              },
              '_nanoseconds': <String, Object?>{
                'type': 'integer',
                'minimum': 0,
                'maximum': 999999999,
              },
            },
          },
          'endsAt': <String, Object?>{
            'type': 'object',
            'description': 'Serialized Firestore Timestamp fixture shape.',
            'x-firestore-type': 'timestamp',
            'additionalProperties': false,
            'required': <Object?>[
              '_seconds',
              '_nanoseconds',
            ],
            'properties': <String, Object?>{
              '_seconds': <String, Object?>{
                'type': 'integer',
              },
              '_nanoseconds': <String, Object?>{
                'type': 'integer',
                'minimum': 0,
                'maximum': 999999999,
              },
            },
          },
          'peerUids': <String, Object?>{
            'type': 'array',
            'maxItems': 20,
            'items': <String, Object?>{
              'type': 'string',
              'minLength': 1,
              'maxLength': 180,
            },
          },
          'compatibility': <String, Object?>{
            'type': 'string',
            'enum': <Object?>[
              'mutual_interest',
              'one_way_interest',
              'questionnaire_match',
              'social',
              'mixed',
              'host_override',
            ],
          },
        },
      },
      'x-catch-ownership': 'callable-owned',
    },
    'source': <String, Object?>{
      'type': 'string',
      'enum': <Object?>[
        'server_v1',
        'host_override_v1',
        'server',
      ],
      'x-catch-ownership': 'callable-owned',
    },
    'createdAt': <String, Object?>{
      'type': 'object',
      'description': 'Serialized Firestore Timestamp fixture shape.',
      'x-firestore-type': 'timestamp',
      'additionalProperties': false,
      'required': <Object?>[
        '_seconds',
        '_nanoseconds',
      ],
      'properties': <String, Object?>{
        '_seconds': <String, Object?>{
          'type': 'integer',
        },
        '_nanoseconds': <String, Object?>{
          'type': 'integer',
          'minimum': 0,
          'maximum': 999999999,
        },
      },
      'x-catch-ownership': 'callable-owned',
    },
    'updatedAt': <String, Object?>{
      'type': 'object',
      'description': 'Serialized Firestore Timestamp fixture shape.',
      'x-firestore-type': 'timestamp',
      'additionalProperties': false,
      'required': <Object?>[
        '_seconds',
        '_nanoseconds',
      ],
      'properties': <String, Object?>{
        '_seconds': <String, Object?>{
          'type': 'integer',
        },
        '_nanoseconds': <String, Object?>{
          'type': 'integer',
          'minimum': 0,
          'maximum': 999999999,
        },
      },
      'x-catch-ownership': 'callable-owned',
    },
    'synthetic': <String, Object?>{
      'type': 'boolean',
      'description': 'Internal demo seed marker used for cleanup and diagnostics.',
    },
    'seedPrefix': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 120,
      'description': 'Internal demo seed prefix used for cleanup and diagnostics.',
    },
    'scenario': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 120,
      'description': 'Internal demo seed scenario name used for cleanup and diagnostics.',
    },
    'demoOps': <String, Object?>{
      'type': 'boolean',
      'description': 'Internal demo-operations marker used for cleanup and diagnostics.',
    },
    'demoOpsId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
      'description': 'Internal demo-operations id used for cleanup and diagnostics.',
    },
    'demoOpsCommand': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 80,
      'description': 'Internal demo-operations command name used for cleanup and diagnostics.',
    },
  },
};
