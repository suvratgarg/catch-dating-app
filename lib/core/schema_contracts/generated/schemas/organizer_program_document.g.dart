// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs
// ignore_for_file: constant_identifier_names, use_null_aware_elements

// JSON Schema constant emitted from firestore/organizer_programs.schema.json.

const schemaOrganizerProgramDocumentSchema = <String, Object?>{
  '\$schema': 'http://json-schema.org/draft-07/schema#',
  '\$id': 'https://catch.app/contracts/firestore/organizer_programs.schema.json',
  'title': 'OrganizerProgramDocument',
  'description': 'Server-owned private wedding/corporate program root. Holds organizer ownership, lifecycle, enabled capabilities and transport tuning. Never publicly readable; guest logistics live in program-scoped collections.',
  'type': 'object',
  'additionalProperties': false,
  'x-firestore-collection': 'organizerPrograms',
  'x-firestore-path': 'organizerPrograms/{programId}',
  'x-document-id-field': 'programId',
  'x-owner': 'program management callables',
  'required': <Object?>[
    'organizerId',
    'kind',
    'title',
    'timezone',
    'startsAt',
    'endsAt',
    'status',
    'capabilities',
    'transportSettings',
    'createdBy',
    'createdAt',
    'updatedAt',
    'revision',
  ],
  'properties': <String, Object?>{
    'organizerId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
    },
    'kind': <String, Object?>{
      'type': 'string',
      'enum': <Object?>[
        'wedding',
        'corporate',
        'social',
        'other',
      ],
    },
    'title': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 140,
    },
    'timezone': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 60,
      'description': 'IANA timezone identifier used for display and time-band boundaries.',
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
    'status': <String, Object?>{
      'type': 'string',
      'enum': <Object?>[
        'draft',
        'active',
        'completed',
        'archived',
      ],
    },
    'capabilities': <String, Object?>{
      'type': 'array',
      'maxItems': 8,
      'uniqueItems': true,
      'items': <String, Object?>{
        'type': 'string',
        'enum': <Object?>[
          'arrivalsTransport',
          'accommodation',
          'forms',
          'messaging',
        ],
      },
    },
    'transportSettings': <String, Object?>{
      'type': 'object',
      'additionalProperties': false,
      'required': <Object?>[
        'bandWindowMillis',
        'maxReadyWaitMillis',
        'domesticExitLagMillis',
        'internationalExitLagMillis',
        'vehicleClasses',
      ],
      'properties': <String, Object?>{
        'bandWindowMillis': <String, Object?>{
          'type': 'integer',
          'minimum': 300000,
          'maximum': 7200000,
          'description': 'Anchored curb-time window used by grouping suggestions. Default 30 minutes.',
        },
        'maxReadyWaitMillis': <String, Object?>{
          'type': 'integer',
          'minimum': 60000,
          'maximum': 3600000,
          'description': 'Ceiling on how long a physically ready party waits before a group is flagged overdue. Default 10 minutes for premium events.',
        },
        'domesticExitLagMillis': <String, Object?>{
          'type': 'integer',
          'minimum': 0,
          'maximum': 7200000,
          'description': 'Default landing-to-curb lag for domestic arrivals.',
        },
        'internationalExitLagMillis': <String, Object?>{
          'type': 'integer',
          'minimum': 0,
          'maximum': 14400000,
          'description': 'Default landing-to-curb lag for international arrivals.',
        },
        'vehicleClasses': <String, Object?>{
          'type': 'array',
          'maxItems': 16,
          'items': <String, Object?>{
            'type': 'object',
            'additionalProperties': false,
            'required': <Object?>[
              'id',
              'label',
              'passengerCapacity',
              'luggageCapacity',
              'capabilities',
              'sortOrder',
            ],
            'properties': <String, Object?>{
              'id': <String, Object?>{
                'type': 'string',
                'minLength': 1,
                'maxLength': 60,
                'pattern': '^[a-z0-9][a-z0-9_-]{0,59}\$',
              },
              'label': <String, Object?>{
                'type': 'string',
                'minLength': 1,
                'maxLength': 60,
              },
              'passengerCapacity': <String, Object?>{
                'type': 'integer',
                'minimum': 1,
                'maximum': 200,
              },
              'luggageCapacity': <String, Object?>{
                'type': 'integer',
                'minimum': 0,
                'maximum': 500,
              },
              'capabilities': <String, Object?>{
                'type': 'array',
                'maxItems': 12,
                'uniqueItems': true,
                'items': <String, Object?>{
                  'type': 'string',
                  'enum': <Object?>[
                    'wheelchairAccessible',
                    'extraLuggage',
                    'childSeat',
                  ],
                },
              },
              'sortOrder': <String, Object?>{
                'type': 'integer',
                'minimum': 0,
                'maximum': 1000,
              },
            },
          },
          'description': 'Program-scoped vehicle catalog consumed by grouping suggestions; ids are unique per program.',
        },
      },
    },
    'createdBy': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
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
    },
    'revision': <String, Object?>{
      'type': 'integer',
      'minimum': 1,
      'maximum': 9007199254740991,
    },
  },
};
