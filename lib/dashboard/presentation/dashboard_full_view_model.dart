import 'package:catch_dating_app/clubs/data/club_membership_repository.dart';
import 'package:catch_dating_app/core/app_config.dart';
import 'package:catch_dating_app/core/city_catalog.dart';
import 'package:catch_dating_app/core/time_formatters.dart';
import 'package:catch_dating_app/events/data/event_repository.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/domain/event_arrival_action.dart';
import 'package:catch_dating_app/explore/data/explore_recommendations_repository.dart';
import 'package:catch_dating_app/explore/domain/explore_event_recommendation.dart';
import 'package:catch_dating_app/health_activity/domain/runner_activity.dart';
import 'package:catch_dating_app/health_activity/domain/weekly_activity_summary.dart';
import 'package:catch_dating_app/notifications/data/activity_notification_repository.dart';
import 'package:catch_dating_app/notifications/domain/activity_notification.dart';
import 'package:catch_dating_app/reviews/data/reviews_repository.dart';
import 'package:catch_dating_app/reviews/domain/review.dart';
import 'package:catch_dating_app/swipes/domain/swipe_window.dart';
import 'package:catch_dating_app/user_profile/data/user_profile_repository.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'dashboard_full_view_model.g.dart';

@riverpod
DateTime dashboardNow(Ref ref) => DateTime.now();

enum DashboardSectionStatus { loading, error, data }

class DashboardSectionModel<T> {
  const DashboardSectionModel._({
    required this.status,
    this.message,
    this.data,
    this.error,
  });

  const DashboardSectionModel.loading(String message)
    : this._(status: DashboardSectionStatus.loading, message: message);

  const DashboardSectionModel.error(String message, {Object? error})
    : this._(
        status: DashboardSectionStatus.error,
        message: message,
        error: error,
      );

  const DashboardSectionModel.data(T data)
    : this._(status: DashboardSectionStatus.data, data: data);

  final DashboardSectionStatus status;
  final String? message;
  final T? data;

  /// The original error for error-status sections, so the UI can render mapped
  /// copy + retry via the canonical error primitives instead of a fixed string.
  final Object? error;

  bool get isLoading => status == DashboardSectionStatus.loading;
  bool get hasError => status == DashboardSectionStatus.error;
}

class DashboardFullViewModel {
  const DashboardFullViewModel({
    required this.upcomingEvents,
    required this.nextEvent,
    required this.arrivalAction,
    required this.windowedEvents,
    required this.pendingReviewEvent,
    this.clubPostNotifications = const <ActivityNotification>[],
    required this.attendedEventsSection,
    DashboardSectionModel<WeeklyActivitySnapshot>? weeklyActivitySection,
    DashboardSectionModel<List<ExploreEventRecommendation>>?
    recommendationsSection,
  }) : _weeklyActivitySection = weeklyActivitySection,
       _recommendationsSection = recommendationsSection;

  final List<Event> upcomingEvents;
  final Event? nextEvent;
  final EventArrivalAction? arrivalAction;
  final List<CatchWindowItem> windowedEvents;
  final Event? pendingReviewEvent;
  final List<ActivityNotification> clubPostNotifications;
  final DashboardSectionModel<List<Event>> attendedEventsSection;
  final DashboardSectionModel<WeeklyActivitySnapshot>? _weeklyActivitySection;
  final DashboardSectionModel<List<ExploreEventRecommendation>>?
  _recommendationsSection;

  @Deprecated('Home no longer renders weekly activity.')
  DashboardSectionModel<WeeklyActivitySnapshot> get weeklyActivitySection =>
      _weeklyActivitySection ??
      DashboardSectionModel<WeeklyActivitySnapshot>.data(
        WeeklyActivitySnapshot.unsupported(referenceDate: DateTime.now()),
      );

  @Deprecated('Explore owns recommendations.')
  DashboardSectionModel<List<ExploreEventRecommendation>>
  get recommendationsSection =>
      _recommendationsSection ??
      const DashboardSectionModel<List<ExploreEventRecommendation>>.data([]);
}

class CatchWindowItem {
  const CatchWindowItem({
    required this.event,
    required this.title,
    required this.subtitle,
    required this.dateAttendeeLabel,
    required this.attendedCountLabel,
    required this.windowClosesAt,
  });

  final Event event;
  final String title;
  final String subtitle;
  final String dateAttendeeLabel;
  final String attendedCountLabel;
  final DateTime windowClosesAt;

  String countdownLabel(DateTime now) =>
      catchWindowCountdownLabel(windowClosesAt.difference(now));
}

enum DashboardHomeScreenStatus { loading, error, empty, full }

enum DashboardHomeLiveState {
  idle('idle'),
  booked('booked'),
  eventDay('event_day'),
  windowOpen('window_open');

  const DashboardHomeLiveState(this.analyticsValue);

  final String analyticsValue;
}

enum DashboardHomeRetryTarget { userProfile, memberships, signedUpEvents }

class DashboardHomeLoadError {
  const DashboardHomeLoadError({
    required this.error,
    required this.fallbackMessage,
    required this.retryTarget,
    this.uid,
  });

  final Object error;
  final String fallbackMessage;
  final DashboardHomeRetryTarget retryTarget;
  final String? uid;
}

class DashboardHomeHeaderModel {
  const DashboardHomeHeaderModel({required this.eyebrow, required this.title});

  final String eyebrow;
  final String title;

  factory DashboardHomeHeaderModel.empty() {
    return const DashboardHomeHeaderModel(
      eyebrow: 'WELCOME TO CATCH',
      title: "Let's find your first event",
    );
  }

  factory DashboardHomeHeaderModel.full({
    required UserProfile user,
    required DateTime now,
  }) {
    return DashboardHomeHeaderModel(
      eyebrow: dashboardDayCity(user.city, now: now).toUpperCase(),
      title: '${dashboardGreeting(now)}, ${user.greetingDisplayName}',
    );
  }
}

class DashboardHomeScreenState {
  const DashboardHomeScreenState._({
    required this.status,
    required this.header,
    this.error,
    this.user,
    this.viewModel,
    this.followedClubIds = const <String>[],
    this.notificationUid,
  });

  DashboardHomeScreenState.loading()
    : this._(
        status: DashboardHomeScreenStatus.loading,
        header: DashboardHomeHeaderModel.empty(),
      );

  DashboardHomeScreenState.error(DashboardHomeLoadError error)
    : this._(
        status: DashboardHomeScreenStatus.error,
        header: DashboardHomeHeaderModel.empty(),
        error: error,
      );

  DashboardHomeScreenState.empty({String? notificationUid})
    : this._(
        status: DashboardHomeScreenStatus.empty,
        header: DashboardHomeHeaderModel.empty(),
        notificationUid: notificationUid,
      );

  DashboardHomeScreenState.full({
    required DashboardHomeHeaderModel header,
    required UserProfile user,
    required DashboardFullViewModel viewModel,
    required List<String> followedClubIds,
  }) : this._(
         status: DashboardHomeScreenStatus.full,
         header: header,
         user: user,
         viewModel: viewModel,
         followedClubIds: followedClubIds,
         notificationUid: user.uid,
       );

  final DashboardHomeScreenStatus status;
  final DashboardHomeHeaderModel header;
  final DashboardHomeLoadError? error;
  final UserProfile? user;
  final DashboardFullViewModel? viewModel;
  final List<String> followedClubIds;
  final String? notificationUid;
}

String dashboardGreeting(DateTime now) {
  final hour = now.hour;
  if (hour < 12) return 'Morning';
  if (hour < 17) return 'Afternoon';
  return 'Evening';
}

String dashboardDayCity(String? city, {required DateTime now}) {
  final day = AppTimeFormatters.longWeekday(now);
  final label = cityLabel(city);
  return '$day · ${label.isEmpty ? defaultCityDataForMarket().label : label}';
}

DashboardHomeLiveState dashboardHomeLiveStateFor(
  DashboardHomeScreenState state, {
  required DateTime now,
}) {
  if (state.status != DashboardHomeScreenStatus.full) {
    return DashboardHomeLiveState.idle;
  }

  final viewModel = state.viewModel;
  if (viewModel == null) return DashboardHomeLiveState.idle;
  if (viewModel.windowedEvents.isNotEmpty) {
    return DashboardHomeLiveState.windowOpen;
  }
  if (viewModel.arrivalAction != null ||
      viewModel.upcomingEvents.any(
        (event) => _isSameLocalDay(event.startTime, now),
      )) {
    return DashboardHomeLiveState.eventDay;
  }
  if (viewModel.upcomingEvents.isNotEmpty) {
    return DashboardHomeLiveState.booked;
  }
  return DashboardHomeLiveState.idle;
}

List<String> dashboardHomeModuleImpressionsFor(DashboardHomeScreenState state) {
  if (state.status == DashboardHomeScreenStatus.loading ||
      state.status == DashboardHomeScreenStatus.error) {
    return const <String>[];
  }

  final viewModel = state.viewModel;
  if (viewModel == null) return const ['idle_cta'];

  final modules = <String>[];
  if (viewModel.windowedEvents.isNotEmpty) {
    modules.add('catch_window');
  }
  if (viewModel.upcomingEvents.isNotEmpty ||
      viewModel.arrivalAction != null ||
      viewModel.pendingReviewEvent != null) {
    modules.add('lifecycle_timeline');
  }
  final hasLiveModule = modules.isNotEmpty;
  if (!hasLiveModule) {
    modules.add('idle_cta');
  }
  if (viewModel.clubPostNotifications.isNotEmpty) {
    modules.add('club_posts');
  }
  return List.unmodifiable(modules);
}

List<CatchWindowItem> catchWindowItemsFromEvents(
  Iterable<Event> events, {
  required DateTime now,
}) {
  final items = [
    for (final event in eventsWithOpenSwipeWindow(events, now: now))
      catchWindowItemFromEvent(event),
  ]..sort((a, b) => a.windowClosesAt.compareTo(b.windowClosesAt));
  return List.unmodifiable(items);
}

CatchWindowItem catchWindowItemFromEvent(Event event) {
  final dateLabel = AppTimeFormatters.weekdayDayMonth(event.startTime);
  return CatchWindowItem(
    event: event,
    title: event.title,
    subtitle: 'Only checked-in attendees from ${event.title} are here.',
    dateAttendeeLabel:
        '$dateLabel · ${event.attendedCount} attendees checked in',
    attendedCountLabel: '${event.attendedCount}',
    windowClosesAt: swipeWindowClosesAt(event),
  );
}

String catchWindowCountdownLabel(Duration remaining) {
  if (remaining.isNegative) return '0h 00m';
  final hours = remaining.inHours;
  final minutes = remaining.inMinutes.remainder(60);
  return '${hours}h ${minutes.toString().padLeft(2, '0')}m';
}

List<ActivityNotification> clubPostNotificationsFromActivity(
  Iterable<ActivityNotification> notifications,
) {
  final posts =
      notifications
          .where(
            (notification) =>
                notification.isUnread &&
                notification.type == ActivityNotificationType.clubUpdate &&
                notification.postId != null,
          )
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  return posts.take(3).toList(growable: false);
}

bool _isSameLocalDay(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

DashboardFullViewModel buildDashboardFullViewModel({
  required List<Event> signedUpEvents,
  String? uid,
  UserProfile? viewer,
  required AsyncValue<List<Event>> attendedEventsAsync,
  @Deprecated('Explore owns recommendations; retained for compatibility.')
  AsyncValue<List<ExploreEventRecommendationCandidate>>? recommendedEventsAsync,
  AsyncValue<WeeklyActivitySnapshot>? weeklyActivityAsync,
  AsyncValue<List<Review>> reviewsByUserAsync = const AsyncData<List<Review>>(
    [],
  ),
  List<ActivityNotification> clubPostNotifications =
      const <ActivityNotification>[],
  DateTime? now,
}) {
  final effectiveNow = now ?? DateTime.now();

  final upcomingEvents =
      signedUpEvents
          .where((event) => event.startTime.isAfter(effectiveNow))
          .toList()
        ..sort((a, b) => a.startTime.compareTo(b.startTime));

  final nextEvent = upcomingEvents.firstOrNull;

  final attendedEventsSection = attendedEventsAsync.when(
    loading: () => const DashboardSectionModel<List<Event>>.loading(
      'Loading your recent events...',
    ),
    error: (error, stackTrace) => DashboardSectionModel<List<Event>>.error(
      'Unable to load your recent events.',
      error: error,
    ),
    data: DashboardSectionModel<List<Event>>.data,
  );
  final weeklyActivitySection = _buildWeeklyActivitySection(
    attendedEventsAsync: attendedEventsAsync,
    weeklyActivityAsync: weeklyActivityAsync,
    referenceDate: effectiveNow,
  );
  final signedUpEventIds = signedUpEvents.map((event) => event.id).toSet();
  final recommendationsSection =
      recommendedEventsAsync?.when(
        loading: () =>
            const DashboardSectionModel<
              List<ExploreEventRecommendation>
            >.loading('Loading recommended events...'),
        error: (error, stackTrace) =>
            DashboardSectionModel<List<ExploreEventRecommendation>>.error(
              'Unable to load recommended events.',
              error: error,
            ),
        data: (candidates) =>
            DashboardSectionModel<List<ExploreEventRecommendation>>.data(
              rankExploreEventRecommendations(
                candidates: candidates,
                signedUpEventIds: signedUpEventIds,
                attendedEvents:
                    attendedEventsAsync.asData?.value ?? const <Event>[],
                signedUpEvents: signedUpEvents,
                viewer: viewer,
                now: effectiveNow,
              ),
            ),
      ) ??
      const DashboardSectionModel<List<ExploreEventRecommendation>>.data([]);
  final windowedEvents = attendedEventsSection.data == null
      ? const <CatchWindowItem>[]
      : catchWindowItemsFromEvents(
          attendedEventsSection.data!,
          now: effectiveNow,
        );
  final reviewedEventIds =
      reviewsByUserAsync.asData?.value
          .map((review) => review.eventId)
          .whereType<String>()
          .toSet() ??
      const <String>{};
  final pendingReviewEvent = attendedEventsSection.data == null
      ? null
      : _latestUnreviewedAttendedEvent(
          attendedEventsSection.data!,
          reviewedEventIds: reviewedEventIds,
        );
  final arrivalAction = uid == null
      ? null
      : selectEventArrivalAction(
          signedUpEvents: signedUpEvents,
          hostedEvents: const [],
          uid: uid,
          now: effectiveNow,
        );

  return DashboardFullViewModel(
    upcomingEvents: upcomingEvents,
    nextEvent: nextEvent,
    arrivalAction: arrivalAction,
    windowedEvents: windowedEvents,
    pendingReviewEvent: pendingReviewEvent,
    clubPostNotifications: clubPostNotifications,
    attendedEventsSection: attendedEventsSection,
    weeklyActivitySection: weeklyActivitySection,
    recommendationsSection: recommendationsSection,
  );
}

DashboardSectionModel<WeeklyActivitySnapshot> _buildWeeklyActivitySection({
  required AsyncValue<List<Event>> attendedEventsAsync,
  required AsyncValue<WeeklyActivitySnapshot>? weeklyActivityAsync,
  required DateTime referenceDate,
}) {
  if (attendedEventsAsync.isLoading) {
    return const DashboardSectionModel<WeeklyActivitySnapshot>.loading(
      'Loading your recent events...',
    );
  }
  if (weeklyActivityAsync?.isLoading ?? false) {
    return const DashboardSectionModel<WeeklyActivitySnapshot>.loading(
      'Loading your weekly activity...',
    );
  }

  final attendedEvents = attendedEventsAsync.asData?.value;
  final platformSnapshot = weeklyActivityAsync?.asData?.value;
  if (attendedEventsAsync.hasError &&
      platformSnapshot?.hasPlatformConnection != true) {
    return DashboardSectionModel<WeeklyActivitySnapshot>.error(
      'Unable to load your recent events.',
      error: attendedEventsAsync.error,
    );
  }

  if (attendedEvents != null || platformSnapshot != null) {
    return DashboardSectionModel<WeeklyActivitySnapshot>.data(
      buildDashboardWeeklyActivitySnapshot(
        attendedEvents: attendedEvents ?? const <Event>[],
        platformSnapshot:
            platformSnapshot ??
            WeeklyActivitySnapshot.unsupported(referenceDate: referenceDate),
        referenceDate: referenceDate,
      ),
    );
  }

  return DashboardSectionModel<WeeklyActivitySnapshot>.data(
    WeeklyActivitySnapshot.unsupported(referenceDate: referenceDate),
  );
}

WeeklyActivitySnapshot buildDashboardWeeklyActivitySnapshot({
  required List<Event> attendedEvents,
  required WeeklyActivitySnapshot platformSnapshot,
  required DateTime referenceDate,
}) {
  final catchActivities = attendedEvents
      .map(_activityFromCatchEvent)
      .toList(growable: false);

  if (!platformSnapshot.hasPlatformConnection) {
    final catchSummary = WeeklyActivitySummary.fromActivities(
      catchActivities,
      referenceDate: referenceDate,
      refreshedAt: platformSnapshot.summary.refreshedAt,
    );
    if (!catchSummary.hasEvents) {
      return platformSnapshot.copyWith(
        summary: catchSummary,
        activities: const [],
        source: WeeklyActivitySource.none,
      );
    }
    return platformSnapshot.copyWith(
      summary: catchSummary,
      activities: catchActivities,
      source: WeeklyActivitySource.catchFallback,
      message: 'Catch check-ins only.',
    );
  }

  final platformActivities = platformSnapshot.activities;
  final catchOnlyActivities = catchActivities
      .where(
        (activity) => !_overlapsPlatformActivity(activity, platformActivities),
      )
      .toList(growable: false);
  final mergedActivities = [...platformActivities, ...catchOnlyActivities];
  final summary = WeeklyActivitySummary.fromActivities(
    mergedActivities,
    referenceDate: referenceDate,
    refreshedAt: platformSnapshot.summary.refreshedAt,
  );

  final source = _weeklyActivitySource(
    platformActivities: platformActivities,
    catchActivities: catchOnlyActivities,
    summary: summary,
  );

  return platformSnapshot.copyWith(
    summary: summary,
    activities: mergedActivities,
    source: source,
    clearMessage: source != WeeklyActivitySource.catchFallback,
    message: source == WeeklyActivitySource.catchFallback
        ? 'Catch check-ins only.'
        : null,
  );
}

PhysicalActivity _activityFromCatchEvent(Event event) {
  final activityKind = event.eventFormat.healthActivityKind;
  return PhysicalActivity(
    stableId: 'catch:${event.id}',
    provider: PhysicalActivityProvider.catchAttendance,
    type: activityKind,
    startTime: event.startTime,
    endTime: event.endTime,
    distanceMeters: activityKind.isDistanceBased
        ? event.distanceKm * 1000
        : null,
    sourceName: 'Catch',
    matchedCatchEventId: event.id,
  );
}

bool _overlapsPlatformActivity(
  PhysicalActivity catchActivity,
  List<PhysicalActivity> platformActivities,
) {
  final matchWindowStart = catchActivity.startTime.subtract(
    const Duration(minutes: 30),
  );
  final matchWindowEnd = catchActivity.endTime.add(const Duration(minutes: 30));
  return platformActivities.any(
    (activity) => activity.overlaps(matchWindowStart, matchWindowEnd),
  );
}

WeeklyActivitySource _weeklyActivitySource({
  required List<PhysicalActivity> platformActivities,
  required List<PhysicalActivity> catchActivities,
  required WeeklyActivitySummary summary,
}) {
  if (!summary.hasEvents) return WeeklyActivitySource.none;
  if (platformActivities.isNotEmpty && catchActivities.isNotEmpty) {
    return WeeklyActivitySource.mixed;
  }
  if (platformActivities.isNotEmpty) {
    return WeeklyActivitySource.healthPlatform;
  }
  return WeeklyActivitySource.catchFallback;
}

Event? _latestUnreviewedAttendedEvent(
  List<Event> attendedEvents, {
  required Set<String> reviewedEventIds,
}) {
  final unreviewedEvents =
      attendedEvents
          .where((event) => !reviewedEventIds.contains(event.id))
          .toList()
        ..sort((a, b) => b.endTime.compareTo(a.endTime));
  return unreviewedEvents.firstOrNull;
}

@Deprecated('Use ExploreEventRecommendation from explore recommendations.')
typedef DashboardEventRecommendation = ExploreEventRecommendation;

@Deprecated('Use rankExploreEventRecommendations from explore recommendations.')
List<DashboardEventRecommendation> rankDashboardEventRecommendations({
  required List<ExploreEventRecommendationCandidate> candidates,
  required Set<String> signedUpEventIds,
  required List<Event> attendedEvents,
  required List<Event> signedUpEvents,
  required DateTime now,
  UserProfile? viewer,
  int limit = 10,
}) {
  return rankExploreEventRecommendations(
    candidates: candidates,
    signedUpEventIds: signedUpEventIds,
    attendedEvents: attendedEvents,
    signedUpEvents: signedUpEvents,
    now: now,
    viewer: viewer,
    limit: limit,
  );
}

/// Combines signed-up and attended events into the live-layer home model.
@riverpod
DashboardFullViewModel dashboardFullViewModel(
  Ref ref, {
  required List<Event> signedUpEvents,
  required UserProfile user,
  required String uid,
  required List<String> followedClubIds,
}) {
  final clubPostNotifications = AppConfig.enableClubPosts
      ? clubPostNotificationsFromActivity(
          ref.watch(watchActivityNotificationsProvider(uid)).asData?.value ??
              const <ActivityNotification>[],
        )
      : const <ActivityNotification>[];

  return buildDashboardFullViewModel(
    signedUpEvents: signedUpEvents,
    uid: uid,
    viewer: user,
    attendedEventsAsync: ref.watch(watchAttendedEventsProvider(uid)),
    reviewsByUserAsync: ref.watch(watchReviewsByUserProvider(uid)),
    clubPostNotifications: clubPostNotifications,
    now: ref.watch(dashboardNowProvider),
  );
}

/// Builds the route-level state for Dashboard Home.
///
/// The route widget should only switch over this state and compose the selected
/// sections; provider waves, retry targets, header copy, and empty/full
/// selection live here.
@riverpod
DashboardHomeScreenState dashboardHomeScreenState(Ref ref) {
  final now = ref.watch(dashboardNowProvider);
  final userAsync = ref.watch(watchUserProfileProvider);

  return userAsync.when(
    loading: DashboardHomeScreenState.loading,
    error: (error, stackTrace) => DashboardHomeScreenState.error(
      DashboardHomeLoadError(
        error: error,
        fallbackMessage: 'Unable to load your dashboard.',
        retryTarget: DashboardHomeRetryTarget.userProfile,
      ),
    ),
    data: (user) {
      if (user == null) {
        return DashboardHomeScreenState.empty();
      }

      final followedClubIdsAsync = ref.watch(
        currentUserFollowedClubIdsProvider,
      );
      final signedUpEventsAsync = ref.watch(
        watchSignedUpEventsProvider(user.uid),
      );

      if (followedClubIdsAsync.isLoading || signedUpEventsAsync.isLoading) {
        return DashboardHomeScreenState.loading();
      }
      if (followedClubIdsAsync.hasError) {
        return DashboardHomeScreenState.error(
          DashboardHomeLoadError(
            error: followedClubIdsAsync.error!,
            fallbackMessage: 'Unable to load your clubs.',
            retryTarget: DashboardHomeRetryTarget.memberships,
            uid: user.uid,
          ),
        );
      }
      if (signedUpEventsAsync.hasError) {
        return DashboardHomeScreenState.error(
          DashboardHomeLoadError(
            error: signedUpEventsAsync.error!,
            fallbackMessage: 'Unable to load your booked events.',
            retryTarget: DashboardHomeRetryTarget.signedUpEvents,
            uid: user.uid,
          ),
        );
      }

      final signedUpEvents =
          signedUpEventsAsync.asData?.value ?? const <Event>[];
      final followedClubIds = [...?followedClubIdsAsync.asData?.value]..sort();
      final viewModel = ref.watch(
        dashboardFullViewModelProvider(
          signedUpEvents: signedUpEvents,
          user: user,
          uid: user.uid,
          followedClubIds: followedClubIds,
        ),
      );

      return DashboardHomeScreenState.full(
        header: DashboardHomeHeaderModel.full(user: user, now: now),
        user: user,
        viewModel: viewModel,
        followedClubIds: followedClubIds,
      );
    },
  );
}
