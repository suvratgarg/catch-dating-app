import 'package:catch_dating_app/cross_paths/cross_paths.dart';
import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../../support/contract_preview.dart';
import '../../support/page_preview.dart';
import 'cross_paths_fixtures.dart';
import 'fixtures.dart';
import 'preview.dart';
import 'scope.dart';

final _bookedCrossPathsSuggestion = CrossPathsSuggestion(
  profile: widgetbookExploreCrossPathsSuggestion.profile,
  event: CrossPathsSuggestionEvent(
    eventId: widgetbookExploreCrossPathsSuggestion.event.eventId,
    organizerId: widgetbookExploreCrossPathsSuggestion.event.organizerId,
    startTime: widgetbookExploreCrossPathsSuggestion.event.startTime,
    endTime: widgetbookExploreCrossPathsSuggestion.event.endTime,
    meetingPoint: widgetbookExploreCrossPathsSuggestion.event.meetingPoint,
    activityKind: widgetbookExploreCrossPathsSuggestion.event.activityKind,
    photoUrl: widgetbookExploreCrossPathsSuggestion.event.photoUrl,
    viewerBookingStatus: CrossPathsViewerBookingStatus.signedUp,
  ),
  reasonCodes: widgetbookExploreCrossPathsSuggestion.reasonCodes,
  suggestionToken: widgetbookExploreCrossPathsSuggestion.suggestionToken,
  tokenExpiresAt: widgetbookExploreCrossPathsSuggestion.tokenExpiresAt,
  rankingVersion: widgetbookExploreCrossPathsSuggestion.rankingVersion,
);

final _pairAvailableCrossPathsSuggestion = CrossPathsSuggestion(
  profile: widgetbookExploreCrossPathsSuggestion.profile,
  event: CrossPathsSuggestionEvent(
    eventId: widgetbookExploreCrossPathsSuggestion.event.eventId,
    organizerId: widgetbookExploreCrossPathsSuggestion.event.organizerId,
    startTime: widgetbookExploreCrossPathsSuggestion.event.startTime,
    endTime: widgetbookExploreCrossPathsSuggestion.event.endTime,
    meetingPoint: widgetbookExploreCrossPathsSuggestion.event.meetingPoint,
    activityKind: widgetbookExploreCrossPathsSuggestion.event.activityKind,
    photoUrl: widgetbookExploreCrossPathsSuggestion.event.photoUrl,
    viewerBookingStatus: CrossPathsViewerBookingStatus.canBookNow,
    pairHoldAvailable: true,
  ),
  reasonCodes: widgetbookExploreCrossPathsSuggestion.reasonCodes,
  suggestionToken: widgetbookExploreCrossPathsSuggestion.suggestionToken,
  tokenExpiresAt: widgetbookExploreCrossPathsSuggestion.tokenExpiresAt,
  rankingVersion: widgetbookExploreCrossPathsSuggestion.rankingVersion,
);

@widgetbook.UseCase(
  name: 'Cross Paths person card',
  type: CrossPathsExploreCard,
  path: '[Explore]/Sections',
)
Widget crossPathsExploreCardStates(BuildContext context) {
  return WidgetbookScrollCatalogFrame(
    title: 'CrossPathsExploreCard',
    catalogId: 'card.person.cross_paths',
    children: [
      WidgetbookPageStateCard(
        label: 'bookable event',
        description:
            'Person Polaroid with separate, prospective event context and action.',
        child: WidgetbookExploreDeviceFrame(
          child: SingleChildScrollView(
            padding: CatchInsets.pageBody,
            child: CrossPathsExploreCard(
              suggestion: widgetbookExploreCrossPathsSuggestion,
              event: widgetbookExploreFeedItems[1].event,
              onProfileSelected: widgetbookNoop,
              onEventSelected: widgetbookNoop,
            ),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Cross Paths event context',
  type: CrossPathsEventContextCard,
  path: '[Explore]/Sections',
)
Widget crossPathsEventContextStates(BuildContext context) {
  return WidgetbookScrollCatalogFrame(
    title: 'CrossPathsEventContextCard',
    catalogId: 'card.event.cross_paths_context',
    children: [
      WidgetbookPageStateCard(
        label: 'bookable associated event',
        child: WidgetbookExploreDeviceFrame(
          child: Padding(
            padding: CatchInsets.pageBody,
            child: CrossPathsEventContextCard(
              suggestion: widgetbookExploreCrossPathsSuggestion,
              event: widgetbookExploreFeedItems[1].event,
              onEventSelected: widgetbookNoop,
            ),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Cross Paths profile preview',
  type: CrossPathsProfilePreviewSheet,
  path: '[Explore]/Sections',
)
Widget crossPathsProfilePreviewStates(BuildContext context) {
  final pending = widgetbookExploreCrossPathsInvitation(
    id: 'widgetbook-profile-preview-pending',
    status: CrossPathsInvitationStatus.pending,
    outgoing: true,
  );
  final accepted = widgetbookExploreCrossPathsInvitation(
    id: 'widgetbook-profile-preview-accepted',
    status: CrossPathsInvitationStatus.accepted,
    outgoing: true,
    conversationId: 'widgetbook-profile-preview-plan',
  );
  return WidgetbookScrollCatalogFrame(
    title: 'CrossPathsProfilePreviewSheet',
    catalogId: 'overlay.person.cross_paths_profile',
    children: [
      WidgetbookPageStateCard(
        label: 'book first',
        child: WidgetbookExploreDeviceFrame(
          child: WidgetbookExploreScope(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: CrossPathsProfilePreviewSheet(
                suggestion: widgetbookExploreCrossPathsSuggestion,
                event: widgetbookExploreFeedItems[1].event,
                onEventSelected: widgetbookNoop,
              ),
            ),
          ),
        ),
      ),
      WidgetbookPageStateCard(
        label: 'booked and invitation ready',
        child: WidgetbookExploreDeviceFrame(
          child: WidgetbookExploreScope(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: CrossPathsProfilePreviewSheet(
                suggestion: _bookedCrossPathsSuggestion,
                event: widgetbookExploreFeedItems[1].event,
                onEventSelected: widgetbookNoop,
              ),
            ),
          ),
        ),
      ),
      WidgetbookPageStateCard(
        label: 'pair spot available before booking',
        child: WidgetbookExploreDeviceFrame(
          child: WidgetbookExploreScope(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: CrossPathsProfilePreviewSheet(
                suggestion: _pairAvailableCrossPathsSuggestion,
                event: widgetbookExploreFeedItems[1].event,
                onEventSelected: widgetbookNoop,
              ),
            ),
          ),
        ),
      ),
      WidgetbookPageStateCard(
        label: 'invitation pending',
        child: WidgetbookExploreDeviceFrame(
          child: WidgetbookExploreScope(
            outgoingInvitation: pending,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: CrossPathsProfilePreviewSheet(
                suggestion: _bookedCrossPathsSuggestion,
                event: widgetbookExploreFeedItems[1].event,
                onEventSelected: widgetbookNoop,
              ),
            ),
          ),
        ),
      ),
      WidgetbookPageStateCard(
        label: 'event plan ready',
        child: WidgetbookExploreDeviceFrame(
          child: WidgetbookExploreScope(
            outgoingInvitation: accepted,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: CrossPathsProfilePreviewSheet(
                suggestion: _bookedCrossPathsSuggestion,
                event: widgetbookExploreFeedItems[1].event,
                onEventSelected: widgetbookNoop,
                onPlanSelected: (_) {},
              ),
            ),
          ),
        ),
      ),
    ],
  );
}
