// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs
// ignore_for_file: constant_identifier_names, use_null_aware_elements

// JSON Schema constant emitted from callable_responses/program_staff_list_response.schema.json.

const schemaProgramStaffListCallableResponseSchema = <String, Object?>{
  '\$schema': 'http://json-schema.org/draft-07/schema#',
  '\$id': 'https://catch.app/contracts/callable_responses/program_staff_list_response.schema.json',
  'title': 'ProgramStaffListCallableResponse',
  'description': 'Manager\'s view of program staff grants.',
  'type': 'object',
  'additionalProperties': false,
  'required': <Object?>[
    'programId',
    'members',
  ],
  'properties': <String, Object?>{
    'programId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
    },
    'members': <String, Object?>{
      'type': 'array',
      'maxItems': 100,
      'items': <String, Object?>{
        'type': 'object',
        'additionalProperties': false,
        'required': <Object?>[
          'uid',
          'displayName',
          'phoneLastFour',
          'duties',
          'status',
          'expiresAtMillis',
          'revision',
        ],
        'properties': <String, Object?>{
          'uid': <String, Object?>{
            'type': 'string',
            'minLength': 1,
            'maxLength': 180,
          },
          'displayName': <String, Object?>{
            'type': 'string',
            'minLength': 1,
            'maxLength': 120,
          },
          'phoneLastFour': <String, Object?>{
            'type': 'string',
            'pattern': '^[0-9]{4}\$',
          },
          'duties': <String, Object?>{
            'type': 'array',
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
          'status': <String, Object?>{
            'type': 'string',
            'enum': <Object?>[
              'active',
              'expired',
              'revoked',
            ],
          },
          'expiresAtMillis': <String, Object?>{
            'type': 'integer',
            'minimum': 0,
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
