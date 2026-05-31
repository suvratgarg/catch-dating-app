import 'package:catch_dating_app/clubs/data/club_membership_repository.dart';
import 'package:catch_dating_app/core/city_catalog.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_error_state.dart';
import 'package:catch_dating_app/core/widgets/catch_loading_indicator.dart';
import 'package:catch_dating_app/core/widgets/catch_top_bar.dart';
import 'package:catch_dating_app/dashboard/presentation/dashboard_full_view_model.dart';
import 'package:catch_dating_app/dashboard/presentation/widgets/dashboard_empty.dart';
import 'package:catch_dating_app/dashboard/presentation/widgets/dashboard_full.dart';
import 'package:catch_dating_app/dashboard/presentation/widgets/dashboard_sliver_header.dart';
import 'package:catch_dating_app/events/data/event_repository.dart';
import 'package:catch_dating_app/notifications/data/activity_notification_repository.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:catch_dating_app/user_profile/data/user_profile_repository.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(watchUserProfileProvider);

    return userAsync.when(
      loading: () => const _DashboardLoadingScreen(),
      error: (e, _) => _DashboardErrorScreen(
        message: 'Unable to load your dashboard.',
        onRetry: () => ref.invalidate(watchUserProfileProvider),
      ),
      data: (user) {
        if (user == null) {
          return _DashboardHomeScreen(
            header: _DashboardHeaderModel.empty(),
            dashboardSliver: const DashboardEmptySliverBody(),
          );
        }

        final membershipsAsync = ref.watch(
          watchActiveClubMembershipsForUserProvider(user.uid),
        );
        final signedUpEventsAsync = ref.watch(
          watchSignedUpEventsProvider(user.uid),
        );
        if (membershipsAsync.isLoading || signedUpEventsAsync.isLoading) {
          return const _DashboardLoadingScreen();
        }
        if (membershipsAsync.hasError) {
          return _DashboardErrorScreen(
            message: 'Unable to load your clubs.',
            onRetry: () => ref.invalidate(
              watchActiveClubMembershipsForUserProvider(user.uid),
            ),
          );
        }
        return signedUpEventsAsync.when(
          loading: () => const _DashboardLoadingScreen(),
          error: (e, _) => _DashboardErrorScreen(
            message: 'Unable to load your booked events.',
            onRetry: () =>
                ref.invalidate(watchSignedUpEventsProvider(user.uid)),
          ),
          data: (signedUpEvents) {
            final followedClubIds =
                membershipsAsync.asData?.value
                    .map((membership) => membership.clubId)
                    .toList(growable: false) ??
                const <String>[];
            final viewModel = ref.watch(
              dashboardFullViewModelProvider(
                signedUpEvents: signedUpEvents,
                user: user,
                uid: user.uid,
                followedClubIds: followedClubIds,
              ),
            );

            final showEmptyDashboard =
                signedUpEvents.isEmpty && viewModel.arrivalAction == null;

            return _DashboardHomeScreen(
              header: showEmptyDashboard
                  ? _DashboardHeaderModel.empty()
                  : _DashboardHeaderModel.full(context, user),
              dashboardSliver: showEmptyDashboard
                  ? DashboardEmptySliverBody(
                      weeklyActivitySection: viewModel.weeklyActivitySection,
                      followedClubIds: followedClubIds,
                      hostedClubShortcut: viewModel.hostedClubShortcut,
                    )
                  : DashboardFullSliverBody(
                      viewModel: viewModel,
                      user: user,
                      followedClubIds: followedClubIds,
                    ),
              notificationAction: _NotificationsAction(uid: user.uid),
            );
          },
        );
      },
    );
  }
}

class _DashboardHomeScreen extends StatelessWidget {
  const _DashboardHomeScreen({
    required this.header,
    required this.dashboardSliver,
    this.notificationAction,
  });

  final _DashboardHeaderModel header;
  final Widget dashboardSliver;
  final Widget? notificationAction;

  @override
  Widget build(BuildContext context) {
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
}

class _DashboardHeaderModel {
  const _DashboardHeaderModel({required this.eyebrow, required this.title});

  final String eyebrow;
  final String title;

  factory _DashboardHeaderModel.empty() {
    return _DashboardHeaderModel(
      eyebrow: 'WELCOME TO CATCH',
      title: "Let's find your first event",
    );
  }

  factory _DashboardHeaderModel.full(BuildContext context, UserProfile user) {
    final firstName = user.greetingDisplayName;
    return _DashboardHeaderModel(
      eyebrow: DashboardFull.dayCity(cityLabel(user.city)).toUpperCase(),
      title: '${DashboardFull.greeting()}, $firstName',
    );
  }
}

class _NotificationsAction extends ConsumerWidget {
  const _NotificationsAction({required this.uid});

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

    return _NotificationBellButton(
      unreadCount: unreadCount,
      onPressed: () => context.pushNamed(Routes.notificationsScreen.name),
    );
  }
}

class _NotificationBellButton extends StatelessWidget {
  const _NotificationBellButton({
    required this.unreadCount,
    required this.onPressed,
  });

  final int unreadCount;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final badgeLabel = unreadCount > 99 ? '99+' : '$unreadCount';

    return SizedBox.square(
      dimension: CatchLayout.eventInfoTileExtent,
      child: Badge(
        isLabelVisible: unreadCount > 0,
        label: Text(
          badgeLabel,
          style: CatchTextStyles.statusLabel(context, color: t.primaryInk),
        ),
        backgroundColor: t.primary,
        alignment: Alignment.topRight,
        offset: const Offset(-2, 2),
        child: Align(
          alignment: Alignment.center,
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

class _DashboardLoadingScreen extends StatelessWidget {
  const _DashboardLoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: CatchLoadingIndicator());
  }
}

class _DashboardErrorScreen extends StatelessWidget {
  const _DashboardErrorScreen({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return CatchErrorScaffold(
      title: 'Dashboard unavailable',
      message: message,
      onRetry: onRetry,
    );
  }
}
