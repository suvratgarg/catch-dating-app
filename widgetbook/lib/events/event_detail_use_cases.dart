import 'dart:async';

import 'package:catch_dating_app/activity/domain/activity_taxonomy.dart';
import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/clubs/data/clubs_repository.dart';
import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/clubs/data/club_name_lookup.dart';
import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/core/device_location.dart';
import 'package:catch_dating_app/core/media/uploaded_photo.dart';
import 'package:catch_dating_app/core/theme/activity_palette.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_badge.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_empty_state.dart';
import 'package:catch_dating_app/core/widgets/catch_field.dart';
import 'package:catch_dating_app/core/widgets/catch_meta_row.dart';
import 'package:catch_dating_app/core/widgets/catch_person_avatar.dart';
import 'package:catch_dating_app/core/widgets/event_activity_visuals.dart';
import 'package:catch_dating_app/event_policies/domain/event_policy.dart';
import 'package:catch_dating_app/event_success/data/event_success_repository.dart';
import 'package:catch_dating_app/event_success/domain/event_success_plan.dart';
import 'package:catch_dating_app/events/data/event_participation_repository.dart';
import 'package:catch_dating_app/events/data/event_repository.dart';
import 'package:catch_dating_app/events/data/saved_event_repository.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/domain/event_formatters.dart';
import 'package:catch_dating_app/events/domain/event_participation.dart';
import 'package:catch_dating_app/events/domain/event_participation_roster.dart';
import 'package:catch_dating_app/events/presentation/event_check_in_celebration_screen.dart';
import 'package:catch_dating_app/events/presentation/event_joined_celebration_screen.dart';
import 'package:catch_dating_app/events/presentation/event_location_map_screen.dart';
import 'package:catch_dating_app/events/presentation/event_map_screen.dart';
import 'package:catch_dating_app/events/presentation/event_map_view_model.dart';
import 'package:catch_dating_app/events/presentation/event_detail_route_transition.dart';
import 'package:catch_dating_app/events/presentation/event_detail_screen.dart';
import 'package:catch_dating_app/events/presentation/event_detail_view_model.dart';
import 'package:catch_dating_app/events/presentation/location_picker_screen.dart';
import 'package:catch_dating_app/events/presentation/saved_events_screen.dart';
import 'package:catch_dating_app/events/presentation/saved_events_state.dart';
import 'package:catch_dating_app/events/presentation/widgets/event_agenda_list.dart';
import 'package:catch_dating_app/events/presentation/widgets/booking_conflict_sheet.dart';
import 'package:catch_dating_app/events/presentation/widgets/event_detail_body.dart';
import 'package:catch_dating_app/events/presentation/widgets/event_detail_cta.dart';
import 'package:catch_dating_app/events/presentation/widgets/event_detail_design_primitives.dart';
import 'package:catch_dating_app/events/presentation/widgets/event_detail_hero_app_bar.dart';
import 'package:catch_dating_app/events/presentation/widgets/event_detail_optimistic_body.dart';
import 'package:catch_dating_app/events/presentation/widgets/event_detail_overview_section.dart';
import 'package:catch_dating_app/events/presentation/widgets/event_detail_social_section.dart';
import 'package:catch_dating_app/events/presentation/widgets/event_detail_surface_style.dart';
import 'package:catch_dating_app/events/presentation/widgets/event_hype_avatar_stack.dart';
import 'package:catch_dating_app/events/presentation/widgets/event_photo_header.dart';
import 'package:catch_dating_app/events/presentation/widgets/event_pins_map.dart';
import 'package:catch_dating_app/events/presentation/widgets/event_share_card.dart';
import 'package:catch_dating_app/events/presentation/widgets/event_stats_grid.dart';
import 'package:catch_dating_app/events/presentation/widgets/event_tiles/event_action_card.dart';
import 'package:catch_dating_app/events/presentation/widgets/event_tiles/event_agenda_tile.dart';
import 'package:catch_dating_app/events/presentation/widgets/event_tiles/event_compact_row.dart';
import 'package:catch_dating_app/events/presentation/widgets/event_tiles/event_date_marker.dart';
import 'package:catch_dating_app/events/presentation/widgets/event_tiles/event_date_rail_card.dart';
import 'package:catch_dating_app/events/presentation/widgets/event_tiles/event_tile_data.dart';
import 'package:catch_dating_app/core/widgets/event_visual_atoms.dart';
import 'package:catch_dating_app/events/presentation/widgets/map_overlay_controls.dart';
import 'package:catch_dating_app/events/presentation/widgets/map_pin_tile.dart';
import 'package:catch_dating_app/events/presentation/widgets/requirements_row.dart';
import 'package:catch_dating_app/events/presentation/widgets/who_is_going.dart';
import 'package:catch_dating_app/locations/domain/location_coordinate.dart';
import 'package:catch_dating_app/payments/data/payment_repository.dart';
import 'package:catch_dating_app/payments/domain/payment_confirmation_data.dart';
import 'package:catch_dating_app/reviews/data/reviews_repository.dart';
import 'package:catch_dating_app/reviews/domain/review.dart';
import 'package:catch_dating_app/reviews/presentation/reviews_history_screen.dart';
import 'package:catch_dating_app/reviews/presentation/reviews_section.dart';
import 'package:catch_dating_app/user_profile/data/user_profile_repository.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

const _viewerUid = 'widgetbook-event-viewer';
const _clubId = 'widgetbook-event-club';
final _now = DateTime(2026, 6, 22, 9);

final _club = Club(
  id: _clubId,
  name: 'Sunday Sea Face Crew',
  description:
      'A city running crew for easy starts, steady conversation, and a cafe finish.',
  location: 'mumbai',
  area: 'Bandra',
  hostUserId: 'host-mira',
  hostName: 'Mira Shah',
  hostAvatarUrl:
      'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=160&q=80',
  ownerUserId: 'host-mira',
  hostProfiles: const [
    ClubHostProfile(
      uid: 'host-mira',
      displayName: 'Mira Shah',
      role: ClubHostRole.owner,
    ),
  ],
  createdAt: DateTime(2025, 10, 4),
  memberCount: 412,
  rating: 4.9,
  reviewCount: 73,
);

final _event = _eventDetailEvent();
final _pastEvent = _eventDetailEvent(
  id: 'widgetbook-event-detail-past',
  startTime: _now.subtract(const Duration(hours: 18)),
);
final _emptyEvent = _eventDetailEvent(
  id: 'widgetbook-event-detail-empty',
  bookedCount: 0,
  waitlistedCount: 0,
);

final _viewer = UserProfile(
  uid: _viewerUid,
  name: 'Neha Kapoor',
  firstName: 'Neha',
  lastName: 'Kapoor',
  displayName: 'Neha',
  dateOfBirth: DateTime(1996, 4, 12),
  gender: Gender.woman,
  phoneNumber: '+919876543210',
  profileComplete: true,
  city: 'Mumbai',
  interestedInGenders: const [Gender.man],
);

final _signedUp = EventParticipation(
  id: '${_event.id}_$_viewerUid',
  eventId: _event.id,
  clubId: _clubId,
  uid: _viewerUid,
  status: EventParticipationStatus.signedUp,
  createdAt: _now.subtract(const Duration(days: 3)),
  updatedAt: _now.subtract(const Duration(days: 3)),
  signedUpAt: _now.subtract(const Duration(days: 3)),
  genderAtSignup: Gender.woman,
);

final _attended = EventParticipation(
  id: '${_pastEvent.id}_$_viewerUid',
  eventId: _pastEvent.id,
  clubId: _clubId,
  uid: _viewerUid,
  status: EventParticipationStatus.attended,
  createdAt: _now.subtract(const Duration(days: 4)),
  updatedAt: _now.subtract(const Duration(hours: 12)),
  signedUpAt: _now.subtract(const Duration(days: 4)),
  attendedAt: _now.subtract(const Duration(hours: 12)),
  genderAtSignup: Gender.woman,
);

final _hostViewer = _viewer.copyWith(
  uid: 'host-mira',
  name: 'Mira Shah',
  displayName: 'Mira Shah',
  firstName: 'Mira',
  lastName: 'Shah',
);

final _reviews = [
  Review(
    id: 'widgetbook-event-review-1',
    clubId: _clubId,
    eventId: _pastEvent.id,
    reviewerUserId: _viewerUid,
    reviewerName: 'Neha',
    rating: 5,
    comment: 'Easy pace, clear host cues, and a genuinely good post-run table.',
    createdAt: _now.subtract(const Duration(hours: 10)),
  ),
  Review(
    id: 'widgetbook-event-review-2',
    clubId: _clubId,
    eventId: _pastEvent.id,
    reviewerUserId: 'runner-dev',
    reviewerName: 'Dev',
    rating: 5,
    comment: 'The group stayed together without feeling over-managed.',
    createdAt: _now.subtract(const Duration(hours: 8)),
    ownerResponse: ReviewOwnerResponse(
      hostUserId: 'host-mira',
      hostName: 'Mira Shah',
      hostAvatarUrl:
          'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=160&q=80',
      message:
          'Glad that felt balanced. We are keeping the regroup points next week.',
      createdAt: _now.subtract(const Duration(hours: 7)),
      updatedAt: _now.subtract(const Duration(hours: 7)),
    ),
  ),
  Review(
    id: 'widgetbook-event-review-3',
    clubId: _clubId,
    eventId: _pastEvent.id,
    reviewerUserId: 'runner-ana',
    reviewerName: 'Ana',
    rating: 4,
    comment: 'Great route and thoughtful regroup points.',
    createdAt: _now.subtract(const Duration(hours: 7)),
  ),
  Review(
    id: 'widgetbook-event-review-4',
    clubId: _clubId,
    eventId: _pastEvent.id,
    reviewerUserId: 'runner-lee',
    reviewerName: 'Lee',
    rating: 5,
    comment: 'The host made first-timers feel expected.',
    createdAt: _now.subtract(const Duration(hours: 6)),
  ),
];

@widgetbook.UseCase(
  name: 'Screen states',
  type: EventDetailScreen,
  path: '[Event Detail]/Screen states',
)
Widget eventDetailScreenStates(BuildContext context) {
  return _CatalogScreen(
    title: 'EventDetailScreen',
    catalogId: 'screen.event.detail',
    children: [
      _StateCard(
        label: 'loading',
        child: _RouteFrame(
          value: const AsyncLoading<EventDetailViewModel?>(),
          child: EventDetailScreen(clubId: _clubId, eventId: _event.id),
        ),
      ),
      _StateCard(
        label: 'not found',
        child: _RouteFrame(
          value: const AsyncData<EventDetailViewModel?>(null),
          child: EventDetailScreen(clubId: _clubId, eventId: _event.id),
        ),
      ),
      _StateCard(
        label: 'fatal error',
        child: _RouteFrame(
          value: AsyncError<EventDetailViewModel?>(
            StateError('Widgetbook event detail load failed'),
            StackTrace.empty,
          ),
          child: EventDetailScreen(clubId: _clubId, eventId: _event.id),
        ),
      ),
      _StateCard(
        label: 'member default',
        child: _RouteFrame(
          value: AsyncData(_eventVm(_event, participation: _signedUp)),
          child: EventDetailScreen(clubId: _clubId, eventId: _event.id),
        ),
      ),
      _StateCard(
        label: 'guest',
        child: _RouteFrame(
          value: AsyncData(
            _eventVm(_event, isAuthenticated: false, isSaved: false),
          ),
          child: EventDetailScreen(clubId: _clubId, eventId: _event.id),
        ),
      ),
      _StateCard(
        label: 'host app',
        child: _RouteFrame(
          value: AsyncData(
            _eventVm(_event, userProfile: _hostViewer, isHost: true),
          ),
          child: EventDetailScreen(clubId: _clubId, eventId: _event.id),
        ),
      ),
      _StateCard(
        label: 'offline error',
        child: _RouteFrame(
          value: AsyncError<EventDetailViewModel?>(
            StateError('No network connection for Event Detail'),
            StackTrace.empty,
          ),
          child: EventDetailScreen(clubId: _clubId, eventId: _event.id),
        ),
      ),
      _StateCard(
        label: 'ticket presentation',
        child: _RouteFrame(
          value: AsyncData(_eventVm(_event, participation: _signedUp)),
          child: EventDetailScreen(
            clubId: _clubId,
            eventId: _event.id,
            presentationMode: EventDetailPresentationMode.ticket,
          ),
        ),
      ),
      _StateCard(
        label: 'spotlight dark presentation',
        child: _RouteFrame(
          value: AsyncData(_eventVm(_event, participation: _signedUp)),
          child: EventDetailScreen(
            clubId: _clubId,
            eventId: _event.id,
            presentationMode: EventDetailPresentationMode.spotlightDark,
          ),
        ),
      ),
      _StateCard(
        label: 'text scale 2',
        child: MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(2)),
          child: _RouteFrame(
            value: AsyncData(_eventVm(_event, participation: _signedUp)),
            child: EventDetailScreen(clubId: _clubId, eventId: _event.id),
          ),
        ),
      ),
      _StateCard(
        label: 'reduced motion',
        child: TickerMode(
          enabled: false,
          child: _RouteFrame(
            value: AsyncData(_eventVm(_event, participation: _signedUp)),
            child: EventDetailScreen(clubId: _clubId, eventId: _event.id),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Legacy hero states',
  type: LegacyEventHeroSurface,
  path: '[Event Detail]/Hero',
)
Widget eventDetailLegacyHeroSurfaceStates(BuildContext context) {
  return _CatalogScreen(
    title: 'LegacyEventHeroSurface',
    catalogId: 'event_detail.hero.legacy_surface',
    children: [
      _StateCard(
        label: 'standard route hero',
        child: ClipRRect(
          borderRadius: BorderRadius.circular(CatchRadius.lg),
          child: SizedBox(
            height: 280,
            child: LegacyEventHeroSurface(event: _event),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Ticket hero states',
  type: EventDetailTicketHeroSurface,
  path: '[Event Detail]/Hero',
)
Widget eventDetailTicketHeroSurfaceStates(BuildContext context) {
  return _CatalogScreen(
    title: 'EventDetailTicketHeroSurface',
    catalogId: 'event_detail.hero.ticket_hero_surface',
    children: [
      _StateCard(
        label: 'ticket transition target',
        child: ClipRRect(
          borderRadius: BorderRadius.circular(CatchRadius.lg),
          child: SizedBox(
            height: 360,
            child: EventDetailTicketHeroSurface(
              event: _event,
              presentationMode: EventDetailPresentationMode.ticket,
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'spotlight transition target',
        child: ClipRRect(
          borderRadius: BorderRadius.circular(CatchRadius.lg),
          child: SizedBox(
            height: 360,
            child: EventDetailTicketHeroSurface(
              event: _event,
              presentationMode: EventDetailPresentationMode.spotlightDark,
            ),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Ticket surface states',
  type: EventDetailTicketSurface,
  path: '[Event Detail]/Hero',
)
Widget eventDetailTicketSurfaceStates(BuildContext context) {
  return _CatalogScreen(
    title: 'EventDetailTicketSurface',
    catalogId: 'event_detail.hero.ticket_surface',
    children: [
      _StateCard(
        label: 'ticket and spotlight bodies',
        child: Wrap(
          spacing: CatchSpacing.s4,
          runSpacing: CatchSpacing.s4,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(CatchRadius.lg),
              child: SizedBox(
                width: 320,
                height: 360,
                child: EventDetailTicketSurface(
                  event: _event,
                  presentationMode: EventDetailPresentationMode.ticket,
                ),
              ),
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(CatchRadius.lg),
              child: SizedBox(
                width: 320,
                height: 360,
                child: EventDetailTicketSurface(
                  event: _event,
                  presentationMode: EventDetailPresentationMode.spotlightDark,
                ),
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Activity badge states',
  type: HeroActivityBadge,
  path: '[Event Detail]/Hero',
)
Widget eventDetailHeroActivityBadgeStates(BuildContext context) {
  return _CatalogScreen(
    title: 'HeroActivityBadge',
    catalogId: 'event_detail.hero.activity_badge',
    children: [
      _StateCard(
        label: 'activity badges',
        child: ColoredBox(
          color: CatchTokens.editorialDark,
          child: Padding(
            padding: CatchInsets.content,
            child: Wrap(
              spacing: CatchSpacing.s3,
              runSpacing: CatchSpacing.s3,
              children: [
                HeroActivityBadge(
                  visual: eventActivityVisual(
                    ActivityKind.socialRun,
                    context: context,
                  ),
                ),
                HeroActivityBadge(
                  visual: eventActivityVisual(
                    ActivityKind.dinner,
                    context: context,
                  ),
                ),
                HeroActivityBadge(
                  visual: eventActivityVisual(
                    ActivityKind.pickleball,
                    context: context,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Time chip states',
  type: HeroTimeChip,
  path: '[Event Detail]/Hero',
)
Widget eventDetailHeroTimeChipStates(BuildContext context) {
  return _CatalogScreen(
    title: 'HeroTimeChip',
    catalogId: 'event_detail.hero.time_chip',
    children: [
      _StateCard(
        label: 'time chips',
        child: ColoredBox(
          color: CatchTokens.editorialDark,
          child: Padding(
            padding: CatchInsets.content,
            child: Wrap(
              spacing: CatchSpacing.s3,
              runSpacing: CatchSpacing.s3,
              children: [
                HeroTimeChip(event: _event),
                HeroTimeChip(
                  event: _eventDetailEvent(
                    id: 'widgetbook-event-detail-evening',
                    activityKind: ActivityKind.dinner,
                    startTime: DateTime(2026, 6, 24, 19, 30),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Overview states',
  type: EventDetailOverviewSection,
  path: '[Event Detail]/Sections',
)
Widget eventDetailOverviewSectionStates(BuildContext context) {
  return _CatalogScreen(
    title: 'EventDetailOverviewSection',
    catalogId: 'section.event.plan',
    children: [
      _StateCard(
        label: 'standard run plan',
        child: EventDetailOverviewSection(event: _event, onLocationTap: _noop),
      ),
      _StateCard(
        label: 'fallback plan / no photos',
        child: EventDetailOverviewSection(
          event: _event.copyWith(description: '', eventPhotos: const []),
        ),
      ),
      _StateCard(
        label: 'approval and paid policy',
        child: EventDetailOverviewSection(
          event: _eventDetailEvent(
            id: 'widgetbook-event-detail-approval',
            activityKind: ActivityKind.dinner,
            priceInPaise: 140000,
            bookedCount: 10,
            eventPolicy: EventPolicyBundle.requestToJoinEvent(
              capacityLimit: 12,
              basePriceInPaise: 140000,
            ),
          ),
          onLocationTap: _noop,
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Event description',
  type: EventDescription,
  path: '[Event Detail]/Sections',
)
Widget eventDescriptionState(BuildContext context) {
  return const Padding(
    padding: CatchInsets.contentDense,
    child: EventDescription(
      description:
          'A low-pressure morning plan with a clear route, relaxed pace, and coffee after.',
    ),
  );
}

@widgetbook.UseCase(
  name: 'What to expect',
  type: WhatToExpectSection,
  path: '[Event Detail]/Sections',
)
Widget eventWhatToExpectState(BuildContext context) {
  return Padding(
    padding: CatchInsets.contentDense,
    child: WhatToExpectSection(event: _event),
  );
}

@widgetbook.UseCase(
  name: 'Optimistic body states',
  type: EventDetailOptimisticBody,
  path: '[Event Detail]/Sections',
)
Widget eventDetailOptimisticBodyStates(BuildContext context) {
  return _CatalogScreen(
    title: 'EventDetailOptimisticBody',
    catalogId: 'section.event.optimistic_body',
    children: [
      _StateCard(
        label: 'standard loading bridge',
        child: _DeviceFrame(
          child: EventDetailOptimisticBody(event: _event, clubId: _clubId),
        ),
      ),
      _StateCard(
        label: 'spotlight bridge',
        child: _DeviceFrame(
          child: EventDetailOptimisticBody(
            event: _event,
            clubId: _clubId,
            presentationMode: EventDetailPresentationMode.spotlightDark,
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Optimistic hosts skeleton',
  type: OptimisticHostsSkeleton,
  path: '[Event Detail]/Sections',
)
Widget eventDetailOptimisticHostsSkeletonState(BuildContext context) {
  return const Padding(
    padding: CatchInsets.contentDense,
    child: OptimisticHostsSkeleton(),
  );
}

@widgetbook.UseCase(
  name: 'Optimistic social skeleton',
  type: OptimisticSocialSkeleton,
  path: '[Event Detail]/Sections',
)
Widget eventDetailOptimisticSocialSkeletonState(BuildContext context) {
  return const Padding(
    padding: CatchInsets.contentDense,
    child: OptimisticSocialSkeleton(),
  );
}

@widgetbook.UseCase(
  name: 'Policy summary states',
  type: EventDetailPolicySummary,
  path: '[Event Detail]/Sections',
)
Widget eventDetailPolicySummaryStates(BuildContext context) {
  return _CatalogScreen(
    title: 'EventDetailPolicySummary',
    catalogId: 'section.event.plan.policy_summary',
    children: [
      _StateCard(
        label: 'open free event',
        child: EventDetailPolicySummary(event: _event),
      ),
      _StateCard(
        label: 'request to join paid event',
        child: EventDetailPolicySummary(
          event: _eventDetailEvent(
            id: 'widgetbook-policy-paid-request',
            activityKind: ActivityKind.dinner,
            priceInPaise: 140000,
            eventPolicy: EventPolicyBundle.requestToJoinEvent(
              capacityLimit: 12,
              basePriceInPaise: 140000,
            ),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Policy summary line',
  type: EventDetailPolicySummaryLine,
  path: '[Event Detail]/Sections',
)
Widget eventDetailPolicySummaryLineState(BuildContext context) {
  return EventDetailPolicySummaryLine(
    icon: CatchIcons.groupOutlined,
    title: 'Open booking',
    body: 'Anyone who meets the event requirements can book instantly.',
  );
}

@widgetbook.UseCase(
  name: 'Photo strip tile states',
  type: EventDetailPhotoStripTile,
  path: '[Event Detail]/Design Primitives',
)
Widget eventDetailPhotoStripTileStates(BuildContext context) {
  final activity = ActivityPalette.resolve(context, ActivityKind.socialRun);
  final photo = UploadedPhoto.fromUpload(
    url:
        'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?w=640&q=80',
    storagePath: 'widgetbook/events/photo-strip-tile.jpg',
    position: 0,
    now: _now,
  );

  return _CatalogScreen(
    title: 'EventDetailPhotoStripTile',
    catalogId: 'event_detail.design.photo_strip_tile',
    children: [
      _StateCard(
        label: 'uploaded photo',
        child: SizedBox(
          width: 116,
          child: EventDetailPhotoStripTile(
            index: 0,
            photo: photo,
            backgroundColor: activity.soft,
            iconColor: activity.deep,
            icon: activity.glyph,
          ),
        ),
      ),
      _StateCard(
        label: 'placeholder',
        child: SizedBox(
          width: 116,
          child: EventDetailPhotoStripTile(
            index: 1,
            photo: null,
            backgroundColor: activity.soft,
            iconColor: activity.deep,
            icon: activity.glyph,
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Ticket stub cell states',
  type: TicketStubCell,
  path: '[Event Detail]/Design Primitives',
)
Widget eventDetailTicketStubCellStates(BuildContext context) {
  return _CatalogScreen(
    title: 'TicketStubCell',
    catalogId: 'event_detail.design.ticket_stub_cell',
    children: [
      _StateCard(
        label: 'ticket row cells',
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Row(
            children: [
              Expanded(
                child: TicketStubCell(
                  cell: TicketStubCellData(
                    label: 'When',
                    value: 'Wed, Jun 24',
                    detail: '6:30 AM-8:15 AM',
                    icon: CatchIcons.calendarAdd,
                  ),
                  showDivider: false,
                ),
              ),
              Expanded(
                child: TicketStubCell(
                  cell: TicketStubCellData(
                    label: 'Where',
                    value: 'Carter Road Jetty',
                    detail: 'Bandra West',
                    icon: CatchIcons.locationOnOutlined,
                  ),
                  showDivider: true,
                ),
              ),
            ],
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Hairline list states',
  type: HairlineList,
  path: '[Event Detail]/Design Primitives',
)
Widget eventDetailHairlineListStates(BuildContext context) {
  final activity = ActivityPalette.resolve(context, ActivityKind.socialRun);
  final icons = [
    CatchIcons.calendarTodayOutlined,
    CatchIcons.groupOutlined,
    CatchIcons.receiptLongOutlined,
  ];
  final titles = ['Arrival', 'Group rhythm', 'Cancellation'];
  final bodies = [
    'Host check-in starts ten minutes before the run.',
    'Regroup points keep the route social without stopping the flow.',
    'Free cancellation until 24 hours before start time.',
  ];

  return _CatalogScreen(
    title: 'HairlineList',
    catalogId: 'event_detail.design.hairline_list',
    children: [
      _StateCard(
        label: 'field rows',
        child: HairlineList(
          itemCount: titles.length,
          itemBuilder: (context, index) => CatchField.read(
            icon: icons[index],
            iconColor: activity.deep,
            title: titles[index],
            body: bodies[index],
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Itinerary row states',
  type: ItineraryRow,
  path: '[Event Detail]/Design Primitives',
)
Widget eventDetailItineraryRowStates(BuildContext context) {
  final t = CatchTokens.of(context);
  final activity = ActivityPalette.resolve(context, ActivityKind.socialRun);
  final steps = const [
    ItineraryStep(
      time: '6:30 AM',
      title: 'Gather at Carter Road Jetty',
      detail: 'Quick hellos, host check-in, and the plan for the group.',
    ),
    ItineraryStep(
      time: '6:45 AM',
      title: 'Easy social run',
      detail: 'A conversational 5 km route with two regroup points.',
    ),
    ItineraryStep(
      time: '8:15 AM',
      title: 'Coffee finish',
      detail: 'Attendees can linger naturally; follow-up unlocks after.',
    ),
  ];

  return _CatalogScreen(
    title: 'ItineraryRow',
    catalogId: 'event_detail.design.itinerary_row',
    children: [
      _StateCard(
        label: 'timeline rows',
        child: Column(
          children: [
            for (var index = 0; index < steps.length; index += 1)
              ItineraryRow(
                step: steps[index],
                isLast: index == steps.length - 1,
                accent: activity.accent,
                railColor: t.line2,
              ),
          ],
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Map pill states',
  type: MapPill,
  path: '[Event Detail]/Design Primitives',
)
Widget eventDetailMapPillStates(BuildContext context) {
  final t = CatchTokens.of(context);
  return _CatalogScreen(
    title: 'MapPill',
    catalogId: 'event_detail.design.map_pill',
    children: [
      _StateCard(
        label: 'location labels',
        child: Wrap(
          spacing: CatchSpacing.s2,
          runSpacing: CatchSpacing.s2,
          children: [
            MapPill(text: 'Carter Road Jetty', color: t.ink),
            MapPill(text: 'PIN READY', color: t.ink2),
            MapPill(text: 'DROPS MORNING-OF', color: t.ink2),
          ],
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Host avatar states',
  type: HostAvatar,
  path: '[Event Detail]/Design Primitives',
)
Widget eventDetailHostAvatarStates(BuildContext context) {
  final activity = ActivityPalette.resolve(context, ActivityKind.socialRun);
  return _CatalogScreen(
    title: 'HostAvatar',
    catalogId: 'event_detail.design.host_avatar',
    children: [
      _StateCard(
        label: 'fallback and photo',
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            HostAvatar(activity: activity),
            gapW12,
            HostAvatar(
              activity: activity,
              photoUrl:
                  'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=160&q=80',
            ),
          ],
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Social states',
  type: EventDetailSocialSection,
  path: '[Event Detail]/Sections',
)
Widget eventDetailSocialSectionStates(BuildContext context) {
  return _CatalogScreen(
    title: 'EventDetailSocialSection',
    catalogId: 'section.event.who_is_going',
    children: [
      _StateCard(
        label: 'guest locked',
        child: _EventScope(
          event: _event,
          roster: _roster(),
          child: EventDetailSocialSection(
            event: _event,
            clubId: _clubId,
            reviews: const [],
            userProfile: null,
            state: eventDetailSocialStateFrom(
              event: _event,
              userProfile: null,
              isAuthenticated: false,
              renderAsHost: false,
              participation: null,
              now: _now,
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'member visible',
        child: _EventScope(
          event: _event,
          roster: _roster(),
          child: EventDetailSocialSection(
            event: _event,
            clubId: _clubId,
            reviews: const [],
            userProfile: _viewer,
            state: eventDetailSocialStateFrom(
              event: _event,
              userProfile: _viewer,
              isAuthenticated: true,
              renderAsHost: false,
              participation: _signedUp,
              now: _now,
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'empty roster',
        child: _EventScope(
          event: _emptyEvent,
          roster: EventParticipationRoster.empty(),
          child: EventDetailSocialSection(
            event: _emptyEvent,
            clubId: _clubId,
            reviews: const [],
            userProfile: _viewer,
            state: eventDetailSocialStateFrom(
              event: _emptyEvent,
              userProfile: _viewer,
              isAuthenticated: true,
              renderAsHost: false,
              participation: null,
              now: _now,
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'long avatar feed',
        child: _EventScope(
          event: _pastEvent,
          roster: _roster(event: _pastEvent, count: 9),
          avatarItems: _avatarItems,
          child: EventDetailSocialSection(
            event: _pastEvent,
            clubId: _clubId,
            reviews: _reviews,
            userProfile: _viewer,
            state: eventDetailSocialStateFrom(
              event: _pastEvent,
              userProfile: _viewer,
              isAuthenticated: true,
              renderAsHost: false,
              participation: _attended,
              now: _now,
            ),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Review states',
  type: EventReviewsSection,
  path: '[Event Detail]/Sections',
)
Widget eventDetailReviewsSectionStates(BuildContext context) {
  return _CatalogScreen(
    title: 'EventReviewsSection',
    catalogId: 'section.event.reviews',
    children: [
      _StateCard(
        label: 'hidden guest',
        child: const _HiddenSectionState(
          message: 'Reviews are not composed for signed-out Event Detail.',
        ),
      ),
      _StateCard(
        label: 'member before event',
        child: EventReviewsSection(
          clubId: _clubId,
          eventId: _event.id,
          reviews: const [],
          currentUid: _viewerUid,
          userProfile: _viewer,
        ),
      ),
      _StateCard(
        label: 'attended can review',
        child: EventReviewsSection(
          clubId: _clubId,
          eventId: _pastEvent.id,
          reviews: _reviews,
          currentUid: _viewerUid,
          userProfile: _viewer,
          hasAttended: true,
        ),
      ),
      _StateCard(
        label: 'host response actions',
        child: EventReviewsSection(
          clubId: _clubId,
          eventId: _pastEvent.id,
          reviews: _reviews,
          currentUid: 'host-mira',
          userProfile: _viewer.copyWith(uid: 'host-mira', name: 'Mira Shah'),
          isHost: true,
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Review history states',
  type: ReviewsHistoryScreen,
  path: '[Event Detail]/Screens',
)
Widget reviewsHistoryScreenStates(BuildContext context) {
  return _CatalogScreen(
    title: 'ReviewsHistoryScreen',
    catalogId: 'screen.reviews.history',
    children: [
      _StateCard(
        label: 'signed out',
        child: const _DeviceFrame(
          child: _ReviewsHistoryFrame(
            uid: null,
            user: AsyncData<UserProfile?>(null),
            reviews: AsyncData<List<Review>>([]),
          ),
        ),
      ),
      _StateCard(
        label: 'loading',
        child: const _DeviceFrame(
          child: _ReviewsHistoryFrame(
            uid: _viewerUid,
            user: AsyncLoading<UserProfile?>(),
            reviews: AsyncLoading<List<Review>>(),
          ),
        ),
      ),
      _StateCard(
        label: 'review history',
        child: _DeviceFrame(
          child: _ReviewsHistoryFrame(
            uid: _viewerUid,
            user: AsyncData(_viewer),
            reviews: AsyncData(_reviews),
            events: AsyncData([_pastEvent]),
          ),
        ),
      ),
      _StateCard(
        label: 'reviews unavailable',
        child: _DeviceFrame(
          child: _ReviewsHistoryFrame(
            uid: _viewerUid,
            user: AsyncData(_viewer),
            reviews: AsyncError<List<Review>>(
              StateError('Widgetbook review history failed'),
              StackTrace.empty,
            ),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Share card states',
  type: EventShareCard,
  path: '[Event Detail]/Cards',
)
Widget eventShareCardStates(BuildContext context) {
  return _CatalogScreen(
    title: 'EventShareCard',
    catalogId: 'card.event.share',
    children: [
      _StateCard(
        label: 'free event',
        child: EventShareCard(event: _event),
      ),
      _StateCard(
        label: 'paid limited spots',
        child: EventShareCard(
          event: _eventDetailEvent(
            id: 'widgetbook-event-share-paid',
            activityKind: ActivityKind.dinner,
            priceInPaise: 160000,
            capacityLimit: 12,
            bookedCount: 11,
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Share meta row',
  type: EventShareMetaRow,
  path: '[Event Detail]/Cards',
)
Widget eventShareMetaRowState(BuildContext context) {
  return Padding(
    padding: CatchInsets.contentDense,
    child: EventShareMetaRow(
      icon: CatchIcons.calendarTodayOutlined,
      label: _event.longDateLabel,
      accent: CatchTokens.of(context).accent,
    ),
  );
}

@widgetbook.UseCase(
  name: 'Share pill',
  type: EventSharePill,
  path: '[Event Detail]/Cards',
)
Widget eventSharePillState(BuildContext context) {
  return const Padding(
    padding: CatchInsets.contentDense,
    child: EventSharePill(label: '3 spots left'),
  );
}

@widgetbook.UseCase(
  name: 'BookingDock states',
  type: EventBookingDock,
  path: '[Event Detail]/Sections',
)
Widget eventDetailBookingDockStates(BuildContext context) {
  final t = CatchTokens.of(context);
  return _CatalogScreen(
    title: 'EventBookingDock',
    catalogId: 'section.event.booking_dock',
    children: [
      _StateCard(
        label: 'guest',
        child: const _DockFrame(
          child: EventBookingDock(
            label: 'Sign in to book this event',
            onPressed: _noop,
          ),
        ),
      ),
      _StateCard(
        label: 'bookable with price',
        child: _DockFrame(
          child: EventBookingDock(
            label: 'Book event',
            onPressed: _noop,
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
      _StateCard(
        label: 'pending',
        child: _DockFrame(
          child: EventBookingDock(
            label: 'Join event - 3 spots left',
            onPressed: null,
            isLoading: true,
            buttonAccentColor: t.primary,
          ),
        ),
      ),
      _StateCard(
        label: 'failed mutation',
        child: _DockFrame(
          child: EventBookingDock(
            label: 'Join event - 3 spots left',
            onPressed: _noop,
            errorMessage: 'Unable to book this event right now.',
            buttonAccentColor: t.primary,
          ),
        ),
      ),
      _StateCard(
        label: 'booked',
        child: const _DockFrame(
          child: EventBookingDock(
            label: 'Cancel booking',
            onPressed: _noop,
            leadingContent: BookedLeading(),
          ),
        ),
      ),
      _StateCard(
        label: 'waitlist',
        child: const _DockFrame(
          child: EventBookingDock(label: 'Join waitlist', onPressed: _noop),
        ),
      ),
      _StateCard(
        label: 'waitlist offer',
        child: _DockFrame(
          child: EventBookingDock(
            label: 'Accept spot',
            onPressed: _noop,
            leadingContent: WaitlistOfferLeading(
              expiresAt: _now.add(const Duration(hours: 5)),
              isDeclining: false,
              onDecline: _noop,
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'full / cancelled / past / attended',
        child: const Column(
          children: [
            _DockFrame(
              child: EventBookingDock(
                label: 'Spots for your gender are full',
                onPressed: null,
              ),
            ),
            gapH12,
            _DockFrame(
              child: EventBookingDock(
                label: 'This event has ended',
                onPressed: null,
              ),
            ),
            gapH12,
            _DockFrame(
              child: EventBookingDock(
                label: 'You attended this event',
                onPressed: null,
                leadingContent: AttendedLeading(),
              ),
            ),
          ],
        ),
      ),
      _StateCard(
        label: 'host hidden',
        child: const _HiddenSectionState(
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
  return _CatalogScreen(
    title: 'BookingConflictSheet',
    catalogId: 'sheet.event.booking_conflict',
    children: [
      _StateCard(
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
            onReplaceExisting: _noop,
            onKeepBoth: _noop,
            onKeepExisting: _noop,
          ),
        ),
      ),
      _StateCard(
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
            onReplaceExisting: _noop,
            onKeepBoth: _noop,
            onKeepExisting: _noop,
          ),
        ),
      ),
      _StateCard(
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
            onReplaceExisting: _noop,
            onKeepBoth: _noop,
            onKeepExisting: _noop,
          ),
        ),
      ),
      _StateCard(
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
            onReplaceExisting: _noop,
            onKeepBoth: _noop,
            onKeepExisting: _noop,
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

  return _CatalogScreen(
    title: 'BookingConflictEventRow',
    catalogId: 'row.event.booking_conflict',
    children: [
      _StateCard(
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
      _StateCard(
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
  return _CatalogScreen(
    title: 'EventDetailBody prompts',
    catalogId: 'section.event.companion_invite',
    children: [
      _StateCard(
        label: 'hidden',
        child: _DeviceFrame(
          child: _EventScope(
            event: _event,
            plan: null,
            child: EventDetailBody(
              event: _event,
              userProfile: _viewer,
              clubId: _clubId,
              reviews: const [],
              isAuthenticated: true,
              sectionVisibility: eventDetailSectionVisibilityStateFrom(
                event: _event,
                participation: null,
                isHostApp: false,
                isHost: false,
                now: _now,
              ),
              isSaved: false,
              participation: null,
              savePending: false,
              onBack: _noop,
              onShare: _noopContext,
              showAddToCalendar: false,
              onAddToCalendar: _noopContext,
              onToggleSaved: _noop,
              companionState: const EventDetailCompanionState.hidden(),
              hostState: const EventDetailHostState.hidden(),
              socialState: eventDetailSocialStateFrom(
                event: _event,
                userProfile: _viewer,
                isAuthenticated: true,
                renderAsHost: false,
                participation: null,
                now: _now,
              ),
              onLocationTap: null,
              onOpenCompanion: _noop,
              onRetryCompanion: _noop,
              onViewClub: _noopString,
              onMessageHost: _noopMessageHost,
              onRetryHosts: _noop,
              now: _now,
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'companion available',
        child: _DeviceFrame(
          child: _EventScope(
            event: _event,
            plan: EventSuccessPlan.defaultForEvent(_event, now: _now),
            child: EventDetailBody(
              event: _event,
              userProfile: _viewer,
              clubId: _clubId,
              reviews: _reviews,
              isAuthenticated: true,
              sectionVisibility: eventDetailSectionVisibilityStateFrom(
                event: _event,
                participation: _signedUp,
                isHostApp: false,
                isHost: false,
                now: _now,
              ),
              isSaved: true,
              participation: _signedUp,
              savePending: false,
              onBack: _noop,
              onShare: _noopContext,
              showAddToCalendar: false,
              onAddToCalendar: _noopContext,
              onToggleSaved: _noop,
              companionState: const EventDetailCompanionState.available(),
              hostState: const EventDetailHostState.hidden(),
              socialState: eventDetailSocialStateFrom(
                event: _event,
                userProfile: _viewer,
                isAuthenticated: true,
                renderAsHost: false,
                participation: _signedUp,
                now: _now,
              ),
              onLocationTap: null,
              onOpenCompanion: _noop,
              onRetryCompanion: _noop,
              onViewClub: _noopString,
              onMessageHost: _noopMessageHost,
              onRetryHosts: _noop,
              now: _now,
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'invite loop available',
        child: _DeviceFrame(
          child: _EventScope(
            event: _event,
            plan: null,
            child: EventDetailBody(
              event: _event,
              userProfile: _viewer,
              clubId: _clubId,
              reviews: _reviews,
              isAuthenticated: true,
              sectionVisibility: eventDetailSectionVisibilityStateFrom(
                event: _event,
                participation: _signedUp,
                isHostApp: false,
                isHost: false,
                now: _now,
              ),
              isSaved: true,
              participation: _signedUp,
              savePending: false,
              onBack: _noop,
              onShare: _noopContext,
              showAddToCalendar: false,
              onAddToCalendar: _noopContext,
              onToggleSaved: _noop,
              companionState: const EventDetailCompanionState.hidden(),
              hostState: const EventDetailHostState.hidden(),
              socialState: eventDetailSocialStateFrom(
                event: _event,
                userProfile: _viewer,
                isAuthenticated: true,
                renderAsHost: false,
                participation: _signedUp,
                now: _now,
              ),
              onLocationTap: null,
              onOpenCompanion: _noop,
              onRetryCompanion: _noop,
              onViewClub: _noopString,
              onMessageHost: _noopMessageHost,
              onRetryHosts: _noop,
              now: _now,
              presentationMode: EventDetailPresentationMode.ticket,
            ),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Companion entry states',
  type: EventCompanionEntry,
  path: '[Event Detail]/Sections',
)
Widget eventDetailCompanionEntryStates(BuildContext context) {
  return _CatalogScreen(
    title: 'EventCompanionEntry',
    catalogId: 'section.event.companion_entry',
    children: [
      _StateCard(
        label: 'hidden',
        child: _DeviceFrame(
          child: EventCompanionEntry(
            state: const EventDetailCompanionState.hidden(),
            surfaceStyle: EventDetailSurfaceStyle.light(
              CatchTokens.of(context),
            ),
            onOpen: _noop,
            onRetry: _noop,
          ),
        ),
      ),
      _StateCard(
        label: 'loading',
        child: _DeviceFrame(
          child: EventCompanionEntry(
            state: const EventDetailCompanionState.loading(),
            surfaceStyle: EventDetailSurfaceStyle.light(
              CatchTokens.of(context),
            ),
            onOpen: _noop,
            onRetry: _noop,
          ),
        ),
      ),
      _StateCard(
        label: 'available',
        child: _DeviceFrame(
          child: EventCompanionEntry(
            state: const EventDetailCompanionState.available(),
            surfaceStyle: EventDetailSurfaceStyle.light(
              CatchTokens.of(context),
            ),
            onOpen: _noop,
            onRetry: _noop,
          ),
        ),
      ),
      _StateCard(
        label: 'error',
        child: _DeviceFrame(
          child: EventCompanionEntry(
            state: EventDetailCompanionState.error(
              StateError('Could not load event companion.'),
            ),
            surfaceStyle: EventDetailSurfaceStyle.light(
              CatchTokens.of(context),
            ),
            onOpen: _noop,
            onRetry: _noop,
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Invite loop card',
  type: EventInviteLoopCard,
  path: '[Event Detail]/Sections',
)
Widget eventDetailInviteLoopCardStates(BuildContext context) {
  return _CatalogScreen(
    title: 'EventInviteLoopCard',
    catalogId: 'section.event.invite_loop_card',
    children: [
      _StateCard(
        label: 'light surface',
        child: _DeviceFrame(
          child: Padding(
            padding: CatchInsets.content,
            child: EventInviteLoopCard(
              event: _event,
              onShare: _noopContext,
              surfaceStyle: EventDetailSurfaceStyle.light(
                CatchTokens.of(context),
              ),
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'ticket surface',
        child: _DeviceFrame(
          child: Padding(
            padding: CatchInsets.content,
            child: EventInviteLoopCard(
              event: _event,
              onShare: _noopContext,
              surfaceStyle: EventDetailSurfaceStyle.dark(
                CatchTokens.of(context),
              ),
            ),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Companion card',
  type: EventCompanionCard,
  path: '[Event Detail]/Sections',
)
Widget eventDetailCompanionCardStates(BuildContext context) {
  return _CatalogScreen(
    title: 'EventCompanionCard',
    catalogId: 'section.event.companion_card',
    children: [
      _StateCard(
        label: 'light surface',
        child: _DeviceFrame(
          child: Padding(
            padding: CatchInsets.content,
            child: EventCompanionCard(
              surfaceStyle: EventDetailSurfaceStyle.light(
                CatchTokens.of(context),
              ),
              onOpen: _noop,
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'ticket surface',
        child: _DeviceFrame(
          child: Padding(
            padding: CatchInsets.content,
            child: EventCompanionCard(
              surfaceStyle: EventDetailSurfaceStyle.dark(
                CatchTokens.of(context),
              ),
              onOpen: _noop,
            ),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Guest book CTA',
  type: GuestBookCta,
  path: '[Event Detail]/Sections',
)
Widget eventDetailGuestBookCtaStates(BuildContext context) {
  return _CatalogScreen(
    title: 'GuestBookCta',
    catalogId: 'section.event.guest_book_cta',
    children: [
      _StateCard(
        label: 'light dock',
        child: const _DockFrame(child: GuestBookCta(onPressed: _noop)),
      ),
      _StateCard(
        label: 'dark dock',
        child: const _DockFrame(
          child: GuestBookCta(onPressed: _noop, darkSurface: true),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Host section states',
  type: EventDetailHostsSection,
  path: '[Event Detail]/Sections',
)
Widget eventDetailHostSectionStates(BuildContext context) {
  final style = EventDetailSurfaceStyle.light(CatchTokens.of(context));
  return _CatalogScreen(
    title: 'EventDetailHostsSection',
    catalogId: 'section.event.hosts',
    children: [
      _StateCard(
        label: 'hidden',
        child: _DeviceFrame(
          child: EventDetailHostsSection(
            event: _event,
            state: const EventDetailHostState.hidden(),
            onViewClub: _noopString,
            onMessageHost: _noopMessageHost,
            onRetry: _noop,
            surfaceStyle: style,
          ),
        ),
      ),
      _StateCard(
        label: 'loading',
        child: _DeviceFrame(
          child: EventDetailHostsSection(
            event: _event,
            state: const EventDetailHostState.loading(),
            onViewClub: _noopString,
            onMessageHost: _noopMessageHost,
            onRetry: _noop,
            surfaceStyle: style,
          ),
        ),
      ),
      _StateCard(
        label: 'content',
        child: _DeviceFrame(
          child: EventDetailHostsSection(
            event: _event,
            state: const EventDetailHostState.content(
              clubId: _clubId,
              hostUid: 'host-mira',
              hostName: 'Mira Shah',
              photoUrl:
                  'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=160&q=80',
              meta: 'HOSTING SINCE JAN 2025 · BANDRA',
              verified: true,
              stats: [
                EventDetailHostStat(value: '128', label: 'Members'),
                EventDetailHostStat(value: '4.9', label: 'Rating'),
                EventDetailHostStat(value: '42', label: 'Reviews'),
              ],
              canMessage: true,
            ),
            onViewClub: _noopString,
            onMessageHost: _noopMessageHost,
            onRetry: _noop,
            surfaceStyle: style,
          ),
        ),
      ),
      _StateCard(
        label: 'error',
        child: _DeviceFrame(
          child: EventDetailHostsSection(
            event: _event,
            state: EventDetailHostState.error(
              StateError('Could not load host details.'),
            ),
            onViewClub: _noopString,
            onMessageHost: _noopMessageHost,
            onRetry: _noop,
            surfaceStyle: style,
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Joined confirmation',
  type: EventJoinedCelebrationScreen,
  path: '[Event Detail]/Screens',
)
Widget eventJoinedCelebrationScreenState(BuildContext context) {
  return _DeviceFrame(
    child: EventJoinedCelebrationScreen(
      event: _event,
      clubName: _club.name,
      paymentData: const PaymentConfirmationData(
        paymentId: 'pay_widgetbook_123',
        orderId: 'order_widgetbook_123',
        amountInPaise: 140000,
        currency: 'INR',
        eventId: 'widgetbook-event-detail',
      ),
      onViewEvent: _noop,
      onBackHome: _noop,
    ),
  );
}

@widgetbook.UseCase(
  name: 'Check-in confirmation',
  type: EventCheckInCelebrationScreen,
  path: '[Event Detail]/Screens',
)
Widget eventCheckInCelebrationScreenState(BuildContext context) {
  return _DeviceFrame(
    child: EventCheckInCelebrationScreen(
      event: _event,
      onViewEvent: _noop,
      onBackHome: _noop,
    ),
  );
}

@widgetbook.UseCase(
  name: 'Saved states',
  type: SavedEventsScreen,
  path: '[Events]/Screens',
)
Widget savedEventsScreenStates(BuildContext context) {
  final savedEvents = _agendaEvents();
  final pastOnlyEvents = [
    _pastEvent,
    _eventDetailEvent(
      id: 'widgetbook-saved-past-dinner',
      activityKind: ActivityKind.dinner,
      startTime: _now.subtract(const Duration(days: 3, hours: 2)),
    ),
  ];
  return _CatalogScreen(
    title: 'SavedEventsScreen',
    catalogId: 'screen.events.saved',
    children: [
      _StateCard(
        label: 'empty signed out',
        child: _SavedEventsRouteFrame(
          uid: null,
          savedEvents: const AsyncData<List<Event>>([]),
        ),
      ),
      _StateCard(
        label: 'saved list',
        child: _SavedEventsRouteFrame(
          savedEvents: AsyncData<List<Event>>(savedEvents),
        ),
      ),
      _StateCard(
        label: 'loading',
        child: const _SavedEventsRouteFrame(
          savedEvents: AsyncLoading<List<Event>>(),
        ),
      ),
      _StateCard(
        label: 'stream error',
        child: _SavedEventsRouteFrame(
          savedEvents: AsyncError<List<Event>>(
            StateError('Saved events failed'),
            StackTrace.empty,
          ),
        ),
      ),
      _StateCard(
        label: 'empty saved events',
        child: const _SavedEventsRouteFrame(
          savedEvents: AsyncData<List<Event>>([]),
        ),
      ),
      _StateCard(
        label: 'club names loading',
        child: _SavedEventsRouteFrame(
          savedEvents: AsyncData<List<Event>>(savedEvents),
          clubNames: const AsyncLoading<Map<String, String>>(),
        ),
      ),
      _StateCard(
        label: 'club names error',
        child: _SavedEventsRouteFrame(
          savedEvents: AsyncData<List<Event>>(savedEvents),
          clubNames: AsyncError<Map<String, String>>(
            StateError('Club names failed'),
            StackTrace.empty,
          ),
        ),
      ),
      _StateCard(
        label: 'past only',
        child: _SavedEventsRouteFrame(
          savedEvents: AsyncData<List<Event>>(pastOnlyEvents),
        ),
      ),
      _StateCard(
        label: 'text scale 2',
        child: MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(2)),
          child: _SavedEventsRouteFrame(
            savedEvents: AsyncData<List<Event>>(savedEvents),
          ),
        ),
      ),
      _StateCard(
        label: 'dark theme',
        child: Theme(
          data: AppTheme.dark,
          child: _SavedEventsRouteFrame(
            savedEvents: AsyncData<List<Event>>(savedEvents),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Header sliver',
  type: SavedEventsHeaderSliver,
  path: '[Events]/Sections',
)
Widget savedEventsHeaderSliverState(BuildContext context) {
  return const SizedBox(
    height: 160,
    child: CustomScrollView(slivers: [SavedEventsHeaderSliver()]),
  );
}

@widgetbook.UseCase(
  name: 'Agenda sliver states',
  type: SavedEventsAgendaSliver,
  path: '[Events]/Sections',
)
Widget savedEventsAgendaSliverStates(BuildContext context) {
  final events = _agendaEvents();
  return SizedBox(
    height: 620,
    child: CustomScrollView(
      slivers: [
        SavedEventsAgendaSliver(
          state: SavedEventsListState.from(events, now: _now),
          clubNames: {for (final event in events) event.clubId: _club.name},
          onEventSelected: (_) {},
        ),
      ],
    ),
  );
}

@widgetbook.UseCase(
  name: 'Route error',
  type: SavedEventsError,
  path: '[Events]/Sections',
)
Widget savedEventsErrorState(BuildContext context) {
  return SizedBox(
    height: 360,
    child: SavedEventsError(
      error: StateError('Saved events failed'),
      onRetry: _noop,
    ),
  );
}

@widgetbook.UseCase(
  name: 'Club names error sliver',
  type: SavedEventsClubNamesErrorSliver,
  path: '[Events]/Sections',
)
Widget savedEventsClubNamesErrorSliverState(BuildContext context) {
  return SizedBox(
    height: 360,
    child: CustomScrollView(
      slivers: [
        SavedEventsClubNamesErrorSliver(
          error: StateError('Club names failed'),
          onRetry: _noop,
        ),
      ],
    ),
  );
}

class _SavedEventsRouteFrame extends StatelessWidget {
  const _SavedEventsRouteFrame({
    this.uid = _viewerUid,
    this.savedEvents,
    this.clubNames,
  });

  final String? uid;
  final AsyncValue<List<Event>>? savedEvents;
  final AsyncValue<Map<String, String>>? clubNames;

  @override
  Widget build(BuildContext context) {
    final effectiveSavedEvents =
        savedEvents ?? AsyncData<List<Event>>(_agendaEvents());
    final events = _asyncDataList(effectiveSavedEvents);
    final query = ClubNameLookupQuery(events.map((event) => event.clubId));

    return _DeviceFrame(
      child: ProviderScope(
        overrides: [
          uidProvider.overrideWithValue(AsyncData<String?>(uid)),
          if (uid != null)
            watchSavedEventDetailsForUserProvider(
              uid!,
            ).overrideWithValue(effectiveSavedEvents),
          if (events.isNotEmpty)
            clubNameLookupProvider(query).overrideWithValue(
              clubNames ??
                  AsyncData<Map<String, String>>({
                    for (final event in events) event.clubId: _club.name,
                  }),
            ),
        ],
        child: SavedEventsScreen(referenceNow: _now),
      ),
    );
  }
}

List<T> _asyncDataList<T>(AsyncValue<List<T>> value) {
  return switch (value) {
    AsyncData<List<T>>(:final value) => value,
    _ => <T>[],
  };
}

@widgetbook.UseCase(
  name: 'Picker states',
  type: LocationPickerScreen,
  path: '[Events]/Screens',
)
Widget locationPickerScreenStates(BuildContext context) {
  return _DeviceFrame(
    child: LocationPickerScreen(
      initialLocation: _mapCenter,
      initialLabel: 'Carter Road Jetty',
      loadMapTiles: false,
    ),
  );
}

@widgetbook.UseCase(
  name: 'Map view states',
  type: EventMapView,
  path: '[Events]/Map',
)
Widget eventMapViewStates(BuildContext context) {
  final items = _eventMapItems();
  return _CatalogScreen(
    title: 'EventMapView',
    catalogId: 'screen.events.map',
    children: [
      _StateCard(
        label: 'loading',
        child: SizedBox(
          height: 360,
          child: ProviderScope(
            overrides: [
              deviceLocationProvider.overrideWith(_NoDeviceLocation.new),
            ],
            child: const EventMapView(
              viewModel: AsyncLoading<EventMapViewModel>(),
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'pinned events',
        child: SizedBox(
          height: 360,
          child: ProviderScope(
            overrides: [
              deviceLocationProvider.overrideWith(_NoDeviceLocation.new),
            ],
            child: EventMapView(
              enableNetworkTiles: false,
              viewModel: AsyncData(
                EventMapViewModel(
                  events: [for (final item in items) item.event],
                  pinnedEvents: [for (final item in items) item.event],
                  items: items,
                  pinnedItems: items,
                ),
              ),
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'empty',
        child: SizedBox(
          height: 360,
          child: ProviderScope(
            overrides: [
              deviceLocationProvider.overrideWith(_NoDeviceLocation.new),
            ],
            child: const EventMapView(
              viewModel: AsyncData(
                EventMapViewModel(events: <Event>[], pinnedEvents: <Event>[]),
              ),
            ),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Map empty states',
  type: EventMapEmptyState,
  path: '[Events]/Map',
)
Widget eventMapEmptyStates(BuildContext context) {
  return const _CatalogScreen(
    title: 'Event map empty states',
    catalogId: 'screen.events.map.empty_states',
    children: [
      _StateCard(
        label: 'no mapped events',
        child: SizedBox(height: 220, child: EventMapEmptyState()),
      ),
      _StateCard(
        label: 'no exact pins',
        child: SizedBox(height: 220, child: EventMapNoPinnedEventsState()),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Map no-pinned state',
  type: EventMapNoPinnedEventsState,
  path: '[Events]/Map',
)
Widget eventMapNoPinnedEventsState(BuildContext context) {
  return const SizedBox(height: 220, child: EventMapNoPinnedEventsState());
}

@widgetbook.UseCase(
  name: 'Location loading',
  type: EventLocationMapLoadingBody,
  path: '[Events]/Map',
)
Widget eventLocationMapLoadingBodyState(BuildContext context) {
  return const SizedBox(height: 360, child: EventLocationMapLoadingBody());
}

@widgetbook.UseCase(
  name: 'Map loading',
  type: EventMapLoadingBody,
  path: '[Events]/Map',
)
Widget eventMapLoadingBodyState(BuildContext context) {
  return const SizedBox(height: 360, child: EventMapLoadingBody());
}

@widgetbook.UseCase(
  name: 'Chromeless map scaffold',
  type: ChromelessMapScaffold,
  path: '[Events]/Map',
)
Widget chromelessMapScaffoldState(BuildContext context) {
  return const _DeviceFrame(
    child: ChromelessMapScaffold(child: EventMapLoadingBody()),
  );
}

@widgetbook.UseCase(
  name: 'Map placeholder',
  type: EventPinsMap,
  path: '[Events]/Map',
)
Widget eventPinsMapState(BuildContext context) {
  return SizedBox(
    height: 360,
    child: EventPinsMap(
      items: _eventMapItems(),
      initialCenter: _mapCenter,
      selectedEventId: _event.id,
      selectedEventCenter: _mapCenter,
      enableNetworkTiles: false,
      userLocation: _mapCenter,
      distanceRingRadiusKm: 3,
      onEventSelected: (_) {},
    ),
  );
}

@widgetbook.UseCase(
  name: 'Pins placeholder',
  type: EventPinsMapPlaceholder,
  path: '[Events]/Map',
)
Widget eventPinsMapPlaceholderState(BuildContext context) {
  return SizedBox(
    height: 360,
    child: EventPinsMapPlaceholder(
      items: _eventMapItems(),
      selectedEventId: _event.id,
      markerIcon: CatchIcons.running,
      userLocation: _mapCenter,
      distanceRingRadiusKm: 3,
      onEventSelected: (_) {},
    ),
  );
}

@widgetbook.UseCase(
  name: 'Overlay controls',
  type: MapOverlayControls,
  path: '[Events]/Map',
)
Widget mapOverlayControlsState(BuildContext context) {
  return SizedBox(
    height: 180,
    child: Stack(
      children: [
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: CatchTokens.of(context).primarySoft,
            ),
          ),
        ),
        MapOverlayControls(
          trailing: Icon(CatchIcons.locationOnOutlined),
          below: const MapPinTile(
            startingPoint: _mapCenter,
            selectedLabel: 'Carter Road Jetty',
            onTap: _noop,
          ),
          onBack: _noop,
        ),
      ],
    ),
  );
}

@widgetbook.UseCase(
  name: 'Pin tile states',
  type: MapPinTile,
  path: '[Events]/Map',
)
Widget mapPinTileStates(BuildContext context) {
  return const _CatalogScreen(
    title: 'MapPinTile',
    catalogId: 'control.events.map_pin',
    children: [
      _StateCard(
        label: 'selected',
        child: MapPinTile(
          startingPoint: _mapCenter,
          selectedLabel: 'Carter Road Jetty',
          onTap: _noop,
        ),
      ),
      _StateCard(
        label: 'empty',
        child: MapPinTile(startingPoint: null, onTap: _noop),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Agenda list',
  type: EventAgendaList,
  path: '[Events]/Lists',
)
Widget eventAgendaListState(BuildContext context) {
  return SizedBox(
    height: 620,
    child: EventAgendaList(
      events: _agendaEvents(),
      today: DateUtils.dateOnly(_now),
      showClubName: true,
      clubNameBuilder: (_) => _club.name,
      statusBuilder: (_) => EventTileStatus.saved,
      badgeLabel: 'SAVED',
      onEventSelected: (_) {},
    ),
  );
}

@widgetbook.UseCase(
  name: 'Agenda sliver list',
  type: EventAgendaSliverList,
  path: '[Events]/Lists',
)
Widget eventAgendaSliverListState(BuildContext context) {
  return SizedBox(
    height: 620,
    child: CustomScrollView(
      slivers: [
        EventAgendaSliverList(
          events: _agendaEvents(),
          today: DateUtils.dateOnly(_now),
          showClubName: true,
          clubNameBuilder: (_) => _club.name,
          badgeLabel: 'OPEN',
          onEventSelected: (_) {},
        ),
      ],
    ),
  );
}

@widgetbook.UseCase(
  name: 'Agenda day group',
  type: AgendaDayGroup,
  path: '[Events]/Lists',
)
Widget eventAgendaDayGroupState(BuildContext context) {
  return Padding(
    padding: CatchInsets.pageBody,
    child: AgendaDayGroup(
      date: DateUtils.dateOnly(_event.startTime),
      today: DateUtils.dateOnly(_now),
      events: [
        _event,
        _eventDetailEvent(
          id: 'widgetbook-event-agenda-day-dinner',
          activityKind: ActivityKind.dinner,
          startTime: _event.startTime.add(const Duration(hours: 2)),
          capacityLimit: 10,
          bookedCount: 8,
          priceInPaise: 180000,
        ),
      ],
      onEventSelected: (_) {},
      badgeLabel: 'OPEN',
      badgeLabelBuilder: null,
      clubNameBuilder: (_) => _club.name,
      statusBuilder: (_) => EventTileStatus.saved,
      showClubName: true,
      dayLabelBottomGap: CatchLayout.agendaDayLabelBottomGap,
      itemGap: CatchLayout.agendaItemGap,
    ),
  );
}

@widgetbook.UseCase(
  name: 'Agenda skeleton',
  type: EventAgendaSliverSkeleton,
  path: '[Events]/Lists',
)
Widget eventAgendaSliverSkeletonState(BuildContext context) {
  return const SizedBox(
    height: 520,
    child: CustomScrollView(slivers: [EventAgendaSliverSkeleton()]),
  );
}

@widgetbook.UseCase(
  name: 'Agenda tile skeleton',
  type: EventAgendaTileSkeleton,
  path: '[Events]/Lists',
)
Widget eventAgendaTileSkeletonState(BuildContext context) {
  return const Padding(
    padding: CatchInsets.pageBody,
    child: EventAgendaTileSkeleton(),
  );
}

@widgetbook.UseCase(
  name: 'Agenda tile',
  type: EventAgendaTile,
  path: '[Events]/Tiles',
)
Widget eventAgendaTileState(BuildContext context) {
  return EventAgendaTile(
    data: _eventTileData(_event, status: EventTileStatus.joined),
    showClubName: true,
    badgeLabel: 'JOINED',
    onTap: _noop,
  );
}

@widgetbook.UseCase(
  name: 'Action card',
  type: EventActionCard,
  path: '[Events]/Tiles',
)
Widget eventActionCardState(BuildContext context) {
  return EventActionCard(
    event: _event,
    indexLabel: '1',
    badges: [
      EventActionCardBadge(
        label: 'Booked',
        tone: CatchBadgeTone.success,
        icon: CatchIcons.checkCircleRounded,
      ),
    ],
    metaRows: [
      [
        CatchMetaEntry(icon: CatchIcons.scheduleRounded, label: '6:30 AM'),
        CatchMetaEntry(icon: CatchIcons.locationOnOutlined, label: 'Bandra'),
      ],
    ],
    actions: [
      EventActionCardAction(
        label: 'Open event',
        icon: CatchIcons.calendarMonthOutlined,
        onPressed: _noop,
        variant: CatchButtonVariant.primary,
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Action card header',
  type: EventActionCardHeader,
  path: '[Events]/Tiles',
)
Widget eventActionCardHeaderState(BuildContext context) {
  return Padding(
    padding: CatchInsets.contentDense,
    child: EventActionCardHeader(
      indexLabel: '1 / 3',
      badges: [
        EventActionCardBadge(
          label: 'Booked',
          tone: CatchBadgeTone.success,
          icon: CatchIcons.checkCircleRounded,
        ),
        EventActionCardBadge(label: 'Host pick', tone: CatchBadgeTone.brand),
      ],
    ),
  );
}

@widgetbook.UseCase(
  name: 'Action card actions',
  type: EventActionCardActions,
  path: '[Events]/Tiles',
)
Widget eventActionCardActionsState(BuildContext context) {
  return Padding(
    padding: CatchInsets.contentDense,
    child: EventActionCardActions(
      actions: [
        EventActionCardAction(
          label: 'Open event',
          icon: CatchIcons.calendarMonthOutlined,
          onPressed: _noop,
          variant: CatchButtonVariant.primary,
        ),
        EventActionCardAction(
          label: 'Add to calendar',
          icon: CatchIcons.eventAvailableOutlined,
          onPressed: _noop,
        ),
      ],
    ),
  );
}

@widgetbook.UseCase(
  name: 'Compact row',
  type: EventCompactRow,
  path: '[Events]/Tiles',
)
Widget eventCompactRowState(BuildContext context) {
  return EventCompactRow(event: _event, statusLabel: 'Saved', onTap: _noop);
}

@widgetbook.UseCase(
  name: 'Compact date pill',
  type: EventCompactDatePill,
  path: '[Events]/Tiles',
)
Widget eventCompactDatePillState(BuildContext context) {
  return EventCompactDatePill(
    date: _event.startTime,
    accent: CatchTokens.of(context).accent,
  );
}

@widgetbook.UseCase(
  name: 'Date rail card',
  type: EventDateRailCard,
  path: '[Events]/Tiles',
)
Widget eventDateRailCardState(BuildContext context) {
  return EventDateRailCard(
    event: _event,
    kicker: _club.name,
    statusLabel: 'Open',
    onTap: _noop,
  );
}

@widgetbook.UseCase(name: 'Date rail', type: DateRail, path: '[Events]/Tiles')
Widget eventDateRailState(BuildContext context) {
  return DateRail(
    startTime: _event.startTime,
    color: CatchTokens.of(context).accent,
  );
}

@widgetbook.UseCase(
  name: 'Perforation line',
  type: PerforationLine,
  path: '[Events]/Tiles',
)
Widget eventPerforationLineState(BuildContext context) {
  return SizedBox(
    height: 120,
    child: PerforationLine(
      color: CatchTokens.of(context).ticketPerforationLine,
    ),
  );
}

@widgetbook.UseCase(
  name: 'Date marker states',
  type: EventDateMarker,
  path: '[Events]/Calendar',
)
Widget eventDateMarkerStates(BuildContext context) {
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      EventDateMarker(
        date: _event.startTime,
        active: true,
        hasEvent: true,
        today: true,
        onTap: _noop,
      ),
      gapW12,
      EventDateMarker(
        date: _event.startTime.add(const Duration(days: 1)),
        active: false,
        hasEvent: true,
        layout: EventDateMarkerLayout.monthGrid,
        onTap: _noop,
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Week marker states',
  type: WeekMarker,
  path: '[Events]/Calendar',
)
Widget eventWeekMarkerStates(BuildContext context) {
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      WeekMarker(
        date: _event.startTime,
        active: true,
        hasEvent: true,
        onTap: _noop,
      ),
      gapW12,
      WeekMarker(
        date: _event.startTime.add(const Duration(days: 1)),
        active: false,
        hasEvent: true,
        onTap: _noop,
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Month marker states',
  type: MonthMarker,
  path: '[Events]/Calendar',
)
Widget eventMonthMarkerStates(BuildContext context) {
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      MonthMarker(
        date: _event.startTime,
        active: true,
        today: true,
        hasEvent: true,
        enabled: true,
        onTap: _noop,
      ),
      gapW12,
      MonthMarker(
        date: _event.startTime.add(const Duration(days: 1)),
        active: false,
        today: false,
        hasEvent: true,
        enabled: true,
        onTap: _noop,
      ),
      gapW12,
      MonthMarker(
        date: _event.startTime.add(const Duration(days: 2)),
        active: false,
        today: false,
        hasEvent: false,
        enabled: false,
        onTap: _noop,
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Visual atom clock',
  type: EventClockMark,
  path: '[Events]/Tiles',
)
Widget eventClockMarkState(BuildContext context) {
  return EventClockMark(
    accent: CatchTokens.of(context).primary,
    time: TimeOfDay.fromDateTime(_event.startTime),
    size: 42,
    centerDotRadius: 2,
  );
}

@widgetbook.UseCase(
  name: 'Visual atom status',
  type: EventStatusPill,
  path: '[Events]/Tiles',
)
Widget eventStatusPillState(BuildContext context) {
  final t = CatchTokens.of(context);
  return Wrap(
    spacing: CatchSpacing.s2,
    children: [
      EventStatusPill(label: 'Open', color: t.primary),
      EventStatusPill(
        label: 'Booked',
        color: t.success,
        tone: EventStatusPillTone.dark,
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Event photo header',
  type: EventPhotoHeader,
  path: '[Event Detail]/Sections',
)
Widget eventPhotoHeaderState(BuildContext context) {
  return SizedBox(height: 240, child: EventPhotoHeader(event: _event));
}

@widgetbook.UseCase(
  name: 'Event stats',
  type: EventStatsGrid,
  path: '[Event Detail]/Sections',
)
Widget eventStatsGridState(BuildContext context) {
  return EventStatsGrid(event: _event);
}

@widgetbook.UseCase(
  name: 'Requirements',
  type: RequirementsRow,
  path: '[Event Detail]/Sections',
)
Widget requirementsRowState(BuildContext context) {
  return RequirementsRow(
    event: _event.copyWith(
      constraints: _event.constraints.copyWith(minAge: 24, maxAge: 36),
    ),
  );
}

@widgetbook.UseCase(
  name: 'Guest who is going',
  type: GuestWhoIsGoing,
  path: '[Event Detail]/Sections',
)
Widget eventDetailGuestWhoIsGoingState(BuildContext context) {
  return const Padding(
    padding: CatchInsets.contentDense,
    child: GuestWhoIsGoing(),
  );
}

@widgetbook.UseCase(
  name: 'Hype avatars',
  type: EventHypeAvatarStack,
  path: '[Event Detail]/Sections',
)
Widget eventHypeAvatarStackState(BuildContext context) {
  return EventHypeAvatarStack(
    eventId: _event.id,
    totalCount: 12,
    viewerInterestedInGenders: _viewer.interestedInGenders,
    avatarItems: _avatarItems,
    obscured: false,
    showOverflowCount: true,
    activityKind: _event.activityKind,
  );
}

@widgetbook.UseCase(
  name: "Who's going states",
  type: WhoIsGoing,
  path: '[Event Detail]/Sections',
)
Widget whoIsGoingStates(BuildContext context) {
  return _CatalogScreen(
    title: 'WhoIsGoing',
    catalogId: 'section.event.who_is_going.roster',
    children: [
      _StateCard(
        label: 'visible roster',
        child: _EventScope(
          event: _event,
          roster: _roster(),
          avatarItems: _avatarItems,
          child: WhoIsGoing(event: _event, userProfile: _viewer),
        ),
      ),
      _StateCard(
        label: 'empty roster',
        child: _EventScope(
          event: _emptyEvent,
          roster: EventParticipationRoster.empty(),
          child: WhoIsGoing(event: _emptyEvent, userProfile: _viewer),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: "Who's going content",
  type: WhoIsGoingContent,
  path: '[Event Detail]/Sections',
)
Widget whoIsGoingContentStates(BuildContext context) {
  return _CatalogScreen(
    title: 'WhoIsGoingContent',
    catalogId: 'section.event.who_is_going.content',
    children: [
      _StateCard(
        label: 'upcoming roster',
        child: WhoIsGoingContent(
          event: _event,
          roster: _roster(),
          avatarItems: _avatarItems,
          userProfile: _viewer,
        ),
      ),
      _StateCard(
        label: 'empty roster',
        child: WhoIsGoingContent(
          event: _emptyEvent,
          roster: EventParticipationRoster.empty(),
          userProfile: _viewer,
        ),
      ),
      _StateCard(
        label: 'post-event closed window',
        child: WhoIsGoingContent(
          event: _pastEvent,
          roster: _roster(event: _pastEvent, count: 5),
          avatarItems: _avatarItems.take(5).toList(growable: false),
          userProfile: _viewer,
          showHeader: false,
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Empty roster message',
  type: EmptyRosterMessage,
  path: '[Event Detail]/Sections',
)
Widget emptyRosterMessageStates(BuildContext context) {
  return _CatalogScreen(
    title: 'EmptyRosterMessage',
    catalogId: 'section.event.who_is_going.empty_roster_message',
    children: [
      _StateCard(
        label: 'upcoming',
        child: const EmptyRosterMessage(
          title: 'No attendees yet',
          message: 'Be the first to book this event.',
        ),
      ),
      _StateCard(
        label: 'surface-styled',
        child: Builder(
          builder: (context) {
            final style = EventDetailSurfaceStyle.dark(CatchTokens.of(context));
            return EmptyRosterMessage(
              title: 'No attendees booked',
              message: 'This event did not have any booked attendees.',
              surfaceStyle: style,
            );
          },
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Swipe window banner',
  type: SwipeWindowBanner,
  path: '[Event Detail]/Sections',
)
Widget swipeWindowBannerStates(BuildContext context) {
  return _CatalogScreen(
    title: 'SwipeWindowBanner',
    catalogId: 'section.event.who_is_going.swipe_window_banner',
    children: [
      _StateCard(
        label: 'locked',
        child: SwipeWindowBanner(
          icon: CatchIcons.lockOutlineRounded,
          message: 'Catches unlock for 24 hours after the event finishes.',
        ),
      ),
      _StateCard(
        label: 'open',
        child: SwipeWindowBanner(
          icon: CatchIcons.favoriteRounded,
          message:
              'The catch window is open for 24 hours after the event finishes.',
        ),
      ),
      _StateCard(
        label: 'surface-styled',
        child: Builder(
          builder: (context) {
            final style = EventDetailSurfaceStyle.dark(CatchTokens.of(context));
            return SwipeWindowBanner(
              icon: CatchIcons.scheduleRounded,
              message: 'The catch window for this event has closed.',
              surfaceStyle: style,
            );
          },
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
    expiresAt: _now.add(const Duration(hours: 5)),
    isDeclining: false,
    onDecline: _noop,
  );
}

@widgetbook.UseCase(
  name: 'Booked leading',
  type: BookedLeading,
  path: '[Event Detail]/Booking Dock',
)
Widget bookedLeadingState(BuildContext context) {
  return const BookedLeading();
}

@widgetbook.UseCase(
  name: 'Attended leading',
  type: AttendedLeading,
  path: '[Event Detail]/Booking Dock',
)
Widget attendedLeadingState(BuildContext context) {
  return const AttendedLeading();
}

class _EventScope extends StatelessWidget {
  const _EventScope({
    required this.event,
    required this.child,
    this.roster,
    this.avatarItems,
    this.plan,
  });

  final Event event;
  final Widget child;
  final EventParticipationRoster? roster;
  final List<CatchPersonAvatarItem>? avatarItems;
  final EventSuccessPlan? plan;

  @override
  Widget build(BuildContext context) {
    final avatarQuery = EventHypeAvatarQuery(
      eventId: event.id,
      viewerInterestedInGenders: _viewer.interestedInGenders,
      limit: 7,
    );
    final avatars = avatarItems;
    return ProviderScope(
      overrides: [
        fetchClubProvider(_clubId).overrideWith((ref) => _club),
        watchEventParticipationRosterProvider(
          event.id,
        ).overrideWith((ref) => Stream.value(roster ?? _roster(event: event))),
        if (avatars != null)
          eventHypeAvatarsProvider(
            avatarQuery,
          ).overrideWith((ref) async => avatars),
        watchEventSuccessPlanProvider(
          event.id,
        ).overrideWith((ref) => Stream.value(plan)),
        paymentRepositoryProvider.overrideWithValue(_FakePaymentRepository()),
      ],
      child: child,
    );
  }
}

class _ReviewsHistoryFrame extends StatelessWidget {
  const _ReviewsHistoryFrame({
    required this.uid,
    required this.user,
    required this.reviews,
    this.events = const AsyncData<List<Event>>([]),
  });

  final String? uid;
  final AsyncValue<UserProfile?> user;
  final AsyncValue<List<Review>> reviews;
  final AsyncValue<List<Event>> events;

  @override
  Widget build(BuildContext context) {
    final effectiveUid = uid;
    final eventIds = _eventIdsFor(reviews.asData?.value ?? const []);

    return ProviderScope(
      overrides: [
        uidProvider.overrideWith((ref) => Stream<String?>.value(effectiveUid)),
        watchUserProfileProvider.overrideWith((ref) => _streamFor(user)),
        if (effectiveUid != null)
          watchReviewsByUserProvider(
            effectiveUid,
          ).overrideWith((ref) => _streamFor(reviews)),
        if (effectiveUid != null && eventIds.isNotEmpty)
          watchEventsByIdsProvider(
            EventsByIdQuery(eventIds),
          ).overrideWith((ref) => _streamFor(events)),
      ],
      child: const ReviewsHistoryScreen(),
    );
  }
}

List<String> _eventIdsFor(List<Review> reviews) {
  final eventIds = <String>{
    for (final review in reviews)
      if (review.eventId != null) review.eventId!,
  };
  return eventIds.toList()..sort();
}

Stream<T> _streamFor<T>(AsyncValue<T> value) {
  return switch (value) {
    AsyncData(:final value) => Stream<T>.value(value),
    AsyncError(:final error, :final stackTrace) => Stream<T>.error(
      error,
      stackTrace,
    ),
    _ => Stream<T>.empty(),
  };
}

class _RouteFrame extends StatelessWidget {
  const _RouteFrame({required this.value, required this.child});

  final AsyncValue<EventDetailViewModel?> value;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final avatarQuery = EventHypeAvatarQuery(
      eventId: _event.id,
      viewerInterestedInGenders: _viewer.interestedInGenders,
      limit: 7,
    );

    return _DeviceFrame(
      child: ProviderScope(
        overrides: [
          eventDetailViewModelProvider(_event.id).overrideWithValue(value),
          fetchClubProvider(_clubId).overrideWith((ref) => _club),
          watchEventParticipationRosterProvider(
            _event.id,
          ).overrideWith((ref) => Stream.value(_roster())),
          eventHypeAvatarsProvider(
            avatarQuery,
          ).overrideWith((ref) async => _avatarItems),
          watchEventSuccessPlanProvider(
            _event.id,
          ).overrideWith((ref) => Stream.value(null)),
          paymentRepositoryProvider.overrideWithValue(
            const _FakePaymentRepository(),
          ),
        ],
        child: child,
      ),
    );
  }
}

class _FakePaymentRepository implements PaymentRepository {
  const _FakePaymentRepository();

  @override
  bool get supportsPaidBookings => true;

  @override
  bool supportsPaidBookingsForCurrency(String currencyCode) => true;

  @override
  Future<void> bookFreeEvent({
    required String eventId,
    String? inviteCode,
    String? inviteLinkId,
  }) async {}

  @override
  Future<PaymentConfirmationData> processPayment({
    required String eventId,
    required String currencyCode,
    required String description,
    required String userName,
    required String userEmail,
    required String userContact,
    String? inviteCode,
    String? inviteLinkId,
  }) async {
    return PaymentConfirmationData(
      paymentId: 'widgetbook-payment',
      orderId: 'widgetbook-order',
      amountInPaise: 0,
      currency: currencyCode,
      eventId: eventId,
    );
  }

  @override
  void dispose() {}
}

class _NoDeviceLocation extends DeviceLocation {
  @override
  Future<LocationCoordinate?> build() async => null;
}

EventDetailViewModel _eventVm(
  Event event, {
  UserProfile? userProfile,
  bool isAuthenticated = true,
  bool isHost = false,
  bool isSaved = true,
  EventParticipation? participation,
}) {
  return EventDetailViewModel(
    event: event,
    userProfile: userProfile ?? (isAuthenticated ? _viewer : null),
    reviews: _reviews,
    isAuthenticated: isAuthenticated,
    isHost: isHost,
    isSaved: isSaved,
    participation: participation,
  );
}

const _mapCenter = LocationCoordinate(19.0676, 72.8227);

List<Event> _agendaEvents() {
  return [
    _event,
    _eventDetailEvent(
      id: 'widgetbook-event-agenda-pickleball',
      activityKind: ActivityKind.pickleball,
      startTime: _event.startTime.add(const Duration(days: 1, hours: 12)),
      bookedCount: 6,
    ),
    _eventDetailEvent(
      id: 'widgetbook-event-agenda-dinner',
      activityKind: ActivityKind.dinner,
      startTime: _event.startTime.add(const Duration(days: 3, hours: 13)),
      capacityLimit: 10,
      bookedCount: 8,
      priceInPaise: 180000,
    ),
    _pastEvent,
  ];
}

EventTileData _eventTileData(
  Event event, {
  EventTileStatus status = EventTileStatus.open,
}) {
  return EventTileData.fromEvent(
    event: event,
    status: status,
    clubName: _club.name,
  );
}

List<EventMapItem> _eventMapItems() {
  final events = _agendaEvents().take(3).toList(growable: false);
  return [
    for (var index = 0; index < events.length; index += 1)
      EventMapItem(
        event: events[index].copyWith(
          startingPointLat: _mapCenter.latitude + (index * 0.006),
          startingPointLng: _mapCenter.longitude + (index * 0.004),
        ),
        status: switch (index) {
          0 => EventTileStatus.joined,
          1 => EventTileStatus.saved,
          _ => EventTileStatus.recommended,
        },
        clubName: _club.name,
      ),
  ];
}

class _CatalogScreen extends StatelessWidget {
  const _CatalogScreen({
    required this.title,
    required this.catalogId,
    required this.children,
  });

  final String title;
  final String catalogId;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Scaffold(
      backgroundColor: t.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: CatchInsets.content,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: CatchTextStyles.titleL(context)),
              gapH4,
              Text(
                catalogId,
                style: CatchTextStyles.monoLabel(context, color: t.ink2),
              ),
              gapH24,
              for (final child in children) ...[child, gapH20],
            ],
          ),
        ),
      ),
    );
  }
}

class _StateCard extends StatelessWidget {
  const _StateCard({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: t.surface,
        border: Border.all(color: t.line),
        borderRadius: BorderRadius.circular(CatchRadius.lg),
      ),
      child: Padding(
        padding: CatchInsets.content,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: CatchTextStyles.sectionTitle(context)),
            gapH12,
            child,
          ],
        ),
      ),
    );
  }
}

class _DeviceFrame extends StatelessWidget {
  const _DeviceFrame({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 390),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: t.surface,
            border: Border.all(color: t.line),
            borderRadius: BorderRadius.circular(CatchRadius.lg),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(CatchRadius.lg),
            child: SizedBox(height: 720, child: child),
          ),
        ),
      ),
    );
  }
}

class _DockFrame extends StatelessWidget {
  const _DockFrame({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 390),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: t.surface,
          border: Border.all(color: t.line),
          borderRadius: BorderRadius.circular(CatchRadius.lg),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(CatchRadius.lg),
          child: child,
        ),
      ),
    );
  }
}

class _SheetFrame extends StatelessWidget {
  const _SheetFrame({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 390),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: t.bg,
            border: Border.all(color: t.line),
            borderRadius: BorderRadius.circular(CatchRadius.lg),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(CatchRadius.lg),
            child: SizedBox(
              height: 560,
              child: Align(alignment: Alignment.bottomCenter, child: child),
            ),
          ),
        ),
      ),
    );
  }
}

class _HiddenSectionState extends StatelessWidget {
  const _HiddenSectionState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return CatchEmptyState(
      title: 'Hidden',
      message: message,
      layout: CatchEmptyStateLayout.inline,
      surface: true,
    );
  }
}

Event _eventDetailEvent({
  String id = 'widgetbook-event-detail',
  ActivityKind activityKind = ActivityKind.socialRun,
  EventPolicyBundle? eventPolicy,
  int capacityLimit = 12,
  int bookedCount = 9,
  int waitlistedCount = 3,
  int priceInPaise = 0,
  DateTime? startTime,
}) {
  final start = startTime ?? DateTime(2026, 6, 24, 6, 30);
  return Event(
    id: id,
    clubId: _clubId,
    startTime: start,
    endTime: start.add(const Duration(hours: 1, minutes: 45)),
    meetingPoint: 'Carter Road Jetty',
    meetingLocation: EventMeetingLocation.legacy(
      name: 'Carter Road Jetty',
      latitude: 19.0676,
      longitude: 72.8227,
      notes: 'Bandra West',
    ),
    eventPhotos: [
      _photo('seaface', 0),
      _photo('coffee', 1),
      _photo('finish', 2),
    ],
    eventFormat: EventFormatSnapshot.fromActivityKind(activityKind),
    distanceKm: activityKind == ActivityKind.socialRun ? 5 : 0,
    pace: PaceLevel.easy,
    capacityLimit: capacityLimit,
    description:
        'An easy social pace along the seafront as the light goes gold, with coffee after for anyone who lingers.',
    priceInPaise: priceInPaise,
    bookedCount: bookedCount,
    waitlistedCount: waitlistedCount,
    eventPolicy:
        eventPolicy ??
        EventPolicyBundle.openEvent(
          capacityLimit: capacityLimit,
          basePriceInPaise: priceInPaise,
        ),
  );
}

EventParticipationRoster _roster({Event? event, int count = 7}) {
  final id = event?.id ?? _event.id;
  return EventParticipationRoster(
    bookedIds: List.generate(count, (index) => '$id-booked-$index'),
    checkedInIds: const [],
    waitlistedIds: const [],
  );
}

UploadedPhoto _photo(String id, int position) {
  return UploadedPhoto.fromUpload(
    url: 'https://example.invalid/widgetbook-event-$id.jpg',
    storagePath: 'widgetbook/events/$id.jpg',
    position: position,
    now: _now.add(Duration(minutes: position)),
  );
}

const _avatarItems = [
  CatchPersonAvatarItem(name: 'Rahul Anand'),
  CatchPersonAvatarItem(name: 'Arjun Iyer'),
  CatchPersonAvatarItem(name: 'Kabir Mehta'),
  CatchPersonAvatarItem(name: 'Dev Shah'),
  CatchPersonAvatarItem(name: 'Aarav Rao'),
  CatchPersonAvatarItem(name: 'Nikhil Menon'),
  CatchPersonAvatarItem(name: 'Ishaan Kapoor'),
];

void _noop() {}

void _noopContext(BuildContext context) {}

void _noopString(String value) {}

void _noopMessageHost(String clubId, String hostUid) {}
