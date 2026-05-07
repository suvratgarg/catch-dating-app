import 'package:catch_dating_app/public_profile/data/public_profile_repository.dart';
import 'package:catch_dating_app/runs/data/run_participation_repository.dart';
import 'package:catch_dating_app/runs/data/run_repository.dart';
import 'package:catch_dating_app/runs/domain/run_participation.dart';
import 'package:catch_dating_app/runs/presentation/attendance_sheet_screen.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_pump_helpers.dart';
import 'runs_test_helpers.dart';

void main() {
  testWidgets('shows an empty state when no runners have signed up', (
    tester,
  ) async {
    final run = buildRun(bookedCount: 1);

    await pumpRunsTestApp(
      tester,
      AttendanceSheetScreen(runClubId: run.runClubId, runId: run.id),
      overrides: [
        watchRunProvider(run.id).overrideWith((ref) => Stream.value(run)),
        watchRunParticipationsForRunProvider(
          run.id,
        ).overrideWith((ref) => Stream.value(const [])),
      ],
    );
    await _settleAttendanceSheet(tester);

    expect(find.text('No runners yet'), findsOneWidget);
    expect(find.text('No one has signed up for this run yet.'), findsOneWidget);
  });

  testWidgets('renders attendee profiles and toggles attendance', (
    tester,
  ) async {
    final run = buildRun(id: 'attendance-run');
    final fakeRunRepository = FakeRunRepository();
    final fakePublicProfileRepository = FakePublicProfileRepository()
      ..profiles = [
        buildPublicProfile(uid: 'runner-1', name: 'Asha'),
        buildPublicProfile(uid: 'runner-2', name: 'Kabir'),
      ];

    await pumpRunsTestApp(
      tester,
      AttendanceSheetScreen(runClubId: run.runClubId, runId: run.id),
      overrides: [
        watchRunProvider(run.id).overrideWith((ref) => Stream.value(run)),
        watchRunParticipationsForRunProvider(run.id).overrideWith(
          (ref) => Stream.value([
            buildRunParticipation(
              run: run,
              uid: 'runner-1',
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
              status: RunParticipationStatus.waitlisted,
              createdAt: DateTime(2026, 5, 6, 7, 3),
            ),
          ]),
        ),
        runRepositoryProvider.overrideWith((ref) => fakeRunRepository),
        publicProfileRepositoryProvider.overrideWith(
          (ref) => fakePublicProfileRepository,
        ),
      ],
      signedInUid: 'host-1',
    );
    await _settleAttendanceSheet(tester);

    expect(fakePublicProfileRepository.lastRequestedUids, [
      'runner-1',
      'runner-2',
    ]);
    expect(find.text('1 / 2 checked in'), findsOneWidget);
    expect(find.text('Asha'), findsOneWidget);
    expect(find.text('Kabir'), findsOneWidget);
    expect(find.text('ABSENT'), findsOneWidget);
    expect(find.text('CHECKED IN'), findsOneWidget);

    await tester.tap(find.text('Asha'));
    await tester.pump();

    expect(fakeRunRepository.markedAttendanceRunId, 'attendance-run');
    expect(fakeRunRepository.markedAttendanceUserId, 'runner-1');
  });
}

Future<void> _settleAttendanceSheet(WidgetTester tester) =>
    pumpFeatureUi(tester);
