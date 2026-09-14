import 'package:catch_dating_app/activity/domain/activity_taxonomy.dart';
import 'package:catch_dating_app/event_success/domain/event_success_plan.dart';
import 'package:catch_dating_app/events/presentation/event_detail_display_state.dart';
import 'package:catch_dating_app/events/presentation/event_detail_information_state.dart';
import 'package:catch_dating_app/events/presentation/widgets/booking_conflict_sheet.dart';
import 'package:catch_dating_app/events/presentation/widgets/event_detail_body.dart';
import 'package:catch_dating_app/events/presentation/widgets/event_detail_cta.dart';
import 'package:catch_dating_app/events/shared/event_detail_route_transition.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../../preview_layout_contracts.dart';
import '../../support/contract_preview.dart';
import '../../support/page_preview.dart';
import '../../support/widgetbook_harness.dart';
import 'event_scope.dart';
import 'fixtures.dart';
import 'preview.dart';

@widgetbook.UseCase(
  name: 'BookingDock states',
  type: EventBookingDock,
  path: '[Event Detail]/Sections',
)
Widget eventDetailBookingDockStates(BuildContext context) {
  final t = CatchTokens.of(context);
  return WidgetbookEventCatalogFrame(
    title: 'EventBookingDock',
    catalogId: 'section.event.booking_dock',
    children: [
      WidgetbookPageStateCard(
        label: 'guest',
        child: const WidgetbookEventDockFrame(
          child: EventBookingDock(
            label: 'Sign in to book this event',
            onPressed: widgetbookNoop,
          ),
        ),
      ),
      WidgetbookPageStateCard(
        label: 'bookable with price',
        child: WidgetbookEventDockFrame(
          child: EventBookingDock(
            label: 'Book event',
            onPressed: widgetbookNoop,
            leadingContent: const PriceLeading(
              price: '₹1,400',
              note: '2 spots left',
              warn: true,
            ),
            buttonAccentColor: t.primary,
            catchLine: 'Matching opens for everyone who goes',
            catchLineAccent: t.primary,
          ),
        ),
      ),
      WidgetbookPageStateCard(
        label: 'pending',
        child: WidgetbookEventDockFrame(
          child: EventBookingDock(
            label: 'Join event - 3 spots left',
            onPressed: null,
            isLoading: true,
            buttonAccentColor: t.primary,
          ),
        ),
      ),
      WidgetbookPageStateCard(
        label: 'failed mutation',
        child: WidgetbookEventDockFrame(
          child: EventBookingDock(
            label: 'Join event - 3 spots left',
            onPressed: widgetbookNoop,
            errorMessage: 'Unable to book this event right now.',
            buttonAccentColor: t.primary,
          ),
        ),
      ),
      WidgetbookPageStateCard(
        label: 'booked',
        child: WidgetbookEventDockFrame(
          child: EventBookingDock(
            label: 'Cancel booking',
            onPressed: widgetbookNoop,
            leadingContent: EventCtaStatusLeading(
              icon: CatchIcons.checkCircleRounded,
              label: "You're in!",
            ),
          ),
        ),
      ),
      WidgetbookPageStateCard(
        label: 'waitlist',
        child: const WidgetbookEventDockFrame(
          child: EventBookingDock(
            label: 'Join waitlist',
            onPressed: widgetbookNoop,
          ),
        ),
      ),
      WidgetbookPageStateCard(
        label: 'waitlist offer',
        child: WidgetbookEventDockFrame(
          child: EventBookingDock(
            label: 'Accept spot',
            onPressed: widgetbookNoop,
            leadingContent: WaitlistOfferLeading(
              expiresAt: widgetbookEventsNow.add(const Duration(hours: 5)),
              isDeclining: false,
              onDecline: widgetbookNoop,
            ),
          ),
        ),
      ),
      WidgetbookPageStateCard(
        label: 'full / cancelled / past / attended',
        child: Column(
          children: [
            const WidgetbookEventDockFrame(
              child: EventBookingDock(
                label: 'Spots for your gender are full',
                onPressed: null,
              ),
            ),
            gapH12,
            const WidgetbookEventDockFrame(
              child: EventBookingDock(
                label: 'This event has ended',
                onPressed: null,
              ),
            ),
            gapH12,
            WidgetbookEventDockFrame(
              child: EventBookingDock(
                label: 'You attended this event',
                onPressed: null,
                leadingContent: EventCtaStatusLeading(
                  icon: CatchIcons.directionsRunRounded,
                  label: 'Completed',
                ),
              ),
            ),
          ],
        ),
      ),
      WidgetbookPageStateCard(
        label: 'host hidden',
        child: const WidgetbookEventHiddenSectionState(
          message: 'No booking dock is composed in host app context.',
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Booking conflict sheet states',
  type: BookingConflictSheet,
  path: '[Event Detail]/Sheets',
)
Widget eventDetailBookingConflictSheetStates(BuildContext context) {
  return WidgetbookEventCatalogFrame(
    title: 'BookingConflictSheet',
    catalogId: 'sheet.event.booking_conflict',
    children: [
      WidgetbookPageStateCard(
        label: 'default conflict',
        child: const _SheetFrame(
          child: BookingConflictSheet(
            existing: BookingConflictEvent(
              title: 'Sunday Sea Face Crew',
              when: 'Wed, Jun 24 · 6:30 AM-8:15 AM',
              activityKind: ActivityKind.socialRun,
            ),
            incoming: BookingConflictEvent(
              title: 'Kala Ghoda Coffee Walk',
              when: 'Wed, Jun 24 · 6:45 AM-8:00 AM',
              activityKind: ActivityKind.walking,
            ),
            onReplaceExisting: widgetbookNoop,
            onKeepBoth: widgetbookNoop,
            onKeepExisting: widgetbookNoop,
          ),
        ),
      ),
      WidgetbookPageStateCard(
        label: 'replacement decision',
        child: const _SheetFrame(
          child: BookingConflictSheet(
            existing: BookingConflictEvent(
              title: 'Neighborhood Easy Run',
              when: 'Fri, Jun 26 · 7:00 PM-8:30 PM',
              activityKind: ActivityKind.socialRun,
            ),
            incoming: BookingConflictEvent(
              title: 'Founder-hosted Singles Dinner',
              when: 'Fri, Jun 26 · 7:15 PM-9:30 PM',
              activityKind: ActivityKind.dinner,
            ),
            onReplaceExisting: widgetbookNoop,
            onKeepBoth: widgetbookNoop,
            onKeepExisting: widgetbookNoop,
          ),
        ),
      ),
      WidgetbookPageStateCard(
        label: 'long event names',
        child: const _SheetFrame(
          child: BookingConflictSheet(
            existing: BookingConflictEvent(
              title:
                  'South Mumbai Golden Hour Social Run with Coffee and First-timer Intros',
              when: 'Sat, Jun 27 · 6:00 AM-8:45 AM · Carter Road to Bandstand',
              activityKind: ActivityKind.socialRun,
            ),
            incoming: BookingConflictEvent(
              title:
                  'Bandra Pub Quiz Mixer for People Who Always Say One More Round',
              when: 'Sat, Jun 27 · 6:15 AM-9:00 AM · Pali Hill Studio',
              activityKind: ActivityKind.pubQuiz,
            ),
            onReplaceExisting: widgetbookNoop,
            onKeepBoth: widgetbookNoop,
            onKeepExisting: widgetbookNoop,
          ),
        ),
      ),
      WidgetbookPageStateCard(
        label: 'fallback activity visuals',
        child: const _SheetFrame(
          child: BookingConflictSheet(
            existing: BookingConflictEvent(
              title: 'Saved event without activity metadata',
              when: 'Sun, Jun 28 · 5:00 PM-6:30 PM',
            ),
            incoming: BookingConflictEvent(
              title: 'Pickleball Doubles Mixer',
              when: 'Sun, Jun 28 · 5:15 PM-7:00 PM',
              activityKind: ActivityKind.pickleball,
            ),
            onReplaceExisting: widgetbookNoop,
            onKeepBoth: widgetbookNoop,
            onKeepExisting: widgetbookNoop,
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Booking conflict event row states',
  type: BookingConflictEventRow,
  path: '[Event Detail]/Sheets',
)
Widget eventDetailBookingConflictEventRowStates(BuildContext context) {
  final t = CatchTokens.of(context);

  return WidgetbookEventCatalogFrame(
    title: 'BookingConflictEventRow',
    catalogId: 'row.event.booking_conflict',
    children: [
      WidgetbookPageStateCard(
        label: 'activity visual',
        child: BookingConflictEventRow(
          tag: 'New',
          tagColor: t.warning,
          event: const BookingConflictEvent(
            title: 'Founder-hosted Singles Dinner',
            when: 'Fri, Jun 26 · 7:15 PM-9:30 PM',
            activityKind: ActivityKind.dinner,
          ),
        ),
      ),
      WidgetbookPageStateCard(
        label: 'fallback visual',
        child: BookingConflictEventRow(
          tag: 'Already booked',
          tagColor: t.ink3,
          event: const BookingConflictEvent(
            title: 'Saved event without activity metadata',
            when: 'Sun, Jun 28 · 5:00 PM-6:30 PM',
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Prompt states',
  type: EventDetailBody,
  path: '[Event Detail]/Sections',
)
Widget eventDetailPromptBodyStates(BuildContext context) {
  return WidgetbookEventCatalogFrame(
    title: 'EventDetailBody prompts',
    catalogId: 'section.event.companion_invite',
    children: [
      WidgetbookPageStateCard(
        label: 'hidden',
        child: WidgetbookEventDeviceFrame(
          child: WidgetbookEventScope(
            event: widgetbookEvent,
            plan: null,
            child: EventDetailBody(
              event: widgetbookEvent,
              userProfile: widgetbookEventsViewer,
              clubId: widgetbookEventsClubId,
              reviews: const [],
              isAuthenticated: true,
              sectionVisibility: eventDetailSectionVisibilityStateFrom(
                event: widgetbookEvent,
                participation: null,
                isHostApp: false,
                isHost: false,
                now: widgetbookEventsNow,
              ),
              isSaved: false,
              participation: null,
              savePending: false,
              onBack: widgetbookNoop,
              onShare: widgetbookEventsNoopContext,
              showAddToCalendar: false,
              onAddToCalendar: widgetbookEventsNoopContext,
              onToggleSaved: widgetbookNoop,
              companionState: const EventDetailCompanionState.hidden(),
              hostState: const EventDetailHostState.hidden(),
              socialState: eventDetailSocialStateFrom(
                event: widgetbookEvent,
                hasReviews: false,
                userProfile: widgetbookEventsViewer,
                isAuthenticated: true,
                renderAsHost: false,
                participation: null,
                now: widgetbookEventsNow,
              ),
              informationState: eventDetailInformationStateFrom(
                event: widgetbookEvent,
                l10n: context.l10n,
              ),
              onLocationTap: null,
              onOpenCompanion: widgetbookNoop,
              onRetryCompanion: widgetbookNoop,
              onViewClub: widgetbookIgnoreString,
              onMessageHost: widgetbookEventsNoopMessageHost,
              onRetryHosts: widgetbookNoop,
              now: widgetbookEventsNow,
              enableMapNetworkTiles: false,
            ),
          ),
        ),
      ),
      WidgetbookPageStateCard(
        label: 'companion available',
        child: WidgetbookEventDeviceFrame(
          child: WidgetbookEventScope(
            event: widgetbookEvent,
            plan: EventSuccessPlan.defaultForEvent(
              widgetbookEvent,
              now: widgetbookEventsNow,
            ),
            child: EventDetailBody(
              event: widgetbookEvent,
              userProfile: widgetbookEventsViewer,
              clubId: widgetbookEventsClubId,
              reviews: widgetbookEventsReviews,
              isAuthenticated: true,
              sectionVisibility: eventDetailSectionVisibilityStateFrom(
                event: widgetbookEvent,
                participation: widgetbookEventsSignedUp,
                isHostApp: false,
                isHost: false,
                now: widgetbookEventsNow,
              ),
              isSaved: true,
              participation: widgetbookEventsSignedUp,
              savePending: false,
              onBack: widgetbookNoop,
              onShare: widgetbookEventsNoopContext,
              showAddToCalendar: false,
              onAddToCalendar: widgetbookEventsNoopContext,
              onToggleSaved: widgetbookNoop,
              companionState: const EventDetailCompanionState.available(),
              hostState: const EventDetailHostState.hidden(),
              socialState: eventDetailSocialStateFrom(
                event: widgetbookEvent,
                hasReviews: widgetbookEventsReviews.isNotEmpty,
                userProfile: widgetbookEventsViewer,
                isAuthenticated: true,
                renderAsHost: false,
                participation: widgetbookEventsSignedUp,
                now: widgetbookEventsNow,
              ),
              informationState: eventDetailInformationStateFrom(
                event: widgetbookEvent,
                l10n: context.l10n,
              ),
              onLocationTap: null,
              onOpenCompanion: widgetbookNoop,
              onRetryCompanion: widgetbookNoop,
              onViewClub: widgetbookIgnoreString,
              onMessageHost: widgetbookEventsNoopMessageHost,
              onRetryHosts: widgetbookNoop,
              now: widgetbookEventsNow,
              enableMapNetworkTiles: false,
            ),
          ),
        ),
      ),
      WidgetbookPageStateCard(
        label: 'invite loop available',
        child: WidgetbookEventDeviceFrame(
          child: WidgetbookEventScope(
            event: widgetbookEvent,
            plan: null,
            child: EventDetailBody(
              event: widgetbookEvent,
              userProfile: widgetbookEventsViewer,
              clubId: widgetbookEventsClubId,
              reviews: widgetbookEventsReviews,
              isAuthenticated: true,
              sectionVisibility: eventDetailSectionVisibilityStateFrom(
                event: widgetbookEvent,
                participation: widgetbookEventsSignedUp,
                isHostApp: false,
                isHost: false,
                now: widgetbookEventsNow,
              ),
              isSaved: true,
              participation: widgetbookEventsSignedUp,
              savePending: false,
              onBack: widgetbookNoop,
              onShare: widgetbookEventsNoopContext,
              showAddToCalendar: false,
              onAddToCalendar: widgetbookEventsNoopContext,
              onToggleSaved: widgetbookNoop,
              companionState: const EventDetailCompanionState.hidden(),
              hostState: const EventDetailHostState.hidden(),
              socialState: eventDetailSocialStateFrom(
                event: widgetbookEvent,
                hasReviews: widgetbookEventsReviews.isNotEmpty,
                userProfile: widgetbookEventsViewer,
                isAuthenticated: true,
                renderAsHost: false,
                participation: widgetbookEventsSignedUp,
                now: widgetbookEventsNow,
              ),
              informationState: eventDetailInformationStateFrom(
                event: widgetbookEvent,
                l10n: context.l10n,
              ),
              onLocationTap: null,
              onOpenCompanion: widgetbookNoop,
              onRetryCompanion: widgetbookNoop,
              onViewClub: widgetbookIgnoreString,
              onMessageHost: widgetbookEventsNoopMessageHost,
              onRetryHosts: widgetbookNoop,
              now: widgetbookEventsNow,
              presentationMode: EventDetailPresentationMode.ticket,
              enableMapNetworkTiles: false,
            ),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Price leading',
  type: PriceLeading,
  path: '[Event Detail]/Booking Dock',
)
Widget priceLeadingState(BuildContext context) {
  return const PriceLeading(price: '₹1,400', note: '2 spots left', warn: true);
}

@widgetbook.UseCase(
  name: 'Waitlist offer leading',
  type: WaitlistOfferLeading,
  path: '[Event Detail]/Booking Dock',
)
Widget waitlistOfferLeadingState(BuildContext context) {
  return WaitlistOfferLeading(
    expiresAt: widgetbookEventsNow.add(const Duration(hours: 5)),
    isDeclining: false,
    onDecline: widgetbookNoop,
  );
}

@widgetbook.UseCase(
  name: 'Status leading states',
  type: EventCtaStatusLeading,
  path: '[Event Detail]/Booking Dock',
)
Widget eventCtaStatusLeadingStates(BuildContext context) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      EventCtaStatusLeading(
        icon: CatchIcons.checkCircleRounded,
        label: "You're in!",
      ),
      gapH12,
      EventCtaStatusLeading(
        icon: CatchIcons.directionsRunRounded,
        label: 'Completed',
      ),
    ],
  );
}

class _SheetFrame extends StatelessWidget {
  const _SheetFrame({required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) =>
      WidgetbookViewportFrame.constrainedSheet(
        size: const Size(
          390,
          WidgetbookPreviewLayout.profileExpandedEditorHeight,
        ),
        child: child,
      );
}
