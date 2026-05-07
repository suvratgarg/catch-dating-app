import 'package:catch_dating_app/runs/data/saved_run_repository.dart';
import 'package:catch_dating_app/runs/domain/saved_run.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

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
  });
}
