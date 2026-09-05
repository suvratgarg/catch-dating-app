import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/hosts/domain/host_form.dart';
import 'package:catch_dating_app/hosts/domain/host_form_operations.dart';
import 'package:catch_dating_app/hosts/presentation/forms/host_form_builder_screen.dart';
import 'package:catch_dating_app/hosts/presentation/forms/host_form_metrics.dart';
import 'package:catch_dating_app/hosts/presentation/forms/host_form_operations_controller.dart';
import 'package:catch_dating_app/hosts/presentation/forms/host_form_response_detail_screen.dart';
import 'package:catch_dating_app/hosts/presentation/forms/host_forms_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../preview_layout_contracts.dart';

final _state = HostFormEditorState(
  editor: HostFormEditor(
    form: _previewPublishedSummary('org_1', 'form_1'),
    definition: HostFormDefinition.fromMap(_previewPublishedDefinition()),
    validationIssues: const [],
  ),
);
final _response = HostFormResponseDetail.fromCallableData(_previewDetailMap());

@widgetbook.UseCase(
  name: 'Published workspace navigation',
  type: HostFormWorkspaceHeader,
  path: '[P1 product surfaces]/Host operations/Forms',
)
Widget hostFormWorkspaceHeaderPreview(BuildContext context) {
  var selected = HostFormWorkspaceView.overview;
  return SizedBox(
    width: WidgetbookPreviewLayout.wideContractWidth,
    child: StatefulBuilder(
      builder: (context, setState) => HostFormWorkspaceHeader(
        state: _state,
        selected: selected,
        onChanged: (value) => setState(() => selected = value),
      ),
    ),
  );
}

@widgetbook.UseCase(
  name: 'Published form overview',
  type: HostFormWorkspaceOverview,
  path: '[P1 product surfaces]/Host operations/Forms',
)
Widget hostFormWorkspaceOverviewPreview(BuildContext context) => ProviderScope(
  overrides: [
    hostFormResponsesControllerProvider.overrideWith2(
      (_) => _PreviewResponses(),
    ),
  ],
  child: SizedBox(
    width: WidgetbookPreviewLayout.wideContractWidth,
    height: WidgetbookPreviewLayout.hostEditorViewportHeight,
    child: Scaffold(
      body: SingleChildScrollView(
        padding: CatchInsets.pageBody,
        child: HostFormWorkspaceOverview(
          organizerId: 'org_1',
          state: _state,
          onQuestions: () {},
          onReviewResponses: () {},
          onSettings: () {},
          onShare: () {},
          onPreview: () {},
        ),
      ),
    ),
  ),
);

@widgetbook.UseCase(
  name: 'Unboxed form metrics',
  type: HostFormMetrics,
  path: '[P1 product surfaces]/Host operations/Forms',
)
Widget hostFormMetricsPreview(BuildContext context) => const SizedBox(
  width: WidgetbookPreviewLayout.wideContractWidth,
  child: HostFormMetrics(
    items: [
      (value: '84', label: 'Responses'),
      (value: '5', label: 'Questions'),
    ],
  ),
);

@widgetbook.UseCase(
  name: 'Application conversion',
  type: HostFormResponsePrimaryAction,
  path: '[P1 product surfaces]/Host operations/Forms',
)
Widget hostFormResponsePrimaryActionPreview(BuildContext context) =>
    ProviderScope(
      overrides: [
        hostFormResponseCanApplyProvider(
          organizerId: 'org_1',
          responseId: 'response_1',
        ).overrideWith((_) async => true),
      ],
      child: SizedBox(
        width: WidgetbookPreviewLayout.wideContractWidth,
        child: HostFormResponsePrimaryAction(
          detail: _response,
          organizerId: 'org_1',
          converting: null,
          onConvert: (_) {},
        ),
      ),
    );

@widgetbook.UseCase(
  name: 'People conversion',
  type: HostFormResponsePrimaryAction,
  path: '[P1 product surfaces]/Host operations/Forms',
)
Widget hostFormResponsePeopleActionPreview(BuildContext context) =>
    ProviderScope(
      overrides: [
        hostFormResponseCanApplyProvider(
          organizerId: 'org_1',
          responseId: 'response_1',
        ).overrideWith((_) async => false),
      ],
      child: SizedBox(
        width: WidgetbookPreviewLayout.wideContractWidth,
        child: HostFormResponsePrimaryAction(
          detail: _response,
          organizerId: 'org_1',
          converting: null,
          onConvert: (_) {},
        ),
      ),
    );

@widgetbook.UseCase(
  name: 'Related People and event actions',
  type: HostFormResponseRelatedActions,
  path: '[P1 product surfaces]/Host operations/Forms',
)
Widget hostFormResponseRelatedActionsPreview(BuildContext context) =>
    ProviderScope(
      overrides: [
        hostFormResponseCanApplyProvider(
          organizerId: 'org_1',
          responseId: 'response_1',
        ).overrideWith((_) async => true),
      ],
      child: SizedBox(
        width: WidgetbookPreviewLayout.wideContractWidth,
        child: HostFormResponseRelatedActions(
          detail: _response,
          organizerId: 'org_1',
          converting: null,
          onConvert: (_) {},
        ),
      ),
    );

class _PreviewResponses extends HostFormResponsesController {
  @override
  Future<HostFormResponsesState> build(
    HostFormResponseListRequest request,
  ) async =>
      HostFormResponsesState(responses: [_response.response], nextCursor: null);
}

HostFormSummary _previewPublishedSummary(String organizerId, String formId) =>
    HostFormSummary(
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

Map<String, Object?> _previewPublishedDefinition() => {
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
        _previewPublishedQuestion(
          id: 'full_name',
          label: 'Full name',
          kind: 'shortText',
          canonicalFieldId: 'fullName',
        ),
        _previewPublishedQuestion(
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
        _previewPublishedQuestion(
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

Map<String, Object?> _previewPublishedQuestion({
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

Map<String, Object?> _previewDetailMap() => {
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
