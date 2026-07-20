// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs
// ignore_for_file: constant_identifier_names, use_null_aware_elements

// JSON Schema constant emitted from callables/record_organizer_analytics_event_payload.schema.json.

const schemaRecordOrganizerAnalyticsEventCallablePayloadSchema = <String, Object?>{
  '\$schema': 'http://json-schema.org/draft-07/schema#',
  '\$id': 'https://catch.app/contracts/callables/record_organizer_analytics_event_payload.schema.json',
  'title': 'RecordOrganizerAnalyticsEventCallablePayload',
  'description': 'Public website analytics event for host-visible organizer metrics. The callable validates organizer scope and writes a raw, aggregate-safe event to BigQuery.',
  'type': 'object',
  'additionalProperties': false,
  'required': <Object?>[
    'organizerId',
    'eventName',
    'pagePath',
  ],
  'properties': <String, Object?>{
    'organizerId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
    },
    'clubId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
    },
    'eventId': <String, Object?>{
      'anyOf': <Object?>[
        <String, Object?>{
          'type': 'string',
          'minLength': 1,
          'maxLength': 180,
        },
        <String, Object?>{
          'type': 'null',
        },
      ],
    },
    'eventName': <String, Object?>{
      'type': 'string',
      'enum': <Object?>[
        'listingView',
        'searchAppearance',
        'eventView',
        'organizerSave',
        'eventSave',
        'contactClick',
        'claimClick',
        'outboundClick',
      ],
    },
    'pagePath': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 240,
    },
    'source': <String, Object?>{
      'type': <Object?>[
        'string',
        'null',
      ],
      'maxLength': 80,
    },
    'sessionId': <String, Object?>{
      'type': <Object?>[
        'string',
        'null',
      ],
      'maxLength': 80,
    },
    'platform': <String, Object?>{
      'type': <Object?>[
        'string',
        'null',
      ],
      'maxLength': 40,
    },
  },
};
