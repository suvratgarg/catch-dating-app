import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_bottom_action.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_icon_button.dart';
import 'package:catch_dating_app/core/widgets/catch_metric_strip.dart';
import 'package:catch_dating_app/core/widgets/catch_top_bar.dart';
import 'package:catch_dating_app/hosts/domain/host_form.dart';
import 'package:catch_dating_app/hosts/domain/host_form_operations.dart';
import 'package:catch_dating_app/hosts/presentation/forms/host_form_builder_screen.dart';
import 'package:catch_dating_app/hosts/presentation/forms/host_form_operations_controller.dart';
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
    expect(find.text('Responses · 2'), findsOneWidget);
    expect(find.text('DRAFT · 2 QUESTIONS'), findsOneWidget);
    expect(find.text('Questions'), findsWidgets);
    expect(find.text('What do you need to know?'), findsNothing);
    expect(
      find.text('Choose the questions that will help you decide who to call.'),
      findsOneWidget,
    );
    expect(
      find.textContaining('Full name', findRichText: true),
      findsOneWidget,
    );
    expect(
      find.textContaining('Short text · Required', findRichText: true),
      findsOneWidget,
    );
    expect(find.text('Add question'), findsOneWidget);
    expect(find.text('Reorder questions'), findsNothing);
    expect(find.byIcon(Icons.drag_indicator_rounded), findsNWidgets(2));
    expect(find.text('Form settings'), findsOneWidget);
    expect(find.text('2 questions · Ready to publish?'), findsOneWidget);
    expect(find.text('Review & publish'), findsOneWidget);
    expect(find.text('Continue to settings'), findsNothing);
    expect(find.text('Continue to publish'), findsNothing);
    expect(find.text('Form title'), findsNothing);
    final topBar = find.byType(CatchTopBar);
    expect(tester.widget<CatchTopBar>(topBar).titleWidget, isNull);
    final titleFinder = find.descendant(
      of: topBar,
      matching: find.text('Saturday Social application'),
    );
    final titleContext = tester.element(titleFinder);
    expect(
      tester.widget<Text>(titleFinder).style,
      CatchTextStyles.routeTitle(
        titleContext,
        color: CatchTokens.of(titleContext).ink,
      ),
    );
    final topBarButtons = find.descendant(
      of: topBar,
      matching: find.byType(CatchIconButton),
    );
    expect(topBarButtons, findsNWidgets(3));
    expect(
      tester
          .widgetList<CatchIconButton>(topBarButtons)
          .map((button) => button.variant),
      everyElement(CatchIconButtonVariant.bordered),
    );
    expect(
      find.descendant(
        of: topBar,
        matching: find.byIcon(CatchIcons.arrowBackIosNewRounded),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: topBar,
        matching: find.byIcon(CatchIcons.visibilityOutlined),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: topBar,
        matching: find.byIcon(CatchIcons.moreHorizRounded),
      ),
      findsOneWidget,
    );
    expect(
      tester
          .widget<CatchBottomAction>(find.byType(CatchBottomAction))
          .buttonShape,
      CatchButtonShape.rounded,
    );
  });

  testWidgets(
    'tablet builder keeps three panes and publish in the command bar',
    (tester) async {
      await _pumpBuilder(tester, size: const Size(1024, 1366));

      expect(find.text('Outline'), findsOneWidget);
      expect(find.text('SECTION 1'), findsOneWidget);
      expect(find.byType(CatchBottomAction), findsNothing);
      final publishAction = find.byType(CatchTopBarPrimaryAction);
      expect(publishAction, findsOneWidget);
      expect(
        tester.widget<CatchTopBarPrimaryAction>(publishAction).label,
        'Review & publish',
      );

      await tester.tap(find.byIcon(CatchIcons.moreHorizRounded));
      await pumpFeatureUi(tester);
      expect(find.text('Preview'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'question editor stays focused and settings remain directly reachable',
    (tester) async {
      await _pumpBuilder(tester);

      final fullNameRowLabel = find
          .descendant(
            of: find.byKey(const ValueKey('form-question-question_1')),
            matching: find.textContaining('Full name', findRichText: true),
          )
          .first;
      await ensureCentered(tester, fullNameRowLabel);
      await tester.tap(fullNameRowLabel);
      await pumpFeatureUi(tester);

      expect(
        find.byKey(const ValueKey('form-question-question_1-editor')),
        findsOneWidget,
      );
      expect(find.text('Edit question'), findsNothing);
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

      await ensureCentered(tester, fullNameRowLabel);
      await tester.tap(fullNameRowLabel);
      await pumpFeatureUi(tester);

      expect(
        find.byKey(const ValueKey('form-question-question_1-editor')),
        findsNothing,
      );

      await ensureCentered(tester, find.text('Form settings'));
      await tester.tap(find.text('Form settings'));
      await pumpFeatureUi(tester);

      expect(find.text('Form settings'), findsWidgets);
      expect(find.text('Form title'), findsOneWidget);
      expect(find.text('Who can respond'), findsWidgets);
      expect(find.text('Identity consequence'), findsOneWidget);
      expect(find.textContaining('Verifies phone'), findsOneWidget);
      expect(
        find.textContaining(
          'Identity checks and contact creation do not grant messaging permission.',
        ),
        findsOneWidget,
      );
    },
  );

  testWidgets('publish review names cross-workspace consequences and limits', (
    tester,
  ) async {
    await _pumpBuilder(tester);

    await tester.tap(find.text('Review & publish'));
    await pumpFeatureUi(tester);

    expect(find.text('Review before publishing'), findsOneWidget);
    expect(find.text('What publishing does'), findsOneWidget);
    expect(
      find.text('Verifies phone · Sends a record to application review'),
      findsOneWidget,
    );
    expect(find.text('Messaging permission'), findsOneWidget);
    expect(
      find.text(
        'Identity checks and contact creation do not grant messaging permission.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('publish review labels incomplete legacy automation coverage', (
    tester,
  ) async {
    await _pumpBuilder(tester, legacyConsequences: true);

    await tester.tap(find.text('Review & publish'));
    await pumpFeatureUi(tester);

    expect(
      find.text(
        'Verifies phone · Sends a record to application review · '
        'Automation consequences need review',
      ),
      findsOneWidget,
    );
  });

  testWidgets('opening a question closes the previously expanded editor', (
    tester,
  ) async {
    await _pumpBuilder(tester);

    await tester.tap(find.textContaining('Full name', findRichText: true));
    await pumpFeatureUi(tester);
    expect(
      find.byKey(const ValueKey('form-question-question_1-editor')),
      findsOneWidget,
    );

    final phoneNumberRowLabel = find.descendant(
      of: find.byKey(const ValueKey('form-question-question_2')),
      matching: find.textContaining('Phone number', findRichText: true),
    );
    await ensureCentered(tester, phoneNumberRowLabel);
    await tester.tap(phoneNumberRowLabel);
    await pumpFeatureUi(tester);

    expect(
      find.byKey(const ValueKey('form-question-question_1-editor')),
      findsNothing,
    );
    expect(
      find.byKey(const ValueKey('form-question-question_2-editor')),
      findsOneWidget,
    );
  });

  testWidgets('single page summarizes readiness and keeps preview explicit', (
    tester,
  ) async {
    await _pumpBuilder(tester);

    expect(find.text('2 questions · Ready to publish?'), findsOneWidget);
    expect(find.byTooltip('Preview'), findsOneWidget);
    expect(find.text('Review & publish'), findsOneWidget);
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
      matching: find.textContaining('Phone number', findRichText: true),
    );
    final nameRow = find.descendant(
      of: find.byKey(const ValueKey('form-question-question_1')),
      matching: find.textContaining('Full name', findRichText: true),
    );
    expect(
      tester.getTopLeft(phoneRow).dy,
      lessThan(tester.getTopLeft(nameRow).dy),
    );
    expect(
      tester
          .getCenter(
            find.byKey(const ValueKey('form-question-question_2-drag')),
          )
          .dx,
      lessThan(tester.getTopLeft(phoneRow).dx),
    );
    expect(
      tester
          .getCenter(
            find.byKey(const ValueKey('form-question-question_2-drag')),
          )
          .dy,
      closeTo(tester.getCenter(phoneRow).dy, 0.5),
    );
  });

  testWidgets('published form opens on its operational command center', (
    tester,
  ) async {
    await _pumpBuilder(tester, published: true);

    expect(
      find.byKey(const ValueKey('host-form-command-center')),
      findsOneWidget,
    );
    expect(find.text('Saturday Social application'), findsOneWidget);
    expect(find.text('View responses'), findsOneWidget);
    expect(find.text('Maya Kapoor'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('host-form-command-center-metrics')),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('host-form-builder-tabs')), findsNothing);

    await tester.tap(
      find.byKey(const ValueKey('host-form-command-center-edit')),
    );
    await pumpFeatureUi(tester);

    expect(
      find.byKey(const ValueKey('host-form-command-center')),
      findsNothing,
    );
    expect(
      find.byKey(const ValueKey('host-form-builder-tabs')),
      findsOneWidget,
    );
  });

  testWidgets('published command center reflows at large text in dark mode', (
    tester,
  ) async {
    await _pumpBuilder(
      tester,
      published: true,
      textScale: 2,
      disableAnimations: true,
      theme: AppTheme.dark,
    );

    final title = find.byKey(const ValueKey('host-form-command-center-title'));
    final edit = find.byKey(const ValueKey('host-form-command-center-edit'));
    expect(
      tester.getBottomLeft(title).dy,
      lessThan(tester.getTopLeft(edit).dy),
    );
    expect(
      find.byKey(const ValueKey('catch_metric_strip.reflow')),
      findsOneWidget,
    );
    final metricCells = find.byType(CatchMetricStripCell);
    expect(metricCells, findsNWidgets(3));
    expect(
      tester.getCenter(metricCells.at(0)).dy,
      lessThan(tester.getCenter(metricCells.at(1)).dy),
    );
    expect(
      tester.getSize(find.widgetWithText(CatchButton, 'View responses')).height,
      greaterThan(CatchSpacing.s12),
    );
    expect(tester.takeException(), isNull);
  });
}

Future<void> _pumpBuilder(
  WidgetTester tester, {
  bool published = false,
  bool legacyConsequences = false,
  double textScale = 1,
  bool disableAnimations = false,
  ThemeData? theme,
  Size size = const Size(390, 844),
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPhysicalSize);
  final summary = _summaryMap();
  if (legacyConsequences) {
    summary['consequences'] = <String, Object?>{
      'coverage': 'identityOnly',
      'identityPolicy': 'phoneVerified',
      'enabledAutomationActionKinds': <Object?>[],
    };
  }
  if (published) {
    summary
      ..['status'] = 'published'
      ..['activeVersionId'] = 'version_1'
      ..['publishedVersion'] = 1
      ..['submittedResponseCount'] = 12
      ..['publishedAtMillis'] = DateTime(2026, 8, 20).millisecondsSinceEpoch
      ..['lastResponseAtMillis'] = DateTime(
        2026,
        8,
        20,
        10,
        42,
      ).millisecondsSinceEpoch;
  }
  final state = HostFormEditorState(
    editor: HostFormEditor(
      form: HostFormSummary.fromMap(summary),
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
        if (published)
          hostFormResponsesControllerProvider.overrideWith2(
            (_) => _FakeHostFormResponsesController(),
          ),
      ],
      child: MaterialApp(
        theme: theme ?? AppTheme.light,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(textScale),
            disableAnimations: disableAnimations,
          ),
          child: child!,
        ),
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

class _FakeHostFormResponsesController extends HostFormResponsesController {
  @override
  Future<HostFormResponsesState> build(
    HostFormResponseListRequest request,
  ) async => HostFormResponsesState(
    responses: [HostFormResponseSummary.fromMap(_responseSummaryMap())],
    nextCursor: null,
  );
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
  'consequences': {
    'coverage': 'exact',
    'identityPolicy': 'phoneVerified',
    'enabledAutomationActionKinds': <Object?>[],
  },
  'updatedAtMillis': 1,
  'publishedAtMillis': null,
  'lastResponseAtMillis': null,
};

Map<String, Object?> _responseSummaryMap() => {
  'responseId': 'response_1',
  'formId': 'form_1',
  'formTitle': 'Saturday Social application',
  'versionId': 'version_1',
  'version': 1,
  'status': 'submitted',
  'identityKind': 'phoneVerified',
  'identity': {
    'displayName': 'Maya Kapoor',
    'email': null,
    'phoneE164': '+919876543210',
    'origin': 'respondentGranted',
  },
  'sourceLinkId': null,
  'sourceLabel': 'Instagram',
  'submittedAtMillis': DateTime(2026, 8, 20, 10, 42).millisecondsSinceEpoch,
  'withdrawnAtMillis': null,
  'highlights': <Object?>[],
  'conversionKinds': <Object?>[],
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
