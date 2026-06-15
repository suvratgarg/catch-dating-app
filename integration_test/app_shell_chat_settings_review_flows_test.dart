import 'package:catch_dating_app/matches/domain/match.dart';
import 'package:catch_dating_app/reviews/presentation/review_keys.dart';
import 'package:catch_dating_app/safety/data/safety_repository.dart';
import 'package:catch_dating_app/safety/presentation/settings_keys.dart';
import 'package:flutter/material.dart' show TextButton, TextField;
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../test/clubs/clubs_test_helpers.dart' as club_helpers;
import '../test/events/events_test_helpers.dart' as event_helpers;
import '../test/support/profile_readiness_fixtures.dart';
import '../test/test_pump_helpers.dart';
import 'support/app_shell_test_harness.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('matches list opens chat and resets unread state', (
    tester,
  ) async {
    final user = buildSocialReadyUser(name: 'Suvrat Garg');
    final match = Match(
      id: 'match-1',
      user1Id: user.uid,
      user2Id: 'runner-2',
      eventIds: const ['run-1'],
      createdAt: DateTime(2026, 4, 23, 9),
      lastMessageAt: DateTime(2026, 4, 23, 10),
      lastMessagePreview: 'See you at the event',
      lastMessageSenderId: 'runner-2',
      unreadCounts: const {'runner-1': 1},
    );
    final profile = event_helpers.buildPublicProfile(
      uid: 'runner-2',
      name: 'Taylor',
    );
    final conversationRepository = FakeShellConversationRepository();
    final safetyRepository = FakeShellSafetyRepository();

    await pumpCatchAppShell(
      tester,
      overrides: appShellTestOverrides(
        uid: user.uid,
        user: user,
        matches: [match],
        publicProfiles: [profile],
        conversationRepository: conversationRepository,
        safetyRepository: safetyRepository,
      ),
    );

    await openAppTab(tester, 'Chats');
    expect(find.text('Taylor'), findsOneWidget);
    expect(find.text('See you at the event'), findsOneWidget);

    await tester.tap(find.text('Taylor'));
    await pumpFeatureUi(tester);

    expect(find.text('Say hi to Taylor!'), findsOneWidget);
    expect(
      conversationRepository.markReadCalls,
      contains(('match-1', user.uid)),
    );

    await tester.enterText(find.byType(TextField), '  See you there  ');
    await tester.tap(find.byTooltip('Send message'));
    await flushTestEventQueue();
    await pumpFeatureUi(tester);

    expect(
      conversationRepository.sentTextMessages,
      contains(
        SentTextMessage(
          conversationId: match.id,
          senderId: user.uid,
          text: 'See you there',
        ),
      ),
    );

    await tester.tap(find.byTooltip('Chat actions'));
    await pumpFeatureUi(tester);
    await tester.tap(find.text('Report'));
    await flushTestEventQueue();
    await pumpFeatureUi(tester);

    expect(safetyRepository.reportedUserId, profile.uid);
    expect(safetyRepository.reportContextId, match.id);
    expect(find.text('Report submitted for Taylor.'), findsOneWidget);

    await tester.tap(find.byTooltip('Chat actions'));
    await pumpFeatureUi(tester);
    await tester.tap(find.text('Block'));
    await pumpFeatureUi(tester);
    await tester.tap(find.widgetWithText(TextButton, 'Block'));
    await flushTestEventQueue();
    await pumpFeatureUi(tester);

    expect(safetyRepository.blockedUserId, profile.uid);
  });

  testWidgets('settings opens payment history from profile', (tester) async {
    final user = buildSocialReadyUser(name: 'Suvrat Garg');

    await pumpCatchAppShell(
      tester,
      overrides: appShellTestOverrides(uid: user.uid, user: user),
    );

    await openAppTab(tester, 'Profile');
    await tester.tap(find.byTooltip('Settings'));
    await pumpFeatureUi(tester);

    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Account'), findsOneWidget);
    expect(find.byKey(SettingsKeys.paymentHistoryRow), findsOneWidget);

    await tester.tap(find.byKey(SettingsKeys.paymentHistoryRow));
    await pumpFeatureUi(tester);
    expect(find.text('Payment history'), findsOneWidget);
    expect(find.text('No payments yet'), findsOneWidget);
  });

  testWidgets('settings opens review history from profile', (tester) async {
    final user = buildSocialReadyUser(name: 'Suvrat Garg');

    await pumpCatchAppShell(
      tester,
      overrides: appShellTestOverrides(uid: user.uid, user: user),
    );

    await openAppTab(tester, 'Profile');
    await tester.tap(find.byTooltip('Settings'));
    await pumpFeatureUi(tester);

    await tester.tap(find.byKey(SettingsKeys.reviewHistoryRow));
    await pumpFeatureUi(tester);
    expect(find.text('Review history'), findsOneWidget);
    expect(find.text('No reviews yet'), findsOneWidget);
  });

  testWidgets('attended event detail submits a review', (tester) async {
    final user = buildSocialReadyUser(name: 'Suvrat Garg');
    final club = club_helpers.buildClub();
    final run = event_helpers.buildEvent(
      id: 'review-run-1',
      clubId: club.id,
      startTime: DateTime.now().subtract(const Duration(hours: 2)),
      endTime: DateTime.now().subtract(const Duration(hours: 1)),
      meetingPoint: 'Carter Road Amphitheatre',
      bookedCount: 1,
    );
    final reviewsRepository = FakeShellReviewsRepository();

    await pumpCatchAppShell(
      tester,
      overrides: appShellTestOverrides(
        uid: user.uid,
        user: user,
        clubs: [club],
        joinedClubIds: {club.id},
        clubEvents: {
          club.id: [run],
        },
        attendedEvents: [run],
        reviewsRepository: reviewsRepository,
      ),
    );

    await openAppTab(tester, 'Explore');
    await openClubDetail(tester, club);
    await pumpFeatureUi(tester);
    await openEventDetail(tester, club: club, event: run);
    await tester.scrollUntilVisible(
      find.byKey(ReviewKeys.writeReviewButton),
      300,
    );
    await pumpFeatureUi(tester);
    await tester.tap(find.byKey(ReviewKeys.writeReviewButton));
    await pumpFeatureUi(tester);

    await tester.tap(find.byKey(ReviewKeys.ratingStar(4)));
    await tester.enterText(find.byType(TextField), '  Friendly crew.  ');
    await tester.tap(find.byKey(ReviewKeys.submitReviewButton));
    await flushTestEventQueue();
    await pumpMutationUi(tester);

    expect(reviewsRepository.addedReview?.clubId, club.id);
    expect(reviewsRepository.addedReview?.eventId, run.id);
    expect(reviewsRepository.addedReview?.reviewerUserId, user.uid);
    expect(reviewsRepository.addedReview?.reviewerName, user.name);
    expect(reviewsRepository.addedReview?.rating, 4);
    expect(reviewsRepository.addedReview?.comment, 'Friendly crew.');
  });

  testWidgets('review history edits and deletes an existing review', (
    tester,
  ) async {
    final user = buildSocialReadyUser(name: 'Suvrat Garg');
    final run = event_helpers.buildEvent(
      id: 'review-run-1',
      meetingPoint: 'Carter Road Amphitheatre',
    );
    final review = event_helpers.buildReview(
      id: '${run.id}~${user.uid}',
      clubId: run.clubId,
      eventId: run.id,
      reviewerUserId: user.uid,
      reviewerName: user.name,
      rating: 3,
      comment: 'Good route.',
    );
    final reviewsRepository = FakeShellReviewsRepository(
      reviewsByUser: [review],
    );

    await pumpCatchAppShell(
      tester,
      overrides: appShellTestOverrides(
        uid: user.uid,
        user: user,
        signedUpEvents: [run],
        reviewsByUser: [review],
        reviewsRepository: reviewsRepository,
      ),
    );

    await openAppTab(tester, 'Profile');
    await tester.tap(find.byTooltip('Settings'));
    await pumpFeatureUi(tester);
    await tester.tap(find.byKey(SettingsKeys.reviewHistoryRow));
    await pumpFeatureUi(tester);

    expect(find.text('Good route.'), findsOneWidget);

    await tester.tap(find.byKey(ReviewKeys.editReviewButton(review.id)));
    await pumpFeatureUi(tester);
    await tester.enterText(find.byType(TextField), '  Even better now.  ');
    await tester.tap(find.byKey(ReviewKeys.ratingStar(5)));
    await tester.tap(find.byKey(ReviewKeys.submitReviewButton));
    await flushTestEventQueue();
    await pumpFeatureUi(tester);

    expect(reviewsRepository.updatedReview?.id, review.id);
    expect(reviewsRepository.updatedReview?.rating, 5);
    expect(reviewsRepository.updatedReview?.comment, 'Even better now.');

    await tester.tap(find.byKey(ReviewKeys.editReviewButton(review.id)));
    await pumpFeatureUi(tester);
    await tester.tap(find.byKey(ReviewKeys.deleteReviewButton));
    await pumpFeatureUi(tester);
    await tester.tap(find.widgetWithText(TextButton, 'Delete'));
    await flushTestEventQueue();
    await pumpFeatureUi(tester);

    expect(reviewsRepository.deletedReviewId, review.id);
  });

  testWidgets('settings signs out through auth controller', (tester) async {
    final user = buildSocialReadyUser(name: 'Suvrat Garg');
    final authRepository = FakeShellAuthRepository();

    await pumpCatchAppShell(
      tester,
      overrides: appShellTestOverrides(
        uid: user.uid,
        user: user,
        authRepository: authRepository,
      ),
    );

    await openAppTab(tester, 'Profile');
    await tester.tap(find.byTooltip('Settings'));
    await pumpFeatureUi(tester);

    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Account'), findsOneWidget);
    expect(find.byKey(SettingsKeys.signOutRow), findsOneWidget);
    await tester.tap(find.byKey(SettingsKeys.signOutRow));
    await flushTestEventQueue();
    await pumpFeatureUi(tester);

    expect(authRepository.signOutCallCount, 1);
  });

  testWidgets(
    'settings updates notification preferences and unblocks account',
    (tester) async {
      final user = buildSocialReadyUser(
        name: 'Suvrat Garg',
      ).copyWith(prefsWeeklyDigest: false);
      final userProfileRepository = FakeShellUserProfileRepository();
      final safetyRepository = FakeShellSafetyRepository(
        blockedUsers: [
          BlockedUser(
            uid: 'blocked-1',
            source: 'chat',
            createdAt: DateTime(2026, 5),
          ),
        ],
      );
      final blockedProfile = event_helpers.buildPublicProfile(
        uid: 'blocked-1',
        name: 'Riya',
      );

      await pumpCatchAppShell(
        tester,
        overrides: appShellTestOverrides(
          uid: user.uid,
          user: user,
          userProfileRepository: userProfileRepository,
          safetyRepository: safetyRepository,
          publicProfiles: [blockedProfile],
        ),
      );

      await openAppTab(tester, 'Profile');
      await tester.tap(find.byTooltip('Settings'));
      await pumpFeatureUi(tester);
      await tester.scrollUntilVisible(
        find.byKey(SettingsKeys.weeklyDigestSwitch),
        240,
      );
      await pumpFeatureUi(tester);
      await tester.tap(find.byKey(SettingsKeys.weeklyDigestSwitch));
      await flushTestEventQueue();
      await pumpFeatureUi(tester);

      expect(userProfileRepository.updatedUid, user.uid);
      expect(userProfileRepository.updatedFields, {'prefsWeeklyDigest': true});

      await tester.scrollUntilVisible(find.text('Riya'), 240);
      await pumpFeatureUi(tester);
      await tester.tap(find.byKey(SettingsKeys.unblockButton('blocked-1')));
      await flushTestEventQueue();
      await pumpFeatureUi(tester);

      expect(safetyRepository.unblockedUserId, 'blocked-1');
      expect(find.text('Account unblocked.'), findsOneWidget);
    },
  );

  testWidgets('settings requests account deletion after confirmation', (
    tester,
  ) async {
    final user = buildSocialReadyUser(name: 'Suvrat Garg');
    final safetyRepository = FakeShellSafetyRepository();

    await pumpCatchAppShell(
      tester,
      overrides: appShellTestOverrides(
        uid: user.uid,
        user: user,
        safetyRepository: safetyRepository,
      ),
    );

    await openAppTab(tester, 'Profile');
    await tester.tap(find.byTooltip('Settings'));
    await pumpFeatureUi(tester);
    await tester.scrollUntilVisible(
      find.byKey(SettingsKeys.deleteAccountRow),
      320,
    );
    await pumpFeatureUi(tester);
    await tester.tap(find.byKey(SettingsKeys.deleteAccountRow));
    await pumpFeatureUi(tester);

    expect(find.text('Delete account?'), findsOneWidget);

    await tester.tap(find.widgetWithText(TextButton, 'Delete'));
    await flushTestEventQueue();
    await pumpFeatureUi(tester);

    expect(safetyRepository.requestDeletionCallCount, 1);
  });
}
