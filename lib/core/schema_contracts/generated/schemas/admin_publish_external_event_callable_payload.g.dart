// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs
// ignore_for_file: constant_identifier_names, use_null_aware_elements

// JSON Schema constant emitted from callables/admin_publish_external_event_payload.schema.json.

const schemaAdminPublishExternalEventCallablePayloadSchema = <String, Object?>{
  '\$schema': 'http://json-schema.org/draft-07/schema#',
  '\$id': 'https://catch.app/contracts/callables/admin_publish_external_event_payload.schema.json',
  'title': 'AdminPublishExternalEventCallablePayload',
  'description': 'Callable payload accepted by adminPublishExternalEvent. This publishes one preflight-approved read-only externalEvents/{eventId} document from eventSupplyReadiness/current.',
  'type': 'object',
  'additionalProperties': false,
  'required': <Object?>[
    'sourceActionId',
    'targetPath',
    'reviewNote',
    'checklist',
  ],
  'properties': <String, Object?>{
    'sourceActionId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 240,
    },
    'targetPath': <String, Object?>{
      'type': 'string',
      'pattern': '^externalEvents/[A-Za-z0-9_-]{1,180}\$',
    },
    'reviewNote': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 1000,
    },
    'checklist': <String, Object?>{
      'type': 'object',
      'additionalProperties': false,
      'required': <Object?>[
        'preflightActionReviewed',
        'outboundLinksReviewed',
        'noCatchBookingPaymentsWaitlist',
        'ownerSafeCopyReviewed',
      ],
      'properties': <String, Object?>{
        'preflightActionReviewed': <String, Object?>{
          'type': 'boolean',
        },
        'outboundLinksReviewed': <String, Object?>{
          'type': 'boolean',
        },
        'noCatchBookingPaymentsWaitlist': <String, Object?>{
          'type': 'boolean',
        },
        'ownerSafeCopyReviewed': <String, Object?>{
          'type': 'boolean',
        },
      },
    },
  },
};
