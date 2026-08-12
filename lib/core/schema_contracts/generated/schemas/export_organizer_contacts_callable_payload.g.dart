// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs
// ignore_for_file: constant_identifier_names, use_null_aware_elements

// JSON Schema constant emitted from callables/export_organizer_contacts_payload.schema.json.

const schemaExportOrganizerContactsCallablePayloadSchema = <String, Object?>{
  '\$schema': 'http://json-schema.org/draft-07/schema#',
  '\$id': 'https://catch.app/contracts/callables/export_organizer_contacts_payload.schema.json',
  'title': 'ExportOrganizerContactsCallablePayload',
  'description': 'Manager-only bounded organizer audience export request.',
  'type': 'object',
  'additionalProperties': false,
  'required': <Object?>[
    'organizerId',
  ],
  'properties': <String, Object?>{
    'organizerId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
    },
    'segmentId': <String, Object?>{
      'anyOf': <Object?>[
        <String, Object?>{
          'type': 'string',
          'enum': <Object?>[
            'new_to_organizer',
            'first_time_attendee',
            'repeat_attendee',
            'regular',
            'lapsed_regular',
            'reliable_attendee',
            'needs_confirmation',
            'advocate',
            'high_impact_advocate',
            'whatsapp_reachable',
            'sms_reachable',
          ],
        },
        <String, Object?>{
          'type': 'null',
        },
      ],
    },
  },
};
