part of '../host_operations_screen.dart';

abstract final class HostClubEditFieldKeys {
  static const organizerType = 'organizerType';
  static const name = 'name';
  static const location = 'location';
  static const area = 'area';
  static const description = 'description';
  static const instagramHandle = 'instagramHandle';
  static const phoneNumber = 'phoneNumber';
  static const email = 'email';
  static const primaryActivityKind = 'primaryActivityKind';
  static const admissionPreset = 'admissionPreset';
  static const ageRange = 'ageRange';
  static const cancellationPolicyId = 'cancellationPolicyId';
}

abstract final class HostClubMediaKeys {
  static const summaryStrip = ValueKey('host-media-summary-strip');
  static const logoTile = ValueKey('host-media-logo-tile');
}

typedef HostClubSettingsNavigation = void Function(Routes route, String clubId);

class HostClubEditTab extends ConsumerStatefulWidget {
  const HostClubEditTab({
    super.key,
    required this.club,
    required this.currentUid,
    required this.isOwner,
    this.initialExpandedField,
    this.onOpenSettingsRoute,
  });

  final Club club;
  final String currentUid;
  final bool isOwner;
  final String? initialExpandedField;
  final HostClubSettingsNavigation? onOpenSettingsRoute;

  @override
  ConsumerState<HostClubEditTab> createState() => _HostClubEditTabState();
}

class _HostClubEditTabState extends ConsumerState<HostClubEditTab> {
  late final CatchFieldAccordion _fieldAccordion;
  late List<_HostClubMediaDraft> _mediaDrafts;
  HostPickedClubLogo? _pickedLogo;
  bool _removeLogoOnSave = false;
  bool _mediaDirty = false;
  bool _mediaCommitInFlight = false;
  bool _mediaAwaitingSnapshot = false;
  int _mediaSourceRevision = 0;
  bool _showMediaError = false;
  Object? _mediaError;
  ValueNotifier<List<OrderedPhotoPreview>>? _mediaManagerPhotos;

  Future<void> _setPublicListingEnabled(bool enabled) async {
    try {
      await HostClubEditController.publicationMutation.run(
        ref,
        (tx) => tx
            .get(hostClubEditControllerProvider)
            .updateClub(
              clubId: widget.club.id,
              patch: UpdateClubPatch(publicListingEnabled: enabled),
            ),
      );
    } catch (_) {
      // The publication card owns the localized mutation error.
    }
  }

  @override
  void initState() {
    super.initState();
    _fieldAccordion = CatchFieldAccordion(
      initialExpanded: widget.initialExpandedField,
    )..addListener(_handleAccordionChanged);
    _resetMediaFromClub();
    _mediaManagerPhotos = ValueNotifier(_visibleMediaPreviews);
  }

  @override
  void didUpdateWidget(covariant HostClubEditTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.club.id != widget.club.id) {
      _setExpandedField(widget.initialExpandedField);
      _resetMediaFromClub();
    } else if (oldWidget.initialExpandedField != widget.initialExpandedField) {
      _setExpandedField(widget.initialExpandedField);
    }
    if (oldWidget.club.clubPhotos != widget.club.clubPhotos ||
        oldWidget.club.profileImageUrl != widget.club.profileImageUrl ||
        oldWidget.club.logoPhoto != widget.club.logoPhoto) {
      _mediaSourceRevision += 1;
      _mediaAwaitingSnapshot = false;
      _resetMediaFromClub();
    }
  }

  @override
  void dispose() {
    _fieldAccordion
      ..removeListener(_handleAccordionChanged)
      ..dispose();
    _mediaManagerPhotos?.dispose();
    super.dispose();
  }

  void _handleAccordionChanged() {
    if (mounted) setState(() {});
  }

  void _setExpandedField(String? fieldName) {
    if (fieldName == null) {
      _fieldAccordion.collapse();
    } else if (_fieldAccordion.expanded != fieldName) {
      _fieldAccordion.toggle(fieldName);
    }
  }

  void _resetMediaFromClub() {
    final drafts = <_HostClubMediaDraft>[
      for (final photo in [
        ...widget.club.clubPhotos,
      ]..sort((a, b) => a.position.compareTo(b.position)))
        _HostExistingClubMediaDraft(photo),
    ];
    _mediaDrafts = drafts;
    _pickedLogo = null;
    _removeLogoOnSave = false;
    _mediaDirty = false;
    _mediaAwaitingSnapshot = false;
    _showMediaError = false;
    _mediaError = null;
    _syncMediaManagerPhotos();
  }

  void _syncMediaManagerPhotos() {
    _mediaManagerPhotos?.value = _visibleMediaPreviews;
  }

  Future<HostPickedClubLogo?> _pickLogo() async {
    final logo = await ref.read(hostClubEditControllerProvider).pickClubLogo();
    if (!mounted || logo == null) return null;
    final previousLogo = _pickedLogo;
    setState(() {
      _pickedLogo = logo;
      _removeLogoOnSave = false;
      _mediaDirty = true;
      _showMediaError = false;
    });
    _syncMediaManagerPhotos();
    if (previousLogo?.uploadedPhoto != null) {
      unawaited(
        ref
            .read(hostClubEditControllerProvider)
            .discardClubMedia(photoInputs: const [], logo: previousLogo),
      );
    }
    return logo;
  }

  Future<void> _pickPhotos() async {
    await _pickAndAppendPhotos();
  }

  Future<List<OrderedPhotoPreview>> _pickPhotosInManager() async {
    final added = await _pickAndAppendPhotos();
    return [for (final draft in added) draft.preview];
  }

  Future<List<_HostPickedClubMediaDraft>> _pickAndAppendPhotos() async {
    final photos = await ref
        .read(hostClubEditControllerProvider)
        .pickClubPhotos();
    if (!mounted || photos.isEmpty) return const [];
    final added = [
      for (final photo in photos) _HostPickedClubMediaDraft(photo),
    ];
    setState(() {
      _mediaDrafts.addAll(added);
      _mediaDirty = true;
      _showMediaError = false;
    });
    _syncMediaManagerPhotos();
    return added;
  }

  List<OrderedPhotoPreview> get _visibleMediaPreviews => _mediaDrafts.isNotEmpty
      ? [for (final draft in _mediaDrafts) draft.preview]
      : [
          if (widget.club.imageUrl case final imageUrl?)
            OrderedPhotoPreview(
              id: 'existing_legacy_club_cover',
              imageUrl: imageUrl,
            ),
        ];

  Future<void> _openMediaManager() async {
    final photos = _visibleMediaPreviews;
    final saved = await Navigator.of(context, rootNavigator: true).push<bool>(
      MaterialPageRoute<bool>(
        fullscreenDialog: true,
        builder: (_) => OrderedPhotoManagerScreen(
          photos: photos,
          onAddPhotos: _pickPhotos,
          onRemovePhoto: _removePhoto,
          onReorderPhoto: _reorderPhoto,
          onRetryPhoto: _retryPhoto,
          onAddPhotosInManager: _pickPhotosInManager,
          photosListenable: _mediaManagerPhotos,
          canAdd: true,
          header: _HostClubLogoManagerHeader(
            imageBytes: _pickedLogo?.bytes,
            existingImageUrl: _removeLogoOnSave
                ? null
                : widget.club.profileImageUrl,
            onPickLogo: _pickLogo,
            onRemoveLogo: _removeLogo,
          ),
          footer: _HostClubMediaManagerActions(
            onSave: _saveMedia,
            errorText: _mediaErrorText,
          ),
          showDoneAction: false,
        ),
      ),
    );
    if (!mounted || saved == true || !_mediaDirty) return;
    await _discardMedia();
  }

  Future<void> _retryPhoto(int index) async {
    if (index < 0 || index >= _mediaDrafts.length) return;
    final draft = _mediaDrafts[index];
    if (draft is! _HostPickedClubMediaDraft || !draft.job.canRetry) {
      return;
    }
    setState(() {
      _mediaDrafts[index] = draft.withJob(const ImageUploadJobState.queued());
      _mediaDirty = true;
    });
    _syncMediaManagerPhotos();
    await _saveMedia();
  }

  Future<void> _removeLogo() async {
    final stagedLogo = _pickedLogo;
    setState(() {
      _pickedLogo = null;
      _removeLogoOnSave = widget.club.profileImageUrl != null;
      _mediaDirty = true;
      _showMediaError = false;
    });
    _syncMediaManagerPhotos();
    if (stagedLogo?.uploadedPhoto != null) {
      await ref
          .read(hostClubEditControllerProvider)
          .discardClubMedia(photoInputs: const [], logo: stagedLogo);
    }
  }

  void _removePhoto(int index) {
    if (index < 0 || index >= _mediaDrafts.length) return;
    final removed = _mediaDrafts[index];
    setState(() {
      _mediaDrafts.removeAt(index);
      _mediaDirty = true;
      _showMediaError = false;
    });
    _syncMediaManagerPhotos();
    if (removed is _HostPickedClubMediaDraft && removed.input.isUploaded) {
      unawaited(
        ref
            .read(hostClubEditControllerProvider)
            .discardClubMedia(photoInputs: [removed.input]),
      );
    }
  }

  void _reorderPhoto(int fromIndex, int toIndex) {
    if (fromIndex == toIndex ||
        fromIndex < 0 ||
        toIndex < 0 ||
        fromIndex >= _mediaDrafts.length ||
        toIndex >= _mediaDrafts.length) {
      return;
    }
    setState(() {
      final moved = _mediaDrafts.removeAt(fromIndex);
      _mediaDrafts.insert(toIndex, moved);
      _mediaDirty = true;
      _showMediaError = false;
    });
    _syncMediaManagerPhotos();
  }

  Future<bool> _saveMedia() async {
    if (!_mediaDirty) return true;
    if (_mediaCommitInFlight) return false;
    final sourceRevision = _mediaSourceRevision;
    _mediaCommitInFlight = true;
    setState(() {
      _showMediaError = false;
      _mediaError = null;
      _mediaDrafts = [
        for (final draft in _mediaDrafts)
          if (draft is _HostPickedClubMediaDraft && !draft.input.isUploaded)
            draft.withJob(const ImageUploadJobState.queued())
          else
            draft,
      ];
    });
    try {
      final result = await HostClubEditController.updateMediaMutation.run(
        ref,
        (tx) => tx
            .get(hostClubEditControllerProvider)
            .updateClubMedia(
              club: widget.club,
              photoInputs: [for (final draft in _mediaDrafts) draft.input],
              logo: _pickedLogo,
              removeLogo: _removeLogoOnSave,
              onProgress: _updateMediaProgress,
            ),
      );
      if (!mounted) return !result.hasFailures;
      setState(() {
        _applyResolvedInputs(result);
        if (result.hasFailures) {
          _mediaAwaitingSnapshot = false;
          _showMediaError = true;
          _mediaError = result.failures.values.first;
          return;
        }
        _mediaDirty = false;
        _removeLogoOnSave = false;
        _mediaAwaitingSnapshot = _mediaSourceRevision == sourceRevision;
        _showMediaError = false;
      });
      _syncMediaManagerPhotos();
      return !result.hasFailures;
    } catch (error) {
      if (!mounted) return false;
      setState(() {
        _mediaDrafts = [
          for (final draft in _mediaDrafts)
            if (draft is _HostPickedClubMediaDraft)
              draft.clearUpload(error)
            else
              draft,
        ];
        if (_pickedLogo != null) {
          _pickedLogo = HostPickedClubLogo(
            id: _pickedLogo!.id,
            image: _pickedLogo!.image,
            bytes: _pickedLogo!.bytes,
          );
        }
        _mediaAwaitingSnapshot = false;
        _showMediaError = true;
        _mediaError = error;
      });
      _syncMediaManagerPhotos();
      return false;
    } finally {
      _mediaCommitInFlight = false;
      if (mounted) setState(() {});
    }
  }

  String? _mediaErrorText(BuildContext context) {
    if (!_showMediaError || _mediaError == null) return null;
    return appErrorMessage(
      _mediaError!,
      l10n: context.l10n,
      context: AppErrorContext.club,
    );
  }

  void _updateMediaProgress(HostClubMediaProgress progress) {
    if (!mounted) return;
    final index = _mediaDrafts.indexWhere((draft) => draft.id == progress.id);
    if (index < 0) return;
    final draft = _mediaDrafts[index];
    if (draft is! _HostPickedClubMediaDraft) return;
    setState(() => _mediaDrafts[index] = draft.withJob(progress.state));
    _syncMediaManagerPhotos();
  }

  void _applyResolvedInputs(HostClubMediaSaveResult result) {
    final resolvedById = {
      for (final input in result.photoInputs ?? const <HostClubMediaInput>[])
        input.id: input,
    };
    _mediaDrafts = [
      for (final draft in _mediaDrafts)
        switch (draft) {
          _HostExistingClubMediaDraft() => draft,
          _HostPickedClubMediaDraft() => draft.withResolvedInput(
            resolvedById[draft.id],
            error: result.failures[draft.id],
          ),
        },
    ];
    _pickedLogo = result.logo;
  }

  Future<void> _discardMedia() async {
    if (_mediaCommitInFlight) return;
    _mediaCommitInFlight = true;
    if (mounted) setState(() {});
    try {
      await ref
          .read(hostClubEditControllerProvider)
          .discardClubMedia(
            photoInputs: [for (final draft in _mediaDrafts) draft.input],
            logo: _pickedLogo,
          );
      if (mounted) setState(_resetMediaFromClub);
    } finally {
      _mediaCommitInFlight = false;
      if (mounted) setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final club = widget.club;
    final updateClubMutation = ref.watch(
      HostClubEditController.updateClubMutation,
    );
    final mediaPending = _mediaCommitInFlight || _mediaAwaitingSnapshot;
    final publicationMutation = ref.watch(
      HostClubEditController.publicationMutation,
    );
    final publicationState = HostClubPublicationState.fromClub(club);
    final publicationBody = switch (publicationState.kind) {
      HostClubPublicationKind.private =>
        context.l10n.hostsHostClubPublicationBodyPrivate,
      HostClubPublicationKind.catchOnly =>
        context.l10n.hostsHostClubPublicationBodyCatchOnly,
      HostClubPublicationKind.websiteOnly =>
        context.l10n.hostsHostClubPublicationBodyWebsiteOnly,
      HostClubPublicationKind.everywhere =>
        context.l10n.hostsHostClubPublicationBodyEverywhere,
    };
    final publicationAction = switch (publicationState.kind) {
      HostClubPublicationKind.private =>
        context.l10n.hostsHostClubPublicationActionMakePublic,
      HostClubPublicationKind.catchOnly =>
        context.l10n.hostsHostClubPublicationActionEnableWebsite,
      HostClubPublicationKind.websiteOnly =>
        context.l10n.hostsHostClubPublicationActionRestoreCatch,
      HostClubPublicationKind.everywhere =>
        context.l10n.hostsHostClubPublicationActionMakePrivate,
    };
    final cityOptions = <_HostClubCityOption>[
      for (final city in defaultCityOptions.where((city) => city.hostCreatable))
        _HostClubCityOption(value: city.effectiveMarketId, label: city.label),
      if (!defaultCityOptions.any(
        (city) => city.hostCreatable && city.effectiveMarketId == club.location,
      ))
        _HostClubCityOption(
          value: club.location,
          label: cityLabel(club.location),
        ),
    ];
    final eventSuccess = club.hostDefaults.eventSuccessForActivity(
      club.hostDefaults.primaryActivityKind,
    );
    final hostCount = club.displayHostProfiles.length;
    final identityRows = _identityRows(context, club, cityOptions);
    final contactRows = _contactRows(context, club);
    final visibleMediaPreviews = _visibleMediaPreviews;
    final hasVisibleLogo =
        _pickedLogo != null ||
        (!_removeLogoOnSave && club.profileImageUrl != null);
    final mediaAssetCount =
        visibleMediaPreviews.length + (hasVisibleLogo ? 1 : 0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (updateClubMutation.hasError) ...[
          CatchMutationErrorBanner(
            mutation: updateClubMutation,
            errorContext: AppErrorContext.club,
          ),
          gapH12,
        ],
        if (widget.isOwner)
          CatchSection.contained(
            title: context.l10n.hostsHostClubPublicationTitle,
            tone: CatchSurfaceTone.primarySoft,
            elevation: CatchSurfaceElevation.none,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _HostClubPublicationChannelRow(
                  key: const ValueKey('host-publication-catch-app'),
                  label: context.l10n.hostsHostClubPublicationChannelCatch,
                  status: publicationState.catchAppVisible
                      ? context.l10n.hostsHostClubPublicationStatusVisible
                      : context.l10n.hostsHostClubPublicationStatusHidden,
                  visible: publicationState.catchAppVisible,
                ),
                gapH8,
                _HostClubPublicationChannelRow(
                  key: const ValueKey('host-publication-website'),
                  label: context.l10n.hostsHostClubPublicationChannelWebsite,
                  status: publicationState.websiteEnabled
                      ? context.l10n.hostsHostClubPublicationStatusEnabled
                      : context.l10n.hostsHostClubPublicationStatusNotEnabled,
                  visible: publicationState.websiteEnabled,
                ),
                gapH16,
                Text(
                  publicationBody,
                  style: CatchTextStyles.supporting(
                    context,
                    color: CatchTokens.of(context).ink2,
                  ),
                ),
                gapH12,
                CatchButton(
                  label: publicationAction,
                  onPressed: publicationMutation.isPending
                      ? null
                      : () => unawaited(
                          _setPublicListingEnabled(
                            publicationState.targetPublicListingEnabled,
                          ),
                        ),
                  isLoading: publicationMutation.isPending,
                  variant:
                      publicationState.kind ==
                          HostClubPublicationKind.everywhere
                      ? CatchButtonVariant.secondary
                      : CatchButtonVariant.primary,
                  fullWidth: true,
                ),
                if (publicationMutation.hasError) ...[
                  gapH8,
                  CatchFieldSupportRow(
                    text: mutationErrorMessage(
                      publicationMutation,
                      l10n: context.l10n,
                    ),
                    color: CatchTokens.of(context).danger,
                    showErrorIcon: true,
                  ),
                ],
              ],
            ),
          ),
        CatchSection.fieldRows(
          title: context.l10n.hostsHostClubProfileTitleMedia,
          first: !widget.isOwner,
          count: context.l10n.coreOrderedPhotoPickerSubtitlePhotoCount(
            count: mediaAssetCount,
          ),
          trailing: CatchTextButton(
            key: OrderedPhotoPickerKeys.manageAction,
            label: context.l10n.hostsHostClubEditTabActionManageImages,
            onPressed: mediaPending
                ? null
                : () => unawaited(_openMediaManager()),
            padding: EdgeInsets.zero,
          ),
          child: Padding(
            padding: CatchInsets.fieldSectionChildTop,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                HostClubMediaSummary(
                  logoImageBytes: _pickedLogo?.bytes,
                  logoImageUrl: _removeLogoOnSave ? null : club.profileImageUrl,
                  photos: visibleMediaPreviews,
                  logoBadgeLabel: context.l10n.hostsHostClubEditTabBadgeLogo,
                  addPhotosLabel: context
                      .l10n
                      .hostsCreateClubPhotosPickerVisiblecopyAddPhotos,
                  onManageMedia: mediaPending
                      ? null
                      : () => unawaited(_openMediaManager()),
                ),
              ],
            ),
          ),
        ),
        CatchFormRowList<UpdateClubPatch>(
          title: context.l10n.hostsHostClubProfileTitleIdentity,
          rows: identityRows,
          accordion: _fieldAccordion,
          savePatch: _savePatch,
          errorText: _errorText,
        ),
        CatchFormRowList<UpdateClubPatch>(
          title: context.l10n.hostsHostClubProfileTitleContact,
          rows: contactRows,
          accordion: _fieldAccordion,
          savePatch: _savePatch,
          errorText: _errorText,
        ),
        CatchSection.fieldRows(
          title: context.l10n.hostsHostClubEditTabTitleClubSettings,
          children: [
            CatchField.nav(
              key: const ValueKey('host-club-settings-event-defaults'),
              title: context.l10n.hostsHostClubEditTabLabelEventDefaults,
              valueText: club.hostDefaults.primaryActivityKind.label,
              icon: CatchIcons.eventOutlined,
              onTap: () => _openSpoke(Routes.hostClubEventDefaultsScreen),
            ),
            CatchField.nav(
              key: const ValueKey('host-club-settings-live-guide'),
              title: context.l10n.hostsHostClubEditTabLabelLiveEventGuide,
              valueText: eventSuccess.enabled
                  ? context.l10n.hostsHostClubEditTabValueOn
                  : context.l10n.hostsHostClubEditTabValueOff,
              icon: CatchIcons.autoAwesomeOutlined,
              onTap: () => _openSpoke(Routes.hostClubLiveGuideScreen),
            ),
            if (widget.isOwner)
              CatchField.nav(
                key: const ValueKey('host-club-settings-payments'),
                title: context.l10n.hostsHostClubEditTabLabelPayments,
                icon: CatchIcons.paymentsOutlined,
                onTap: () => _openSpoke(Routes.hostClubPaymentsScreen),
              ),
            CatchField.nav(
              key: const ValueKey('host-club-settings-host-team'),
              title: context.l10n.hostsHostClubEditTabLabelHostTeam,
              valueText: context.l10n.hostsHostClubEditTabValueHostCount(
                count: hostCount,
              ),
              icon: CatchIcons.groupAddOutlined,
              onTap: () => _openSpoke(Routes.hostClubTeamScreen),
            ),
          ],
        ),
      ],
    );
  }

  List<CatchFormRowDescriptor<UpdateClubPatch>> _identityRows(
    BuildContext context,
    Club club,
    List<_HostClubCityOption> cityOptions,
  ) {
    final organizerTypeOptions = [
      for (final type in OrganizerType.values)
        _HostOrganizerTypeOption(
          value: type,
          label: _hostOrganizerTypeLabel(context, type),
        ),
    ];
    final selectedOrganizerType = organizerTypeOptions.firstWhere(
      (option) => option.value == club.organizerType,
    );
    if (!widget.isOwner) {
      return [
        CatchFormReadRow<UpdateClubPatch>(
          id: HostClubEditFieldKeys.organizerType,
          icon: CatchIcons.groups3Outlined,
          label: context.l10n.hostsOrganizerTypeLabel,
          body: selectedOrganizerType.label,
        ),
        CatchFormReadRow<UpdateClubPatch>(
          id: HostClubEditFieldKeys.name,
          icon: CatchIcons.groups3Outlined,
          label: context.l10n.hostsHostClubProfileLabelClubName,
          body: club.name,
        ),
        CatchFormReadRow<UpdateClubPatch>(
          id: HostClubEditFieldKeys.location,
          icon: CatchIcons.locationCityOutlined,
          label: context.l10n.hostsHostClubProfileLabelCity,
          body: cityLabel(club.location),
        ),
        CatchFormReadRow<UpdateClubPatch>(
          id: HostClubEditFieldKeys.area,
          icon: CatchIcons.locationOnOutlined,
          label: context.l10n.hostsHostClubProfileLabelAreaNeighbourhood,
          body: _valueOrDash(club.area),
        ),
        CatchFormReadRow<UpdateClubPatch>(
          id: HostClubEditFieldKeys.description,
          icon: CatchIcons.descriptionOutlined,
          label: context.l10n.hostsHostClubProfileLabelDescription,
          body: _valueOrDash(club.description),
        ),
      ];
    }

    return [
      CatchFormSingleChoiceRow<UpdateClubPatch, _HostOrganizerTypeOption>(
        id: HostClubEditFieldKeys.organizerType,
        icon: CatchIcons.groups3Outlined,
        label: context.l10n.hostsOrganizerTypeLabel,
        values: organizerTypeOptions,
        value: selectedOrganizerType,
        allowEmptySelection: false,
        contract: CatchContractConstraints.updateClubPatchOrganizerType,
        contractValue: (option) => option.value.name,
        patchForValue: (value) => UpdateClubPatch(organizerType: value!.value),
      ),
      CatchFormTextRow<UpdateClubPatch>(
        id: HostClubEditFieldKeys.name,
        icon: CatchIcons.groups3Outlined,
        label: context.l10n.hostsHostClubProfileLabelClubName,
        currentValue: club.name,
        currentFieldValue: club.name,
        placeholder: club.name,
        normalizeInput: _normalizeSingleLineInput,
        contract: CatchContractConstraints.updateClubPatchName,
        patchForValue: (value) => UpdateClubPatch(name: value as String),
      ),
      CatchFormSingleChoiceRow<UpdateClubPatch, _HostClubCityOption>(
        id: HostClubEditFieldKeys.location,
        icon: CatchIcons.locationCityOutlined,
        label: context.l10n.hostsHostClubProfileLabelCity,
        values: cityOptions,
        value: cityOptions.firstWhere((city) => city.value == club.location),
        allowEmptySelection: false,
        contract: CatchContractConstraints.updateClubPatchLocation,
        contractValue: (option) => option.value,
        patchForValue: (value) => UpdateClubPatch(location: value!.value),
      ),
      CatchFormTextRow<UpdateClubPatch>(
        id: HostClubEditFieldKeys.area,
        icon: CatchIcons.locationOnOutlined,
        label: context.l10n.hostsHostClubProfileLabelAreaNeighbourhood,
        currentValue: club.area,
        currentFieldValue: club.area,
        placeholder: _valueOrDash(club.area),
        normalizeInput: _normalizeSingleLineInput,
        contract: CatchContractConstraints.updateClubPatchArea,
        patchForValue: (value) => UpdateClubPatch(area: value as String),
      ),
      CatchFormTextRow<UpdateClubPatch>(
        id: HostClubEditFieldKeys.description,
        icon: CatchIcons.descriptionOutlined,
        label: context.l10n.hostsHostClubProfileLabelDescription,
        currentValue: club.description,
        currentFieldValue: club.description,
        placeholder: _valueOrDash(club.description),
        keyboardType: TextInputType.multiline,
        maxLines: 3,
        minLines: 2,
        normalizeInput: _normalizeMultilineInput,
        contract: CatchContractConstraints.updateClubPatchDescription,
        patchForValue: (value) => UpdateClubPatch(description: value as String),
      ),
    ];
  }

  List<CatchFormRowDescriptor<UpdateClubPatch>> _contactRows(
    BuildContext context,
    Club club,
  ) {
    if (!widget.isOwner) {
      return [
        CatchFormReadRow<UpdateClubPatch>(
          id: HostClubEditFieldKeys.instagramHandle,
          icon: CatchIcons.alternateEmailRounded,
          label: context.l10n.hostsHostClubProfileLabelInstagram,
          body: _valueOrDash(club.instagramHandle),
        ),
        CatchFormReadRow<UpdateClubPatch>(
          id: HostClubEditFieldKeys.phoneNumber,
          icon: CatchIcons.phoneOutlined,
          label: context.l10n.hostsHostClubProfileLabelPhone,
          body: _valueOrDash(club.phoneNumber),
        ),
        CatchFormReadRow<UpdateClubPatch>(
          id: HostClubEditFieldKeys.email,
          icon: CatchIcons.emailOutlined,
          label: context.l10n.hostsHostClubProfileLabelEmail,
          body: _valueOrDash(club.email),
        ),
      ];
    }

    return [
      CatchFormTextRow<UpdateClubPatch>(
        id: HostClubEditFieldKeys.instagramHandle,
        icon: CatchIcons.alternateEmailRounded,
        label: context.l10n.hostsHostClubProfileLabelInstagram,
        currentValue: club.instagramHandle ?? '',
        currentFieldValue: club.instagramHandle,
        placeholder: context.l10n.hostsHostClubProfilePlaceholderYourclub,
        keyboardType: TextInputType.text,
        normalizeInput: _normalizeSingleLineInput,
        toFieldValue: _optionalStringFieldValue,
        contract: CatchContractConstraints.updateClubPatchInstagramHandle,
        patchForValue: (value) => UpdateClubPatch(instagramHandle: value),
      ),
      CatchFormTextRow<UpdateClubPatch>(
        id: HostClubEditFieldKeys.phoneNumber,
        icon: CatchIcons.phoneOutlined,
        label: context.l10n.hostsHostClubProfileLabelPhone,
        currentValue: club.phoneNumber ?? '',
        currentFieldValue: club.phoneNumber,
        placeholder: '98765 43210',
        keyboardType: TextInputType.phone,
        normalizeInput: _normalizeSingleLineInput,
        toFieldValue: _optionalStringFieldValue,
        contract: CatchContractConstraints.updateClubPatchPhoneNumber,
        patchForValue: (value) => UpdateClubPatch(phoneNumber: value),
      ),
      CatchFormTextRow<UpdateClubPatch>(
        id: HostClubEditFieldKeys.email,
        icon: CatchIcons.emailOutlined,
        label: context.l10n.hostsHostClubProfileLabelEmail,
        currentValue: club.email ?? '',
        currentFieldValue: club.email,
        placeholder:
            context.l10n.hostsHostClubProfilePlaceholderHelloYourclubCom,
        keyboardType: TextInputType.emailAddress,
        normalizeInput: _normalizeSingleLineInput,
        validator: (value) => _optionalEmailValidator(value, context.l10n),
        toFieldValue: _optionalStringFieldValue,
        contract: CatchContractConstraints.updateClubPatchEmail,
        patchForValue: (value) => UpdateClubPatch(email: value),
      ),
    ];
  }

  Future<bool> _savePatch(UpdateClubPatch patch) async {
    if (patch.isEmpty) return true;
    if (ref.read(HostClubEditController.updateClubMutation).isPending) {
      return false;
    }
    await HostClubEditController.updateClubMutation.run(
      ref,
      (tx) => tx
          .get(hostClubEditControllerProvider)
          .updateClub(clubId: widget.club.id, patch: patch),
    );
    return true;
  }

  String _errorText(BuildContext context, Object error) =>
      appErrorMessage(error, l10n: context.l10n, context: AppErrorContext.club);

  void _openSpoke(Routes route) {
    final onOpenSettingsRoute = widget.onOpenSettingsRoute;
    if (onOpenSettingsRoute != null) {
      onOpenSettingsRoute(route, widget.club.id);
      return;
    }
    context.pushNamed(route.name, queryParameters: {'clubId': widget.club.id});
  }
}

class _HostClubPublicationChannelRow extends StatelessWidget {
  const _HostClubPublicationChannelRow({
    super.key,
    required this.label,
    required this.status,
    required this.visible,
  });

  final String label;
  final String status;
  final bool visible;

  @override
  Widget build(BuildContext context) {
    final tokens = CatchTokens.of(context);
    return Semantics(
      label: '$label: $status',
      child: ExcludeSemantics(
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: CatchTextStyles.labelM(context, color: tokens.ink),
              ),
            ),
            gapW12,
            CatchBadge.functional(
              label: status,
              tone: visible ? CatchBadgeTone.success : CatchBadgeTone.neutral,
            ),
          ],
        ),
      ),
    );
  }
}

class HostClubMediaSummary extends StatelessWidget {
  const HostClubMediaSummary({
    super.key,
    required this.logoImageBytes,
    required this.logoImageUrl,
    required this.photos,
    required this.logoBadgeLabel,
    required this.addPhotosLabel,
    required this.onManageMedia,
  });

  final Uint8List? logoImageBytes;
  final String? logoImageUrl;
  final List<OrderedPhotoPreview> photos;
  final String logoBadgeLabel;
  final String addPhotosLabel;
  final VoidCallback? onManageMedia;

  @override
  Widget build(BuildContext context) {
    const extent = CatchLayout.hostMediaThumbnailExtent;

    return SizedBox(
      key: HostClubMediaKeys.summaryStrip,
      height: extent,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: photos.length + 2,
        separatorBuilder: (_, _) => gapW8,
        itemBuilder: (_, index) {
          if (index == 0) {
            return SizedBox.square(
              dimension: extent,
              child: Stack(
                key: HostClubMediaKeys.logoTile,
                fit: StackFit.expand,
                children: [
                  ClubProfileImageTile(
                    imageBytes: logoImageBytes,
                    existingImageUrl: logoImageUrl,
                    onTap: onManageMedia,
                    size: extent,
                  ),
                  Positioned(
                    top: CatchSpacing.s1,
                    left: CatchSpacing.s1,
                    child: IgnorePointer(
                      child: _HostClubMediaRoleBadge(label: logoBadgeLabel),
                    ),
                  ),
                ],
              ),
            );
          }
          if (index == photos.length + 1) {
            return SizedBox.square(
              dimension: extent,
              child: OrderedPhotoAddTile(
                label: addPhotosLabel,
                onTap: onManageMedia,
              ),
            );
          }

          final photoIndex = index - 1;
          final photo = photos[photoIndex];
          final isCover = photoIndex == 0;
          return SizedBox(
            width:
                extent *
                (isCover
                    ? CatchAspectRatio.organizerCover
                    : CatchAspectRatio.organizerGallery),
            height: extent,
            child: OrderedPhotoTile(
              key: ValueKey('host-media-summary-photo-${photo.id}'),
              photo: photo,
              index: photoIndex,
              canReorder: false,
              showCoverBadge: isCover,
              showReorderHandle: false,
              statusActionKey: isCover
                  ? OrderedPhotoPickerKeys.coverRetryAction
                  : null,
            ),
          );
        },
      ),
    );
  }
}

class _HostClubMediaRoleBadge extends StatelessWidget {
  const _HostClubMediaRoleBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return CatchSurface.tinted(
      radius: CatchRadius.pill,
      backgroundColor: t.ink.withValues(
        alpha: CatchOpacity.photoSlotDeleteChrome,
      ),
      padding: CatchInsets.mediaRoleBadgeContent,
      child: Text(
        label,
        style: CatchTextStyles.monoLabel(context, color: t.surface),
      ),
    );
  }
}

class _HostClubLogoManagerHeader extends StatefulWidget {
  const _HostClubLogoManagerHeader({
    required this.imageBytes,
    required this.existingImageUrl,
    required this.onPickLogo,
    required this.onRemoveLogo,
  });

  final Uint8List? imageBytes;
  final String? existingImageUrl;
  final Future<HostPickedClubLogo?> Function() onPickLogo;
  final Future<void> Function() onRemoveLogo;

  @override
  State<_HostClubLogoManagerHeader> createState() =>
      _HostClubLogoManagerHeaderState();
}

class _HostClubLogoManagerHeaderState
    extends State<_HostClubLogoManagerHeader> {
  late Uint8List? _imageBytes;
  late String? _existingImageUrl;

  @override
  void initState() {
    super.initState();
    _imageBytes = widget.imageBytes;
    _existingImageUrl = widget.existingImageUrl;
  }

  Future<void> _pickLogo() async {
    final logo = await widget.onPickLogo();
    if (!mounted || logo == null) return;
    setState(() {
      _imageBytes = logo.bytes;
      _existingImageUrl = null;
    });
  }

  Future<void> _removeLogo() async {
    await widget.onRemoveLogo();
    if (!mounted) return;
    setState(() {
      _imageBytes = null;
      _existingImageUrl = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CreateClubProfileImagePicker(
      imageBytes: _imageBytes,
      existingImageUrl: _existingImageUrl,
      onTap: () => unawaited(_pickLogo()),
      onRemove: _imageBytes != null || _existingImageUrl != null
          ? () => unawaited(_removeLogo())
          : null,
      variant: CreateClubProfileImagePickerVariant.editLogo,
    );
  }
}

class _HostClubMediaManagerActions extends StatefulWidget {
  const _HostClubMediaManagerActions({
    required this.onSave,
    required this.errorText,
  });

  final Future<bool> Function() onSave;
  final String? Function(BuildContext context) errorText;

  @override
  State<_HostClubMediaManagerActions> createState() =>
      _HostClubMediaManagerActionsState();
}

class _HostClubMediaManagerActionsState
    extends State<_HostClubMediaManagerActions> {
  bool _saving = false;
  bool _showError = false;

  Future<void> _save() async {
    if (_saving) return;
    setState(() {
      _saving = true;
      _showError = false;
    });
    final saved = await widget.onSave();
    if (!mounted) return;
    if (saved) {
      Navigator.of(context).pop(true);
      return;
    }
    setState(() {
      _saving = false;
      _showError = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final error = _showError ? widget.errorText(context) : null;
    return SafeArea(
      top: false,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: CatchTokens.of(context).bg,
          border: Border(top: BorderSide(color: CatchTokens.of(context).line)),
        ),
        child: Padding(
          padding: CatchInsets.pageHorizontal.copyWith(
            top: CatchSpacing.s2,
            bottom: CatchSpacing.s2,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                key: const ValueKey('host-media-action-bar'),
                children: [
                  Expanded(
                    child: CatchButton(
                      key: const ValueKey('host-media-discard'),
                      label:
                          context.l10n.hostsHostClubEditTabActionDiscardMedia,
                      onPressed: _saving
                          ? null
                          : () => Navigator.of(context).pop(false),
                      variant: CatchButtonVariant.secondary,
                      fullWidth: true,
                    ),
                  ),
                  gapW8,
                  Expanded(
                    child: CatchButton(
                      key: const ValueKey('host-media-save'),
                      label: context.l10n.hostsHostClubEditTabActionSaveMedia,
                      onPressed: _saving ? null : () => unawaited(_save()),
                      isLoading: _saving,
                      fullWidth: true,
                    ),
                  ),
                ],
              ),
              if (error != null) ...[
                gapH8,
                CatchFieldSupportRow(
                  text: error,
                  color: CatchTokens.of(context).danger,
                  showErrorIcon: true,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

final class _HostClubCityOption implements Labelled {
  const _HostClubCityOption({required this.value, required this.label});

  final String value;
  @override
  final String label;
}

final class _HostOrganizerTypeOption implements Labelled {
  const _HostOrganizerTypeOption({required this.value, required this.label});

  final OrganizerType value;
  @override
  final String label;
}

String _hostOrganizerTypeLabel(BuildContext context, OrganizerType type) =>
    switch (type) {
      OrganizerType.club => context.l10n.hostsOrganizerTypeClub,
      OrganizerType.community => context.l10n.hostsOrganizerTypeCommunity,
      OrganizerType.individual => context.l10n.hostsOrganizerTypeIndividual,
      OrganizerType.eventProducer =>
        context.l10n.hostsOrganizerTypeEventProducer,
      OrganizerType.venue => context.l10n.hostsOrganizerTypeVenue,
      OrganizerType.brand => context.l10n.hostsOrganizerTypeBrand,
    };

sealed class _HostClubMediaDraft {
  const _HostClubMediaDraft();

  String get id;
  OrderedPhotoPreview get preview;
  HostClubMediaInput get input;
}

final class _HostExistingClubMediaDraft extends _HostClubMediaDraft {
  const _HostExistingClubMediaDraft(this.photo);

  final UploadedPhoto photo;

  @override
  String get id => photo.id;

  @override
  OrderedPhotoPreview get preview => OrderedPhotoPreview(
    id: 'existing-${photo.id}',
    imageUrl: photo.thumbnailOrUrl,
  );

  @override
  HostClubMediaInput get input => HostExistingClubPhotoInput(photo);
}

final class _HostPickedClubMediaDraft extends _HostClubMediaDraft {
  const _HostPickedClubMediaDraft(
    this.photo, {
    this.uploadedPhoto,
    this.job = const ImageUploadJobState.queued(),
  });

  final HostPickedClubPhoto photo;
  final UploadedPhoto? uploadedPhoto;
  final ImageUploadJobState job;

  @override
  String get id => photo.id;

  _HostPickedClubMediaDraft withJob(ImageUploadJobState job) =>
      _HostPickedClubMediaDraft(photo, uploadedPhoto: uploadedPhoto, job: job);

  _HostPickedClubMediaDraft withResolvedInput(
    HostClubMediaInput? resolved, {
    Object? error,
  }) {
    final uploaded = switch (resolved) {
      HostNewClubPhotoInput(:final uploadedPhoto) => uploadedPhoto,
      _ => uploadedPhoto,
    };
    return _HostPickedClubMediaDraft(
      photo,
      uploadedPhoto: uploaded,
      job: error == null
          ? const ImageUploadJobState(stage: ImageUploadJobStage.complete)
          : ImageUploadJobState(
              stage: ImageUploadJobStage.failed,
              error: error,
            ),
    );
  }

  _HostPickedClubMediaDraft clearUpload(Object error) =>
      _HostPickedClubMediaDraft(
        photo,
        job: ImageUploadJobState(
          stage: ImageUploadJobStage.failed,
          error: error,
        ),
      );

  @override
  OrderedPhotoPreview get preview => OrderedPhotoPreview(
    id: id,
    bytes: photo.bytes,
    status: switch (job.stage) {
      ImageUploadJobStage.failed => OrderedPhotoStatus.failed,
      ImageUploadJobStage.preparing ||
      ImageUploadJobStage.uploading ||
      ImageUploadJobStage.attaching => OrderedPhotoStatus.uploading,
      ImageUploadJobStage.queued ||
      ImageUploadJobStage.picking => OrderedPhotoStatus.queued,
      _ => OrderedPhotoStatus.ready,
    },
    progress: job.progress,
    error: job.error,
  );

  @override
  HostNewClubPhotoInput get input => HostNewClubPhotoInput(
    id: id,
    image: photo.image,
    uploadedPhoto: uploadedPhoto,
  );
}
