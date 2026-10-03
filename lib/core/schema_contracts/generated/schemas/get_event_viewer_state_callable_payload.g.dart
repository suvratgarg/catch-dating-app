// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs
// ignore_for_file: constant_identifier_names, use_null_aware_elements

// JSON Schema constant emitted from callables/get_event_viewer_state_payload.schema.json.

const schemaGetEventViewerStateCallablePayloadSchema = <String, Object?>{
  'type': 'object',
  'additionalProperties': false,
  'required': <Object?>[
    'eventId',
  ],
  'properties': <String, Object?>{
    'eventId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
    },
    'inviteCode': <String, Object?>{
      'anyOf': <Object?>[
        <String, Object?>{
          'type': 'string',
          'minLength': 1,
          'maxLength': 120,
        },
        <String, Object?>{
          'type': 'null',
        },
      ],
    },
    'publicPaymentId': <String, Object?>{
      'anyOf': <Object?>[
        <String, Object?>{
          'type': 'string',
          'minLength': 1,
          'maxLength': 180,
        },
        <String, Object?>{
          'type': 'null',
        },
      ],
    },
  },
  '\$schema': 'http://json-schema.org/draft-07/schema#',
  '\$id': 'https://catch.app/contracts/callables/get_event_viewer_state_payload.schema.json',
  'title': 'GetEventViewerStateCallablePayload',
  'description': 'Read current account-scoped event facts using an Auth-derived subject; never reserve or grant admission.',
  'x-callable-aliases': <Object?>[
    'getEventViewerState',
  ],
};
