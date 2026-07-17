part of '../host_operations_screen.dart';

abstract final class HostClubEditFieldKeys {
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
  late List<_HostClubMediaDraft> _committedMediaDrafts;
  HostPickedClubLogo? _pickedLogo;
  Timer? _reorderDebounce;
  bool _mediaCommitInFlight = false;
  bool _mediaAwaitingSnapshot = false;
  int _mediaSourceRevision = 0;
  bool _showMediaError = false;

  @override
  void initState() {
    super.initState();
    _fieldAccordion = CatchFieldAccordion(
      initialExpanded: widget.initialExpandedField,
    )..addListener(_handleAccordionChanged);
    _resetMediaFromClub();
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
    _reorderDebounce?.cancel();
    _fieldAccordion
      ..removeListener(_handleAccordionChanged)
      ..dispose();
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
    _committedMediaDrafts = [...drafts];
    _pickedLogo = null;
    _mediaAwaitingSnapshot = false;
    _showMediaError = false;
  }

  Future<void> _pickLogo() async {
    final logo = await ref.read(hostClubEditControllerProvider).pickClubLogo();
    if (!mounted || logo == null) return;
    setState(() => _pickedLogo = logo);
    await _commitMedia(logo: logo);
  }

  Future<void> _pickPhotos() async {
    final remaining = maxClubPhotos - _mediaDrafts.length;
    if (remaining <= 0) return;
    final photos = await ref
        .read(hostClubEditControllerProvider)
        .pickClubPhotos(limit: remaining);
    if (!mounted || photos.isEmpty) return;
    _reorderDebounce?.cancel();
    setState(() {
      _mediaDrafts.addAll(
        photos.map(
          (photo) => _HostPickedClubMediaDraft(
            '${DateTime.now().microsecondsSinceEpoch}-${photo.image.name}',
            photo,
          ),
        ),
      );
    });
    await _commitMedia(commitPhotos: true);
  }

  void _removePhoto(int index) {
    if (index < 0 || index >= _mediaDrafts.length) return;
    _reorderDebounce?.cancel();
    setState(() => _mediaDrafts.removeAt(index));
    unawaited(_commitMedia(commitPhotos: true));
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
    });
    _reorderDebounce?.cancel();
    _reorderDebounce = Timer(CatchMotion.mediaReorderDebounce, () {
      if (mounted) unawaited(_commitMedia(commitPhotos: true));
    });
  }

  Future<void> _commitMedia({
    bool commitPhotos = false,
    HostPickedClubLogo? logo,
  }) async {
    if (_mediaCommitInFlight) return;
    final sourceRevision = _mediaSourceRevision;
    _mediaCommitInFlight = true;
    setState(() => _showMediaError = false);
    try {
      await HostClubEditController.updateMediaMutation.run(
        ref,
        (tx) => tx
            .get(hostClubEditControllerProvider)
            .updateClubMedia(
              club: widget.club,
              photoInputs: commitPhotos
                  ? [for (final draft in _mediaDrafts) draft.input]
                  : null,
              logo: logo,
            ),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() {
        if (commitPhotos) _mediaDrafts = [..._committedMediaDrafts];
        if (logo != null) _pickedLogo = null;
        _mediaAwaitingSnapshot = false;
        _showMediaError = true;
      });
      return;
    } finally {
      _mediaCommitInFlight = false;
      if (mounted) setState(() {});
    }
    if (!mounted) return;
    setState(() {
      if (commitPhotos) _committedMediaDrafts = [..._mediaDrafts];
      if (logo != null) _pickedLogo = null;
      _mediaAwaitingSnapshot = _mediaSourceRevision == sourceRevision;
      _showMediaError = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final club = widget.club;
    final mediaMutation = ref.watch(HostClubEditController.updateMediaMutation);
    final mediaPending =
        mediaMutation.isPending ||
        _mediaCommitInFlight ||
        _mediaAwaitingSnapshot;
    final mediaError = _showMediaError && mediaMutation.hasError
        ? mutationErrorMessage(
            mediaMutation,
            l10n: context.l10n,
            context: AppErrorContext.club,
          )
        : null;
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CatchSection.fieldRows(
          title: context.l10n.hostsHostClubProfileTitleMedia,
          count: context.l10n
              .hostsHostClubProfileVisiblecopyCompletedcountOfMaximumclubphotocountAdded(
                completedCount: _mediaDrafts.length,
                maximumClubPhotoCount: maxClubPhotos,
              ),
          child: Padding(
            padding: CatchInsets.fieldSectionChildTop,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CreateClubProfileImagePicker(
                  imageBytes: _pickedLogo?.bytes,
                  existingImageUrl: club.profileImageUrl,
                  onTap: mediaPending ? null : _pickLogo,
                  variant: CreateClubProfileImagePickerVariant.editLogo,
                ),
                gapH20,
                CreateClubPhotosPicker(
                  photos: [for (final draft in _mediaDrafts) draft.preview],
                  existingImageUrl: _mediaDrafts.isEmpty ? club.imageUrl : null,
                  onAddPhotos:
                      mediaPending || _mediaDrafts.length >= maxClubPhotos
                      ? null
                      : _pickPhotos,
                  onRemovePhoto: mediaPending ? null : _removePhoto,
                  onReorderPhoto: mediaPending ? null : _reorderPhoto,
                  variant: CreateClubPhotosPickerVariant.editStrip,
                ),
                if (mediaError != null) ...[
                  gapH12,
                  CatchFieldSupportRow(
                    text: mediaError,
                    color: CatchTokens.of(context).danger,
                    showErrorIcon: true,
                  ),
                ],
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
    if (!widget.isOwner) {
      return [
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
      CatchFormTextRow<UpdateClubPatch>(
        id: HostClubEditFieldKeys.name,
        icon: CatchIcons.groups3Outlined,
        label: context.l10n.hostsHostClubProfileLabelClubName,
        currentValue: club.name,
        currentFieldValue: club.name,
        placeholder: club.name,
        explicitSave: true,
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
        patchForValue: (value) => UpdateClubPatch(location: value!.value),
      ),
      CatchFormTextRow<UpdateClubPatch>(
        id: HostClubEditFieldKeys.area,
        icon: CatchIcons.locationOnOutlined,
        label: context.l10n.hostsHostClubProfileLabelAreaNeighbourhood,
        currentValue: club.area,
        currentFieldValue: club.area,
        placeholder: _valueOrDash(club.area),
        explicitSave: true,
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
        explicitSave: true,
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
        explicitSave: true,
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
        explicitSave: true,
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
        explicitSave: true,
        keyboardType: TextInputType.emailAddress,
        normalizeInput: _normalizeSingleLineInput,
        validator: _optionalEmailValidator,
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

final class _HostClubCityOption implements Labelled {
  const _HostClubCityOption({required this.value, required this.label});

  final String value;
  @override
  final String label;
}

sealed class _HostClubMediaDraft {
  const _HostClubMediaDraft();

  OrderedPhotoPreview get preview;
  HostClubMediaInput get input;
}

final class _HostExistingClubMediaDraft extends _HostClubMediaDraft {
  const _HostExistingClubMediaDraft(this.photo);

  final UploadedPhoto photo;

  @override
  OrderedPhotoPreview get preview => OrderedPhotoPreview(
    id: 'existing-${photo.id}',
    imageUrl: photo.thumbnailOrUrl,
  );

  @override
  HostClubMediaInput get input => HostExistingClubPhotoInput(photo);
}

final class _HostPickedClubMediaDraft extends _HostClubMediaDraft {
  const _HostPickedClubMediaDraft(this.id, this.photo);

  final String id;
  final HostPickedClubPhoto photo;

  @override
  OrderedPhotoPreview get preview =>
      OrderedPhotoPreview(id: id, bytes: photo.bytes);

  @override
  HostClubMediaInput get input => HostNewClubPhotoInput(photo.image);
}
