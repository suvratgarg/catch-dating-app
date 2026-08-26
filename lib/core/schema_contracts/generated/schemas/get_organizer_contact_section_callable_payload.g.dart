// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs
// ignore_for_file: constant_identifier_names, use_null_aware_elements

// JSON Schema constant emitted from callables/get_organizer_contact_section_payload.schema.json.

const schemaGetOrganizerContactSectionCallablePayloadSchema = <String, Object?>{
  '\$schema': 'http://json-schema.org/draft-07/schema#',
  '\$id': 'https://catch.app/contracts/callables/get_organizer_contact_section_payload.schema.json',
  'title': 'GetOrganizerContactSectionCallablePayload',
  'description': 'Manager-authorized request for one independently loadable organizer contact section.',
  'type': 'object',
  'additionalProperties': false,
  'required': <Object?>[
    'organizerId',
    'contactId',
    'section',
  ],
  'properties': <String, Object?>{
    'organizerId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
    },
    'contactId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
    },
    'section': <String, Object?>{
      'type': 'string',
      'enum': <Object?>[
        'overview',
        'history',
      ],
    },
  },
};
