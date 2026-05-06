import 'package:catch_dating_app/core/celebration/catch_celebration_screen.dart';
import 'package:catch_dating_app/core/celebration/celebration_effects_controller.dart';
import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders celebration content and dispatches effects once', (
    tester,
  ) async {
    final effects = _FakeCelebrationEffectsController();
    var primaryPressed = 0;
    var secondaryPressed = 0;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          celebrationEffectsControllerProvider.overrideWithValue(effects),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: CatchCelebrationScreen(
            kind: CelebrationMomentKind.runJoined,
            eyebrow: 'Booking confirmed',
            title: "You're in.",
            message: 'Your spot is confirmed.',
            details: const [
              CelebrationDetail(label: 'Where', value: 'Carter Road'),
            ],
            primaryAction: CelebrationAction(
              label: 'View run',
              onPressed: () => primaryPressed++,
            ),
            secondaryAction: CelebrationAction(
              label: 'Back to home',
              onPressed: () => secondaryPressed++,
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(effects.playedKinds, [CelebrationMomentKind.runJoined]);
    expect(find.text('BOOKING CONFIRMED'), findsOneWidget);
    expect(find.text("You're in."), findsOneWidget);
    expect(find.text('Your spot is confirmed.'), findsOneWidget);
    expect(find.text('Where'), findsOneWidget);
    expect(find.text('Carter Road'), findsOneWidget);

    await tester.tap(find.text('View run'));
    await tester.pump();
    await tester.tap(find.text('Back to home'));
    await tester.pump();

    expect(primaryPressed, 1);
    expect(secondaryPressed, 1);
    expect(effects.playedKinds, [CelebrationMomentKind.runJoined]);
  });

  testWidgets('can suppress effects for deterministic surfaces', (
    tester,
  ) async {
    final effects = _FakeCelebrationEffectsController();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          celebrationEffectsControllerProvider.overrideWithValue(effects),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: CatchCelebrationScreen(
            kind: CelebrationMomentKind.match,
            title: "It's a Catch.",
            message: 'You both liked each other.',
            playEffects: false,
            primaryAction: CelebrationAction(
              label: 'Continue',
              onPressed: () {},
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(effects.playedKinds, isEmpty);
  });
}

class _FakeCelebrationEffectsController extends CelebrationEffectsController {
  _FakeCelebrationEffectsController();

  final List<CelebrationMomentKind> playedKinds = [];

  @override
  Future<void> play(CelebrationMomentKind kind) async {
    playedKinds.add(kind);
  }
}
