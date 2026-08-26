import 'package:catch_dating_app/core/external_links.dart';
import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_bottom_dock.dart';
import 'package:catch_dating_app/hosts/domain/host_form_operations.dart';
import 'package:catch_dating_app/hosts/presentation/forms/host_form_operations_controller.dart';
import 'package:catch_dating_app/hosts/presentation/forms/host_form_response_detail_screen.dart';
import 'package:catch_dating_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../test_pump_helpers.dart';

void main() {
  testWidgets('response detail prioritizes identity, contact, and answers', (
    tester,
  ) async {
    final launched = <Uri>[];
    await _pumpDetail(tester, launched: launched);

    expect(
      find.byKey(const ValueKey('host-form-response-name')),
      findsOneWidget,
    );
    expect(find.text('Maya Kapoor'), findsOneWidget);
    expect(find.text('Saturday Social application'), findsOneWidget);
    expect(find.text('Submitted · Phone'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('host-form-response-call')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('host-form-response-email')),
      findsOneWidget,
    );
    expect(find.text('Why do you want to join?'), findsOneWidget);
    expect(find.text('I love meeting new people in the city.'), findsOneWidget);
    expect(find.byType(CatchBottomDock), findsOneWidget);
    expect(
      find.byKey(const ValueKey('host-form-response-convert-application')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('host-form-response-convert-crm')),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const ValueKey('host-form-response-call')));
    await pumpFeatureUi(tester);
    expect(launched.single, Uri(scheme: 'tel', path: '+919876543210'));
  });

  testWidgets('response detail reflows identity and actions at large text', (
    tester,
  ) async {
    await _pumpDetail(
      tester,
      theme: AppTheme.dark,
      textScale: 2,
      disableAnimations: true,
    );

    expect(tester.takeException(), isNull);
    final name = find.byKey(const ValueKey('host-form-response-name'));
    final status = find.byKey(const ValueKey('host-form-response-status'));
    await pumpUntilFound(tester, name);
    expect(
      tester.getBottomLeft(name).dy,
      lessThan(tester.getTopLeft(status).dy),
    );
    expect(
      tester
          .getSize(
            find.byKey(
              const ValueKey('host-form-response-convert-application'),
            ),
          )
          .height,
      greaterThan(CatchSpacing.s12),
    );
    expect(
      tester
          .getSize(find.byKey(const ValueKey('host-form-response-convert-crm')))
          .height,
      greaterThan(CatchSpacing.s12),
    );
    expect(find.byType(CatchBottomDock), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

Future<void> _pumpDetail(
  WidgetTester tester, {
  List<Uri>? launched,
  ThemeData? theme,
  double textScale = 1,
  bool disableAnimations = false,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = const Size(390, 844);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPhysicalSize);
  final detail = HostFormResponseDetail.fromCallableData(_detailMap());
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
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
