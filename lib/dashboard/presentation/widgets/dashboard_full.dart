import 'dart:async';

import 'package:catch_dating_app/clubs/data/club_name_lookup.dart';
import 'package:catch_dating_app/clubs/data/clubs_repository.dart';
import 'package:catch_dating_app/clubs/presentation/discovery/widgets/club_avatar_rail.dart';
import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/external_links.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_error_snackbar.dart';
import 'package:catch_dating_app/core/widgets/catch_error_state.dart';
import 'package:catch_dating_app/core/widgets/catch_section_layout.dart';
import 'package:catch_dating_app/core/widgets/catch_skeleton.dart';
import 'package:catch_dating_app/dashboard/presentation/dashboard_full_view_model.dart';
import 'package:catch_dating_app/dashboard/presentation/dashboard_recommendations_provider.dart';
import 'package:catch_dating_app/dashboard/presentation/dashboard_stride_actions.dart';
import 'package:catch_dating_app/dashboard/presentation/widgets/dashboard_section_state_card.dart';
import 'package:catch_dating_app/dashboard/presentation/widgets/dashboard_sliver_header.dart';
import 'package:catch_dating_app/dashboard/presentation/widgets/event_focus_rail.dart';
import 'package:catch_dating_app/dashboard/presentation/widgets/quick_actions.dart';
import 'package:catch_dating_app/dashboard/presentation/widgets/recommendations.dart';
import 'package:catch_dating_app/dashboard/presentation/widgets/stride_card.dart';
import 'package:catch_dating_app/event_success/event_success_companion_launcher.dart';
import 'package:catch_dating_app/events/data/event_calendar_links.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/domain/event_location_links.dart';
import 'package:catch_dating_app/events/presentation/event_booking_controller.dart';
import 'package:catch_dating_app/events/presentation/event_check_in_celebration_screen.dart';
import 'package:catch_dating_app/exceptions/app_exception.dart';
import 'package:catch_dating_app/health_activity/data/health_activity_repository.dart';
import 'package:catch_dating_app/reviews/presentation/write_review_sheet.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/experimental/mutation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class DashboardFull extends ConsumerWidget {
  const DashboardFull({
    super.key,
    required this.user,
    required this.signedUpEvents,
    required this.followedClubIds,
  });

  static const scrollViewKey = ValueKey('dashboard-full-scroll-view');

  final UserProfile user;
  final List<Event> signedUpEvents;
  final List<String> followedClubIds;

  static String greeting([DateTime? now]) =>
      dashboardGreeting(now ?? DateTime.now());

  static String dayCity(String? city, {DateTime? now}) =>
      dashboardDayCity(city, now: now ?? DateTime.now());

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = CatchTokens.of(context);
    final now = ref.watch(dashboardNowProvider);
    final header = DashboardHomeHeaderModel.full(user: user, now: now);
    final viewModel = ref.watch(
      dashboardFullViewModelProvider(
        signedUpEvents: signedUpEvents,
        user: user,
        uid: user.uid,
        followedClubIds: followedClubIds,
      ),
    );

    return Scaffold(
      backgroundColor: t.bg,
      body: SafeArea(
        child: CustomScrollView(
          key: scrollViewKey,
          slivers: [
            ...DashboardSliverHeader(
              eyebrow: header.eyebrow,
              title: header.title,
            ).buildSlivers(context),
            DashboardFullSliverBody(
              viewModel: viewModel,
              user: user,
              followedClubIds: followedClubIds,
            ),
          ],
        ),
      ),
    );
  }
}

class DashboardFullSliverBody extends ConsumerStatefulWidget {
  const DashboardFullSliverBody({
    super.key,
    required this.viewModel,
    required this.user,
    this.followedClubIds = const <String>[],
  });

  final DashboardFullViewModel viewModel;
  final UserProfile user;
  final List<String> followedClubIds;

  @override
  ConsumerState<DashboardFullSliverBody> createState() =>
      _DashboardFullSliverBodyState();
}

class _DashboardFullSliverBodyState
    extends ConsumerState<DashboardFullSliverBody> {
  bool _isConnectingStride = false;
  bool _isInstallingHealthConnect = false;

  @override
  Widget build(BuildContext context) {
    final focusEvents = [
      ...widget.viewModel.upcomingEvents,
      if (widget.viewModel.activeSwipeEvent != null)
        widget.viewModel.activeSwipeEvent!,
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
      EventBookingController.selfCheckInMutation,
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
              if (focusEvents.isNotEmpty)
                EventFocusRail(
                  upcomingEvents: widget.viewModel.upcomingEvents,
                  arrivalAction: widget.viewModel.arrivalAction,
                  activeSwipeEvent: widget.viewModel.activeSwipeEvent,
                  pendingReviewEvent: widget.viewModel.pendingReviewEvent,
                  clubNameBuilder: (event) => clubNames?[event.clubId],
                  checkInState: EventFocusCheckInState(
                    isPending: checkInMutation.isPending,
                    error: checkInMutation.hasError
                        ? (checkInMutation as MutationError).error
                        : null,
                  ),
                  actions: _buildEventFocusActions(context, ref),
                ),
              DashboardStrideSection(
                section: widget.viewModel.weeklyActivitySection,
                actionState: DashboardStrideActionState(
                  isConnecting: _isConnectingStride,
                  isInstallingHealthConnect: _isInstallingHealthConnect,
                ),
                actions: DashboardStrideSectionActions(
                  onRetry: () => ref.invalidate(weeklyActivityProvider),
                  onConnect: () => _connectStride(context),
                  onInstallHealthConnect: _installHealthConnect,
                ),
              ),
              QuickActions(actions: _buildQuickActions(context)),
              if (widget.followedClubIds.isNotEmpty) _buildFollowedClubsRail(),
              ..._buildRecommendedEventsSection(
                ref: ref,
                recommendationsSection: widget.viewModel.recommendationsSection,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFollowedClubsRail() {
    final uniqueIds = widget.followedClubIds
        .toSet()
        .take(12)
        .toList(growable: false);
    if (uniqueIds.isEmpty) return const SizedBox.shrink();

    final clubsAsync = ref.watch(
      watchClubsByIdsProvider(ClubsByIdQuery(uniqueIds)),
    );
    final clubs = clubsAsync.asData?.value ?? const [];

    if (clubs.isNotEmpty) {
      return ClubAvatarRail(
        clubs: clubs,
        showDivider: false,
        headerPadding: EdgeInsets.zero,
        listPadding: EdgeInsets.zero,
      );
    }

    return clubsAsync.isLoading
        ? const FollowedClubsRailSkeleton()
        : const SizedBox.shrink();
  }

  EventFocusActions _buildEventFocusActions(
    BuildContext context,
    WidgetRef ref,
  ) {
    return EventFocusActions(
      onViewEvent: (event) => _openEvent(context, event),
      onCheckIn: (event) => _checkIn(context, ref, event),
      onOpenSwipe: (event) => _openSwipe(context, event),
      onWriteReview: (event) => _writeReview(context, event),
      onOpenDirections: (event) => _openDirections(ref, event),
      onAddToCalendar: (event) => _addToCalendar(ref, event),
      onResetCheckInError: () =>
          EventBookingController.selfCheckInMutation.reset(ref),
    );
  }

  List<DashboardQuickAction> _buildQuickActions(BuildContext context) {
    return dashboardQuickActions(
      onCalendarPressed: () => context.push(Routes.calendarScreen.path),
      onSavedEventsPressed: () => context.push(Routes.savedEventsScreen.path),
    );
  }

  void _openEvent(BuildContext context, Event event) {
    context.pushNamed(
      Routes.dashboardEventDetailScreen.name,
      pathParameters: {'clubId': event.clubId, 'eventId': event.id},
      extra: event,
    );
  }

  void _openDirections(WidgetRef ref, Event event) {
    unawaited(
      ref
          .read(externalLinkControllerProvider)
          .openExternal(directionsUriForEvent(event)),
    );
  }

  void _addToCalendar(WidgetRef ref, Event event) {
    unawaited(ref.read(eventCalendarControllerProvider).addToCalendar(event));
  }

  void _openSwipe(BuildContext context, Event event) {
    context.pushNamed(
      Routes.swipeEventScreen.name,
      pathParameters: {'eventId': event.id},
    );
  }

  void _writeReview(BuildContext context, Event event) {
    showWriteReviewSheet(
      context: context,
      clubId: event.clubId,
      eventId: event.id,
      reviewer: widget.user,
    );
  }

  void _checkIn(BuildContext context, WidgetRef ref, Event event) {
    unawaited(
      EventBookingController.selfCheckInMutation
          .run(ref, (tx) async {
            await tx
                .get(eventBookingControllerProvider.notifier)
                .selfCheckIn(eventId: event.id);
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
                      pathParameters: {
                        'clubId': event.clubId,
                        'eventId': event.id,
                      },
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
          })
          .catchError((_) {}),
    );
  }

  Future<void> _connectStride(BuildContext context) async {
    if (_isConnectingStride) return;
    setState(() => _isConnectingStride = true);
    final actions = ref.read(dashboardStrideActionsProvider);
    final granted = await actions.requestActivityReadPermission();
    actions.refreshWeeklyActivity();
    if (!mounted || !context.mounted) return;
    setState(() => _isConnectingStride = false);
    if (!granted) {
      showCatchErrorSnackBar(
        context,
        const PermissionException('Health access was not granted.'),
        errorContext: AppErrorContext.dashboard,
      );
    }
  }

  Future<void> _installHealthConnect() async {
    if (_isInstallingHealthConnect) return;
    setState(() => _isInstallingHealthConnect = true);
    final actions = ref.read(dashboardStrideActionsProvider);
    await actions.installHealthConnect();
    actions.refreshWeeklyActivity();
    if (!mounted) return;
    setState(() => _isInstallingHealthConnect = false);
  }

  List<Widget> _buildRecommendedEventsSection({
    required WidgetRef ref,
    required DashboardSectionModel<List<DashboardEventRecommendation>>
    recommendationsSection,
  }) {
    if (recommendationsSection.isLoading) {
      return const [
        DashboardSectionStateCard(
          message: 'Loading recommended events...',
          isLoading: true,
        ),
      ];
    }

    final error = recommendationsSection.error;
    if (error != null) {
      return [
        CatchInlineErrorState.fromError(
          error,
          context: AppErrorContext.dashboard,
          compact: true,
          onRetry: () => ref.invalidate(dashboardRecommendedEventsProvider),
        ),
      ];
    }

    final recommendations =
        recommendationsSection.data ?? const <DashboardEventRecommendation>[];
    return recommendations.isEmpty
        ? const []
        : [Recommendations(recommendations: recommendations)];
  }
}

class FollowedClubsRailSkeleton extends StatelessWidget {
  const FollowedClubsRailSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Your clubs', style: CatchTextStyles.titleL(context)),
        const SizedBox(height: CatchSpacing.s3),
        Row(
          children: [
            for (var index = 0; index < 3; index += 1) ...[
              if (index > 0) const SizedBox(width: CatchSpacing.micro14),
              Column(
                children: [
                  CatchSkeleton.circle(size: 64),
                  const SizedBox(height: CatchSpacing.micro6),
                  CatchSkeleton.text(width: CatchLayout.skeletonTextShortWidth),
                ],
              ),
            ],
          ],
        ),
      ],
    );
  }
}
