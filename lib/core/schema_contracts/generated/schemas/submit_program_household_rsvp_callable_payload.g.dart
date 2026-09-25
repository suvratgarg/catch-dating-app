// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs
// ignore_for_file: constant_identifier_names, use_null_aware_elements

// JSON Schema constant emitted from callables/submit_program_household_rsvp_payload.schema.json.

const schemaSubmitProgramHouseholdRsvpCallablePayloadSchema = <String, Object?>{
  '\$schema': 'http://json-schema.org/draft-07/schema#',
  '\$id': 'https://catch.app/contracts/callables/submit_program_household_rsvp_payload.schema.json',
  'title': 'SubmitProgramHouseholdRsvpCallablePayload',
  'description': 'Token-authenticated household RSVP submit. Responses are limited to guests in the token\'s household and apply atomically. messagingConsent records the explicit checkbox state; it is never implied by submitting.',
  'type': 'object',
  'additionalProperties': false,
  'required': <Object?>[
    'token',
    'responses',
    'messagingConsent',
  ],
  'properties': <String, Object?>{
    'token': <String, Object?>{
      'type': 'string',
      'minLength': 16,
      'maxLength': 1024,
    },
    'responses': <String, Object?>{
      'type': 'array',
      'maxItems': 2000,
      'items': <String, Object?>{
        'type': 'object',
        'additionalProperties': false,
        'required': <Object?>[
          'guestId',
          'functionId',
          'rsvpStatus',
        ],
        'properties': <String, Object?>{
          'guestId': <String, Object?>{
            'type': 'string',
            'minLength': 1,
            'maxLength': 180,
          },
          'functionId': <String, Object?>{
            'type': 'string',
            'minLength': 1,
            'maxLength': 180,
          },
          'rsvpStatus': <String, Object?>{
            'type': 'string',
            'enum': <Object?>[
              'pending',
              'attending',
              'declined',
              'maybe',
            ],
          },
          'partySize': <String, Object?>{
            'type': <Object?>[
              'integer',
              'null',
            ],
            'minimum': 1,
            'maximum': 20,
          },
          'responseNote': <String, Object?>{
            'type': <Object?>[
              'string',
              'null',
            ],
            'maxLength': 500,
          },
        },
      },
    },
    'messagingConsent': <String, Object?>{
      'type': 'boolean',
      'description': 'The explicit household messaging-consent checkbox; recorded exactly as ticked.',
    },
  },
};
