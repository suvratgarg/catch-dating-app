// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs
// ignore_for_file: constant_identifier_names, use_null_aware_elements

// JSON Schema constant emitted from callable_responses/program_guest_list_response.schema.json.

const schemaProgramGuestListCallableResponseSchema = <String, Object?>{
  '\$schema': 'http://json-schema.org/draft-07/schema#',
  '\$id': 'https://catch.app/contracts/callable_responses/program_guest_list_response.schema.json',
  'title': 'ProgramGuestListCallableResponse',
  'description': 'Manager/coordinator guest inventory with household labels. Contact fields are present because this surface requires the programCoordinator duty or organizer management.',
  'type': 'object',
  'additionalProperties': false,
  'required': <Object?>[
    'programId',
    'guests',
    'households',
    'nextCursor',
  ],
  'properties': <String, Object?>{
    'programId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
    },
    'guests': <String, Object?>{
      'type': 'array',
      'maxItems': 200,
      'items': <String, Object?>{
        'type': 'object',
        'additionalProperties': false,
        'required': <Object?>[
          'guestId',
          'displayName',
          'householdId',
          'phoneE164',
          'email',
          'externalReference',
          'invitationStatus',
          'rsvpStatus',
          'revision',
        ],
        'properties': <String, Object?>{
          'guestId': <String, Object?>{
            'type': 'string',
            'minLength': 1,
            'maxLength': 180,
          },
          'displayName': <String, Object?>{
            'type': 'string',
            'minLength': 1,
            'maxLength': 140,
          },
          'householdId': <String, Object?>{
            'type': <Object?>[
              'string',
              'null',
            ],
            'maxLength': 180,
          },
          'phoneE164': <String, Object?>{
            'type': <Object?>[
              'string',
              'null',
            ],
            'maxLength': 20,
          },
          'email': <String, Object?>{
            'type': <Object?>[
              'string',
              'null',
            ],
            'maxLength': 320,
          },
          'externalReference': <String, Object?>{
            'type': <Object?>[
              'string',
              'null',
            ],
            'maxLength': 180,
          },
          'invitationStatus': <String, Object?>{
            'type': 'string',
            'enum': <Object?>[
              'notInvited',
              'invited',
              'delivered',
              'responded',
            ],
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
          'revision': <String, Object?>{
            'type': 'integer',
            'minimum': 1,
          },
        },
      },
    },
    'households': <String, Object?>{
      'type': 'array',
      'maxItems': 500,
      'items': <String, Object?>{
        'type': 'object',
        'additionalProperties': false,
        'required': <Object?>[
          'householdId',
          'label',
          'memberGuestIds',
          'revision',
        ],
        'properties': <String, Object?>{
          'householdId': <String, Object?>{
            'type': 'string',
            'minLength': 1,
            'maxLength': 180,
          },
          'label': <String, Object?>{
            'type': 'string',
            'minLength': 1,
            'maxLength': 140,
          },
          'memberGuestIds': <String, Object?>{
            'type': 'array',
            'maxItems': 50,
            'items': <String, Object?>{
              'type': 'string',
              'minLength': 1,
              'maxLength': 180,
            },
          },
          'revision': <String, Object?>{
            'type': 'integer',
            'minimum': 1,
          },
        },
      },
    },
    'nextCursor': <String, Object?>{
      'type': <Object?>[
        'string',
        'null',
      ],
      'maxLength': 240,
    },
  },
};
