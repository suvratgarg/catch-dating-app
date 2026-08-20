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
    expect(find.text('What do you need to know?'), findsOneWidget);
    expect(
      find.text('Choose the questions that will help you decide who to call.'),
      findsOneWidget,
    );
    expect(find.text('Full name'), findsOneWidget);
    expect(find.text('Short text · Required'), findsOneWidget);
    expect(find.text('Add question'), findsOneWidget);
    expect(find.text('Reorder questions'), findsNothing);
    expect(find.byIcon(Icons.drag_indicator_rounded), findsNWidgets(2));
    expect(find.text('Continue to settings'), findsOneWidget);
    expect(find.text('Form title'), findsNothing);
  });

  testWidgets(
    'question editor stays focused and settings are a distinct step',
    (tester) async {
      await _pumpBuilder(tester);

      await tester.tap(find.text('Full name'));
      await pumpFeatureUi(tester);

      expect(find.text('Edit question'), findsOneWidget);
      expect(find.text('Question'), findsOneWidget);
      expect(find.text('Answer type'), findsOneWidget);
      expect(find.text('Response required'), findsOneWidget);
      expect(find.text('Advanced settings'), findsOneWidget);
      expect(find.text('Data classification'), findsNothing);

      await tester.tap(find.text('Advanced settings'));
      await pumpFeatureUi(tester);

      expect(find.text('Data classification'), findsOneWidget);
      expect(find.text('Prefill behavior'), findsOneWidget);
      expect(find.text('Host response view'), findsOneWidget);

      Navigator.of(tester.element(find.text('Question'))).pop();
      await pumpFeatureUi(tester);

      await tester.tap(find.text('Continue to settings'));
      await pumpFeatureUi(tester);

      expect(find.text('How should this form work?'), findsOneWidget);
      expect(find.text('Form title'), findsOneWidget);
      expect(find.text('Who can respond'), findsOneWidget);
      expect(find.text('Continue to publish'), findsOneWidget);
    },
  );

  testWidgets('publish step summarizes readiness and keeps preview explicit', (
    tester,
  ) async {
    await _pumpBuilder(tester);

    await tester.tap(find.text('Continue to settings'));
    await pumpFeatureUi(tester);
    await ensureCentered(tester, find.text('Continue to publish'));
    await tester.tap(find.text('Continue to publish'));
    await pumpFeatureUi(tester);

    expect(find.text('Ready to publish?'), findsOneWidget);
    expect(find.text('Verified phone required'), findsOneWidget);
    expect(find.text('2 questions'), findsOneWidget);
    expect(find.text('Preview'), findsWidgets);
    expect(find.text('Publish form'), findsOneWidget);
  });

  testWidgets('inline drag handle changes the persisted question order', (
    tester,
  ) async {
    await _pumpBuilder(tester);

    final reorderList = tester.widget<ReorderableListView>(
      find.byType(ReorderableListView),
    );
    reorderList.onReorderItem!(0, 2);
    await tester.pump();

    final phoneRow = find.descendant(
      of: find.byKey(const ValueKey('form-question-question_2')),
      matching: find.text('Phone number'),
    );
    final nameRow = find.descendant(
      of: find.byKey(const ValueKey('form-question-question_1')),
      matching: find.text('Full name'),
    );
    expect(
      tester.getTopLeft(phoneRow).dy,
      lessThan(tester.getTopLeft(nameRow).dy),
    );
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

  @override
  void moveQuestion(int sectionIndex, int questionIndex, int delta) {
    final current = state.requireValue;
    final currentSection = current.editor.definition.sections[sectionIndex];
    final target = (questionIndex + delta)
        .clamp(0, currentSection.questions.length - 1)
        .toInt();
    final definition = current.editor.definition.replaceSection(
      sectionIndex,
      currentSection.moveQuestion(questionIndex, target),
    );
    state = AsyncData(
      current.copyWith(editor: current.editor.copyWith(definition: definition)),
    );
  }
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
        {
          'questionId': 'question_2',
          'key': 'phone_number',
          'label': 'Phone number',
          'helpText': null,
          'kind': 'phone',
          'required': true,
          'options': <Object?>[],
          'canonicalFieldId': 'phoneNumber',
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
