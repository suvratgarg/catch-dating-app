import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final progress in [0.0, 1.0]) {
    testWidgets(
      'fade-scale endpoint $progress preserves the route transition',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: CatchFadeScaleViewport(
              animation: AlwaysStoppedAnimation(progress),
              child: const Text('Route content'),
            ),
          ),
        );
        final viewport = find.byType(CatchFadeScaleViewport);
        final fade = tester.widget<FadeTransition>(
          find.descendant(of: viewport, matching: find.byType(FadeTransition)),
        );
        final scale = tester.widget<ScaleTransition>(
          find.descendant(of: viewport, matching: find.byType(ScaleTransition)),
        );
        expect(fade.opacity.value, progress);
        expect(scale.scale.value, progress == 0 ? 0.985 : 1);
      },
    );
  }

  testWidgets('ticket viewport preserves the shared flight tag and material', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: CatchTicketHeroViewport(
          prefix: 'event',
          id: 'one',
          child: Text('Ticket'),
        ),
      ),
    );
    final hero = tester.widget<Hero>(find.byType(Hero));
    expect(hero.tag, 'event-ticket-hero-one');
    expect(hero.transitionOnUserGestures, isTrue);
    expect(hero.flightShuttleBuilder, isNotNull);
    expect((hero.child as Material).type, MaterialType.transparency);
  });

  testWidgets(
    'map reveal preserves content and removes its veil for reduced motion',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: CatchTheme.light,
          home: const MediaQuery(
            data: MediaQueryData(disableAnimations: true),
            child: CatchMapRevealViewport(
              animation: AlwaysStoppedAnimation(0.0),
              child: Text('Map content'),
            ),
          ),
        ),
      );
      expect(find.text('Map content'), findsOneWidget);
      expect(find.byKey(const ValueKey('catch_map_reveal.veil')), findsNothing);
    },
  );
}
