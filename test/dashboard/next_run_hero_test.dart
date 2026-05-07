import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/dashboard/presentation/widgets/next_run_hero.dart';
import 'package:catch_dating_app/runs/domain/run.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('NextRunHero uses a native dark-mode surface', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: NextRunHero(nextRun: _run()),
          ),
        ),
      ),
    );

    final surface = tester.widget<CatchSurface>(
      find.byKey(NextRunHero.cardKey),
    );

    expect(surface.backgroundColor, CatchTokens.sunsetDark.surface);
    expect(surface.borderColor, CatchTokens.sunsetDark.line2);
    expect(find.textContaining('NEXT RUN'), findsOneWidget);
    expect(find.text('Thursday Morning Run'), findsOneWidget);
    expect(find.text('1 runner confirmed'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

Run _run() {
  final start = DateTime(2026, 5, 7, 6);
  return Run(
    id: 'next-run',
    runClubId: 'club-1',
    startTime: start,
    endTime: start.add(const Duration(hours: 1)),
    meetingPoint: 'Neighbourhood park gate',
    distanceKm: 5,
    pace: PaceLevel.easy,
    capacityLimit: 20,
    description: 'Easy neighbourhood loop.',
    priceInPaise: 0,
    bookedCount: 1,
  );
}
