import 'package:catch_dating_app/clubs/data/club_membership_repository.dart';
import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_badge.dart';
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

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(dashboardHomeScreenStateProvider);

    return switch (state.status) {
      DashboardHomeScreenStatus.loading => _buildDashboardLoadingScreen(
        context,
      ),
      DashboardHomeScreenStatus.error => _buildDashboardErrorScreen(
        error: state.error!.error,
        fallbackMessage: state.error!.fallbackMessage,
        onRetry: () => _retryDashboardLoad(ref, state.error!),
      ),
      DashboardHomeScreenStatus.empty => _buildDashboardEmptyHomeScreen(
        context,
      ),
      DashboardHomeScreenStatus.full => _buildDashboardHomeScreen(
        context,
        header: state.header,
        dashboardSliver: DashboardFullSliverBody(
          viewModel: state.viewModel!,
          user: state.user!,
          followedClubIds: state.followedClubIds,
        ),
        notificationAction: _buildNotificationsAction(
          context,
          ref,
          uid: state.notificationUid!,
        ),
      ),
    };
  }
}

void _retryDashboardLoad(WidgetRef ref, DashboardHomeLoadError error) {
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
}

Widget _buildDashboardEmptyHomeScreen(BuildContext context) {
  final t = CatchTokens.of(context);

  return Scaffold(
    backgroundColor: t.bg,
    body: SafeArea(
      bottom: false,
      child: Semantics(
        label: 'Home',
        child: const CustomScrollView(slivers: [DashboardEmptySliverBody()]),
      ),
    ),
  );
}

Widget _buildDashboardHomeScreen(
  BuildContext context, {
  required DashboardHomeHeaderModel header,
  required Widget dashboardSliver,
  Widget? notificationAction,
}) {
  final t = CatchTokens.of(context);

  return Scaffold(
    backgroundColor: t.bg,
    body: SafeArea(
      bottom: false,
      child: Semantics(
        label: 'Home',
        child: CustomScrollView(
          slivers: [
            ...DashboardSliverHeader(
              eyebrow: header.eyebrow,
              title: header.title,
              actions: [?notificationAction],
            ).buildSlivers(context),
            dashboardSliver,
          ],
        ),
      ),
    ),
  );
}

Widget _buildNotificationsAction(
  BuildContext context,
  WidgetRef ref, {
  required String uid,
}) {
  final notificationsAsync = ref.watch(watchActivityNotificationsProvider(uid));
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
    final badgeLabel = unreadCount > 99 ? '99+' : '$unreadCount';

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

Widget _buildDashboardLoadingScreen(BuildContext context) {
  final t = CatchTokens.of(context);

  return Scaffold(
    backgroundColor: t.bg,
    body: SafeArea(
      bottom: false,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildDashboardLoadingHeader()),
          SliverToBoxAdapter(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: CatchLayout.maxContentWidth,
                ),
                child: CatchSectionStack(
                  padding: CatchInsets.pageBodyUnderHeader,
                  gap: CatchSpacing.micro18,
                  children: [
                    _buildDashboardFocusLoadingCard(context),
                    _buildDashboardStrideLoadingCard(context),
                    _buildDashboardQuickActionsLoadingRow(),
                    _buildDashboardRecommendedLoadingSection(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildDashboardLoadingHeader() {
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

Widget _buildDashboardFocusLoadingCard(BuildContext context) {
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

Widget _buildDashboardStrideLoadingCard(BuildContext context) {
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

Widget _buildDashboardQuickActionsLoadingRow() {
  return Row(
    children: [
      for (var i = 0; i < 2; i++) ...[
        Expanded(
          child: CatchSkeleton.box(
            height: CatchLayout.dashboardQuickActionSkeletonHeight,
            radius: CatchRadius.md,
          ),
        ),
        if (i == 0) gapW12,
      ],
    ],
  );
}

Widget _buildDashboardRecommendedLoadingSection() {
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

Widget _buildDashboardErrorScreen({
  required Object error,
  required String fallbackMessage,
  required VoidCallback onRetry,
}) {
  if (error is AppException) {
    return CatchErrorScaffold.fromError(
      error,
      context: AppErrorContext.dashboard,
      onRetry: onRetry,
    );
  }
  return CatchErrorScaffold(
    title: 'Dashboard unavailable',
    message: fallbackMessage,
    onRetry: onRetry,
  );
}
