import 'package:catch_dating_app/activity/domain/activity_taxonomy.dart';
import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/clubs/data/club_membership_repository.dart';
import 'package:catch_dating_app/clubs/data/clubs_repository.dart';
import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/clubs/domain/club_membership.dart';
import 'package:catch_dating_app/clubs/presentation/club_name_lookup.dart';
import 'package:catch_dating_app/core/external_links.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/dashboard/presentation/dashboard_full_view_model.dart';
import 'package:catch_dating_app/dashboard/presentation/dashboard_recommendations_provider.dart';
import 'package:catch_dating_app/dashboard/presentation/dashboard_screen.dart';
import 'package:catch_dating_app/dashboard/presentation/widgets/quick_actions.dart';
import 'package:catch_dating_app/dashboard/presentation/widgets/recommend_card.dart';
import 'package:catch_dating_app/dashboard/presentation/widgets/stride_card.dart';
import 'package:catch_dating_app/events/data/event_repository.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/presentation/event_calendar_links.dart';
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
  type: QuickActions,
  path: '[P1 product surfaces]/Dashboard primitives',
)
Widget dashboardQuickActionsReviewStates(BuildContext context) {
  return _DashboardCatalog(
    title: 'QuickActions',
    contractId: 'dashboard.primitives.quick_actions',
    children: [
      _StateCard(
        label: 'normal primary actions',
        child: _DashboardPrimitiveFrame(
          child: QuickActions(
            actions: dashboardQuickActions(
              onCalendarPressed: _noopTap,
              onSavedEventsPressed: _noopTap,
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'one disabled action',
        child: _DashboardPrimitiveFrame(
          child: QuickActions(
            actions: [
              DashboardQuickAction(
                icon: CatchIcons.calendarMonthOutlined,
                label: 'Calendar',
              ),
              DashboardQuickAction(
                icon: CatchIcons.bookmarkBorderRounded,
                label: 'Saved events',
                onPressed: _noopTap,
              ),
            ],
          ),
        ),
      ),
      _StateCard(
        label: 'two-column action set',
        child: _DashboardPrimitiveFrame(
          maxWidth: 300,
          child: QuickActions(
            actions: [
              DashboardQuickAction(
                icon: CatchIcons.calendarMonthOutlined,
                label: 'Calendar',
                onPressed: _noopTap,
              ),
              DashboardQuickAction(
                icon: CatchIcons.bookmarkBorderRounded,
                label: 'Saved events',
                onPressed: _noopTap,
              ),
              DashboardQuickAction(
                icon: CatchIcons.mapOutlined,
                label: 'Map view',
                onPressed: _noopTap,
              ),
              DashboardQuickAction(
                icon: CatchIcons.eventAvailableOutlined,
                label: 'Event guide',
                onPressed: _noopTap,
              ),
            ],
          ),
        ),
      ),
      _StateCard(
        label: 'long copy truncation',
        child: _DashboardPrimitiveFrame(
          maxWidth: 300,
          child: QuickActions(
            actions: [
              DashboardQuickAction(
                icon: CatchIcons.calendarTodayOutlined,
                label: 'Add every upcoming RSVP to calendar',
                onPressed: _noopTap,
              ),
              DashboardQuickAction(
                icon: CatchIcons.bookmarkBorderRounded,
                label: 'Review saved events with longer venue names',
                onPressed: _noopTap,
              ),
            ],
          ),
        ),
      ),
      _StateCard(
        label: 'empty action list',
        child: const _DashboardPrimitiveFrame(
          maxWidth: 300,
          child: QuickActions(actions: []),
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
