import 'dart:math' as math;

import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_empty_state.dart';
import 'package:catch_dating_app/core/widgets/catch_error_state.dart';
import 'package:catch_dating_app/core/widgets/catch_loading_indicator.dart';
import 'package:catch_dating_app/image_uploads/presentation/photo_upload_controller.dart';
import 'package:catch_dating_app/public_profile/domain/public_profile.dart';
import 'package:catch_dating_app/user_profile/data/user_profile_repository.dart';
import 'package:catch_dating_app/user_profile/presentation/widgets/preview_tab.dart';
import 'package:catch_dating_app/user_profile/presentation/widgets/profile_sliver_header.dart';
import 'package:catch_dating_app/user_profile/presentation/widgets/profile_tab.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

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
    _tabController = TabController(length: 2, vsync: this);
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

    final userProfileAsync = ref.watch(watchUserProfileProvider);
    final uploadState = ref.watch(photoUploadControllerProvider);

    ref.listen(photoUploadControllerProvider, (_, state) {
      if (state.uploadError != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Upload failed. Please try again.')),
        );
      }
    });

    return Scaffold(
      backgroundColor: t.bg,
      body: SafeArea(
        bottom: false,
        child: Semantics(
          label: 'Profile tabs',
          hint: 'Swipe left or right to switch between Edit and Preview.',
          child: NestedScrollView(
            controller: _outerScrollController,
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              final headerSlivers = ProfileSliverHeader(
                controller: _tabController,
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
            body: userProfileAsync.when<Widget>(
              loading: () => const Center(child: CatchLoadingIndicator()),
              error: (e, _) => CatchErrorState.fromError(
                e,
                context: AppErrorContext.profile,
                onRetry: () => ref.invalidate(watchUserProfileProvider),
              ),
              data: (user) {
                if (user == null) {
                  return const _ProfileUnavailableBody();
                }

                return TabBarView(
                  controller: _tabController,
                  children: [
                    _ProfileTabScrollView(
                      scrollKey: const PageStorageKey(
                        'profile-edit-tab-scroll',
                      ),
                      slivers: [
                        ProfileTabSliverBody(
                          user: user,
                          uploadState: uploadState,
                        ),
                      ],
                    ),
                    _ProfileTabScrollView(
                      scrollKey: const PageStorageKey(
                        'profile-preview-tab-scroll',
                      ),
                      slivers: [
                        _PreviewTabSliverBody(
                          profile: publicProfileFromUserProfile(user),
                          scrollController: _previewScrollController,
                          onForwardScroll: _handlePreviewForwardScroll,
                          onLeadingOverscroll: _handlePreviewLeadingOverscroll,
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileTabScrollView extends StatelessWidget {
  const _ProfileTabScrollView({required this.scrollKey, required this.slivers});

  final PageStorageKey<String> scrollKey;
  final List<Widget> slivers;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      key: scrollKey,
      slivers: [
        SliverOverlapInjector(
          handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
        ),
        ...slivers,
      ],
    );
  }
}

class _ProfileUnavailableBody extends StatelessWidget {
  const _ProfileUnavailableBody();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CatchEmptyState(
        icon: Icons.person_off_outlined,
        title: 'Profile not available',
        message: 'Finish onboarding or sign in again to load your profile.',
        surface: false,
        iconStyle: CatchEmptyStateIconStyle.plain,
      ),
    );
  }
}

class _PreviewTabSliverBody extends StatelessWidget {
  const _PreviewTabSliverBody({
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
        padding: profileTabBodyPadding,
        child: PreviewTab(
          profile: profile,
          scrollController: scrollController,
          scrollPhysics: _PreviewHeaderBridgeScrollPhysics(
            onForwardScroll: onForwardScroll,
          ),
          bottomPadding: 0,
          onLeadingOverscroll: onLeadingOverscroll,
        ),
      ),
    );
  }
}

class _PreviewHeaderBridgeScrollPhysics extends ClampingScrollPhysics {
  const _PreviewHeaderBridgeScrollPhysics({
    required this.onForwardScroll,
    super.parent,
  });

  final double Function(double scrollDelta) onForwardScroll;

  @override
  _PreviewHeaderBridgeScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return _PreviewHeaderBridgeScrollPhysics(
      onForwardScroll: onForwardScroll,
      parent: buildParent(ancestor),
    );
  }

  @override
  double applyPhysicsToUserOffset(ScrollMetrics position, double offset) {
    final childOffset = super.applyPhysicsToUserOffset(position, offset);
    if (childOffset >= 0) return childOffset;

    final consumedByHeader = onForwardScroll(-childOffset);
    if (consumedByHeader <= 0) return childOffset;

    return childOffset + math.min(consumedByHeader, -childOffset);
  }
}
