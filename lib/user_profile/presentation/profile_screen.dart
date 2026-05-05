import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_empty_state.dart';
import 'package:catch_dating_app/core/widgets/catch_error_text.dart';
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
  static const _tabSwipeDistanceThreshold = 80.0;
  static const _tabSwipeVelocityThreshold = 250.0;

  late final TabController _tabController;
  int _selectedTabIndex = 0;
  double _horizontalDragDistance = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this)
      ..addListener(_handleTabChanged);
  }

  void _handleTabChanged() {
    if (_selectedTabIndex == _tabController.index) return;
    setState(() => _selectedTabIndex = _tabController.index);
  }

  void _handleHorizontalDragStart(DragStartDetails details) {
    _horizontalDragDistance = 0;
  }

  void _handleHorizontalDragUpdate(DragUpdateDetails details) {
    _horizontalDragDistance += details.primaryDelta ?? 0;
  }

  void _handleHorizontalDragEnd(DragEndDetails details) {
    final velocity = details.primaryVelocity;
    final isDistanceSwipe =
        _horizontalDragDistance.abs() >= _tabSwipeDistanceThreshold;
    final isVelocitySwipe =
        velocity != null && velocity.abs() >= _tabSwipeVelocityThreshold;
    if (!isDistanceSwipe && !isVelocitySwipe) {
      return;
    }

    final swipeOffset = isDistanceSwipe ? _horizontalDragDistance : -velocity!;
    final direction = swipeOffset < 0 ? 1 : -1;
    final nextIndex = (_tabController.index + direction).clamp(
      0,
      _tabController.length - 1,
    );
    if (nextIndex == _tabController.index) return;

    _tabController.animateTo(nextIndex);
  }

  @override
  void dispose() {
    _tabController
      ..removeListener(_handleTabChanged)
      ..dispose();
    super.dispose();
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
      body: Semantics(
        label: 'Profile tabs',
        hint: 'Swipe left or right to switch between Edit and Preview.',
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onHorizontalDragStart: _handleHorizontalDragStart,
          onHorizontalDragUpdate: _handleHorizontalDragUpdate,
          onHorizontalDragEnd: _handleHorizontalDragEnd,
          child: CustomScrollView(
            slivers: [
              ...ProfileSliverHeader(
                controller: _tabController,
              ).buildSlivers(context),
              ...userProfileAsync.when<List<Widget>>(
                loading: () => const [
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(child: CatchLoadingIndicator()),
                  ),
                ],
                error: (e, _) => [
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(child: CatchErrorText(e)),
                  ),
                ],
                data: (user) {
                  if (user == null) {
                    return const [_ProfileUnavailableSliver()];
                  }

                  if (_selectedTabIndex == 0) {
                    return [
                      ProfileTabSliverBody(
                        user: user,
                        uploadState: uploadState,
                      ),
                    ];
                  }

                  return [
                    _PreviewTabSliverBody(
                      profile: publicProfileFromUserProfile(user),
                    ),
                  ];
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileUnavailableSliver extends StatelessWidget {
  const _ProfileUnavailableSliver();

  @override
  Widget build(BuildContext context) {
    return const SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: CatchEmptyState(
          icon: Icons.person_off_outlined,
          title: 'Profile not available',
          message: 'Finish onboarding or sign in again to load your profile.',
          surface: false,
          iconStyle: CatchEmptyStateIconStyle.plain,
        ),
      ),
    );
  }
}

class _PreviewTabSliverBody extends StatelessWidget {
  const _PreviewTabSliverBody({required this.profile});

  final PublicProfile profile;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(
        CatchSpacing.s4,
        CatchSpacing.s2,
        CatchSpacing.s4,
        CatchSpacing.s6,
      ),
      sliver: SliverFillRemaining(child: PreviewTab(profile: profile)),
    );
  }
}
