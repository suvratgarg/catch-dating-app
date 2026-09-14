import 'package:catch_dating_app/cross_paths/cross_paths.dart';

import 'fixtures.dart';

final widgetbookExploreCrossPathsSuggestion =
    CrossPathsSuggestion.fromCallableData({
      'person': {
        'uid': 'widgetbook-cross-paths-rhea',
        'name': 'Rhea Kapoor',
        'age': 29,
        'gender': 'woman',
        'city': 'in-mh-mumbai',
        'photoUrls': const [
          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=1200',
          'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=1200',
          'https://images.unsplash.com/photo-1531123897727-8f129e1688ce?w=1200',
        ],
        'promptAnswers': const [
          {
            'prompt': 'A perfect event',
            'answer': 'A sunset walk and good chai',
          },
          {
            'prompt': 'Typical Sunday',
            'answer': 'Coffee, a long read, then dinner',
          },
          {
            'prompt': 'Together we could',
            'answer': 'Try every new place in town',
          },
        ],
        'relationshipGoal': 'relationship',
      },
      'event': {
        'eventId': 'widgetbook-long-table-dinner',
        'organizerId': 'widgetbook-long-table-club',
        'startTime': '2026-06-24T14:30:00.000Z',
        'endTime': '2026-06-24T16:30:00.000Z',
        'meetingPoint': 'Kala Ghoda table room',
        'activityKind': 'dinner',
        'photoUrl': null,
        'viewerBookingStatus': 'canBookNow',
      },
      'reasonCodes': const [
        'attending_event',
        'booking_available',
        'mutual_preferences',
        'showcase_ready',
      ],
      'suggestionToken':
          'widgetbook-token-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx',
      'tokenExpiresAt': '2027-06-24T14:20:00.000Z',
    });

CrossPathsInvitation widgetbookExploreCrossPathsInvitation({
  required String id,
  required CrossPathsInvitationStatus status,
  String? conversationId,
  bool outgoing = false,
  CrossPathsInvitationInvalidationReason? invalidationReason,
  String? pairHoldId,
}) {
  return CrossPathsInvitation(
    id: id,
    eventId: widgetbookExploreFeedItems[1].event.id,
    senderUid: outgoing
        ? widgetbookExploreViewerUid
        : widgetbookExploreCrossPathsSuggestion.profile.uid,
    recipientUid: outgoing
        ? widgetbookExploreCrossPathsSuggestion.profile.uid
        : widgetbookExploreViewerUid,
    participantIds: [
      widgetbookExploreViewerUid,
      widgetbookExploreCrossPathsSuggestion.profile.uid,
    ],
    status: status,
    createdAt: widgetbookExploreNow,
    updatedAt: widgetbookExploreNow,
    expiresAt: widgetbookExploreNow.add(const Duration(hours: 24)),
    respondedAt: status == CrossPathsInvitationStatus.accepted
        ? widgetbookExploreNow
        : null,
    cancelledAt: null,
    invalidatedAt: null,
    invalidationReason: invalidationReason,
    conversationId: conversationId,
    pairHoldId: pairHoldId,
  );
}
