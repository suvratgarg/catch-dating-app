// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs
// ignore_for_file: constant_identifier_names, use_null_aware_elements

// JSON Schema constant emitted from callables/update_club_payload.schema.json.

const schemaUpdateClubCallablePayloadSchema = <String, Object?>{
  '\$schema': 'http://json-schema.org/draft-07/schema#',
  '\$id': 'https://catch.app/contracts/callables/update_club_payload.schema.json',
  'title': 'UpdateClubCallablePayload',
  'description': 'Callable payload accepted by updateClub.',
  'x-callable-shape': 'patch',
  'type': 'object',
  'additionalProperties': false,
  'required': <Object?>[
    'clubId',
    'fields',
  ],
  'properties': <String, Object?>{
    'clubId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
    },
    'fields': <String, Object?>{
      'type': 'object',
      'additionalProperties': false,
      'minProperties': 1,
      'properties': <String, Object?>{
        'name': <String, Object?>{
          'type': 'string',
          'minLength': 1,
          'maxLength': 120,
        },
        'description': <String, Object?>{
          'type': 'string',
          'minLength': 1,
          'maxLength': 2000,
        },
        'location': <String, Object?>{
          'type': <Object?>[
            'string',
            'null',
          ],
          'minLength': 1,
          'maxLength': 80,
          'pattern': '^[a-z0-9-]+\$',
        },
        'area': <String, Object?>{
          'type': 'string',
          'minLength': 1,
          'maxLength': 120,
        },
        'hostName': <String, Object?>{
          'type': 'string',
          'minLength': 1,
          'maxLength': 120,
        },
        'hostAvatarUrl': <String, Object?>{
          'type': <Object?>[
            'string',
            'null',
          ],
          'maxLength': 320,
        },
        'imageUrl': <String, Object?>{
          'type': <Object?>[
            'string',
            'null',
          ],
          'maxLength': 320,
        },
        'profileImageUrl': <String, Object?>{
          'type': <Object?>[
            'string',
            'null',
          ],
          'maxLength': 320,
        },
        'tags': <String, Object?>{
          'type': 'array',
          'items': <String, Object?>{
            'type': 'string',
            'minLength': 1,
            'maxLength': 40,
          },
          'maxItems': 12,
          'uniqueItems': true,
        },
        'instagramHandle': <String, Object?>{
          'type': <Object?>[
            'string',
            'null',
          ],
          'maxLength': 320,
        },
        'phoneNumber': <String, Object?>{
          'type': <Object?>[
            'string',
            'null',
          ],
          'maxLength': 320,
        },
        'email': <String, Object?>{
          'type': <Object?>[
            'string',
            'null',
          ],
          'maxLength': 320,
        },
        'hostDefaults': <String, Object?>{
          'type': 'object',
          'additionalProperties': false,
          'properties': <String, Object?>{
            'primaryActivityKind': <String, Object?>{
              'type': 'string',
              'enum': <Object?>[
                'socialRun',
                'running',
                'walking',
                'pickleball',
                'padel',
                'tennis',
                'badminton',
                'cycling',
                'spinClass',
                'yoga',
                'strengthTraining',
                'pubQuiz',
                'barCrawl',
                'dinner',
                'singlesMixer',
                'openActivity',
              ],
            },
            'supportedActivityKinds': <String, Object?>{
              'type': 'array',
              'maxItems': 16,
              'uniqueItems': true,
              'items': <String, Object?>{
                'type': 'string',
                'enum': <Object?>[
                  'socialRun',
                  'running',
                  'walking',
                  'pickleball',
                  'padel',
                  'tennis',
                  'badminton',
                  'cycling',
                  'spinClass',
                  'yoga',
                  'strengthTraining',
                  'pubQuiz',
                  'barCrawl',
                  'dinner',
                  'singlesMixer',
                  'openActivity',
                ],
              },
            },
            'eventPolicy': <String, Object?>{
              'type': 'object',
              'additionalProperties': false,
              'properties': <String, Object?>{
                'admissionPreset': <String, Object?>{
                  'type': 'string',
                  'enum': <Object?>[
                    'openCapacity',
                    'inviteOnly',
                    'balancedSingles',
                    'fixedCohortCaps',
                  ],
                },
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
                'dynamicPricingEnabled': <String, Object?>{
                  'type': 'boolean',
                },
                'dynamicPricingStepInPaise': <String, Object?>{
                  'type': <Object?>[
                    'integer',
                    'null',
                  ],
                  'minimum': 0,
                  'maximum': 100000000,
                },
                'dynamicPricingMaxInPaise': <String, Object?>{
                  'type': <Object?>[
                    'integer',
                    'null',
                  ],
                  'minimum': 0,
                  'maximum': 100000000,
                },
                'cancellationPolicyId': <String, Object?>{
                  'type': 'string',
                  'enum': <Object?>[
                    'flexible',
                    'standard',
                    'strict',
                  ],
                },
              },
            },
            'eventSuccess': <String, Object?>{
              'type': 'object',
              'additionalProperties': false,
              'properties': <String, Object?>{
                'enabled': <String, Object?>{
                  'type': 'boolean',
                },
                'playbookId': <String, Object?>{
                  'type': 'string',
                  'minLength': 1,
                  'maxLength': 120,
                },
                'selectedModuleIds': <String, Object?>{
                  'type': 'array',
                  'maxItems': 24,
                  'items': <String, Object?>{
                    'type': 'string',
                    'minLength': 1,
                    'maxLength': 120,
                  },
                },
                'structureConfig': <String, Object?>{
                  'type': 'object',
                  'additionalProperties': false,
                  'required': <Object?>[
                    'unitKind',
                    'unitSize',
                    'revealCountdownSeconds',
                  ],
                  'properties': <String, Object?>{
                    'unitKind': <String, Object?>{
                      'type': 'string',
                      'enum': <Object?>[
                        'wholeGroup',
                        'pods',
                        'pairs',
                        'teams',
                        'tables',
                      ],
                    },
                    'unitSize': <String, Object?>{
                      'type': 'integer',
                      'minimum': 1,
                      'maximum': 1000,
                    },
                    'unitCount': <String, Object?>{
                      'type': <Object?>[
                        'integer',
                        'null',
                      ],
                      'minimum': 1,
                      'maximum': 200,
                    },
                    'rotationIntervalMinutes': <String, Object?>{
                      'type': <Object?>[
                        'integer',
                        'null',
                      ],
                      'minimum': 5,
                      'maximum': 180,
                    },
                    'revealCountdownSeconds': <String, Object?>{
                      'type': 'integer',
                      'minimum': 0,
                      'maximum': 60,
                    },
                  },
                },
                'hostGoal': <String, Object?>{
                  'type': 'string',
                  'maxLength': 300,
                },
                'wingmanRequestsEnabled': <String, Object?>{
                  'type': 'boolean',
                },
                'contextualOpenersEnabled': <String, Object?>{
                  'type': 'boolean',
                },
                'compatibilityAffectsRanking': <String, Object?>{
                  'type': 'boolean',
                },
                'questionnaireConfig': <String, Object?>{
                  'type': 'object',
                  'additionalProperties': false,
                  'required': <Object?>[
                    'templateId',
                  ],
                  'properties': <String, Object?>{
                    'templateId': <String, Object?>{
                      'type': 'string',
                      'minLength': 1,
                      'maxLength': 120,
                    },
                    'customTitle': <String, Object?>{
                      'type': <Object?>[
                        'string',
                        'null',
                      ],
                      'maxLength': 80,
                    },
                    'customQuestions': <String, Object?>{
                      'type': 'array',
                      'maxItems': 8,
                      'items': <String, Object?>{
                        'type': 'object',
                        'additionalProperties': false,
                        'required': <Object?>[
                          'id',
                          'prompt',
                          'options',
                        ],
                        'properties': <String, Object?>{
                          'id': <String, Object?>{
                            'type': 'string',
                            'minLength': 1,
                            'maxLength': 120,
                          },
                          'prompt': <String, Object?>{
                            'type': 'string',
                            'minLength': 1,
                            'maxLength': 140,
                          },
                          'options': <String, Object?>{
                            'type': 'array',
                            'minItems': 2,
                            'maxItems': 5,
                            'items': <String, Object?>{
                              'type': 'object',
                              'additionalProperties': false,
                              'required': <Object?>[
                                'id',
                                'label',
                              ],
                              'properties': <String, Object?>{
                                'id': <String, Object?>{
                                  'type': 'string',
                                  'minLength': 1,
                                  'maxLength': 120,
                                },
                                'label': <String, Object?>{
                                  'type': 'string',
                                  'minLength': 1,
                                  'maxLength': 80,
                                },
                              },
                            },
                          },
                        },
                      },
                    },
                  },
                },
                'attendeePrompt': <String, Object?>{
                  'type': <Object?>[
                    'string',
                    'null',
                  ],
                  'maxLength': 300,
                },
              },
            },
            'eventSuccessByActivityKind': <String, Object?>{
              'type': 'object',
              'maxProperties': 16,
              'additionalProperties': <String, Object?>{
                'type': 'object',
                'additionalProperties': false,
                'properties': <String, Object?>{
                  'enabled': <String, Object?>{
                    'type': 'boolean',
                  },
                  'playbookId': <String, Object?>{
                    'type': 'string',
                    'minLength': 1,
                    'maxLength': 120,
                  },
                  'selectedModuleIds': <String, Object?>{
                    'type': 'array',
                    'maxItems': 24,
                    'items': <String, Object?>{
                      'type': 'string',
                      'minLength': 1,
                      'maxLength': 120,
                    },
                  },
                  'structureConfig': <String, Object?>{
                    'type': 'object',
                    'additionalProperties': false,
                    'required': <Object?>[
                      'unitKind',
                      'unitSize',
                      'revealCountdownSeconds',
                    ],
                    'properties': <String, Object?>{
                      'unitKind': <String, Object?>{
                        'type': 'string',
                        'enum': <Object?>[
                          'wholeGroup',
                          'pods',
                          'pairs',
                          'teams',
                          'tables',
                        ],
                      },
                      'unitSize': <String, Object?>{
                        'type': 'integer',
                        'minimum': 1,
                        'maximum': 1000,
                      },
                      'unitCount': <String, Object?>{
                        'type': <Object?>[
                          'integer',
                          'null',
                        ],
                        'minimum': 1,
                        'maximum': 200,
                      },
                      'rotationIntervalMinutes': <String, Object?>{
                        'type': <Object?>[
                          'integer',
                          'null',
                        ],
                        'minimum': 5,
                        'maximum': 180,
                      },
                      'revealCountdownSeconds': <String, Object?>{
                        'type': 'integer',
                        'minimum': 0,
                        'maximum': 60,
                      },
                    },
                  },
                  'hostGoal': <String, Object?>{
                    'type': 'string',
                    'maxLength': 300,
                  },
                  'wingmanRequestsEnabled': <String, Object?>{
                    'type': 'boolean',
                  },
                  'contextualOpenersEnabled': <String, Object?>{
                    'type': 'boolean',
                  },
                  'compatibilityAffectsRanking': <String, Object?>{
                    'type': 'boolean',
                  },
                  'questionnaireConfig': <String, Object?>{
                    'type': 'object',
                    'additionalProperties': false,
                    'required': <Object?>[
                      'templateId',
                    ],
                    'properties': <String, Object?>{
                      'templateId': <String, Object?>{
                        'type': 'string',
                        'minLength': 1,
                        'maxLength': 120,
                      },
                      'customTitle': <String, Object?>{
                        'type': <Object?>[
                          'string',
                          'null',
                        ],
                        'maxLength': 80,
                      },
                      'customQuestions': <String, Object?>{
                        'type': 'array',
                        'maxItems': 8,
                        'items': <String, Object?>{
                          'type': 'object',
                          'additionalProperties': false,
                          'required': <Object?>[
                            'id',
                            'prompt',
                            'options',
                          ],
                          'properties': <String, Object?>{
                            'id': <String, Object?>{
                              'type': 'string',
                              'minLength': 1,
                              'maxLength': 120,
                            },
                            'prompt': <String, Object?>{
                              'type': 'string',
                              'minLength': 1,
                              'maxLength': 140,
                            },
                            'options': <String, Object?>{
                              'type': 'array',
                              'minItems': 2,
                              'maxItems': 5,
                              'items': <String, Object?>{
                                'type': 'object',
                                'additionalProperties': false,
                                'required': <Object?>[
                                  'id',
                                  'label',
                                ],
                                'properties': <String, Object?>{
                                  'id': <String, Object?>{
                                    'type': 'string',
                                    'minLength': 1,
                                    'maxLength': 120,
                                  },
                                  'label': <String, Object?>{
                                    'type': 'string',
                                    'minLength': 1,
                                    'maxLength': 80,
                                  },
                                },
                              },
                            },
                          },
                        },
                      },
                    },
                  },
                  'attendeePrompt': <String, Object?>{
                    'type': <Object?>[
                      'string',
                      'null',
                    ],
                    'maxLength': 300,
                  },
                },
              },
            },
          },
        },
      },
    },
  },
};
