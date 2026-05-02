import 'package:catch_dating_app/constants/app_sizes.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/core/widgets/catch_top_bar.dart';
import 'package:catch_dating_app/core/widgets/section_header.dart';
import 'package:catch_dating_app/core/widgets/settings_row.dart';
import 'package:catch_dating_app/public_profile/data/public_profile_repository.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:catch_dating_app/safety/data/safety_repository.dart';
import 'package:catch_dating_app/user_profile/data/user_profile_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _deleting = false;
  bool _showOnMap = true;
  bool _newCatches = true;
  bool _runReminders = true;
  bool _weeklyDigest = false;
  bool _didSeedFromProfile = false;

  Future<void> _savePref(String key, bool value) async {
    final uid = ref.read(userProfileStreamProvider).asData?.value?.uid;
    if (uid == null) return;
    await ref.read(userProfileRepositoryProvider).updatePreferences(
      uid: uid,
      prefsNewCatches: key == 'prefsNewCatches' ? value : null,
      prefsRunReminders: key == 'prefsRunReminders' ? value : null,
      prefsWeeklyDigest: key == 'prefsWeeklyDigest' ? value : null,
      prefsShowOnMap: key == 'prefsShowOnMap' ? value : null,
    );
  }

  Future<void> _confirmDeleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete account?'),
        content: const Text(
          'This removes your public profile, signs you out, and keeps only the '
          'minimal records required for safety and payment history.',
        ),
        actions: [
          CatchButton(
            label: 'Cancel',
            onPressed: () => Navigator.of(context).pop(false),
            variant: CatchButtonVariant.ghost,
            size: CatchButtonSize.sm,
          ),
          CatchButton(
            label: 'Delete',
            onPressed: () => Navigator.of(context).pop(true),
            variant: CatchButtonVariant.danger,
            size: CatchButtonSize.sm,
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _deleting = true);
    try {
      await ref.read(safetyRepositoryProvider).requestAccountDeletion();
    } finally {
      if (mounted) setState(() => _deleting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final userProfile = ref.watch(userProfileStreamProvider).asData?.value;
    final phoneNumber = userProfile?.phoneNumber ?? '';

    if (!_didSeedFromProfile && userProfile != null) {
      _didSeedFromProfile = true;
      _showOnMap = userProfile.prefsShowOnMap;
      _newCatches = userProfile.prefsNewCatches;
      _runReminders = userProfile.prefsRunReminders;
      _weeklyDigest = userProfile.prefsWeeklyDigest;
    }

    return Scaffold(
      appBar: const CatchTopBar(title: 'Settings'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          CatchSpacing.s5,
          Sizes.p12,
          CatchSpacing.s5,
          Sizes.p32,
        ),
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionHeader(title: 'Account'),
              _SettingsCard(
                children: [
                  SettingsRow(
                    label: 'Phone',
                    value: phoneNumber.isNotEmpty ? '+91 $phoneNumber' : '',
                    icon: Icons.phone_outlined,
                  ),
                  SettingsRow(
                    label: 'Payment history',
                    value: 'Bookings and receipts',
                    icon: Icons.receipt_long_outlined,
                    onTap: () =>
                        context.pushNamed(Routes.paymentHistoryScreen.name),
                  ),
                ],
              ),
            ],
          ),
          gapH20,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionHeader(title: 'Discovery'),
              _SettingsCard(
                children: [
                  SettingsRow(
                    label: 'Who can see me',
                    value: 'Runners on my runs',
                    icon: Icons.visibility_outlined,
                  ),
                  SettingsRow(
                    label: 'Show me on map',
                    icon: Icons.map_outlined,
                    trailing: Switch.adaptive(
                      value: _showOnMap,
                      onChanged: (value) {
                        setState(() => _showOnMap = value);
                        _savePref('prefsShowOnMap', value);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
          gapH20,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionHeader(title: 'Notifications'),
              _SettingsCard(
                children: [
                  SettingsRow(
                    label: 'Activity',
                    value: 'Matches and run reminders',
                    icon: Icons.notifications_none_rounded,
                    onTap: () => context.pushNamed(Routes.activityScreen.name),
                  ),
                  SettingsRow(
                    label: 'New catches',
                    icon: Icons.favorite_outline,
                    trailing: Switch.adaptive(
                      value: _newCatches,
                      onChanged: (value) {
                        setState(() => _newCatches = value);
                        _savePref('prefsNewCatches', value);
                      },
                    ),
                  ),
                  SettingsRow(
                    label: 'Run reminders',
                    icon: Icons.directions_run_outlined,
                    trailing: Switch.adaptive(
                      value: _runReminders,
                      onChanged: (value) {
                        setState(() => _runReminders = value);
                        _savePref('prefsRunReminders', value);
                      },
                    ),
                  ),
                  SettingsRow(
                    label: 'Weekly digest',
                    icon: Icons.mark_email_read_outlined,
                    trailing: Switch.adaptive(
                      value: _weeklyDigest,
                      onChanged: (value) {
                        setState(() => _weeklyDigest = value);
                        _savePref('prefsWeeklyDigest', value);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
          gapH20,
          const SectionHeader(title: 'Safety'),
          gapH8,
          const _BlockedAccountsSection(),
          gapH20,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionHeader(title: 'About'),
              _SettingsCard(
                children: [
                  SettingsRow(
                    label: 'Help & support',
                    value: 'Contact us',
                    icon: Icons.help_outline,
                    onTap: () => launchUrl(
                      Uri.parse('https://catchdates.com/help'),
                      mode: LaunchMode.externalApplication,
                    ),
                  ),
                  SettingsRow(
                    label: 'Privacy',
                    value: 'Policy',
                    icon: Icons.lock_outline,
                    onTap: () => launchUrl(
                      Uri.parse('https://catchdates.com/privacy'),
                      mode: LaunchMode.externalApplication,
                    ),
                  ),
                  SettingsRow(
                    label: 'Terms',
                    value: 'Legal',
                    icon: Icons.description_outlined,
                    onTap: () => launchUrl(
                      Uri.parse('https://catchdates.com/terms'),
                      mode: LaunchMode.externalApplication,
                    ),
                  ),
                ],
              ),
            ],
          ),
          gapH20,
          _SettingsCard(
            children: [
              SettingsRow(
                label: 'Delete account',
                value: 'Remove your profile',
                icon: Icons.delete_outline,
                danger: true,
                trailing: _deleting
                    ? const SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : null,
                onTap: _deleting ? null : _confirmDeleteAccount,
              ),
            ],
          ),
          gapH20,
          Center(
            child: Text(
              'Catch v1.0 · made for runners in India',
              style: CatchTextStyles.bodyS(context, color: t.ink3),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return CatchSurface(
      borderColor: t.line,
      child: Column(children: children),
    );
  }
}

class _BlockedAccountsSection extends ConsumerWidget {
  const _BlockedAccountsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final blockedUsersAsync = ref.watch(blockedUsersProvider);
    final t = CatchTokens.of(context);

    return _SettingsCard(
      children: [
        blockedUsersAsync.when(
          loading: () => const Padding(
            padding: EdgeInsets.all(Sizes.p16),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (_, _) => Padding(
            padding: const EdgeInsets.all(Sizes.p16),
            child: Text(
              'Unable to load blocked accounts.',
              style: CatchTextStyles.bodyM(context, color: t.ink2),
            ),
          ),
          data: (blockedUsers) {
            if (blockedUsers.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(Sizes.p16),
                child: Text(
                  'No blocked accounts.',
                  style: CatchTextStyles.bodyM(context, color: t.ink2),
                ),
              );
            }

            return Column(
              children: [
                for (var i = 0; i < blockedUsers.length; i++) ...[
                  _BlockedAccountTile(blockedUser: blockedUsers[i]),
                  if (i < blockedUsers.length - 1)
                    Divider(color: t.line, height: 1),
                ],
              ],
            );
          },
        ),
      ],
    );
  }
}

class _BlockedAccountTile extends ConsumerWidget {
  const _BlockedAccountTile({required this.blockedUser});

  final BlockedUser blockedUser;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(publicProfileProvider(blockedUser.uid));
    final profile = profileAsync.asData?.value;

    return ListTile(
      leading: CircleAvatar(
        child: Text((profile?.name ?? 'U').characters.first.toUpperCase()),
      ),
      title: Text(profile?.name ?? 'Blocked account'),
      subtitle: Text(blockedUser.source),
      trailing: CatchButton(
        label: 'Unblock',
        onPressed: () => ref
            .read(safetyRepositoryProvider)
            .unblockUser(targetUserId: blockedUser.uid),
        variant: CatchButtonVariant.ghost,
        size: CatchButtonSize.sm,
      ),
    );
  }
}
