import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/cross_paths/data/cross_paths_repository.dart';
import 'package:catch_dating_app/cross_paths/domain/cross_paths_invitation.dart';
import 'package:catch_dating_app/cross_paths/domain/cross_paths_suggestion.dart';
import 'package:catch_dating_app/cross_paths/presentation/cross_paths_invitation_screen.dart';
import 'package:catch_dating_app/events/data/event_repository.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/l10n/generated/app_localizations.dart';
import 'package:catch_dating_app/public_profile/data/public_profile_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../events/events_test_helpers.dart' as event_test;

void main() {
  testWidgets('recipient sees accept and decline actions', (tester) async {
    final fixture = _fixture();

    await _pumpInvitation(tester, fixture.invitation, fixture);
    await tester.scrollUntilVisible(find.text('Accept and make a plan'), 180);

    expect(find.text('Cross Paths invitation'), findsOneWidget);
    expect(find.text('Rhea Kapoor, 29'), findsOneWidget);
    expect(find.text('Accept and make a plan'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Decline'), 120);
    expect(find.text('Decline'), findsOneWidget);
  });

  testWidgets('accepted invitation exposes its event plan actions', (
    tester,
  ) async {
    final fixture = _fixture(status: CrossPathsInvitationStatus.accepted);

    await _pumpInvitation(tester, fixture.invitation, fixture);
    await tester.scrollUntilVisible(find.text('Open event plan'), 180);

    expect(find.text('Open event plan'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Cancel event plan'), 120);
    expect(find.text('Cancel event plan'), findsOneWidget);
    expect(find.text('Accept and make a plan'), findsNothing);
  });
}

Future<void> _pumpInvitation(
  WidgetTester tester,
  CrossPathsInvitation invitation,
  _InvitationFixture fixture,
) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        uidProvider.overrideWith((ref) => Stream.value('viewer-1')),
        watchCrossPathsInvitationProvider(
          invitation.id,
        ).overrideWith((ref) => Stream.value(invitation)),
        watchPublicProfileProvider(
          fixture.suggestion.profile.uid,
        ).overrideWith((ref) => Stream.value(fixture.suggestion.profile)),
        watchEventProvider(
          fixture.event.id,
        ).overrideWith((ref) => Stream.value(fixture.event)),
      ],
      child: MaterialApp(
        theme: AppTheme.light,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: CrossPathsInvitationScreen(invitationId: invitation.id),
      ),
    ),
  );
  await tester.pump();
  await tester.pump();
  await tester.pump();
  await tester.pump();
}

_InvitationFixture _fixture({
  CrossPathsInvitationStatus status = CrossPathsInvitationStatus.pending,
}) {
  final event = event_test.buildEvent(
    meetingPoint: 'Kala Ghoda table room',
    startTime: DateTime(2026, 8, 8, 18),
  );
  final parsedSuggestion = CrossPathsSuggestion.fromCallableData({
    'person': {
      'uid': 'candidate-1',
      'name': 'Rhea Kapoor',
      'age': 29,
      'gender': 'woman',
      'city': 'in-mh-mumbai',
      'photoUrls': const [
        'https://example.com/one.jpg',
        'https://example.com/two.jpg',
        'https://example.com/three.jpg',
      ],
      'promptAnswers': const [
        {'prompt': 'A perfect event', 'answer': 'A sunset walk'},
        {'prompt': 'Typical Sunday', 'answer': 'Coffee and a long read'},
        {'prompt': 'Together we could', 'answer': 'Try every new place'},
      ],
      'relationshipGoal': 'relationship',
    },
    'event': {
      'eventId': event.id,
      'organizerId': event.organizerId,
      'startTime': event.startTime.toUtc().toIso8601String(),
      'endTime': event.endTime.toUtc().toIso8601String(),
      'meetingPoint': event.meetingPoint,
      'activityKind': event.activityKind.name,
      'photoUrl': null,
      'viewerBookingStatus': 'signedUp',
    },
    'reasonCodes': const [
      'attending_event',
      'viewer_attending',
      'mutual_preferences',
      'showcase_ready',
    ],
    'suggestionToken': 'tttttttttttttttttttttttttttttttttttttttt.token',
    'tokenExpiresAt': '2026-08-08T17:00:00.000Z',
  });
  final suggestion = CrossPathsSuggestion(
    profile: parsedSuggestion.profile.copyWith(profilePhotos: const []),
    event: parsedSuggestion.event,
    reasonCodes: parsedSuggestion.reasonCodes,
    suggestionToken: parsedSuggestion.suggestionToken,
    tokenExpiresAt: parsedSuggestion.tokenExpiresAt,
    rankingVersion: parsedSuggestion.rankingVersion,
  );
  final now = DateTime(2026, 8, 5, 12);
  final invitation = CrossPathsInvitation(
    id: 'invitation-1',
    eventId: event.id,
    senderUid: suggestion.profile.uid,
    recipientUid: 'viewer-1',
    participantIds: const ['candidate-1', 'viewer-1'],
    status: status,
    createdAt: now,
    updatedAt: now,
    expiresAt: now.add(const Duration(days: 1)),
    respondedAt: status == CrossPathsInvitationStatus.accepted ? now : null,
    cancelledAt: null,
    invalidatedAt: null,
    invalidationReason: null,
    conversationId: status == CrossPathsInvitationStatus.accepted
        ? 'plan-1'
        : null,
  );
  return _InvitationFixture(
    invitation: invitation,
    suggestion: suggestion,
    event: event,
  );
}

class _InvitationFixture {
  const _InvitationFixture({
    required this.invitation,
    required this.suggestion,
    required this.event,
  });

  final CrossPathsInvitation invitation;
  final CrossPathsSuggestion suggestion;
  final Event event;
}
