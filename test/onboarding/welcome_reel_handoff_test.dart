import 'package:catch_dating_app/core/analytics/app_analytics.dart';
import 'package:catch_dating_app/core/startup/catch_startup_animation_scope.dart';
import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/core/theme/catch_fonts.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/onboarding/presentation/pages/welcome_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'onboarding_test_helpers.dart';

void main() {
  group('Welcome reel handoff', () {
    testWidgets('does not replay after the consumer cold-start reel', (
      tester,
    ) async {
      final reporter = _WelcomeReelAnalyticsReporter();
      final container = createOnboardingTestContainer(
        appAnalytics: AppAnalytics(reporter: reporter, shouldCollect: true),
      );
      addTearDown(container.dispose);

      await pumpOnboardingPage(
        tester,
        container: container,
        child: const CatchStartupAnimationScope(
          consumerWelcomeReelPlayed: true,
          child: WelcomePage(),
        ),
      );

      expect(
        find.widgetWithText(CatchButton, 'Continue with phone'),
        findsOneWidget,
      );
      expect(
        find.widgetWithText(CatchButton, 'See what\'s on'),
        findsOneWidget,
      );
      expect(
        reporter.events.single.parameters,
        containsPair(AnalyticsParameters.splashMotion, 'direct'),
      );
    });

    testWidgets('landed scene pins reel and CTA anchors', (tester) async {
      tester.view.physicalSize = const Size(320, 630);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: WelcomeScene(
            viewportHeight: 630,
            mediaPadding: EdgeInsets.zero,
            spinValue: 1,
            landingValue: 1,
            landed: true,
            onContinue: () {},
            onExplore: () {},
          ),
        ),
      );

      final catchFinder = find.byKey(WelcomeScene.catchWordKey);
      final catchTopLeft = tester.getTopLeft(catchFinder);
      expect(catchTopLeft.dx, closeTo(CatchLayout.welcomeReelCatchLeft, 0.1));
      expect(
        catchTopLeft.dy,
        closeTo(
          CatchLayout.welcomeReelTop + CatchLayout.welcomeReelCatchFocusTop,
          0.1,
        ),
      );

      final phraseFinder = find.byKey(ReelRow.focusedPhraseKey);
      final phraseTopLeft = tester.getTopLeft(phraseFinder);
      expect(phraseTopLeft.dx, closeTo(CatchLayout.welcomeReelObjectLeft, 0.1));
      expect(
        phraseTopLeft.dy,
        closeTo(
          CatchLayout.welcomeReelTop + CatchLayout.welcomeReelCatchFocusTop,
          0.1,
        ),
      );
      final phraseText = tester.widget<Text>(phraseFinder);
      final rootSpan = phraseText.textSpan! as TextSpan;
      final periodSpan = rootSpan.children!.last as TextSpan;
      expect(periodSpan.text, '.');
      expect(periodSpan.style!.color!.a, closeTo(1, 0.001));
      expect(
        phraseText.style!.fontVariations,
        contains(const FontVariation('wdth', CatchFonts.archivoWidth)),
      );

      final catchParagraph = tester.renderObject<RenderParagraph>(catchFinder);
      final phraseParagraph = tester.renderObject<RenderParagraph>(
        phraseFinder,
      );
      final catchBaseline =
          catchTopLeft.dy +
          catchParagraph.getDryBaseline(
            catchParagraph.constraints,
            TextBaseline.alphabetic,
          )!;
      final phraseBaseline =
          phraseTopLeft.dy +
          phraseParagraph.getDryBaseline(
            phraseParagraph.constraints,
            TextBaseline.alphabetic,
          )!;
      expect(phraseBaseline, closeTo(catchBaseline, 0.1));

      final underlineFinder = find.byKey(ReelRow.focusedUnderlineKey);
      expect(
        tester.getTopLeft(underlineFinder).dy,
        greaterThan(tester.getBottomLeft(phraseFinder).dy),
      );

      expect(
        tester
            .getBottomLeft(find.widgetWithText(CatchButton, 'See what\'s on'))
            .dy,
        closeTo(630 - CatchLayout.welcomeButtonsBottom, 0.1),
      );
    });
  });
}

final class _WelcomeReelAnalyticsEvent {
  const _WelcomeReelAnalyticsEvent(this.name, this.parameters);

  final String name;
  final Map<String, Object>? parameters;
}

final class _WelcomeReelAnalyticsReporter implements AnalyticsReporter {
  final events = <_WelcomeReelAnalyticsEvent>[];

  @override
  Future<void> logEvent(String name, {Map<String, Object>? parameters}) async {
    events.add(_WelcomeReelAnalyticsEvent(name, parameters));
  }

  @override
  Future<void> logScreenView({
    required String screenName,
    String? screenClass,
  }) async {}

  @override
  Future<void> setCollectionEnabled(bool enabled) async {}

  @override
  Future<void> setUserId(String? userId) async {}
}
