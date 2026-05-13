import 'package:catch_dating_app/runs/data/saved_run_repository.dart';
import 'package:catch_dating_app/runs/domain/run.dart';
import 'package:catch_dating_app/runs/domain/saved_run.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

import 'runs_test_helpers.dart';

void main() {
  group('SavedRunRepository', () {
    late FakeFirebaseFirestore firestore;
    late SavedRunRepository repository;

    setUp(() {
      firestore = FakeFirebaseFirestore();
      repository = SavedRunRepository(firestore);
    });

    test('saveRun writes only the saved-run edge document', () async {
      await repository.saveRun(uid: 'runner-1', runId: 'run-1');

      final edge = await firestore
          .collection('savedRuns')
          .doc(savedRunId(uid: 'runner-1', runId: 'run-1'))
          .get();
      final user = await firestore.collection('users').doc('runner-1').get();

      expect(edge.data(), containsPair('uid', 'runner-1'));
      expect(edge.data(), containsPair('runId', 'run-1'));
      expect(edge.data(), contains('savedAt'));
      expect(user.exists, isFalse);
    });

    test('unsaveRun deletes only the saved-run edge document', () async {
      final id = savedRunId(uid: 'runner-1', runId: 'run-1');
      await firestore.collection('savedRuns').doc(id).set({
        'uid': 'runner-1',
        'runId': 'run-1',
        'savedAt': DateTime(2026, 1, 1),
      });

      await repository.unsaveRun(uid: 'runner-1', runId: 'run-1');

      final edge = await firestore.collection('savedRuns').doc(id).get();
      final user = await firestore.collection('users').doc('runner-1').get();

      expect(edge.exists, isFalse);
      expect(user.exists, isFalse);
    });

    test(
      'watchSavedRun emits null when the saved-run edge is absent',
      () async {
        await expectLater(
          repository.watchSavedRun(uid: 'runner-1', runId: 'run-1'),
          emits(isNull),
        );
      },
    );

    test('watchSavedRun emits the matching saved-run edge', () async {
      final id = savedRunId(uid: 'runner-1', runId: 'run-1');
      await firestore.collection('savedRuns').doc(id).set({
        'uid': 'runner-1',
        'runId': 'run-1',
        'savedAt': DateTime(2026, 1, 1),
      });

      await expectLater(
        repository.watchSavedRun(uid: 'runner-1', runId: 'run-1'),
        emits(
          isA<SavedRun>()
              .having((savedRun) => savedRun.id, 'id', id)
              .having((savedRun) => savedRun.uid, 'uid', 'runner-1')
              .having((savedRun) => savedRun.runId, 'runId', 'run-1'),
        ),
      );
    });

    test(
      'watchSavedRunDetailsForUser streams saved run documents in time order',
      () async {
        final later = buildRun(
          id: 'run-later',
          startTime: DateTime(2026, 1, 3, 7),
        );
        final earlier = buildRun(
          id: 'run-earlier',
          startTime: DateTime(2026, 1, 2, 7),
        );
        await firestore.collection('runs').doc(later.id).set(later.toJson());
        await firestore
            .collection('runs')
            .doc(earlier.id)
            .set(earlier.toJson());
        await firestore
            .collection('savedRuns')
            .doc(savedRunId(uid: 'runner-1', runId: later.id))
            .set({
              'uid': 'runner-1',
              'runId': later.id,
              'savedAt': DateTime(2026, 1, 1),
            });
        await firestore
            .collection('savedRuns')
            .doc(savedRunId(uid: 'runner-1', runId: earlier.id))
            .set({
              'uid': 'runner-1',
              'runId': earlier.id,
              'savedAt': DateTime(2026, 1, 1),
            });
        await firestore
            .collection('savedRuns')
            .doc(savedRunId(uid: 'runner-1', runId: 'deleted-run'))
            .set({
              'uid': 'runner-1',
              'runId': 'deleted-run',
              'savedAt': DateTime(2026, 1, 1),
            });

        await expectLater(
          repository.watchSavedRunDetailsForUser(uid: 'runner-1'),
          emits([
            isA<Run>().having((run) => run.id, 'id', earlier.id),
            isA<Run>().having((run) => run.id, 'id', later.id),
          ]),
        );
      },
    );
  });
}
