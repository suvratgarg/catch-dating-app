part of '../host_operations_screen.dart';

class HostAccountScreen extends ConsumerStatefulWidget {
  const HostAccountScreen({super.key});

  @override
  ConsumerState<HostAccountScreen> createState() => _HostAccountScreenState();
}

class _HostAccountScreenState extends ConsumerState<HostAccountScreen> {
  var _selectedTab = HostSettingsMode.edit;
  final _profileFormKey = GlobalKey<FormState>();
  final _displayNameController = TextEditingController();
  final _roleTitleController = TextEditingController();
  final _bioController = TextEditingController();
  String? _loadedProfileKey;

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
    final saveMutation = ref.watch(HostProfileController.saveProfileMutation);
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
    final editableProfile = actions.profileForEdit;
    if (editableProfile != null) _syncProfileControllers(editableProfile);

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
                formKey: _profileFormKey,
                displayNameController: _displayNameController,
                roleTitleController: _roleTitleController,
                bioController: _bioController,
                savingProfile: saveMutation.isPending,
                onSaveProfile: actions.canEditProfile && !saveMutation.isPending
                    ? () => unawaited(_saveProfile())
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

  void _syncProfileControllers(HostProfile profile) {
    final profileKey = [
      profile.uid,
      profile.displayName,
      profile.roleTitle,
      profile.bio,
      profile.updatedAt?.microsecondsSinceEpoch,
    ].join('|');
    if (_loadedProfileKey == profileKey) return;
    _loadedProfileKey = profileKey;
    _displayNameController.text = profile.displayName;
    _roleTitleController.text = profile.roleTitle ?? '';
    _bioController.text = profile.bio ?? '';
  }

  Future<void> _saveProfile() async {
    if (_profileFormKey.currentState?.validate() != true) return;
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
    } catch (_) {
      // CatchMutationErrorListener owns user-facing error display.
      return;
    }
    if (!mounted) return;
    showCatchSnackBar(
      context,
      context.l10n.hostsHostAccountScreenVisiblecopyHostProfileSaved,
    );
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
    if (navigation.destination == HostSettingsClubDestination.edit) {
      context.goNamed(
        Routes.hostOrganizerScreen.name,
        queryParameters: {
          'clubId': navigation.club.id,
          'tab': HostClubTab.edit.name,
        },
      );
      return;
    }
    context.pushNamed(
      Routes.hostClubDetailScreen.name,
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
    required this.formKey,
    required this.displayNameController,
    required this.roleTitleController,
    required this.bioController,
    required this.savingProfile,
    required this.onSaveProfile,
  });

  final HostSettingsProfileState state;
  final bool editMode;
  final bool creatingProfile;
  final VoidCallback? onRetry;
  final VoidCallback? onCreateProfile;
  final GlobalKey<FormState> formKey;
  final TextEditingController displayNameController;
  final TextEditingController roleTitleController;
  final TextEditingController bioController;
  final bool savingProfile;
  final VoidCallback? onSaveProfile;

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
        formKey: formKey,
        displayNameController: displayNameController,
        roleTitleController: roleTitleController,
        bioController: bioController,
        savingProfile: savingProfile,
        onSaveProfile: onSaveProfile,
      ),
    };
  }
}

class HostSettingsProfileRows extends StatelessWidget {
  const HostSettingsProfileRows({
    super.key,
    required this.profile,
    required this.editMode,
    required this.formKey,
    required this.displayNameController,
    required this.roleTitleController,
    required this.bioController,
    required this.savingProfile,
    required this.onSaveProfile,
  });

  final HostProfile profile;
  final bool editMode;
  final GlobalKey<FormState> formKey;
  final TextEditingController displayNameController;
  final TextEditingController roleTitleController;
  final TextEditingController bioController;
  final bool savingProfile;
  final VoidCallback? onSaveProfile;

  @override
  Widget build(BuildContext context) {
    if (!editMode) {
      return CatchSection.fieldRows(
        title: context.l10n.hostsHostAccountScreenTitleProfile,
        first: true,
        children: [
          CatchField.read(
            title: context.l10n.hostsHostAccountScreenTitleDisplayName,
            valueText: profile.displayName,
            icon: CatchIcons.personOutlineRounded,
          ),
          CatchField.read(
            title: context.l10n.hostsHostAccountScreenTitleRoleTitle,
            valueText: profile.roleTitle?.trim().isNotEmpty == true
                ? profile.roleTitle!.trim()
                : context.l10n.hostsHostAccountScreenVisiblecopyAddRoleTitle,
            icon: CatchIcons.cardMembershipOutlined,
          ),
          CatchField.read(
            title: context.l10n.hostsHostAccountScreenTitleStatus,
            valueText: hostProfileStatusLabel(profile.status),
            icon: CatchIcons.checkCircleOutlineRounded,
          ),
          CatchField.read(
            title: context.l10n.hostsHostAccountScreenTitleAboutYouAsA,
            valueText: profile.bio?.trim().isNotEmpty == true
                ? profile.bio!.trim()
                : context.l10n.hostsHostAccountScreenVisiblecopyAddAHostBio,
            icon: CatchIcons.chatBubbleOutlineRounded,
            valueMaxLines: 3,
          ),
        ],
      );
    }

    return Form(
      key: formKey,
      child: CatchSection.fieldRows(
        title: context.l10n.hostsHostAccountScreenTitleProfile,
        first: true,
        footer: CatchButton(
          label: context.l10n.hostsHostAccountScreenLabelSaveProfile,
          icon: Icon(CatchIcons.checkRounded, size: CatchIcon.md),
          isLoading: savingProfile,
          fullWidth: true,
          onPressed: onSaveProfile,
        ),
        children: [
          CatchField.input(
            title: context.l10n.hostsHostAccountScreenTitleDisplayName,
            controller: displayNameController,
            icon: CatchIcons.personOutlineRounded,
            textInputAction: TextInputAction.next,
            textCapitalization: TextCapitalization.words,
            validator: _requiredDisplayName,
          ),
          CatchField.input(
            title: context.l10n.hostsHostAccountScreenTitleRoleTitle,
            isOptional: true,
            controller: roleTitleController,
            icon: CatchIcons.cardMembershipOutlined,
            textInputAction: TextInputAction.next,
            textCapitalization: TextCapitalization.words,
          ),
          CatchField.read(
            title: context.l10n.hostsHostAccountScreenTitleStatus,
            valueText: hostProfileStatusLabel(profile.status),
            icon: CatchIcons.checkCircleOutlineRounded,
          ),
          CatchField.input(
            title: context.l10n.hostsHostAccountScreenTitleAboutYouAsA,
            isOptional: true,
            controller: bioController,
            icon: CatchIcons.chatBubbleOutlineRounded,
            minLines: 2,
            maxLines: 4,
            textCapitalization: TextCapitalization.sentences,
          ),
        ],
      ),
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
    final sectionChildren = switch (state) {
      HostSettingsClubsLoading() => const <Widget>[
        CatchSkeletonRows(
          leading: CatchSkeletonRowLeading.icon,
          count: 2,
          divided: true,
        ),
      ],
      HostSettingsClubsError(:final error) => <Widget>[
        CatchErrorState.fromError(
          error,
          context: AppErrorContext.club,
          onRetry: onRetry,
        ),
      ],
      HostSettingsClubsEmpty() => <Widget>[
        Text(
          context.l10n.hostsHostAccountScreenTextNoHostClubsYet,
          style: CatchTextStyles.supporting(context, color: t.ink2),
        ),
      ],
      HostSettingsClubsContent(:final clubs) => <Widget>[
        for (final club in clubs)
          CatchField.nav(
            title: actions.clubNavigationFor(club).roleLabel,
            valueText: club.name,
            icon: CatchIcons.groupOutlined,
            onTap: () => onOpenClub(actions.clubNavigationFor(club)),
          ),
      ],
    };
    return CatchSection.fieldRows(
      title: context.l10n.hostsHostAccountScreenTitleClubsYouHost,
      children: sectionChildren,
    );
  }
}
