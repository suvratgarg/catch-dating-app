// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs
// ignore_for_file: constant_identifier_names, use_null_aware_elements

// JSON Schema constant emitted from callables/register_public_event_payload.schema.json.

const schemaRegisterPublicEventCallablePayloadSchema = <String, Object?>{
  '\$schema': 'http://json-schema.org/draft-07/schema#',
  '\$id': 'https://catch.app/contracts/callables/register_public_event_payload.schema.json',
  'title': 'RegisterPublicEventCallablePayload',
  'description': 'Phone-authenticated website registration for a published Catch event without a Consumer profile.',
  'type': 'object',
  'additionalProperties': false,
  'required': <Object?>[
    'eventId',
    'displayName',
  ],
  'properties': <String, Object?>{
    'eventId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
    },
    'displayName': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 120,
    },
  },
};
