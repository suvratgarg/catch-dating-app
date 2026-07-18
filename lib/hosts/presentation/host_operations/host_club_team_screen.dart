part of '../host_operations_screen.dart';

class HostClubTeamScreen extends ConsumerStatefulWidget {
  const HostClubTeamScreen({super.key, required this.clubId});

  final String clubId;

  @override
  ConsumerState<HostClubTeamScreen> createState() => _HostClubTeamScreenState();
}

class _HostClubTeamScreenState extends ConsumerState<HostClubTeamScreen> {
  var _selectedTab = HostTeamMode.edit;
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
        title: context.l10n.hostsHostClubEditTabLabelHostTeam,
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
    if (uid == null) return const HostAuthRequiredScreen();

    final hostProfileAsync = ref.watch(watchHostProfileProvider(uid));
    final clubsAsync = ref.watch(_hostClubsForUserProvider(uid));
    if (clubsAsync.isLoading) {
      return HostLoadingScreen(
        title: context.l10n.hostsHostClubEditTabLabelHostTeam,
        showTabRail: true,
      );
    }
    if (clubsAsync.hasError) {
      return CatchErrorScaffold.fromError(
        clubsAsync.error!,
        context: AppErrorContext.club,
        onRetry: () => ref.invalidate(_hostClubsForUserProvider(uid)),
      );
    }
    final clubs = clubsAsync.asData?.value ?? const <Club>[];
    final club = clubs.where((item) => item.id == widget.clubId).firstOrNull;
    if (club == null) {
      return CatchErrorScaffold.fromError(
        StateError('Club unavailable'),
        context: AppErrorContext.club,
        onRetry: () => ref.invalidate(_hostClubsForUserProvider(uid)),
      );
    }
    final ensureMutation = ref.watch(
      HostProfileController.ensureProfileMutation,
    );
    final saveMutation = ref.watch(HostProfileController.saveProfileMutation);
    final signOutMutation = ref.watch(AuthSessionController.signOutMutation);
    final isEditMode = _selectedTab == HostTeamMode.edit;
    final state = buildHostTeamWorkspaceState(
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
          appBar: CatchScreenTopBar(
            context: context,
            eyebrow: club.name,
            title: context.l10n.hostsHostClubEditTabLabelHostTeam,
            leading: CatchIconAction(
              tooltip: MaterialLocalizations.of(context).backButtonTooltip,
              icon: CatchIcons.arrowBackIosNewRounded,
              onPressed: _leaveTeam,
            ),
            leadingType: CatchTopBarLeading.back,
            border: true,
            bottom: CatchTabRail<HostTeamMode>(
              selected: _selectedTab,
              onChanged: (tab) => setState(() => _selectedTab = tab),
              options: [
                CatchOption(
                  value: HostTeamMode.edit,
                  label: context.l10n.hostsHostClubTeamScreenLabelEdit,
                ),
                CatchOption(
                  value: HostTeamMode.preview,
                  label: context.l10n.hostsHostClubTeamScreenLabelPreview,
                ),
              ],
            ),
          ),
          body: SafeArea(
            top: false,
            bottom: false,
            child: ListView(
              padding: CatchInsets.pageBodyUnderHeader.copyWith(bottom: 0),
              children: [
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: CatchLayout.maxContentWidth,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        HostTeamProfileSection(
                          state: state.profile,
                          editMode: actions.editMode,
                          creatingProfile: actions.creatingProfile,
                          onRetry: () =>
                              ref.invalidate(watchHostProfileProvider(uid)),
                          onCreateProfile: actions.canCreateProfile
                              ? () => unawaited(_createHostProfile())
                              : null,
                          formKey: _profileFormKey,
                          displayNameController: _displayNameController,
                          roleTitleController: _roleTitleController,
                          bioController: _bioController,
                          savingProfile: saveMutation.isPending,
                          onSaveProfile:
                              actions.canEditProfile && !saveMutation.isPending
                              ? () => unawaited(_saveProfile())
                              : null,
                        ),
                        HostTeamManagementSection(
                          club: club,
                          currentUid: uid,
                          canManage: club.isOwnedBy(uid) && isEditMode,
                        ),
                        HostTeamHostedClubsSection(
                          actions: actions,
                          state: state.clubs,
                          onRetry: () =>
                              ref.invalidate(_hostClubsForUserProvider(uid)),
                          onOpenClub: _openHostedClub,
                        ),
                        if (isEditMode)
                          CatchSection.fieldRows(
                            children: [
                              CatchField.nav(
                                key: const ValueKey('host-team-sign-out'),
                                title: context
                                    .l10n
                                    .hostsHostClubTeamScreenTitleSignOut,
                                icon: CatchIcons.logoutRounded,
                                tone: CatchFieldTone.danger,
                                action: actions.signOutPending
                                    ? const SizedBox.square(
                                        dimension: CatchIcon.control,
                                        child: CatchLoadingIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : null,
                                onTap: actions.canSignOut
                                    ? () => unawaited(_signOut())
                                    : null,
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
                const CatchScrollTerminalPadding(),
              ],
            ),
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
      context.l10n.hostsHostClubTeamScreenVisiblecopyHostProfileSaved,
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
      context.l10n.hostsHostClubTeamScreenVisiblecopyHostProfileCreated,
    );
  }

  void _openHostedClub(HostTeamClubNavigationState navigation) {
    if (navigation.destination == HostTeamClubDestination.edit) {
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

  void _leaveTeam() {
    if (context.canPop()) {
      context.pop();
      return;
    }
    context.goNamed(
      Routes.hostOrganizerScreen.name,
      queryParameters: {'clubId': widget.clubId, 'tab': HostClubTab.edit.name},
    );
  }
}

class HostTeamProfileSection extends StatelessWidget {
  const HostTeamProfileSection({
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

  final HostTeamProfileState state;
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
      HostTeamProfileLoading() => const CatchSkeletonRows(
        leading: CatchSkeletonRowLeading.icon,
        divided: true,
      ),
      HostTeamProfileError(:final error) => CatchErrorState.fromError(
        error,
        context: AppErrorContext.profile,
        onRetry: onRetry,
      ),
      HostTeamProfileMissing() => CatchSection.fieldRows(
        title: context.l10n.hostsHostClubTeamScreenTitleProfile,
        first: true,
        children: [
          CatchField.nav(
            title: context.l10n.hostsHostClubTeamScreenTitleDisplayName,
            valueText: creatingProfile
                ? context.l10n.hostsHostClubTeamScreenVisiblecopyCreatingProfile
                : context
                      .l10n
                      .hostsHostClubTeamScreenVisiblecopyCreateHostProfile,
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
      HostTeamProfileContent(:final profile) => HostTeamProfileRows(
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

class HostTeamProfileRows extends StatelessWidget {
  const HostTeamProfileRows({
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
        title: context.l10n.hostsHostClubTeamScreenTitleProfile,
        first: true,
        children: [
          CatchField.read(
            title: context.l10n.hostsHostClubTeamScreenTitleDisplayName,
            valueText: profile.displayName,
            icon: CatchIcons.personOutlineRounded,
          ),
          CatchField.read(
            title: context.l10n.hostsHostClubTeamScreenTitleRoleTitle,
            valueText: profile.roleTitle?.trim().isNotEmpty == true
                ? profile.roleTitle!.trim()
                : context.l10n.hostsHostClubTeamScreenVisiblecopyAddRoleTitle,
            icon: CatchIcons.cardMembershipOutlined,
          ),
          CatchField.read(
            title: context.l10n.hostsHostClubTeamScreenTitleStatus,
            valueText: hostProfileStatusLabel(profile.status, context.l10n),
            icon: CatchIcons.checkCircleOutlineRounded,
          ),
          CatchField.read(
            title: context.l10n.hostsHostClubTeamScreenTitleAboutYouAsA,
            valueText: profile.bio?.trim().isNotEmpty == true
                ? profile.bio!.trim()
                : context.l10n.hostsHostClubTeamScreenVisiblecopyAddAHostBio,
            icon: CatchIcons.chatBubbleOutlineRounded,
            valueMaxLines: 3,
          ),
        ],
      );
    }

    return Form(
      key: formKey,
      child: CatchSection.fieldRows(
        title: context.l10n.hostsHostClubTeamScreenTitleProfile,
        first: true,
        footer: CatchButton(
          label: context.l10n.hostsHostClubTeamScreenLabelSaveProfile,
          icon: Icon(CatchIcons.checkRounded, size: CatchIcon.md),
          isLoading: savingProfile,
          fullWidth: true,
          onPressed: onSaveProfile,
        ),
        children: [
          CatchField.input(
            title: context.l10n.hostsHostClubTeamScreenTitleDisplayName,
            controller: displayNameController,
            icon: CatchIcons.personOutlineRounded,
            textInputAction: TextInputAction.next,
            textCapitalization: TextCapitalization.words,
            validator: (value) => _requiredDisplayName(value, context.l10n),
          ),
          CatchField.input(
            title: context.l10n.hostsHostClubTeamScreenTitleRoleTitle,
            isOptional: true,
            controller: roleTitleController,
            icon: CatchIcons.cardMembershipOutlined,
            textInputAction: TextInputAction.next,
            textCapitalization: TextCapitalization.words,
          ),
          CatchField.read(
            title: context.l10n.hostsHostClubTeamScreenTitleStatus,
            valueText: hostProfileStatusLabel(profile.status, context.l10n),
            icon: CatchIcons.checkCircleOutlineRounded,
          ),
          CatchField.input(
            title: context.l10n.hostsHostClubTeamScreenTitleAboutYouAsA,
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

class HostTeamHostedClubsSection extends StatelessWidget {
  const HostTeamHostedClubsSection({
    super.key,
    required this.actions,
    required this.state,
    required this.onRetry,
    required this.onOpenClub,
  });

  final HostTeamWorkspaceActionState actions;
  final HostTeamHostedClubsState state;
  final VoidCallback? onRetry;
  final ValueChanged<HostTeamClubNavigationState> onOpenClub;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final sectionChildren = switch (state) {
      HostTeamHostedClubsLoading() => const <Widget>[
        CatchSkeletonRows(
          leading: CatchSkeletonRowLeading.icon,
          count: 2,
          divided: true,
        ),
      ],
      HostTeamHostedClubsError(:final error) => <Widget>[
        CatchErrorState.fromError(
          error,
          context: AppErrorContext.club,
          onRetry: onRetry,
        ),
      ],
      HostTeamHostedClubsEmpty() => <Widget>[
        Text(
          context.l10n.hostsHostClubTeamScreenTextNoHostClubsYet,
          style: CatchTextStyles.supporting(context, color: t.ink2),
        ),
      ],
      HostTeamHostedClubsContent(:final clubs) => <Widget>[
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
      title: context.l10n.hostsHostClubTeamScreenTitleClubsYouHost,
      children: sectionChildren,
    );
  }
}

String? _requiredDisplayName(String? value, AppLocalizations l10n) {
  if (value == null || value.trim().isEmpty) {
    return l10n.hostsValidationEnterDisplayName;
  }
  return null;
}

String hostProfileStatusLabel(HostProfileStatus status, AppLocalizations l10n) {
  return switch (status) {
    HostProfileStatus.active => l10n.hostsProfileStatusActive,
    HostProfileStatus.pending => l10n.hostsProfileStatusPending,
    HostProfileStatus.suspended => l10n.hostsProfileStatusSuspended,
  };
}
