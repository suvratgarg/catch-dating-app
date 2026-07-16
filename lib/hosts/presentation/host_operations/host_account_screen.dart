part of '../host_operations_screen.dart';

class HostAccountScreen extends ConsumerStatefulWidget {
  const HostAccountScreen({super.key});

  @override
  ConsumerState<HostAccountScreen> createState() => _HostAccountScreenState();
}

class _HostAccountScreenState extends ConsumerState<HostAccountScreen> {
  var _selectedTab = HostSettingsMode.edit;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final uidAsync = ref.watch(uidProvider);
    if (uidAsync.isLoading) {
      return HostLoadingScreen(
        title: context.l10n.hostsHostAccountScreenTitleHostProfile,
        showTabRail: true,
      );
    }
    if (uidAsync.hasError) {
      return CatchErrorScaffold.fromError(
        uidAsync.error!,
        context: AppErrorContext.auth,
        onRetry: () => ref.invalidate(uidProvider),
      );
    }

    final uid = uidAsync.asData?.value;
    final hostProfileAsync = uid == null
        ? const AsyncData<HostProfile?>(null)
        : ref.watch(watchHostProfileProvider(uid));
    final clubsAsync = uid == null
        ? const AsyncData<List<Club>>([])
        : ref.watch(_hostClubsForUserProvider(uid));
    final ensureMutation = ref.watch(
      HostProfileController.ensureProfileMutation,
    );
    final signOutMutation = ref.watch(AuthSessionController.signOutMutation);
    final isEditMode = _selectedTab == HostSettingsMode.edit;
    final state = buildHostSettingsState(
      uid: uid,
      profile: hostProfileAsync,
      clubs: clubsAsync,
      editMode: isEditMode,
      creatingProfile: ensureMutation.isPending,
      signOutPending: signOutMutation.isPending,
    );
    final actions = state.actions;

    return CatchMutationErrorListener(
      mutation: AuthSessionController.signOutMutation,
      errorContext: AppErrorContext.auth,
      child: CatchMutationErrorListeners(
        mutations: [
          HostProfileController.ensureProfileMutation,
          HostProfileController.saveProfileMutation,
        ],
        errorContext: AppErrorContext.profile,
        child: Scaffold(
          backgroundColor: t.bg,
          appBar: CatchTopBar(
            title: context.l10n.hostsHostAccountScreenTitleHostProfile,
            leadingType: CatchTopBarLeading.back,
            onBack: _leaveAccount,
            border: true,
            actions: [
              CatchIconAction(
                tooltip: context.l10n.hostsHostAccountScreenTooltipSignOut,
                icon: CatchIcons.logoutRounded,
                onPressed: actions.canSignOut
                    ? () => unawaited(_signOut())
                    : null,
              ),
            ],
            bottom: CatchTabRail<HostSettingsMode>(
              selected: _selectedTab,
              onChanged: (tab) => setState(() => _selectedTab = tab),
              options: [
                CatchOption(
                  value: HostSettingsMode.edit,
                  label: context.l10n.hostsHostAccountScreenLabelEdit,
                ),
                CatchOption(
                  value: HostSettingsMode.preview,
                  label: context.l10n.hostsHostAccountScreenLabelPreview,
                ),
              ],
            ),
          ),
          body: ListView(
            padding: CatchInsets.pageBodyUnderHeader,
            children: [
              HostSettingsProfileSection(
                state: state.profile,
                editMode: actions.editMode,
                creatingProfile: actions.creatingProfile,
                onRetry: uid == null
                    ? null
                    : () => ref.invalidate(watchHostProfileProvider(uid)),
                onCreateProfile: actions.canCreateProfile
                    ? () => unawaited(_createHostProfile())
                    : null,
                onEditProfile: actions.canEditProfile
                    ? () => unawaited(
                        _openProfileEditor(
                          actions.uid!,
                          actions.profileForEdit!,
                        ),
                      )
                    : null,
              ),
              HostSettingsClubsSection(
                actions: actions,
                state: state.clubs,
                onRetry: uid == null
                    ? null
                    : () => ref.invalidate(_hostClubsForUserProvider(uid)),
                onOpenClub: _openSettingsClub,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openProfileEditor(String uid, HostProfile profile) async {
    final saved = await showCatchBottomSheet<bool>(
      context: context,
      builder: (_) => HostProfileEditorSheet(profile: profile),
    );
    if (saved == true && mounted) {
      showCatchSnackBar(
        context,
        context.l10n.hostsHostAccountScreenVisiblecopyHostProfileSaved,
      );
    }
  }

  Future<void> _createHostProfile() async {
    try {
      await HostProfileController.ensureProfileMutation.run(
        ref,
        (tx) async =>
            tx.get(hostProfileControllerProvider.notifier).ensureProfile(),
      );
    } catch (_) {
      // CatchMutationErrorListener owns user-facing error display.
      return;
    }
    if (!mounted) return;
    showCatchSnackBar(
      context,
      context.l10n.hostsHostAccountScreenVisiblecopyHostProfileCreated,
    );
  }

  void _openSettingsClub(HostSettingsClubNavigationState navigation) {
    context.pushNamed(
      navigation.destination == HostSettingsClubDestination.edit
          ? Routes.hostEditClubScreen.name
          : Routes.hostClubDetailScreen.name,
      pathParameters: {'clubId': navigation.club.id},
      extra: navigation.club,
    );
  }

  Future<void> _signOut() async {
    final mutation = ref.read(AuthSessionController.signOutMutation);
    if (mutation.isPending) return;
    try {
      await AuthSessionController.signOutMutation.run(
        ref,
        (tx) async => tx.get(authSessionControllerProvider.notifier).signOut(),
      );
    } catch (_) {
      // CatchMutationErrorListener owns user-facing error display.
      return;
    }
    if (mounted) context.go(Routes.startScreen.path);
  }

  void _leaveAccount() {
    if (context.canPop()) {
      context.pop();
      return;
    }
    context.go(Routes.hostOrganizerScreen.path);
  }
}

class HostSettingsProfileSection extends StatelessWidget {
  const HostSettingsProfileSection({
    super.key,
    required this.state,
    required this.editMode,
    this.creatingProfile = false,
    required this.onRetry,
    required this.onCreateProfile,
    required this.onEditProfile,
  });

  final HostSettingsProfileState state;
  final bool editMode;
  final bool creatingProfile;
  final VoidCallback? onRetry;
  final VoidCallback? onCreateProfile;
  final VoidCallback? onEditProfile;

  @override
  Widget build(BuildContext context) {
    return switch (state) {
      HostSettingsProfileLoading() => const CatchSkeletonRows(
        leading: CatchSkeletonRowLeading.icon,
        divided: true,
      ),
      HostSettingsProfileError(:final error) => CatchErrorState.fromError(
        error,
        context: AppErrorContext.profile,
        onRetry: onRetry,
      ),
      HostSettingsProfileMissing() => CatchSection.fieldRows(
        title: context.l10n.hostsHostAccountScreenTitleProfile,
        first: true,
        children: [
          CatchField.nav(
            title: context.l10n.hostsHostAccountScreenTitleDisplayName,
            valueText: creatingProfile
                ? context.l10n.hostsHostAccountScreenVisiblecopyCreatingProfile
                : context
                      .l10n
                      .hostsHostAccountScreenVisiblecopyCreateHostProfile,
            icon: CatchIcons.businessOutlined,
            action: creatingProfile
                ? const SizedBox.square(
                    dimension: CatchIcon.md,
                    child: CatchLoadingIndicator(
                      strokeWidth: CatchIcon.strokeSm,
                    ),
                  )
                : null,
            onTap: creatingProfile ? null : onCreateProfile,
          ),
        ],
      ),
      HostSettingsProfileContent(:final profile) => HostSettingsProfileRows(
        profile: profile,
        editMode: editMode,
        onEditProfile: onEditProfile,
      ),
    };
  }
}

class HostSettingsProfileRows extends StatelessWidget {
  const HostSettingsProfileRows({
    super.key,
    required this.profile,
    required this.editMode,
    required this.onEditProfile,
  });

  final HostProfile profile;
  final bool editMode;
  final VoidCallback? onEditProfile;

  @override
  Widget build(BuildContext context) {
    final canEdit = editMode && onEditProfile != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CatchSection.fieldRows(
          title: context.l10n.hostsHostAccountScreenTitleProfile,
          first: true,
          children: [
            CatchField.nav(
              title: context.l10n.hostsHostAccountScreenTitleDisplayName,
              valueText: profile.displayName,
              icon: CatchIcons.personOutlineRounded,
              onTap: canEdit ? onEditProfile : null,
            ),
            CatchField.nav(
              title: context.l10n.hostsHostAccountScreenTitleRoleTitle,
              valueText: profile.roleTitle?.trim().isNotEmpty == true
                  ? profile.roleTitle!.trim()
                  : context.l10n.hostsHostAccountScreenVisiblecopyAddRoleTitle,
              icon: CatchIcons.cardMembershipOutlined,
              onTap: canEdit ? onEditProfile : null,
            ),
            CatchField.read(
              title: context.l10n.hostsHostAccountScreenTitleStatus,
              valueText: hostProfileStatusLabel(profile.status),
              icon: CatchIcons.checkCircleOutlineRounded,
            ),
          ],
        ),
        CatchSection.fieldRows(
          title: context.l10n.hostsHostAccountScreenTitleBio,
          children: [
            CatchField.nav(
              title: context.l10n.hostsHostAccountScreenTitleAboutYouAsA,
              valueText: profile.bio?.trim().isNotEmpty == true
                  ? profile.bio!.trim()
                  : context.l10n.hostsHostAccountScreenVisiblecopyAddAHostBio,
              icon: CatchIcons.chatBubbleOutlineRounded,
              valueMaxLines: 2,
              onTap: canEdit ? onEditProfile : null,
            ),
          ],
        ),
      ],
    );
  }
}

class HostSettingsClubsSection extends StatelessWidget {
  const HostSettingsClubsSection({
    super.key,
    required this.actions,
    required this.state,
    required this.onRetry,
    required this.onOpenClub,
  });

  final HostSettingsActionState actions;
  final HostSettingsClubsState state;
  final VoidCallback? onRetry;
  final ValueChanged<HostSettingsClubNavigationState> onOpenClub;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return CatchSection.fieldRows(
      title: context.l10n.hostsHostAccountScreenTitleClubsYouHost,
      children: switch (state) {
        HostSettingsClubsLoading() => [
          const CatchSkeletonRows(
            leading: CatchSkeletonRowLeading.icon,
            count: 2,
            divided: true,
          ),
        ],
        HostSettingsClubsError(:final error) => [
          CatchErrorState.fromError(
            error,
            context: AppErrorContext.club,
            onRetry: onRetry,
          ),
        ],
        HostSettingsClubsEmpty() => [
          Text(
            context.l10n.hostsHostAccountScreenTextNoHostClubsYet,
            style: CatchTextStyles.supporting(context, color: t.ink2),
          ),
        ],
        HostSettingsClubsContent(:final clubs) => [
          for (final club in clubs)
            Builder(
              builder: (context) {
                final navigation = actions.clubNavigationFor(club);
                return CatchField.nav(
                  title: navigation.roleLabel,
                  valueText: club.name,
                  icon: CatchIcons.groupOutlined,
                  onTap: () => onOpenClub(navigation),
                );
              },
            ),
        ],
      },
    );
  }
}

class HostProfileEditorSheet extends ConsumerStatefulWidget {
  const HostProfileEditorSheet({super.key, required this.profile});

  final HostProfile profile;

  @override
  ConsumerState<HostProfileEditorSheet> createState() =>
      _HostProfileEditorSheetState();
}

class _HostProfileEditorSheetState
    extends ConsumerState<HostProfileEditorSheet> {
  final _formKey = GlobalKey<FormState>();
  final _displayNameController = TextEditingController();
  final _roleTitleController = TextEditingController();
  final _bioController = TextEditingController();

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
    final saveMutation = ref.watch(HostProfileController.saveProfileMutation);
    return Form(
      key: _formKey,
      child: CatchBottomSheetScaffold(
        title: context.l10n.hostsHostAccountScreenTitleProfessionalProfile,
        subtitle: hostProfileStatusLabel(widget.profile.status),
        keyboardSafe: true,
        action: CatchButton(
          label: context.l10n.hostsHostAccountScreenLabelSaveProfile,
          icon: Icon(CatchIcons.checkRounded, size: CatchIcon.md),
          isLoading: saveMutation.isPending,
          fullWidth: true,
          onPressed: saveMutation.isPending
              ? null
              : () => unawaited(_saveProfile()),
        ),
        child: HostProfileFields(
          status: widget.profile.status,
          displayNameController: _displayNameController,
          roleTitleController: _roleTitleController,
          bioController: _bioController,
          showStatus: false,
        ),
      ),
    );
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState?.validate() != true) return;
    try {
      await HostProfileController.saveProfileMutation.run(
        ref,
        (tx) async => tx
            .get(hostProfileControllerProvider.notifier)
            .saveProfile(
              displayName: _displayNameController.text,
              roleTitle: _roleTitleController.text,
              bio: _bioController.text,
            ),
      );
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (_) {
      // CatchMutationErrorListener owns user-facing error display.
    }
  }
}
