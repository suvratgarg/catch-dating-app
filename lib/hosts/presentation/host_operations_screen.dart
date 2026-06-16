import 'dart:async';

import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/auth/presentation/auth_session_controller.dart';
import 'package:catch_dating_app/clubs/data/clubs_repository.dart';
import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_activity_chip.dart';
import 'package:catch_dating_app/core/widgets/catch_badge.dart';
import 'package:catch_dating_app/core/widgets/catch_bottom_sheet.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_error_snackbar.dart';
import 'package:catch_dating_app/core/widgets/catch_error_state.dart';
import 'package:catch_dating_app/core/widgets/catch_loading_indicator.dart';
import 'package:catch_dating_app/core/widgets/catch_option_group.dart';
import 'package:catch_dating_app/core/widgets/catch_settings_row.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/core/widgets/catch_text_field.dart';
import 'package:catch_dating_app/core/widgets/catch_top_bar.dart';
import 'package:catch_dating_app/event_policies/domain/event_policy_defaults.dart';
import 'package:catch_dating_app/events/data/event_repository.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/presentation/event_formatters.dart';
import 'package:catch_dating_app/hosts/data/host_profile_repository.dart';
import 'package:catch_dating_app/hosts/domain/host_profile.dart';
import 'package:catch_dating_app/hosts/presentation/payments/host_payment_account_card.dart';
import 'package:catch_dating_app/hosts/presentation/widgets/host_team_management_section.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:flutter/material.dart';
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

enum _HostClubTab { edit, preview }

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
    final profile = hostProfileAsync.asData?.value;
    final isEditMode = _selectedTab == _HostAccountTab.edit;

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
          if (hostProfileAsync.isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: CatchSpacing.s4),
              child: CatchLoadingIndicator(),
            )
          else if (hostProfileAsync.hasError)
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
                        .ensureHostProfile(
                          uid: uid,
                          displayName: 'Catch Host',
                        );
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
          else if (_selectedTab == _HostClubTab.edit)
            _HostClubProfileCard(
              club: selectedClub,
              currentUid: widget.currentUid,
              isOwner: selectedClub.isOwnedBy(widget.currentUid),
            )
          else
            _HostClubPreviewPane(club: selectedClub),
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
        const SizedBox(height: CatchSpacing.s5 + CatchSpacing.micro2),
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

class _HostClubProfileCard extends StatelessWidget {
  const _HostClubProfileCard({
    required this.club,
    required this.currentUid,
    required this.isOwner,
  });

  final Club club;
  final String currentUid;
  final bool isOwner;

  @override
  Widget build(BuildContext context) {
    final policy = club.hostDefaults.eventPolicy;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _HostMetaRow(
          club: club,
          roleLabel: isOwner ? 'Owner' : 'Host team',
          owner: isOwner,
        ),
        const SizedBox(height: CatchSpacing.s5 + CatchSpacing.micro2),
        _HostAccountSection(
          label: 'Identity',
          first: true,
          children: [
            CatchSettingsRow(
              label: 'Club name',
              value: club.name,
              icon: CatchIcons.groups3Outlined,
              onTap: isOwner ? () => _openClubEditor(context) : null,
            ),
            CatchSettingsRow(
              label: 'City',
              value: _valueOrDash(club.location),
              icon: CatchIcons.locationCityOutlined,
              divider: true,
              onTap: isOwner ? () => _openClubEditor(context) : null,
            ),
            CatchSettingsRow(
              label: 'Area / neighbourhood',
              value: _valueOrDash(club.area),
              icon: CatchIcons.locationOnOutlined,
              divider: true,
              onTap: isOwner ? () => _openClubEditor(context) : null,
            ),
            CatchSettingsRow(
              label: 'Description',
              value: _valueOrDash(club.description),
              icon: CatchIcons.descriptionOutlined,
              divider: true,
              valueMaxLines: 2,
              onTap: isOwner ? () => _openClubEditor(context) : null,
            ),
          ],
        ),
        _HostAccountSection(
          label: 'Contact',
          children: [
            CatchSettingsRow(
              label: 'Instagram',
              value: _valueOrDash(club.instagramHandle),
              icon: CatchIcons.alternateEmailRounded,
              onTap: isOwner ? () => _openClubEditor(context) : null,
            ),
            CatchSettingsRow(
              label: 'Phone',
              value: _valueOrDash(club.phoneNumber),
              icon: CatchIcons.phoneOutlined,
              divider: true,
              onTap: isOwner ? () => _openClubEditor(context) : null,
            ),
            CatchSettingsRow(
              label: 'Email',
              value: _valueOrDash(club.email),
              icon: CatchIcons.emailOutlined,
              divider: true,
              onTap: isOwner ? () => _openClubEditor(context) : null,
            ),
          ],
        ),
        _HostAccountSection(
          label: 'Event defaults',
          children: [
            CatchSettingsRow(
              label: 'Default activity',
              value: club.hostDefaults.primaryActivityKind.label,
              icon: CatchIcons.eventOutlined,
              onTap: isOwner ? () => _openClubEditor(context) : null,
            ),
            CatchSettingsRow(
              label: 'Admission',
              value: _admissionDefaultLabel(policy.admissionPreset),
              icon: CatchIcons.eventSeatOutlined,
              divider: true,
              onTap: isOwner ? () => _openClubEditor(context) : null,
            ),
            CatchSettingsRow(
              label: 'Age range',
              value: '${policy.minAge}–${policy.maxAge}',
              icon: CatchIcons.cakeOutlined,
              divider: true,
              onTap: isOwner ? () => _openClubEditor(context) : null,
            ),
            CatchSettingsRow(
              label: 'Cancellation policy',
              value: policy.cancellationPolicy.title,
              icon: CatchIcons.eventBusyOutlined,
              divider: true,
              onTap: isOwner ? () => _openClubEditor(context) : null,
            ),
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
              HostTeamManagementSection(club: club, currentUid: currentUid),
            ],
          ),
        ],
      ],
    );
  }

  void _openClubEditor(BuildContext context) {
    context.pushNamed(
      Routes.hostEditClubScreen.name,
      pathParameters: {'clubId': club.id},
      extra: club,
    );
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
