// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs
// ignore_for_file: constant_identifier_names, use_null_aware_elements

// JSON Schema constant emitted from callable_responses/private_event_setup_response.schema.json.

const schemaPrivateEventSetupCallableResponseSchema = <String, Object?>{
  '\$schema': 'http://json-schema.org/draft-07/schema#',
  '\$id': 'https://catch.app/contracts/callable_responses/private_event_setup_response.schema.json',
  'title': 'PrivateEventSetupCallableResponse',
  'type': 'object',
  'additionalProperties': false,
  'required': <Object?>[
    'eventId',
    'organizerId',
    'setupRevision',
    'name',
    'city',
    'localDate',
    'localStartTime',
    'timezone',
    'startTimeMillis',
    'publicationState',
    'status',
    'setupDefaults',
    'detailsConfigured',
    'eventPreferences',
  ],
  'properties': <String, Object?>{
    'eventId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
    },
    'organizerId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
    },
    'setupRevision': <String, Object?>{
      'type': 'integer',
      'minimum': 1,
    },
    'name': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 120,
    },
    'city': <String, Object?>{
      'type': 'object',
      'additionalProperties': false,
      'required': <Object?>[
        'cityId',
        'marketId',
      ],
      'properties': <String, Object?>{
        'cityId': <String, Object?>{
          'type': 'string',
          'minLength': 1,
          'maxLength': 180,
        },
        'marketId': <String, Object?>{
          'type': 'string',
          'minLength': 1,
          'maxLength': 180,
        },
      },
    },
    'localDate': <String, Object?>{
      'type': 'string',
      'pattern': '^[0-9]{4}-[0-9]{2}-[0-9]{2}\$',
    },
    'localStartTime': <String, Object?>{
      'type': 'string',
      'pattern': '^[0-9]{2}:[0-9]{2}\$',
    },
    'timezone': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 100,
    },
    'startTimeMillis': <String, Object?>{
      'type': 'integer',
    },
    'publicationState': <String, Object?>{
      'type': 'string',
      'const': 'private',
    },
    'status': <String, Object?>{
      'type': 'string',
      'enum': <Object?>[
        'active',
        'cancelled',
      ],
    },
    'setupDefaults': <String, Object?>{
      'title': 'EventSetupDefaults',
      'type': 'object',
      'additionalProperties': false,
      'required': <Object?>[
        'city',
        'timezone',
        'organizerDefaultsRevision',
        'organizerDefaultsHash',
      ],
      'properties': <String, Object?>{
        'city': <String, Object?>{
          'type': 'object',
          'additionalProperties': false,
          'required': <Object?>[
            'value',
            'source',
          ],
          'properties': <String, Object?>{
            'value': <String, Object?>{
              'type': 'object',
              'additionalProperties': false,
              'required': <Object?>[
                'cityId',
                'marketId',
              ],
              'properties': <String, Object?>{
                'cityId': <String, Object?>{
                  'type': 'string',
                  'minLength': 1,
                  'maxLength': 180,
                },
                'marketId': <String, Object?>{
                  'type': 'string',
                  'minLength': 1,
                  'maxLength': 180,
                },
              },
            },
            'source': <String, Object?>{
              'type': 'string',
              'enum': <Object?>[
                'organizer',
                'event',
              ],
            },
          },
        },
        'timezone': <String, Object?>{
          'type': 'object',
          'additionalProperties': false,
          'required': <Object?>[
            'value',
            'source',
          ],
          'properties': <String, Object?>{
            'value': <String, Object?>{
              'type': 'string',
              'minLength': 1,
              'maxLength': 100,
            },
            'source': <String, Object?>{
              'type': 'string',
              'enum': <Object?>[
                'organizer',
                'event',
              ],
            },
          },
        },
        'organizerDefaultsRevision': <String, Object?>{
          'type': <Object?>[
            'integer',
            'null',
          ],
          'minimum': 0,
        },
        'organizerDefaultsHash': <String, Object?>{
          'type': 'string',
          'pattern': '^[a-f0-9]{64}\$',
        },
      },
      'definitions': <String, Object?>{
        'basicsInput': <String, Object?>{
          'type': 'object',
          'additionalProperties': false,
          'required': <Object?>[
            'name',
            'city',
            'localDate',
            'localStartTime',
            'timezone',
          ],
          'properties': <String, Object?>{
            'name': <String, Object?>{
              'type': 'string',
              'minLength': 1,
              'maxLength': 120,
            },
            'city': <String, Object?>{
              'oneOf': <Object?>[
                <String, Object?>{
                  'type': 'object',
                  'additionalProperties': false,
                  'required': <Object?>[
                    'mode',
                  ],
                  'properties': <String, Object?>{
                    'mode': <String, Object?>{
                      'const': 'inherit',
                      'type': 'string',
                    },
                  },
                },
                <String, Object?>{
                  'type': 'object',
                  'additionalProperties': false,
                  'required': <Object?>[
                    'mode',
                    'value',
                  ],
                  'properties': <String, Object?>{
                    'mode': <String, Object?>{
                      'const': 'set',
                      'type': 'string',
                    },
                    'value': <String, Object?>{
                      'type': 'object',
                      'additionalProperties': false,
                      'required': <Object?>[
                        'cityId',
                        'marketId',
                      ],
                      'properties': <String, Object?>{
                        'cityId': <String, Object?>{
                          'type': 'string',
                          'minLength': 1,
                          'maxLength': 180,
                        },
                        'marketId': <String, Object?>{
                          'type': 'string',
                          'minLength': 1,
                          'maxLength': 180,
                        },
                      },
                    },
                  },
                },
              ],
            },
            'localDate': <String, Object?>{
              'type': 'string',
              'pattern': '^[0-9]{4}-[0-9]{2}-[0-9]{2}\$',
            },
            'localStartTime': <String, Object?>{
              'type': 'string',
              'pattern': '^[0-9]{2}:[0-9]{2}\$',
            },
            'timezone': <String, Object?>{
              'oneOf': <Object?>[
                <String, Object?>{
                  'type': 'object',
                  'additionalProperties': false,
                  'required': <Object?>[
                    'mode',
                  ],
                  'properties': <String, Object?>{
                    'mode': <String, Object?>{
                      'const': 'inherit',
                      'type': 'string',
                    },
                  },
                },
                <String, Object?>{
                  'type': 'object',
                  'additionalProperties': false,
                  'required': <Object?>[
                    'mode',
                    'value',
                  ],
                  'properties': <String, Object?>{
                    'mode': <String, Object?>{
                      'const': 'set',
                      'type': 'string',
                    },
                    'value': <String, Object?>{
                      'type': 'string',
                      'minLength': 1,
                      'maxLength': 100,
                    },
                  },
                },
              ],
            },
            'reviewedDefaultsHash': <String, Object?>{
              'type': 'string',
              'pattern': '^[a-f0-9]{64}\$',
            },
          },
        },
      },
    },
    'detailsConfigured': <String, Object?>{
      'type': 'boolean',
    },
    'eventPreferences': <String, Object?>{
      'anyOf': <Object?>[
        <String, Object?>{
          'type': 'object',
          'additionalProperties': false,
          'required': <Object?>[
            'revision',
            'preferences',
            'paymentTerms',
          ],
          'properties': <String, Object?>{
            'revision': <String, Object?>{
              'type': 'integer',
              'minimum': 1,
              'maximum': 1000000000,
            },
            'preferences': <String, Object?>{
              'title': 'ResolvedEventPreferences',
              'type': 'object',
              'additionalProperties': false,
              'required': <Object?>[
                'defaultsRevision',
                'defaultsHash',
                'usualDurationMinutes',
                'preferredVenueId',
                'offerValidityMinutes',
                'collectionPreference',
                'currency',
                'offerMessageTemplate',
                'paymentInstructions',
                'reusablePaymentPage',
                'admissionPreset',
                'expectedAmountMinor',
              ],
              'properties': <String, Object?>{
                'defaultsRevision': <String, Object?>{
                  'type': 'integer',
                  'minimum': 0,
                  'maximum': 1000000000,
                },
                'defaultsHash': <String, Object?>{
                  'type': 'string',
                  'pattern': '^[a-f0-9]{64}\$',
                },
                'usualDurationMinutes': <String, Object?>{
                  'type': 'object',
                  'additionalProperties': false,
                  'required': <Object?>[
                    'value',
                    'source',
                  ],
                  'properties': <String, Object?>{
                    'value': <String, Object?>{
                      'anyOf': <Object?>[
                        <String, Object?>{
                          'type': 'integer',
                          'minimum': 15,
                          'maximum': 240,
                        },
                        <String, Object?>{
                          'type': 'null',
                        },
                      ],
                    },
                    'source': <String, Object?>{
                      'type': 'string',
                      'enum': <Object?>[
                        'organizer',
                        'event',
                        'cleared',
                      ],
                    },
                  },
                },
                'preferredVenueId': <String, Object?>{
                  'type': 'object',
                  'additionalProperties': false,
                  'required': <Object?>[
                    'value',
                    'source',
                  ],
                  'properties': <String, Object?>{
                    'value': <String, Object?>{
                      'anyOf': <Object?>[
                        <String, Object?>{
                          'type': 'string',
                          'pattern': '^[A-Za-z0-9][A-Za-z0-9_-]{0,119}\$',
                        },
                        <String, Object?>{
                          'type': 'null',
                        },
                      ],
                    },
                    'source': <String, Object?>{
                      'type': 'string',
                      'enum': <Object?>[
                        'organizer',
                        'event',
                        'cleared',
                      ],
                    },
                  },
                },
                'offerValidityMinutes': <String, Object?>{
                  'type': 'object',
                  'additionalProperties': false,
                  'required': <Object?>[
                    'value',
                    'source',
                  ],
                  'properties': <String, Object?>{
                    'value': <String, Object?>{
                      'anyOf': <Object?>[
                        <String, Object?>{
                          'type': 'integer',
                          'minimum': 5,
                          'maximum': 10080,
                        },
                        <String, Object?>{
                          'type': 'null',
                        },
                      ],
                    },
                    'source': <String, Object?>{
                      'type': 'string',
                      'enum': <Object?>[
                        'organizer',
                        'event',
                        'cleared',
                      ],
                    },
                  },
                },
                'collectionPreference': <String, Object?>{
                  'type': 'object',
                  'additionalProperties': false,
                  'required': <Object?>[
                    'value',
                    'source',
                  ],
                  'properties': <String, Object?>{
                    'value': <String, Object?>{
                      'anyOf': <Object?>[
                        <String, Object?>{
                          'type': 'string',
                          'enum': <Object?>[
                            'manualInstructions',
                            'reusablePage',
                            'personalRequest',
                            'catchCheckout',
                          ],
                        },
                        <String, Object?>{
                          'type': 'null',
                        },
                      ],
                    },
                    'source': <String, Object?>{
                      'type': 'string',
                      'enum': <Object?>[
                        'organizer',
                        'event',
                        'cleared',
                      ],
                    },
                  },
                },
                'currency': <String, Object?>{
                  'type': 'object',
                  'additionalProperties': false,
                  'required': <Object?>[
                    'value',
                    'source',
                  ],
                  'properties': <String, Object?>{
                    'value': <String, Object?>{
                      'anyOf': <Object?>[
                        <String, Object?>{
                          'type': 'string',
                          'pattern': '^[A-Z]{3}\$',
                        },
                        <String, Object?>{
                          'type': 'null',
                        },
                      ],
                    },
                    'source': <String, Object?>{
                      'type': 'string',
                      'enum': <Object?>[
                        'organizer',
                        'event',
                        'cleared',
                      ],
                    },
                  },
                },
                'offerMessageTemplate': <String, Object?>{
                  'type': 'object',
                  'additionalProperties': false,
                  'required': <Object?>[
                    'value',
                    'source',
                  ],
                  'properties': <String, Object?>{
                    'value': <String, Object?>{
                      'anyOf': <Object?>[
                        <String, Object?>{
                          'type': 'string',
                          'minLength': 1,
                          'maxLength': 1000,
                        },
                        <String, Object?>{
                          'type': 'null',
                        },
                      ],
                    },
                    'source': <String, Object?>{
                      'type': 'string',
                      'enum': <Object?>[
                        'organizer',
                        'event',
                        'cleared',
                      ],
                    },
                  },
                },
                'paymentInstructions': <String, Object?>{
                  'type': 'object',
                  'additionalProperties': false,
                  'required': <Object?>[
                    'value',
                    'source',
                  ],
                  'properties': <String, Object?>{
                    'value': <String, Object?>{
                      'anyOf': <Object?>[
                        <String, Object?>{
                          'type': 'string',
                          'minLength': 1,
                          'maxLength': 1000,
                        },
                        <String, Object?>{
                          'type': 'null',
                        },
                      ],
                    },
                    'source': <String, Object?>{
                      'type': 'string',
                      'enum': <Object?>[
                        'organizer',
                        'event',
                        'cleared',
                      ],
                    },
                  },
                },
                'reusablePaymentPage': <String, Object?>{
                  'type': 'object',
                  'additionalProperties': false,
                  'required': <Object?>[
                    'value',
                    'source',
                  ],
                  'properties': <String, Object?>{
                    'value': <String, Object?>{
                      'anyOf': <Object?>[
                        <String, Object?>{
                          'type': 'object',
                          'additionalProperties': false,
                          'required': <Object?>[
                            'url',
                            'reusableForEvents',
                          ],
                          'properties': <String, Object?>{
                            'url': <String, Object?>{
                              'type': 'string',
                              'format': 'uri',
                              'maxLength': 2048,
                            },
                            'reusableForEvents': <String, Object?>{
                              'type': 'boolean',
                              'const': true,
                            },
                          },
                        },
                        <String, Object?>{
                          'type': 'null',
                        },
                      ],
                    },
                    'source': <String, Object?>{
                      'type': 'string',
                      'enum': <Object?>[
                        'organizer',
                        'event',
                        'cleared',
                      ],
                    },
                  },
                },
                'admissionPreset': <String, Object?>{
                  'type': 'object',
                  'additionalProperties': false,
                  'required': <Object?>[
                    'value',
                    'source',
                  ],
                  'properties': <String, Object?>{
                    'value': <String, Object?>{
                      'anyOf': <Object?>[
                        <String, Object?>{
                          'type': 'string',
                          'enum': <Object?>[
                            'openCapacity',
                            'inviteOnly',
                            'balancedSingles',
                            'fixedCohortCaps',
                          ],
                        },
                        <String, Object?>{
                          'type': 'null',
                        },
                      ],
                    },
                    'source': <String, Object?>{
                      'type': 'string',
                      'enum': <Object?>[
                        'organizer',
                        'event',
                        'cleared',
                      ],
                    },
                  },
                },
                'expectedAmountMinor': <String, Object?>{
                  'type': 'object',
                  'additionalProperties': false,
                  'required': <Object?>[
                    'value',
                    'source',
                  ],
                  'properties': <String, Object?>{
                    'value': <String, Object?>{
                      'anyOf': <Object?>[
                        <String, Object?>{
                          'type': 'integer',
                          'minimum': 0,
                          'maximum': 100000000,
                        },
                        <String, Object?>{
                          'type': 'null',
                        },
                      ],
                    },
                    'source': <String, Object?>{
                      'type': 'string',
                      'enum': <Object?>[
                        'organizer',
                        'event',
                        'cleared',
                      ],
                    },
                  },
                },
              },
            },
            'paymentTerms': <String, Object?>{
              'title': 'EventPaymentTerms',
              'type': 'object',
              'additionalProperties': false,
              'required': <Object?>[
                'revision',
                'preferredCollection',
                'reusablePaymentPage',
                'paymentInstructions',
                'expectedAmountMinor',
                'currency',
                'offerValidityMinutes',
                'offerMessageTemplate',
                'sourceDefaultsRevision',
                'sourceDefaultsHash',
                'fieldSources',
              ],
              'properties': <String, Object?>{
                'revision': <String, Object?>{
                  'type': 'integer',
                  'minimum': 1,
                  'maximum': 1000000000,
                },
                'preferredCollection': <String, Object?>{
                  'anyOf': <Object?>[
                    <String, Object?>{
                      'type': 'string',
                      'enum': <Object?>[
                        'manualInstructions',
                        'reusablePage',
                        'personalRequest',
                        'catchCheckout',
                      ],
                    },
                    <String, Object?>{
                      'type': 'null',
                    },
                  ],
                },
                'reusablePaymentPage': <String, Object?>{
                  'anyOf': <Object?>[
                    <String, Object?>{
                      'type': 'object',
                      'additionalProperties': false,
                      'required': <Object?>[
                        'url',
                        'reusableForEvents',
                      ],
                      'properties': <String, Object?>{
                        'url': <String, Object?>{
                          'type': 'string',
                          'format': 'uri',
                          'maxLength': 2048,
                        },
                        'reusableForEvents': <String, Object?>{
                          'type': 'boolean',
                          'const': true,
                        },
                      },
                    },
                    <String, Object?>{
                      'type': 'null',
                    },
                  ],
                },
                'paymentInstructions': <String, Object?>{
                  'anyOf': <Object?>[
                    <String, Object?>{
                      'type': 'string',
                      'minLength': 1,
                      'maxLength': 1000,
                    },
                    <String, Object?>{
                      'type': 'null',
                    },
                  ],
                },
                'expectedAmountMinor': <String, Object?>{
                  'anyOf': <Object?>[
                    <String, Object?>{
                      'type': 'integer',
                      'minimum': 0,
                      'maximum': 100000000,
                    },
                    <String, Object?>{
                      'type': 'null',
                    },
                  ],
                },
                'currency': <String, Object?>{
                  'anyOf': <Object?>[
                    <String, Object?>{
                      'type': 'string',
                      'pattern': '^[A-Z]{3}\$',
                    },
                    <String, Object?>{
                      'type': 'null',
                    },
                  ],
                },
                'offerValidityMinutes': <String, Object?>{
                  'anyOf': <Object?>[
                    <String, Object?>{
                      'type': 'integer',
                      'minimum': 5,
                      'maximum': 10080,
                    },
                    <String, Object?>{
                      'type': 'null',
                    },
                  ],
                },
                'offerMessageTemplate': <String, Object?>{
                  'anyOf': <Object?>[
                    <String, Object?>{
                      'type': 'string',
                      'minLength': 1,
                      'maxLength': 1000,
                    },
                    <String, Object?>{
                      'type': 'null',
                    },
                  ],
                },
                'sourceDefaultsRevision': <String, Object?>{
                  'type': 'integer',
                  'minimum': 0,
                  'maximum': 1000000000,
                },
                'sourceDefaultsHash': <String, Object?>{
                  'type': 'string',
                  'pattern': '^[a-f0-9]{64}\$',
                },
                'fieldSources': <String, Object?>{
                  'type': 'object',
                  'additionalProperties': false,
                  'required': <Object?>[
                    'preferredCollection',
                    'reusablePaymentPage',
                    'paymentInstructions',
                    'expectedAmountMinor',
                    'currency',
                    'offerValidityMinutes',
                    'offerMessageTemplate',
                  ],
                  'properties': <String, Object?>{
                    'preferredCollection': <String, Object?>{
                      'type': 'string',
                      'enum': <Object?>[
                        'organizer',
                        'event',
                        'cleared',
                      ],
                    },
                    'reusablePaymentPage': <String, Object?>{
                      'type': 'string',
                      'enum': <Object?>[
                        'organizer',
                        'event',
                        'cleared',
                      ],
                    },
                    'paymentInstructions': <String, Object?>{
                      'type': 'string',
                      'enum': <Object?>[
                        'organizer',
                        'event',
                        'cleared',
                      ],
                    },
                    'expectedAmountMinor': <String, Object?>{
                      'type': 'string',
                      'enum': <Object?>[
                        'organizer',
                        'event',
                        'cleared',
                      ],
                    },
                    'currency': <String, Object?>{
                      'type': 'string',
                      'enum': <Object?>[
                        'organizer',
                        'event',
                        'cleared',
                      ],
                    },
                    'offerValidityMinutes': <String, Object?>{
                      'type': 'string',
                      'enum': <Object?>[
                        'organizer',
                        'event',
                        'cleared',
                      ],
                    },
                    'offerMessageTemplate': <String, Object?>{
                      'type': 'string',
                      'enum': <Object?>[
                        'organizer',
                        'event',
                        'cleared',
                      ],
                    },
                  },
                },
              },
            },
          },
        },
        <String, Object?>{
          'type': 'null',
        },
      ],
    },
  },
};
