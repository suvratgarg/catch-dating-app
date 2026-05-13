import 'package:catch_dating_app/runs/data/run_participation_repository.dart';
import 'package:catch_dating_app/runs/domain/run_participation.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RunParticipationRepository', () {
    late FakeFirebaseFirestore firestore;
    late RunParticipationRepository repository;

    setUp(() {
      firestore = FakeFirebaseFirestore();
      repository = RunParticipationRepository(firestore);
    });

    test(
      'watchParticipationsForRun emits only roster-visible statuses',
      () async {
        await _seedParticipation(
          firestore,
          runId: 'run-1',
          uid: 'runner-1',
          status: 'signedUp',
        );
        await _seedParticipation(
          firestore,
          runId: 'run-1',
          uid: 'runner-2',
          status: 'waitlisted',
        );
        await _seedParticipation(
          firestore,
          runId: 'run-1',
          uid: 'runner-3',
          status: 'attended',
        );
        await _seedParticipation(
          firestore,
          runId: 'run-1',
          uid: 'runner-4',
          status: 'cancelled',
        );
        await _seedParticipation(
          firestore,
          runId: 'run-1',
          uid: 'runner-5',
          status: 'deleted',
        );

        await expectLater(
          repository.watchParticipationsForRun(runId: 'run-1'),
          emits(
            allOf(
              hasLength(3),
              everyElement(
                isA<RunParticipation>().having(
                  (participation) => participation.status,
                  'status',
                  isIn({
                    RunParticipationStatus.signedUp,
                    RunParticipationStatus.waitlisted,
                    RunParticipationStatus.attended,
                  }),
                ),
              ),
            ),
          ),
        );
      },
    );

    test(
      'fetchParticipationsForRun returns only roster-visible statuses',
      () async {
        await _seedParticipation(
          firestore,
          runId: 'run-1',
          uid: 'runner-1',
          status: 'signedUp',
        );
        await _seedParticipation(
          firestore,
          runId: 'run-1',
          uid: 'runner-2',
          status: 'cancelled',
        );
        await _seedParticipation(
          firestore,
          runId: 'run-2',
          uid: 'runner-3',
          status: 'signedUp',
        );

        final participations = await repository.fetchParticipationsForRun(
          runId: 'run-1',
        );

        expect(participations, hasLength(1));
        expect(participations.single.uid, 'runner-1');
        expect(participations.single.status, RunParticipationStatus.signedUp);
      },
    );
  });
}

Future<void> _seedParticipation(
  FakeFirebaseFirestore firestore, {
  required String runId,
  required String uid,
  required String status,
}) async {
  final now = DateTime(2026, 5, 1, 10);
  await firestore
      .collection('runParticipations')
      .doc(runParticipationId(runId: runId, uid: uid))
      .set({
        'runId': runId,
        'runClubId': 'club-1',
        'uid': uid,
        'status': status,
        'createdAt': now,
        'updatedAt': now,
        'signedUpAt': status == 'signedUp' || status == 'attended' ? now : null,
        'waitlistedAt': status == 'waitlisted' ? now : null,
        'attendedAt': status == 'attended' ? now : null,
        'cancelledAt': status == 'cancelled' ? now : null,
        'deletedAt': status == 'deleted' ? now : null,
        'genderAtSignup': 'woman',
        'paymentId': null,
      });
}
