import 'dart:async';

import 'package:catch_dating_app/auth/presentation/auth_session_controller.dart';
import 'package:catch_dating_app/core/app_config.dart';
import 'package:catch_dating_app/core/external_links.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_empty_state.dart';
import 'package:catch_dating_app/core/widgets/catch_error_snackbar.dart';
import 'package:catch_dating_app/core/widgets/catch_error_state.dart';
import 'package:catch_dating_app/core/widgets/catch_field.dart';
import 'package:catch_dating_app/core/widgets/catch_loading_indicator.dart';
import 'package:catch_dating_app/core/widgets/catch_mutation_error_listener.dart';
import 'package:catch_dating_app/core/widgets/catch_person_row.dart';
import 'package:catch_dating_app/core/widgets/catch_section_layout.dart';
import 'package:catch_dating_app/core/widgets/catch_skeleton.dart';
import 'package:catch_dating_app/core/widgets/catch_toggle.dart';
import 'package:catch_dating_app/core/widgets/catch_top_bar.dart';
import 'package:catch_dating_app/core/widgets/confirm_danger_dialog.dart';
import 'package:catch_dating_app/public_profile/data/public_profiles_lookup.dart';
import 'package:catch_dating_app/public_profile/domain/public_profile.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:catch_dating_app/safety/data/safety_repository.dart';
import 'package:catch_dating_app/safety/presentation/settings_account_state.dart';
import 'package:catch_dating_app/safety/presentation/settings_controller.dart';
import 'package:catch_dating_app/safety/presentation/settings_keys.dart';
import 'package:catch_dating_app/user_profile/data/user_profile_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  SettingsPreferenceValues _preferences =
      const SettingsPreferenceValues.defaults();
  String? _seededUid;

  Future<void> _savePref({
    required SettingsPreference preference,
    required bool value,
  }) async {
    final previousPreferences = _preferences;
    setState(() {
      _preferences = _preferences.copyWithPreference(preference, value);
    });

    try {
      await SettingsController.savePreferenceMutation.run(
        ref,
        (tx) async => tx
            .get(settingsControllerProvider.notifier)
            .savePreference(preference: preference, value: value),
      );
    } catch (_) {
      // CatchMutationErrorListener owns user-facing error display.
    }

    if (!mounted) return;
    if (ref.read(SettingsController.savePreferenceMutation).hasError) {
      setState(() => _preferences = previousPreferences);
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
      // CatchMutationErrorListener owns user-facing error display.
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

  void _openHostApp() {
    unawaited(ref.read(externalLinkControllerProvider).openHostApp());
  }

  void _unblockUser(String targetUserId) {
    unawaited(
      SettingsController.unblockUserMutation.run(
        ref,
        (tx) async => tx
            .get(settingsControllerProvider.notifier)
            .unblockUser(targetUserId: targetUserId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final userProfileAsync = ref.watch(watchUserProfileProvider);
    final userProfile = userProfileAsync.asData?.value;
    final blockedUsersAsync = ref.watch(watchBlockedUsersProvider);
    final blockedUsers = blockedUsersAsync.asData?.value;
    final blockedProfilesAsync = blockedUsers == null || blockedUsers.isEmpty
        ? const AsyncData(<String, PublicProfile>{})
        : ref.watch(
            publicProfilesByIdsProvider(
              PublicProfilesQuery(blockedUsers.map((blocked) => blocked.uid)),
            ),
          );

    if (userProfile != null && userProfile.uid != _seededUid) {
      _seededUid = userProfile.uid;
      _preferences = SettingsPreferenceValues.fromProfile(userProfile);
    }

    final state = SettingsAccountState.fromAsync(
      profile: userProfileAsync,
      preferences: _preferences,
      blockedUsers: blockedUsersAsync,
      blockedProfiles: blockedProfilesAsync,
      mutations: SettingsMutationState(
        savingPreference: ref
            .watch(SettingsController.savePreferenceMutation)
            .isPending,
        deletingAccount: ref
            .watch(SettingsController.requestAccountDeletionMutation)
            .isPending,
        signingOut: ref.watch(AuthSessionController.signOutMutation).isPending,
        unblocking: ref.watch(SettingsController.unblockUserMutation).isPending,
      ),
    );

    ref.listen(SettingsController.unblockUserMutation, (previous, current) {
      if (previous?.isPending == true && current.isSuccess) {
        showCatchSnackBar(context, 'Account unblocked.');
      }
    });

    return CatchMutationErrorListener(
      mutation: AuthSessionController.signOutMutation,
      child: CatchMutationErrorListener(
        mutation: SettingsController.savePreferenceMutation,
        child: CatchMutationErrorListener(
          mutation: SettingsController.requestAccountDeletionMutation,
          child: CatchMutationErrorListener(
            mutation: SettingsController.unblockUserMutation,
            child: Scaffold(
              appBar: const CatchTopBar(title: 'Settings'),
              body: CatchScreenBody(
                pt: CatchSpacing.s2,
                pb: CatchSpacing.s7,
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: CatchLayout.maxContentWidth,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _settingsSection(
                          first: true,
                          title: 'Account',
                          footer: _accountProfileStatus(
                            profile: state.profile,
                            onRetry: () =>
                                ref.invalidate(watchUserProfileProvider),
                          ),
                          children: [
                            CatchField(
                              title: 'Phone number',
                              valueText: state.profile.phoneNumber,
                              icon: CatchIcons.phoneOutlined,
                            ),
                            CatchField(
                              title: 'Email',
                              valueText: state.profile.email,
                              icon: CatchIcons.emailOutlined,
                            ),
                            CatchField(
                              title: 'Edit profile',
                              icon: CatchIcons.personOutlined,
                              onTap: () =>
                                  context.pushNamed(Routes.profileScreen.name),
                            ),
                            CatchField(
                              key: SettingsKeys.reviewHistoryRow,
                              title: 'Review history',
                              valueText: 'Events you reviewed',
                              icon: CatchIcons.rateReviewOutlined,
                              onTap: () => context.pushNamed(
                                Routes.reviewsHistoryScreen.name,
                              ),
                            ),
                            CatchField(
                              key: SettingsKeys.paymentHistoryRow,
                              title: 'Payment history',
                              valueText: 'Bookings and receipts',
                              icon: CatchIcons.receiptLongOutlined,
                              onTap: () => context.pushNamed(
                                Routes.paymentHistoryScreen.name,
                              ),
                            ),
                            CatchField(
                              key: SettingsKeys.hostAppRow,
                              title: 'Catch Host',
                              valueText: 'Manage events and clubs',
                              icon: CatchIcons.workOutlineRounded,
                              onTap: _openHostApp,
                            ),
                          ],
                        ),
                        if (AppConfig.enableEventPolicyLab ||
                            AppConfig.enableEventSuccessPreview) ...[
                          _settingsSection(
                            title: 'Development',
                            children: [
                              if (AppConfig.enableEventPolicyLab)
                                CatchField(
                                  key: SettingsKeys.eventPolicyLabRow,
                                  title: 'Event policy lab',
                                  valueText: 'Static booking policy previews',
                                  icon: CatchIcons.scienceOutlined,
                                  onTap: () => context.pushNamed(
                                    Routes.eventPolicyLabScreen.name,
                                  ),
                                ),
                              if (AppConfig.enableEventSuccessPreview)
                                CatchField(
                                  key: SettingsKeys.eventSuccessLabRow,
                                  title: 'Event success lab',
                                  valueText:
                                      'Host, attendee, and report previews',
                                  icon: CatchIcons.autoGraphRounded,
                                  onTap: () => context.pushNamed(
                                    Routes.eventSuccessLabScreen.name,
                                  ),
                                ),
                              if (AppConfig.enableEventSuccessPreview)
                                CatchField(
                                  key: SettingsKeys.eventSuccessManualQaRow,
                                  title: 'Event success manual QA',
                                  valueText: 'Host and attendee side by side',
                                  icon: CatchIcons.splitscreenRounded,
                                  onTap: () => context.pushNamed(
                                    Routes.eventSuccessManualQaScreen.name,
                                  ),
                                ),
                            ],
                          ),
                        ],
                        _settingsSection(
                          title: 'Notifications',
                          children: [
                            CatchField(
                              title: 'Push notifications',
                              icon: CatchIcons.favoriteOutline,
                              action: CatchToggle(
                                key: SettingsKeys.newCatchesSwitch,
                                value: state.preferences.newCatches,
                                semanticLabel: 'Push notifications',
                                onChanged: state.mutations.savingPreference
                                    ? null
                                    : (value) => _savePref(
                                        preference:
                                            SettingsPreference.newCatches,
                                        value: value,
                                      ),
                              ),
                            ),
                            CatchField(
                              title: 'Messages',
                              icon: CatchIcons.chatBubbleOutlineRounded,
                              action: CatchToggle(
                                key: SettingsKeys.messagesSwitch,
                                value: state.preferences.messages,
                                semanticLabel: 'Messages',
                                onChanged: state.mutations.savingPreference
                                    ? null
                                    : (value) => _savePref(
                                        preference: SettingsPreference.messages,
                                        value: value,
                                      ),
                              ),
                            ),
                            CatchField(
                              title: 'Event reminders',
                              icon: CatchIcons.directionsRunOutlined,
                              action: CatchToggle(
                                key: SettingsKeys.eventRemindersSwitch,
                                value: state.preferences.eventReminders,
                                semanticLabel: 'Event reminders',
                                onChanged: state.mutations.savingPreference
                                    ? null
                                    : (value) => _savePref(
                                        preference:
                                            SettingsPreference.eventReminders,
                                        value: value,
                                      ),
                              ),
                            ),
                            CatchField(
                              title: 'Event changes and cancellations',
                              icon: CatchIcons.eventRepeatOutlined,
                              action: CatchToggle(
                                key: SettingsKeys.eventStatusUpdatesSwitch,
                                value: state.preferences.eventStatusUpdates,
                                semanticLabel:
                                    'Event changes and cancellations',
                                onChanged: state.mutations.savingPreference
                                    ? null
                                    : (value) => _savePref(
                                        preference: SettingsPreference
                                            .eventStatusUpdates,
                                        value: value,
                                      ),
                              ),
                            ),
                            CatchField(
                              title: 'Club announcements',
                              icon: CatchIcons.notificationsActiveOutlined,
                              action: CatchToggle(
                                key: SettingsKeys.clubUpdatesSwitch,
                                value: state.preferences.clubUpdates,
                                semanticLabel: 'Club announcements',
                                onChanged: state.mutations.savingPreference
                                    ? null
                                    : (value) => _savePref(
                                        preference:
                                            SettingsPreference.clubUpdates,
                                        value: value,
                                      ),
                              ),
                            ),
                            CatchField(
                              title: 'Email updates',
                              icon: CatchIcons.markEmailReadOutlined,
                              action: CatchToggle(
                                key: SettingsKeys.weeklyDigestSwitch,
                                value: state.preferences.weeklyDigest,
                                semanticLabel: 'Email updates',
                                onChanged: state.mutations.savingPreference
                                    ? null
                                    : (value) => _savePref(
                                        preference:
                                            SettingsPreference.weeklyDigest,
                                        value: value,
                                      ),
                              ),
                            ),
                          ],
                        ),
                        _settingsSection(
                          title: 'Privacy & safety',
                          footer: _blockedAccountsSection(
                            state: state.blockedAccounts,
                            unblocking: state.mutations.unblocking,
                            onRetry: () =>
                                ref.invalidate(watchBlockedUsersProvider),
                            onUnblock: _unblockUser,
                          ),
                          children: [
                            CatchField(
                              title: 'Blocked users',
                              valueText: state.blockedAccounts.count
                                  ?.toString(),
                              icon: CatchIcons.shieldOutlined,
                            ),
                            CatchField(
                              title: 'Who can see you',
                              valueText: 'Runners on my events',
                              icon: CatchIcons.visibilityOutlined,
                            ),
                            CatchField(
                              title: 'Show me on map',
                              icon: CatchIcons.mapOutlined,
                              action: CatchToggle(
                                key: SettingsKeys.showOnMapSwitch,
                                value: state.preferences.showOnMap,
                                semanticLabel: 'Show me on map',
                                onChanged: state.mutations.savingPreference
                                    ? null
                                    : (value) => _savePref(
                                        preference:
                                            SettingsPreference.showOnMap,
                                        value: value,
                                      ),
                              ),
                            ),
                            CatchField(
                              title: 'Privacy policy',
                              icon: CatchIcons.lockOutline,
                              onTap: () => _openExternal(
                                Uri.parse('https://catchdates.com/privacy'),
                              ),
                            ),
                            CatchField(
                              key: SettingsKeys.deleteAccountRow,
                              title: 'Delete account',
                              icon: CatchIcons.deleteOutline,
                              tone: CatchFieldTone.danger,
                              action: state.mutations.deletingAccount
                                  ? const SizedBox.square(
                                      dimension: CatchIcon.control,
                                      child: CatchLoadingIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : null,
                              onTap: state.mutations.deletingAccount
                                  ? null
                                  : _confirmDeleteAccount,
                            ),
                          ],
                        ),
                        _settingsSection(
                          title: 'About',
                          children: [
                            CatchField(
                              title: 'Help & support',
                              valueText: 'Contact us',
                              icon: CatchIcons.helpOutline,
                              onTap: () => _openExternal(
                                Uri.parse('https://catchdates.com/help'),
                              ),
                            ),
                            CatchField(
                              title: 'Terms',
                              valueText: 'Legal',
                              icon: CatchIcons.descriptionOutlined,
                              onTap: () => _openExternal(
                                Uri.parse('https://catchdates.com/terms'),
                              ),
                            ),
                            CatchField(
                              title: 'Version',
                              valueText: '1.0',
                              icon: CatchIcons.infoOutline,
                            ),
                          ],
                        ),
                        _settingsSection(
                          title: '',
                          hideTitle: true,
                          children: [
                            CatchField(
                              key: SettingsKeys.signOutRow,
                              title: 'Log out',
                              icon: CatchIcons.logoutRounded,
                              tone: CatchFieldTone.danger,
                              action: state.mutations.signingOut
                                  ? const SizedBox.square(
                                      dimension: CatchIcon.control,
                                      child: CatchLoadingIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : null,
                              onTap: state.mutations.signingOut
                                  ? null
                                  : _signOut,
                            ),
                          ],
                        ),
                        gapH20,
                        Center(
                          child: Text(
                            'Catch 1.0 · made in Bombay',
                            style: CatchTextStyles.statusLabel(
                              context,
                              color: t.ink3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Widget _settingsSection({
  required String title,
  required List<Widget> children,
  bool first = false,
  bool hideTitle = false,
  Widget? footer,
}) {
  return Builder(
    builder: (context) {
      final t = CatchTokens.of(context);
      final topPadding = hideTitle ? CatchSpacing.s3 : 18.0;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!first) ...[
            gapH8,
            ColoredBox(
              color: t.line,
              child: const SizedBox(height: CatchStroke.hairline),
            ),
            SizedBox(height: topPadding),
          ],
          if (!hideTitle) ...[
            Text(
              title.toUpperCase(),
              style: CatchTextStyles.kicker(context, color: t.ink2),
            ),
            gapH10,
          ],
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0)
              Padding(
                padding: const EdgeInsets.only(
                  left: CatchLayout.settingsRowDividerIconInset,
                ),
                child: ColoredBox(
                  color: t.line.withValues(
                    alpha: CatchOpacity.profileInfoDivider,
                  ),
                  child: const SizedBox(height: CatchStroke.hairline),
                ),
              ),
            children[i],
          ],
          ?footer,
        ],
      );
    },
  );
}

Widget _accountProfileStatus({
  required SettingsProfileState profile,
  required VoidCallback onRetry,
}) {
  return Builder(
    builder: (context) {
      if (profile.isError) {
        return Padding(
          padding: CatchInsets.content,
          child: CatchInlineErrorState.fromError(
            profile.error!,
            compact: true,
            onRetry: onRetry,
          ),
        );
      }

      if (profile.isMissing) {
        return const Padding(
          padding: CatchInsets.content,
          child: CatchInlineErrorState(
            title: 'Account unavailable',
            message: 'Sign out and sign back in if this keeps happening.',
            compact: true,
          ),
        );
      }

      return const SizedBox.shrink();
    },
  );
}

Widget _blockedAccountsSection({
  required SettingsBlockedAccountsState state,
  required bool unblocking,
  required VoidCallback onRetry,
  required ValueChanged<String> onUnblock,
}) {
  return Builder(
    builder: (context) {
      final t = CatchTokens.of(context);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ColoredBox(
            color: t.line.withValues(alpha: CatchOpacity.profileInfoDivider),
            child: const SizedBox(height: CatchStroke.hairline),
          ),
          switch (state.status) {
            SettingsBlockedAccountsStatus.loading => _blockedAccountsSkeleton(
              context,
            ),
            SettingsBlockedAccountsStatus.error => Padding(
              padding: CatchInsets.content,
              child: CatchInlineErrorState.fromError(
                state.error!,
                compact: true,
                onRetry: onRetry,
              ),
            ),
            SettingsBlockedAccountsStatus.empty => Padding(
              padding: CatchInsets.content,
              child: CatchEmptyState(
                icon: CatchIcons.verifiedUserOutlined,
                title: 'No blocked accounts',
                message: 'People you block will appear here.',
                iconSize: CatchIcon.tile,
                titleStyle: CatchTextStyles.sectionTitle(context),
                messageStyle: CatchTextStyles.supporting(
                  context,
                  color: t.ink2,
                ),
              ),
            ),
            SettingsBlockedAccountsStatus.content => Column(
              children: [
                for (var i = 0; i < state.rows.length; i++) ...[
                  _blockedAccountTile(
                    row: state.rows[i],
                    unblocking: unblocking,
                    onUnblock: onUnblock,
                  ),
                  if (i < state.rows.length - 1)
                    Divider(color: t.line, height: 1),
                ],
              ],
            ),
          },
        ],
      );
    },
  );
}

Widget _blockedAccountsSkeleton(BuildContext context) {
  return Padding(
    padding: CatchInsets.content,
    child: Column(
      children: [
        for (var index = 0; index < 3; index++) ...[
          Row(
            children: [
              CatchSkeleton.circle(size: CatchIcon.avatarLg),
              gapW12,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CatchSkeleton.text(
                      width: index == 1
                          ? CatchLayout.skeletonTextTitleWidth
                          : CatchLayout.skeletonTextShortWidth,
                    ),
                    gapH8,
                    CatchSkeleton.text(
                      width: index == 2
                          ? CatchLayout.skeletonTextShortWidth
                          : CatchLayout.skeletonTextShortWidth,
                    ),
                  ],
                ),
              ),
              gapW12,
              CatchSkeleton.box(
                width: CatchLayout.skeletonTextShortWidth,
                height: CatchSpacing.s8,
                radius: CatchRadius.pill,
              ),
            ],
          ),
          if (index < 2) ...[
            gapH12,
            ColoredBox(
              color: CatchTokens.of(context).line,
              child: const SizedBox(height: CatchStroke.hairline),
            ),
            gapH12,
          ],
        ],
      ],
    ),
  );
}

Widget _blockedAccountTile({
  required SettingsBlockedAccountRow row,
  required bool unblocking,
  required ValueChanged<String> onUnblock,
}) {
  return CatchPersonRow(
    data: CatchPersonRowData(
      name: row.name,
      imageUrl: row.imageUrl,
      metaLine: row.metaLine,
      seed: row.seed,
    ),
    trailing: CatchButton(
      key: SettingsKeys.unblockButton(row.uid),
      label: 'Unblock',
      isLoading: unblocking,
      onPressed: unblocking ? null : () => onUnblock(row.uid),
      variant: CatchButtonVariant.ghost,
      size: CatchButtonSize.sm,
    ),
  );
}
