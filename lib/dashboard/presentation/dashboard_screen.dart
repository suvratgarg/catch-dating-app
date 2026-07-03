import 'package:catch_dating_app/clubs/data/club_membership_repository.dart';
import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_badge.dart';
import 'package:catch_dating_app/core/widgets/catch_count_badge.dart';
import 'package:catch_dating_app/core/widgets/catch_error_state.dart';
import 'package:catch_dating_app/core/widgets/catch_section_layout.dart';
import 'package:catch_dating_app/core/widgets/catch_skeleton.dart';
import 'package:catch_dating_app/core/widgets/catch_skeleton_layouts.dart';
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

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(dashboardHomeScreenStateProvider);

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
          followedClubIds: state.followedClubIds,
        ),
        notificationAction: NotificationsAction(uid: state.notificationUid!),
      ),
    };
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
      onPressed: () => context.pushNamed(Routes.notificationsScreen.name),
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

    return SizedBox.square(
      dimension: CatchLayout.eventInfoTileExtent,
      child: CatchIconBadge(
        isLabelVisible: unreadCount > 0,
        label: badgeLabel,
        child: Align(
          child: CatchTopBarIconAction(
            icon: unreadCount > 0
                ? CatchIcons.notificationsRounded
                : CatchIcons.notificationsNoneRounded,
            tooltip: 'Notifications',
            onPressed: onPressed,
          ),
        ),
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

class DashboardStrideLoadingCard extends StatelessWidget {
  const DashboardStrideLoadingCard({super.key});

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return CatchSurface(
      borderColor: t.line,
      padding: CatchInsets.content,
      child: Row(
        children: [
          CatchSkeleton.circle(size: CatchLayout.skeletonMediaTileExtent),
          gapW14,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CatchSkeleton.text(width: CatchLayout.skeletonTextWideWidth),
                gapH8,
                CatchSkeleton.textBlock(lines: 2),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DashboardRecommendedLoadingSection extends StatelessWidget {
  const DashboardRecommendedLoadingSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CatchSkeleton.text(width: CatchLayout.skeletonTextSectionWidth),
        gapH12,
        const CatchSkeletonList(
          count: 2,
          height: CatchLayout.dashboardRecommendedEventSkeletonHeight,
        ),
      ],
    );
  }
}
