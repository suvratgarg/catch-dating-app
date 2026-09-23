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
          'revision': <String, Object?>{
            'type': 'integer',
            'minimum': 1,
          },
        },
      },
    },
  },
};
