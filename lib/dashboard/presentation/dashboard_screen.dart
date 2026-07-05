import 'package:catch_dating_app/clubs/data/club_membership_repository.dart';
import 'package:catch_dating_app/core/analytics/app_analytics.dart';
import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_badge.dart';
import 'package:catch_dating_app/core/widgets/catch_count_badge.dart';
import 'package:catch_dating_app/core/widgets/catch_error_state.dart';
import 'package:catch_dating_app/core/widgets/catch_section_layout.dart';
import 'package:catch_dating_app/core/widgets/catch_skeleton.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/core/widgets/catch_top_bar.dart';
import 'package:catch_dating_app/dashboard/presentation/dashboard_full_view_model.dart';
import 'package:catch_dating_app/dashboard/presentation/widgets/dashboard_empty.dart';
import 'package:catch_dating_app/dashboard/presentation/widgets/dashboard_full.dart';
import 'package:catch_dating_app/dashboard/presentation/widgets/dashboard_sliver_header.dart';
import 'package:catch_dating_app/events/data/event_repository.dart';
import 'package:catch_dating_app/exceptions/app_exception.dart';
import 'package:catch_dating_app/notifications/data/activity_notification_repository.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:catch_dating_app/user_profile/data/user_profile_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

part 'dashboard_empty_home_screen.dart';
part 'dashboard_error_screen.dart';
part 'dashboard_home_screen.dart';
part 'dashboard_loading_screen.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  String? _lastLoggedHomeState;
  final Set<String> _loggedModuleImpressions = <String>{};

  @override
  Widget build(BuildContext context) {
    final now = ref.watch(dashboardNowProvider);
    final state = ref.watch(dashboardHomeScreenStateProvider);
    _logHomeAnalytics(state, now: now);

    return switch (state.status) {
      DashboardHomeScreenStatus.loading => const DashboardLoadingScreen(),
      DashboardHomeScreenStatus.error => DashboardErrorScreen(
        error: state.error!.error,
        fallbackMessage: state.error!.fallbackMessage,
        onRetry: () {
          final error = state.error!;
          switch (error.retryTarget) {
            case DashboardHomeRetryTarget.userProfile:
              ref.invalidate(watchUserProfileProvider);
            case DashboardHomeRetryTarget.memberships:
              final uid = error.uid;
              if (uid != null) {
                ref.invalidate(watchActiveClubMembershipsForUserProvider(uid));
              }
            case DashboardHomeRetryTarget.signedUpEvents:
              final uid = error.uid;
              if (uid != null) {
                ref.invalidate(watchSignedUpEventsProvider(uid));
              }
          }
        },
      ),
      DashboardHomeScreenStatus.empty => const DashboardEmptyHomeScreen(),
      DashboardHomeScreenStatus.full => DashboardHomeScreen(
        header: state.header,
        dashboardSliver: DashboardFullSliverBody(
          viewModel: state.viewModel!,
          user: state.user!,
        ),
        actions: [
          Consumer(
            builder: (context, ref, child) {
              return CatchIconAction(
                icon: CatchIcons.calendarMonthOutlined,
                tooltip: 'Calendar',
                onPressed: () {
                  ref
                      .read(appAnalyticsProvider)
                      .logEvent(
                        AnalyticsEvents.homeActionTap,
                        parameters: {
                          AnalyticsParameters.homeModule: 'header',
                          AnalyticsParameters.homeAction: 'calendar',
                        },
                      );
                  context.push(Routes.calendarScreen.path);
                },
              );
            },
          ),
          NotificationsAction(uid: state.notificationUid!),
        ],
      ),
    };
  }

  void _logHomeAnalytics(
    DashboardHomeScreenState state, {
    required DateTime now,
  }) {
    if (state.status == DashboardHomeScreenStatus.loading ||
        state.status == DashboardHomeScreenStatus.error) {
      return;
    }

    final analytics = ref.read(appAnalyticsProvider);
    final liveState = dashboardHomeLiveStateFor(state, now: now);
    final stateValue = liveState.analyticsValue;
    if (_lastLoggedHomeState != stateValue) {
      _lastLoggedHomeState = stateValue;
      analytics.logEvent(
        AnalyticsEvents.homeOpened,
        parameters: {AnalyticsParameters.homeState: stateValue},
      );
    }

    for (final module in dashboardHomeModuleImpressionsFor(state)) {
      final key = '$stateValue:$module';
      if (!_loggedModuleImpressions.add(key)) continue;
      analytics.logEvent(
        AnalyticsEvents.homeModuleImpression,
        parameters: {AnalyticsParameters.homeModule: module},
      );
      if (module == 'club_posts') {
        analytics.logEvent(
          AnalyticsEvents.clubPostImpression,
          parameters: {AnalyticsParameters.surface: 'home'},
        );
      }
    }
  }
}

class NotificationsAction extends ConsumerWidget {
  const NotificationsAction({super.key, required this.uid});

  final String uid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(
      watchActivityNotificationsProvider(uid),
    );
    final unreadCount =
        notificationsAsync.asData?.value
            .where((notification) => notification.isUnread)
            .length ??
        0;

    return DashboardNotificationBellButton(
      unreadCount: unreadCount,
      onPressed: () {
        ref
            .read(appAnalyticsProvider)
            .logEvent(
              AnalyticsEvents.homeActionTap,
              parameters: {
                AnalyticsParameters.homeModule: 'header',
                AnalyticsParameters.homeAction: 'notifications',
              },
            );
        context.pushNamed(Routes.notificationsScreen.name);
      },
    );
  }
}

class DashboardNotificationBellButton extends StatelessWidget {
  const DashboardNotificationBellButton({
    super.key,
    required this.unreadCount,
    required this.onPressed,
  });

  final int unreadCount;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final badgeLabel = catchCountLabel(unreadCount);

    return CatchIconBadge(
      isLabelVisible: unreadCount > 0,
      label: badgeLabel,
      child: CatchIconAction(
        icon: unreadCount > 0
            ? CatchIcons.notificationsRounded
            : CatchIcons.notificationsNoneRounded,
        tooltip: 'Notifications',
        onPressed: onPressed,
      ),
    );
  }
}

class DashboardLoadingHeader extends StatelessWidget {
  const DashboardLoadingHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: CatchInsets.screenTitleBlockCompact,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CatchSkeleton.text(width: CatchLayout.skeletonTextEyebrowWidth),
                gapH8,
                CatchSkeleton.text(width: CatchLayout.skeletonTextHeroWidth),
              ],
            ),
          ),
          gapW12,
          CatchSkeleton.box(
            width: CatchLayout.eventInfoTileExtent,
            height: CatchLayout.eventInfoTileExtent,
            radius: CatchRadius.sm,
          ),
        ],
      ),
    );
  }
}

class DashboardFocusLoadingCard extends StatelessWidget {
  const DashboardFocusLoadingCard({super.key});

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return CatchSurface(
      borderColor: t.line,
      padding: CatchInsets.content,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CatchSkeleton.text(width: CatchLayout.skeletonTextLabelWidth),
          gapH12,
          CatchSkeleton.text(width: CatchLayout.skeletonTextBannerWidth),
          gapH12,
          CatchSkeleton.textBlock(lines: 2),
          gapH16,
          Row(
            children: [
              Expanded(
                child: CatchSkeleton.box(
                  height: CatchLayout.controlMdMinHeight,
                  radius: CatchRadius.sm,
                ),
              ),
              gapW10,
              Expanded(
                child: CatchSkeleton.box(
                  height: CatchLayout.controlMdMinHeight,
                  radius: CatchRadius.sm,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
