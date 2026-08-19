part of 'onboarding_widgets_test.dart';

void _registerWelcomePageTests() {
  group('WelcomePage', () {
    testWidgets('reel phrase bank matches strings.json', (tester) async {
      final strings =
          jsonDecode(_welcomeStringsSource().readAsStringSync())
              as Map<String, dynamic>;
      final phrases = (strings['phrases'] as List<Object?>)
          .cast<Map<String, dynamic>>();
      final objects = [
        for (final phrase in phrases) '${phrase['object'] as String}.',
      ];
      final runtimePhrases = welcomePhraseBank;

      expect(strings['landingIndex'], welcomeLandingIndex);
      expect(runtimePhrases, hasLength(phrases.length));
      for (final entry in phrases.indexed) {
        final source = entry.$2;
        final runtime = runtimePhrases[entry.$1];
        final sourceActivity = _welcomeActivityKind(
          source['activity'] as String,
        );
        final sourcePigment = _colorFromHex(source['pigment'] as String);

        expect(runtime.object, source['object']);
        expect(runtime.activityKind, sourceActivity);
        expect(ActivityPalette.pigments[runtime.activityKind], sourcePigment);
      }

      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: SizedBox(
            width: 320,
            height: 540,
            child: ReelBand(spinValue: 0, landingValue: 0, landed: false),
          ),
        ),
      );

      final rendered = tester
          .widgetList<RichText>(find.byType(RichText))
          .map((widget) => widget.text.toPlainText())
          .toList();

      expect(objects.last, 'someone real.');
      expect(objects[welcomeLandingIndex], 'the sunset 5K.');
      expect(rendered, [...objects, ...objects]);
    });

    testWidgets('shows the landed welcome page with CTA', (tester) async {
      final reporter = _FakeAnalyticsReporter();
      final container = createOnboardingTestContainer(
        appAnalytics: AppAnalytics(reporter: reporter, shouldCollect: true),
      );
      addTearDown(container.dispose);

      await pumpOnboardingPage(
        tester,
        container: container,
        child: const WelcomePage(playIntro: false),
      );

      expect(
        find.widgetWithText(CatchButton, 'See what\'s on'),
        findsOneWidget,
      );
      expect(
        find.widgetWithText(CatchButton, 'Continue with phone'),
        findsOneWidget,
      );
      expect(find.text('Catch the sunset 5K.'), findsOneWidget);
      expect(find.text('RUN CLUB DATING'), findsNothing);
      expect(find.text('Love arrives\nat mile\nthree.'), findsNothing);
      expect(find.byType(TextButton), findsNothing);
      expect(find.text('Already a runner? Sign in'), findsNothing);
      expect(reporter.events, hasLength(1));
      expect(reporter.events.single.name, AnalyticsEvents.welcomeSplashShown);
      expect(
        reporter.events.single.parameters,
        containsPair(AnalyticsParameters.splashMotion, 'direct'),
      );
    });

    testWidgets('reduced motion renders landed state immediately', (
      tester,
    ) async {
      final reporter = _FakeAnalyticsReporter();
      final container = createOnboardingTestContainer(
        appAnalytics: AppAnalytics(reporter: reporter, shouldCollect: true),
      );
      addTearDown(container.dispose);

      await pumpOnboardingPage(
        tester,
        container: container,
        child: const MediaQuery(
          data: MediaQueryData(disableAnimations: true),
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
        containsPair(AnalyticsParameters.splashMotion, 'reduced_motion'),
      );
    });

    testWidgets('tap skips the reel into the welcome CTAs', (tester) async {
      final reporter = _FakeAnalyticsReporter();
      final container = createOnboardingTestContainer(
        appAnalytics: AppAnalytics(reporter: reporter, shouldCollect: true),
      );
      addTearDown(container.dispose);

      await pumpOnboardingPage(
        tester,
        container: container,
        child: const WelcomePage(),
      );

      expect(
        find.widgetWithText(CatchButton, 'Continue with phone'),
        findsNothing,
      );

      await tester.tap(find.byKey(WelcomePage.splashTapTargetKey));
      await tester.pump(CatchMotion.welcomeLandingReveal);
      await tester.pump();

      expect(
        find.widgetWithText(CatchButton, 'Continue with phone'),
        findsOneWidget,
      );
      expect(
        find.widgetWithText(CatchButton, 'See what\'s on'),
        findsOneWidget,
      );
      expect(
        reporter.events.map((event) => event.name),
        containsAllInOrder([
          AnalyticsEvents.welcomeSplashShown,
          AnalyticsEvents.welcomeSplashSkipped,
        ]),
      );
    });

    testWidgets('see whats on routes through the named Explore route', (
      tester,
    ) async {
      final reporter = _FakeAnalyticsReporter();
      final container = createOnboardingTestContainer(
        appAnalytics: AppAnalytics(reporter: reporter, shouldCollect: true),
      );
      addTearDown(container.dispose);
      final router = GoRouter(
        initialLocation: app_router.Routes.startScreen.path,
        routes: [
          GoRoute(
            path: app_router.Routes.startScreen.path,
            builder: (_, _) => const WelcomePage(playIntro: false),
          ),
          GoRoute(
            path: app_router.Routes.exploreScreen.path,
            name: app_router.Routes.exploreScreen.name,
            builder: (_, _) => const Scaffold(body: Text('Explore route')),
          ),
        ],
      );
      addTearDown(router.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(
            theme: AppTheme.light,
            routerConfig: router,
          ),
        ),
      );
      await pumpOnboardingUi(tester);

      await tester.tap(find.widgetWithText(CatchButton, 'See what\'s on'));
      await tester.pump();
      await tester.pump();

      expect(router.routeInformationProvider.value.uri.path, '/organizers');
      expect(find.text('Explore route'), findsOneWidget);
      expect(
        reporter.events.map((event) => event.name),
        contains(AnalyticsEvents.welcomeCtaTapped),
      );
    });
  });
}
