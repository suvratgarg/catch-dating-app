// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs
// ignore_for_file: constant_identifier_names, use_null_aware_elements

// JSON Schema constant emitted from callables/upsert_program_household_payload.schema.json.

const schemaUpsertProgramHouseholdCallablePayloadSchema = <String, Object?>{
  '\$schema': 'http://json-schema.org/draft-07/schema#',
  '\$id': 'https://catch.app/contracts/callables/upsert_program_household_payload.schema.json',
  'title': 'UpsertProgramHouseholdCallablePayload',
  'description': 'Create or update a household/party grouping for program guests.',
  'type': 'object',
  'additionalProperties': false,
  'required': <Object?>[
    'programId',
    'label',
    'primaryContactName',
    'memberGuestIds',
  ],
  'properties': <String, Object?>{
    'programId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
    },
    'householdId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
    },
    'expectedRevision': <String, Object?>{
      'type': 'integer',
      'minimum': 1,
      'maximum': 9007199254740991,
    },
    'label': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 140,
    },
    'primaryContactName': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 140,
    },
    'primaryPhoneE164': <String, Object?>{
      'type': <Object?>[
        'string',
        'null',
      ],
      'maxLength': 20,
    },
    'primaryEmail': <String, Object?>{
      'type': <Object?>[
        'string',
        'null',
      ],
      'maxLength': 320,
    },
    'memberGuestIds': <String, Object?>{
      'type': 'array',
      'minItems': 1,
      'maxItems': 50,
      'uniqueItems': true,
      'items': <String, Object?>{
        'type': 'string',
        'minLength': 1,
        'maxLength': 180,
      },
    },
    'deliveryPreference': <String, Object?>{
      'type': 'string',
      'enum': <Object?>[
        'whatsapp',
        'sms',
        'email',
        'none',
      ],
    },
  },
};
