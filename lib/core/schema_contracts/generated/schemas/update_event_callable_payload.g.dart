// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs
// ignore_for_file: constant_identifier_names, use_null_aware_elements

// JSON Schema constant emitted from callables/update_event_payload.schema.json.

const schemaUpdateEventCallablePayloadSchema = <String, Object?>{
  '\$schema': 'http://json-schema.org/draft-07/schema#',
  '\$id': 'https://catch.app/contracts/callables/update_event_payload.schema.json',
  'title': 'UpdateEventCallablePayload',
  'description': 'Callable payload accepted by updateEvent.',
  'type': 'object',
  'additionalProperties': false,
  'required': <Object?>[
    'eventId',
    'fields',
  ],
  'properties': <String, Object?>{
    'eventId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
    },
    'fields': <String, Object?>{
      'type': 'object',
      'additionalProperties': false,
      'minProperties': 1,
      'properties': <String, Object?>{
        'startTimeMillis': <String, Object?>{
          'type': 'integer',
        },
        'endTimeMillis': <String, Object?>{
          'type': 'integer',
        },
        'meetingPoint': <String, Object?>{
          'type': 'string',
          'minLength': 1,
          'maxLength': 240,
        },
        'meetingLocation': <String, Object?>{
          'type': 'object',
          'additionalProperties': false,
          'description': 'Canonical meeting location selected from Google Places or a manually pinned map coordinate.',
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
        'startingPointLat': <String, Object?>{
          'anyOf': <Object?>[
            <String, Object?>{
              'type': <Object?>[
                'number',
                'null',
              ],
              'minimum': -90,
              'maximum': 90,
            },
            <String, Object?>{
              'type': 'null',
            },
          ],
        },
        'startingPointLng': <String, Object?>{
          'anyOf': <Object?>[
            <String, Object?>{
              'type': <Object?>[
                'number',
                'null',
              ],
              'minimum': -180,
              'maximum': 180,
            },
            <String, Object?>{
              'type': 'null',
            },
          ],
        },
        'locationDetails': <String, Object?>{
          'type': <Object?>[
            'string',
            'null',
          ],
          'maxLength': 1000,
        },
        'photoUrl': <String, Object?>{
          'anyOf': <Object?>[
            <String, Object?>{
              'type': 'string',
              'format': 'uri',
              'maxLength': 2048,
            },
            <String, Object?>{
              'type': 'null',
            },
          ],
        },
        'distanceKm': <String, Object?>{
          'type': 'number',
          'minimum': 0,
          'maximum': 100,
        },
        'pace': <String, Object?>{
          'type': 'string',
          'enum': <Object?>[
            'easy',
            'moderate',
            'fast',
            'competitive',
          ],
        },
        'description': <String, Object?>{
          'type': 'string',
          'maxLength': 2000,
        },
        'capacityLimit': <String, Object?>{
          'type': 'integer',
          'minimum': 1,
          'maximum': 1000,
        },
        'priceInPaise': <String, Object?>{
          'type': 'integer',
          'minimum': 0,
          'maximum': 100000000,
        },
        'constraints': <String, Object?>{
          'type': 'object',
          'additionalProperties': false,
          'properties': <String, Object?>{
            'minAge': <String, Object?>{
              'type': 'integer',
              'minimum': 0,
              'maximum': 120,
            },
            'maxAge': <String, Object?>{
              'type': 'integer',
              'minimum': 0,
              'maximum': 120,
            },
            'maxMen': <String, Object?>{
              'type': <Object?>[
                'integer',
                'null',
              ],
              'minimum': 0,
            },
            'maxWomen': <String, Object?>{
              'type': <Object?>[
                'integer',
                'null',
              ],
              'minimum': 0,
            },
          },
        },
        'eventPolicy': <String, Object?>{
          'type': 'object',
          'additionalProperties': false,
          'required': <Object?>[
            'version',
            'admission',
            'pricing',
            'cancellation',
            'settlement',
          ],
          'properties': <String, Object?>{
            'version': <String, Object?>{
              'type': 'integer',
              'const': 1,
            },
            'admission': <String, Object?>{
              'type': 'object',
              'additionalProperties': false,
              'required': <Object?>[
                'format',
                'capacityLimit',
                'waitlistPolicy',
                'inviteRequired',
                'membershipRequired',
                'manualApprovalRequired',
                'privateAccessPolicy',
                'cohortCapacityLimits',
                'balancedRatioPolicy',
              ],
              'properties': <String, Object?>{
                'format': <String, Object?>{
                  'type': 'string',
                  'enum': <Object?>[
                    'open',
                    'inviteOnly',
                    'manualApproval',
                    'fixedCohortCaps',
                    'balancedRatio',
                    'membersOnly',
                  ],
                },
                'capacityLimit': <String, Object?>{
                  'type': 'integer',
                  'minimum': 1,
                  'maximum': 1000,
                },
                'waitlistPolicy': <String, Object?>{
                  'type': 'object',
                  'additionalProperties': false,
                  'required': <Object?>[
                    'mode',
                    'offerWindowMinutes',
                  ],
                  'properties': <String, Object?>{
                    'mode': <String, Object?>{
                      'type': 'string',
                      'enum': <Object?>[
                        'disabled',
                        'rankedOffer',
                        'broadcastFirstComeFirstServed',
                        'manualReview',
                      ],
                    },
                    'offerWindowMinutes': <String, Object?>{
                      'type': 'integer',
                      'minimum': 0,
                      'maximum': 10080,
                    },
                  },
                },
                'inviteRequired': <String, Object?>{
                  'type': 'boolean',
                },
                'membershipRequired': <String, Object?>{
                  'type': 'boolean',
                },
                'manualApprovalRequired': <String, Object?>{
                  'type': 'boolean',
                },
                'privateAccessPolicy': <String, Object?>{
                  'type': 'object',
                  'additionalProperties': false,
                  'required': <Object?>[
                    'mode',
                    'inviteCodeHint',
                    'privateLinkEnabled',
                  ],
                  'properties': <String, Object?>{
                    'mode': <String, Object?>{
                      'type': 'string',
                      'enum': <Object?>[
                        'none',
                        'inviteCode',
                      ],
                    },
                    'inviteCodeHint': <String, Object?>{
                      'type': <Object?>[
                        'string',
                        'null',
                      ],
                      'maxLength': 64,
                    },
                    'privateLinkEnabled': <String, Object?>{
                      'type': 'boolean',
                    },
                  },
                },
                'cohortCapacityLimits': <String, Object?>{
                  'type': 'object',
                  'additionalProperties': <String, Object?>{
                    'type': 'integer',
                    'minimum': 0,
                  },
                },
                'balancedRatioPolicy': <String, Object?>{
                  'type': <Object?>[
                    'object',
                    'null',
                  ],
                  'additionalProperties': false,
                  'required': <Object?>[
                    'leftCohortId',
                    'rightCohortId',
                    'maxSkew',
                    'openingBufferPerCohort',
                    'outOfRatioCohortPolicy',
                  ],
                  'properties': <String, Object?>{
                    'leftCohortId': <String, Object?>{
                      'type': 'string',
                      'minLength': 1,
                      'maxLength': 120,
                    },
                    'rightCohortId': <String, Object?>{
                      'type': 'string',
                      'minLength': 1,
                      'maxLength': 120,
                    },
                    'maxSkew': <String, Object?>{
                      'type': 'integer',
                      'minimum': 0,
                      'maximum': 1000,
                    },
                    'openingBufferPerCohort': <String, Object?>{
                      'type': 'integer',
                      'minimum': 0,
                      'maximum': 1000,
                    },
                    'outOfRatioCohortPolicy': <String, Object?>{
                      'type': 'string',
                      'enum': <Object?>[
                        'admitWithinGeneralCapacity',
                        'waitlist',
                        'manualReview',
                        'reject',
                      ],
                    },
                  },
                },
              },
            },
            'pricing': <String, Object?>{
              'type': 'object',
              'additionalProperties': false,
              'required': <Object?>[
                'basePriceInPaise',
                'cohortAdjustmentsInPaise',
                'demandPricingRules',
              ],
              'properties': <String, Object?>{
                'basePriceInPaise': <String, Object?>{
                  'type': 'integer',
                  'minimum': 0,
                  'maximum': 100000000,
                },
                'cohortAdjustmentsInPaise': <String, Object?>{
                  'type': 'object',
                  'additionalProperties': <String, Object?>{
                    'type': 'integer',
                    'minimum': -100000000,
                    'maximum': 100000000,
                  },
                },
                'demandPricingRules': <String, Object?>{
                  'type': 'array',
                  'maxItems': 20,
                  'items': <String, Object?>{
                    'type': 'object',
                    'additionalProperties': false,
                    'required': <Object?>[
                      'pricedCohortId',
                      'balancingCohortId',
                      'stepAdjustmentInPaise',
                      'maxAdjustmentInPaise',
                      'freeSkew',
                      'demandStep',
                    ],
                    'properties': <String, Object?>{
                      'pricedCohortId': <String, Object?>{
                        'type': 'string',
                        'minLength': 1,
                        'maxLength': 120,
                      },
                      'balancingCohortId': <String, Object?>{
                        'type': 'string',
                        'minLength': 1,
                        'maxLength': 120,
                      },
                      'stepAdjustmentInPaise': <String, Object?>{
                        'type': 'integer',
                        'minimum': 0,
                        'maximum': 100000000,
                      },
                      'maxAdjustmentInPaise': <String, Object?>{
                        'type': 'integer',
                        'minimum': 0,
                        'maximum': 100000000,
                      },
                      'freeSkew': <String, Object?>{
                        'type': 'integer',
                        'minimum': 0,
                        'maximum': 1000,
                      },
                      'demandStep': <String, Object?>{
                        'type': 'integer',
                        'minimum': 1,
                        'maximum': 1000,
                      },
                    },
                  },
                },
              },
            },
            'cancellation': <String, Object?>{
              'type': 'object',
              'additionalProperties': false,
              'required': <Object?>[
                'policyId',
              ],
              'properties': <String, Object?>{
                'policyId': <String, Object?>{
                  'type': 'string',
                  'enum': <Object?>[
                    'flexible',
                    'standard',
                    'strict',
                  ],
                },
              },
            },
            'settlement': <String, Object?>{
              'type': 'object',
              'additionalProperties': false,
              'required': <Object?>[
                'hostPayoutTiming',
              ],
              'properties': <String, Object?>{
                'hostPayoutTiming': <String, Object?>{
                  'type': 'string',
                  'enum': <Object?>[
                    'afterEventCompletion',
                  ],
                },
              },
            },
          },
        },
        'privateAccess': <String, Object?>{
          'type': 'object',
          'additionalProperties': false,
          'properties': <String, Object?>{
            'inviteCode': <String, Object?>{
              'type': <Object?>[
                'string',
                'null',
              ],
              'minLength': 4,
              'maxLength': 64,
              'pattern': '^[A-Za-z0-9_-]+\$',
            },
          },
        },
      },
    },
  },
};
