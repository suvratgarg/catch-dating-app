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
    const cityFieldName = HostClubEditFieldKeys.location;
    final cityOptions = <HostInlineOption<String>>[
      for (final city in defaultCityOptions.where((city) => city.hostCreatable))
        HostInlineOption(value: city.effectiveMarketId, label: city.label),
      if (!defaultCityOptions.any(
        (city) => city.hostCreatable && city.effectiveMarketId == club.location,
      ))
        HostInlineOption(value: club.location, label: cityLabel(club.location)),
    ];
    final cityEntry = !widget.isOwner
        ? CatchField.read(
            title: context.l10n.hostsHostClubProfileLabelCity,
            valueText: cityLabel(club.location),
            icon: CatchIcons.locationCityOutlined,
          )
        : HostInlineOptionEditor<String>(
            key: const ValueKey('host-inline-location'),
            clubId: club.id,
            icon: CatchIcons.locationCityOutlined,
            label: context.l10n.hostsHostClubProfileLabelCity,
            value: cityLabel(club.location),
            currentValue: club.location,
            fieldName: cityFieldName,
            isExpanded: _fieldAccordion.isExpanded(cityFieldName),
            options: cityOptions,
            patchForValue: (value) => UpdateClubPatch(location: value),
            onTap: () => _fieldAccordion.toggle(cityFieldName),
            onSaved: _fieldAccordion.collapse,
            onCancel: _fieldAccordion.collapse,
          );
    final eventSuccess = club.hostDefaults.eventSuccessForActivity(
      club.hostDefaults.primaryActivityKind,
    );
    final hostCount = club.displayHostProfiles.length;

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
        CatchSection.fieldRows(
          title: context.l10n.hostsHostClubProfileTitleIdentity,
          children: [
            HostClubInlineTextEntry._(
              club: club,
              isOwner: widget.isOwner,
              accordion: _fieldAccordion,
              fieldName: HostClubEditFieldKeys.name,
              label: context.l10n.hostsHostClubProfileLabelClubName,
              value: club.name,
              currentValue: club.name,
              icon: CatchIcons.groups3Outlined,
              validator: _requiredHostFieldValidator(
                context.l10n.hostsHostClubProfileVisiblecopyClubName,
              ),
              normalizeInput: _normalizeSingleLineInput,
              patchForValue: (value) => UpdateClubPatch(name: value as String),
            ),
            cityEntry,
            HostClubInlineTextEntry._(
              club: club,
              isOwner: widget.isOwner,
              accordion: _fieldAccordion,
              fieldName: HostClubEditFieldKeys.area,
              label: context.l10n.hostsHostClubProfileLabelAreaNeighbourhood,
              value: _valueOrDash(club.area),
              currentValue: club.area,
              icon: CatchIcons.locationOnOutlined,
              validator: _requiredHostFieldValidator(
                context.l10n.hostsHostClubProfileVisiblecopyAreaNeighbourhood,
              ),
              normalizeInput: _normalizeSingleLineInput,
              patchForValue: (value) => UpdateClubPatch(area: value as String),
            ),
            HostClubInlineTextEntry._(
              club: club,
              isOwner: widget.isOwner,
              accordion: _fieldAccordion,
              fieldName: HostClubEditFieldKeys.description,
              label: context.l10n.hostsHostClubProfileLabelDescription,
              value: _valueOrDash(club.description),
              currentValue: club.description,
              icon: CatchIcons.descriptionOutlined,
              maxLines: 3,
              minLines: 2,
              maxLength: 280,
              showCounter: true,
              keyboardType: TextInputType.multiline,
              validator: _requiredHostFieldValidator(
                context.l10n.hostsHostClubProfileVisiblecopyDescription8d3ca8,
              ),
              normalizeInput: _normalizeMultilineInput,
              patchForValue: (value) =>
                  UpdateClubPatch(description: value as String),
            ),
          ],
        ),
        CatchSection.fieldRows(
          title: context.l10n.hostsHostClubProfileTitleContact,
          children: [
            HostClubInlineTextEntry._(
              club: club,
              isOwner: widget.isOwner,
              accordion: _fieldAccordion,
              fieldName: HostClubEditFieldKeys.instagramHandle,
              label: context.l10n.hostsHostClubProfileLabelInstagram,
              value: _valueOrDash(club.instagramHandle),
              placeholder: context.l10n.hostsHostClubProfilePlaceholderYourclub,
              currentValue: club.instagramHandle ?? '',
              currentFieldValue: club.instagramHandle,
              icon: CatchIcons.alternateEmailRounded,
              keyboardType: TextInputType.text,
              normalizeInput: _normalizeSingleLineInput,
              toFieldValue: _optionalStringFieldValue,
              patchForValue: (value) => UpdateClubPatch(instagramHandle: value),
            ),
            HostClubInlineTextEntry._(
              club: club,
              isOwner: widget.isOwner,
              accordion: _fieldAccordion,
              fieldName: HostClubEditFieldKeys.phoneNumber,
              label: context.l10n.hostsHostClubProfileLabelPhone,
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
            HostClubInlineTextEntry._(
              club: club,
              isOwner: widget.isOwner,
              accordion: _fieldAccordion,
              fieldName: HostClubEditFieldKeys.email,
              label: context.l10n.hostsHostClubProfileLabelEmail,
              value: _valueOrDash(club.email),
              placeholder:
                  context.l10n.hostsHostClubProfilePlaceholderHelloYourclubCom,
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

  void _openSpoke(Routes route) {
    final onOpenSettingsRoute = widget.onOpenSettingsRoute;
    if (onOpenSettingsRoute != null) {
      onOpenSettingsRoute(route, widget.club.id);
      return;
    }
    context.pushNamed(route.name, queryParameters: {'clubId': widget.club.id});
  }
}

class HostClubInlineTextEntry extends StatelessWidget {
  const HostClubInlineTextEntry._({
    required this.club,
    required this.isOwner,
    required this.accordion,
    required this.fieldName,
    required this.label,
    required this.value,
    required this.currentValue,
    required this.icon,
    required this.patchForValue,
    this.currentFieldValue,
    this.placeholder,
    this.keyboardType,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.showCounter = false,
    this.normalizeInput,
    this.validator,
    this.toFieldValue,
  });

  final Club club;
  final bool isOwner;
  final CatchFieldAccordion accordion;
  final String fieldName;
  final String label;
  final String value;
  final String currentValue;
  final IconData icon;
  final UpdateClubPatch Function(Object? value) patchForValue;
  final Object? currentFieldValue;
  final String? placeholder;
  final TextInputType? keyboardType;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final bool showCounter;
  final String Function(String value)? normalizeInput;
  final FormFieldValidator<String>? validator;
  final Object? Function(String value)? toFieldValue;

  @override
  Widget build(BuildContext context) {
    if (!isOwner) {
      return CatchField.read(title: label, valueText: value, icon: icon);
    }

    return HostInlineTextEntryEditor(
      key: ValueKey('host-inline-$fieldName'),
      clubId: club.id,
      icon: icon,
      label: label,
      value: value,
      currentValue: currentValue,
      currentFieldValue: currentFieldValue ?? currentValue,
      fieldName: fieldName,
      isExpanded: accordion.isExpanded(fieldName),
      placeholder: placeholder,
      keyboardType: keyboardType,
      maxLines: maxLines,
      minLines: minLines,
      maxLength: maxLength,
      showCounter: showCounter,
      normalizeInput: normalizeInput,
      validator: validator,
      toFieldValue: toFieldValue,
      patchForValue: patchForValue,
      onTap: () => accordion.toggle(fieldName),
      onSaved: accordion.collapse,
      onCancel: accordion.collapse,
    );
  }
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
