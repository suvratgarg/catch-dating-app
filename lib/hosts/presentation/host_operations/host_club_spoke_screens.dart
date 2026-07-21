part of '../host_operations_screen.dart';

class HostClubEventDefaultsScreen extends StatelessWidget {
  const HostClubEventDefaultsScreen({super.key, required this.clubId});

  final String clubId;

  @override
  Widget build(BuildContext context) {
    return HostClubSpokeResolver._(
      clubId: clubId,
      title: context.l10n.hostsHostClubEditTabLabelEventDefaults,
      builder: (context, club, _, isOwner) => isOwner
          ? HostClubDefaultsEditor._(
              club: club,
              builder: (context, defaults, apply, errorMessage, _) =>
                  CatchSectionList(
                    emptyStateOmitted: true,
                    children: [
                      ClubPolicyDefaultsCard(
                        defaults: defaults.eventPolicy,
                        currencyCode: currencyCodeForCityName(club.location),
                        activityKind: defaults.primaryActivityKind,
                        onActivityChanged: (activityKind) => apply(
                          (current) =>
                              _hostDefaultsWithActivity(current, activityKind),
                        ),
                        onChanged: (update) => apply(
                          (current) => current.copyWith(
                            eventPolicy: update(current.eventPolicy),
                          ),
                        ),
                      ),
                      if (errorMessage != null)
                        CatchFieldSupportRow(
                          text: errorMessage,
                          color: CatchTokens.of(context).danger,
                          showErrorIcon: true,
                        ),
                    ],
                  ),
            )
          : HostClubReadOnlyEventDefaults._(club: club),
    );
  }
}

class HostClubSpokeResolver extends ConsumerWidget {
  const HostClubSpokeResolver._({
    required this.clubId,
    required this.title,
    required this.builder,
  });

  final String clubId;
  final String title;
  final Widget Function(
    BuildContext context,
    Club club,
    String currentUid,
    bool isOwner,
  )
  builder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uidAsync = ref.watch(uidProvider);
    if (uidAsync.isLoading) return HostLoadingScreen(title: title);
    if (uidAsync.hasError) {
      return CatchErrorScaffold.fromError(
        uidAsync.error!,
        context: AppErrorContext.auth,
        onRetry: () => ref.invalidate(uidProvider),
      );
    }
    final uid = uidAsync.asData?.value;
    if (uid == null) return const HostAuthRequiredScreen();

    final clubsAsync = ref.watch(_hostClubsForUserProvider(uid));
    return CatchAsyncValueView<List<Club>>(
      value: clubsAsync,
      onRetry: () => ref.invalidate(_hostClubsForUserProvider(uid)),
      loadingBuilder: (_) => HostLoadingScreen(title: title),
      errorBuilder: (_, error, _) => CatchErrorScaffold.fromError(
        error,
        context: AppErrorContext.club,
        onRetry: () => ref.invalidate(_hostClubsForUserProvider(uid)),
      ),
      builder: (context, clubs) {
        final club = clubs.where((item) => item.id == clubId).firstOrNull;
        if (club == null) {
          return CatchErrorScaffold.fromError(
            StateError('Organizer unavailable'),
            context: AppErrorContext.club,
            onRetry: () => ref.invalidate(_hostClubsForUserProvider(uid)),
          );
        }
        return HostClubSpokeScaffold._(
          club: club,
          title: title,
          child: builder(context, club, uid, club.isOwnedBy(uid)),
        );
      },
    );
  }
}

class HostClubSpokeScaffold extends StatelessWidget {
  const HostClubSpokeScaffold._({
    required this.club,
    required this.title,
    required this.child,
  });

  final Club club;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CatchTokens.of(context).bg,
      appBar: CatchScreenTopBar(
        context: context,
        eyebrow: club.name,
        title: title,
        leadingType: CatchTopBarLeading.back,
        border: true,
      ),
      body: SafeArea(
        top: false,
        bottom: false,
        child: ListView(
          padding: CatchInsets.pageBody.copyWith(bottom: 0),
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: CatchLayout.maxContentWidth,
                ),
                child: SizedBox(width: double.infinity, child: child),
              ),
            ),
            const CatchScrollTerminalPadding(),
          ],
        ),
      ),
    );
  }
}

class HostClubDefaultsEditor extends ConsumerStatefulWidget {
  const HostClubDefaultsEditor._({required this.club, required this.builder});

  final Club club;
  final Widget Function(
    BuildContext context,
    ClubHostDefaults defaults,
    ValueChanged<ClubHostDefaultsUpdate> apply,
    String? errorMessage,
    bool isSaving,
  )
  builder;

  @override
  ConsumerState<HostClubDefaultsEditor> createState() =>
      _HostClubDefaultsEditorState();
}

class _HostClubDefaultsEditorState
    extends ConsumerState<HostClubDefaultsEditor> {
  HostClubDefaultsSaver? _saver;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _saver ??= _createSaver();
  }

  HostClubDefaultsSaver _createSaver() {
    return HostClubDefaultsSaver(
      initial: widget.club.hostDefaults,
      writer: (defaults) => HostClubEditController.updateClubMutation.run(
        ref,
        (tx) => tx
            .get(hostClubEditControllerProvider)
            .updateClub(
              clubId: widget.club.id,
              patch: UpdateClubPatch(hostDefaults: defaults),
            ),
      ),
      errorMessageFor: (error) => appErrorMessage(
        error,
        l10n: context.l10n,
        context: AppErrorContext.club,
      ),
    )..addListener(_handleSaverChanged);
  }

  @override
  void didUpdateWidget(covariant HostClubDefaultsEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.club.id != widget.club.id) {
      _saver
        ?..removeListener(_handleSaverChanged)
        ..dispose();
      _saver = _createSaver();
    } else {
      _saver?.reconcile(widget.club.hostDefaults);
    }
  }

  @override
  void dispose() {
    _saver
      ?..removeListener(_handleSaverChanged)
      ..dispose();
    super.dispose();
  }

  void _handleSaverChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final saver = _saver!;
    return widget.builder(
      context,
      saver.optimistic,
      saver.apply,
      saver.errorMessage,
      saver.isSaving,
    );
  }
}

class HostClubReadOnlyEventDefaults extends StatelessWidget {
  const HostClubReadOnlyEventDefaults._({required this.club});

  final Club club;

  @override
  Widget build(BuildContext context) {
    final policy = club.hostDefaults.eventPolicy;
    return CatchSection.fieldRows(
      first: true,
      title: context.l10n.hostsHostClubEditTabLabelEventDefaults,
      children: [
        CatchField.read(
          title: context.l10n.hostsHostClubProfileTitleDefaultActivity,
          valueText: club.hostDefaults.primaryActivityKind.label,
          icon: CatchIcons.eventOutlined,
        ),
        CatchField.read(
          title: context.l10n.hostsHostClubProfileTitleAdmission,
          body: _admissionDefaultDescription(
            policy.admissionPreset,
            context.l10n,
          ),
          valueText: _admissionDefaultLabel(
            policy.admissionPreset,
            context.l10n,
          ),
          icon: CatchIcons.eventSeatOutlined,
        ),
        CatchField.read(
          title: context.l10n.hostsHostClubProfileTitleAgeRange,
          valueText: context.l10n.hostsHostClubProfileVisiblecopyMinageMaxage(
            minAge: policy.minAge,
            maxAge: policy.maxAge,
          ),
          icon: CatchIcons.cakeOutlined,
        ),
        CatchField.read(
          title: context.l10n.hostsHostClubProfileTitleCancellationPolicy,
          body: policy.cancellationPolicy.attendeeSummary,
          valueText: policy.cancellationPolicy.title,
          icon: CatchIcons.eventBusyOutlined,
        ),
      ],
    );
  }
}
