// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs
// ignore_for_file: constant_identifier_names, use_null_aware_elements

// JSON Schema constant emitted from callable_responses/organizer_program_list_response.schema.json.

const schemaOrganizerProgramListCallableResponseSchema = <String, Object?>{
  '\$schema': 'http://json-schema.org/draft-07/schema#',
  '\$id': 'https://catch.app/contracts/callable_responses/organizer_program_list_response.schema.json',
  'title': 'OrganizerProgramListCallableResponse',
  'description': 'Manager\'s program inventory: summaries only, no guest or logistics data.',
  'type': 'object',
  'additionalProperties': false,
  'required': <Object?>[
    'programs',
  ],
  'properties': <String, Object?>{
    'programs': <String, Object?>{
      'type': 'array',
      'maxItems': 50,
      'items': <String, Object?>{
        'type': 'object',
        'additionalProperties': false,
        'required': <Object?>[
          'programId',
          'kind',
          'title',
          'status',
          'timezone',
          'startsAtMillis',
          'endsAtMillis',
          'capabilities',
          'revision',
        ],
        'properties': <String, Object?>{
          'programId': <String, Object?>{
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
          'status': <String, Object?>{
            'type': 'string',
            'enum': <Object?>[
              'draft',
              'active',
              'completed',
              'archived',
            ],
          },
          'timezone': <String, Object?>{
            'type': 'string',
            'minLength': 1,
            'maxLength': 60,
            'description': 'IANA timezone used to recover the Program\'s civil calendar dates from its stored instants.',
          },
          'startsAtMillis': <String, Object?>{
            'type': 'integer',
            'minimum': 0,
          },
          'endsAtMillis': <String, Object?>{
            'type': 'integer',
            'minimum': 0,
          },
          'capabilities': <String, Object?>{
            'type': 'array',
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
          'functionCount': <String, Object?>{
            'type': 'integer',
            'minimum': 0,
            'description': 'Exact count of constituent program events for a completely read authorized batch. Omitted when unavailable or the bounded batch is incomplete; absence never means zero.',
          },
          'revision': <String, Object?>{
            'type': 'integer',
            'minimum': 1,
          },
          'archivedAtMillis': <String, Object?>{
            'type': <Object?>[
              'integer',
              'null',
            ],
            'minimum': 0,
            'description': 'Set when the program is archived; null otherwise.',
          },
          'anonymizeAtMillis': <String, Object?>{
            'type': <Object?>[
              'integer',
              'null',
            ],
            'minimum': 0,
            'description': 'Grace deadline after which identity fields are scrubbed.',
          },
          'anonymizedAtMillis': <String, Object?>{
            'type': <Object?>[
              'integer',
              'null',
            ],
            'minimum': 0,
            'description': 'Set once identity/free-text fields were scrubbed.',
          },
        },
      },
    },
    'nextCursor': <String, Object?>{
      'type': <Object?>[
        'string',
        'null',
      ],
      'minLength': 1,
      'maxLength': 512,
      'description': 'Opaque stable cursor for the last returned startsAt/program-ID tuple when another page exists, otherwise null. Optional for legacy readers.',
    },
  },
};
