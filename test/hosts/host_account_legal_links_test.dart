import 'dart:async';

import 'package:catch_dating_app/core/external_links.dart';
import 'package:catch_dating_app/core/legal_links.dart';
import 'package:catch_dating_app/core/riverpod_ui/catch_notice_overlay.dart';
import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/hosts/presentation/host_operations_screen.dart';
import 'package:catch_dating_app/l10n/generated/app_localizations.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:url_launcher/url_launcher.dart';

import '../test_pump_helpers.dart';

final _legalLinks = LegalLinks(
  privacyPolicy: Uri.parse('https://catchdates.com/privacy/'),
  terms: Uri.parse('https://catchdates.com/terms/'),
  help: Uri.parse('https://catchdates.com/help/'),
);

Future<void> _pump(
  WidgetTester tester, {
  required LegalLinks legalLinks,
  required ExternalUrlLauncher launcher,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        legalLinksProvider.overrideWithValue(legalLinks),
        externalUrlLauncherProvider.overrideWithValue(launcher),
      ],
      child: MaterialApp(
        theme: AppTheme.light,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (_, child) => CatchNoticeOverlay(child: child!),
        home: const HostClubsScaffold(
          clubs: [],
          currentUid: 'host-legal-links-test',
          initialTab: HostClubTab.edit,
        ),
      ),
    ),
  );
  await pumpFeatureUi(tester);
}

Future<void> _openAccountMenu(WidgetTester tester) async {
  await tester.tap(find.byKey(const ValueKey('host-account-menu')));
  await pumpFeatureUi(tester);
}

CatchActionMenu<String> _accountMenu(WidgetTester tester) =>
    tester.widget(find.byKey(const ValueKey('host-account-menu')));

CatchIconAction _signOutAction(WidgetTester tester) =>
    tester.widget(find.byKey(const ValueKey('host-organizer-sign-out')));

void main() {
  for (final (label, expected) in [
    ('Privacy policy', 'https://catchdates.com/privacy/'),
    ('Terms', 'https://catchdates.com/terms/'),
    ('Help & support', 'https://catchdates.com/help/'),
  ]) {
    testWidgets('Host account menu opens $label externally', (tester) async {
      Uri? launchedUri;
      LaunchMode? launchMode;
      await _pump(
        tester,
        legalLinks: _legalLinks,
        launcher: (uri, {mode = LaunchMode.platformDefault}) async {
          launchedUri = uri;
          launchMode = mode;
          return true;
        },
      );
      await _openAccountMenu(tester);
      expect(find.text('Privacy policy'), findsOneWidget);
      expect(find.text('Terms'), findsOneWidget);
      expect(find.text('Help & support'), findsOneWidget);
      expect(find.text('Delete account'), findsOneWidget);

      await tester.tap(find.text(label));
      await pumpFeatureUi(tester);

      expect(launchedUri, Uri.parse(expected));
      expect(launchMode, LaunchMode.externalApplication);
      expect(find.text('Delete account?'), findsNothing);
    });
  }

  testWidgets('Host account menu hides unconfigured legal destinations', (
    tester,
  ) async {
    var launchCount = 0;
    await _pump(
      tester,
      legalLinks: const LegalLinks(),
      launcher: (uri, {mode = LaunchMode.platformDefault}) async {
        launchCount++;
        return true;
      },
    );
    await _openAccountMenu(tester);

    expect(find.text('Privacy policy'), findsNothing);
    expect(find.text('Terms'), findsNothing);
    expect(find.text('Help & support'), findsNothing);
    expect(find.text('Delete account'), findsOneWidget);
    expect(launchCount, 0);
  });

  testWidgets('pending Host legal launch freezes account actions', (
    tester,
  ) async {
    final launchResult = Completer<bool>();
    await _pump(
      tester,
      legalLinks: _legalLinks,
      launcher: (uri, {mode = LaunchMode.platformDefault}) =>
          launchResult.future,
    );
    await _openAccountMenu(tester);
    await tester.tap(find.text('Terms'));
    await tester.pump();

    expect(_accountMenu(tester).enabled, isFalse);
    expect(_signOutAction(tester).onPressed, isNull);

    launchResult.complete(false);
    await pumpFeatureUi(tester);

    expect(
      find.text('Could not open that link. Please try again.'),
      findsOneWidget,
    );
    expect(_accountMenu(tester).enabled, isTrue);
    expect(_signOutAction(tester).onPressed, isNotNull);
  });

  testWidgets('Host legal link launch failure is visible', (tester) async {
    await _pump(
      tester,
      legalLinks: _legalLinks,
      launcher: (uri, {mode = LaunchMode.platformDefault}) async =>
          throw StateError('launcher unavailable'),
    );
    await _openAccountMenu(tester);
    await tester.tap(find.text('Privacy policy'));
    await pumpFeatureUi(tester);

    expect(
      find.text('Could not open that link. Please try again.'),
      findsOneWidget,
    );
  });
}
