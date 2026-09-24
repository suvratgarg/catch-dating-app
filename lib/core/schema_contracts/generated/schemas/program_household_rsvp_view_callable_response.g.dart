// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs
// ignore_for_file: constant_identifier_names, use_null_aware_elements

// JSON Schema constant emitted from callable_responses/program_household_rsvp_view_response.schema.json.

const schemaProgramHouseholdRsvpViewCallableResponseSchema = <String, Object?>{
  '\$schema': 'http://json-schema.org/draft-07/schema#',
  '\$id': 'https://catch.app/contracts/callable_responses/program_household_rsvp_view_response.schema.json',
  'title': 'ProgramHouseholdRsvpViewCallableResponse',
  'description': 'The household\'s RSVP page model: program display facts, consent state, and each member\'s invited functions with current responses. Contains no data outside the token\'s household.',
  'type': 'object',
  'additionalProperties': false,
  'x-callable-aliases': <Object?>[
    'getProgramHouseholdRsvpView',
  ],
  'required': <Object?>[
    'programId',
    'programTitle',
    'timezone',
    'householdId',
    'householdLabel',
    'messagingConsentGranted',
    'members',
  ],
  'properties': <String, Object?>{
    'programId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
    },
    'programTitle': <String, Object?>{
      'type': 'string',
      'maxLength': 140,
    },
    'timezone': <String, Object?>{
      'type': 'string',
      'maxLength': 64,
    },
    'householdId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
    },
    'householdLabel': <String, Object?>{
      'type': 'string',
      'maxLength': 140,
    },
    'messagingConsentGranted': <String, Object?>{
      'type': 'boolean',
      'description': 'Current consent state so the page can pre-tick.',
    },
    'members': <String, Object?>{
      'type': 'array',
      'items': <String, Object?>{
        'type': 'object',
        'additionalProperties': false,
        'required': <Object?>[
          'guestId',
          'displayName',
          'functions',
        ],
        'properties': <String, Object?>{
          'guestId': <String, Object?>{
            'type': 'string',
            'minLength': 1,
            'maxLength': 180,
          },
          'displayName': <String, Object?>{
            'type': 'string',
            'maxLength': 140,
          },
          'functions': <String, Object?>{
            'type': 'array',
            'items': <String, Object?>{
              'type': 'object',
              'additionalProperties': false,
              'required': <Object?>[
                'functionId',
                'name',
                'startsAtMillis',
                'endsAtMillis',
                'rsvpStatus',
                'partySize',
                'responseNote',
              ],
              'properties': <String, Object?>{
                'functionId': <String, Object?>{
                  'type': 'string',
                  'minLength': 1,
                  'maxLength': 180,
                },
                'name': <String, Object?>{
                  'type': 'string',
                  'maxLength': 140,
                },
                'startsAtMillis': <String, Object?>{
                  'type': 'integer',
                  'minimum': 0,
                  'maximum': 9007199254740991,
                },
                'endsAtMillis': <String, Object?>{
                  'type': 'integer',
                  'minimum': 0,
                  'maximum': 9007199254740991,
                },
                'venueName': <String, Object?>{
                  'type': <Object?>[
                    'string',
                    'null',
                  ],
                  'maxLength': 140,
                },
                'dressCode': <String, Object?>{
                  'type': <Object?>[
                    'string',
                    'null',
                  ],
                  'maxLength': 140,
                },
                'instructions': <String, Object?>{
                  'type': <Object?>[
                    'string',
                    'null',
                  ],
                  'maxLength': 1000,
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
        },
      },
    },
  },
};
