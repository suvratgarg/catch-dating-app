// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs
// ignore_for_file: constant_identifier_names, use_null_aware_elements

// JSON Schema constant emitted from callables/control_event_rehearsal_payload.schema.json.

const schemaControlEventRehearsalCallablePayloadSchema = <String, Object?>{
  '\$schema': 'http://json-schema.org/draft-07/schema#',
  '\$id': 'https://catch.app/contracts/callables/control_event_rehearsal_payload.schema.json',
  'title': 'ControlEventRehearsalCallablePayload',
  'description': 'Revision-fenced Host lifecycle or virtual-clock control.',
  'type': 'object',
  'additionalProperties': false,
  'required': <Object?>[
    'sessionId',
    'expectedRevision',
    'clientActionId',
    'action',
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
    'clientActionId': <String, Object?>{
      'type': 'string',
      'pattern': '^[A-Za-z0-9_-]{8,120}\$',
    },
    'action': <String, Object?>{
      'type': 'string',
      'enum': <Object?>[
        'markReady',
        'start',
        'pause',
        'resume',
        'advance',
        'previous',
        'advanceClock',
        'complete',
      ],
    },
    'minutes': <String, Object?>{
      'type': 'integer',
      'minimum': 1,
      'maximum': 120,
    },
  },
};
