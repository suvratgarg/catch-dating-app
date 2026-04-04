import 'package:catch_dating_app/appUser/data/app_user_repository.dart';
import 'package:catch_dating_app/appUser/domain/app_user.dart';
import 'package:catch_dating_app/auth/auth_repository.dart';
import 'package:catch_dating_app/imageUploads/presentation/photo_grid.dart';
import 'package:catch_dating_app/imageUploads/presentation/photo_upload_controller.dart';
import 'package:catch_dating_app/publicProfile/domain/public_profile.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:catch_dating_app/swipes/presentation/profile_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen>
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
    final appUserAsync = ref.watch(appUserStreamProvider);
    final uploadState = ref.watch(photoUploadControllerProvider);

    ref.listen(photoUploadControllerProvider, (_, state) {
      if (state.uploadError != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Upload failed. Please try again.')),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit profile',
            onPressed: () => context.pushNamed(Routes.editProfileScreen.name),
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Sign out',
            onPressed: () => ref.read(authRepositoryProvider).signOut(),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Profile'),
            Tab(text: 'Preview'),
          ],
        ),
      ),
      body: appUserAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (user) {
          if (user == null) return const SizedBox.shrink();

          return TabBarView(
            controller: _tabController,
            children: [
              _ProfileTab(user: user, uploadState: uploadState, ref: ref),
              _PreviewTab(profile: publicProfileFromAppUser(user)),
            ],
          );
        },
      ),
    );
  }
}

// ── Profile tab ───────────────────────────────────────────────────────────────

class _ProfileTab extends StatelessWidget {
  const _ProfileTab({
    required this.user,
    required this.uploadState,
    required this.ref,
  });

  final AppUser user;
  final PhotoUploadState uploadState;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        PhotoGrid(
          photoUrls: user.photoUrls,
          loadingIndices: uploadState.loadingIndices,
          onSlotTapped: (index) => ref
              .read(photoUploadControllerProvider.notifier)
              .pickAndUpload(index),
        ),
        const SizedBox(height: 20),
        Center(
          child: Text(
            '${user.name}, ${user.age}',
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        if (user.bio.isNotEmpty) ...[
          const SizedBox(height: 8),
          Center(
            child: Text(
              user.bio,
              textAlign: TextAlign.center,
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
          ),
        ],

        // ── Identity ───────────────────────────────────────────────────────

        const SizedBox(height: 24),
        const Divider(),
        const SizedBox(height: 8),
        _InfoTile(
            icon: Icons.wc_outlined,
            label: 'Gender',
            value: user.gender.label),
        _InfoTile(
            icon: Icons.cake_outlined,
            label: 'Age',
            value: '${user.age} years old'),
        _InfoTile(
            icon: Icons.email_outlined, label: 'Email', value: user.email),
        _InfoTile(
            icon: Icons.phone_outlined,
            label: 'Phone',
            value: user.phoneNumber),
        if (user.height != null)
          _InfoTile(
              icon: Icons.height_outlined,
              label: 'Height',
              value: '${user.height} cm'),

        // ── Background ─────────────────────────────────────────────────────

        if (user.occupation != null ||
            user.company != null ||
            user.education != null ||
            user.religion != null ||
            user.languages.isNotEmpty) ...[
          const SizedBox(height: 8),
          const Divider(),
          const SizedBox(height: 8),
          if (user.occupation != null)
            _InfoTile(
                icon: Icons.work_outline,
                label: 'Job title',
                value: user.occupation!),
          if (user.company != null)
            _InfoTile(
                icon: Icons.business_outlined,
                label: 'Company',
                value: user.company!),
          if (user.education != null)
            _InfoTile(
                icon: Icons.school_outlined,
                label: 'Education',
                value: user.education!.label),
          if (user.religion != null)
            _InfoTile(
                icon: Icons.volunteer_activism_outlined,
                label: 'Religion',
                value: user.religion!.label),
          if (user.languages.isNotEmpty)
            _InfoTile(
                icon: Icons.language_outlined,
                label: 'Languages',
                value: user.languages.map((l) => l.label).join(', ')),
        ],

        // ── Intentions ─────────────────────────────────────────────────────

        if (user.relationshipGoal != null) ...[
          const SizedBox(height: 8),
          const Divider(),
          const SizedBox(height: 8),
          _InfoTile(
              icon: Icons.favorite_outline,
              label: 'Looking for',
              value: user.relationshipGoal!.label),
        ],

        // ── Lifestyle ──────────────────────────────────────────────────────

        if (user.drinking != null ||
            user.smoking != null ||
            user.workout != null ||
            user.diet != null ||
            user.children != null) ...[
          const SizedBox(height: 8),
          const Divider(),
          const SizedBox(height: 8),
          if (user.drinking != null)
            _InfoTile(
                icon: Icons.local_bar_outlined,
                label: 'Drinking',
                value: user.drinking!.label),
          if (user.smoking != null)
            _InfoTile(
                icon: Icons.smoke_free_outlined,
                label: 'Smoking',
                value: user.smoking!.label),
          if (user.workout != null)
            _InfoTile(
                icon: Icons.fitness_center_outlined,
                label: 'Workout',
                value: user.workout!.label),
          if (user.diet != null)
            _InfoTile(
                icon: Icons.restaurant_outlined,
                label: 'Diet',
                value: user.diet!.label),
          if (user.children != null)
            _InfoTile(
                icon: Icons.child_care_outlined,
                label: 'Children',
                value: user.children!.label),
        ],

        const SizedBox(height: 32),
      ],
    );
  }
}

// ── Preview tab ───────────────────────────────────────────────────────────────

class _PreviewTab extends StatelessWidget {
  const _PreviewTab({required this.profile});

  final PublicProfile profile;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ProfileCard(profile: profile),
    );
  }
}

// ── Info tile ─────────────────────────────────────────────────────────────────

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, color: colorScheme.onSurfaceVariant),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                    fontSize: 12, color: colorScheme.onSurfaceVariant),
              ),
              Text(value, style: Theme.of(context).textTheme.bodyLarge),
            ],
          ),
        ],
      ),
    );
  }
}
