// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs
// ignore_for_file: constant_identifier_names, use_null_aware_elements

// JSON Schema constant emitted from callable_responses/event_rehearsal_reproduction_response.schema.json.

const schemaEventRehearsalReproductionCallableResponseSchema = <String, Object?>{
  '\$schema': 'http://json-schema.org/draft-07/schema#',
  '\$id': 'https://catch.app/contracts/callable_responses/event_rehearsal_reproduction_response.schema.json',
  'title': 'EventRehearsalReproductionCallableResponse',
  'description': 'Portable deterministic reproduction record for internal QA and product review.',
  'type': 'object',
  'additionalProperties': false,
  'required': <Object?>[
    'schemaVersion',
    'sessionId',
    'scenarioId',
    'seed',
    'setup',
    'actions',
  ],
  'properties': <String, Object?>{
    'schemaVersion': <String, Object?>{
      'type': 'integer',
      'const': 1,
    },
    'sessionId': <String, Object?>{
      'type': 'string',
    },
    'scenarioId': <String, Object?>{
      'type': 'string',
      'enum': <Object?>[
        'smoothRun',
        'lateAndNoShow',
        'earlyExitAndReturn',
        'rosterAndCapacity',
        'walkInAndAmbiguousClaim',
        'privacyAndKeepApart',
        'lowConnectivity',
        'concurrentHosts',
        'revealInterrupted',
        'externalProfiles',
        'accountabilitySweep',
      ],
    },
    'seed': <String, Object?>{
      'type': 'integer',
    },
    'setup': <String, Object?>{
      'type': 'object',
      'additionalProperties': false,
      'required': <Object?>[
        'title',
        'locationName',
        'durationMinutes',
        'hostGoal',
        'attendeePrompt',
        'moduleIds',
      ],
      'properties': <String, Object?>{
        'title': <String, Object?>{
          'type': 'string',
          'minLength': 1,
          'maxLength': 120,
        },
        'locationName': <String, Object?>{
          'type': 'string',
          'minLength': 1,
          'maxLength': 180,
        },
        'durationMinutes': <String, Object?>{
          'type': 'integer',
          'minimum': 30,
          'maximum': 360,
        },
        'hostGoal': <String, Object?>{
          'type': 'string',
          'minLength': 1,
          'maxLength': 240,
        },
        'attendeePrompt': <String, Object?>{
          'type': 'string',
          'minLength': 1,
          'maxLength': 320,
        },
        'moduleIds': <String, Object?>{
          'type': 'array',
          'minItems': 1,
          'maxItems': 8,
          'uniqueItems': true,
          'items': <String, Object?>{
            'type': 'string',
            'enum': <Object?>[
              'arrival',
              'firstHello',
              'pods',
              'rotations',
              'conversationCues',
              'reveal',
              'afterglow',
              'accountability',
            ],
          },
        },
      },
    },
    'actions': <String, Object?>{
      'type': 'array',
      'maxItems': 500,
      'items': <String, Object?>{
        'type': 'object',
      },
    },
  },
};
