// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs
// ignore_for_file: constant_identifier_names, use_null_aware_elements

// JSON Schema constant emitted from callables/admin_resolve_organizer_event_location_payload.schema.json.

const schemaAdminResolveOrganizerEventLocationCallablePayloadSchema = <String, Object?>{
  '\$schema': 'http://json-schema.org/draft-07/schema#',
  '\$id': 'https://catch.app/contracts/callables/admin_resolve_organizer_event_location_payload.schema.json',
  'title': 'AdminResolveOrganizerEventLocationCallablePayload',
  'description': 'Callable payload accepted by adminResolveOrganizerEventLocation. This records reviewed coordinates for a private external event candidate without importing the event.',
  'type': 'object',
  'additionalProperties': false,
  'required': <Object?>[
    'candidateId',
    'location',
    'checklist',
    'note',
  ],
  'properties': <String, Object?>{
    'candidateId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 240,
    },
    'location': <String, Object?>{
      'type': 'object',
      'additionalProperties': false,
      'required': <Object?>[
        'name',
        'latitude',
        'longitude',
      ],
      'properties': <String, Object?>{
        'name': <String, Object?>{
          'type': 'string',
          'minLength': 1,
          'maxLength': 240,
        },
        'address': <String, Object?>{
          'type': <Object?>[
            'string',
            'null',
          ],
          'maxLength': 500,
        },
        'placeId': <String, Object?>{
          'type': <Object?>[
            'string',
            'null',
          ],
          'minLength': 1,
          'maxLength': 256,
        },
        'latitude': <String, Object?>{
          'type': <Object?>[
            'number',
            'null',
          ],
          'minimum': -90,
          'maximum': 90,
        },
        'longitude': <String, Object?>{
          'type': <Object?>[
            'number',
            'null',
          ],
          'minimum': -180,
          'maximum': 180,
        },
        'notes': <String, Object?>{
          'type': <Object?>[
            'string',
            'null',
          ],
          'maxLength': 1000,
        },
      },
    },
    'checklist': <String, Object?>{
      'type': 'object',
      'additionalProperties': false,
      'required': <Object?>[
        'sourceLocationReviewed',
        'coordinatesReviewed',
        'placeIdentityReviewed',
        'importSafetyReviewed',
      ],
      'properties': <String, Object?>{
        'sourceLocationReviewed': <String, Object?>{
          'type': 'boolean',
        },
        'coordinatesReviewed': <String, Object?>{
          'type': 'boolean',
        },
        'placeIdentityReviewed': <String, Object?>{
          'type': 'boolean',
        },
        'importSafetyReviewed': <String, Object?>{
          'type': 'boolean',
        },
      },
    },
    'note': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 1000,
    },
  },
};
