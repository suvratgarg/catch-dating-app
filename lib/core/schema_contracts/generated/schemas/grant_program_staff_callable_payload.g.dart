// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs
// ignore_for_file: constant_identifier_names, use_null_aware_elements

// JSON Schema constant emitted from callables/grant_program_staff_payload.schema.json.

const schemaGrantProgramStaffCallablePayloadSchema = <String, Object?>{
  '\$schema': 'http://json-schema.org/draft-07/schema#',
  '\$id': 'https://catch.app/contracts/callables/grant_program_staff_payload.schema.json',
  'title': 'GrantProgramStaffCallablePayload',
  'description': 'Grant named, station-scoped program duties to a signed-in account. Manager-only.',
  'type': 'object',
  'additionalProperties': false,
  'required': <Object?>[
    'programId',
    'phoneNumber',
    'duties',
    'expiresAtMillis',
  ],
  'properties': <String, Object?>{
    'programId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
    },
    'phoneNumber': <String, Object?>{
      'type': 'string',
      'minLength': 4,
      'maxLength': 32,
    },
    'duties': <String, Object?>{
      'type': 'array',
      'minItems': 1,
      'maxItems': 8,
      'items': <String, Object?>{
        'type': 'object',
        'additionalProperties': false,
        'required': <Object?>[
          'duty',
          'pickupPointIds',
          'hotelIds',
        ],
        'properties': <String, Object?>{
          'duty': <String, Object?>{
            'type': 'string',
            'enum': <Object?>[
              'programCoordinator',
              'airportGreeter',
              'hotelDesk',
              'transportDispatcher',
              'reconciliationViewer',
            ],
          },
          'pickupPointIds': <String, Object?>{
            'type': 'array',
            'maxItems': 32,
            'uniqueItems': true,
            'items': <String, Object?>{
              'type': 'string',
              'minLength': 1,
              'maxLength': 180,
            },
            'description': 'Station scope for airportGreeter/transportDispatcher duties. Empty means all pickup points in the program.',
          },
          'hotelIds': <String, Object?>{
            'type': 'array',
            'maxItems': 64,
            'uniqueItems': true,
            'items': <String, Object?>{
              'type': 'string',
              'minLength': 1,
              'maxLength': 180,
            },
            'description': 'Hotel scope for hotelDesk duties. Empty means all hotels in the program.',
          },
        },
      },
    },
    'expiresAtMillis': <String, Object?>{
      'type': 'integer',
      'minimum': 0,
      'maximum': 9007199254740991,
    },
  },
};
