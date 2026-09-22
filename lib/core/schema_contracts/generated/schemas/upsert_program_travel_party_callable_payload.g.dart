// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs
// ignore_for_file: constant_identifier_names, use_null_aware_elements

// JSON Schema constant emitted from callables/upsert_program_travel_party_payload.schema.json.

const schemaUpsertProgramTravelPartyCallablePayloadSchema = <String, Object?>{
  '\$schema': 'http://json-schema.org/draft-07/schema#',
  '\$id': 'https://catch.app/contracts/callables/upsert_program_travel_party_payload.schema.json',
  'title': 'UpsertProgramTravelPartyCallablePayload',
  'description': 'Create or update a ride-together travel party.',
  'type': 'object',
  'additionalProperties': false,
  'required': <Object?>[
    'programId',
    'memberGuestIds',
    'dedicatedVehicle',
  ],
  'properties': <String, Object?>{
    'programId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
    },
    'partyId': <String, Object?>{
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
      'type': <Object?>[
        'string',
        'null',
      ],
      'maxLength': 140,
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
      'description': 'One to fifty people traveling together. A one-person party supports private transfers and staged manifest imports.',
    },
    'dedicatedVehicle': <String, Object?>{
      'type': 'boolean',
    },
  },
};
