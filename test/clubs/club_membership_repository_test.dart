import 'package:catch_dating_app/clubs/data/club_membership_repository.dart';
import 'package:catch_dating_app/clubs/domain/club_membership.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ClubMembershipRepository', () {
    late FakeFirebaseFirestore firestore;
    late ClubMembershipRepository repository;

    setUp(() {
      firestore = FakeFirebaseFirestore();
      repository = ClubMembershipRepository(firestore);
    });

    test('watchMembership emits null when the edge is absent', () async {
      await expectLater(
        repository.watchMembership(clubId: 'club-1', uid: 'runner-1'),
        emits(isNull),
      );
    });

    test('watchMembership emits the matching membership edge', () async {
      final id = clubMembershipId(clubId: 'club-1', uid: 'runner-1');
      await firestore.collection('clubMemberships').doc(id).set({
        'clubId': 'club-1',
        'uid': 'runner-1',
        'role': ClubMembershipRole.member.name,
        'status': ClubMembershipStatus.active.name,
        'joinedAt': DateTime(2026, 1, 1),
        'leftAt': null,
      });

      await expectLater(
        repository.watchMembership(clubId: 'club-1', uid: 'runner-1'),
        emits(
          isA<ClubMembership>()
              .having((membership) => membership.id, 'id', id)
              .having((membership) => membership.clubId, 'clubId', 'club-1')
              .having((membership) => membership.uid, 'uid', 'runner-1'),
        ),
      );
    });
  });
}
