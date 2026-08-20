import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/hosts/domain/host_form.dart';
import 'package:catch_dating_app/hosts/presentation/forms/host_form_builder_screen.dart';
import 'package:catch_dating_app/hosts/presentation/forms/host_forms_controller.dart';
import 'package:catch_dating_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../test_pump_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('compact builder leads with questions instead of raw settings', (
    tester,
  ) async {
    await _pumpBuilder(tester);

    expect(find.text('Build'), findsOneWidget);
    expect(find.text('Responses 2'), findsOneWidget);
    expect(find.text('Questions'), findsOneWidget);
    expect(find.text('Full name'), findsOneWidget);
    expect(find.text('Short text · Required'), findsOneWidget);
    expect(find.text('Add question'), findsOneWidget);
    expect(find.text('Form settings'), findsOneWidget);
    expect(find.text('Review & publish'), findsOneWidget);
    expect(find.text('Form title'), findsNothing);
    expect(
      find.text(
        'Publishing validates the draft and creates an immutable respondent version.',
      ),
      findsNothing,
    );
  });

  testWidgets('question and form settings open focused edit sheets', (
    tester,
  ) async {
    await _pumpBuilder(tester);

    await tester.tap(find.text('Full name'));
    await pumpFeatureUi(tester);

    expect(find.text('Question'), findsOneWidget);
    expect(find.text('Answer type'), findsOneWidget);
    expect(find.text('Response required'), findsOneWidget);

    Navigator.of(tester.element(find.text('Question'))).pop();
    await pumpFeatureUi(tester);

    await ensureCentered(tester, find.text('Form settings'));
    await tester.tap(find.text('Form settings'));
    await pumpFeatureUi(tester);

    expect(find.text('Form title'), findsOneWidget);
    expect(find.text('Who can respond'), findsOneWidget);
  });
}

Future<void> _pumpBuilder(WidgetTester tester) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = const Size(390, 844);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPhysicalSize);
  final state = HostFormEditorState(
    editor: HostFormEditor(
      form: HostFormSummary.fromMap(_summaryMap()),
      definition: HostFormDefinition.fromMap(_definitionMap()),
      validationIssues: const [],
    ),
  );
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        hostFormEditorControllerProvider(
          'org_1',
          'form_1',
        ).overrideWith(() => _FakeHostFormEditorController(state)),
      ],
      child: MaterialApp(
        theme: AppTheme.light,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const HostFormBuilderScreen(
          organizerId: 'org_1',
          formId: 'form_1',
        ),
      ),
    ),
  );
  await pumpFeatureUi(tester);
}

class _FakeHostFormEditorController extends HostFormEditorController {
  _FakeHostFormEditorController(this.initialState);

  final HostFormEditorState initialState;

  @override
  Future<HostFormEditorState> build(String organizerId, String formId) async =>
      initialState;
}

Map<String, Object?> _summaryMap() => {
  'organizerId': 'org_1',
  'formId': 'form_1',
  'title': 'Saturday Social application',
  'description': null,
  'purpose': 'application',
  'status': 'draft',
  'templateId': 'event_application',
  'publicFormId': 'public_1',
  'defaultTargetKind': 'organizer',
  'defaultTargetId': null,
  'activeVersionId': null,
  'draftRevision': 2,
  'publishedVersion': 0,
  'submittedResponseCount': 2,
  'updatedAtMillis': 1,
  'publishedAtMillis': null,
  'lastResponseAtMillis': null,
};

Map<String, Object?> _definitionMap() => {
  'schemaVersion': 1,
  'title': 'Saturday Social application',
  'description': 'Tell us a little about yourself.',
  'purpose': 'application',
  'identityPolicy': 'phoneVerified',
  'sections': [
    {
      'sectionId': 'section_1',
      'title': 'About you',
      'description': null,
      'pageBreak': false,
      'questions': [
        {
          'questionId': 'question_1',
          'key': 'full_name',
          'label': 'Full name',
          'helpText': null,
          'kind': 'shortText',
          'required': true,
          'options': <Object?>[],
          'canonicalFieldId': 'fullName',
          'privacyClass': 'contact',
          'prefillPolicy': 'never',
          'hostPresentation': 'detailOnly',
          'validation': _validationMap(),
        },
      ],
    },
  ],
  'logicRules': <Object?>[],
  'appearance': {
    'preset': 'minimal',
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
    'consentCopy': 'I consent.',
    'consentVersion': 'v1',
    'retentionCopy': 'Retained for this form purpose.',
  },
  'completion': {
    'title': 'Thanks',
    'message': 'We will be in touch.',
    'actionKind': 'none',
    'actionLabel': null,
    'actionUrl': null,
  },
};

Map<String, Object?> _validationMap() => {
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
};
