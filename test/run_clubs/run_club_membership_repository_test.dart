import 'package:catch_dating_app/run_clubs/data/run_club_membership_repository.dart';
import 'package:catch_dating_app/run_clubs/domain/run_club_membership.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RunClubMembershipRepository', () {
    late FakeFirebaseFirestore firestore;
    late RunClubMembershipRepository repository;

    setUp(() {
      firestore = FakeFirebaseFirestore();
      repository = RunClubMembershipRepository(firestore);
    });

    test('watchMembership emits null when the edge is absent', () async {
      await expectLater(
        repository.watchMembership(clubId: 'club-1', uid: 'runner-1'),
        emits(isNull),
      );
    });

    test('watchMembership emits the matching membership edge', () async {
      final id = runClubMembershipId(clubId: 'club-1', uid: 'runner-1');
      await firestore.collection('runClubMemberships').doc(id).set({
        'clubId': 'club-1',
        'uid': 'runner-1',
        'role': RunClubMembershipRole.member.name,
        'status': RunClubMembershipStatus.active.name,
        'joinedAt': DateTime(2026, 1, 1),
        'leftAt': null,
      });

      await expectLater(
        repository.watchMembership(clubId: 'club-1', uid: 'runner-1'),
        emits(
          isA<RunClubMembership>()
              .having((membership) => membership.id, 'id', id)
              .having((membership) => membership.clubId, 'clubId', 'club-1')
              .having((membership) => membership.uid, 'uid', 'runner-1'),
        ),
      );
    });
  });
}
