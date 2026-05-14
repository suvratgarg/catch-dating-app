import 'package:catch_dating_app/core/city_catalog.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_error_state.dart';
import 'package:catch_dating_app/core/widgets/catch_loading_indicator.dart';
import 'package:catch_dating_app/core/widgets/person_avatar.dart';
import 'package:catch_dating_app/dashboard/presentation/dashboard_full_view_model.dart';
import 'package:catch_dating_app/dashboard/presentation/widgets/activity_section.dart';
import 'package:catch_dating_app/dashboard/presentation/widgets/dashboard_empty.dart';
import 'package:catch_dating_app/dashboard/presentation/widgets/dashboard_full.dart';
import 'package:catch_dating_app/dashboard/presentation/widgets/dashboard_sliver_header.dart';
import 'package:catch_dating_app/dashboard/presentation/widgets/dashed_avatar.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:catch_dating_app/run_clubs/data/run_club_membership_repository.dart';
import 'package:catch_dating_app/runs/data/run_repository.dart';
import 'package:catch_dating_app/user_profile/data/user_profile_repository.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(watchUserProfileProvider);

    return userAsync.when(
      loading: () => const _DashboardLoadingScreen(),
      error: (e, _) => _DashboardErrorScreen(
        message: 'Unable to load your dashboard.',
        onRetry: () => ref.invalidate(watchUserProfileProvider),
      ),
      data: (user) {
        if (user == null) {
          return _DashboardTabbedScreen(
            controller: _tabController,
            header: _DashboardHeaderModel.empty(null),
            dashboardSliver: const DashboardEmptySliverBody(),
            activitySliver: const _SignedOutActivitySliverBody(),
          );
        }

        final membershipsAsync = ref.watch(
          watchActiveRunClubMembershipsForUserProvider(user.uid),
        );
        final signedUpRunsAsync = ref.watch(
          watchSignedUpRunsProvider(user.uid),
        );
        if (membershipsAsync.isLoading || signedUpRunsAsync.isLoading) {
          return const _DashboardLoadingScreen();
        }
        if (membershipsAsync.hasError) {
          return _DashboardErrorScreen(
            message: 'Unable to load your clubs.',
            onRetry: () => ref.invalidate(
              watchActiveRunClubMembershipsForUserProvider(user.uid),
            ),
          );
        }
        return signedUpRunsAsync.when(
          loading: () => const _DashboardLoadingScreen(),
          error: (e, _) => _DashboardErrorScreen(
            message: 'Unable to load your booked runs.',
            onRetry: () => ref.invalidate(watchSignedUpRunsProvider(user.uid)),
          ),
          data: (signedUpRuns) {
            final followedClubIds =
                membershipsAsync.asData?.value
                    .map((membership) => membership.clubId)
                    .toList(growable: false) ??
                const <String>[];
            final viewModel = ref.watch(
              dashboardFullViewModelProvider(
                signedUpRuns: signedUpRuns,
                user: user,
                uid: user.uid,
                followedClubIds: followedClubIds,
              ),
            );

            final showEmptyDashboard =
                signedUpRuns.isEmpty && viewModel.arrivalAction == null;

            return _DashboardTabbedScreen(
              controller: _tabController,
              header: showEmptyDashboard
                  ? _DashboardHeaderModel.empty(user)
                  : _DashboardHeaderModel.full(context, user),
              dashboardSliver: showEmptyDashboard
                  ? const DashboardEmptySliverBody()
                  : DashboardFullSliverBody(viewModel: viewModel, user: user),
              activitySliver: ActivitySliverBody(uid: user.uid),
            );
          },
        );
      },
    );
  }
}

class _DashboardTabbedScreen extends StatelessWidget {
  const _DashboardTabbedScreen({
    required this.controller,
    required this.header,
    required this.dashboardSliver,
    required this.activitySliver,
  });

  final TabController controller;
  final _DashboardHeaderModel header;
  final Widget dashboardSliver;
  final Widget activitySliver;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return Scaffold(
      backgroundColor: t.bg,
      body: SafeArea(
        bottom: false,
        child: Semantics(
          label: 'Home tabs',
          hint: 'Swipe left or right to switch between Dashboard and Activity.',
          child: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              final headerSlivers = DashboardSliverHeader(
                eyebrow: header.eyebrow,
                title: header.title,
                avatar: header.avatar,
                controller: controller,
              ).buildSlivers(context);
              final collapsibleSlivers = headerSlivers.take(
                headerSlivers.length - 1,
              );
              final pinnedSliver = headerSlivers.last;

              return [
                ...collapsibleSlivers,
                SliverOverlapAbsorber(
                  handle: NestedScrollView.sliverOverlapAbsorberHandleFor(
                    context,
                  ),
                  sliver: pinnedSliver,
                ),
              ];
            },
            body: TabBarView(
              controller: controller,
              children: [
                _DashboardTabScrollView(
                  scrollKey: const PageStorageKey('home-dashboard-tab-scroll'),
                  sliver: dashboardSliver,
                ),
                _DashboardTabScrollView(
                  scrollKey: const PageStorageKey('home-activity-tab-scroll'),
                  sliver: activitySliver,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DashboardTabScrollView extends StatelessWidget {
  const _DashboardTabScrollView({
    required this.scrollKey,
    required this.sliver,
  });

  final PageStorageKey<String> scrollKey;
  final Widget sliver;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      key: scrollKey,
      slivers: [
        SliverOverlapInjector(
          handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
        ),
        sliver,
      ],
    );
  }
}

class _DashboardHeaderModel {
  const _DashboardHeaderModel({
    required this.eyebrow,
    required this.title,
    required this.avatar,
  });

  final String eyebrow;
  final String title;
  final Widget avatar;

  factory _DashboardHeaderModel.empty(UserProfile? user) {
    final firstName = user?.greetingDisplayName ?? '';
    return _DashboardHeaderModel(
      eyebrow: 'WELCOME TO CATCH',
      title: "Let's find your first run",
      avatar: DashedAvatar(
        size: 42,
        imageUrl: user?.primaryPhotoThumbnailUrl,
        name: firstName,
      ),
    );
  }

  factory _DashboardHeaderModel.full(BuildContext context, UserProfile user) {
    final firstName = user.greetingDisplayName;
    final t = CatchTokens.of(context);
    return _DashboardHeaderModel(
      eyebrow: DashboardFull.dayCity(cityLabel(user.city)).toUpperCase(),
      title: '${DashboardFull.greeting()}, $firstName',
      avatar: Tooltip(
        message: 'Open profile',
        child: Semantics(
          button: true,
          label: 'Open profile',
          child: InkResponse(
            onTap: () => context.goNamed(Routes.profileScreen.name),
            radius: 26,
            customBorder: const CircleBorder(),
            child: PersonAvatar(
              size: 42,
              name: user.publicDisplayName,
              imageUrl: user.primaryPhotoThumbnailUrl,
              borderWidth: 2,
              borderColor: t.primary,
            ),
          ),
        ),
      ),
    );
  }
}

class _SignedOutActivitySliverBody extends StatelessWidget {
  const _SignedOutActivitySliverBody();

  @override
  Widget build(BuildContext context) {
    return const SliverFillRemaining(
      hasScrollBody: false,
      child: Center(child: ActivitySignedOutState()),
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
