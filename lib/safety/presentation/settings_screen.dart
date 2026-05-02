import 'package:catch_dating_app/constants/app_sizes.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/core/widgets/catch_top_bar.dart';
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
          _SettingsGroup(
            title: 'Account',
            children: [
              _SettingsRow(
                label: 'Phone',
                value: phoneNumber.isNotEmpty ? '+91 $phoneNumber' : '',
                icon: Icons.phone_outlined,
                tokens: t,
              ),
              _SettingsRow(
                label: 'Payment history',
                value: 'Bookings and receipts',
                icon: Icons.receipt_long_outlined,
                tokens: t,
                onTap: () =>
                    context.pushNamed(Routes.paymentHistoryScreen.name),
              ),
            ],
          ),
          gapH20,
          _SettingsGroup(
            title: 'Discovery',
            children: [
              _SettingsRow(
                label: 'Who can see me',
                value: 'Runners on my runs',
                icon: Icons.visibility_outlined,
                tokens: t,
              ),
              _SettingsRow(
                label: 'Show me on map',
                icon: Icons.map_outlined,
                tokens: t,
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
          gapH20,
          _SettingsGroup(
            title: 'Notifications',
            children: [
              _SettingsRow(
                label: 'Activity',
                value: 'Matches and run reminders',
                icon: Icons.notifications_none_rounded,
                tokens: t,
                onTap: () => context.pushNamed(Routes.activityScreen.name),
              ),
              _SettingsRow(
                label: 'New catches',
                icon: Icons.favorite_outline,
                tokens: t,
                trailing: Switch.adaptive(
                  value: _newCatches,
                  onChanged: (value) {
                    setState(() => _newCatches = value);
                    _savePref('prefsNewCatches', value);
                  },
                ),
              ),
              _SettingsRow(
                label: 'Run reminders',
                icon: Icons.directions_run_outlined,
                tokens: t,
                trailing: Switch.adaptive(
                  value: _runReminders,
                  onChanged: (value) {
                    setState(() => _runReminders = value);
                    _savePref('prefsRunReminders', value);
                  },
                ),
              ),
              _SettingsRow(
                label: 'Weekly digest',
                icon: Icons.mark_email_read_outlined,
                tokens: t,
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
          gapH20,
          Text('Safety', style: CatchTextStyles.labelM(context)),
          gapH8,
          const _BlockedAccountsSection(),
          gapH20,
          _SettingsGroup(
            title: 'About',
            children: [
              _SettingsRow(
                label: 'Help & support',
                value: 'Contact us',
                icon: Icons.help_outline,
                tokens: t,
                onTap: () => launchUrl(
                  Uri.parse('https://catchdates.com/help'),
                  mode: LaunchMode.externalApplication,
                ),
              ),
              _SettingsRow(
                label: 'Privacy',
                value: 'Policy',
                icon: Icons.lock_outline,
                tokens: t,
                onTap: () => launchUrl(
                  Uri.parse('https://catchdates.com/privacy'),
                  mode: LaunchMode.externalApplication,
                ),
              ),
              _SettingsRow(
                label: 'Terms',
                value: 'Legal',
                icon: Icons.description_outlined,
                tokens: t,
                onTap: () => launchUrl(
                  Uri.parse('https://catchdates.com/terms'),
                  mode: LaunchMode.externalApplication,
                ),
              ),
            ],
          ),
          gapH20,
          _SettingsCard(
            children: [
              _SettingsRow(
                label: 'Delete account',
                value: 'Remove your profile',
                icon: Icons.delete_outline,
                tokens: t,
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

class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title.toUpperCase(), style: CatchTextStyles.labelM(context)),
        gapH8,
        _SettingsCard(children: children),
      ],
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

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.label,
    required this.icon,
    required this.tokens,
    this.value,
    this.trailing,
    this.onTap,
    this.danger = false,
  });

  final String label;
  final String? value;
  final IconData icon;
  final CatchTokens tokens;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final color = danger ? tokens.primary : tokens.ink;
    final child = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      child: Row(
        children: [
          Icon(icon, color: danger ? tokens.primary : tokens.ink2, size: 22),
          gapW12,
          Expanded(
            child: Text(
              label,
              style: CatchTextStyles.bodyM(
                context,
                color: color,
              ).copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          if (trailing != null)
            trailing!
          else ...[
            if (value != null)
              Flexible(
                child: Text(
                  value!,
                  textAlign: TextAlign.right,
                  style: CatchTextStyles.bodyS(context, color: tokens.ink2),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            if (onTap != null) ...[
              gapW6,
              Icon(Icons.chevron_right_rounded, color: tokens.ink3),
            ],
          ],
        ],
      ),
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(onTap: onTap, child: child),
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
