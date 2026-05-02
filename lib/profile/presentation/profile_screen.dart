import 'package:catch_dating_app/auth/auth_repository.dart';
import 'package:catch_dating_app/core/widgets/catch_top_bar.dart';
import 'package:catch_dating_app/image_uploads/presentation/photo_upload_controller.dart';
import 'package:catch_dating_app/profile/presentation/widgets/preview_tab.dart';
import 'package:catch_dating_app/profile/presentation/widgets/profile_tab.dart';
import 'package:catch_dating_app/public_profile/domain/public_profile.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:catch_dating_app/user_profile/data/user_profile_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfileAsync = ref.watch(userProfileStreamProvider);
    final uploadState = ref.watch(photoUploadControllerProvider);

    ref.listen(photoUploadControllerProvider, (_, state) {
      if (state.uploadError != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Upload failed. Please try again.')),
        );
      }
    });

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: CatchTopBar(
          title: 'Profile',
          showBackButton: false,
          actions: [
            CatchTopBarIconAction(
              icon: Icons.notifications_none_rounded,
              tooltip: 'Activity',
              onPressed: () => context.pushNamed(Routes.activityScreen.name),
            ),
            CatchTopBarIconAction(
              icon: Icons.settings_outlined,
              tooltip: 'Settings',
              onPressed: () => context.pushNamed(Routes.settingsScreen.name),
            ),
            CatchTopBarMenuAction<String>(
              tooltip: 'More profile actions',
              onSelected: (value) {
                if (value == 'payments') {
                  context.pushNamed(Routes.paymentHistoryScreen.name);
                } else if (value == 'edit') {
                  context.pushNamed(Routes.editProfileScreen.name);
                } else if (value == 'signOut') {
                  ref.read(authRepositoryProvider).signOut();
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem(
                  value: 'payments',
                  child: Text('Payment history'),
                ),
                PopupMenuItem(value: 'edit', child: Text('Edit profile')),
                PopupMenuItem(value: 'signOut', child: Text('Sign out')),
              ],
            ),
          ],
          bottom: const CatchTopBarTabBar(
            tabs: [
              Tab(text: 'Profile'),
              Tab(text: 'Preview'),
            ],
          ),
        ),
        body: userProfileAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
          data: (user) {
            if (user == null) return const SizedBox.shrink();

            return TabBarView(
              children: [
                ProfileTab(user: user, uploadState: uploadState),
                PreviewTab(profile: publicProfileFromUserProfile(user)),
              ],
            );
          },
        ),
      ),
    );
  }
}
