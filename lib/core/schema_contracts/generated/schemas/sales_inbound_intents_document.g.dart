// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs
// ignore_for_file: constant_identifier_names, use_null_aware_elements

// JSON Schema constant emitted from firestore/sales_inbound_intents.schema.json.

const schemaSalesInboundIntentsDocumentSchema = <String, Object?>{
  '\$schema': 'http://json-schema.org/draft-07/schema#',
  '\$id': 'https://catch.app/contracts/firestore/sales_inbound_intents.schema.json',
  'title': 'SalesInboundIntentDocument',
  'description': 'Private self-reported host submission, immutable at capture and linked only after identity review.',
  'type': 'object',
  'additionalProperties': false,
  'x-firestore-collection': 'salesInboundIntents',
  'x-firestore-path': 'salesInboundIntents/{intentId}',
  'x-document-id-field': 'intentId',
  'x-owner': 'joinWaitlist and adminLinkSalesInboundIntent',
  'required': <Object?>[
    'schemaVersion',
    'revision',
    'classification',
    'intentId',
    'source',
    'submissionId',
    'requestHash',
    'waitlistId',
    'status',
    'organizerId',
    'evidenceStatus',
    'fullName',
    'email',
    'city',
    'entryRoute',
    'alreadyJoined',
    'hostApplication',
    'createdAt',
    'updatedAt',
  ],
  'properties': <String, Object?>{
    'schemaVersion': <String, Object?>{
      'const': 1,
    },
    'revision': <String, Object?>{
      'type': 'integer',
      'minimum': 1,
    },
    'classification': <String, Object?>{
      'const': 'sales_private',
    },
    'intentId': <String, Object?>{
      'type': 'string',
      'pattern': '^[a-f0-9]{64}\$',
    },
    'source': <String, Object?>{
      'const': 'website',
    },
    'submissionId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 160,
    },
    'requestHash': <String, Object?>{
      'type': 'string',
      'pattern': '^[a-f0-9]{64}\$',
    },
    'waitlistId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 512,
    },
    'status': <String, Object?>{
      'enum': <Object?>[
        'needs_identity_review',
        'linked',
        'dismissed',
      ],
    },
    'organizerId': <String, Object?>{
      'anyOf': <Object?>[
        <String, Object?>{
          'type': 'string',
          'minLength': 1,
          'maxLength': 128,
        },
        <String, Object?>{
          'type': 'null',
        },
      ],
    },
    'evidenceStatus': <String, Object?>{
      'const': 'self_reported',
    },
    'fullName': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 100,
    },
    'email': <String, Object?>{
      'type': 'string',
      'format': 'email',
      'maxLength': 320,
    },
    'city': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 80,
    },
    'entryRoute': <String, Object?>{
      'anyOf': <Object?>[
        <String, Object?>{
          'type': 'string',
          'maxLength': 512,
        },
        <String, Object?>{
          'type': 'null',
        },
      ],
    },
    'alreadyJoined': <String, Object?>{
      'type': 'boolean',
    },
    'hostApplication': <String, Object?>{
      'anyOf': <Object?>[
        <String, Object?>{
          'type': 'object',
          'additionalProperties': false,
          'properties': <String, Object?>{
            'organizationName': <String, Object?>{
              'anyOf': <Object?>[
                <String, Object?>{
                  'type': 'string',
                  'maxLength': 140,
                },
                <String, Object?>{
                  'type': 'null',
                },
              ],
            },
            'organizationType': <String, Object?>{
              'anyOf': <Object?>[
                <String, Object?>{
                  'type': 'string',
                  'maxLength': 80,
                },
                <String, Object?>{
                  'type': 'null',
                },
              ],
            },
            'operatingCity': <String, Object?>{
              'anyOf': <Object?>[
                <String, Object?>{
                  'type': 'string',
                  'maxLength': 80,
                },
                <String, Object?>{
                  'type': 'null',
                },
              ],
            },
            'communityLink': <String, Object?>{
              'anyOf': <Object?>[
                <String, Object?>{
                  'type': 'string',
                  'maxLength': 512,
                },
                <String, Object?>{
                  'type': 'null',
                },
              ],
            },
            'formats': <String, Object?>{
              'type': 'array',
              'maxItems': 10,
              'uniqueItems': true,
              'items': <String, Object?>{
                'type': 'string',
                'maxLength': 80,
              },
            },
            'eventCadence': <String, Object?>{
              'anyOf': <Object?>[
                <String, Object?>{
                  'type': 'string',
                  'maxLength': 80,
                },
                <String, Object?>{
                  'type': 'null',
                },
              ],
            },
            'nextEventName': <String, Object?>{
              'anyOf': <Object?>[
                <String, Object?>{
                  'type': 'string',
                  'maxLength': 160,
                },
                <String, Object?>{
                  'type': 'null',
                },
              ],
            },
            'nextEventDate': <String, Object?>{
              'anyOf': <Object?>[
                <String, Object?>{
                  'type': 'string',
                  'maxLength': 80,
                },
                <String, Object?>{
                  'type': 'null',
                },
              ],
            },
            'eventLocation': <String, Object?>{
              'anyOf': <Object?>[
                <String, Object?>{
                  'type': 'string',
                  'maxLength': 180,
                },
                <String, Object?>{
                  'type': 'null',
                },
              ],
            },
            'expectedCapacity': <String, Object?>{
              'anyOf': <Object?>[
                <String, Object?>{
                  'type': 'string',
                  'maxLength': 40,
                },
                <String, Object?>{
                  'type': 'null',
                },
              ],
            },
            'bookingPlatform': <String, Object?>{
              'anyOf': <Object?>[
                <String, Object?>{
                  'type': 'string',
                  'maxLength': 120,
                },
                <String, Object?>{
                  'type': 'null',
                },
              ],
            },
            'guestListFormat': <String, Object?>{
              'anyOf': <Object?>[
                <String, Object?>{
                  'type': 'string',
                  'maxLength': 120,
                },
                <String, Object?>{
                  'type': 'null',
                },
              ],
            },
            'priceRange': <String, Object?>{
              'anyOf': <Object?>[
                <String, Object?>{
                  'type': 'string',
                  'maxLength': 80,
                },
                <String, Object?>{
                  'type': 'null',
                },
              ],
            },
            'admissionModel': <String, Object?>{
              'anyOf': <Object?>[
                <String, Object?>{
                  'type': 'string',
                  'maxLength': 80,
                },
                <String, Object?>{
                  'type': 'null',
                },
              ],
            },
            'waitlistPlan': <String, Object?>{
              'anyOf': <Object?>[
                <String, Object?>{
                  'type': 'string',
                  'maxLength': 80,
                },
                <String, Object?>{
                  'type': 'null',
                },
              ],
            },
            'paymentReadiness': <String, Object?>{
              'anyOf': <Object?>[
                <String, Object?>{
                  'type': 'string',
                  'maxLength': 120,
                },
                <String, Object?>{
                  'type': 'null',
                },
              ],
            },
            'eventSuccessModules': <String, Object?>{
              'type': 'array',
              'maxItems': 16,
              'uniqueItems': true,
              'items': <String, Object?>{
                'type': 'string',
                'maxLength': 120,
              },
            },
            'hostGoals': <String, Object?>{
              'anyOf': <Object?>[
                <String, Object?>{
                  'type': 'string',
                  'maxLength': 1000,
                },
                <String, Object?>{
                  'type': 'null',
                },
              ],
            },
            'operatingNotes': <String, Object?>{
              'anyOf': <Object?>[
                <String, Object?>{
                  'type': 'string',
                  'maxLength': 1000,
                },
                <String, Object?>{
                  'type': 'null',
                },
              ],
            },
          },
        },
        <String, Object?>{
          'type': 'null',
        },
      ],
    },
    'createdAt': <String, Object?>{
      'type': 'object',
      'description': 'Serialized Firestore Timestamp fixture shape.',
      'x-firestore-type': 'timestamp',
      'additionalProperties': false,
      'required': <Object?>[
        '_seconds',
        '_nanoseconds',
      ],
      'properties': <String, Object?>{
        '_seconds': <String, Object?>{
          'type': 'integer',
        },
        '_nanoseconds': <String, Object?>{
          'type': 'integer',
          'minimum': 0,
          'maximum': 999999999,
        },
      },
    },
    'updatedAt': <String, Object?>{
      'type': 'object',
      'description': 'Serialized Firestore Timestamp fixture shape.',
      'x-firestore-type': 'timestamp',
      'additionalProperties': false,
      'required': <Object?>[
        '_seconds',
        '_nanoseconds',
      ],
      'properties': <String, Object?>{
        '_seconds': <String, Object?>{
          'type': 'integer',
        },
        '_nanoseconds': <String, Object?>{
          'type': 'integer',
          'minimum': 0,
          'maximum': 999999999,
        },
      },
    },
    'linkedAt': <String, Object?>{
      'type': 'object',
      'description': 'Serialized Firestore Timestamp fixture shape.',
      'x-firestore-type': 'timestamp',
      'additionalProperties': false,
      'required': <Object?>[
        '_seconds',
        '_nanoseconds',
      ],
      'properties': <String, Object?>{
        '_seconds': <String, Object?>{
          'type': 'integer',
        },
        '_nanoseconds': <String, Object?>{
          'type': 'integer',
          'minimum': 0,
          'maximum': 999999999,
        },
      },
    },
    'linkedBy': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 128,
    },
    'linkRequestId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 128,
    },
  },
  'allOf': <Object?>[
    <String, Object?>{
      'if': <String, Object?>{
        'properties': <String, Object?>{
          'status': <String, Object?>{
            'const': 'linked',
          },
        },
      },
      'then': <String, Object?>{
        'required': <Object?>[
          'linkedAt',
          'linkedBy',
          'linkRequestId',
        ],
        'properties': <String, Object?>{
          'organizerId': <String, Object?>{
            'type': 'string',
            'minLength': 1,
            'maxLength': 128,
          },
        },
      },
      'else': <String, Object?>{
        'properties': <String, Object?>{
          'organizerId': <String, Object?>{
            'type': 'null',
          },
        },
      },
    },
  ],
};
