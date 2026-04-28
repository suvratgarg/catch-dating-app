import 'package:catch_dating_app/constants/app_sizes.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/public_profile/data/public_profile_repository.dart';
import 'package:catch_dating_app/safety/data/safety_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _deleting = false;

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
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
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

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(Sizes.p16),
        children: [
          Text('Safety', style: CatchTextStyles.displaySm(context)),
          gapH12,
          const _BlockedAccountsSection(),
          gapH24,
          Text('Account', style: CatchTextStyles.displaySm(context)),
          gapH12,
          DecoratedBox(
            decoration: BoxDecoration(
              color: t.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: t.line),
            ),
            child: ListTile(
              leading: Icon(Icons.delete_outline, color: t.primary),
              title: const Text('Delete account'),
              subtitle: const Text(
                'Remove your profile and sign out of Catch.',
              ),
              trailing: _deleting
                  ? const SizedBox.square(
                      dimension: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.chevron_right_rounded),
              onTap: _deleting ? null : _confirmDeleteAccount,
            ),
          ),
        ],
      ),
    );
  }
}

class _BlockedAccountsSection extends ConsumerWidget {
  const _BlockedAccountsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final blockedUsersAsync = ref.watch(blockedUsersProvider);
    final t = CatchTokens.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: t.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: t.line),
      ),
      child: blockedUsersAsync.when(
        loading: () => const Padding(
          padding: EdgeInsets.all(Sizes.p16),
          child: Center(child: CircularProgressIndicator()),
        ),
        error: (_, _) => Padding(
          padding: const EdgeInsets.all(Sizes.p16),
          child: Text(
            'Unable to load blocked accounts.',
            style: CatchTextStyles.bodyMd(context, color: t.ink2),
          ),
        ),
        data: (blockedUsers) {
          if (blockedUsers.isEmpty) {
            return Padding(
              padding: const EdgeInsets.all(Sizes.p16),
              child: Text(
                'No blocked accounts.',
                style: CatchTextStyles.bodyMd(context, color: t.ink2),
              ),
            );
          }

          return Column(
            children: [
              for (final blockedUser in blockedUsers)
                _BlockedAccountTile(blockedUser: blockedUser),
            ],
          );
        },
      ),
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
      trailing: TextButton(
        onPressed: () => ref
            .read(safetyRepositoryProvider)
            .unblockUser(targetUserId: blockedUser.uid),
        child: const Text('Unblock'),
      ),
    );
  }
}
