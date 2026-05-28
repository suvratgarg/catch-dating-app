// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs
// ignore_for_file: constant_identifier_names, use_null_aware_elements

// JSON Schema constant emitted from callables/explore_search_payload.schema.json.

const schemaExploreSearchCallablePayloadSchema = <String, Object?>{
  '\$schema': 'http://json-schema.org/draft-07/schema#',
  '\$id': 'https://catch.app/contracts/callables/explore_search_payload.schema.json',
  'title': 'ExploreSearchCallablePayload',
  'description': 'Callable payload accepted by exploreSearch.',
  'type': 'object',
  'additionalProperties': false,
  'required': <Object?>[
    'query',
  ],
  'properties': <String, Object?>{
    'query': <String, Object?>{
      'type': 'string',
      'minLength': 2,
      'maxLength': 120,
    },
    'cityName': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 120,
    },
    'limit': <String, Object?>{
      'type': 'integer',
      'minimum': 1,
      'maximum': 50,
    },
  },
};
