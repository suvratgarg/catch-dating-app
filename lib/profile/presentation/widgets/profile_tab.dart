import 'package:catch_dating_app/app_user/domain/app_user.dart';
import 'package:catch_dating_app/constants/app_sizes.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/image_uploads/presentation/photo_grid.dart';
import 'package:catch_dating_app/image_uploads/presentation/photo_upload_controller.dart';
import 'package:catch_dating_app/profile/presentation/widgets/profile_info_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileTab extends ConsumerWidget {
  const ProfileTab({
    super.key,
    required this.user,
    required this.uploadState,
  });

  final AppUser user;
  final PhotoUploadState uploadState;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = CatchTokens.of(context);

    return ListView(
      padding: const EdgeInsets.all(Sizes.p24),
      children: [
        PhotoGrid(
          photoUrls: user.photoUrls,
          loadingIndices: uploadState.loadingIndices,
          onSlotTapped: (index) => ref
              .read(photoUploadControllerProvider.notifier)
              .pickAndUpload(index),
        ),
        gapH20,
        Center(
          child: Text(
            '${user.name}, ${user.age}',
            style: CatchTextStyles.displayLg(context)
                .copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        if (user.bio.isNotEmpty) ...[
          gapH8,
          Center(
            child: Text(
              user.bio,
              textAlign: TextAlign.center,
              style: CatchTextStyles.bodyMd(context, color: t.ink2),
            ),
          ),
        ],

        gapH24,
        const Divider(),
        gapH8,
        ProfileInfoTile(icon: Icons.wc_outlined, label: 'Gender', value: user.gender.label),
        ProfileInfoTile(icon: Icons.cake_outlined, label: 'Age', value: '${user.age} years old'),
        ProfileInfoTile(icon: Icons.email_outlined, label: 'Email', value: user.email),
        ProfileInfoTile(icon: Icons.phone_outlined, label: 'Phone', value: user.phoneNumber),
        if (user.height != null)
          ProfileInfoTile(icon: Icons.height_outlined, label: 'Height', value: '${user.height} cm'),

        if (user.occupation != null ||
            user.company != null ||
            user.education != null ||
            user.religion != null ||
            user.languages.isNotEmpty) ...[
          gapH8,
          const Divider(),
          gapH8,
          if (user.occupation != null)
            ProfileInfoTile(icon: Icons.work_outline, label: 'Job title', value: user.occupation!),
          if (user.company != null)
            ProfileInfoTile(icon: Icons.business_outlined, label: 'Company', value: user.company!),
          if (user.education != null)
            ProfileInfoTile(icon: Icons.school_outlined, label: 'Education', value: user.education!.label),
          if (user.religion != null)
            ProfileInfoTile(icon: Icons.volunteer_activism_outlined, label: 'Religion', value: user.religion!.label),
          if (user.languages.isNotEmpty)
            ProfileInfoTile(
              icon: Icons.language_outlined,
              label: 'Languages',
              value: user.languages.map((l) => l.label).join(', '),
            ),
        ],

        if (user.relationshipGoal != null) ...[
          gapH8,
          const Divider(),
          gapH8,
          ProfileInfoTile(
            icon: Icons.favorite_outline,
            label: 'Looking for',
            value: user.relationshipGoal!.label,
          ),
        ],

        if (user.drinking != null ||
            user.smoking != null ||
            user.workout != null ||
            user.diet != null ||
            user.children != null) ...[
          gapH8,
          const Divider(),
          gapH8,
          if (user.drinking != null)
            ProfileInfoTile(icon: Icons.local_bar_outlined, label: 'Drinking', value: user.drinking!.label),
          if (user.smoking != null)
            ProfileInfoTile(icon: Icons.smoke_free_outlined, label: 'Smoking', value: user.smoking!.label),
          if (user.workout != null)
            ProfileInfoTile(icon: Icons.fitness_center_outlined, label: 'Workout', value: user.workout!.label),
          if (user.diet != null)
            ProfileInfoTile(icon: Icons.restaurant_outlined, label: 'Diet', value: user.diet!.label),
          if (user.children != null)
            ProfileInfoTile(icon: Icons.child_care_outlined, label: 'Children', value: user.children!.label),
        ],

        gapH32,
      ],
    );
  }
}
