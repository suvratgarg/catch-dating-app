import 'dart:async';

import 'package:catch_dating_app/activity/domain/activity_taxonomy.dart';
import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/auth/presentation/auth_session_controller.dart';
import 'package:catch_dating_app/clubs/data/clubs_repository.dart';
import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/clubs/domain/club_host_defaults.dart';
import 'package:catch_dating_app/clubs/domain/update_club_patch.dart';
import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/theme/activity_palette.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_activity_chip.dart';
import 'package:catch_dating_app/core/widgets/catch_adaptive_picker.dart';
import 'package:catch_dating_app/core/widgets/catch_badge.dart';
import 'package:catch_dating_app/core/widgets/catch_bottom_sheet.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_error_banner.dart';
import 'package:catch_dating_app/core/widgets/catch_error_snackbar.dart';
import 'package:catch_dating_app/core/widgets/catch_error_state.dart';
import 'package:catch_dating_app/core/widgets/catch_loading_indicator.dart';
import 'package:catch_dating_app/core/widgets/catch_option_group.dart';
import 'package:catch_dating_app/core/widgets/catch_select_chip.dart';
import 'package:catch_dating_app/core/widgets/catch_settings_row.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/core/widgets/catch_text_field.dart';
import 'package:catch_dating_app/core/widgets/catch_top_bar.dart';
import 'package:catch_dating_app/event_policies/domain/event_policy.dart';
import 'package:catch_dating_app/event_policies/domain/event_policy_defaults.dart';
import 'package:catch_dating_app/events/data/event_repository.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/presentation/event_formatters.dart';
import 'package:catch_dating_app/hosts/data/host_analytics_repository.dart';
import 'package:catch_dating_app/hosts/data/host_profile_repository.dart';
import 'package:catch_dating_app/hosts/domain/host_profile.dart';
import 'package:catch_dating_app/hosts/presentation/payments/host_payment_account_card.dart';
import 'package:catch_dating_app/hosts/presentation/widgets/host_team_management_section.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:catch_dating_app/user_profile/presentation/widgets/profile_inline_editors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class HostOperationsHomeScreen extends ConsumerWidget {
  const HostOperationsHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uid = ref.watch(uidProvider).asData?.value;
    if (uid == null) return const _HostAuthRequiredScreen();

    final clubsAsync = ref.watch(_hostClubsForUserProvider(uid));
    return clubsAsync.when(
      loading: () => const _HostLoadingScreen(),
      error: (error, _) => CatchErrorScaffold.fromError(
        error,
        context: AppErrorContext.club,
        onRetry: () => ref.invalidate(_hostClubsForUserProvider(uid)),
      ),
      data: (clubs) => _HostEventsScaffold(clubs: clubs, currentUid: uid),
    );
  }
}

class HostClubsScreen extends ConsumerWidget {
  const HostClubsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uid = ref.watch(uidProvider).asData?.value;
    if (uid == null) return const _HostAuthRequiredScreen();

    final clubsAsync = ref.watch(_hostClubsForUserProvider(uid));
    return clubsAsync.when(
      loading: () => const _HostLoadingScreen(),
      error: (error, _) => CatchErrorScaffold.fromError(
        error,
        context: AppErrorContext.club,
        onRetry: () => ref.invalidate(_hostClubsForUserProvider(uid)),
      ),
      data: (clubs) => _HostClubsScaffold(clubs: clubs, currentUid: uid),
    );
  }
}

enum _HostAccountTab { edit, preview }

enum _HostClubTab { edit, insights, preview }

const _hostClubTabRailKey = ValueKey('host-club-tab-rail');

class HostAccountScreen extends ConsumerStatefulWidget {
  const HostAccountScreen({super.key});

  @override
  ConsumerState<HostAccountScreen> createState() => _HostAccountScreenState();
}

class _HostAccountScreenState extends ConsumerState<HostAccountScreen> {
  var _selectedTab = _HostAccountTab.edit;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final uid = ref.watch(uidProvider).asData?.value;
    final hostProfileAsync = uid == null
        ? const AsyncData<HostProfile?>(null)
        : ref.watch(watchHostProfileProvider(uid));
    final clubsAsync = uid == null
        ? const AsyncData<List<Club>>([])
        : ref.watch(_hostClubsForUserProvider(uid));
    final loadedProfile = hostProfileAsync.asData?.value;
    final fallbackProfile = uid == null
        ? null
        : _fallbackHostProfileFromClubs(uid, clubsAsync.asData?.value);
    final profile = loadedProfile ?? fallbackProfile;
    final isEditMode = _selectedTab == _HostAccountTab.edit;
    final profileIsBlockedLoading =
        hostProfileAsync.isLoading && profile == null;
    final profileIsBlockedError = hostProfileAsync.hasError && profile == null;

    return Scaffold(
      backgroundColor: t.bg,
      appBar: CatchTopBar(
        title: 'Host profile',
        showBackButton: false,
        border: true,
        actions: [
          CatchTopBarIconAction(
            tooltip: 'Sign out',
            icon: CatchIcons.logoutRounded,
            onPressed: () => unawaited(_signOut(context, ref)),
          ),
        ],
        bottom: _HostAccountTabRail(
          selected: _selectedTab,
          onChanged: (tab) => setState(() => _selectedTab = tab),
        ),
      ),
      body: ListView(
        padding: CatchInsets.pageBodyUnderHeader,
        children: [
          if (profileIsBlockedLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: CatchSpacing.s4),
              child: CatchLoadingIndicator(),
            )
          else if (profileIsBlockedError)
            CatchErrorState.fromError(
              hostProfileAsync.error!,
              onRetry: uid == null
                  ? null
                  : () => ref.invalidate(watchHostProfileProvider(uid)),
            )
          else if (profile == null)
            _HostAccountSection(
              label: 'Profile',
              first: true,
              children: [
                CatchSettingsRow(
                  label: 'Display name',
                  value: 'Create host profile',
                  icon: CatchIcons.businessOutlined,
                  onTap: uid == null
                      ? null
                      : () => unawaited(_createHostProfile(uid)),
                ),
              ],
            )
          else ...[
            _HostAccountSection(
              label: 'Profile',
              first: true,
              children: [
                CatchSettingsRow(
                  label: 'Display name',
                  value: profile.displayName,
                  icon: CatchIcons.personOutlineRounded,
                  onTap: isEditMode && uid != null
                      ? () => unawaited(_openProfileEditor(uid, profile))
                      : null,
                  showChevron: isEditMode,
                ),
                CatchSettingsRow(
                  label: 'Role title',
                  value: profile.roleTitle?.trim().isNotEmpty == true
                      ? profile.roleTitle!.trim()
                      : 'Add role title',
                  icon: CatchIcons.cardMembershipOutlined,
                  divider: true,
                  onTap: isEditMode && uid != null
                      ? () => unawaited(_openProfileEditor(uid, profile))
                      : null,
                  showChevron: isEditMode,
                ),
                CatchSettingsRow(
                  label: 'Status',
                  value: _hostProfileStatusLabel(profile.status),
                  icon: CatchIcons.checkCircleOutlineRounded,
                  divider: true,
                  showChevron: false,
                ),
              ],
            ),
            _HostAccountSection(
              label: 'Bio',
              children: [
                CatchSettingsRow(
                  label: 'About you as a host',
                  value: profile.bio?.trim().isNotEmpty == true
                      ? profile.bio!.trim()
                      : 'Add a host bio',
                  icon: CatchIcons.chatBubbleOutlineRounded,
                  valueMaxLines: 2,
                  onTap: isEditMode && uid != null
                      ? () => unawaited(_openProfileEditor(uid, profile))
                      : null,
                  showChevron: isEditMode,
                ),
              ],
            ),
          ],
          _HostAccountClubsSection(
            uid: uid,
            clubsAsync: clubsAsync,
            editMode: isEditMode,
          ),
        ],
      ),
    );
  }

  Future<void> _openProfileEditor(String uid, HostProfile profile) async {
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _HostProfileEditorSheet(uid: uid, profile: profile),
    );
    if (saved == true && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Host profile saved.')));
    }
  }

  Future<void> _createHostProfile(String uid) async {
    await ref
        .read(hostProfileRepositoryProvider)
        .ensureHostProfile(uid: uid, displayName: 'Catch Host');
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Host profile created.')));
  }

  Future<void> _signOut(BuildContext context, WidgetRef ref) async {
    final mutation = ref.read(AuthSessionController.signOutMutation);
    if (mutation.isPending) return;
    try {
      await AuthSessionController.signOutMutation.run(
        ref,
        (tx) async => tx.get(authSessionControllerProvider.notifier).signOut(),
      );
    } catch (error) {
      if (!context.mounted) return;
      showCatchErrorSnackBar(context, error);
      return;
    }
    if (context.mounted) context.go(Routes.startScreen.path);
  }
}

class _HostAccountTabRail extends StatelessWidget
    implements PreferredSizeWidget {
  const _HostAccountTabRail({required this.selected, required this.onChanged});

  final _HostAccountTab selected;
  final ValueChanged<_HostAccountTab> onChanged;

  @override
  Size get preferredSize => const Size.fromHeight(48);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: preferredSize.height,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          CatchSpacing.s5,
          0,
          CatchSpacing.s5,
          CatchSpacing.s2,
        ),
        child: CatchOptionGroup<_HostAccountTab>(
          selected: selected,
          onChanged: onChanged,
          options: const [
            CatchOption(value: _HostAccountTab.edit, label: 'Edit'),
            CatchOption(value: _HostAccountTab.preview, label: 'Preview'),
          ],
        ),
      ),
    );
  }
}

HostProfile? _fallbackHostProfileFromClubs(String uid, List<Club>? clubs) {
  if (clubs == null || clubs.isEmpty) return null;
  final hostedClubs = clubs.where((club) => club.isHostedBy(uid)).toList();
  if (hostedClubs.isEmpty) return null;
  final firstClub = hostedClubs.first;
  ClubHostProfile? clubHostProfile;
  for (final club in hostedClubs) {
    for (final profile in club.displayHostProfiles) {
      if (profile.uid == uid) {
        clubHostProfile = profile;
        break;
      }
    }
    if (clubHostProfile != null) break;
  }

  final displayName = _firstNonBlank([
    clubHostProfile?.displayName,
    firstClub.hostName,
    firstClub.displayHostName,
    'Catch Host',
  ]);
  final avatarUrl = _firstNonBlank([
    clubHostProfile?.avatarUrl,
    firstClub.hostAvatarUrl,
  ]);
  final ownsAnyClub = hostedClubs.any((club) => club.isOwnedBy(uid));

  return HostProfile(
    uid: uid,
    displayName: displayName,
    avatarUrl: avatarUrl,
    roleTitle: ownsAnyClub ? 'Owner' : 'Host team',
    status: HostProfileStatus.active,
    linkedClubIds: [for (final club in hostedClubs) club.id],
    createdAt: null,
    updatedAt: null,
  );
}

String _firstNonBlank(Iterable<String?> values) {
  for (final value in values) {
    final trimmed = value?.trim();
    if (trimmed != null && trimmed.isNotEmpty) return trimmed;
  }
  return 'Catch Host';
}

class _HostAccountSection extends StatelessWidget {
  const _HostAccountSection({
    required this.label,
    required this.children,
    this.first = false,
  });

  final String label;
  final List<Widget> children;
  final bool first;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return Padding(
      padding: EdgeInsets.only(top: first ? 0 : CatchSpacing.s2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!first) ...[
            Divider(color: t.line, height: 1, thickness: 1),
            gapH18,
          ],
          Text(label, style: CatchTextStyles.kicker(context, color: t.ink2)),
          gapH10,
          ...children,
        ],
      ),
    );
  }
}

class _HostAccountClubsSection extends ConsumerWidget {
  const _HostAccountClubsSection({
    required this.uid,
    required this.clubsAsync,
    required this.editMode,
  });

  final String? uid;
  final AsyncValue<List<Club>> clubsAsync;
  final bool editMode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = CatchTokens.of(context);
    final clubs = clubsAsync.asData?.value;

    return _HostAccountSection(
      label: 'Clubs you host',
      children: [
        if (clubsAsync.isLoading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: CatchSpacing.s4),
            child: CatchLoadingIndicator(),
          )
        else if (clubsAsync.hasError)
          CatchErrorState.fromError(
            clubsAsync.error!,
            onRetry: uid == null
                ? null
                : () => ref.invalidate(_hostClubsForUserProvider(uid!)),
          )
        else if (clubs == null || clubs.isEmpty)
          Text(
            'No host clubs yet.',
            style: CatchTextStyles.supporting(context, color: t.ink2),
          )
        else
          for (final club in clubs) ...[
            CatchSettingsRow(
              label: club.isOwnedBy(uid) ? 'Owner' : 'Host team',
              value: club.name,
              icon: CatchIcons.groupOutlined,
              divider: club != clubs.first,
              onTap: () => context.pushNamed(
                editMode && club.isOwnedBy(uid)
                    ? Routes.hostEditClubScreen.name
                    : Routes.hostClubDetailScreen.name,
                pathParameters: {'clubId': club.id},
                extra: club,
              ),
            ),
          ],
      ],
    );
  }
}

class _HostProfileEditorSheet extends ConsumerStatefulWidget {
  const _HostProfileEditorSheet({required this.uid, required this.profile});

  final String uid;
  final HostProfile profile;

  @override
  ConsumerState<_HostProfileEditorSheet> createState() =>
      _HostProfileEditorSheetState();
}

class _HostProfileEditorSheetState
    extends ConsumerState<_HostProfileEditorSheet> {
  final _formKey = GlobalKey<FormState>();
  final _displayNameController = TextEditingController();
  final _roleTitleController = TextEditingController();
  final _bioController = TextEditingController();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _displayNameController.text = widget.profile.displayName;
    _roleTitleController.text = widget.profile.roleTitle ?? '';
    _bioController.text = widget.profile.bio ?? '';
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _roleTitleController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: CatchBottomSheetScaffold(
        title: 'Professional profile',
        subtitle: _hostProfileStatusLabel(widget.profile.status),
        keyboardSafe: true,
        action: CatchButton(
          label: 'Save profile',
          icon: Icon(CatchIcons.checkRounded, size: CatchIcon.md),
          isLoading: _saving,
          fullWidth: true,
          onPressed: _saving ? null : () => unawaited(_saveProfile()),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CatchTextField(
              label: 'Display name',
              controller: _displayNameController,
              textInputAction: TextInputAction.next,
              textCapitalization: TextCapitalization.words,
              validator: _requiredDisplayName,
            ),
            gapH14,
            CatchTextField(
              label: 'Role title',
              isOptional: true,
              controller: _roleTitleController,
              textInputAction: TextInputAction.next,
              textCapitalization: TextCapitalization.words,
            ),
            gapH14,
            CatchTextField(
              label: 'Bio',
              isOptional: true,
              controller: _bioController,
              minLines: 4,
              maxLines: 6,
              textCapitalization: TextCapitalization.sentences,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState?.validate() != true) return;
    setState(() => _saving = true);
    try {
      await ref
          .read(hostProfileRepositoryProvider)
          .saveHostProfile(
            uid: widget.uid,
            displayName: _displayNameController.text,
            roleTitle: _roleTitleController.text,
            bio: _bioController.text,
          );
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;
      showCatchErrorSnackBar(context, error);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}

class HostProfileScreen extends ConsumerStatefulWidget {
  const HostProfileScreen({super.key});

  @override
  ConsumerState<HostProfileScreen> createState() => _HostProfileScreenState();
}

class _HostProfileScreenState extends ConsumerState<HostProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _displayNameController = TextEditingController();
  final _roleTitleController = TextEditingController();
  final _bioController = TextEditingController();
  String? _loadedProfileKey;
  bool _saving = false;

  @override
  void dispose() {
    _displayNameController.dispose();
    _roleTitleController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final uid = ref.watch(uidProvider).asData?.value;
    if (uid == null) return const _HostAuthRequiredScreen();

    final profileAsync = ref.watch(watchHostProfileProvider(uid));
    return Scaffold(
      backgroundColor: t.bg,
      appBar: CatchTopBar(
        border: true,
        titleWidget: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'HOST PROFILE',
              style: CatchTextStyles.kicker(context, color: t.ink3),
            ),
            gapH2,
            Text(
              'Professional profile',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: CatchTextStyles.titleL(context, color: t.ink),
            ),
          ],
        ),
      ),
      body: profileAsync.when(
        loading: () => const CatchLoadingIndicator(),
        error: (error, _) => CatchErrorState.fromError(
          error,
          onRetry: () => ref.invalidate(watchHostProfileProvider(uid)),
        ),
        data: (profile) {
          if (profile == null) {
            return _HostProfileMissingState(uid: uid);
          }
          _syncControllers(profile);
          return Form(
            key: _formKey,
            child: ListView(
              padding: CatchInsets.pageBodyUnderHeader,
              children: [
                CatchSurface(
                  padding: CatchInsets.content,
                  borderColor: t.line,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _hostProfileStatusLabel(profile.status),
                        style: CatchTextStyles.supporting(
                          context,
                          color: profile.isActive ? t.success : t.ink2,
                        ),
                      ),
                      gapH14,
                      CatchTextField(
                        label: 'Display name',
                        controller: _displayNameController,
                        textInputAction: TextInputAction.next,
                        textCapitalization: TextCapitalization.words,
                        validator: _requiredDisplayName,
                      ),
                      gapH14,
                      CatchTextField(
                        label: 'Role title',
                        isOptional: true,
                        controller: _roleTitleController,
                        textInputAction: TextInputAction.next,
                        textCapitalization: TextCapitalization.words,
                      ),
                      gapH14,
                      CatchTextField(
                        label: 'Bio',
                        isOptional: true,
                        controller: _bioController,
                        minLines: 4,
                        maxLines: 6,
                        textCapitalization: TextCapitalization.sentences,
                      ),
                      gapH18,
                      CatchButton(
                        label: 'Save profile',
                        icon: Icon(CatchIcons.checkRounded, size: CatchIcon.md),
                        isLoading: _saving,
                        fullWidth: true,
                        onPressed: _saving
                            ? null
                            : () => unawaited(_saveProfile(uid)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _syncControllers(HostProfile profile) {
    final key = [
      profile.uid,
      profile.displayName,
      profile.roleTitle,
      profile.bio,
      profile.updatedAt?.microsecondsSinceEpoch,
    ].join('|');
    if (_loadedProfileKey == key) return;
    _loadedProfileKey = key;
    _displayNameController.text = profile.displayName;
    _roleTitleController.text = profile.roleTitle ?? '';
    _bioController.text = profile.bio ?? '';
  }

  Future<void> _saveProfile(String uid) async {
    if (_formKey.currentState?.validate() != true) return;
    setState(() => _saving = true);
    try {
      await ref
          .read(hostProfileRepositoryProvider)
          .saveHostProfile(
            uid: uid,
            displayName: _displayNameController.text,
            roleTitle: _roleTitleController.text,
            bio: _bioController.text,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Host profile saved.')));
    } catch (error) {
      if (!mounted) return;
      showCatchErrorSnackBar(context, error);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}

class _HostProfileMissingState extends ConsumerWidget {
  const _HostProfileMissingState({required this.uid});

  final String uid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = CatchTokens.of(context);
    return ListView(
      padding: CatchInsets.pageBodyUnderHeader,
      children: [
        CatchSurface(
          padding: CatchInsets.content,
          borderColor: t.line,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'No host profile yet',
                style: CatchTextStyles.sectionTitle(context),
              ),
              gapH8,
              Text(
                'Create a professional host identity before editing profile details.',
                style: CatchTextStyles.supporting(context, color: t.ink2),
              ),
              gapH18,
              CatchButton(
                label: 'Create host profile',
                icon: Icon(CatchIcons.businessOutlined, size: CatchIcon.md),
                onPressed: () async {
                  try {
                    await ref
                        .read(hostProfileRepositoryProvider)
                        .ensureHostProfile(uid: uid, displayName: 'Catch Host');
                  } catch (error) {
                    if (context.mounted) showCatchErrorSnackBar(context, error);
                  }
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

String? _requiredDisplayName(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Enter a display name.';
  }
  return null;
}

String _hostProfileStatusLabel(HostProfileStatus status) {
  return switch (status) {
    HostProfileStatus.active => 'Active professional profile',
    HostProfileStatus.pending => 'Profile pending review',
    HostProfileStatus.suspended => 'Profile suspended',
  };
}

class _HostEventsScaffold extends StatefulWidget {
  const _HostEventsScaffold({required this.clubs, required this.currentUid});

  final List<Club> clubs;
  final String currentUid;

  @override
  State<_HostEventsScaffold> createState() => _HostEventsScaffoldState();
}

class _HostEventsScaffoldState extends State<_HostEventsScaffold> {
  var _selectedClubIndex = 0;

  @override
  void didUpdateWidget(_HostEventsScaffold oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_selectedClubIndex >= widget.clubs.length) {
      _selectedClubIndex = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final hasClubs = widget.clubs.isNotEmpty;
    final selectedClub = hasClubs ? widget.clubs[_selectedClubIndex] : null;
    final showClubPicker = widget.clubs.length > 1;

    return Scaffold(
      backgroundColor: t.bg,
      appBar: _HostOperationsTopBar(
        kicker: 'OPERATIONS',
        title: selectedClub?.name ?? 'Host events',
        actions: [
          if (showClubPicker)
            CatchTopBarMenuAction<int>(
              tooltip: 'Switch club',
              icon: CatchIcons.expandMoreRounded,
              items: [
                for (var index = 0; index < widget.clubs.length; index++)
                  CatchActionMenuItem(
                    value: index,
                    label:
                        '${widget.clubs[index].name} · '
                        '${widget.clubs[index].isOwnedBy(widget.currentUid) ? 'Owner' : 'Host team'}',
                  ),
              ],
              onSelected: (index) => setState(() => _selectedClubIndex = index),
            ),
        ],
      ),
      body: ListView(
        padding: CatchInsets.pageBodyUnderHeader,
        children: [
          if (selectedClub == null)
            const _HostEmptyState(
              title: 'Create your first club',
              body:
                  'Create a club to publish events, manage attendees, and run Event Success.',
            )
          else
            _HostEventsClubCard(
              club: selectedClub,
              currentUid: widget.currentUid,
            ),
        ],
      ),
    );
  }
}

class _HostClubsScaffold extends StatefulWidget {
  const _HostClubsScaffold({required this.clubs, required this.currentUid});

  final List<Club> clubs;
  final String currentUid;

  @override
  State<_HostClubsScaffold> createState() => _HostClubsScaffoldState();
}

class _HostClubsScaffoldState extends State<_HostClubsScaffold> {
  var _selectedClubIndex = 0;
  var _selectedTab = _HostClubTab.edit;

  @override
  void didUpdateWidget(_HostClubsScaffold oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_selectedClubIndex >= widget.clubs.length) {
      _selectedClubIndex = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final hasClubs = widget.clubs.isNotEmpty;
    final selectedClub = hasClubs ? widget.clubs[_selectedClubIndex] : null;
    final showClubPicker = widget.clubs.length > 1;

    return Scaffold(
      backgroundColor: t.bg,
      appBar: _HostOperationsTopBar(
        kicker: 'HOST CLUBS',
        title: selectedClub?.name ?? 'Clubs',
        bottom: selectedClub == null
            ? null
            : _HostClubTabRail(
                selected: _selectedTab,
                onChanged: (tab) => setState(() => _selectedTab = tab),
              ),
        actions: [
          if (showClubPicker)
            CatchTopBarMenuAction<int>(
              tooltip: 'Switch club',
              icon: CatchIcons.expandMoreRounded,
              items: [
                for (var index = 0; index < widget.clubs.length; index++)
                  CatchActionMenuItem(
                    value: index,
                    label:
                        '${widget.clubs[index].name} · '
                        '${widget.clubs[index].isOwnedBy(widget.currentUid) ? 'Owner' : 'Host team'}',
                  ),
              ],
              onSelected: (index) => setState(() => _selectedClubIndex = index),
            ),
        ],
      ),
      body: ListView(
        padding: CatchInsets.pageBodyUnderHeader,
        children: [
          if (selectedClub == null)
            const _HostEmptyState(
              title: 'No host clubs yet',
              body:
                  'Create a club or accept a host invite to start managing events.',
            )
          else
            switch (_selectedTab) {
              _HostClubTab.edit => _HostClubProfileCard(
                club: selectedClub,
                currentUid: widget.currentUid,
                isOwner: selectedClub.isOwnedBy(widget.currentUid),
              ),
              _HostClubTab.insights => _HostClubInsightsPane(
                club: selectedClub,
              ),
              _HostClubTab.preview => _HostClubPreviewPane(club: selectedClub),
            },
        ],
      ),
    );
  }
}

class _HostClubTabRail extends StatelessWidget implements PreferredSizeWidget {
  const _HostClubTabRail({required this.selected, required this.onChanged});

  final _HostClubTab selected;
  final ValueChanged<_HostClubTab> onChanged;

  @override
  Size get preferredSize => const Size.fromHeight(48);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: preferredSize.height,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          CatchSpacing.s5,
          0,
          CatchSpacing.s5,
          CatchSpacing.s2,
        ),
        child: CatchOptionGroup<_HostClubTab>(
          key: _hostClubTabRailKey,
          selected: selected,
          onChanged: onChanged,
          options: const [
            CatchOption(value: _HostClubTab.edit, label: 'Edit'),
            CatchOption(value: _HostClubTab.insights, label: 'Insights'),
            CatchOption(value: _HostClubTab.preview, label: 'Preview'),
          ],
        ),
      ),
    );
  }
}

class _HostOperationsTopBar extends StatelessWidget
    implements PreferredSizeWidget {
  const _HostOperationsTopBar({
    required this.kicker,
    required this.title,
    this.actions = const [],
    this.bottom,
  });

  final String kicker;
  final String title;
  final List<Widget> actions;
  final PreferredSizeWidget? bottom;

  @override
  Size get preferredSize => Size.fromHeight(
    CatchLayout.topBarHeight + (bottom?.preferredSize.height ?? 0),
  );

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return CatchTopBar(
      border: true,
      actions: actions,
      bottom: bottom,
      titleWidget: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(kicker, style: CatchTextStyles.kicker(context, color: t.ink3)),
          gapH2,
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: CatchTextStyles.titleL(context, color: t.ink),
          ),
        ],
      ),
    );
  }
}

class _HostSectionLabel extends StatelessWidget {
  const _HostSectionLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Text(label, style: CatchTextStyles.kicker(context, color: t.ink3));
  }
}

class _HostEventsClubCard extends ConsumerWidget {
  const _HostEventsClubCard({required this.club, required this.currentUid});

  final Club club;
  final String currentUid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = CatchTokens.of(context);
    final eventsAsync = ref.watch(watchEventsForClubProvider(club.id));
    final events = [...?eventsAsync.asData?.value]
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
    final upcoming = events
        .where((event) => !event.isCancelled)
        .take(3)
        .toList(growable: false);
    final owner = club.isOwnedBy(currentUid);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _HostMetaRow(
          club: club,
          roleLabel: owner ? 'Owner' : 'Host team',
          owner: owner,
        ),
        gapH24,
        const _HostSectionLabel(label: 'Upcoming'),
        gapH8,
        if (eventsAsync.isLoading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: CatchSpacing.s4),
            child: CatchLoadingIndicator(),
          )
        else ...[
          for (final event in upcoming)
            _HostEventRow(
              club: club,
              event: event,
              divider: event != upcoming.first,
            ),
          CatchSettingsRow(
            label: 'Add event',
            icon: CatchIcons.addRounded,
            divider: upcoming.isNotEmpty,
            onTap: () => context.pushNamed(
              Routes.hostCreateEventScreen.name,
              pathParameters: {'clubId': club.id},
              extra: club,
            ),
          ),
          if (upcoming.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: CatchSpacing.s2),
              child: Text(
                'No active events yet.',
                style: CatchTextStyles.supporting(context, color: t.ink2),
              ),
            ),
        ],
      ],
    );
  }
}

class _HostMetaRow extends StatelessWidget {
  const _HostMetaRow({
    required this.club,
    required this.roleLabel,
    required this.owner,
  });

  final Club club;
  final String roleLabel;
  final bool owner;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final area = [
      if (club.area.trim().isNotEmpty) club.area.trim(),
      if (club.location.trim().isNotEmpty) club.location.trim(),
    ].join(' · ');

    return Wrap(
      spacing: CatchSpacing.s2,
      runSpacing: CatchSpacing.s2,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        if (area.isNotEmpty)
          Text(
            area.toUpperCase(),
            style: CatchTextStyles.monoLabel(context, color: t.ink3),
          ),
        CatchBadge(
          label: roleLabel,
          tone: owner ? CatchBadgeTone.solid : CatchBadgeTone.neutral,
          uppercase: true,
        ),
        CatchActivityChip(
          activityKind: club.hostDefaults.primaryActivityKind,
          primary: true,
        ),
      ],
    );
  }
}

class _HostClubProfileCard extends ConsumerStatefulWidget {
  const _HostClubProfileCard({
    required this.club,
    required this.currentUid,
    required this.isOwner,
  });

  final Club club;
  final String currentUid;
  final bool isOwner;

  @override
  ConsumerState<_HostClubProfileCard> createState() =>
      _HostClubProfileCardState();
}

class _HostClubProfileCardState extends ConsumerState<_HostClubProfileCard> {
  String? _expandedField;

  bool _isExpanded(String fieldName) => _expandedField == fieldName;

  void _toggleField(String fieldName) {
    setState(() {
      _expandedField = _expandedField == fieldName ? null : fieldName;
    });
  }

  void _collapseField() {
    if (_expandedField == null) return;
    setState(() => _expandedField = null);
  }

  @override
  void didUpdateWidget(covariant _HostClubProfileCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.club.id != widget.club.id) {
      _expandedField = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final club = widget.club;
    final isOwner = widget.isOwner;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _HostMetaRow(
          club: club,
          roleLabel: isOwner ? 'Owner' : 'Host team',
          owner: isOwner,
        ),
        gapH24,
        _HostAccountSection(
          label: 'Identity',
          first: true,
          children: [
            _textEntry(
              club: club,
              fieldName: 'name',
              label: 'Club name',
              value: club.name,
              currentValue: club.name,
              icon: CatchIcons.groups3Outlined,
              validator: _requiredHostFieldValidator('Club name'),
              normalizeInput: _normalizeSingleLineInput,
              patchForValue: (value) => UpdateClubPatch(name: value as String),
            ),
            _textEntry(
              club: club,
              fieldName: 'location',
              label: 'City',
              value: _valueOrDash(club.location),
              currentValue: club.location,
              icon: CatchIcons.locationCityOutlined,
              validator: _requiredHostFieldValidator('City'),
              normalizeInput: _normalizeSingleLineInput,
              patchForValue: (value) =>
                  UpdateClubPatch(location: value as String),
            ),
            _textEntry(
              club: club,
              fieldName: 'area',
              label: 'Area / neighbourhood',
              value: _valueOrDash(club.area),
              currentValue: club.area,
              icon: CatchIcons.locationOnOutlined,
              validator: _requiredHostFieldValidator('Area / neighbourhood'),
              normalizeInput: _normalizeSingleLineInput,
              patchForValue: (value) => UpdateClubPatch(area: value as String),
            ),
            _textEntry(
              club: club,
              fieldName: 'description',
              label: 'Description',
              value: _valueOrDash(club.description),
              currentValue: club.description,
              icon: CatchIcons.descriptionOutlined,
              maxLines: 3,
              minLines: 2,
              maxLength: 280,
              showCounter: true,
              keyboardType: TextInputType.multiline,
              validator: _requiredHostFieldValidator('Description'),
              normalizeInput: _normalizeMultilineInput,
              patchForValue: (value) =>
                  UpdateClubPatch(description: value as String),
            ),
          ],
        ),
        _HostAccountSection(
          label: 'Contact',
          children: [
            _textEntry(
              club: club,
              fieldName: 'instagramHandle',
              label: 'Instagram',
              value: _valueOrDash(club.instagramHandle),
              placeholder: '@yourclub',
              currentValue: club.instagramHandle ?? '',
              currentFieldValue: club.instagramHandle,
              icon: CatchIcons.alternateEmailRounded,
              keyboardType: TextInputType.text,
              normalizeInput: _normalizeSingleLineInput,
              toFieldValue: _optionalStringFieldValue,
              patchForValue: (value) => UpdateClubPatch(instagramHandle: value),
            ),
            _textEntry(
              club: club,
              fieldName: 'phoneNumber',
              label: 'Phone',
              value: _valueOrDash(club.phoneNumber),
              placeholder: '98765 43210',
              currentValue: club.phoneNumber ?? '',
              currentFieldValue: club.phoneNumber,
              icon: CatchIcons.phoneOutlined,
              keyboardType: TextInputType.phone,
              normalizeInput: _normalizeSingleLineInput,
              toFieldValue: _optionalStringFieldValue,
              patchForValue: (value) => UpdateClubPatch(phoneNumber: value),
            ),
            _textEntry(
              club: club,
              fieldName: 'email',
              label: 'Email',
              value: _valueOrDash(club.email),
              placeholder: 'hello@yourclub.com',
              currentValue: club.email ?? '',
              currentFieldValue: club.email,
              icon: CatchIcons.emailOutlined,
              keyboardType: TextInputType.emailAddress,
              normalizeInput: _normalizeSingleLineInput,
              validator: _optionalEmailValidator,
              toFieldValue: _optionalStringFieldValue,
              patchForValue: (value) => UpdateClubPatch(email: value),
            ),
          ],
        ),
        _HostAccountSection(
          label: 'Event defaults',
          children: [
            _activityDefaultEntry(club),
            _admissionDefaultEntry(club),
            _ageRangeDefaultEntry(club),
            _cancellationDefaultEntry(club),
          ],
        ),
        _HostAccountSection(
          label: 'Public profile',
          children: [
            CatchSettingsRow(
              label: 'Preview club page',
              value: 'Preview',
              icon: CatchIcons.visibilityOutlined,
              onTap: () => context.pushNamed(
                Routes.hostClubDetailScreen.name,
                pathParameters: {'clubId': club.id},
                extra: club,
              ),
            ),
          ],
        ),
        if (isOwner) ...[
          _HostAccountSection(
            label: 'Payouts',
            children: [HostPaymentAccountCard(club: club)],
          ),
          _HostAccountSection(
            label: 'Host team',
            children: [
              HostTeamManagementSection(
                club: club,
                currentUid: widget.currentUid,
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _textEntry({
    required Club club,
    required String fieldName,
    required String label,
    required String value,
    required String currentValue,
    required IconData icon,
    required UpdateClubPatch Function(Object? value) patchForValue,
    Object? currentFieldValue,
    String? placeholder,
    TextInputType? keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.sentences,
    int? maxLines = 1,
    int? minLines,
    int? maxLength,
    bool showCounter = false,
    String Function(String value)? normalizeInput,
    FormFieldValidator<String>? validator,
    Object? Function(String value)? toFieldValue,
  }) {
    if (!widget.isOwner) {
      return CatchSettingsRow(label: label, value: value, icon: icon);
    }

    return _HostInlineTextEntryEditor(
      key: ValueKey('host-inline-$fieldName'),
      clubId: club.id,
      icon: icon,
      label: label,
      value: value,
      currentValue: currentValue,
      currentFieldValue: currentFieldValue ?? currentValue,
      fieldName: fieldName,
      isExpanded: _isExpanded(fieldName),
      placeholder: placeholder,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      maxLines: maxLines,
      minLines: minLines,
      maxLength: maxLength,
      showCounter: showCounter,
      normalizeInput: normalizeInput,
      validator: validator,
      toFieldValue: toFieldValue,
      patchForValue: patchForValue,
      onTap: () => _toggleField(fieldName),
      onSaved: _collapseField,
      onCancel: _collapseField,
    );
  }

  Widget _activityDefaultEntry(Club club) {
    const fieldName = 'primaryActivityKind';
    final selected = club.hostDefaults.primaryActivityKind;
    if (!widget.isOwner) {
      return CatchSettingsRow(
        label: 'Default activity',
        value: selected.label,
        icon: CatchIcons.eventOutlined,
      );
    }

    return _HostInlineOptionEditor<ActivityKind>(
      key: const ValueKey('host-inline-primaryActivityKind'),
      clubId: club.id,
      icon: CatchIcons.eventOutlined,
      label: 'Default activity',
      value: selected.label,
      currentValue: selected,
      fieldName: fieldName,
      isExpanded: _isExpanded(fieldName),
      options: [
        for (final activityKind in ActivityKind.eventCreationDefaults)
          _HostInlineOption(
            value: activityKind,
            label: activityKind.label,
            accentColor: ActivityPalette.resolve(context, activityKind).accent,
          ),
      ],
      patchForValue: (activityKind) => UpdateClubPatch(
        hostDefaults: _hostDefaultsWithActivity(
          club.hostDefaults,
          activityKind,
        ),
      ),
      onTap: () => _toggleField(fieldName),
      onSaved: _collapseField,
      onCancel: _collapseField,
    );
  }

  Widget _admissionDefaultEntry(Club club) {
    const fieldName = 'admissionPreset';
    final selected = club.hostDefaults.eventPolicy.admissionPreset;
    if (!widget.isOwner) {
      return CatchSettingsRow(
        label: 'Admission',
        value: _admissionDefaultLabel(selected),
        icon: CatchIcons.eventSeatOutlined,
      );
    }

    return _HostInlineOptionEditor<EventAdmissionDefaultPreset>(
      key: const ValueKey('host-inline-admissionPreset'),
      clubId: club.id,
      icon: CatchIcons.eventSeatOutlined,
      label: 'Admission',
      value: _admissionDefaultLabel(selected),
      currentValue: selected,
      fieldName: fieldName,
      isExpanded: _isExpanded(fieldName),
      helperText: _admissionDefaultDescription(selected),
      options: [
        for (final preset in EventAdmissionDefaultPreset.values)
          _HostInlineOption(
            value: preset,
            label: _admissionDefaultLabel(preset),
          ),
      ],
      patchForValue: (preset) {
        final policy = club.hostDefaults.eventPolicy;
        return UpdateClubPatch(
          hostDefaults: club.hostDefaults.copyWith(
            eventPolicy: policy.copyWith(
              admissionPreset: preset,
              dynamicPricingEnabled:
                  preset == EventAdmissionDefaultPreset.balancedSingles
                  ? policy.dynamicPricingEnabled
                  : false,
            ),
          ),
        );
      },
      onTap: () => _toggleField(fieldName),
      onSaved: _collapseField,
      onCancel: _collapseField,
    );
  }

  Widget _ageRangeDefaultEntry(Club club) {
    const fieldName = 'ageRange';
    final policy = club.hostDefaults.eventPolicy;
    final value = '${policy.minAge}–${policy.maxAge}';
    if (!widget.isOwner) {
      return CatchSettingsRow(
        label: 'Age range',
        value: value,
        icon: CatchIcons.cakeOutlined,
      );
    }

    return _HostInlineAgeRangeEditor(
      key: const ValueKey('host-inline-ageRange'),
      clubId: club.id,
      icon: CatchIcons.cakeOutlined,
      label: 'Age range',
      value: value,
      fieldName: fieldName,
      hostDefaults: club.hostDefaults,
      isExpanded: _isExpanded(fieldName),
      onTap: () => _toggleField(fieldName),
      onSaved: _collapseField,
      onCancel: _collapseField,
    );
  }

  Widget _cancellationDefaultEntry(Club club) {
    const fieldName = 'cancellationPolicyId';
    final selected = club.hostDefaults.eventPolicy.cancellationPolicyId;
    final selectedPolicy = club.hostDefaults.eventPolicy.cancellationPolicy;
    if (!widget.isOwner) {
      return CatchSettingsRow(
        label: 'Cancellation policy',
        value: selectedPolicy.title,
        icon: CatchIcons.eventBusyOutlined,
      );
    }

    return _HostInlineOptionEditor<EventCancellationPolicyId>(
      key: const ValueKey('host-inline-cancellationPolicyId'),
      clubId: club.id,
      icon: CatchIcons.eventBusyOutlined,
      label: 'Cancellation policy',
      value: selectedPolicy.title,
      currentValue: selected,
      fieldName: fieldName,
      isExpanded: _isExpanded(fieldName),
      helperText: selectedPolicy.attendeeSummary,
      options: [
        for (final policyId in EventCancellationPolicyId.values)
          _HostInlineOption(
            value: policyId,
            label: _cancellationPolicyFor(policyId).title,
          ),
      ],
      patchForValue: (policyId) {
        final policy = club.hostDefaults.eventPolicy;
        return UpdateClubPatch(
          hostDefaults: club.hostDefaults.copyWith(
            eventPolicy: policy.copyWith(cancellationPolicyId: policyId),
          ),
        );
      },
      onTap: () => _toggleField(fieldName),
      onSaved: _collapseField,
      onCancel: _collapseField,
    );
  }
}

class _HostClubInsightsPane extends ConsumerStatefulWidget {
  const _HostClubInsightsPane({required this.club});

  final Club club;

  @override
  ConsumerState<_HostClubInsightsPane> createState() =>
      _HostClubInsightsPaneState();
}

class _HostClubInsightsPaneState extends ConsumerState<_HostClubInsightsPane> {
  var _rangePreset = HostAnalyticsRangePreset.thirtyDays;
  var _granularity = HostAnalyticsGranularity.day;
  String? _selectedEventId;
  DateTime _customStartDate = DateUtils.dateOnly(_analyticsDateDaysAgo(29));
  DateTime _customEndDate = DateUtils.dateOnly(DateTime.now());

  @override
  Widget build(BuildContext context) {
    final query = HostAnalyticsQuery(
      clubId: widget.club.id,
      eventId: _selectedEventId,
      rangePreset: _rangePreset,
      startDate: _customStartDate,
      endDate: _customEndDate,
      granularity: _granularity,
    );
    final analyticsAsync = ref.watch(hostAnalyticsProvider(query));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _HostMetaRow(club: widget.club, roleLabel: 'Insights', owner: true),
        gapH24,
        _HostAnalyticsControls(
          rangePreset: _rangePreset,
          granularity: _granularity,
          customStartDate: _customStartDate,
          customEndDate: _customEndDate,
          selectedEventId: _selectedEventId,
          onRangeChanged: (preset) => setState(() => _rangePreset = preset),
          onGranularityChanged: (granularity) =>
              setState(() => _granularity = granularity),
          onPickStartDate: _pickCustomStartDate,
          onPickEndDate: _pickCustomEndDate,
          onClearEvent: _clearEventScope,
        ),
        gapH20,
        analyticsAsync.when(
          loading: () => const Padding(
            padding: CatchInsets.tileVertical,
            child: CatchLoadingIndicator(),
          ),
          error: (error, _) => CatchErrorState.fromError(
            error,
            onRetry: () => ref.invalidate(hostAnalyticsProvider(query)),
          ),
          data: (report) => _HostAnalyticsReportView(
            report: report,
            selectedEventId: _selectedEventId,
            onEventSelected: _selectEventScope,
            onClearEvent: _clearEventScope,
          ),
        ),
      ],
    );
  }

  Future<void> _pickCustomStartDate() async {
    final picked = await showCatchDatePicker(
      context: context,
      initialDate: _customStartDate,
      firstDate: _analyticsDateDaysAgo(366),
      lastDate: _customEndDate,
      title: 'Start date',
    );
    if (picked == null || !mounted) return;
    setState(() {
      _customStartDate = DateUtils.dateOnly(picked);
      _rangePreset = HostAnalyticsRangePreset.custom;
    });
  }

  Future<void> _pickCustomEndDate() async {
    final picked = await showCatchDatePicker(
      context: context,
      initialDate: _customEndDate,
      firstDate: _customStartDate,
      lastDate: DateUtils.dateOnly(DateTime.now()),
      title: 'End date',
    );
    if (picked == null || !mounted) return;
    setState(() {
      _customEndDate = DateUtils.dateOnly(picked);
      _rangePreset = HostAnalyticsRangePreset.custom;
    });
  }

  void _selectEventScope(String eventId) {
    setState(() => _selectedEventId = eventId);
  }

  void _clearEventScope() {
    setState(() => _selectedEventId = null);
  }
}

class _HostAnalyticsControls extends StatelessWidget {
  const _HostAnalyticsControls({
    required this.rangePreset,
    required this.granularity,
    required this.customStartDate,
    required this.customEndDate,
    required this.selectedEventId,
    required this.onRangeChanged,
    required this.onGranularityChanged,
    required this.onPickStartDate,
    required this.onPickEndDate,
    required this.onClearEvent,
  });

  final HostAnalyticsRangePreset rangePreset;
  final HostAnalyticsGranularity granularity;
  final DateTime customStartDate;
  final DateTime customEndDate;
  final String? selectedEventId;
  final ValueChanged<HostAnalyticsRangePreset> onRangeChanged;
  final ValueChanged<HostAnalyticsGranularity> onGranularityChanged;
  final VoidCallback onPickStartDate;
  final VoidCallback onPickEndDate;
  final VoidCallback onClearEvent;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CatchOptionGroup<HostAnalyticsRangePreset>(
          selected: rangePreset,
          onChanged: onRangeChanged,
          variant: CatchOptionGroupVariant.mono,
          options: const [
            CatchOption(value: HostAnalyticsRangePreset.sevenDays, label: '7D'),
            CatchOption(
              value: HostAnalyticsRangePreset.thirtyDays,
              label: '30D',
            ),
            CatchOption(
              value: HostAnalyticsRangePreset.ninetyDays,
              label: '90D',
            ),
            CatchOption(value: HostAnalyticsRangePreset.month, label: 'MONTH'),
            CatchOption(
              value: HostAnalyticsRangePreset.custom,
              label: 'CUSTOM',
            ),
          ],
        ),
        gapH12,
        CatchOptionGroup<HostAnalyticsGranularity>(
          selected: granularity,
          onChanged: onGranularityChanged,
          variant: CatchOptionGroupVariant.mono,
          options: const [
            CatchOption(value: HostAnalyticsGranularity.day, label: 'DAY'),
            CatchOption(value: HostAnalyticsGranularity.week, label: 'WEEK'),
            CatchOption(value: HostAnalyticsGranularity.month, label: 'MONTH'),
          ],
        ),
        if (rangePreset == HostAnalyticsRangePreset.custom) ...[
          gapH12,
          Row(
            children: [
              Expanded(
                child: _HostAnalyticsDateButton(
                  label: 'Start',
                  value: _formatAnalyticsDate(customStartDate),
                  onTap: onPickStartDate,
                ),
              ),
              const SizedBox(width: CatchSpacing.s3),
              Expanded(
                child: _HostAnalyticsDateButton(
                  label: 'End',
                  value: _formatAnalyticsDate(customEndDate),
                  onTap: onPickEndDate,
                ),
              ),
            ],
          ),
        ],
        if (selectedEventId != null) ...[
          gapH12,
          CatchSurface(
            padding: CatchInsets.contentDense,
            borderColor: t.line,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Event scoped',
                    style: CatchTextStyles.labelM(context, color: t.ink2),
                  ),
                ),
                CatchButton(
                  label: 'All events',
                  onPressed: onClearEvent,
                  variant: CatchButtonVariant.ghost,
                  size: CatchButtonSize.sm,
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _HostAnalyticsDateButton extends StatelessWidget {
  const _HostAnalyticsDateButton({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return CatchSurface(
      padding: CatchInsets.contentDense,
      borderColor: t.line,
      onTap: onTap,
      child: Row(
        children: [
          Icon(CatchIcons.calendarTodayOutlined, size: CatchIcon.sm),
          const SizedBox(width: CatchSpacing.s2),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: CatchTextStyles.labelS(context, color: t.ink3),
                ),
                gapH2,
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: CatchTextStyles.monoLabel(context, color: t.ink),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HostAnalyticsReportView extends StatelessWidget {
  const _HostAnalyticsReportView({
    required this.report,
    required this.selectedEventId,
    required this.onEventSelected,
    required this.onClearEvent,
  });

  final HostAnalyticsReport report;
  final String? selectedEventId;
  final ValueChanged<String> onEventSelected;
  final VoidCallback onClearEvent;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _HostAnalyticsMetricGrid(metrics: report.summaryCards),
        gapH24,
        _HostAnalyticsTrendPanel(points: report.trend),
        gapH24,
        _HostAnalyticsEventList(
          events: report.topEvents,
          selectedEventId: selectedEventId,
          onEventSelected: onEventSelected,
          onClearEvent: onClearEvent,
        ),
        gapH24,
        _HostAnalyticsReviewDiscoveryPanel(report: report),
        gapH24,
        _HostAnalyticsDataQualityPanel(rows: report.dataQuality),
      ],
    );
  }
}

class _HostAnalyticsMetricGrid extends StatelessWidget {
  const _HostAnalyticsMetricGrid({required this.metrics});

  final List<HostAnalyticsMetricCard> metrics;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth = (constraints.maxWidth - CatchSpacing.s3) / 2;
        return Wrap(
          spacing: CatchSpacing.s3,
          runSpacing: CatchSpacing.s3,
          children: [
            for (final metric in metrics)
              SizedBox(
                width: itemWidth,
                child: _HostAnalyticsMetricTile(metric: metric),
              ),
          ],
        );
      },
    );
  }
}

class _HostAnalyticsMetricTile extends StatelessWidget {
  const _HostAnalyticsMetricTile({required this.metric});

  final HostAnalyticsMetricCard metric;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final muted = metric.status == HostAnalyticsMetricStatus.missing;
    return CatchSurface(
      padding: CatchInsets.content,
      borderColor: muted
          ? t.warning.withValues(alpha: CatchOpacity.mutedBorderUrgent)
          : t.line,
      backgroundColor: muted
          ? t.warning.withValues(alpha: CatchOpacity.warningFill)
          : t.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(_metricIcon(metric.id), size: CatchIcon.sm, color: t.ink2),
              const Spacer(),
              if (metric.status != HostAnalyticsMetricStatus.ready)
                CatchBadge(
                  label: metric.status == HostAnalyticsMetricStatus.partial
                      ? 'Partial'
                      : 'Missing',
                  tone: metric.status == HostAnalyticsMetricStatus.partial
                      ? CatchBadgeTone.warning
                      : CatchBadgeTone.neutral,
                ),
            ],
          ),
          gapH12,
          Text(
            _formatMetricValue(metric),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: CatchTextStyles.numericLarge(
              context,
              color: muted ? t.ink3 : t.ink,
            ),
          ),
          gapH4,
          Text(
            metric.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: CatchTextStyles.labelM(context, color: t.ink2),
          ),
          if (metric.caption case final caption?
              when caption.trim().isNotEmpty) ...[
            gapH8,
            Text(
              caption,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: CatchTextStyles.bodyS(context, color: t.ink3),
            ),
          ],
        ],
      ),
    );
  }
}

class _HostAnalyticsTrendPanel extends StatelessWidget {
  const _HostAnalyticsTrendPanel({required this.points});

  final List<HostAnalyticsTrendPoint> points;

  @override
  Widget build(BuildContext context) {
    final totalBookings = points.fold<num>(
      0,
      (sum, point) => sum + (point.metrics['bookings'] ?? 0),
    );
    final totalDemand = points.fold<num>(
      0,
      (sum, point) => sum + (point.metrics['demand'] ?? 0),
    );
    final maxBookings = points.fold<num>(0, (max, point) {
      final value = point.metrics['bookings'] ?? 0;
      return value > max ? value : max;
    });

    return _HostAnalyticsSection(
      label: 'Funnel',
      child: CatchSurface(
        padding: CatchInsets.content,
        borderColor: CatchTokens.of(context).line,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: _HostAnalyticsInlineStat(
                    label: 'Demand',
                    value: _formatCount(totalDemand),
                  ),
                ),
                Expanded(
                  child: _HostAnalyticsInlineStat(
                    label: 'Bookings',
                    value: _formatCount(totalBookings),
                  ),
                ),
              ],
            ),
            gapH16,
            SizedBox(
              height: CatchSpacing.s16,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  for (final point in points.take(18)) ...[
                    if (point != points.first)
                      const SizedBox(width: CatchSpacing.micro6),
                    Expanded(
                      child: _HostAnalyticsBar(
                        value: point.metrics['bookings'] ?? 0,
                        maxValue: maxBookings,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HostAnalyticsBar extends StatelessWidget {
  const _HostAnalyticsBar({required this.value, required this.maxValue});

  final num value;
  final num maxValue;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final ratio = maxValue <= 0 ? 0.02 : (value / maxValue).clamp(0.06, 1);
    return Align(
      alignment: Alignment.bottomCenter,
      child: FractionallySizedBox(
        heightFactor: ratio.toDouble(),
        child: CatchSurface(
          radius: CatchRadius.xs,
          borderWidth: 0,
          backgroundColor: value <= 0 ? t.line2 : t.ink,
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}

class _HostAnalyticsEventList extends StatelessWidget {
  const _HostAnalyticsEventList({
    required this.events,
    required this.selectedEventId,
    required this.onEventSelected,
    required this.onClearEvent,
  });

  final List<HostAnalyticsEventRow> events;
  final String? selectedEventId;
  final ValueChanged<String> onEventSelected;
  final VoidCallback onClearEvent;

  @override
  Widget build(BuildContext context) {
    return _HostAnalyticsSection(
      label: selectedEventId == null ? 'Top events' : 'Selected event',
      child: Column(
        children: [
          if (selectedEventId != null) ...[
            Align(
              alignment: Alignment.centerLeft,
              child: CatchButton(
                label: 'All events',
                onPressed: onClearEvent,
                variant: CatchButtonVariant.ghost,
                size: CatchButtonSize.sm,
              ),
            ),
            gapH8,
          ],
          if (events.isEmpty)
            CatchSurface(
              padding: CatchInsets.content,
              borderColor: CatchTokens.of(context).line,
              child: Text(
                'No events in this range.',
                style: CatchTextStyles.supporting(
                  context,
                  color: CatchTokens.of(context).ink2,
                ),
              ),
            )
          else
            for (final event in events.take(5))
              _HostAnalyticsEventTile(
                event: event,
                divider: event != events.first,
                selected: event.eventId == selectedEventId,
                onTap: () => onEventSelected(event.eventId),
              ),
        ],
      ),
    );
  }
}

class _HostAnalyticsEventTile extends StatelessWidget {
  const _HostAnalyticsEventTile({
    required this.event,
    required this.divider,
    required this.selected,
    required this.onTap,
  });

  final HostAnalyticsEventRow event;
  final bool divider;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Column(
      children: [
        if (divider) Divider(height: 1, color: t.line),
        CatchSurface(
          tone: CatchSurfaceTone.transparent,
          borderWidth: 0,
          padding: CatchInsets.contentVertical,
          onTap: onTap,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(CatchIcons.eventOutlined, color: t.ink2),
              const SizedBox(width: CatchSpacing.s3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            event.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: CatchTextStyles.labelL(
                              context,
                              color: t.ink,
                            ),
                          ),
                        ),
                        if (selected) ...[
                          const SizedBox(width: CatchSpacing.s2),
                          const CatchBadge(label: 'Selected'),
                        ],
                      ],
                    ),
                    gapH4,
                    Text(
                      EventFormatters.shortDate(event.startTime),
                      style: CatchTextStyles.bodyS(context, color: t.ink3),
                    ),
                    gapH8,
                    Wrap(
                      spacing: CatchSpacing.s2,
                      runSpacing: CatchSpacing.s2,
                      children: [
                        CatchBadge(
                          label: _analyticsEventStatusLabel(event.status),
                          tone: _analyticsEventStatusTone(event.status),
                        ),
                        CatchBadge(label: '${event.demandCount} demand'),
                        CatchBadge(label: '${event.bookedCount} booked'),
                        if (event.waitlistedCount > 0)
                          CatchBadge(
                            label: '${event.waitlistedCount} waitlisted',
                            tone: CatchBadgeTone.warning,
                          ),
                        CatchBadge(
                          label: '${event.checkedInCount} attended',
                          tone: CatchBadgeTone.success,
                        ),
                        if (event.mutualMatchCount > 0)
                          CatchBadge(
                            label: '${event.mutualMatchCount} matches',
                            tone: CatchBadgeTone.brand,
                          ),
                        if (event.chatStartedCount > 0)
                          CatchBadge(label: '${event.chatStartedCount} chats'),
                        if (event.repeatAttendeeCount > 0)
                          CatchBadge(
                            label: '${event.repeatAttendeeCount} repeat',
                          ),
                        if (event.checkoutStartedCount > 0)
                          CatchBadge(
                            label: '${event.checkoutStartedCount} checkouts',
                          ),
                        if (event.checkoutDropoffCount > 0)
                          CatchBadge(
                            label: '${event.checkoutDropoffCount} drop-off',
                            tone: CatchBadgeTone.warning,
                          ),
                        if (event.paymentFailedCount > 0)
                          CatchBadge(
                            label: '${event.paymentFailedCount} failed',
                            tone: CatchBadgeTone.danger,
                          ),
                        if (event.paymentRefundedCount > 0)
                          CatchBadge(
                            label: '${event.paymentRefundedCount} refunded',
                            tone: CatchBadgeTone.warning,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: CatchSpacing.s3),
              Text(
                EventFormatters.priceInPaise(
                  event.grossRevenueMinor,
                  currencyCode: event.currency,
                ),
                style: CatchTextStyles.monoLabel(context, color: t.ink2),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

String _formatAnalyticsDate(DateTime date) {
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '$day/$month/${date.year}';
}

DateTime _analyticsDateDaysAgo(int days) {
  final today = DateUtils.dateOnly(DateTime.now());
  return DateTime(today.year, today.month, today.day - days);
}

class _HostAnalyticsReviewDiscoveryPanel extends StatelessWidget {
  const _HostAnalyticsReviewDiscoveryPanel({required this.report});

  final HostAnalyticsReport report;

  @override
  Widget build(BuildContext context) {
    return _HostAnalyticsSection(
      label: 'Reviews and saves',
      child: CatchSurface(
        padding: CatchInsets.content,
        borderColor: CatchTokens.of(context).line,
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _HostAnalyticsInlineStat(
                    label: 'New reviews',
                    value: '${report.reviewSummary.newReviews}',
                  ),
                ),
                Expanded(
                  child: _HostAnalyticsInlineStat(
                    label: 'Average rating',
                    value: report.reviewSummary.averageRating <= 0
                        ? '—'
                        : report.reviewSummary.averageRating.toStringAsFixed(1),
                  ),
                ),
              ],
            ),
            gapH16,
            Row(
              children: [
                Expanded(
                  child: _HostAnalyticsInlineStat(
                    label: 'Event saves',
                    value: '${report.discoverySummary.eventSaves}',
                  ),
                ),
                Expanded(
                  child: _HostAnalyticsInlineStat(
                    label: 'Responses',
                    value: '${report.reviewSummary.ownerResponseCount}',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _HostAnalyticsDataQualityPanel extends StatelessWidget {
  const _HostAnalyticsDataQualityPanel({required this.rows});

  final List<HostAnalyticsDataQuality> rows;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return _HostAnalyticsSection(
      label: 'Data quality',
      child: Column(
        children: [
          for (final indexedRow in rows.indexed) ...[
            if (indexedRow.$1 > 0) gapH8,
            CatchSurface(
              padding: CatchInsets.contentDense,
              borderColor: t.line,
              backgroundColor:
                  indexedRow.$2.state == HostAnalyticsDataQualityState.ok
                  ? t.surface
                  : t.warning.withValues(alpha: CatchOpacity.warningFill),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    indexedRow.$2.state == HostAnalyticsDataQualityState.ok
                        ? CatchIcons.checkCircleOutlineRounded
                        : CatchIcons.warningAmberRounded,
                    size: CatchIcon.md,
                    color:
                        indexedRow.$2.state == HostAnalyticsDataQualityState.ok
                        ? t.success
                        : t.warning,
                  ),
                  const SizedBox(width: CatchSpacing.s3),
                  Expanded(
                    child: Text(
                      indexedRow.$2.detail,
                      style: CatchTextStyles.bodyS(context, color: t.ink2),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _HostAnalyticsInlineStat extends StatelessWidget {
  const _HostAnalyticsInlineStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: CatchTextStyles.numericMeta(context, color: t.ink)),
        gapH4,
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: CatchTextStyles.labelS(context, color: t.ink3),
        ),
      ],
    );
  }
}

class _HostAnalyticsSection extends StatelessWidget {
  const _HostAnalyticsSection({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _HostSectionLabel(label: label),
        gapH8,
        child,
      ],
    );
  }
}

IconData _metricIcon(String metricId) {
  return switch (metricId) {
    'listingViews' || 'eventViews' => CatchIcons.visibilityOutlined,
    'bookings' => CatchIcons.confirmationNumberOutlined,
    'attendanceRate' => CatchIcons.factCheckOutlined,
    'revenue' => CatchIcons.accountBalanceWalletOutlined,
    'checkoutDropoff' ||
    'checkoutConversionRate' => CatchIcons.paymentsOutlined,
    'newReviews' => CatchIcons.rateReviewOutlined,
    'connections' => CatchIcons.favoriteOutlineRounded,
    'chats' => CatchIcons.chatBubbleOutlineRounded,
    _ => CatchIcons.insightsOutlined,
  };
}

String _formatMetricValue(HostAnalyticsMetricCard metric) {
  return switch (metric.unit) {
    HostAnalyticsMetricUnit.percent => '${metric.value.round()}%',
    HostAnalyticsMetricUnit.moneyMinor => EventFormatters.priceInPaise(
      metric.value.round(),
    ),
    HostAnalyticsMetricUnit.rating =>
      metric.value <= 0 ? '—' : metric.value.toStringAsFixed(1),
    HostAnalyticsMetricUnit.count => _formatCount(metric.value),
  };
}

String _analyticsEventStatusLabel(String status) {
  final normalized = status.trim();
  if (normalized.isEmpty || normalized == 'unknown') return 'Unknown';
  return normalized
      .split(RegExp(r'[_\-\s]+'))
      .where((part) => part.isNotEmpty)
      .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
      .join(' ');
}

CatchBadgeTone _analyticsEventStatusTone(String status) {
  return switch (status.trim().toLowerCase()) {
    'live' || 'active' || 'open' || 'published' => CatchBadgeTone.live,
    'completed' || 'past' => CatchBadgeTone.success,
    'draft' || 'pending' || 'scheduled' => CatchBadgeTone.warning,
    'cancelled' || 'canceled' => CatchBadgeTone.danger,
    _ => CatchBadgeTone.neutral,
  };
}

String _formatCount(num value) {
  final rounded = value.round();
  if (rounded >= 1000000) {
    return '${(rounded / 1000000).toStringAsFixed(1)}M';
  }
  if (rounded >= 1000) return '${(rounded / 1000).toStringAsFixed(1)}K';
  return '$rounded';
}

mixin _HostInlineClubSaveState<T extends ConsumerStatefulWidget>
    on ConsumerState<T> {
  bool _isSaving = false;
  Object? _saveError;

  bool get isSaving => _isSaving;

  Future<bool> saveClubPatch({
    required String clubId,
    required UpdateClubPatch patch,
  }) async {
    if (_isSaving) return false;
    if (patch.isEmpty) return true;
    setState(() {
      _isSaving = true;
      _saveError = null;
    });

    try {
      await ref
          .read(clubsRepositoryProvider)
          .updateClub(clubId: clubId, patch: patch);
      if (!mounted) return false;
      setState(() => _isSaving = false);
      return true;
    } catch (error) {
      if (!mounted) return false;
      setState(() {
        _isSaving = false;
        _saveError = error;
      });
      return false;
    }
  }

  Widget? buildSaveError() {
    final error = _saveError;
    if (error == null) return null;
    return CatchErrorBanner(
      message: appErrorMessage(error, context: AppErrorContext.club),
    );
  }
}

class _HostInlineTextEntryEditor extends ConsumerStatefulWidget {
  const _HostInlineTextEntryEditor({
    super.key,
    required this.clubId,
    required this.icon,
    required this.label,
    required this.value,
    required this.currentValue,
    required this.currentFieldValue,
    required this.fieldName,
    required this.isExpanded,
    required this.onTap,
    required this.onSaved,
    required this.onCancel,
    required this.patchForValue,
    this.placeholder,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.showCounter = false,
    this.normalizeInput,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.sentences,
    this.validator,
    this.toFieldValue,
  });

  final String clubId;
  final IconData icon;
  final String label;
  final String value;
  final String currentValue;
  final Object? currentFieldValue;
  final String fieldName;
  final bool isExpanded;
  final VoidCallback onTap;
  final VoidCallback onSaved;
  final VoidCallback onCancel;
  final UpdateClubPatch Function(Object? value) patchForValue;
  final String? placeholder;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final bool showCounter;
  final String Function(String value)? normalizeInput;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final FormFieldValidator<String>? validator;
  final Object? Function(String value)? toFieldValue;

  @override
  ConsumerState<_HostInlineTextEntryEditor> createState() =>
      _HostInlineTextEntryEditorState();
}

class _HostInlineTextEntryEditorState
    extends ConsumerState<_HostInlineTextEntryEditor>
    with _HostInlineClubSaveState<_HostInlineTextEntryEditor> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  String? _validationError;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.currentValue);
    _focusNode = FocusNode();
    _controller.addListener(_clearValidationError);
    if (widget.isExpanded) {
      _requestFocusAfterExpansionFrame();
    }
  }

  @override
  void didUpdateWidget(covariant _HostInlineTextEntryEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.fieldName != widget.fieldName ||
        oldWidget.currentValue != widget.currentValue) {
      _controller.text = widget.currentValue;
    }
    if (widget.isExpanded && !oldWidget.isExpanded) {
      _requestFocusAfterExpansionFrame();
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_clearValidationError);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _clearValidationError() {
    if (_validationError == null) return;
    setState(() => _validationError = null);
  }

  void _requestFocusAfterExpansionFrame() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !widget.isExpanded || isSaving || _focusNode.hasFocus) {
        return;
      }
      _focusNode.requestFocus();
    });
  }

  void _cancel() {
    _controller.text = widget.currentValue;
    widget.onCancel();
  }

  Future<void> _submit() async {
    if (isSaving) return;
    final normalizedText =
        widget.normalizeInput?.call(_controller.text) ?? _controller.text;
    if (normalizedText != _controller.text) {
      _controller.text = normalizedText;
    }

    final validationError = widget.validator?.call(normalizedText);
    if (validationError != null) {
      setState(() => _validationError = validationError);
      return;
    }

    final rawValue = normalizedText.trim();
    final fieldValue = widget.toFieldValue != null
        ? widget.toFieldValue!(rawValue)
        : rawValue;
    if (_isUnchanged(fieldValue)) {
      _cancel();
      return;
    }

    final saved = await saveClubPatch(
      clubId: widget.clubId,
      patch: widget.patchForValue(fieldValue),
    );
    if (saved && mounted) widget.onSaved();
  }

  bool _isUnchanged(Object? fieldValue) {
    final currentFieldValue = widget.currentFieldValue;
    return fieldValue == currentFieldValue ||
        (fieldValue == null &&
            (currentFieldValue == null || widget.currentValue.trim().isEmpty));
  }

  @override
  Widget build(BuildContext context) {
    return ProfileInlineFieldScaffold(
      icon: widget.icon,
      label: widget.label,
      value: widget.value,
      isExpanded: widget.isExpanded,
      onTap: widget.onTap,
      isSaving: isSaving,
      animateValueContent: false,
      valueContent: ProfileInlineTextValue(
        label: widget.label,
        displayValue: widget.value,
        placeholder: widget.placeholder,
        controller: _controller,
        focusNode: _focusNode,
        isEditing: widget.isExpanded,
        enabled: !isSaving,
        keyboardType: widget.keyboardType,
        textCapitalization: widget.textCapitalization,
        maxLines: widget.maxLines,
        minLines: widget.minLines,
        maxLength: widget.maxLength,
        showCounter: widget.showCounter,
        collapseStackedBlankLines: widget.maxLines != 1,
        onSubmitted: (_) => _submit(),
      ),
      saveError: _validationError == null
          ? buildSaveError()
          : CatchErrorBanner(message: _validationError!),
      actionLeading: widget.showCounter && widget.maxLength != null
          ? AnimatedBuilder(
              animation: _controller,
              builder: (context, _) => Text(
                '${_controller.text.length} / ${widget.maxLength}',
                style: CatchTextStyles.labelM(context),
              ),
            )
          : null,
      onCancel: _cancel,
      onSubmit: _submit,
    );
  }
}

class _HostInlineOption<T> {
  const _HostInlineOption({
    required this.value,
    required this.label,
    this.accentColor,
  });

  final T value;
  final String label;
  final Color? accentColor;
}

class _HostInlineOptionEditor<T> extends ConsumerStatefulWidget {
  const _HostInlineOptionEditor({
    super.key,
    required this.clubId,
    required this.icon,
    required this.label,
    required this.value,
    required this.currentValue,
    required this.fieldName,
    required this.isExpanded,
    required this.options,
    required this.patchForValue,
    required this.onTap,
    required this.onSaved,
    required this.onCancel,
    this.helperText,
  });

  final String clubId;
  final IconData icon;
  final String label;
  final String value;
  final T currentValue;
  final String fieldName;
  final bool isExpanded;
  final List<_HostInlineOption<T>> options;
  final UpdateClubPatch Function(T value) patchForValue;
  final VoidCallback onTap;
  final VoidCallback onSaved;
  final VoidCallback onCancel;
  final String? helperText;

  @override
  ConsumerState<_HostInlineOptionEditor<T>> createState() =>
      _HostInlineOptionEditorState<T>();
}

class _HostInlineOptionEditorState<T>
    extends ConsumerState<_HostInlineOptionEditor<T>>
    with _HostInlineClubSaveState<_HostInlineOptionEditor<T>> {
  late T _selected = widget.currentValue;

  @override
  void didUpdateWidget(covariant _HostInlineOptionEditor<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.fieldName != widget.fieldName ||
        oldWidget.currentValue != widget.currentValue) {
      _selected = widget.currentValue;
    }
  }

  void _cancel() {
    setState(() => _selected = widget.currentValue);
    widget.onCancel();
  }

  Future<void> _submit() async {
    if (isSaving) return;
    if (_selected == widget.currentValue) {
      _cancel();
      return;
    }

    final saved = await saveClubPatch(
      clubId: widget.clubId,
      patch: widget.patchForValue(_selected),
    );
    if (saved && mounted) widget.onSaved();
  }

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final displayValue = widget.isExpanded
        ? _labelFor(_selected)
        : widget.value;
    return ProfileInlineFieldScaffold(
      icon: widget.icon,
      label: widget.label,
      value: displayValue,
      isExpanded: widget.isExpanded,
      onTap: widget.onTap,
      isSaving: isSaving,
      animateValueContent: false,
      saveError: buildSaveError(),
      editorChildren: [
        if (widget.helperText != null) ...[
          Text(
            widget.helperText!,
            style: CatchTextStyles.supporting(context, color: t.ink2),
          ),
          gapH12,
        ],
        Wrap(
          spacing: CatchSpacing.s2,
          runSpacing: CatchSpacing.s2,
          children: [
            for (final option in widget.options)
              CatchSelectChip(
                label: option.label,
                active: _selected == option.value,
                accentColor: option.accentColor,
                enabled: !isSaving,
                onTap: () => setState(() => _selected = option.value),
              ),
          ],
        ),
      ],
      onCancel: _cancel,
      onSubmit: _submit,
    );
  }

  String _labelFor(T value) {
    for (final option in widget.options) {
      if (option.value == value) return option.label;
    }
    return widget.value;
  }
}

class _HostInlineAgeRangeEditor extends ConsumerStatefulWidget {
  const _HostInlineAgeRangeEditor({
    super.key,
    required this.clubId,
    required this.icon,
    required this.label,
    required this.value,
    required this.fieldName,
    required this.hostDefaults,
    required this.isExpanded,
    required this.onTap,
    required this.onSaved,
    required this.onCancel,
  });

  final String clubId;
  final IconData icon;
  final String label;
  final String value;
  final String fieldName;
  final ClubHostDefaults hostDefaults;
  final bool isExpanded;
  final VoidCallback onTap;
  final VoidCallback onSaved;
  final VoidCallback onCancel;

  @override
  ConsumerState<_HostInlineAgeRangeEditor> createState() =>
      _HostInlineAgeRangeEditorState();
}

class _HostInlineAgeRangeEditorState
    extends ConsumerState<_HostInlineAgeRangeEditor>
    with _HostInlineClubSaveState<_HostInlineAgeRangeEditor> {
  late final TextEditingController _minAgeController;
  late final TextEditingController _maxAgeController;
  String? _validationError;

  EventPolicyDefaults get _policy => widget.hostDefaults.eventPolicy;

  @override
  void initState() {
    super.initState();
    _minAgeController = TextEditingController(
      text: _optionalMinAgeText(_policy.minAge),
    );
    _maxAgeController = TextEditingController(
      text: _optionalMaxAgeText(_policy.maxAge),
    );
    _minAgeController.addListener(_clearValidationError);
    _maxAgeController.addListener(_clearValidationError);
  }

  @override
  void didUpdateWidget(covariant _HostInlineAgeRangeEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.fieldName != widget.fieldName ||
        oldWidget.hostDefaults.eventPolicy.minAge != _policy.minAge ||
        oldWidget.hostDefaults.eventPolicy.maxAge != _policy.maxAge) {
      _minAgeController.text = _optionalMinAgeText(_policy.minAge);
      _maxAgeController.text = _optionalMaxAgeText(_policy.maxAge);
    }
  }

  @override
  void dispose() {
    _minAgeController.removeListener(_clearValidationError);
    _maxAgeController.removeListener(_clearValidationError);
    _minAgeController.dispose();
    _maxAgeController.dispose();
    super.dispose();
  }

  void _clearValidationError() {
    if (_validationError == null) return;
    setState(() => _validationError = null);
  }

  void _cancel() {
    _minAgeController.text = _optionalMinAgeText(_policy.minAge);
    _maxAgeController.text = _optionalMaxAgeText(_policy.maxAge);
    widget.onCancel();
  }

  Future<void> _submit() async {
    if (isSaving) return;
    final parsed = _parseAgeRange(
      minText: _minAgeController.text,
      maxText: _maxAgeController.text,
    );
    if (parsed.error != null) {
      setState(() => _validationError = parsed.error);
      return;
    }

    final minAge = parsed.minAge!;
    final maxAge = parsed.maxAge!;
    if (minAge == _policy.minAge && maxAge == _policy.maxAge) {
      _cancel();
      return;
    }

    final saved = await saveClubPatch(
      clubId: widget.clubId,
      patch: UpdateClubPatch(
        hostDefaults: widget.hostDefaults.copyWith(
          eventPolicy: _policy.copyWith(minAge: minAge, maxAge: maxAge),
        ),
      ),
    );
    if (saved && mounted) widget.onSaved();
  }

  @override
  Widget build(BuildContext context) {
    final displayValue = widget.isExpanded ? _draftValue : widget.value;
    return ProfileInlineFieldScaffold(
      icon: widget.icon,
      label: widget.label,
      value: displayValue,
      isExpanded: widget.isExpanded,
      onTap: widget.onTap,
      isSaving: isSaving,
      animateValueContent: false,
      saveError: _validationError == null
          ? buildSaveError()
          : CatchErrorBanner(message: _validationError!),
      editorChildren: [
        Row(
          children: [
            Expanded(
              child: CatchTextField(
                label: 'Min age',
                isOptional: true,
                controller: _minAgeController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                enabled: !isSaving,
              ),
            ),
            gapW12,
            Expanded(
              child: CatchTextField(
                label: 'Max age',
                isOptional: true,
                controller: _maxAgeController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                enabled: !isSaving,
              ),
            ),
          ],
        ),
      ],
      onCancel: _cancel,
      onSubmit: _submit,
    );
  }

  String get _draftValue {
    final minAge = int.tryParse(_minAgeController.text.trim()) ?? 0;
    final maxAge = int.tryParse(_maxAgeController.text.trim()) ?? 99;
    return '$minAge–$maxAge';
  }
}

class _HostClubPreviewPane extends StatelessWidget {
  const _HostClubPreviewPane({required this.club});

  final Club club;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          club.description,
          style: CatchTextStyles.bodyLead(context, color: t.ink),
        ),
        gapH18,
        CatchSettingsRow(
          label: 'Open public preview',
          value: 'Preview',
          icon: CatchIcons.visibilityOutlined,
          onTap: () => context.pushNamed(
            Routes.hostClubDetailScreen.name,
            pathParameters: {'clubId': club.id},
            extra: club,
          ),
        ),
      ],
    );
  }
}

String _valueOrDash(String? value) {
  final trimmed = value?.trim();
  return trimmed == null || trimmed.isEmpty ? '—' : trimmed;
}

String _admissionDefaultLabel(EventAdmissionDefaultPreset preset) {
  return switch (preset) {
    EventAdmissionDefaultPreset.openCapacity => 'Open capacity',
    EventAdmissionDefaultPreset.inviteOnly => 'Invite only',
    EventAdmissionDefaultPreset.balancedSingles => 'Balanced singles',
    EventAdmissionDefaultPreset.fixedCohortCaps => 'Fixed cohort caps',
  };
}

String _admissionDefaultDescription(EventAdmissionDefaultPreset preset) {
  return switch (preset) {
    EventAdmissionDefaultPreset.openCapacity =>
      'Anyone eligible can book until the event reaches capacity.',
    EventAdmissionDefaultPreset.inviteOnly =>
      'New invite-only events ask for an event-specific code.',
    EventAdmissionDefaultPreset.balancedSingles =>
      'Straight men and women are kept within one spot of each other.',
    EventAdmissionDefaultPreset.fixedCohortCaps =>
      'Open booking with optional straight men and straight women caps.',
  };
}

ClubHostDefaults _hostDefaultsWithActivity(
  ClubHostDefaults defaults,
  ActivityKind activityKind,
) {
  final supported =
      defaults.effectiveSupportedActivityKinds.contains(activityKind)
      ? defaults.supportedActivityKinds
      : [...defaults.supportedActivityKinds, activityKind];
  return defaults.copyWith(
    primaryActivityKind: activityKind,
    supportedActivityKinds: supported,
  );
}

EventCancellationPolicy _cancellationPolicyFor(
  EventCancellationPolicyId policyId,
) {
  return switch (policyId) {
    EventCancellationPolicyId.flexible =>
      const EventCancellationPolicy.flexible(),
    EventCancellationPolicyId.standard =>
      const EventCancellationPolicy.standard(),
    EventCancellationPolicyId.strict => const EventCancellationPolicy.strict(),
  };
}

String _normalizeSingleLineInput(String value) {
  return value.trim().replaceAll(RegExp(r'\s+'), ' ');
}

String _normalizeMultilineInput(String value) {
  return value
      .trim()
      .replaceAll(RegExp(r'[ \t]+\n'), '\n')
      .replaceAll(RegExp(r'\n{3,}'), '\n\n');
}

String? Function(String?) _requiredHostFieldValidator(String label) {
  return (value) {
    if (value == null || value.trim().isEmpty) {
      return '$label is required.';
    }
    return null;
  };
}

String? _optionalEmailValidator(String? value) {
  final trimmed = value?.trim() ?? '';
  if (trimmed.isEmpty) return null;
  final valid = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(trimmed);
  return valid ? null : 'Enter a valid email.';
}

Object? _optionalStringFieldValue(String value) {
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}

String _optionalMinAgeText(int minAge) => minAge == 0 ? '' : '$minAge';

String _optionalMaxAgeText(int maxAge) => maxAge == 99 ? '' : '$maxAge';

_ParsedAgeRange _parseAgeRange({
  required String minText,
  required String maxText,
}) {
  final minRaw = minText.trim();
  final maxRaw = maxText.trim();
  final minAge = minRaw.isEmpty ? 0 : int.tryParse(minRaw);
  final maxAge = maxRaw.isEmpty ? 99 : int.tryParse(maxRaw);

  if (minAge == null || (minRaw.isNotEmpty && (minAge < 18 || minAge > 99))) {
    return const _ParsedAgeRange.error('Min age must be 18-99.');
  }
  if (maxAge == null || (maxRaw.isNotEmpty && (maxAge < 18 || maxAge > 99))) {
    return const _ParsedAgeRange.error('Max age must be 18-99.');
  }
  if (minAge > maxAge) {
    return const _ParsedAgeRange.error('Min age must be less than max age.');
  }
  return _ParsedAgeRange(minAge: minAge, maxAge: maxAge);
}

class _ParsedAgeRange {
  const _ParsedAgeRange({required this.minAge, required this.maxAge})
    : error = null;

  const _ParsedAgeRange.error(this.error) : minAge = null, maxAge = null;

  final int? minAge;
  final int? maxAge;
  final String? error;
}

class _HostEventRow extends StatelessWidget {
  const _HostEventRow({
    required this.club,
    required this.event,
    this.divider = false,
  });

  final Club club;
  final Event event;
  final bool divider;

  @override
  Widget build(BuildContext context) {
    void openManageEvent() {
      context.pushNamed(
        Routes.hostAppEventManageScreen.name,
        pathParameters: {'clubId': club.id, 'eventId': event.id},
        extra: event,
      );
    }

    return CatchSettingsRow(
      label: event.title,
      value: event.timeRangeLabel,
      icon: CatchIcons.calendarTodayOutlined,
      divider: divider,
      onTap: openManageEvent,
    );
  }
}

class _HostEmptyState extends StatelessWidget {
  const _HostEmptyState({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return CatchSurface(
      padding: CatchInsets.content,
      borderColor: t.line,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: CatchTextStyles.sectionTitle(context)),
          gapH8,
          Text(body, style: CatchTextStyles.supporting(context, color: t.ink2)),
          gapH18,
          CatchButton(
            label: 'Create club',
            icon: Icon(CatchIcons.addRounded, size: CatchIcon.md),
            onPressed: () =>
                context.pushNamed(Routes.hostCreateClubScreen.name),
          ),
        ],
      ),
    );
  }
}

class _HostAuthRequiredScreen extends StatelessWidget {
  const _HostAuthRequiredScreen();

  @override
  Widget build(BuildContext context) {
    return CatchErrorScaffold(
      title: 'Sign in required',
      message: 'Sign in to manage host operations.',
      retryLabel: 'Sign in',
      onRetry: () => context.go(Routes.authScreen.path),
    );
  }
}

class _HostLoadingScreen extends StatelessWidget {
  const _HostLoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: CatchLoadingIndicator());
  }
}

final _hostClubsForUserProvider = Provider.autoDispose
    .family<AsyncValue<List<Club>>, String>((ref, uid) {
      final hostedAsync = ref.watch(watchClubsHostedByProvider(uid));
      final ownedAsync = ref.watch(watchClubsOwnedByProvider(uid));

      final hosted = hostedAsync.asData?.value;
      final owned = ownedAsync.asData?.value;
      if (hostedAsync.hasError) {
        return AsyncError(
          hostedAsync.error!,
          hostedAsync.stackTrace ?? StackTrace.current,
        );
      }
      if (ownedAsync.hasError) {
        return AsyncError(
          ownedAsync.error!,
          ownedAsync.stackTrace ?? StackTrace.current,
        );
      }
      if (hosted == null || owned == null) return const AsyncLoading();

      final clubsById = <String, Club>{};
      for (final club in hosted) {
        clubsById[club.id] = club;
      }
      for (final club in owned) {
        clubsById[club.id] = club;
      }
      final clubs = clubsById.values.toList()
        ..sort((a, b) {
          final aOwned = a.isOwnedBy(uid);
          final bOwned = b.isOwnedBy(uid);
          if (aOwned != bOwned) return aOwned ? -1 : 1;
          return a.name.compareTo(b.name);
        });
      return AsyncData(List.unmodifiable(clubs));
    });
