// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs
// ignore_for_file: constant_identifier_names, use_null_aware_elements

// JSON Schema constant emitted from callables/update_event_rehearsal_setup_payload.schema.json.

const schemaUpdateEventRehearsalSetupCallablePayloadSchema = <String, Object?>{
  '\$schema': 'http://json-schema.org/draft-07/schema#',
  '\$id': 'https://catch.app/contracts/callables/update_event_rehearsal_setup_payload.schema.json',
  'title': 'UpdateEventRehearsalSetupCallablePayload',
  'description': 'Revision-fenced update to safe rehearsal-only event and playbook setup.',
  'type': 'object',
  'additionalProperties': false,
  'required': <Object?>[
    'sessionId',
    'expectedRevision',
    'scenarioId',
    'actorCount',
    'setup',
  ],
  'properties': <String, Object?>{
    'sessionId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
    },
    'expectedRevision': <String, Object?>{
      'type': 'integer',
      'minimum': 0,
      'maximum': 2147483647,
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
    'actorCount': <String, Object?>{
      'type': 'integer',
      'minimum': 2,
      'maximum': 50,
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
  },
};
