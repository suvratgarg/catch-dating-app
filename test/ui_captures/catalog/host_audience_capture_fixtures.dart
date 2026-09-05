part of 'screen_capture_catalog.dart';

Map<String, Object?> _audienceCaptureDetailMap() => {
  'response': {
    'responseId': 'response_1',
    'formId': 'form_1',
    'formTitle': 'Saturday Social application',
    'versionId': 'version_1',
    'version': 1,
    'status': 'submitted',
    'identityKind': 'phoneVerified',
    'identity': {
      'displayName': 'Maya Kapoor',
      'email': 'maya@example.com',
      'phoneE164': '+919876543210',
      'origin': 'respondentGranted',
    },
    'sourceLinkId': null,
    'sourceLabel': 'Instagram',
    'submittedAtMillis': DateTime(2026, 8, 20, 10, 42).millisecondsSinceEpoch,
    'withdrawnAtMillis': null,
    'highlights': <Object?>[],
    'conversionKinds': <Object?>[],
  },
  'answers': [
    {
      'questionId': 'question_1',
      'key': 'why_join',
      'label': 'Why do you want to join?',
      'kind': 'longText',
      'privacyClass': 'organizerCustom',
      'hostPresentation': 'detailOnly',
      'answer': 'I love meeting new people in the city.',
      'origin': 'respondentGranted',
      'assetDownloads': <Object?>[],
    },
    {
      'questionId': 'question_2',
      'key': 'anything_else',
      'label': 'Anything else we should know?',
      'kind': 'longText',
      'privacyClass': 'organizerCustom',
      'hostPresentation': 'detailOnly',
      'answer': 'I am visiting from Montreal.',
      'origin': 'respondentGranted',
      'assetDownloads': <Object?>[],
    },
  ],
  'consentVersion': 'v1',
  'completionMillis': 82000,
};

final _audienceCaptureAudience = HostSavedAudience(
  organizerId: 'preview-organizer',
  audienceId: 'preview-audience',
  name: 'Sunday regulars',
  status: 'active',
  definition: const HostSavedAudienceDefinition(
    join: HostSavedAudienceJoin.all,
    predicates: [HostSavedAudienceAttendedEvent('sunday-social')],
  ),
  definitionHash: 'preview-definition',
  definitionVersion: 2,
  revision: 1,
  lastPreviewMatchCount: 1,
  lastPreviewReachSummary: _audienceCaptureReach,
  lastPreviewAt: DateTime(2026, 9, 3, 12),
  createdAt: DateTime(2026, 9, 3),
  updatedAt: DateTime(2026, 9, 3),
);
const _audienceCaptureReach = HostAudienceReachSummary(
  inCatch: 0,
  automatic: 0,
  byHand: 1,
  unavailable: 0,
);
const _audienceCaptureOptions = HostSavedAudienceFilterOptions(
  forms: [
    HostAudienceSourceOption(
      id: 'form_1',
      title: 'Saturday Social application',
    ),
  ],
  questions: [
    HostAudienceQuestionOption(
      formId: 'form_1',
      versionId: 'application-v1',
      version: 1,
      formTitle: 'Saturday Social application',
      questionId: 'drink',
      label: 'Favorite drink',
      options: [HostAudienceAnswerOption(label: 'Coffee', value: 'coffee')],
    ),
  ],
  events: [
    HostAudienceSourceOption(id: 'sunday-social', title: 'Sunday social'),
  ],
  tags: [],
);

class _AudienceCapturePreviewAudienceMembers
    extends HostSavedAudienceMembersController {
  @override
  Future<HostSavedAudienceMembersState> build(
    HostSavedAudience audience,
  ) async {
    const members = [
      HostSavedAudiencePreviewContact(
        contactId: 'preview-ada',
        displayName: 'Ada',
      ),
    ];
    return HostSavedAudienceMembersState(
      members: members,
      preview: HostSavedAudiencePreview(
        audience: audience,
        matchCount: 1,
        reachSummary: _audienceCaptureReach,
        sample: members,
        evaluatedAt: DateTime(2026, 9, 3, 12),
      ),
    );
  }
}

final _audienceCaptureApplication = HostApplicationDetail(
  organizerId: 'org_1',
  applicationId: 'design-application-1',
  formId: 'form_1',
  formVersionId: 'design-form-version-1',
  targetKind: 'event',
  targetId: 'sunday-social',
  applicantDisplayName: 'Maya Kapoor',
  reviewStatus: HostApplicationReviewStatus.approved,
  answers: const [
    HostApplicationAnswer(
      questionId: 'interests',
      questionKey: 'interests',
      questionLabel: 'What would you like to join?',
      questionKind: 'text',
      canonicalFieldId: null,
      privacyClass: 'organizer',
      hostPresentation: 'text',
      value: HostApplicationAnswerValue(
        valueKind: 'text',
        textValue: 'Smaller weekend events and running groups.',
        numberValue: null,
        booleanValue: null,
        dateValue: null,
        optionValues: [],
        assetIds: [],
      ),
    ),
  ],
  outreach: const HostApplicationOutreach(
    phoneE164: '+919876543210',
    email: 'maya@example.com',
    instagramUrl: 'https://www.instagram.com/ananya.example/',
    linkedinUrl: null,
  ),
  reviewNote: null,
  assignedReviewerUid: null,
  submittedAt: DateTime(2026, 8, 20),
  reviewedAt: DateTime(2026, 8, 21),
  revision: 2,
  contactId: 'contact_1',
  sourceResponseId: 'design-response-1',
  dataAccessState: 'submittedFormResponse',
);

class _AudienceCaptureResponses extends HostFormResponsesController {
  @override
  Future<HostFormResponsesState> build(
    HostFormResponseListRequest request,
  ) async => HostFormResponsesState(
    responses: [_audienceCaptureResponse.response],
    nextCursor: null,
  );
}

class _AudienceCaptureApplications extends HostApplicationsDirectoryController {
  @override
  Future<HostApplicationsDirectoryState> build(
    HostApplicationListRequest request,
  ) async => HostApplicationsDirectoryState(
    applications: [
      HostApplicationSummary(
        applicationId: _audienceCaptureApplication.applicationId,
        formId: _audienceCaptureApplication.formId,
        formVersionId: _audienceCaptureApplication.formVersionId,
        targetKind: _audienceCaptureApplication.targetKind,
        targetId: _audienceCaptureApplication.targetId,
        applicantDisplayName: _audienceCaptureApplication.applicantDisplayName,
        reviewStatus: _audienceCaptureApplication.reviewStatus,
        sourceKind: HostApplicationSourceKind.native,
        providerId: null,
        submittedAt: _audienceCaptureApplication.submittedAt,
        revision: _audienceCaptureApplication.revision,
      ),
    ],
    nextCursor: null,
  );
}

class _AudienceCaptureAutomations extends HostFormAutomationsController {
  @override
  Future<HostFormAutomationsState> build(
    String organizerId,
    String? formId,
  ) async => HostFormAutomationsState(
    rules: [
      HostFormAutomationRule(
        ruleId: 'rule_1',
        organizerId: organizerId,
        formId: formId ?? 'form_1',
        name: 'Add new responses to People',
        enabled: true,
        revision: 1,
        trigger: HostFormAutomationTrigger.responseSubmitted,
        condition: null,
        actions: const [
          HostFormAutomationAction(
            actionId: 'action_1',
            kind: HostFormAutomationActionKind.createCrmContact,
            tagId: null,
            eventId: null,
            webhookUrl: null,
            webhookSecretConfigured: false,
            channel: null,
          ),
        ],
        updatedAt: DateTime(2026, 9, 5),
      ),
    ],
    runs: const [],
    nextCursor: null,
  );
}

class _AudienceCapturePublishedEditor extends HostFormEditorController {
  @override
  Future<HostFormEditorState> build(String organizerId, String formId) async =>
      HostFormEditorState(
        editor: HostFormEditor(
          form: _audienceCapturePublishedSummary(organizerId, formId),
          definition: HostFormDefinition.fromMap(
            _audienceCapturePublishedDefinition(),
          ),
          validationIssues: const [],
        ),
        canUndo: true,
      );
}

HostFormSummary _audienceCapturePublishedSummary(
  String organizerId,
  String formId,
) => HostFormSummary(
  organizerId: organizerId,
  formId: formId,
  title: 'Saturday Social application',
  description: 'A concise application for the next Saturday Social.',
  purpose: HostFormPurpose.application,
  status: HostFormLifecycleStatus.published,
  templateId: 'event_application',
  publicFormId: 'public-$formId',
  defaultTargetKind: HostFormTargetKind.organizer,
  defaultTargetId: organizerId,
  activeVersionId: 'version_1',
  draftRevision: 4,
  publishedVersion: 1,
  submittedResponseCount: 48,
  consequences: const HostFormConsequences(
    coverage: HostFormConsequenceCoverage.exact,
    identityPolicy: HostFormIdentityPolicy.emailOrPhoneVerified,
    enabledAutomationActionKinds: {
      HostFormAutomationActionKind.createCrmContact,
    },
  ),
  updatedAt: DateTime(2026, 8, 31, 8, 45),
  publishedAt: null,
  lastResponseAt: null,
);

Map<String, Object?> _audienceCapturePublishedDefinition() => {
  'schemaVersion': 1,
  'title': 'Saturday Social application',
  'description': 'A concise application for the next Saturday Social.',
  'purpose': 'application',
  'identityPolicy': 'emailOrPhoneVerified',
  'sections': [
    {
      'sectionId': 'about_you',
      'title': 'About you',
      'description': 'The essentials we need to review your application.',
      'pageBreak': false,
      'questions': [
        _audienceCapturePublishedQuestion(
          id: 'full_name',
          label: 'Full name',
          kind: 'shortText',
          canonicalFieldId: 'fullName',
        ),
        _audienceCapturePublishedQuestion(
          id: 'phone_number',
          label: 'Phone number',
          kind: 'phone',
          canonicalFieldId: 'phoneNumber',
        ),
      ],
    },
    {
      'sectionId': 'intent',
      'title': 'What brings you here?',
      'description': null,
      'pageBreak': false,
      'questions': [
        _audienceCapturePublishedQuestion(
          id: 'looking_for',
          label: 'What are you hoping to find?',
          kind: 'longText',
          required: false,
        ),
      ],
    },
  ],
  'logicRules': <Object?>[],
  'appearance': {
    'preset': 'editorial',
    'logoAssetId': null,
    'coverAssetId': null,
    'activityKind': null,
  },
  'availability': {
    'opensAt': null,
    'closesAt': null,
    'responseLimit': null,
    'closedMessage': null,
  },
  'consent': {
    'consentCopy':
        'I consent to this information being used for this application.',
    'consentVersion': 'v1',
    'retentionCopy':
        'Responses are retained for the application review period.',
  },
  'completion': {
    'title': 'Application received',
    'message': 'We will be in touch after the review.',
    'actionKind': 'none',
    'actionLabel': null,
    'actionUrl': null,
  },
};

Map<String, Object?> _audienceCapturePublishedQuestion({
  required String id,
  required String label,
  required String kind,
  String? canonicalFieldId,
  bool required = true,
}) => {
  'questionId': id,
  'key': id,
  'label': label,
  'helpText': null,
  'kind': kind,
  'required': required,
  'options': <Object?>[],
  'canonicalFieldId': canonicalFieldId,
  'privacyClass': canonicalFieldId == null ? 'organizerCustom' : 'contact',
  'prefillPolicy': 'never',
  'hostPresentation': 'detailOnly',
  'validation': {
    'minLength': null,
    'maxLength': null,
    'minNumber': null,
    'maxNumber': null,
    'earliestDate': null,
    'latestDate': null,
    'minSelections': null,
    'maxSelections': null,
    'maxFileCount': null,
    'maxFileSizeBytes': null,
    'allowedMimeTypes': <Object?>[],
    'patternPreset': null,
    'customError': null,
  },
};

final _audienceCaptureResponse = HostFormResponseDetail.fromCallableData(
  _audienceCaptureDetailMap(),
);
List<Object> _audienceCaptureSources(String organizerId) => [
  hostSavedAudienceFilterOptionsProvider(
    organizerId,
  ).overrideWith((_) async => _audienceCaptureOptions),
];
List<Object> _audienceCaptureFormOverrides({bool published = false}) => [
  hostFormEditorControllerProvider(
    HostOperationsFixtures.primaryClub.id,
    'saturday-social-application',
  ).overrideWith(
    published
        ? _AudienceCapturePublishedEditor.new
        : _CaptureHostFormEditorController.new,
  ),
  hostFormResponsesControllerProvider.overrideWith2(
    (_) => _AudienceCaptureResponses(),
  ),
];
List<Object> _audienceCaptureResponseOverrides({
  bool application = true,
  bool withdrawn = false,
}) => [
  hostFormResponseCanApplyProvider(
    organizerId: 'org_1',
    responseId: 'response_1',
  ).overrideWith((_) async => application),
  hostFormResponseDetailProvider(
    organizerId: 'org_1',
    responseId: 'response_1',
  ).overrideWith((_) async {
    final data = _audienceCaptureDetailMap();
    if (withdrawn) {
      (data['response'] as Map<String, Object?>)['status'] = 'withdrawn';
    }
    return HostFormResponseDetail.fromCallableData(data);
  }),
];
List<Object> _audienceCaptureAutomationOverrides() => [
  ..._audienceCaptureSources('org_1'),
  hostFormAutomationsControllerProvider.overrideWith2(
    (_) => _AudienceCaptureAutomations(),
  ),
];
List<Object> _audienceCaptureGroupOverrides() => [
  ..._audienceCaptureSources(_audienceCaptureAudience.organizerId),
  hostSavedAudienceMembersControllerProvider(
    _audienceCaptureAudience,
  ).overrideWith(_AudienceCapturePreviewAudienceMembers.new),
];
List<Object> _audienceCapturePersonOverrides() => [
  ..._hostShellCaptureOverrides(HostOperationsFixtures.hostUid),
  uidProvider.overrideWithValue(
    const AsyncData<String?>(HostOperationsFixtures.hostUid),
  ),
  ..._audienceCaptureSources(HostOperationsFixtures.primaryClub.id),
  hostAudienceContactDetailProvider(
    HostOperationsFixtures.primaryClub.id,
    'capture-customer-ananya',
  ).overrideWithValue(AsyncData(_hostCustomerMemoryDetail())),
  hostCommunicationPlanProvider(
    HostOperationsFixtures.primaryClub.id,
    'capture-customer-ananya',
  ).overrideWithValue(AsyncData(_hostCustomerMemoryCommunicationPlan())),
  hostApplicationDetailProvider(
    HostOperationsFixtures.primaryClub.id,
    'design-application-1',
  ).overrideWithValue(AsyncData(_audienceCaptureApplication)),
  hostApplicationsDirectoryControllerProvider.overrideWith2(
    (_) => _AudienceCaptureApplications(),
  ),
];
Future<void> _audienceCaptureOpenTab(WidgetTester tester, String label) async {
  final tab = find.text(label).first;
  await tester.ensureVisible(tab);
  await pumpFeatureUi(tester);
  await tester.tap(tab);
  await pumpFeatureUi(tester);
}
