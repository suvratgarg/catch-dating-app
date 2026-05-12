import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/core/widgets/person_avatar.dart';
import 'package:catch_dating_app/dashboard/presentation/widgets/next_run_hero.dart';
import 'package:catch_dating_app/runs/domain/run.dart';
import 'package:catch_dating_app/runs/presentation/widgets/run_hype_avatar_stack.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

const _pageSettlingFrame = Duration(seconds: 1);

void main() {
  testWidgets('NextRunHero uses a native dark-mode surface', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          runHypeAvatarsProvider(
            const RunHypeAvatarQuery(
              runId: 'next-run',
              viewerInterestedInGenders: [Gender.woman],
            ),
          ).overrideWith(
            (ref) async => const [
              PersonAvatarItem(
                name: 'Asha',
                imageUrl: 'https://thumb.test/a.jpg',
              ),
            ],
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.dark,
          home: Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: NextRunHero(
                nextRun: _run(),
                viewerInterestedInGenders: const [Gender.woman],
              ),
            ),
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

  testWidgets('UpcomingRunsHero pages through booked upcoming runs', (
    tester,
  ) async {
    final firstRun = _run(id: 'first', start: DateTime(2026, 5, 10, 6));
    final secondRun = _run(id: 'second', start: DateTime(2026, 5, 11, 18));
    Run? tappedRun;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          for (final run in [firstRun, secondRun])
            runHypeAvatarsProvider(
              RunHypeAvatarQuery(
                runId: run.id,
                viewerInterestedInGenders: const [Gender.woman],
              ),
            ).overrideWith(
              (ref) async => [
                PersonAvatarItem(
                  name: run.id,
                  imageUrl: 'https://thumb.test/${run.id}.jpg',
                ),
              ],
            ),
        ],
        child: MaterialApp(
          theme: AppTheme.dark,
          home: Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: UpcomingRunsHero(
                runs: [firstRun, secondRun],
                viewerInterestedInGenders: const [Gender.woman],
                onRunTap: (run) => tappedRun = run,
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Sunday Morning Run'), findsOneWidget);
    expect(find.text('1/2'), findsOneWidget);

    await tester.drag(find.byType(PageView), const Offset(-500, 0));
    await tester.pump();
    await tester.pump(_pageSettlingFrame);

    expect(find.text('Monday Evening Run'), findsOneWidget);
    expect(find.text('2/2'), findsOneWidget);

    await tester.tap(find.text('Monday Evening Run'));
    expect(tappedRun?.id, 'second');
  });

  testWidgets('UpcomingRunsHero uses bounded progress for many booked runs', (
    tester,
  ) async {
    final runs = [
      for (var i = 0; i < 36; i++)
        _run(id: 'run-$i', start: DateTime(2026, 5, 13 + i, 18)),
    ];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          for (final run in runs)
            runHypeAvatarsProvider(
              RunHypeAvatarQuery(
                runId: run.id,
                viewerInterestedInGenders: const [Gender.woman],
              ),
            ).overrideWith(
              (ref) async => [
                PersonAvatarItem(
                  name: run.id,
                  imageUrl: 'https://thumb.test/${run.id}.jpg',
                ),
              ],
            ),
        ],
        child: MaterialApp(
          theme: AppTheme.dark,
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 390,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: UpcomingRunsHero(
                    runs: runs,
                    viewerInterestedInGenders: const [Gender.woman],
                    onRunTap: (_) {},
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('1/36'), findsOneWidget);
    expect(tester.takeException(), isNull);

    final progressSize = tester.getSize(
      find.byKey(UpcomingRunsHero.progressIndicatorKey),
    );
    expect(progressSize.width, lessThanOrEqualTo(132));

    await tester.drag(find.byType(PageView), const Offset(-500, 0));
    await tester.pump();
    await tester.pump(_pageSettlingFrame);

    expect(find.text('2/36'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

Run _run({String id = 'next-run', DateTime? start}) {
  start ??= DateTime(2026, 5, 7, 6);
  return Run(
    id: id,
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
