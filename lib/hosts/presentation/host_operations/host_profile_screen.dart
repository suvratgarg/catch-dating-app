part of '../host_operations_screen.dart';

class HostProfileScreen extends ConsumerStatefulWidget {
  const HostProfileScreen({
    super.key,
    this.formAutovalidateMode = AutovalidateMode.disabled,
  });

  final AutovalidateMode formAutovalidateMode;

  @override
  ConsumerState<HostProfileScreen> createState() => _HostProfileScreenState();
}

class _HostProfileScreenState extends ConsumerState<HostProfileScreen> {
  final _formKey = GlobalKey<FormState>();
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
    final compactTextScale = MediaQuery.textScalerOf(context).scale(1) >= 1.4;
    final uidAsync = ref.watch(uidProvider);
    if (uidAsync.isLoading) {
      return const HostLoadingScreen(title: 'Professional profile');
    }
    if (uidAsync.hasError) {
      return CatchErrorScaffold.fromError(
        uidAsync.error!,
        context: AppErrorContext.auth,
        onRetry: () => ref.invalidate(uidProvider),
      );
    }

    final uid = uidAsync.asData?.value;
    final profileAsync = uid == null
        ? const AsyncData<HostProfile?>(null)
        : ref.watch(watchHostProfileProvider(uid));
    final state = buildHostProfileEditState(uid: uid, profile: profileAsync);
    final ensureMutation = ref.watch(
      HostProfileController.ensureProfileMutation,
    );
    final saveMutation = ref.watch(HostProfileController.saveProfileMutation);
    if (state is HostProfileEditAuthRequired || uid == null) {
      return const HostAuthRequiredScreen();
    }

    return CatchMutationErrorListeners(
      mutations: [
        HostProfileController.ensureProfileMutation,
        HostProfileController.saveProfileMutation,
      ],
      errorContext: AppErrorContext.profile,
      child: Scaffold(
        backgroundColor: t.bg,
        appBar: CatchTopBar(
          border: true,
          titleWidget: compactTextScale
              ? Text(
                  'Professional profile',
                  semanticsLabel: 'Host profile. Professional profile',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: CatchTextStyles.titleL(context, color: t.ink),
                )
              : Column(
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
        body: _buildProfileBody(
          state,
          uid,
          creatingProfile: ensureMutation.isPending,
          savingProfile: saveMutation.isPending,
        ),
      ),
    );
  }

  Widget _buildProfileBody(
    HostProfileEditState state,
    String uid, {
    required bool creatingProfile,
    required bool savingProfile,
  }) {
    return switch (state) {
      HostProfileEditAuthRequired() => const SizedBox.shrink(),
      HostProfileEditLoading() => const CatchSkeletonRows(
        leading: CatchSkeletonRowLeading.icon,
        count: 4,
        divided: true,
      ),
      HostProfileEditError(:final error) => CatchErrorState.fromError(
        error,
        context: AppErrorContext.profile,
        onRetry: () => ref.invalidate(watchHostProfileProvider(uid)),
      ),
      HostProfileEditMissing() => ListView(
        padding: CatchInsets.pageBodyUnderHeader,
        children: [
          HostEmptyActionCard(
            title: 'No host profile yet',
            body:
                'Create a professional host identity before editing profile details.',
            actions: [
              CatchButton(
                label: 'Create host profile',
                icon: Icon(CatchIcons.businessOutlined, size: CatchIcon.md),
                isLoading: creatingProfile,
                onPressed: creatingProfile
                    ? null
                    : () => unawaited(_createHostProfile()),
              ),
            ],
          ),
        ],
      ),
      HostProfileEditContent(:final profile) => _buildProfileForm(
        profile: profile,
        savingProfile: savingProfile,
      ),
    };
  }

  Widget _buildProfileForm({
    required HostProfile profile,
    required bool savingProfile,
  }) {
    _syncControllers(profile);
    return Form(
      key: _formKey,
      autovalidateMode: widget.formAutovalidateMode,
      child: HostProfileForm(
        profile: profile,
        displayNameController: _displayNameController,
        roleTitleController: _roleTitleController,
        bioController: _bioController,
        saving: savingProfile,
        onSave: () => unawaited(_saveProfile()),
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
      showCatchSnackBar(context, 'Host profile saved.');
    } catch (_) {
      // CatchMutationErrorListener owns user-facing error display.
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
    }
  }
}

class HostProfileForm extends StatelessWidget {
  const HostProfileForm({
    super.key,
    required this.profile,
    required this.displayNameController,
    required this.roleTitleController,
    required this.bioController,
    required this.saving,
    required this.onSave,
  });

  final HostProfile profile;
  final TextEditingController displayNameController;
  final TextEditingController roleTitleController;
  final TextEditingController bioController;
  final bool saving;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
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
              HostProfileFields(
                status: profile.status,
                displayNameController: displayNameController,
                roleTitleController: roleTitleController,
                bioController: bioController,
              ),
              gapH18,
              CatchButton(
                label: 'Save profile',
                icon: Icon(CatchIcons.checkRounded, size: CatchIcon.md),
                isLoading: saving,
                fullWidth: true,
                onPressed: saving ? null : onSave,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class HostProfileFields extends StatelessWidget {
  const HostProfileFields({
    super.key,
    required this.status,
    required this.displayNameController,
    required this.roleTitleController,
    required this.bioController,
    this.showStatus = true,
  });

  final HostProfileStatus status;
  final TextEditingController displayNameController;
  final TextEditingController roleTitleController;
  final TextEditingController bioController;
  final bool showStatus;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showStatus) ...[
          Text(
            hostProfileStatusLabel(status),
            style: CatchTextStyles.supporting(
              context,
              color: status == HostProfileStatus.active ? t.success : t.ink2,
            ),
          ),
          gapH14,
        ],
        CatchField.input(
          title: 'Display name',
          controller: displayNameController,
          textInputAction: TextInputAction.next,
          textCapitalization: TextCapitalization.words,
          validator: _requiredDisplayName,
        ),
        gapH14,
        CatchField.input(
          title: 'Role title',
          isOptional: true,
          controller: roleTitleController,
          textInputAction: TextInputAction.next,
          textCapitalization: TextCapitalization.words,
        ),
        gapH14,
        CatchField.input(
          title: 'Bio',
          isOptional: true,
          controller: bioController,
          minLines: 4,
          maxLines: 6,
          textCapitalization: TextCapitalization.sentences,
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

String hostProfileStatusLabel(HostProfileStatus status) {
  return switch (status) {
    HostProfileStatus.active => 'Active professional profile',
    HostProfileStatus.pending => 'Profile pending review',
    HostProfileStatus.suspended => 'Profile suspended',
  };
}
