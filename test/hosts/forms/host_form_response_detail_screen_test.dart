import 'package:catch_dating_app/core/external_links.dart';
import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/hosts/data/host_application_repository.dart';
import 'package:catch_dating_app/hosts/domain/forms/host_form_response.dart';
import 'package:catch_dating_app/hosts/presentation/forms/host_form_operations_controller.dart';
import 'package:catch_dating_app/hosts/presentation/forms/host_form_response_detail_screen.dart';
import 'package:catch_dating_app/hosts/presentation/forms/host_response_review_detail.dart';
import 'package:catch_dating_app/l10n/generated/app_localizations.dart';
import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../test_pump_helpers.dart';

void main() {
  test(
    'native response and application identities resolve the same detail',
    () async {
      final data = _detailMap()..['applicationId'] = 'app-1';
      final response = HostFormResponseDetail.fromCallableData(data);
      final container = ProviderContainer(
        overrides: [
          hostFormResponseDetailProvider(
            organizerId: 'org_1',
            responseId: 'response_1',
          ).overrideWith((_) async => response),
          hostApplicationDetailProvider(
            'org_1',
            'app-1',
          ).overrideWith((_) async => _application()),
        ],
      );
      addTearDown(container.dispose);
      final fromResponse = await container.read(
        hostResponseReviewDetailProvider((
          organizerId: 'org_1',
          responseId: 'response_1',
          applicationId: null,
        )).future,
      );
      final fromApplication = await container.read(
        hostResponseReviewDetailProvider((
          organizerId: 'org_1',
          responseId: null,
          applicationId: 'app-1',
        )).future,
      );
      expect(fromResponse.response, same(fromApplication.response));
      expect(
        fromResponse.application?.applicationId,
        fromApplication.application?.applicationId,
      );
      expect(fromResponse.canReview, isTrue);
      expect(fromResponse.canConvert, isTrue);
    },
  );

  test('revoked application never fetches the linked response', () async {
    var fetched = false;
    final container = ProviderContainer(
      overrides: [
        hostFormResponseDetailProvider(
          organizerId: 'org_1',
          responseId: 'response_1',
        ).overrideWith((_) async {
          fetched = true;
          return HostFormResponseDetail.fromCallableData(_detailMap());
        }),
        hostApplicationDetailProvider(
          'org_1',
          'app-1',
        ).overrideWith((_) async => _application(revoked: true)),
      ],
    );
    addTearDown(container.dispose);
    final detail = await container.read(
      hostResponseReviewDetailProvider((
        organizerId: 'org_1',
        responseId: null,
        applicationId: 'app-1',
      )).future,
    );
    expect(fetched, isFalse);
    expect(detail.response, isNull);
    expect(detail.canReview, isFalse);
    expect(detail.canConvert, isFalse);
  });

  test(
    'missing linked application fails closed rather than dropping review',
    () async {
      final data = _detailMap()..['applicationId'] = 'app-1';
      final container = ProviderContainer(
        overrides: [
          hostFormResponseDetailProvider(
            organizerId: 'org_1',
            responseId: 'response_1',
          ).overrideWith(
            (_) async => HostFormResponseDetail.fromCallableData(data),
          ),
          hostApplicationDetailProvider(
            'org_1',
            'app-1',
          ).overrideWith((_) async => throw StateError('unavailable')),
        ],
        retry: (_, _) => null,
      );
      addTearDown(container.dispose);
      await expectLater(
        container.read(
          hostResponseReviewDetailProvider((
            organizerId: 'org_1',
            responseId: 'response_1',
            applicationId: null,
          )).future,
        ),
        throwsStateError,
      );
    },
  );

  testWidgets('one flat detail keeps answers and opens full contact targets', (
    tester,
  ) async {
    final launched = <Uri>[];
    await _pumpDetail(tester, launched: launched);
    expect(find.text('Maya Kapoor'), findsOneWidget);
    expect(find.text('Saturday Social application'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('catch_bottom_action.floating_chrome')),
      findsNothing,
    );
    expect(
      find.byKey(const ValueKey('catch_bottom_action.page_action')),
      findsOneWidget,
    );
    expect(find.text('Review application'), findsNothing);
    expect(find.text('Why do you want to join?'), findsOneWidget);
    final call = find.widgetWithText(CatchButton, 'Call');
    final email = find.widgetWithText(CatchButton, 'Email');
    expect(tester.getSize(call).width, tester.getSize(email).width);
    expect(tester.getSize(call).height, greaterThanOrEqualTo(44));
    await tester.tapAt(tester.getTopLeft(call) + const Offset(6, 6));
    await pumpFeatureUi(tester);
    expect(launched.single, Uri(scheme: 'tel', path: '+919876543210'));
    final disclosure = find.text('Submission details');
    await tester.ensureVisible(disclosure);
    await tester.tap(disclosure);
    await pumpFeatureUi(tester);
    expect(find.text('Consent version'), findsOneWidget);
    expect(find.textContaining('Published version 1'), findsOneWidget);
  });

  testWidgets(
    'large text stacks contacts and keeps final content above action',
    (tester) async {
      await _pumpDetail(
        tester,
        theme: AppTheme.dark,
        textScale: 2,
        disableAnimations: true,
      );
      final call = find.widgetWithText(CatchButton, 'Call');
      final email = find.widgetWithText(CatchButton, 'Email');
      expect(
        tester.getBottomLeft(call).dy,
        lessThan(tester.getTopLeft(email).dy),
      );
      expect(
        find.byKey(const ValueKey('catch_bottom_action.floating_chrome')),
        findsNothing,
      );
      final action = find.byKey(
        const ValueKey('host-form-response-convert-crm-primary'),
      );
      final end = find.text('Start application review');
      await tester.ensureVisible(end);
      await pumpFeatureUi(tester);
      expect(
        tester.getBottomLeft(end).dy,
        lessThan(tester.getTopLeft(action).dy),
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'ordinary response has People action without application review',
    (tester) async {
      await _pumpDetail(tester, canApply: false);
      expect(find.text('Start application review'), findsNothing);
      expect(find.text('Add to People'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('withdrawn response keeps authorized answers without mutations', (
    tester,
  ) async {
    await _pumpDetail(tester, withdrawn: true);
    expect(
      find.byKey(const ValueKey('catch_bottom_action.page_action')),
      findsNothing,
    );
    expect(find.text('Add to People'), findsNothing);
    expect(find.text('Propose attendee'), findsNothing);
    expect(find.text('I love meeting new people in the city.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

Future<void> _pumpDetail(
  WidgetTester tester, {
  List<Uri>? launched,
  ThemeData? theme,
  double textScale = 1,
  bool disableAnimations = false,
  bool canApply = true,
  bool withdrawn = false,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = const Size(390, 844);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPhysicalSize);
  final data = _detailMap();
  if (withdrawn) {
    (data['response'] as Map<String, Object?>)['status'] = 'withdrawn';
  }
  final detail = HostFormResponseDetail.fromCallableData(data);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        hostFormResponseCanApplyProvider(
          organizerId: 'org_1',
          responseId: 'response_1',
        ).overrideWith((ref) => canApply),
        hostFormResponseDetailProvider(
          organizerId: 'org_1',
          responseId: 'response_1',
        ).overrideWith((ref) => detail),
        externalUrlLauncherProvider.overrideWithValue((
          uri, {
          mode = LaunchMode.platformDefault,
        }) async {
          launched?.add(uri);
          return true;
        }),
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
        home: const HostFormResponseDetailScreen(
          organizerId: 'org_1',
          responseId: 'response_1',
        ),
      ),
    ),
  );
  await pumpFeatureUi(tester);
  await pumpFeatureUiFor(tester, CatchMotion.fast);
  await pumpFeatureUi(tester);
}

Map<String, Object?> _detailMap() => {
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

HostApplicationDetail _application({bool revoked = false}) =>
    HostApplicationDetail(
      organizerId: 'org_1',
      applicationId: 'app-1',
      formId: 'form_1',
      formVersionId: 'version_1',
      targetKind: 'organizer',
      targetId: null,
      applicantDisplayName: 'Maya Kapoor',
      reviewStatus: HostApplicationReviewStatus.submitted,
      answers: const [],
      outreach: const HostApplicationOutreach(
        phoneE164: '+919876543210',
        email: 'maya@example.com',
        instagramUrl: null,
        linkedinUrl: null,
      ),
      reviewNote: null,
      assignedReviewerUid: null,
      submittedAt: DateTime(2026, 8, 20),
      reviewedAt: null,
      revision: 1,
      sourceResponseId: 'response_1',
      dataAccessState: revoked
          ? 'revokedParticipantGrant'
          : 'submittedFormResponse',
    );
