import 'dart:async';

import 'package:catch_dating_app/clubs/data/club_name_lookup.dart';
import 'package:catch_dating_app/core/analytics/app_analytics.dart';
import 'package:catch_dating_app/core/external_links.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_section_layout.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/dashboard/presentation/dashboard_event_focus_controller.dart';
import 'package:catch_dating_app/dashboard/presentation/dashboard_full_view_model.dart';
import 'package:catch_dating_app/dashboard/presentation/notifications_list_state.dart';
import 'package:catch_dating_app/dashboard/presentation/widgets/club_posts_home_section.dart';
import 'package:catch_dating_app/dashboard/presentation/widgets/empty_hero_card.dart';
import 'package:catch_dating_app/dashboard/presentation/widgets/event_lifecycle_timeline.dart';
import 'package:catch_dating_app/event_success/event_success_companion_launcher.dart';
import 'package:catch_dating_app/events/data/event_calendar_links.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/domain/event_location_links.dart';
import 'package:catch_dating_app/events/shared/event_check_in_celebration_screen.dart';
import 'package:catch_dating_app/notifications/data/activity_notification_repository.dart';
import 'package:catch_dating_app/notifications/domain/activity_notification.dart';
import 'package:catch_dating_app/reviews/shared/write_review_sheet.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/experimental/mutation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class DashboardFullSliverBody extends ConsumerStatefulWidget {
  const DashboardFullSliverBody({
    super.key,
    required this.viewModel,
    required this.user,
  });

  final DashboardFullViewModel viewModel;
  final UserProfile user;

  @override
  ConsumerState<DashboardFullSliverBody> createState() =>
      _DashboardFullSliverBodyState();
}

class _DashboardFullSliverBodyState
    extends ConsumerState<DashboardFullSliverBody> {
  @override
  Widget build(BuildContext context) {
    final focusEvents = [
      for (final window in widget.viewModel.windowedEvents) window.event,
      ...widget.viewModel.upcomingEvents,
      if (widget.viewModel.pendingReviewEvent != null)
        widget.viewModel.pendingReviewEvent!,
    ];
    final clubNamesAsync = ref.watch(
      clubNameLookupProvider(
        ClubNameLookupQuery(focusEvents.map((event) => event.clubId)),
      ),
    );
    final clubNames = clubNamesAsync.asData?.value;
    final checkInMutation = ref.watch(
      DashboardEventFocusController.selfCheckInMutation,
    );

    return SliverToBoxAdapter(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: CatchLayout.maxContentWidth,
          ),
          child: CatchSectionStack(
            padding: CatchInsets.pageBodyUnderHeader,
            gap: CatchSpacing.micro18,
            children: [
              if (focusEvents.isEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    EmptyHeroCard(onFindEvent: () => _openExplore(context)),
                    gapH18,
                    const _HomeCatchWindowExplainer(),
                  ],
                )
              else
                EventLifecycleTimeline(
                  upcomingEvents: widget.viewModel.upcomingEvents,
                  windowedEvents: widget.viewModel.windowedEvents,
                  arrivalAction: widget.viewModel.arrivalAction,
                  pendingReviewEvent: widget.viewModel.pendingReviewEvent,
                  clubNameBuilder: (event) => clubNames?[event.clubId],
                  checkInState: EventFocusCheckInState(
                    isPending: checkInMutation.isPending,
                    error: checkInMutation.hasError
                        ? (checkInMutation as MutationError).error
                        : null,
                  ),
                  actions: _buildEventFocusActions(context),
                ),
              if (widget.viewModel.clubPostNotifications.isNotEmpty)
                ClubPostsHomeSection(
                  notifications: widget.viewModel.clubPostNotifications,
                  onOpenPost: (notification) =>
                      _openClubPost(context, notification),
                ),
            ],
          ),
        ),
      ),
    );
  }

  EventFocusActions _buildEventFocusActions(BuildContext context) {
    return EventFocusActions(
      onViewEvent: (event) => _openEvent(context, event),
      onCheckIn: (event) => _checkIn(context, event),
      onOpenSwipe: (event) => _openSwipe(context, event),
      onWriteReview: (event) => _writeReview(context, event),
      onOpenDirections: _openDirections,
      onAddToCalendar: _addToCalendar,
      onResetCheckInError: () =>
          DashboardEventFocusController(ref: ref).resetSelfCheckInError(),
    );
  }

  void _logAction(String module, String action) {
    ref
        .read(appAnalyticsProvider)
        .logEvent(
          AnalyticsEvents.homeActionTap,
          parameters: {
            AnalyticsParameters.homeModule: module,
            AnalyticsParameters.homeAction: action,
          },
        );
  }

  String _moduleForEvent(Event event) {
    return widget.viewModel.windowedEvents.any(
          (window) => window.event.id == event.id,
        )
        ? 'catch_window'
        : 'lifecycle_timeline';
  }

  void _openExplore(BuildContext context) {
    _logAction('idle_cta', 'find_event');
    context.go(Routes.exploreScreen.path);
  }

  void _openClubPost(BuildContext context, ActivityNotification notification) {
    _logAction('club_posts', 'open_post');
    final parameters = <String, Object>{};
    final clubId = notification.clubId;
    final eventId = notification.eventId;
    if (clubId != null) {
      parameters[AnalyticsParameters.clubId] = clubId;
    }
    if (eventId != null) {
      parameters[AnalyticsParameters.eventId] = eventId;
    }
    ref
        .read(appAnalyticsProvider)
        .logEvent(AnalyticsEvents.clubPostOpen, parameters: parameters);
    unawaited(
      ref
          .read(activityNotificationRepositoryProvider)
          .markAllRead(uid: notification.uid, notifications: [notification]),
    );
    final route = notificationRoute(notification);
    if (route != null) {
      context.push(route);
    }
  }

  void _openEvent(BuildContext context, Event event) {
    _logAction(_moduleForEvent(event), 'view_event');
    context.pushNamed(
      Routes.dashboardEventDetailScreen.name,
      pathParameters: {'clubId': event.clubId, 'eventId': event.id},
      extra: event,
    );
  }

  void _openDirections(Event event) {
    _logAction(_moduleForEvent(event), 'directions');
    unawaited(
      ref
          .read(externalLinkControllerProvider)
          .openExternal(directionsUriForEvent(event)),
    );
  }

  void _addToCalendar(Event event) {
    _logAction(_moduleForEvent(event), 'add_to_calendar');
    unawaited(ref.read(eventCalendarControllerProvider).addToCalendar(event));
  }

  void _openSwipe(BuildContext context, Event event) {
    final module = _moduleForEvent(event);
    _logAction(module, 'open_catch_window');
    if (module == 'catch_window') {
      ref
          .read(appAnalyticsProvider)
          .logEvent(
            AnalyticsEvents.catchWindowOpen,
            parameters: {
              AnalyticsParameters.surface: 'home',
              AnalyticsParameters.eventId: event.id,
            },
          );
    }
    context.pushNamed(
      Routes.swipeEventScreen.name,
      pathParameters: {'eventId': event.id},
    );
  }

  void _writeReview(BuildContext context, Event event) {
    _logAction(_moduleForEvent(event), 'write_review');
    showWriteReviewSheet(
      context: context,
      clubId: event.clubId,
      eventId: event.id,
      reviewer: widget.user,
    );
  }

  void _checkIn(BuildContext context, Event event) {
    _logAction(_moduleForEvent(event), 'check_in');
    unawaited(_runCheckInFlow(context, event));
  }

  Future<void> _runCheckInFlow(BuildContext context, Event event) async {
    final controller = DashboardEventFocusController(ref: ref);
    try {
      await DashboardEventFocusController.selfCheckInMutation.run(ref, (
        tx,
      ) async {
        await controller.selfCheckIn(tx, event);
        if (!context.mounted) return;
        final launchResult = await launchEventSuccessCompanionIfAvailable(
          context: context,
          ref: ref,
          uid: widget.user.uid,
          event: event,
        );
        if (!context.mounted ||
            launchResult != EventSuccessCompanionLaunchResult.unavailable) {
          return;
        }
        await Navigator.of(context, rootNavigator: true).push(
          MaterialPageRoute<void>(
            fullscreenDialog: true,
            builder: (routeContext) => EventCheckInCelebrationScreen(
              event: event,
              onViewEvent: () {
                Navigator.of(routeContext).pop();
                GoRouter.of(context).goNamed(
                  Routes.eventDetailScreen.name,
                  pathParameters: {'clubId': event.clubId, 'eventId': event.id},
                  extra: event,
                );
              },
              onBackHome: () {
                Navigator.of(routeContext).pop();
                GoRouter.of(context).goNamed(Routes.dashboardScreen.name);
              },
            ),
          ),
        );
      });
    } catch (_) {
      // Mutation state owns the inline error display in EventLifecycleTimeline.
    }
  }
}

class _HomeCatchWindowExplainer extends StatelessWidget {
  const _HomeCatchWindowExplainer();

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return CatchSurface(
      padding: CatchInsets.content,
      tone: CatchSurfaceTone.raised,
      borderColor: t.line,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            CatchIcons.lockClockRounded,
            color: t.primary,
            size: CatchIcon.control,
          ),
          gapW10,
          Expanded(
            child: Text(
              'Dating stays locked until you actually run together. No cold stranger browsing.',
              style: CatchTextStyles.proseM(context, color: t.ink2),
            ),
          ),
        ],
      ),
    );
  }
}
