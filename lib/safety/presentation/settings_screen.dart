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
import 'package:catch_dating_app/core/widgets/catch_route_scaffold.dart';
import 'package:catch_dating_app/core/widgets/catch_section_layout.dart';
import 'package:catch_dating_app/core/widgets/catch_skeleton.dart';
import 'package:catch_dating_app/core/widgets/catch_top_bar.dart';
import 'package:catch_dating_app/core/widgets/confirm_danger_dialog.dart';
import 'package:catch_dating_app/force_update/data/force_update_provider.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:catch_dating_app/public_profile/data/public_profiles_lookup.dart';
import 'package:catch_dating_app/public_profile/domain/public_profile.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:catch_dating_app/safety/data/safety_repository.dart';
import 'package:catch_dating_app/safety/presentation/settings_account_state.dart';
import 'package:catch_dating_app/safety/presentation/settings_account_view_model.dart';
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
  _SettingsExternalLinkAction? _pendingExternalLink;

  bool get _operationPending =>
      _pendingExternalLink != null ||
      ref.read(SettingsController.savePreferenceMutation).isPending ||
      ref.read(SettingsController.requestAccountDeletionMutation).isPending ||
      ref.read(AuthSessionController.signOutMutation).isPending ||
      ref.read(SettingsController.unblockUserMutation).isPending;

  Future<void> _savePref({
    required SettingsPreference preference,
    required bool value,
  }) async {
    if (_operationPending) return;

    final previousPreferences = _preferences;
    setState(() {
      _preferences = _preferences.copyWithPreference(preference, value);
    });

    // Track error locally to avoid reading mutation state that could have
    // been overwritten by a concurrent call (matching _savePref is guarded
    // by the toggle disabled state, but capturing the result is safer).
    bool hadError = false;
    try {
      await SettingsController.savePreferenceMutation.run(
        ref,
        (tx) async => tx
            .get(settingsControllerProvider.notifier)
            .savePreference(preference: preference, value: value),
      );
    } catch (_) {
      hadError = true;
      // CatchMutationErrorListener owns user-facing error display.
    }

    if (!mounted) return;
    if (hadError) {
      setState(() => _preferences = previousPreferences);
    }
  }

  Future<void> _confirmDeleteAccount() async {
    if (_operationPending) return;

    final confirmed = await showConfirmDangerDialog(
      context: context,
      title: context.l10n.safetySettingsScreenTitleDeleteAccount,
      message: context.l10n.safetySettingsScreenMessageThisRemovesYourPublic,
      confirmLabel: context.l10n.sharedActionDelete,
    );
    if (confirmed != true || !mounted || _operationPending) return;

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

  Future<void> _signOut() async {
    if (_operationPending) return;

    try {
      await AuthSessionController.signOutMutation.run(
        ref,
        (tx) async => tx.get(authSessionControllerProvider.notifier).signOut(),
      );
    } catch (_) {
      // CatchMutationErrorListener owns user-facing error display.
    }
  }

  void _openExternal(_SettingsExternalLinkAction action, Uri uri) {
    unawaited(
      _launchExternalLink(
        action,
        () => ref.read(externalLinkControllerProvider).openExternal(uri),
      ),
    );
  }

  void _openHostApp() {
    unawaited(
      _launchExternalLink(
        _SettingsExternalLinkAction.hostApp,
        () => ref.read(externalLinkControllerProvider).openHostApp(),
      ),
    );
  }

  Future<void> _launchExternalLink(
    _SettingsExternalLinkAction action,
    Future<bool> Function() launch,
  ) async {
    if (_operationPending) return;

    setState(() => _pendingExternalLink = action);
    var opened = false;
    try {
      opened = await launch();
    } catch (_) {
      // ExternalLinkController retains the backend context; this route owns
      // the visible result for both thrown and false launcher outcomes.
    } finally {
      if (mounted) {
        setState(() => _pendingExternalLink = null);
      }
    }

    if (!mounted || opened) return;
    showCatchSnackBar(
      context,
      context.l10n.safetySettingsScreenExternalLinkOpenFailed,
    );
  }

  void _unblockUser(String targetUserId) {
    if (_operationPending) return;
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
    final packageInfo = ref.watch(appPackageInfoProvider).asData?.value;
    final version = packageInfo?.version ?? '—';
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

    final state = buildSettingsAccountState(
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
    final operationPending =
        state.mutations.operationPending || _pendingExternalLink != null;

    ref.listen(SettingsController.unblockUserMutation, (previous, current) {
      if (previous?.isPending == true && current.isSuccess) {
        showCatchSnackBar(context, context.l10n.safetyAccountUnblockedMessage);
      }
    });

    return PopScope(
      canPop: !operationPending,
      child: CatchMutationErrorListeners(
        mutations: [
          AuthSessionController.signOutMutation,
          SettingsController.savePreferenceMutation,
          SettingsController.requestAccountDeletionMutation,
          SettingsController.unblockUserMutation,
        ],
        child: CatchRouteScaffold(
          topBarBuilder: (context, scrolledUnder) => CatchTopBar(
            title: context.l10n.safetySettingsScreenTitleSettings,
            leadingType: CatchTopBarLeading.back,
            leading: operationPending
                ? CatchIconAction(
                    icon: CatchIcons.arrowBackIosNewRounded,
                    tooltip: MaterialLocalizations.of(
                      context,
                    ).backButtonTooltip,
                    onPressed: null,
                  )
                : null,
            divider: scrolledUnder,
          ),
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
                    CatchSection.fieldRows(
                      first: true,
                      title: context.l10n.safetySettingsScreenTitleAccount,
                      footer: AccountProfileStatus(
                        profile: state.profile,
                        onRetry: operationPending
                            ? null
                            : () => ref.invalidate(watchUserProfileProvider),
                      ),
                      children: [
                        CatchField.read(
                          title:
                              context.l10n.safetySettingsScreenTitlePhoneNumber,
                          valueText: state.profile.phoneNumber,
                          icon: CatchIcons.phoneOutlined,
                        ),
                        CatchField.read(
                          title: context.l10n.safetySettingsScreenTitleEmail,
                          valueText: state.profile.email,
                          icon: CatchIcons.emailOutlined,
                        ),
                        CatchField.nav(
                          key: SettingsKeys.reviewHistoryRow,
                          title: context
                              .l10n
                              .safetySettingsScreenTitleReviewHistory,
                          valueText: context
                              .l10n
                              .safetySettingsScreenBodyEventsYouReviewed,
                          icon: CatchIcons.rateReviewOutlined,
                          onTap: operationPending
                              ? null
                              : () => context.pushNamed(
                                  Routes.reviewsHistoryScreen.name,
                                ),
                        ),
                        CatchField.nav(
                          key: SettingsKeys.paymentHistoryRow,
                          title: context
                              .l10n
                              .safetySettingsScreenTitlePaymentHistory,
                          valueText: context
                              .l10n
                              .safetySettingsScreenBodyBookingsAndReceipts,
                          icon: CatchIcons.receiptLongOutlined,
                          onTap: operationPending
                              ? null
                              : () => context.pushNamed(
                                  Routes.paymentHistoryScreen.name,
                                ),
                        ),
                        CatchField.nav(
                          key: SettingsKeys.hostAppRow,
                          title:
                              context.l10n.safetySettingsScreenTitleCatchHost,
                          valueText: context
                              .l10n
                              .safetySettingsScreenBodyManageEventsAndClubs,
                          icon: CatchIcons.workOutlineRounded,
                          action:
                              _pendingExternalLink ==
                                  _SettingsExternalLinkAction.hostApp
                              ? const SizedBox.square(
                                  dimension: CatchIcon.control,
                                  child: CatchLoadingIndicator(strokeWidth: 2),
                                )
                              : null,
                          onTap: operationPending ? null : _openHostApp,
                        ),
                      ],
                    ),
                    if (AppConfig.enableEventPolicyLab ||
                        AppConfig.enableEventSuccessPreview) ...[
                      CatchSection.fieldRows(
                        title:
                            context.l10n.safetySettingsScreenTitleDevelopment,
                        children: [
                          if (AppConfig.enableEventPolicyLab)
                            CatchField.nav(
                              key: SettingsKeys.eventPolicyLabRow,
                              title: context
                                  .l10n
                                  .safetySettingsScreenTitleEventPolicyLab,
                              valueText: context
                                  .l10n
                                  .safetySettingsScreenBodyStaticBookingPolicyPreviews,
                              icon: CatchIcons.scienceOutlined,
                              onTap: operationPending
                                  ? null
                                  : () => context.pushNamed(
                                      Routes.eventPolicyLabScreen.name,
                                    ),
                            ),
                          if (AppConfig.enableEventSuccessPreview)
                            CatchField.nav(
                              key: SettingsKeys.eventSuccessLabRow,
                              title: context
                                  .l10n
                                  .safetySettingsScreenTitleEventSuccessLab,
                              valueText: context
                                  .l10n
                                  .safetySettingsScreenBodyHostAttendeeAndReport,
                              icon: CatchIcons.autoGraphRounded,
                              onTap: operationPending
                                  ? null
                                  : () => context.pushNamed(
                                      Routes.eventSuccessLabScreen.name,
                                    ),
                            ),
                          if (AppConfig.enableEventSuccessPreview)
                            CatchField.nav(
                              key: SettingsKeys.eventSuccessManualQaRow,
                              title: context
                                  .l10n
                                  .safetySettingsScreenTitleEventSuccessManualQa,
                              valueText: context
                                  .l10n
                                  .safetySettingsScreenBodyHostAndAttendeeSide,
                              icon: CatchIcons.splitscreenRounded,
                              onTap: operationPending
                                  ? null
                                  : () => context.pushNamed(
                                      Routes.eventSuccessManualQaScreen.name,
                                    ),
                            ),
                        ],
                      ),
                    ],
                    CatchSection.fieldRows(
                      title:
                          context.l10n.safetySettingsScreenTitleNotifications,
                      children: [
                        CatchField.toggle(
                          key: SettingsKeys.newCatchesSwitch,
                          title: context
                              .l10n
                              .safetySettingsScreenTitlePushNotifications,
                          icon: CatchIcons.favoriteOutline,
                          value: state.preferences.newCatches,
                          onChanged: operationPending
                              ? null
                              : (value) => _savePref(
                                  preference: SettingsPreference.newCatches,
                                  value: value,
                                ),
                        ),
                        CatchField.toggle(
                          key: SettingsKeys.messagesSwitch,
                          title: context.l10n.safetySettingsScreenTitleMessages,
                          icon: CatchIcons.chatBubbleOutlineRounded,
                          value: state.preferences.messages,
                          onChanged: operationPending
                              ? null
                              : (value) => _savePref(
                                  preference: SettingsPreference.messages,
                                  value: value,
                                ),
                        ),
                        CatchField.toggle(
                          key: SettingsKeys.eventRemindersSwitch,
                          title: context
                              .l10n
                              .safetySettingsScreenTitleEventReminders,
                          icon: CatchIcons.directionsRunOutlined,
                          value: state.preferences.eventReminders,
                          onChanged: operationPending
                              ? null
                              : (value) => _savePref(
                                  preference: SettingsPreference.eventReminders,
                                  value: value,
                                ),
                        ),
                        CatchField.toggle(
                          key: SettingsKeys.eventStatusUpdatesSwitch,
                          title: context
                              .l10n
                              .safetySettingsScreenTitleEventChangesAndCancellations,
                          icon: CatchIcons.eventRepeatOutlined,
                          value: state.preferences.eventStatusUpdates,
                          onChanged: operationPending
                              ? null
                              : (value) => _savePref(
                                  preference:
                                      SettingsPreference.eventStatusUpdates,
                                  value: value,
                                ),
                        ),
                        CatchField.toggle(
                          key: SettingsKeys.clubUpdatesSwitch,
                          title: context
                              .l10n
                              .safetySettingsScreenTitleClubAnnouncements,
                          icon: CatchIcons.notificationsActiveOutlined,
                          value: state.preferences.clubUpdates,
                          onChanged: operationPending
                              ? null
                              : (value) => _savePref(
                                  preference: SettingsPreference.clubUpdates,
                                  value: value,
                                ),
                        ),
                        CatchField.toggle(
                          key: SettingsKeys.weeklyDigestSwitch,
                          title: context
                              .l10n
                              .safetySettingsScreenTitleEmailUpdates,
                          icon: CatchIcons.markEmailReadOutlined,
                          value: state.preferences.weeklyDigest,
                          onChanged: operationPending
                              ? null
                              : (value) => _savePref(
                                  preference: SettingsPreference.weeklyDigest,
                                  value: value,
                                ),
                        ),
                      ],
                    ),
                    CatchSection.fieldRows(
                      title:
                          context.l10n.safetySettingsScreenTitlePrivacySafety,
                      footer: BlockedAccountsSection(
                        state: state.blockedAccounts,
                        unblocking: state.mutations.unblocking,
                        enabled: !operationPending,
                        onRetry: operationPending
                            ? null
                            : () => ref.invalidate(watchBlockedUsersProvider),
                        onUnblock: _unblockUser,
                      ),
                      children: [
                        CatchField.read(
                          title: context
                              .l10n
                              .safetySettingsScreenTitleBlockedUsers,
                          valueText: state.blockedAccounts.count?.toString(),
                          icon: CatchIcons.shieldOutlined,
                        ),
                        CatchField.read(
                          title: context
                              .l10n
                              .safetySettingsScreenTitleWhoCanSeeYou,
                          valueText: context
                              .l10n
                              .safetySettingsScreenBodyRunnersOnMyEvents,
                          icon: CatchIcons.visibilityOutlined,
                        ),
                        CatchField.toggle(
                          key: SettingsKeys.showOnMapSwitch,
                          title:
                              context.l10n.safetySettingsScreenTitleShowMeOnMap,
                          icon: CatchIcons.mapOutlined,
                          value: state.preferences.showOnMap,
                          onChanged: operationPending
                              ? null
                              : (value) => _savePref(
                                  preference: SettingsPreference.showOnMap,
                                  value: value,
                                ),
                        ),
                        if (AppConfig.privacyPolicyUrl case final uri?)
                          CatchField.nav(
                            key: SettingsKeys.privacyPolicyRow,
                            title: context
                                .l10n
                                .safetySettingsScreenTitlePrivacyPolicy,
                            icon: CatchIcons.lockOutline,
                            action:
                                _pendingExternalLink ==
                                    _SettingsExternalLinkAction.privacyPolicy
                                ? const SizedBox.square(
                                    dimension: CatchIcon.control,
                                    child: CatchLoadingIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : null,
                            onTap: operationPending
                                ? null
                                : () => _openExternal(
                                    _SettingsExternalLinkAction.privacyPolicy,
                                    uri,
                                  ),
                          ),
                        CatchField.nav(
                          key: SettingsKeys.deleteAccountRow,
                          title: context
                              .l10n
                              .safetySettingsScreenTitleDeleteAccount658588,
                          icon: CatchIcons.deleteOutline,
                          tone: CatchFieldTone.danger,
                          action: state.mutations.deletingAccount
                              ? const SizedBox.square(
                                  dimension: CatchIcon.control,
                                  child: CatchLoadingIndicator(strokeWidth: 2),
                                )
                              : null,
                          onTap: operationPending
                              ? null
                              : _confirmDeleteAccount,
                        ),
                      ],
                    ),
                    CatchSection.fieldRows(
                      title: context.l10n.safetySettingsScreenTitleAbout,
                      children: [
                        if (AppConfig.helpUrl case final uri?)
                          CatchField.nav(
                            key: SettingsKeys.helpSupportRow,
                            title: context
                                .l10n
                                .safetySettingsScreenTitleHelpSupport,
                            valueText:
                                context.l10n.safetySettingsScreenBodyContactUs,
                            icon: CatchIcons.helpOutline,
                            action:
                                _pendingExternalLink ==
                                    _SettingsExternalLinkAction.helpSupport
                                ? const SizedBox.square(
                                    dimension: CatchIcon.control,
                                    child: CatchLoadingIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : null,
                            onTap: operationPending
                                ? null
                                : () => _openExternal(
                                    _SettingsExternalLinkAction.helpSupport,
                                    uri,
                                  ),
                          ),
                        if (AppConfig.termsUrl case final uri?)
                          CatchField.nav(
                            key: SettingsKeys.termsRow,
                            title: context.l10n.safetySettingsScreenTitleTerms,
                            valueText:
                                context.l10n.safetySettingsScreenBodyLegal,
                            icon: CatchIcons.descriptionOutlined,
                            action:
                                _pendingExternalLink ==
                                    _SettingsExternalLinkAction.terms
                                ? const SizedBox.square(
                                    dimension: CatchIcon.control,
                                    child: CatchLoadingIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : null,
                            onTap: operationPending
                                ? null
                                : () => _openExternal(
                                    _SettingsExternalLinkAction.terms,
                                    uri,
                                  ),
                          ),
                        CatchField.read(
                          title: context.l10n.safetySettingsScreenTitleVersion,
                          valueText: version,
                          icon: CatchIcons.infoOutline,
                        ),
                      ],
                    ),
                    CatchSection.fieldRows(
                      children: [
                        CatchField.nav(
                          key: SettingsKeys.signOutRow,
                          title: context.l10n.safetySettingsScreenTitleLogOut,
                          icon: CatchIcons.logoutRounded,
                          tone: CatchFieldTone.danger,
                          action: state.mutations.signingOut
                              ? const SizedBox.square(
                                  dimension: CatchIcon.control,
                                  child: CatchLoadingIndicator(strokeWidth: 2),
                                )
                              : null,
                          onTap: operationPending ? null : _signOut,
                        ),
                      ],
                    ),
                    gapH20,
                    Center(
                      child: Text(
                        context.l10n.safetySettingsScreenTextVersionMade(
                          version: version,
                        ),
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
    );
  }
}

enum _SettingsExternalLinkAction { hostApp, privacyPolicy, helpSupport, terms }

class AccountProfileStatus extends StatelessWidget {
  const AccountProfileStatus({
    super.key,
    required this.profile,
    required this.onRetry,
  });

  final SettingsProfileState profile;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
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
      return Padding(
        padding: CatchInsets.content,
        child: CatchInlineErrorState(
          title: context.l10n.safetySettingsScreenTitleAccountUnavailable,
          message: context.l10n.safetySettingsScreenMessageSignOutAndSign,
          compact: true,
        ),
      );
    }

    return const SizedBox.shrink();
  }
}

class BlockedAccountsSection extends StatelessWidget {
  const BlockedAccountsSection({
    super.key,
    required this.state,
    required this.unblocking,
    this.enabled = true,
    required this.onRetry,
    required this.onUnblock,
  });

  final SettingsBlockedAccountsState state;
  final bool unblocking;
  final bool enabled;
  final VoidCallback? onRetry;
  final ValueChanged<String> onUnblock;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const CatchDivider(),
        switch (state.status) {
          SettingsBlockedAccountsStatus.loading =>
            const BlockedAccountsSkeleton(),
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
              title: context.l10n.safetySettingsScreenTitleNoBlockedAccounts,
              message:
                  context.l10n.safetySettingsScreenMessagePeopleYouBlockWill,
              iconSize: CatchIcon.tile,
              titleStyle: CatchTextStyles.sectionTitle(context),
              messageStyle: CatchTextStyles.supporting(context, color: t.ink2),
            ),
          ),
          SettingsBlockedAccountsStatus.content => Column(
            children: [
              for (var i = 0; i < state.rows.length; i++)
                BlockedAccountTile(
                  row: state.rows[i],
                  divider: i > 0,
                  unblocking: unblocking,
                  enabled: enabled,
                  onUnblock: onUnblock,
                ),
            ],
          ),
        },
      ],
    );
  }
}

class BlockedAccountsSkeleton extends StatelessWidget {
  const BlockedAccountsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
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
                        width: index == 0
                            ? CatchLayout.skeletonTextBodyWidth
                            : index == 1
                            ? CatchLayout.skeletonTextCompactWidth
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
            if (index < 2) ...[gapH12, const CatchDivider(), gapH12],
          ],
        ],
      ),
    );
  }
}

class BlockedAccountTile extends StatelessWidget {
  const BlockedAccountTile({
    super.key,
    required this.row,
    required this.divider,
    required this.unblocking,
    this.enabled = true,
    required this.onUnblock,
  });

  final SettingsBlockedAccountRow row;
  final bool divider;
  final bool unblocking;
  final bool enabled;
  final ValueChanged<String> onUnblock;

  @override
  Widget build(BuildContext context) {
    return CatchPersonRow(
      data: CatchPersonRowData(
        name: row.name,
        imageUrl: row.imageUrl,
        metaLine: row.metaLine,
        seed: row.seed,
      ),
      divider: divider,
      trailing: CatchButton(
        key: SettingsKeys.unblockButton(row.uid),
        label: context.l10n.safetySettingsScreenLabelUnblock,
        isLoading: unblocking,
        onPressed: !enabled || unblocking ? null : () => onUnblock(row.uid),
        variant: CatchButtonVariant.ghost,
        size: CatchButtonSize.sm,
      ),
    );
  }
}
