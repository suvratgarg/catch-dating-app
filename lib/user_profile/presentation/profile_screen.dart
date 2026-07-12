import 'dart:math' as math;

import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_empty_state.dart';
import 'package:catch_dating_app/core/widgets/catch_error_snackbar.dart';
import 'package:catch_dating_app/core/widgets/catch_error_state.dart';
import 'package:catch_dating_app/core/widgets/catch_pager_focus_boundary.dart';
import 'package:catch_dating_app/core/widgets/catch_top_bar.dart';
import 'package:catch_dating_app/image_uploads/shared/photo_upload_controller.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:catch_dating_app/public_profile/domain/public_profile.dart';
import 'package:catch_dating_app/swipes/shared/profile_surface/profile_surface.dart';
import 'package:catch_dating_app/user_profile/data/user_profile_repository.dart';
import 'package:catch_dating_app/user_profile/presentation/self_profile_screen_state.dart';
import 'package:catch_dating_app/user_profile/presentation/self_profile_screen_state_provider.dart';
import 'package:catch_dating_app/user_profile/presentation/widgets/preview_scroll_physics.dart';
import 'package:catch_dating_app/user_profile/presentation/widgets/preview_tab.dart';
import 'package:catch_dating_app/user_profile/presentation/widgets/profile_insights_tab.dart';
import 'package:catch_dating_app/user_profile/presentation/widgets/profile_sliver_header.dart';
import 'package:catch_dating_app/user_profile/presentation/widgets/profile_tab.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _profileTabCount = 3;

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key, this.initialTabIndex = 0})
    : assert(initialTabIndex >= 0 && initialTabIndex < _profileTabCount);

  final int initialTabIndex;

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final ScrollController _outerScrollController;
  late final ScrollController _previewScrollController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: _profileTabCount,
      initialIndex: widget.initialTabIndex,
      vsync: this,
    );
    _outerScrollController = ScrollController();
    _previewScrollController = ScrollController();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _outerScrollController.dispose();
    _previewScrollController.dispose();
    super.dispose();
  }

  void _handlePreviewLeadingOverscroll(double overscroll) {
    if (!_outerScrollController.hasClients || overscroll >= 0) return;

    final position = _outerScrollController.position;
    final nextOffset = (_outerScrollController.offset + overscroll).clamp(
      position.minScrollExtent,
      position.maxScrollExtent,
    );
    _outerScrollController.jumpTo(nextOffset);
  }

  double _handlePreviewForwardScroll(double scrollDelta) {
    if (!_outerScrollController.hasClients || scrollDelta <= 0) return 0;

    final position = _outerScrollController.position;
    final remainingOuterScroll = position.maxScrollExtent - position.pixels;
    if (remainingOuterScroll <= 0) return 0;

    final consumedByHeader = math.min(scrollDelta, remainingOuterScroll);
    _outerScrollController.jumpTo(
      (position.pixels + consumedByHeader).clamp(
        position.minScrollExtent,
        position.maxScrollExtent,
      ),
    );
    return consumedByHeader;
  }

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    final screenState = ref.watch(selfProfileScreenStateProvider);

    ref.listen(photoUploadControllerProvider, (_, state) {
      final uploadError = state.uploadError;
      if (uploadError != null) {
        // Surface the mapped exception copy (e.g. "That image is too large")
        // instead of a generic hardcoded message.
        showCatchErrorSnackBar(
          context,
          uploadError,
          errorContext: AppErrorContext.profile,
        );
      }
    });

    return Scaffold(
      backgroundColor: t.bg,
      body: SafeArea(
        bottom: false,
        child: Semantics(
          label: context.l10n.userProfileProfileScreenLabelProfileTabs,
          hint: context.l10n.userProfileProfileScreenBodyDragLeftOrRight,
          child: NestedScrollView(
            controller: _outerScrollController,
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              final headerSlivers = CatchSliverHeader(
                title: CatchScreenHeaderTitle.block(
                  title: context.l10n.userProfileProfileScreenTitleYourProfile,
                  actions: [ProfileSettingsButton()],
                ),
                bottomHeight: CatchLayout.tabRailHeight,
                bottom: ProfileTabBar(controller: _tabController),
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
            body: SelfProfileTabBody(
              state: screenState,
              controller: _tabController,
              previewScrollController: _previewScrollController,
              onPreviewForwardScroll: _handlePreviewForwardScroll,
              onPreviewLeadingOverscroll: _handlePreviewLeadingOverscroll,
              onRetry: () => _handleRetry(screenState.retryIntent),
            ),
          ),
        ),
      ),
    );
  }

  void _handleRetry(SelfProfileRetryIntent? intent) {
    switch (intent) {
      case SelfProfileRetryIntent.reloadProfile:
        ref.invalidate(watchUserProfileProvider);
      case null:
        break;
    }
  }
}

class SelfProfileTabBody extends StatelessWidget {
  const SelfProfileTabBody({
    super.key,
    required this.state,
    required this.controller,
    required this.previewScrollController,
    required this.onPreviewForwardScroll,
    required this.onPreviewLeadingOverscroll,
    this.onRetry,
  });

  final SelfProfileScreenState state;
  final TabController controller;
  final ScrollController previewScrollController;
  final double Function(double scrollDelta) onPreviewForwardScroll;
  final ValueChanged<double> onPreviewLeadingOverscroll;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    switch (state.status) {
      case SelfProfileRouteStatus.loading:
        return TabBarView(
          controller: controller,
          children: [
            const ProfileTabScrollView(
              scrollKey: PageStorageKey('profile-edit-tab-loading'),
              slivers: [ProfileTabSkeletonSliverBody()],
            ),
            ProfileTabScrollView(
              scrollKey: const PageStorageKey('profile-preview-tab-loading'),
              slivers: [
                PreviewTabSkeletonSliverBody(
                  scrollController: previewScrollController,
                  onForwardScroll: onPreviewForwardScroll,
                  onLeadingOverscroll: onPreviewLeadingOverscroll,
                ),
              ],
            ),
            const ProfileTabScrollView(
              scrollKey: PageStorageKey('profile-insights-tab-loading'),
              slivers: [ProfileInsightsTabSliverBody()],
            ),
          ],
        );
      case SelfProfileRouteStatus.error:
        return CatchErrorState.fromError(
          state.error!,
          context: AppErrorContext.profile,
          onRetry: onRetry,
        );
      case SelfProfileRouteStatus.unavailable:
        return Center(
          child: CatchEmptyState(
            icon: CatchIcons.personOffOutlined,
            title:
                context.l10n.userProfileProfileScreenTitleProfileNotAvailable,
            message: context
                .l10n
                .userProfileProfileScreenMessageFinishOnboardingOrSign,
          ),
        );
      case SelfProfileRouteStatus.ready:
        final user = state.user!;
        final previewProfile = state.previewProfile!;
        return TabBarView(
          controller: controller,
          children: [
            ProfileTabScrollView(
              scrollKey: const PageStorageKey('profile-edit-tab-scroll'),
              slivers: [
                ProfileTabSliverBody(
                  user: user,
                  uploadState: state.uploadState,
                ),
              ],
            ),
            ProfileTabScrollView(
              scrollKey: const PageStorageKey('profile-preview-tab-scroll'),
              slivers: [
                PreviewTabSliverBody(
                  profile: previewProfile,
                  scrollController: previewScrollController,
                  onForwardScroll: onPreviewForwardScroll,
                  onLeadingOverscroll: onPreviewLeadingOverscroll,
                ),
              ],
            ),
            const ProfileTabScrollView(
              scrollKey: PageStorageKey('profile-insights-tab-scroll'),
              slivers: [ProfileInsightsTabSliverBody()],
            ),
          ],
        );
    }
  }
}

class ProfileTabScrollView extends StatelessWidget {
  const ProfileTabScrollView({
    super.key,
    required this.scrollKey,
    required this.slivers,
  });

  final PageStorageKey<String> scrollKey;
  final List<Widget> slivers;

  @override
  Widget build(BuildContext context) {
    return CatchPagerFocusBoundary(
      child: Builder(
        builder: (context) {
          return CustomScrollView(
            key: scrollKey,
            slivers: [
              SliverOverlapInjector(
                handle: NestedScrollView.sliverOverlapAbsorberHandleFor(
                  context,
                ),
              ),
              ...slivers,
            ],
          );
        },
      ),
    );
  }
}

class PreviewTabSkeletonSliverBody extends StatelessWidget {
  const PreviewTabSkeletonSliverBody({
    super.key,
    required this.scrollController,
    required this.onForwardScroll,
    required this.onLeadingOverscroll,
  });

  final ScrollController scrollController;
  final double Function(double scrollDelta) onForwardScroll;
  final ValueChanged<double> onLeadingOverscroll;

  @override
  Widget build(BuildContext context) {
    return SliverFillRemaining(
      child: Padding(
        padding: const EdgeInsets.only(top: CatchSpacing.s2),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: CatchLayout.maxContentWidth,
            ),
            child: ProfileSurfaceSkeleton(
              scrollController: scrollController,
              scrollPhysics: PreviewHeaderBridgeScrollPhysics(
                onForwardScroll: onForwardScroll,
              ),
              bottomPadding: 0,
              onLeadingOverscroll: onLeadingOverscroll,
            ),
          ),
        ),
      ),
    );
  }
}

class PreviewTabSliverBody extends StatelessWidget {
  const PreviewTabSliverBody({
    super.key,
    required this.profile,
    required this.scrollController,
    required this.onForwardScroll,
    required this.onLeadingOverscroll,
  });

  final PublicProfile profile;
  final ScrollController scrollController;
  final double Function(double scrollDelta) onForwardScroll;
  final ValueChanged<double> onLeadingOverscroll;

  @override
  Widget build(BuildContext context) {
    return SliverFillRemaining(
      child: Padding(
        padding: const EdgeInsets.only(top: CatchSpacing.s2),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: CatchLayout.maxContentWidth,
            ),
            child: PreviewTab(
              profile: profile,
              scrollController: scrollController,
              scrollPhysics: PreviewHeaderBridgeScrollPhysics(
                onForwardScroll: onForwardScroll,
              ),
              bottomPadding: 0,
              onLeadingOverscroll: onLeadingOverscroll,
            ),
          ),
        ),
      ),
    );
  }
}
