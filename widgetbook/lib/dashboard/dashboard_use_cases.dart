import 'package:catch_dating_app/activity/domain/activity_taxonomy.dart';
import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/clubs/data/club_membership_repository.dart';
import 'package:catch_dating_app/clubs/data/clubs_repository.dart';
import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/clubs/domain/club_membership.dart';
import 'package:catch_dating_app/clubs/data/club_name_lookup.dart';
import 'package:catch_dating_app/core/external_links.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/dashboard/presentation/dashboard_full_view_model.dart';
import 'package:catch_dating_app/dashboard/presentation/dashboard_recommendations_provider.dart';
import 'package:catch_dating_app/dashboard/presentation/dashboard_screen.dart';
import 'package:catch_dating_app/dashboard/presentation/notifications_list_state.dart';
import 'package:catch_dating_app/dashboard/presentation/widgets/activity_section.dart';
import 'package:catch_dating_app/dashboard/presentation/widgets/dashboard_empty.dart';
import 'package:catch_dating_app/dashboard/presentation/widgets/dashboard_full.dart';
import 'package:catch_dating_app/dashboard/presentation/widgets/dashboard_section_state_card.dart';
import 'package:catch_dating_app/dashboard/presentation/widgets/dashboard_sliver_header.dart';
import 'package:catch_dating_app/dashboard/presentation/widgets/empty_hero_card.dart';
import 'package:catch_dating_app/dashboard/presentation/widgets/event_focus_rail.dart';
import 'package:catch_dating_app/dashboard/presentation/widgets/quick_actions.dart';
import 'package:catch_dating_app/dashboard/presentation/widgets/recommend_card.dart';
import 'package:catch_dating_app/dashboard/presentation/widgets/recommendations.dart';
import 'package:catch_dating_app/dashboard/presentation/widgets/stride_card.dart';
import 'package:catch_dating_app/events/data/event_repository.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/domain/event_arrival_action.dart';
import 'package:catch_dating_app/events/data/event_calendar_links.dart';
import 'package:catch_dating_app/health_activity/data/health_activity_repository.dart';
import 'package:catch_dating_app/health_activity/domain/weekly_activity_summary.dart';
import 'package:catch_dating_app/labs/design_fixtures/dashboard_surface_fixtures.dart';
import 'package:catch_dating_app/notifications/data/activity_notification_repository.dart';
import 'package:catch_dating_app/notifications/domain/activity_notification.dart';
import 'package:catch_dating_app/reviews/data/reviews_repository.dart';
import 'package:catch_dating_app/reviews/domain/review.dart';
import 'package:catch_dating_app/user_profile/data/user_profile_repository.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

final _viewer = DashboardSurfaceFixtures.viewer;
final _club = DashboardSurfaceFixtures.club;
final _memberships = DashboardSurfaceFixtures.memberships;
final _nextEvent = DashboardSurfaceFixtures.nextEvent;
final _recommendationEvent = DashboardSurfaceFixtures.recommendationEvent;
final _notifications = DashboardSurfaceFixtures.notifications;
final _strideActions = DashboardStrideSectionActions(
  onRetry: _noopTap,
  onConnect: _noopTap,
  onInstallHealthConnect: _noopTap,
);
final _eventFocusActions = EventFocusActions(
  onViewEvent: (_) => _noopTap(),
  onCheckIn: (_) => _noopTap(),
  onOpenSwipe: (_) => _noopTap(),
  onWriteReview: (_) => _noopTap(),
  onOpenDirections: (_) => _noopTap(),
  onAddToCalendar: (_) => _noopTap(),
  onResetCheckInError: _noopTap,
);
final _dashboardRecommendation = DashboardEventRecommendation(
  event: _recommendationEvent,
  clubName: _club.name,
  reasonLabel: 'Matches your 10K pace',
  score: 0.92,
);

@widgetbook.UseCase(
  name: 'Screen states',
  type: DashboardScreen,
  path: '[P1 product surfaces]/Dashboard home',
)
Widget dashboardScreenStates(BuildContext context) {
  return _DashboardCatalog(
    title: 'DashboardScreen',
    contractId: 'screen.dashboard.home',
    children: [
      _StateCard(
        label: 'profile loading',
        child: _DeviceFrame(
          child: _DashboardRouteScope(
            profileStream: _loadingStream<UserProfile?>(),
            child: const DashboardScreen(),
          ),
        ),
      ),
      _StateCard(
        label: 'profile error',
        child: _DeviceFrame(
          child: _DashboardRouteScope(
            profileStream: _errorStream<UserProfile?>('Profile failed'),
            child: const DashboardScreen(),
          ),
        ),
      ),
      _StateCard(
        label: 'empty start',
        child: const _DeviceFrame(
          child: _DashboardRouteScope(
            signedUpEvents: [],
            memberships: [],
            child: DashboardScreen(),
          ),
        ),
      ),
      _StateCard(
        label: 'memberships loading',
        child: _DeviceFrame(
          child: _DashboardRouteScope(
            membershipsStream: _loadingStream<List<ClubMembership>>(),
            child: const DashboardScreen(),
          ),
        ),
      ),
      _StateCard(
        label: 'memberships error',
        child: _DeviceFrame(
          child: _DashboardRouteScope(
            membershipsStream: _errorStream<List<ClubMembership>>(
              'Memberships failed',
            ),
            child: const DashboardScreen(),
          ),
        ),
      ),
      _StateCard(
        label: 'booked events loading',
        child: _DeviceFrame(
          child: _DashboardRouteScope(
            signedUpEventsStream: _loadingStream<List<Event>>(),
            child: const DashboardScreen(),
          ),
        ),
      ),
      _StateCard(
        label: 'booked events error',
        child: _DeviceFrame(
          child: _DashboardRouteScope(
            signedUpEventsStream: _errorStream<List<Event>>(
              'Booked events failed',
            ),
            child: const DashboardScreen(),
          ),
        ),
      ),
      _StateCard(
        label: 'full dashboard',
        child: const _DeviceFrame(child: _DashboardRouteScope()),
      ),
      _StateCard(
        label: 'notification action no unread',
        child: const _DeviceFrame(
          child: _DashboardRouteScope(
            notificationsValue: AsyncData<List<ActivityNotification>>([]),
          ),
        ),
      ),
      _StateCard(
        label: 'recent activity loading',
        child: const _DeviceFrame(
          child: _DashboardRouteScope(
            attendedEventsValue: AsyncLoading<List<Event>>(),
          ),
        ),
      ),
      _StateCard(
        label: 'activity permission',
        child: _DeviceFrame(
          child: _DashboardRouteScope(
            weeklyActivityValue: AsyncData<WeeklyActivitySnapshot>(
              DashboardSurfaceFixtures.permissionWeeklyActivity,
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'recommendations loading',
        child: const _DeviceFrame(
          child: _DashboardRouteScope(
            recommendationsValue:
                AsyncLoading<List<DashboardEventRecommendationCandidate>>(),
          ),
        ),
      ),
      _StateCard(
        label: 'recommendations error',
        child: _DeviceFrame(
          child: _DashboardRouteScope(
            recommendationsValue:
                AsyncError<List<DashboardEventRecommendationCandidate>>(
                  StateError('Recommendations failed'),
                  StackTrace.empty,
                ),
          ),
        ),
      ),
      _StateCard(
        label: 'text scale 2.0',
        child: const _DeviceFrame(
          child: _MediaOverride(
            textScaler: TextScaler.linear(2),
            child: _DashboardRouteScope(),
          ),
        ),
      ),
      _StateCard(
        label: 'reduced motion',
        child: const _DeviceFrame(
          child: _MediaOverride(
            disableAnimations: true,
            child: _DashboardRouteScope(),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Review states',
  type: DashboardStrideSection,
  path: '[P1 product surfaces]/Dashboard primitives',
)
Widget dashboardStrideSectionReviewStates(BuildContext context) {
  final referenceDate = DashboardSurfaceFixtures.now;

  return _DashboardCatalog(
    title: 'DashboardStrideSection',
    contractId: 'dashboard.primitives.stride_section',
    children: [
      _StateCard(
        label: 'connected activity',
        child: _DashboardPrimitiveFrame(
          child: DashboardStrideSection(
            section: DashboardSectionModel.data(
              DashboardSurfaceFixtures.connectedWeeklyActivity,
            ),
            actions: _strideActions,
          ),
        ),
      ),
      _StateCard(
        label: 'loading',
        child: _DashboardPrimitiveFrame(
          child: DashboardStrideSection(
            section: const DashboardSectionModel.loading(
              'Loading your weekly activity...',
            ),
            actions: _strideActions,
          ),
        ),
      ),
      _StateCard(
        label: 'error with retry',
        child: _DashboardPrimitiveFrame(
          child: DashboardStrideSection(
            section: DashboardSectionModel.error(
              'Unable to load your weekly activity.',
              error: StateError('Health activity unavailable'),
            ),
            actions: _strideActions,
          ),
        ),
      ),
      _StateCard(
        label: 'permission action',
        child: _DashboardPrimitiveFrame(
          child: DashboardStrideSection(
            section: DashboardSectionModel.data(
              WeeklyActivitySnapshot.permissionRequired(
                referenceDate: referenceDate,
                platformLabel: 'Apple Health',
              ),
            ),
            actions: _strideActions,
          ),
        ),
      ),
      _StateCard(
        label: 'connect pending',
        child: _DashboardPrimitiveFrame(
          child: DashboardStrideSection(
            section: DashboardSectionModel.data(
              WeeklyActivitySnapshot.permissionRequired(
                referenceDate: referenceDate,
                platformLabel: 'Apple Health',
              ),
            ),
            actions: _strideActions,
            actionState: const DashboardStrideActionState(isConnecting: true),
          ),
        ),
      ),
      _StateCard(
        label: 'health connect install',
        child: _DashboardPrimitiveFrame(
          child: DashboardStrideSection(
            section: DashboardSectionModel.data(
              WeeklyActivitySnapshot.needsHealthConnect(
                referenceDate: referenceDate,
              ),
            ),
            actions: _strideActions,
          ),
        ),
      ),
      _StateCard(
        label: 'install pending',
        child: _DashboardPrimitiveFrame(
          child: DashboardStrideSection(
            section: DashboardSectionModel.data(
              WeeklyActivitySnapshot.needsHealthConnect(
                referenceDate: referenceDate,
              ),
            ),
            actions: _strideActions,
            actionState: const DashboardStrideActionState(
              isInstallingHealthConnect: true,
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'connected empty week',
        child: _DashboardPrimitiveFrame(
          child: DashboardStrideSection(
            section: DashboardSectionModel.data(
              WeeklyActivitySnapshot.connected(
                referenceDate: referenceDate,
                platformLabel: 'Apple Health',
                activities: const [],
              ),
            ),
            actions: _strideActions,
          ),
        ),
      ),
      _StateCard(
        label: 'unsupported long copy',
        child: _DashboardPrimitiveFrame(
          child: DashboardStrideSection(
            section: DashboardSectionModel.data(
              WeeklyActivitySnapshot.unsupported(
                referenceDate: referenceDate,
                message:
                    'Activity sync is available from Apple Health and Health Connect; Catch still shows check-ins after attended events are verified.',
              ),
            ),
            actions: _strideActions,
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Review states',
  type: RecommendCard,
  path: '[P1 product surfaces]/Dashboard primitives',
)
Widget dashboardRecommendCardReviewStates(BuildContext context) {
  final soonEvent = _recommendationVariant(
    id: 'widgetbook-recommend-soon-free',
    startsIn: const Duration(hours: 3, minutes: 20),
    bookedCount: 11,
    capacityLimit: 12,
    priceInPaise: 0,
  );
  final dinnerEvent = _recommendationVariant(
    id: 'widgetbook-recommend-dinner-paid',
    startsIn: const Duration(days: 2, hours: 5),
    activityKind: ActivityKind.dinner,
    meetingPoint: 'The Table, Colaba',
    distanceKm: 0,
    pace: PaceLevel.easy,
    bookedCount: 8,
    capacityLimit: 8,
    waitlistedCount: 5,
    priceInPaise: 220000,
  );
  final longCopyEvent = _recommendationVariant(
    id: 'widgetbook-recommend-long-copy',
    startsIn: const Duration(days: 5, hours: 6),
    meetingPoint: 'Mahalaxmi Race Course north gate beside the main paddock',
    bookedCount: 27,
    capacityLimit: 32,
    priceInPaise: 15000,
  );

  return _DashboardCatalog(
    title: 'RecommendCard',
    contractId: 'dashboard.primitives.recommend_card',
    children: [
      _StateCard(
        label: 'ranked recommendation',
        child: _DashboardPrimitiveFrame(
          child: IgnorePointer(
            child: RecommendCard.fromRecommendation(
              recommendation: DashboardEventRecommendation(
                event: _recommendationEvent,
                clubName: _club.name,
                reasonLabel: 'Matches your 10K pace',
                score: 0.92,
              ),
              width: 340,
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'free event soon',
        child: _DashboardPrimitiveFrame(
          child: IgnorePointer(
            child: RecommendCard(
              event: soonEvent,
              clubName: _club.name,
              reasonLabel: 'Almost full near you',
              width: 340,
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'paid full event',
        child: _DashboardPrimitiveFrame(
          child: IgnorePointer(
            child: RecommendCard(
              event: dinnerEvent,
              clubName: 'Colaba Dinner Club',
              reasonLabel: 'Popular with your clubs',
              width: 340,
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'event fallback factory',
        child: _DashboardPrimitiveFrame(
          child: IgnorePointer(
            child: RecommendCard.fromEvent(event: soonEvent, width: 340),
          ),
        ),
      ),
      _StateCard(
        label: 'long venue and reason',
        child: _DashboardPrimitiveFrame(
          child: IgnorePointer(
            child: RecommendCard(
              event: longCopyEvent,
              clubName: 'Mumbai Long Run Collective and Coffee Society',
              reasonLabel: 'Because you saved paced social runs this week',
              width: 340,
            ),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Signed-out state',
  type: ActivitySignedOutState,
  path: '[P1 product surfaces]/Dashboard activity',
)
Widget dashboardActivitySignedOutStateReview(BuildContext context) {
  return const _DashboardCatalog(
    title: 'ActivitySignedOutState',
    contractId: 'dashboard.activity.signed_out',
    children: [
      _StateCard(
        label: 'signed out',
        child: _DashboardPrimitiveFrame(child: ActivitySignedOutState()),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Grouped rows',
  type: NotificationDayGroups,
  path: '[P1 product surfaces]/Dashboard activity',
)
Widget dashboardNotificationDayGroupsReview(BuildContext context) {
  return _DashboardCatalog(
    title: 'NotificationDayGroups',
    contractId: 'dashboard.activity.day_groups',
    children: [
      _StateCard(
        label: 'today and earlier',
        child: _DashboardPrimitiveFrame(
          child: NotificationDayGroups(groups: _notificationDayGroups()),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Grouped row content',
  type: NotificationGroupWidget,
  path: '[P1 product surfaces]/Dashboard activity',
)
Widget dashboardNotificationGroupWidgetReview(BuildContext context) {
  final rows = _notificationDayGroups().first.rows;
  return _DashboardCatalog(
    title: 'NotificationGroupWidget',
    contractId: 'dashboard.activity.notification_group',
    children: [
      _StateCard(
        label: 'mixed read state',
        child: _DashboardPrimitiveFrame(
          child: NotificationGroupWidget(rows: rows),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Skeleton states',
  type: ActivitySectionSkeleton,
  path: '[P1 product surfaces]/Dashboard activity',
)
Widget dashboardActivitySectionSkeletonReview(BuildContext context) {
  return const _DashboardCatalog(
    title: 'ActivitySectionSkeleton',
    contractId: 'dashboard.activity.skeleton',
    children: [
      _StateCard(
        label: 'compact loading',
        child: _DashboardPrimitiveFrame(
          child: ActivitySectionSkeleton(count: 2),
        ),
      ),
      _StateCard(
        label: 'full loading',
        child: _DashboardPrimitiveFrame(child: ActivitySectionSkeleton()),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Row skeleton states',
  type: NotificationRowSkeleton,
  path: '[P1 product surfaces]/Dashboard activity',
)
Widget dashboardNotificationRowSkeletonReview(BuildContext context) {
  return const _DashboardCatalog(
    title: 'NotificationRowSkeleton',
    contractId: 'dashboard.activity.notification_row_skeleton',
    children: [
      _StateCard(
        label: 'first row',
        child: _DashboardPrimitiveFrame(
          child: NotificationRowSkeleton(divider: false),
        ),
      ),
      _StateCard(
        label: 'divided row',
        child: _DashboardPrimitiveFrame(
          child: NotificationRowSkeleton(divider: true),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Empty home sliver',
  type: DashboardEmptySliverBody,
  path: '[P1 product surfaces]/Dashboard home',
)
Widget dashboardEmptySliverBodyReview(BuildContext context) {
  return const _DashboardCatalog(
    title: 'DashboardEmptySliverBody',
    contractId: 'dashboard.home.empty_sliver',
    children: [
      _StateCard(
        label: 'first event education',
        child: _DeviceFrame(
          child: CustomScrollView(slivers: [DashboardEmptySliverBody()]),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Followed clubs skeleton',
  type: FollowedClubsRailSkeleton,
  path: '[P1 product surfaces]/Dashboard home',
)
Widget dashboardFollowedClubsRailSkeletonReview(BuildContext context) {
  return const _DashboardCatalog(
    title: 'FollowedClubsRailSkeleton',
    contractId: 'dashboard.home.followed_clubs_skeleton',
    children: [
      _StateCard(
        label: 'loading clubs',
        child: _DashboardPrimitiveFrame(child: FollowedClubsRailSkeleton()),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Full home',
  type: DashboardFull,
  path: '[P1 product surfaces]/Dashboard home',
)
Widget dashboardFullReview(BuildContext context) {
  return _DashboardCatalog(
    title: 'DashboardFull',
    contractId: 'dashboard.home.full',
    children: [
      _StateCard(
        label: 'booked event with recommendations',
        child: _DeviceFrame(
          child: _DashboardRouteScope(
            child: DashboardFull(
              user: _viewer,
              signedUpEvents: [_nextEvent],
              followedClubIds: const [],
            ),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Full sliver body',
  type: DashboardFullSliverBody,
  path: '[P1 product surfaces]/Dashboard home',
)
Widget dashboardFullSliverBodyReview(BuildContext context) {
  return _DashboardCatalog(
    title: 'DashboardFullSliverBody',
    contractId: 'dashboard.home.full_sliver_body',
    children: [
      _StateCard(
        label: 'body content',
        child: _DeviceFrame(
          child: _DashboardRouteScope(
            child: CustomScrollView(
              slivers: [
                DashboardFullSliverBody(
                  viewModel: _dashboardFullViewModel(),
                  user: _viewer,
                  followedClubIds: const [],
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
  name: 'Header content',
  type: DashboardHeaderContent,
  path: '[P1 product surfaces]/Dashboard home',
)
Widget dashboardHeaderContentReview(BuildContext context) {
  return _DashboardCatalog(
    title: 'DashboardHeaderContent',
    contractId: 'dashboard.home.header_content',
    children: [
      _StateCard(
        label: 'copy only',
        child: const _DashboardPrimitiveFrame(
          child: DashboardHeaderContent(
            eyebrow: 'TODAY · MUMBAI',
            title: 'Good evening, Subrath',
            actions: [],
          ),
        ),
      ),
      _StateCard(
        label: 'notification action',
        child: _DashboardPrimitiveFrame(
          child: DashboardHeaderContent(
            eyebrow: 'THIS WEEK',
            title: 'Three plans ready',
            actions: [
              DashboardNotificationBellButton(
                unreadCount: 3,
                onPressed: _noopTap,
              ),
            ],
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Bell states',
  type: DashboardNotificationBellButton,
  path: '[P1 product surfaces]/Dashboard primitives',
)
Widget dashboardNotificationBellButtonReviewStates(BuildContext context) {
  return _DashboardCatalog(
    title: 'DashboardNotificationBellButton',
    contractId: 'dashboard.primitives.notification_bell',
    children: [
      _StateCard(
        label: 'no unread',
        child: _DashboardPrimitiveFrame(
          child: DashboardNotificationBellButton(
            unreadCount: 0,
            onPressed: _noopTap,
          ),
        ),
      ),
      _StateCard(
        label: 'unread count',
        child: _DashboardPrimitiveFrame(
          child: DashboardNotificationBellButton(
            unreadCount: 3,
            onPressed: _noopTap,
          ),
        ),
      ),
      _StateCard(
        label: 'overflow badge',
        child: _DashboardPrimitiveFrame(
          child: DashboardNotificationBellButton(
            unreadCount: 124,
            onPressed: _noopTap,
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Review states',
  type: DashboardSectionStateCard,
  path: '[P1 product surfaces]/Dashboard primitives',
)
Widget dashboardSectionStateCardReviewStates(BuildContext context) {
  return const _DashboardCatalog(
    title: 'DashboardSectionStateCard',
    contractId: 'dashboard.primitives.section_state_card',
    children: [
      _StateCard(
        label: 'loading',
        child: _DashboardPrimitiveFrame(
          child: DashboardSectionStateCard(
            message: 'Loading recommended events...',
            isLoading: true,
          ),
        ),
      ),
      _StateCard(
        label: 'message',
        child: _DashboardPrimitiveFrame(
          child: DashboardSectionStateCard(
            message: 'This section is temporarily unavailable.',
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Hero states',
  type: EmptyHeroCard,
  path: '[P1 product surfaces]/Dashboard home',
)
Widget dashboardEmptyHeroCardReviewStates(BuildContext context) {
  return const _DashboardCatalog(
    title: 'EmptyHeroCard',
    contractId: 'dashboard.home.empty_hero',
    children: [
      _StateCard(
        label: 'card',
        child: _DashboardPrimitiveFrame(child: EmptyHeroCard()),
      ),
      _StateCard(
        label: 'full bleed',
        child: _DashboardPrimitiveFrame(child: EmptyHeroCard(fullBleed: true)),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Hero content states',
  type: EmptyHeroContent,
  path: '[P1 product surfaces]/Dashboard home',
)
Widget dashboardEmptyHeroContentReviewStates(BuildContext context) {
  final t = CatchTokens.of(context);
  Widget frame({required Widget child}) {
    return _DashboardPrimitiveFrame(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: t.heroGrad,
          borderRadius: BorderRadius.circular(CatchRadius.heroCard),
        ),
        child: Padding(padding: CatchInsets.contentRelaxed, child: child),
      ),
    );
  }

  return _DashboardCatalog(
    title: 'EmptyHeroContent',
    contractId: 'dashboard.home.empty_hero_content',
    children: [
      _StateCard(
        label: 'card copy',
        child: frame(child: EmptyHeroContent(onFindEvent: _noopTap)),
      ),
      _StateCard(
        label: 'welcome eyebrow',
        child: frame(
          child: EmptyHeroContent(
            onFindEvent: _noopTap,
            showWelcomeEyebrow: true,
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Rail states',
  type: EventFocusRail,
  path: '[P1 product surfaces]/Dashboard home',
)
Widget dashboardEventFocusRailReviewStates(BuildContext context) {
  return _DashboardCatalog(
    title: 'EventFocusRail',
    contractId: 'dashboard.home.event_focus_rail',
    children: [
      _StateCard(
        label: 'upcoming event',
        child: _DashboardPrimitiveFrame(
          child: EventFocusRail(
            upcomingEvents: [_nextEvent],
            actions: _eventFocusActions,
            clubNameBuilder: (_) => _club.name,
          ),
        ),
      ),
      _StateCard(
        label: 'check-in pending',
        child: _DashboardPrimitiveFrame(
          child: EventFocusRail(
            upcomingEvents: [_nextEvent],
            arrivalAction: EventArrivalAction(
              kind: EventArrivalActionKind.selfCheckIn,
              event: _nextEvent,
            ),
            checkInState: const EventFocusCheckInState(isPending: true),
            actions: _eventFocusActions,
            clubNameBuilder: (_) => _club.name,
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Card states',
  type: EventFocusCard,
  path: '[P1 product surfaces]/Dashboard home',
)
Widget dashboardEventFocusCardReviewStates(BuildContext context) {
  return _DashboardCatalog(
    title: 'EventFocusCard',
    contractId: 'dashboard.home.event_focus_card',
    children: [
      _StateCard(
        label: 'upcoming',
        child: _DashboardPrimitiveFrame(
          child: EventFocusCard(
            item: EventFocusItem(
              event: _nextEvent,
              kind: EventFocusKind.upcoming,
              clubName: _club.name,
            ),
            cardIndex: 0,
            cardCount: 3,
            checkInState: EventFocusCheckInState.idle,
            onActionPressed: (_) {},
          ),
        ),
      ),
      _StateCard(
        label: 'check-in pending',
        child: _DashboardPrimitiveFrame(
          child: EventFocusCard(
            item: EventFocusItem(
              event: _nextEvent,
              kind: EventFocusKind.checkIn,
              clubName: _club.name,
            ),
            cardIndex: 1,
            cardCount: 3,
            checkInState: const EventFocusCheckInState(isPending: true),
            onActionPressed: (_) {},
          ),
        ),
      ),
      _StateCard(
        label: 'after event actions',
        child: _DashboardPrimitiveFrame(
          child: EventFocusCard(
            item: EventFocusItem(
              event: DashboardSurfaceFixtures.attendedEvent,
              kind: EventFocusKind.afterEvent,
              clubName: _club.name,
              canSwipe: true,
              needsReview: true,
            ),
            cardIndex: 2,
            cardCount: 3,
            checkInState: EventFocusCheckInState.idle,
            onActionPressed: (_) {},
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Page indicator states',
  type: EventFocusPageIndicator,
  path: '[P1 product surfaces]/Dashboard home',
)
Widget dashboardEventFocusPageIndicatorReviewStates(BuildContext context) {
  return const _DashboardCatalog(
    title: 'EventFocusPageIndicator',
    contractId: 'dashboard.home.event_focus_page_indicator',
    children: [
      _StateCard(
        label: 'first of three',
        child: _DashboardPrimitiveFrame(
          child: EventFocusPageIndicator(selectedIndex: 0, itemCount: 3),
        ),
      ),
      _StateCard(
        label: 'middle of three',
        child: _DashboardPrimitiveFrame(
          child: EventFocusPageIndicator(selectedIndex: 1, itemCount: 3),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Tile states',
  type: DashboardQuickActionTile,
  path: '[P1 product surfaces]/Dashboard primitives',
)
Widget dashboardQuickActionTileReviewStates(BuildContext context) {
  return _DashboardCatalog(
    title: 'DashboardQuickActionTile',
    contractId: 'dashboard.primitives.quick_action_tile',
    children: [
      _StateCard(
        label: 'enabled',
        child: _DashboardPrimitiveFrame(
          maxWidth: 180,
          child: DashboardQuickActionTile(
            action: DashboardQuickAction(
              icon: CatchIcons.calendarMonthOutlined,
              label: 'Calendar',
              onPressed: _noopTap,
            ),
            onTap: _noopTap,
          ),
        ),
      ),
      _StateCard(
        label: 'disabled',
        child: _DashboardPrimitiveFrame(
          maxWidth: 180,
          child: DashboardQuickActionTile(
            action: DashboardQuickAction(
              icon: CatchIcons.bookmarkBorderRounded,
              label: 'Saved events',
            ),
            onTap: null,
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Recommendation rail',
  type: Recommendations,
  path: '[P1 product surfaces]/Dashboard home',
)
Widget dashboardRecommendationsReview(BuildContext context) {
  return _DashboardCatalog(
    title: 'Recommendations',
    contractId: 'dashboard.home.recommendations',
    children: [
      _StateCard(
        label: 'ranked events',
        child: _DashboardPrimitiveFrame(
          child: Recommendations(
            recommendations: [
              _dashboardRecommendation,
              DashboardEventRecommendation(
                event: _recommendationVariant(
                  id: 'widgetbook-recommend-rail-paid',
                  startsIn: const Duration(days: 2),
                  priceInPaise: 15000,
                ),
                clubName: _club.name,
                reasonLabel: 'Popular with your clubs',
                score: 0.84,
              ),
            ],
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Card states',
  type: StrideCard,
  path: '[P1 product surfaces]/Dashboard primitives',
)
Widget dashboardStrideCardReviewStates(BuildContext context) {
  return _DashboardCatalog(
    title: 'StrideCard',
    contractId: 'dashboard.primitives.stride_card',
    children: [
      _StateCard(
        label: 'connected',
        child: _DashboardPrimitiveFrame(
          child: StrideCard(
            snapshot: DashboardSurfaceFixtures.connectedWeeklyActivity,
          ),
        ),
      ),
      _StateCard(
        label: 'permission CTA',
        child: _DashboardPrimitiveFrame(
          child: StrideCard(
            snapshot: DashboardSurfaceFixtures.permissionWeeklyActivity,
            onConnect: _noopTap,
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Bar states',
  type: StrideBarColumn,
  path: '[P1 product surfaces]/Dashboard primitives',
)
Widget dashboardStrideBarColumnReviewStates(BuildContext context) {
  return const _DashboardCatalog(
    title: 'StrideBarColumn',
    contractId: 'dashboard.primitives.stride_bar_column',
    children: [
      _StateCard(
        label: 'weekly columns',
        child: _DashboardPrimitiveFrame(
          maxWidth: 280,
          child: SizedBox(
            height: 120,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: StrideBarColumn(
                    fraction: 0.2,
                    dayLabel: 'M',
                    isToday: false,
                  ),
                ),
                gapW6,
                Expanded(
                  child: StrideBarColumn(
                    fraction: 0.72,
                    dayLabel: 'T',
                    isToday: true,
                  ),
                ),
                gapW6,
                Expanded(
                  child: StrideBarColumn(
                    fraction: 0,
                    dayLabel: 'W',
                    isToday: false,
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

class _DashboardRouteScope extends StatelessWidget {
  const _DashboardRouteScope({
    this.profileStream,
    this.membershipsStream,
    this.signedUpEventsStream,
    this.memberships,
    this.signedUpEvents,
    this.attendedEventsValue,
    this.weeklyActivityValue,
    this.recommendationsValue,
    this.notificationsValue,
    this.child = const DashboardScreen(),
  });

  final Stream<UserProfile?>? profileStream;
  final Stream<List<ClubMembership>>? membershipsStream;
  final Stream<List<Event>>? signedUpEventsStream;
  final List<ClubMembership>? memberships;
  final List<Event>? signedUpEvents;
  final AsyncValue<List<Event>>? attendedEventsValue;
  final AsyncValue<WeeklyActivitySnapshot>? weeklyActivityValue;
  final AsyncValue<List<DashboardEventRecommendationCandidate>>?
  recommendationsValue;
  final AsyncValue<List<ActivityNotification>>? notificationsValue;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final effectiveMemberships = memberships ?? _memberships;
    final effectiveSignedUpEvents = signedUpEvents ?? [_nextEvent];
    final followedClubIds = effectiveMemberships
        .map((membership) => membership.clubId)
        .toList(growable: false);
    final recommendationsQuery = DashboardRecommendationsQuery(
      userId: _viewer.uid,
      followedClubIds: followedClubIds,
    );
    final recommendations =
        recommendationsValue ??
        AsyncData<List<DashboardEventRecommendationCandidate>>([
          DashboardEventRecommendationCandidate(
            event: _recommendationEvent,
            clubName: _club.name,
            clubLocation: _club.location,
          ),
        ]);
    final clubNames = <String, String>{_club.id: _club.name};
    final focusClubQuery = ClubNameLookupQuery(
      effectiveSignedUpEvents.map((event) => event.clubId),
    );
    final clubsByIdQuery = ClubsByIdQuery([_club.id]);

    return ProviderScope(
      overrides: [
        uidProvider.overrideWithValue(AsyncData<String?>(_viewer.uid)),
        watchUserProfileProvider.overrideWith(
          (ref) => profileStream ?? Stream<UserProfile?>.value(_viewer),
        ),
        watchActiveClubMembershipsForUserProvider(_viewer.uid).overrideWith(
          (ref) =>
              membershipsStream ??
              Stream<List<ClubMembership>>.value(effectiveMemberships),
        ),
        watchSignedUpEventsProvider(_viewer.uid).overrideWith(
          (ref) =>
              signedUpEventsStream ??
              Stream<List<Event>>.value(effectiveSignedUpEvents),
        ),
        watchActivityNotificationsProvider(_viewer.uid).overrideWithValue(
          notificationsValue ??
              AsyncData<List<ActivityNotification>>(_notifications),
        ),
        watchAttendedEventsProvider(_viewer.uid).overrideWithValue(
          attendedEventsValue ?? const AsyncData<List<Event>>([]),
        ),
        weeklyActivityProvider.overrideWithValue(
          weeklyActivityValue ??
              AsyncData<WeeklyActivitySnapshot>(
                DashboardSurfaceFixtures.connectedWeeklyActivity,
              ),
        ),
        watchReviewsByUserProvider(_viewer.uid).overrideWithValue(
          AsyncData<List<Review>>(DashboardSurfaceFixtures.reviews),
        ),
        dashboardRecommendedEventsProvider(
          recommendationsQuery,
        ).overrideWithValue(recommendations),
        clubNameLookupProvider(
          focusClubQuery,
        ).overrideWith((ref) async => clubNames),
        watchClubsByIdsProvider(
          clubsByIdQuery,
        ).overrideWith((ref) => Stream<List<Club>>.value([_club])),
        watchClubProvider(
          _club.id,
        ).overrideWith((ref) => Stream<Club?>.value(_club)),
        externalUrlLauncherProvider.overrideWithValue(_noopLauncher),
        nativeCalendarLauncherProvider.overrideWithValue(_noopCalendarLauncher),
      ],
      child: child,
    );
  }
}

class _DashboardPrimitiveFrame extends StatelessWidget {
  const _DashboardPrimitiveFrame({required this.child, this.maxWidth = 390});

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}

class _DashboardCatalog extends StatelessWidget {
  const _DashboardCatalog({
    required this.title,
    required this.contractId,
    required this.children,
  });

  final String title;
  final String contractId;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Scaffold(
      backgroundColor: t.bg,
      body: SafeArea(
        child: ListView(
          padding: CatchInsets.content,
          children: [
            Text(title, style: CatchTextStyles.titleL(context)),
            gapH4,
            Text(
              contractId,
              style: CatchTextStyles.monoLabel(context, color: t.ink2),
            ),
            gapH24,
            for (final child in children) ...[child, gapH20],
          ],
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

class _MediaOverride extends StatelessWidget {
  const _MediaOverride({
    required this.child,
    this.textScaler,
    this.disableAnimations = false,
  });

  final Widget child;
  final TextScaler? textScaler;
  final bool disableAnimations;

  @override
  Widget build(BuildContext context) {
    final base = MediaQuery.of(context);
    return MediaQuery(
      data: base.copyWith(
        textScaler: textScaler ?? base.textScaler,
        disableAnimations: disableAnimations || base.disableAnimations,
      ),
      child: child,
    );
  }
}

List<NotificationDayGroup> _notificationDayGroups() {
  return [
    NotificationDayGroup(
      label: 'Today',
      rows: [
        NotificationRowDisplay(
          type: ActivityNotificationType.eventReminder,
          title: 'Event starts tomorrow',
          subtitle: 'Sea Face Social meets at Carter Road Jetty.',
          createdAt: DashboardSurfaceFixtures.now,
          timeLabel: '2h',
          isUnread: true,
        ),
        NotificationRowDisplay(
          type: ActivityNotificationType.match,
          title: "It's a catch",
          subtitle: 'You and Riya matched after Sunday socials.',
          createdAt: DashboardSurfaceFixtures.now.subtract(
            const Duration(hours: 6),
          ),
          timeLabel: '6h',
          isUnread: false,
        ),
      ],
    ),
    NotificationDayGroup(
      label: 'Earlier',
      rows: [
        NotificationRowDisplay(
          type: ActivityNotificationType.clubUpdate,
          title: 'New club update',
          subtitle: 'Sea Face Social added a monsoon breakfast run.',
          createdAt: DashboardSurfaceFixtures.now.subtract(
            const Duration(days: 1),
          ),
          timeLabel: '1d',
          isUnread: false,
        ),
      ],
    ),
  ];
}

DashboardFullViewModel _dashboardFullViewModel() {
  return DashboardFullViewModel(
    upcomingEvents: [_nextEvent],
    nextEvent: _nextEvent,
    arrivalAction: null,
    activeSwipeEvent: null,
    pendingReviewEvent: null,
    attendedEventsSection: DashboardSectionModel.data([
      DashboardSurfaceFixtures.attendedEvent,
    ]),
    weeklyActivitySection: DashboardSectionModel.data(
      DashboardSurfaceFixtures.connectedWeeklyActivity,
    ),
    recommendationsSection: DashboardSectionModel.data([
      _dashboardRecommendation,
    ]),
  );
}

Stream<T> _loadingStream<T>() => DashboardSurfaceFixtures.loadingStream<T>();

Stream<T> _errorStream<T>(String message) =>
    DashboardSurfaceFixtures.errorStream<T>(message);

Future<bool> _noopLauncher(Uri uri, {Object? mode}) async {
  return true;
}

Future<bool> _noopCalendarLauncher(CalendarEventPayload event) async {
  return true;
}

Event _recommendationVariant({
  required String id,
  required Duration startsIn,
  ActivityKind activityKind = ActivityKind.socialRun,
  String meetingPoint = 'Race Course Road main gate',
  double distanceKm = 10,
  PaceLevel pace = PaceLevel.moderate,
  int bookedCount = 4,
  int capacityLimit = 12,
  int waitlistedCount = 0,
  int priceInPaise = 0,
}) {
  final start = DateTime.now().add(startsIn);
  return _recommendationEvent.copyWith(
    id: id,
    startTime: start,
    endTime: start.add(const Duration(hours: 1, minutes: 20)),
    meetingPoint: meetingPoint,
    meetingLocation: EventMeetingLocation.legacy(
      name: meetingPoint,
      latitude: 18.993,
      longitude: 72.824,
      notes: 'Widgetbook review fixture',
    ),
    eventFormat: EventFormatSnapshot.fromActivityKind(activityKind),
    distanceKm: distanceKm,
    pace: pace,
    bookedCount: bookedCount,
    capacityLimit: capacityLimit,
    waitlistedCount: waitlistedCount,
    priceInPaise: priceInPaise,
  );
}

void _noopTap() {}
