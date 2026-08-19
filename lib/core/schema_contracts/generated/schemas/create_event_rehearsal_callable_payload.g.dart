// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs
// ignore_for_file: constant_identifier_names, use_null_aware_elements

// JSON Schema constant emitted from callables/create_event_rehearsal_payload.schema.json.

const schemaCreateEventRehearsalCallablePayloadSchema = <String, Object?>{
  '\$schema': 'http://json-schema.org/draft-07/schema#',
  '\$id': 'https://catch.app/contracts/callables/create_event_rehearsal_payload.schema.json',
  'title': 'CreateEventRehearsalCallablePayload',
  'description': 'Creates an isolated rehearsal from a real event snapshot or the safe sample template.',
  'type': 'object',
  'additionalProperties': false,
  'required': <Object?>[
    'organizerId',
    'sourceEventId',
    'scenarioId',
    'seed',
    'actorCount',
  ],
  'properties': <String, Object?>{
    'organizerId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
    },
    'sourceEventId': <String, Object?>{
      'type': <Object?>[
        'string',
        'null',
      ],
      'maxLength': 180,
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
      'minimum': 1,
      'maximum': 2147483647,
    },
    'actorCount': <String, Object?>{
      'type': 'integer',
      'minimum': 2,
      'maximum': 50,
    },
  },
};
