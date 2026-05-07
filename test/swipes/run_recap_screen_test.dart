import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/public_profile/data/public_profile_repository.dart';
import 'package:catch_dating_app/runs/data/run_participation_repository.dart';
import 'package:catch_dating_app/runs/data/run_repository.dart';
import 'package:catch_dating_app/runs/domain/run_participation.dart';
import 'package:catch_dating_app/swipes/presentation/run_recap_screen.dart';
import 'package:catch_dating_app/swipes/presentation/swipe_keys.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../runs/runs_test_helpers.dart';
import '../test_pump_helpers.dart';

void main() {
  testWidgets('RunRecapScreen builds roster from participation edges', (
    tester,
  ) async {
    final endedAt = DateTime.now().subtract(const Duration(hours: 3));
    final run = buildRun(
      id: 'recap-run',
      startTime: endedAt.subtract(const Duration(hours: 1)),
      endTime: endedAt,
      checkedInCount: 1,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          uidProvider.overrideWith((ref) => Stream.value('runner-1')),
          watchRunProvider(run.id).overrideWith((ref) => Stream.value(run)),
          watchRunParticipationsForRunProvider(run.id).overrideWith(
            (ref) => Stream.value([
              buildRunParticipation(
                run: run,
                uid: 'runner-1',
                status: RunParticipationStatus.attended,
                createdAt: DateTime(2026, 5, 6, 7, 1),
              ),
              buildRunParticipation(
                run: run,
                uid: 'runner-2',
                status: RunParticipationStatus.attended,
                createdAt: DateTime(2026, 5, 6, 7, 2),
              ),
              buildRunParticipation(
                run: run,
                uid: 'runner-3',
                status: RunParticipationStatus.attended,
                createdAt: DateTime(2026, 5, 6, 7, 3),
              ),
              buildRunParticipation(
                run: run,
                uid: 'runner-4',
                status: RunParticipationStatus.signedUp,
                createdAt: DateTime(2026, 5, 6, 7, 4),
              ),
            ]),
          ),
          watchPublicProfileProvider('runner-2').overrideWith(
            (ref) => Stream.value(buildPublicProfile(uid: 'runner-2')),
          ),
          watchPublicProfileProvider('runner-3').overrideWith(
            (ref) => Stream.value(buildPublicProfile(uid: 'runner-3')),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: RunRecapScreen(runId: run.id),
        ),
      ),
    );
    await pumpFeatureUi(tester);

    expect(find.text('Easy pace · 3 checked in'), findsOneWidget);
    expect(find.byKey(SwipeKeys.vibeTile('runner-2')), findsOneWidget);
    expect(find.byKey(SwipeKeys.vibeTile('runner-3')), findsOneWidget);
    expect(find.byKey(SwipeKeys.vibeTile('runner-1')), findsNothing);
    expect(find.byKey(SwipeKeys.vibeTile('runner-4')), findsNothing);
  });
}
