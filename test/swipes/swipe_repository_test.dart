import 'package:catch_dating_app/swipes/data/swipe_repository.dart';
import 'package:catch_dating_app/swipes/domain/swipe.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SwipeRepository', () {
    test(
      'recordSwipe writes optional reaction fields for section likes',
      () async {
        final firestore = FakeFirebaseFirestore();
        final repository = SwipeRepository(firestore);

        await repository.recordSwipe(
          swipe: Swipe(
            swiperId: 'runner-1',
            targetId: 'runner-2',
            runId: 'run-1',
            direction: SwipeDirection.like,
            reactionTargetId: 'profile-prompt-perfectRun',
            reactionTargetType: SwipeReactionTargetType.profilePrompt,
            reactionTargetLabel: 'A perfect run with me looks like...',
            reactionTargetPreview: 'Always up for a sunrise run.',
            comment: '  Same here.  ',
            createdAt: DateTime(2026, 5, 14),
          ),
        );

        final doc = await firestore
            .collection('swipes')
            .doc('runner-1')
            .collection('outgoing')
            .doc('runner-2')
            .get();
        final data = doc.data();

        expect(data?['swiperId'], 'runner-1');
        expect(data?['targetId'], 'runner-2');
        expect(data?['direction'], 'like');
        expect(data?['reactionTargetId'], 'profile-prompt-perfectRun');
        expect(data?['reactionTargetType'], 'profilePrompt');
        expect(
          data?['reactionTargetLabel'],
          'A perfect run with me looks like...',
        );
        expect(data?['reactionTargetPreview'], 'Always up for a sunrise run.');
        expect(data?['comment'], 'Same here.');
      },
    );

    test('recordSwipe omits reaction fields for plain passes', () async {
      final firestore = FakeFirebaseFirestore();
      final repository = SwipeRepository(firestore);

      await repository.recordSwipe(
        swipe: Swipe(
          swiperId: 'runner-1',
          targetId: 'runner-2',
          runId: 'run-1',
          direction: SwipeDirection.pass,
          createdAt: DateTime(2026, 5, 14),
        ),
      );

      final doc = await firestore
          .collection('swipes')
          .doc('runner-1')
          .collection('outgoing')
          .doc('runner-2')
          .get();
      final data = doc.data();

      expect(data?['direction'], 'pass');
      expect(data?.containsKey('reactionTargetId'), isFalse);
      expect(data?.containsKey('comment'), isFalse);
    });
  });
}
