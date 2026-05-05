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
  late final TabController _tabController;
  late final ScrollController _previewScrollController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _previewScrollController = ScrollController();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _previewScrollController.dispose();
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
      body: SafeArea(
        bottom: false,
        child: Semantics(
          label: 'Profile tabs',
          hint: 'Swipe left or right to switch between Edit and Preview.',
          child: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) =>
                ProfileSliverHeader(
                  controller: _tabController,
                ).buildSlivers(context),
            body: userProfileAsync.when<Widget>(
              loading: () => const Center(child: CatchLoadingIndicator()),
              error: (e, _) => Center(child: CatchErrorText(e)),
              data: (user) {
                if (user == null) {
                  return const _ProfileUnavailableBody();
                }

                return TabBarView(
                  controller: _tabController,
                  children: [
                    CustomScrollView(
                      key: const PageStorageKey('profile-edit-tab-scroll'),
                      slivers: [
                        ProfileTabSliverBody(
                          user: user,
                          uploadState: uploadState,
                        ),
                      ],
                    ),
                    CustomScrollView(
                      key: const PageStorageKey('profile-preview-tab-scroll'),
                      slivers: [
                        _PreviewTabSliverBody(
                          profile: publicProfileFromUserProfile(user),
                          scrollController: _previewScrollController,
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
  });

  final PublicProfile profile;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(
        CatchSpacing.s4,
        CatchSpacing.s2,
        CatchSpacing.s4,
        CatchSpacing.s6,
      ),
      sliver: SliverFillRemaining(
        child: PreviewTab(profile: profile, scrollController: scrollController),
      ),
    );
  }
}
