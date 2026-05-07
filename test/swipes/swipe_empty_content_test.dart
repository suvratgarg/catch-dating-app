import 'package:catch_dating_app/runs/domain/run_participation.dart';
import 'package:catch_dating_app/swipes/presentation/swipe_empty_content.dart';
import 'package:flutter_test/flutter_test.dart';

import '../runs/runs_test_helpers.dart';

void main() {
  group('buildSwipeEmptyContent', () {
    test('explains why a run is unavailable when missing', () {
      final content = buildSwipeEmptyContent(
        run: null,
        currentUser: buildUser(uid: 'runner-1'),
        currentUserParticipation: null,
      );

      expect(content.title, 'Catch unavailable');
    });

    test('explains that swiping opens after the run ends', () {
      final run = buildRun();
      final content = buildSwipeEmptyContent(
        run: run,
        currentUser: buildUser(uid: 'runner-1'),
        currentUserParticipation: buildRunParticipation(
          run: run,
          uid: 'runner-1',
          status: RunParticipationStatus.attended,
        ),
      );

      expect(content.title, 'Run in progress');
      expect(
        content.message,
        'Swiping unlocks for 24 hours after the run finishes.',
      );
    });

    test('explains when the user did not attend the run', () {
      final endedAt = DateTime.now().subtract(const Duration(hours: 3));
      final run = buildRun(
        startTime: endedAt.subtract(const Duration(hours: 1)),
        endTime: endedAt,
        checkedInCount: 1,
      );
      final content = buildSwipeEmptyContent(
        run: run,
        currentUser: buildUser(uid: 'runner-1'),
        currentUserParticipation: buildRunParticipation(
          run: run,
          uid: 'runner-1',
          status: RunParticipationStatus.signedUp,
        ),
      );

      expect(content.title, 'Catch unavailable');
      expect(
        content.message,
        'You can only swipe on runners from events you attended.',
      );
    });

    test('explains when the swipe window has closed', () {
      final endedAt = DateTime.now().subtract(const Duration(hours: 26));
      final run = buildRun(
        startTime: endedAt.subtract(const Duration(hours: 1)),
        endTime: endedAt,
      );
      final content = buildSwipeEmptyContent(
        run: run,
        currentUser: buildUser(uid: 'runner-1'),
        currentUserParticipation: buildRunParticipation(
          run: run,
          uid: 'runner-1',
          status: RunParticipationStatus.attended,
        ),
      );

      expect(content.title, 'Swipe window closed');
    });

    test(
      'falls back to the default empty message when the window is active',
      () {
        final endedAt = DateTime.now().subtract(const Duration(hours: 2));
        final run = buildRun(
          startTime: endedAt.subtract(const Duration(hours: 1)),
          endTime: endedAt,
        );
        final content = buildSwipeEmptyContent(
          run: run,
          currentUser: buildUser(uid: 'runner-1'),
          currentUserParticipation: buildRunParticipation(
            run: run,
            uid: 'runner-1',
            status: RunParticipationStatus.attended,
          ),
        );

        expect(content, defaultSwipeEmptyContent);
      },
    );
  });
}
