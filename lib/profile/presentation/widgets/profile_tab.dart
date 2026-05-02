import 'package:catch_dating_app/constants/app_sizes.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/image_uploads/presentation/photo_grid.dart';
import 'package:catch_dating_app/image_uploads/presentation/photo_upload_controller.dart';
import 'package:catch_dating_app/profile/presentation/widgets/profile_info_section.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ProfileTab extends ConsumerWidget {
  const ProfileTab({super.key, required this.user, required this.uploadState});

  final UserProfile user;
  final PhotoUploadState uploadState;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = CatchTokens.of(context);
    final basics = [
      ProfileInfoEntry(
        icon: Icons.wc_outlined,
        label: 'Gender',
        value: user.gender.label,
      ),
      ProfileInfoEntry(
        icon: Icons.cake_outlined,
        label: 'Age',
        value: '${user.age} years old',
      ),
      if (user.email.isNotEmpty)
        ProfileInfoEntry(
          icon: Icons.email_outlined,
          label: 'Email',
          value: user.email,
        ),
      ProfileInfoEntry(
        icon: Icons.phone_outlined,
        label: 'Phone',
        value: user.phoneNumber,
      ),
      if (user.height != null)
        ProfileInfoEntry(
          icon: Icons.height_outlined,
          label: 'Height',
          value: '${user.height} cm',
        ),
    ];
    final background = [
      if (user.occupation != null)
        ProfileInfoEntry(
          icon: Icons.work_outline,
          label: 'Job title',
          value: user.occupation!,
        ),
      if (user.company != null)
        ProfileInfoEntry(
          icon: Icons.business_outlined,
          label: 'Company',
          value: user.company!,
        ),
      if (user.education != null)
        ProfileInfoEntry(
          icon: Icons.school_outlined,
          label: 'Education',
          value: user.education!.label,
        ),
      if (user.religion != null)
        ProfileInfoEntry(
          icon: Icons.volunteer_activism_outlined,
          label: 'Religion',
          value: user.religion!.label,
        ),
      if (user.languages.isNotEmpty)
        ProfileInfoEntry(
          icon: Icons.language_outlined,
          label: 'Languages',
          value: user.languages.map((l) => l.label).join(', '),
        ),
    ];
    final intentions = [
      if (user.relationshipGoal != null)
        ProfileInfoEntry(
          icon: Icons.favorite_outline,
          label: 'Looking for',
          value: user.relationshipGoal!.label,
        ),
    ];
    final lifestyle = [
      if (user.drinking != null)
        ProfileInfoEntry(
          icon: Icons.local_bar_outlined,
          label: 'Drinking',
          value: user.drinking!.label,
        ),
      if (user.smoking != null)
        ProfileInfoEntry(
          icon: Icons.smoke_free_outlined,
          label: 'Smoking',
          value: user.smoking!.label,
        ),
      if (user.workout != null)
        ProfileInfoEntry(
          icon: Icons.fitness_center_outlined,
          label: 'Workout',
          value: user.workout!.label,
        ),
      if (user.diet != null)
        ProfileInfoEntry(
          icon: Icons.restaurant_outlined,
          label: 'Diet',
          value: user.diet!.label,
        ),
      if (user.children != null)
        ProfileInfoEntry(
          icon: Icons.child_care_outlined,
          label: 'Children',
          value: user.children!.label,
        ),
    ];

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        CatchSpacing.s5,
        Sizes.p8,
        CatchSpacing.s5,
        Sizes.p32,
      ),
      children: [
        _ProfileOverviewCard(user: user, tokens: t),
        gapH14,
        _ProfileStatsStrip(user: user, tokens: t),
        if (user.bio.isNotEmpty) ...[
          gapH14,
          _PromptCard(eyebrow: 'On a perfect run', text: user.bio, tokens: t),
        ],
        gapH14,
        _RunningIdentityCard(user: user, tokens: t),
        gapH14,
        CatchButton(
          label: 'Preview as others see you',
          onPressed: () => DefaultTabController.of(context).animateTo(1),
          variant: CatchButtonVariant.secondary,
          fullWidth: true,
        ),
        gapH24,
        Text('Photos', style: CatchTextStyles.titleL(context)),
        gapH12,
        PhotoGrid(
          photoUrls: user.photoUrls,
          loadingIndices: uploadState.loadingIndices,
          onSlotTapped: (index) => ref
              .read(photoUploadControllerProvider.notifier)
              .pickAndUpload(index),
        ),
        gapH24,
        ProfileInfoSection(entries: basics),
        ProfileInfoSection(entries: background),
        ProfileInfoSection(entries: intentions),
        ProfileInfoSection(entries: lifestyle),
        gapH32,
      ],
    );
  }
}

class _ProfileOverviewCard extends StatelessWidget {
  const _ProfileOverviewCard({required this.user, required this.tokens});

  final UserProfile user;
  final CatchTokens tokens;

  @override
  Widget build(BuildContext context) {
    final t = tokens;

    return CatchSurface(
      borderColor: t.line,
      padding: const EdgeInsets.all(Sizes.p16),
      child: Row(
        children: [
          _ProfileAvatar(user: user, tokens: t),
          gapW14,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'YOUR PROFILE',
                  style: CatchTextStyles.labelM(
                    context,
                    color: t.ink3,
                  ).copyWith(fontWeight: FontWeight.w700, letterSpacing: 1.2),
                ),
                gapH4,
                Text(
                  '${user.name}, ${user.age}',
                  style: CatchTextStyles.displayM(context),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                gapH4,
                Text(
                  _profileSubtitle(user),
                  style: CatchTextStyles.bodyS(context, color: t.ink2),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          gapW12,
          CatchButton(
            label: 'Edit',
            onPressed: () => context.pushNamed(Routes.editProfileScreen.name),
            icon: const Icon(Icons.edit_outlined, size: 14),
            size: CatchButtonSize.sm,
            variant: CatchButtonVariant.secondary,
          ),
        ],
      ),
    );
  }

  static String _profileSubtitle(UserProfile user) {
    final parts = [
      if (user.occupation != null && user.occupation!.trim().isNotEmpty)
        user.occupation!.trim(),
      if (user.city != null) user.city!.label,
      user.sexualOrientation.label.toLowerCase(),
    ];
    return parts.join(' · ');
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({required this.user, required this.tokens});

  final UserProfile user;
  final CatchTokens tokens;

  @override
  Widget build(BuildContext context) {
    final t = tokens;

    return ClipOval(
      child: SizedBox(
        width: 72,
        height: 72,
        child: user.photoUrls.isNotEmpty
            ? Image.network(user.photoUrls.first, fit: BoxFit.cover)
            : DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [t.primary, t.accent, t.primarySoft],
                  ),
                ),
                child: Center(
                  child: Text(
                    user.name.characters.first.toUpperCase(),
                    style: CatchTextStyles.displayM(
                      context,
                      color: t.primaryInk,
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}

class _ProfileStatsStrip extends StatelessWidget {
  const _ProfileStatsStrip({required this.user, required this.tokens});

  final UserProfile user;
  final CatchTokens tokens;

  @override
  Widget build(BuildContext context) {
    final stats = [
      ('Photos', '${user.photoUrls.length}/6'),
      ('Pace', _RunningIdentityCard._paceRange(user)),
      ('Runs', _RunningIdentityCard._distanceSummary(user)),
    ];

    return Container(
      padding: const EdgeInsets.all(Sizes.p16),
      decoration: BoxDecoration(
        color: tokens.surface,
        borderRadius: BorderRadius.circular(CatchRadius.md),
        border: Border.all(color: tokens.line),
      ),
      child: Row(
        children: [
          for (var i = 0; i < stats.length; i++) ...[
            Expanded(
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        stats[i].$2,
                        style: CatchTextStyles.titleL(context),
                        maxLines: 1,
                        textAlign: TextAlign.center,
                        softWrap: false,
                      ),
                    ),
                  ),
                  gapH2,
                  Text(
                    stats[i].$1.toUpperCase(),
                    style: CatchTextStyles.labelM(context, color: tokens.ink3),
                  ),
                ],
              ),
            ),
            if (i < stats.length - 1)
              Container(width: 1, height: 38, color: tokens.line),
          ],
        ],
      ),
    );
  }
}

class _PromptCard extends StatelessWidget {
  const _PromptCard({
    required this.eyebrow,
    required this.text,
    required this.tokens,
  });

  final String eyebrow;
  final String text;
  final CatchTokens tokens;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Sizes.p16),
      decoration: BoxDecoration(
        color: tokens.surface,
        borderRadius: BorderRadius.circular(CatchRadius.md),
        border: Border.all(color: tokens.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(eyebrow.toUpperCase(), style: CatchTextStyles.labelM(context)),
          gapH6,
          Text(
            text,
            style: CatchTextStyles.titleL(context).copyWith(height: 1.2),
          ),
        ],
      ),
    );
  }
}

class _RunningIdentityCard extends StatelessWidget {
  const _RunningIdentityCard({required this.user, required this.tokens});

  final UserProfile user;
  final CatchTokens tokens;

  @override
  Widget build(BuildContext context) {
    final t = tokens;

    return Container(
      padding: const EdgeInsets.all(Sizes.p18),
      decoration: BoxDecoration(
        color: t.ink,
        borderRadius: BorderRadius.circular(CatchRadius.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'RUN PROFILE',
            style: CatchTextStyles.labelM(
              context,
              color: t.surface.withValues(alpha: 0.72),
            ).copyWith(fontWeight: FontWeight.w800, letterSpacing: 1.2),
          ),
          gapH8,
          Text(
            '${user.name.split(' ').first} runs ${_paceRange(user)}',
            style: CatchTextStyles.displayM(context, color: t.surface),
          ),
          gapH14,
          Row(
            children: [
              _RunStatPill(label: 'Pace', value: _paceRange(user), tokens: t),
              gapW8,
              _RunStatPill(
                label: 'Distance',
                value: _distanceSummary(user),
                tokens: t,
              ),
            ],
          ),
          if (user.runningReasons.isNotEmpty) ...[
            gapH12,
            Text(
              user.runningReasons.map((reason) => reason.label).join(' · '),
              style: CatchTextStyles.bodyS(
                context,
                color: t.surface.withValues(alpha: 0.76),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }

  static String _paceRange(UserProfile user) {
    return '${_formatPace(user.paceMinSecsPerKm)}-${_formatPace(user.paceMaxSecsPerKm)}/km';
  }

  static String _formatPace(int secsPerKm) {
    final minutes = secsPerKm ~/ 60;
    final seconds = secsPerKm % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  static String _distanceSummary(UserProfile user) {
    if (user.preferredDistances.isEmpty) return 'Any run';
    return user.preferredDistances.map((d) => d.label).take(2).join(', ');
  }
}

class _RunStatPill extends StatelessWidget {
  const _RunStatPill({
    required this.label,
    required this.value,
    required this.tokens,
  });

  final String label;
  final String value;
  final CatchTokens tokens;

  @override
  Widget build(BuildContext context) {
    final t = tokens;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: CatchTextStyles.bodyS(
                context,
                color: t.surface.withValues(alpha: 0.64),
              ),
            ),
            gapH2,
            Text(
              value,
              style: CatchTextStyles.mono(context, color: t.surface),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
