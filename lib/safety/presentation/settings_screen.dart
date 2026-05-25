import 'dart:async';

import 'package:catch_dating_app/auth/presentation/auth_session_controller.dart';
import 'package:catch_dating_app/core/app_config.dart';
import 'package:catch_dating_app/core/external_links.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_empty_state.dart';
import 'package:catch_dating_app/core/widgets/catch_loading_indicator.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/core/widgets/catch_top_bar.dart';
import 'package:catch_dating_app/core/widgets/confirm_danger_dialog.dart';
import 'package:catch_dating_app/core/widgets/mutation_error_snackbar_listener.dart';
import 'package:catch_dating_app/core/widgets/person_row.dart';
import 'package:catch_dating_app/core/widgets/section_header.dart';
import 'package:catch_dating_app/core/widgets/settings_row.dart';
import 'package:catch_dating_app/public_profile/data/public_profile_repository.dart';
import 'package:catch_dating_app/public_profile/domain/public_profile.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:catch_dating_app/safety/data/safety_repository.dart';
import 'package:catch_dating_app/safety/presentation/settings_controller.dart';
import 'package:catch_dating_app/safety/presentation/settings_keys.dart';
import 'package:catch_dating_app/user_profile/data/user_profile_repository.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _showOnMap = true;
  bool _newCatches = true;
  bool _messages = true;
  bool _eventReminders = true;
  bool _eventStatusUpdates = true;
  bool _clubUpdates = true;
  bool _weeklyDigest = false;
  String? _seededUid;

  Future<void> _savePref({
    required SettingsPreference preference,
    required bool value,
    required VoidCallback apply,
    required VoidCallback rollback,
  }) async {
    setState(apply);

    try {
      await SettingsController.savePreferenceMutation.run(
        ref,
        (tx) async => tx
            .get(settingsControllerProvider.notifier)
            .savePreference(preference: preference, value: value),
      );
    } catch (_) {
      // MutationErrorSnackbarListener owns user-facing error display.
    }

    if (!mounted) return;
    if (ref.read(SettingsController.savePreferenceMutation).hasError) {
      setState(rollback);
    }
  }

  Future<void> _confirmDeleteAccount() async {
    final confirmed = await showConfirmDangerDialog(
      context: context,
      title: 'Delete account?',
      message:
          'This removes your public profile, signs you out, and keeps only '
          'the minimal records required for safety and payment history.',
      confirmLabel: 'Delete',
    );
    if (confirmed != true || !mounted) return;

    try {
      await SettingsController.requestAccountDeletionMutation.run(
        ref,
        (tx) async => tx
            .get(settingsControllerProvider.notifier)
            .requestAccountDeletion(),
      );
    } catch (_) {
      // MutationErrorSnackbarListener owns user-facing error display.
    }
  }

  void _signOut() {
    final signOutMutation = ref.read(AuthSessionController.signOutMutation);
    if (signOutMutation.isPending) return;

    unawaited(
      AuthSessionController.signOutMutation.run(
        ref,
        (tx) async => tx.get(authSessionControllerProvider.notifier).signOut(),
      ),
    );
  }

  void _openExternal(Uri uri) {
    unawaited(ref.read(externalLinkControllerProvider).openExternal(uri));
  }

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final userProfile = ref.watch(watchUserProfileProvider).asData?.value;
    final phoneNumber = userProfile?.phoneNumber ?? '';
    final deleting = ref
        .watch(SettingsController.requestAccountDeletionMutation)
        .isPending;
    final signingOut = ref
        .watch(AuthSessionController.signOutMutation)
        .isPending;
    final savingPreference = ref
        .watch(SettingsController.savePreferenceMutation)
        .isPending;

    if (userProfile != null && userProfile.uid != _seededUid) {
      _seededUid = userProfile.uid;
      _showOnMap = userProfile.prefsShowOnMap;
      _newCatches = userProfile.prefsNewCatches;
      _messages = userProfile.prefsMessages;
      _eventReminders = userProfile.prefsEventReminders;
      _eventStatusUpdates = userProfile.prefsRunStatusUpdates;
      _clubUpdates = userProfile.prefsClubUpdates;
      _weeklyDigest = userProfile.prefsWeeklyDigest;
    }

    ref.listen(SettingsController.unblockUserMutation, (previous, current) {
      if (previous?.isPending == true && current.isSuccess) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Account unblocked.')));
      }
    });

    return MutationErrorSnackbarListener(
      mutation: AuthSessionController.signOutMutation,
      child: MutationErrorSnackbarListener(
        mutation: SettingsController.savePreferenceMutation,
        child: MutationErrorSnackbarListener(
          mutation: SettingsController.requestAccountDeletionMutation,
          child: MutationErrorSnackbarListener(
            mutation: SettingsController.unblockUserMutation,
            child: Scaffold(
              appBar: const CatchTopBar(title: 'Settings'),
              body: ListView(
                padding: const EdgeInsets.fromLTRB(
                  CatchSpacing.s5,
                  CatchSpacing.s3,
                  CatchSpacing.s5,
                  CatchSpacing.s8,
                ),
                children: [
                  _SettingsSection(
                    title: 'Account',
                    children: [
                      SettingsRow(
                        label: 'Phone',
                        value: _formatPhoneForDisplay(phoneNumber),
                        icon: Icons.phone_outlined,
                      ),
                      SettingsRow(
                        key: SettingsKeys.reviewHistoryRow,
                        label: 'Review history',
                        value: 'Events you reviewed',
                        icon: Icons.rate_review_outlined,
                        onTap: () =>
                            context.pushNamed(Routes.reviewsHistoryScreen.name),
                      ),
                      SettingsRow(
                        key: SettingsKeys.paymentHistoryRow,
                        label: 'Payment history',
                        value: 'Bookings and receipts',
                        icon: Icons.receipt_long_outlined,
                        onTap: () =>
                            context.pushNamed(Routes.paymentHistoryScreen.name),
                      ),
                      SettingsRow(
                        key: SettingsKeys.signOutRow,
                        label: 'Sign out',
                        value: 'Leave this device',
                        icon: Icons.logout_rounded,
                        danger: true,
                        trailing: signingOut
                            ? const SizedBox.square(
                                dimension: 20,
                                child: CatchLoadingIndicator(strokeWidth: 2),
                              )
                            : null,
                        onTap: signingOut ? null : _signOut,
                      ),
                    ],
                  ),
                  gapH20,
                  if (AppConfig.enableEventPolicyLab ||
                      AppConfig.enableEventSuccessPreview) ...[
                    _SettingsSection(
                      title: 'Development',
                      children: [
                        if (AppConfig.enableEventPolicyLab)
                          SettingsRow(
                            key: SettingsKeys.eventPolicyLabRow,
                            label: 'Event policy lab',
                            value: 'Static booking policy previews',
                            icon: Icons.science_outlined,
                            onTap: () => context.pushNamed(
                              Routes.eventPolicyLabScreen.name,
                            ),
                          ),
                        if (AppConfig.enableEventSuccessPreview)
                          SettingsRow(
                            key: SettingsKeys.eventSuccessLabRow,
                            label: 'Event success lab',
                            value: 'Host, attendee, and report previews',
                            icon: Icons.auto_graph_rounded,
                            onTap: () => context.pushNamed(
                              Routes.eventSuccessLabScreen.name,
                            ),
                          ),
                        if (AppConfig.enableEventSuccessPreview)
                          SettingsRow(
                            key: SettingsKeys.eventSuccessManualQaRow,
                            label: 'Event success manual QA',
                            value: 'Host and attendee side by side',
                            icon: Icons.splitscreen_rounded,
                            onTap: () => context.pushNamed(
                              Routes.eventSuccessManualQaScreen.name,
                            ),
                          ),
                      ],
                    ),
                    gapH20,
                  ],
                  _SettingsSection(
                    title: 'Discovery',
                    children: [
                      SettingsRow(
                        label: 'Who can see me',
                        value: 'Runners on my events',
                        icon: Icons.visibility_outlined,
                      ),
                      SettingsRow(
                        label: 'Show me on map',
                        icon: Icons.map_outlined,
                        trailing: Switch.adaptive(
                          key: SettingsKeys.showOnMapSwitch,
                          value: _showOnMap,
                          onChanged: savingPreference
                              ? null
                              : (value) => _savePref(
                                  preference: SettingsPreference.showOnMap,
                                  value: value,
                                  apply: () => _showOnMap = value,
                                  rollback: () => _showOnMap = !value,
                                ),
                        ),
                      ),
                    ],
                  ),
                  gapH20,
                  _SettingsSection(
                    title: 'Notifications',
                    children: [
                      SettingsRow(
                        label: 'Matches and catches',
                        icon: Icons.favorite_outline,
                        trailing: Switch.adaptive(
                          key: SettingsKeys.newCatchesSwitch,
                          value: _newCatches,
                          onChanged: savingPreference
                              ? null
                              : (value) => _savePref(
                                  preference: SettingsPreference.newCatches,
                                  value: value,
                                  apply: () => _newCatches = value,
                                  rollback: () => _newCatches = !value,
                                ),
                        ),
                      ),
                      SettingsRow(
                        label: 'Messages',
                        icon: Icons.chat_bubble_outline_rounded,
                        trailing: Switch.adaptive(
                          key: SettingsKeys.messagesSwitch,
                          value: _messages,
                          onChanged: savingPreference
                              ? null
                              : (value) => _savePref(
                                  preference: SettingsPreference.messages,
                                  value: value,
                                  apply: () => _messages = value,
                                  rollback: () => _messages = !value,
                                ),
                        ),
                      ),
                      SettingsRow(
                        label: 'Event reminders',
                        icon: Icons.directions_run_outlined,
                        trailing: Switch.adaptive(
                          key: SettingsKeys.eventRemindersSwitch,
                          value: _eventReminders,
                          onChanged: savingPreference
                              ? null
                              : (value) => _savePref(
                                  preference: SettingsPreference.eventReminders,
                                  value: value,
                                  apply: () => _eventReminders = value,
                                  rollback: () => _eventReminders = !value,
                                ),
                        ),
                      ),
                      SettingsRow(
                        label: 'Event changes and cancellations',
                        icon: Icons.event_repeat_outlined,
                        trailing: Switch.adaptive(
                          key: SettingsKeys.eventStatusUpdatesSwitch,
                          value: _eventStatusUpdates,
                          onChanged: savingPreference
                              ? null
                              : (value) => _savePref(
                                  preference:
                                      SettingsPreference.eventStatusUpdates,
                                  value: value,
                                  apply: () => _eventStatusUpdates = value,
                                  rollback: () => _eventStatusUpdates = !value,
                                ),
                        ),
                      ),
                      SettingsRow(
                        label: 'Club announcements',
                        icon: Icons.notifications_active_outlined,
                        trailing: Switch.adaptive(
                          key: SettingsKeys.clubUpdatesSwitch,
                          value: _clubUpdates,
                          onChanged: savingPreference
                              ? null
                              : (value) => _savePref(
                                  preference: SettingsPreference.clubUpdates,
                                  value: value,
                                  apply: () => _clubUpdates = value,
                                  rollback: () => _clubUpdates = !value,
                                ),
                        ),
                      ),
                      SettingsRow(
                        label: 'Weekly digest',
                        icon: Icons.mark_email_read_outlined,
                        trailing: Switch.adaptive(
                          key: SettingsKeys.weeklyDigestSwitch,
                          value: _weeklyDigest,
                          onChanged: savingPreference
                              ? null
                              : (value) => _savePref(
                                  preference: SettingsPreference.weeklyDigest,
                                  value: value,
                                  apply: () => _weeklyDigest = value,
                                  rollback: () => _weeklyDigest = !value,
                                ),
                        ),
                      ),
                    ],
                  ),
                  gapH20,
                  const SectionHeader(title: 'Safety'),
                  gapH8,
                  const _BlockedAccountsSection(),
                  gapH20,
                  _SettingsSection(
                    title: 'About',
                    children: [
                      SettingsRow(
                        label: 'Help & support',
                        value: 'Contact us',
                        icon: Icons.help_outline,
                        onTap: () => _openExternal(
                          Uri.parse('https://catchdates.com/help'),
                        ),
                      ),
                      SettingsRow(
                        label: 'Privacy',
                        value: 'Policy',
                        icon: Icons.lock_outline,
                        onTap: () => _openExternal(
                          Uri.parse('https://catchdates.com/privacy'),
                        ),
                      ),
                      SettingsRow(
                        label: 'Terms',
                        value: 'Legal',
                        icon: Icons.description_outlined,
                        onTap: () => _openExternal(
                          Uri.parse('https://catchdates.com/terms'),
                        ),
                      ),
                    ],
                  ),
                  gapH20,
                  _SettingsCard(
                    children: [
                      SettingsRow(
                        key: SettingsKeys.deleteAccountRow,
                        label: 'Delete account',
                        value: 'Remove your profile',
                        icon: Icons.delete_outline,
                        danger: true,
                        trailing: deleting
                            ? const SizedBox.square(
                                dimension: 20,
                                child: CatchLoadingIndicator(strokeWidth: 2),
                              )
                            : null,
                        onTap: deleting ? null : _confirmDeleteAccount,
                      ),
                    ],
                  ),
                  gapH20,
                  Center(
                    child: Text(
                      'Catch v1.0 · made for runners and clubs',
                      style: CatchTextStyles.supporting(context, color: t.ink3),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatPhoneForDisplay(String phoneNumber) {
    if (phoneNumber.isEmpty) return '';
    if (!phoneNumber.startsWith('+')) return phoneNumber;

    final sortedCodes = codes.toList()
      ..sort(
        (a, b) => b['dial_code']!.length.compareTo(a['dial_code']!.length),
      );
    for (final c in sortedCodes) {
      final dialCode = c['dial_code']!;
      if (phoneNumber.startsWith(dialCode)) {
        final national = phoneNumber.substring(dialCode.length);
        return '$dialCode $national';
      }
    }
    return phoneNumber;
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: title),
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

class _BlockedAccountsSection extends ConsumerWidget {
  const _BlockedAccountsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final blockedUsersAsync = ref.watch(watchBlockedUsersProvider);
    final t = CatchTokens.of(context);

    return _SettingsCard(
      children: [
        blockedUsersAsync.when(
          loading: () => const Padding(
            padding: EdgeInsets.all(CatchSpacing.s4),
            child: CatchLoadingIndicator(),
          ),
          error: (_, _) => Padding(
            padding: const EdgeInsets.all(CatchSpacing.s4),
            child: CatchEmptyState(
              icon: Icons.block_outlined,
              title: 'Unable to load blocked accounts',
              message: 'Try again in a moment.',
              surface: false,
              iconSize: 28,
              titleStyle: CatchTextStyles.titleM(context),
              messageStyle: CatchTextStyles.supporting(context, color: t.ink2),
            ),
          ),
          data: (blockedUsers) {
            if (blockedUsers.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(CatchSpacing.s4),
                child: CatchEmptyState(
                  icon: Icons.verified_user_outlined,
                  title: 'No blocked accounts',
                  message: 'People you block will appear here.',
                  surface: false,
                  iconSize: 28,
                  titleStyle: CatchTextStyles.titleM(context),
                  messageStyle: CatchTextStyles.supporting(
                    context,
                    color: t.ink2,
                  ),
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
    final profileAsync = ref.watch(watchPublicProfileProvider(blockedUser.uid));
    final profile = profileAsync.asData?.value;
    final unblocking = ref.watch(SettingsController.unblockUserMutation);
    final photoUrl = profile?.primaryPhotoThumbnailUrl;

    return PersonRow(
      data: PersonRowData(
        name: profile?.name ?? 'Blocked account',
        imageUrl: photoUrl,
        metaLine: blockedUser.source,
        seed: blockedUser.uid,
      ),
      trailing: CatchButton(
        key: SettingsKeys.unblockButton(blockedUser.uid),
        label: 'Unblock',
        isLoading: unblocking.isPending,
        onPressed: unblocking.isPending
            ? null
            : () => SettingsController.unblockUserMutation.run(
                ref,
                (tx) async => tx
                    .get(settingsControllerProvider.notifier)
                    .unblockUser(targetUserId: blockedUser.uid),
              ),
        variant: CatchButtonVariant.ghost,
        size: CatchButtonSize.sm,
      ),
    );
  }
}
