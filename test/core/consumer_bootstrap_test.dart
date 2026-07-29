import 'dart:async';

import 'package:catch_dating_app/app_bootstrap.dart';
import 'package:catch_dating_app/consumer_bootstrap.dart';
import 'package:catch_dating_app/core/app_config.dart';
import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('animated bootstrap is consumer mobile only', () {
    expect(
      usesAnimatedConsumerBootstrap(
        appRole: AppRole.consumer,
        isWeb: false,
        platform: TargetPlatform.iOS,
      ),
      isTrue,
    );
    expect(
      usesAnimatedConsumerBootstrap(
        appRole: AppRole.consumer,
        isWeb: false,
        platform: TargetPlatform.android,
      ),
      isTrue,
    );
    expect(
      usesAnimatedConsumerBootstrap(
        appRole: AppRole.host,
        isWeb: false,
        platform: TargetPlatform.iOS,
      ),
      isFalse,
    );
    expect(
      usesAnimatedConsumerBootstrap(
        appRole: AppRole.consumer,
        isWeb: true,
        platform: TargetPlatform.iOS,
      ),
      isFalse,
    );
    expect(
      usesAnimatedConsumerBootstrap(
        appRole: AppRole.consumer,
        isWeb: false,
        platform: TargetPlatform.macOS,
      ),
      isFalse,
    );
  });

  testWidgets('initialized app waits for both startup work and the reel', (
    tester,
  ) async {
    var nativeHandoffs = 0;

    await tester.pumpWidget(
      CatchConsumerBootstrap(
        initialize: () async {},
        initializedAppBuilder: (_) =>
            const MaterialApp(home: Text('Initialized app')),
        onNativeSplashReady: () => nativeHandoffs += 1,
        prepareFirstFrame: _prepareFirstFrame,
      ),
    );

    expect(find.text('Initialized app'), findsNothing);
    expect(find.byKey(CatchConsumerBootstrap.bootKey), findsOneWidget);

    await tester.pumpAndSettle();

    expect(find.text('Initialized app'), findsOneWidget);
    expect(nativeHandoffs, 1);
  });

  testWidgets('startup work can outlast the reel without exposing the router', (
    tester,
  ) async {
    final initialization = Completer<void>();
    var nativeHandoffs = 0;

    await tester.pumpWidget(
      CatchConsumerBootstrap(
        initialize: () => initialization.future,
        initializedAppBuilder: (_) =>
            const MaterialApp(home: Text('Initialized app')),
        onNativeSplashReady: () => nativeHandoffs += 1,
        playIntro: false,
        prepareFirstFrame: _prepareFirstFrame,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Initialized app'), findsNothing);
    expect(find.textContaining('someone real'), findsWidgets);
    expect(nativeHandoffs, 1);

    initialization.complete();
    await tester.pumpAndSettle();

    expect(find.text('Initialized app'), findsOneWidget);
  });

  testWidgets('handoff never overlaps independent MaterialApp roots', (
    tester,
  ) async {
    final initialization = Completer<void>();

    await tester.pumpWidget(
      CatchConsumerBootstrap(
        initialize: () => initialization.future,
        initializedAppBuilder: (_) =>
            const MaterialApp(home: Text('Initialized app')),
        onNativeSplashReady: () {},
        playIntro: false,
        prepareFirstFrame: _prepareFirstFrame,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.byKey(CatchConsumerBootstrap.bootKey), findsOneWidget);

    initialization.complete();
    await tester.pump();
    await tester.pump();

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.byKey(CatchConsumerBootstrap.bootKey), findsNothing);
    expect(find.byKey(CatchConsumerBootstrap.initializedKey), findsOneWidget);
    expect(find.text('Initialized app'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'bootstrap failure is retryable and never repeats native handoff',
    (tester) async {
      var attempts = 0;
      var nativeHandoffs = 0;

      await tester.pumpWidget(
        CatchConsumerBootstrap(
          initialize: () async {
            attempts += 1;
            if (attempts == 1) throw StateError('startup failed');
          },
          initializedAppBuilder: (_) =>
              const MaterialApp(home: Text('Initialized app')),
          onNativeSplashReady: () => nativeHandoffs += 1,
          playIntro: false,
          prepareFirstFrame: _prepareFirstFrame,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(CatchConsumerBootstrap.failureKey), findsOneWidget);
      expect(find.widgetWithText(CatchButton, 'Try again'), findsOneWidget);

      await tester.tap(find.widgetWithText(CatchButton, 'Try again'));
      await tester.pumpAndSettle();

      expect(attempts, 2);
      expect(nativeHandoffs, 1);
      expect(find.text('Initialized app'), findsOneWidget);
    },
  );

  testWidgets('boot reel lands without mounting logged-out actions', (
    tester,
  ) async {
    var firstFrames = 0;
    var completions = 0;

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        home: CatchConsumerBootScreen(
          playIntro: false,
          onFirstFlutterFrameReady: () => firstFrames += 1,
          onAnimationComplete: () => completions += 1,
          prepareFirstFrame: _prepareFirstFrame,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(firstFrames, 1);
    expect(completions, 1);
    expect(find.textContaining('someone real'), findsWidgets);
    expect(
      find.widgetWithText(CatchButton, 'Continue with phone'),
      findsNothing,
    );
    expect(find.widgetWithText(CatchButton, 'See what\'s on'), findsNothing);
  });
}

Future<void> _prepareFirstFrame(BuildContext context, String asset) async {}
