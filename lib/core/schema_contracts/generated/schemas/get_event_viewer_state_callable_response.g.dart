// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs
// ignore_for_file: constant_identifier_names, use_null_aware_elements

// JSON Schema constant emitted from callable_responses/get_event_viewer_state_response.schema.json.

const schemaGetEventViewerStateCallableResponseSchema = <String, Object?>{
  'type': 'object',
  'additionalProperties': false,
  'required': <Object?>[
    'viewer',
  ],
  'properties': <String, Object?>{
    'viewer': <String, Object?>{
      'type': 'object',
      'additionalProperties': false,
      'required': <Object?>[
        'eventId',
        'organizerId',
        'observedAtMillis',
        'membership',
        'review',
        'admission',
        'attendance',
        'waitlisted',
        'payment',
        'futureBooking',
        'route',
        'quotedPriceInPaise',
        'basis',
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
        'observedAtMillis': <String, Object?>{
          'type': 'integer',
          'minimum': 0,
          'maximum': 9007199254740991,
        },
        'membership': <String, Object?>{
          'type': 'object',
          'additionalProperties': false,
          'required': <Object?>[
            'state',
            'revision',
            'decisionId',
          ],
          'properties': <String, Object?>{
            'state': <String, Object?>{
              'type': 'string',
              'enum': <Object?>[
                'notRequired',
                'none',
                'active',
                'revoked',
                'unavailable',
              ],
            },
            'revision': <String, Object?>{
              'anyOf': <Object?>[
                <String, Object?>{
                  'type': 'integer',
                  'minimum': 0,
                  'maximum': 9007199254740991,
                },
                <String, Object?>{
                  'type': 'null',
                },
              ],
            },
            'decisionId': <String, Object?>{
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
          },
        },
        'review': <String, Object?>{
          'type': 'string',
          'enum': <Object?>[
            'none',
            'pending',
            'approved',
          ],
        },
        'admission': <String, Object?>{
          'type': 'string',
          'enum': <Object?>[
            'none',
            'nativeParticipation',
            'publicPaidRoster',
          ],
        },
        'attendance': <String, Object?>{
          'type': 'string',
          'enum': <Object?>[
            'notRecorded',
            'attended',
          ],
        },
        'waitlisted': <String, Object?>{
          'type': 'boolean',
        },
        'payment': <String, Object?>{
          'type': 'string',
          'enum': <Object?>[
            'notRead',
            'creatingOrder',
            'orderUnknown',
            'checkoutReady',
            'verifying',
            'captured',
            'admitted',
            'expired',
            'refundPending',
            'refunded',
            'reviewRequired',
            'failed',
            'cancelled',
          ],
        },
        'futureBooking': <String, Object?>{
          'oneOf': <Object?>[
            <String, Object?>{
              'type': 'object',
              'additionalProperties': false,
              'required': <Object?>[
                'allowed',
                'reason',
              ],
              'properties': <String, Object?>{
                'allowed': <String, Object?>{
                  'const': true,
                },
                'reason': <String, Object?>{
                  'type': 'null',
                },
              },
            },
            <String, Object?>{
              'type': 'object',
              'additionalProperties': false,
              'required': <Object?>[
                'allowed',
                'reason',
              ],
              'properties': <String, Object?>{
                'allowed': <String, Object?>{
                  'const': false,
                },
                'reason': <String, Object?>{
                  'type': 'string',
                  'enum': <Object?>[
                    'membershipRequired',
                    'inviteRequired',
                    'reviewRequired',
                    'full',
                    'pairCapacityUnavailable',
                    'generalCapacityUnavailable',
                    'cohortCapacityUnavailable',
                    'outOfRatioReviewRequired',
                    'balanceUnavailable',
                    'bookingDetailsRequired',
                    'runPreferencesRequired',
                    'ageRestricted',
                    'scheduleConflict',
                    'eventUnavailable',
                    'past',
                    'cancelled',
                    'unsupportedRoute',
                  ],
                },
              },
            },
          ],
        },
        'route': <String, Object?>{
          'anyOf': <Object?>[
            <String, Object?>{
              'type': 'string',
              'enum': <Object?>[
                'catchFreeBooking',
                'catchCheckout',
                'catchWaitlistOffer',
              ],
            },
            <String, Object?>{
              'type': 'null',
            },
          ],
        },
        'quotedPriceInPaise': <String, Object?>{
          'anyOf': <Object?>[
            <String, Object?>{
              'type': 'integer',
              'minimum': 0,
              'maximum': 9007199254740991,
            },
            <String, Object?>{
              'type': 'null',
            },
          ],
        },
        'basis': <String, Object?>{
          'type': 'object',
          'additionalProperties': false,
          'required': <Object?>[
            'policyHash',
            'inventoryRevision',
            'capacityRevision',
            'migrationRevision',
          ],
          'properties': <String, Object?>{
            'policyHash': <String, Object?>{
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
            'inventoryRevision': <String, Object?>{
              'anyOf': <Object?>[
                <String, Object?>{
                  'type': 'integer',
                  'minimum': 0,
                  'maximum': 9007199254740991,
                },
                <String, Object?>{
                  'type': 'null',
                },
              ],
            },
            'capacityRevision': <String, Object?>{
              'anyOf': <Object?>[
                <String, Object?>{
                  'type': 'integer',
                  'minimum': 0,
                  'maximum': 9007199254740991,
                },
                <String, Object?>{
                  'type': 'null',
                },
              ],
            },
            'migrationRevision': <String, Object?>{
              'anyOf': <Object?>[
                <String, Object?>{
                  'type': 'integer',
                  'minimum': 0,
                  'maximum': 9007199254740991,
                },
                <String, Object?>{
                  'type': 'null',
                },
              ],
            },
          },
        },
      },
    },
  },
  '\$schema': 'http://json-schema.org/draft-07/schema#',
  '\$id': 'https://catch.app/contracts/callable_responses/get_event_viewer_state_response.schema.json',
  'title': 'GetEventViewerStateCallableResponse',
  'description': 'Current eligibility is separate from retained payment, admission and attendance evidence. Observation only; final mutations revalidate authority.',
};
