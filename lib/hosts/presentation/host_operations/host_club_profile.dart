part of '../host_operations_screen.dart';

typedef _ClubHostDefaultsUpdate =
    ClubHostDefaults Function(ClubHostDefaults current);

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

class HostClubProfileCard extends ConsumerStatefulWidget {
  const HostClubProfileCard({
    super.key,
    required this.club,
    required this.currentUid,
    required this.isOwner,
    this.initialExpandedField,
  });

  final Club club;
  final String currentUid;
  final bool isOwner;
  final String? initialExpandedField;

  @override
  ConsumerState<HostClubProfileCard> createState() =>
      _HostClubProfileCardState();
}

class _HostClubProfileCardState extends ConsumerState<HostClubProfileCard> {
  late final CatchFieldAccordion _fieldAccordion;
  late List<_HostClubMediaDraft> _mediaDrafts;
  HostPickedClubLogo? _pickedLogo;
  bool _clubPhotosTouched = false;
  bool _ownsMediaMutation = false;
  late ClubHostDefaults _defaultsDraft;
  late ClubHostDefaults _defaultsConfirmed;
  late ClubHostDefaults _defaultsOptimistic;
  ClubHostDefaults? _queuedImmediateDefaults;
  bool _flushingImmediateDefaults = false;
  bool _defaultsDirty = false;
  bool _ownsDefaultsMutation = false;

  bool get _mediaDirty => _clubPhotosTouched || _pickedLogo != null;

  @override
  void initState() {
    super.initState();
    _fieldAccordion = CatchFieldAccordion(
      initialExpanded: widget.initialExpandedField,
    )..addListener(_handleAccordionChanged);
    _resetDrafts();
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

  @override
  void didUpdateWidget(covariant HostClubProfileCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.club.id != widget.club.id) {
      _setExpandedField(widget.initialExpandedField);
      _resetDrafts();
    } else if (oldWidget.initialExpandedField != widget.initialExpandedField) {
      _setExpandedField(widget.initialExpandedField);
    }
    if (oldWidget.club.hostDefaults != widget.club.hostDefaults &&
        !_flushingImmediateDefaults &&
        _queuedImmediateDefaults == null) {
      final hadStagedChanges = _defaultsDirty;
      _defaultsConfirmed = widget.club.hostDefaults;
      _defaultsOptimistic = widget.club.hostDefaults;
      if (!hadStagedChanges) {
        _defaultsDraft = widget.club.hostDefaults;
      }
      _defaultsDirty = _defaultsDraft != _defaultsOptimistic;
    }
  }

  @override
  void dispose() {
    _fieldAccordion
      ..removeListener(_handleAccordionChanged)
      ..dispose();
    super.dispose();
  }

  void _resetDrafts() {
    _resetMediaDraft();
    _defaultsDraft = widget.club.hostDefaults;
    _defaultsConfirmed = widget.club.hostDefaults;
    _defaultsOptimistic = widget.club.hostDefaults;
    _queuedImmediateDefaults = null;
    _flushingImmediateDefaults = false;
    _defaultsDirty = false;
    _ownsDefaultsMutation = false;
  }

  void _resetMediaDraft() {
    _mediaDrafts = [
      for (final photo in [
        ...widget.club.clubPhotos,
      ]..sort((a, b) => a.position.compareTo(b.position)))
        _HostExistingClubMediaDraft(photo),
    ];
    _pickedLogo = null;
    _clubPhotosTouched = false;
    _ownsMediaMutation = false;
  }

  void _cancelMedia() => setState(_resetMediaDraft);

  void _cancelDefaults() {
    setState(() {
      _defaultsDraft = _defaultsOptimistic;
      _defaultsDirty = false;
      _ownsDefaultsMutation = false;
    });
  }

  Future<void> _pickLogo() async {
    final logo = await ref.read(hostClubEditControllerProvider).pickClubLogo();
    if (!mounted || logo == null) return;
    setState(() => _pickedLogo = logo);
  }

  Future<void> _pickPhotos() async {
    final remaining = maxClubPhotos - _mediaDrafts.length;
    if (remaining <= 0) return;
    final photos = await ref
        .read(hostClubEditControllerProvider)
        .pickClubPhotos(limit: remaining);
    if (!mounted || photos.isEmpty) return;
    setState(() {
      _mediaDrafts.addAll(
        photos.map(
          (photo) => _HostPickedClubMediaDraft(
            '${DateTime.now().microsecondsSinceEpoch}-${photo.image.name}',
            photo,
          ),
        ),
      );
      _clubPhotosTouched = true;
    });
  }

  void _removePhoto(int index) {
    if (index < 0 || index >= _mediaDrafts.length) return;
    setState(() {
      _mediaDrafts.removeAt(index);
      _clubPhotosTouched = true;
    });
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
      _clubPhotosTouched = true;
    });
  }

  Future<void> _saveMedia() async {
    final mutation = HostClubEditController.updateMediaMutation;
    if (ref.read(mutation).isPending ||
        (!_clubPhotosTouched && _pickedLogo == null)) {
      return;
    }
    setState(() => _ownsMediaMutation = true);
    try {
      await mutation.run(
        ref,
        (tx) => tx
            .get(hostClubEditControllerProvider)
            .updateClubMedia(
              club: widget.club,
              photoInputs: _clubPhotosTouched
                  ? [for (final draft in _mediaDrafts) draft.input]
                  : null,
              logo: _pickedLogo,
            ),
      );
    } catch (_) {
      return;
    }
    if (!mounted) return;
    setState(() {
      _clubPhotosTouched = false;
      _pickedLogo = null;
      _ownsMediaMutation = false;
    });
  }

  void _updateDefaults(ClubHostDefaults defaults) {
    setState(() {
      _defaultsDraft = defaults;
      _defaultsDirty = defaults != _defaultsOptimistic;
      _ownsDefaultsMutation = false;
    });
  }

  void _updateDefaultsImmediately(_ClubHostDefaultsUpdate update) {
    final nextDraft = update(_defaultsDraft);
    final nextOptimistic = update(_defaultsOptimistic);
    if (nextDraft == _defaultsDraft && nextOptimistic == _defaultsOptimistic) {
      return;
    }
    setState(() {
      _defaultsDraft = nextDraft;
      _defaultsOptimistic = nextOptimistic;
      _queuedImmediateDefaults = nextOptimistic;
      _defaultsDirty = nextDraft != nextOptimistic;
      _ownsDefaultsMutation = true;
    });
    unawaited(_flushImmediateDefaults());
  }

  Future<void> _flushImmediateDefaults() async {
    if (_flushingImmediateDefaults) return;
    _flushingImmediateDefaults = true;
    try {
      while (mounted) {
        final target = _queuedImmediateDefaults;
        if (target == null) break;
        _queuedImmediateDefaults = null;
        try {
          await HostClubEditController.updateClubMutation.run(
            ref,
            (tx) => tx
                .get(hostClubEditControllerProvider)
                .updateClub(
                  clubId: widget.club.id,
                  patch: UpdateClubPatch(hostDefaults: target),
                ),
          );
        } catch (_) {
          if (!mounted) return;
          if (_queuedImmediateDefaults == null) {
            setState(() {
              _defaultsOptimistic = _defaultsConfirmed;
              _defaultsDirty = _defaultsDraft != _defaultsOptimistic;
              _ownsDefaultsMutation = true;
            });
          }
          continue;
        }
        if (!mounted) return;
        setState(() {
          _defaultsConfirmed = target;
          if (_queuedImmediateDefaults == null) {
            _defaultsOptimistic = target;
          }
          _defaultsDirty = _defaultsDraft != _defaultsOptimistic;
          _ownsDefaultsMutation = false;
        });
      }
    } finally {
      _flushingImmediateDefaults = false;
    }
  }

  Future<void> _saveDefaults() async {
    final mutation = HostClubEditController.updateClubMutation;
    if (_flushingImmediateDefaults ||
        ref.read(mutation).isPending ||
        !_defaultsDirty) {
      return;
    }
    setState(() => _ownsDefaultsMutation = true);
    try {
      await mutation.run(
        ref,
        (tx) => tx
            .get(hostClubEditControllerProvider)
            .updateClub(
              clubId: widget.club.id,
              patch: UpdateClubPatch(hostDefaults: _defaultsDraft),
            ),
      );
    } catch (_) {
      return;
    }
    if (!mounted) return;
    setState(() {
      _defaultsConfirmed = _defaultsDraft;
      _defaultsOptimistic = _defaultsDraft;
      _defaultsDirty = false;
      _ownsDefaultsMutation = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final club = widget.club;
    final isOwner = widget.isOwner;
    final mediaMutation = ref.watch(HostClubEditController.updateMediaMutation);
    final defaultsMutation = ref.watch(
      HostClubEditController.updateClubMutation,
    );
    final mediaError = _ownsMediaMutation && mediaMutation.hasError
        ? mutationErrorMessage(
            mediaMutation,
            l10n: context.l10n,
            context: AppErrorContext.club,
          )
        : null;
    final defaultsError = _ownsDefaultsMutation && defaultsMutation.hasError
        ? mutationErrorMessage(
            defaultsMutation,
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
    final cityEntry = !isOwner
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CreateClubProfileImagePicker(
                imageBytes: _pickedLogo?.bytes,
                existingImageUrl: club.profileImageUrl,
                onTap: mediaMutation.isPending ? null : _pickLogo,
                variant: CreateClubProfileImagePickerVariant.editLogo,
              ),
              gapH20,
              CreateClubPhotosPicker(
                photos: [for (final draft in _mediaDrafts) draft.preview],
                existingImageUrl: _clubPhotosTouched ? null : club.imageUrl,
                onAddPhotos:
                    mediaMutation.isPending ||
                        _mediaDrafts.length >= maxClubPhotos
                    ? null
                    : _pickPhotos,
                onRemovePhoto: mediaMutation.isPending ? null : _removePhoto,
                onReorderPhoto: mediaMutation.isPending ? null : _reorderPhoto,
                variant: CreateClubPhotosPickerVariant.editStrip,
              ),
              if (_mediaDirty) ...[
                gapH12,
                if (mediaError != null) ...[
                  CatchFieldSupportRow(
                    text: mediaError,
                    color: CatchTokens.of(context).danger,
                    showErrorIcon: true,
                  ),
                  gapH12,
                ],
                CatchFieldActionBar(
                  key: const ValueKey('host-media-action-bar'),
                  loading: mediaMutation.isPending,
                  onCancel: _cancelMedia,
                  onSubmit: _saveMedia,
                ),
              ],
            ],
          ),
        ),
        CatchSection.fieldRows(
          title: context.l10n.hostsHostClubProfileTitleIdentity,
          children: [
            _textEntry(
              club: club,
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
            _textEntry(
              club: club,
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
            _textEntry(
              club: club,
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
            _textEntry(
              club: club,
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
            _textEntry(
              club: club,
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
            _textEntry(
              club: club,
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
          title: context.l10n.hostsHostClubProfileTitleEventDefaults,
          children: [
            _activityDefaultEntry(club),
            _admissionDefaultEntry(club),
            _ageRangeDefaultEntry(club),
            _cancellationDefaultEntry(club),
          ],
        ),
        if (isOwner)
          CatchSection.plain(
            title: context.l10n.hostsHostClubProfileTitleAdvancedEventDefaults,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ClubPolicyDefaultsCard(
                  defaults: _defaultsDraft.eventPolicy,
                  currencyCode: currencyCodeForCityName(club.location),
                  advancedOnly: true,
                  onChanged: (policy) => _updateDefaults(
                    _defaultsDraft.copyWith(eventPolicy: policy),
                  ),
                  onImmediateChanged: (update) => _updateDefaultsImmediately(
                    (defaults) => defaults.copyWith(
                      eventPolicy: update(defaults.eventPolicy),
                    ),
                  ),
                ),
                gapH16,
                EventSuccessDefaultsPanel(
                  defaults: _defaultsDraft.eventSuccessForActivity(
                    _defaultsDraft.primaryActivityKind,
                  ),
                  activityKind: _defaultsDraft.primaryActivityKind,
                  onChanged: (eventSuccess) => _updateDefaults(
                    _defaultsDraft.copyWithEventSuccessForActivity(
                      activityKind: _defaultsDraft.primaryActivityKind,
                      defaults: eventSuccess,
                    ),
                  ),
                  onImmediateChanged: (update) =>
                      _updateDefaultsImmediately((defaults) {
                        final activityKind = defaults.primaryActivityKind;
                        return defaults.copyWithEventSuccessForActivity(
                          activityKind: activityKind,
                          defaults: update(
                            defaults.eventSuccessForActivity(activityKind),
                          ),
                        );
                      }),
                  title: context
                      .l10n
                      .hostsClubEventSuccessDefaultsStepTitleLiveEventGuide,
                  subtitle: context
                      .l10n
                      .hostsClubEventSuccessDefaultsStepSubtitleNewEventsStartWithAReadyToRunPlanForThisActivity,
                ),
                if (_defaultsDirty) ...[
                  gapH12,
                  if (defaultsError != null) ...[
                    CatchFieldSupportRow(
                      text: defaultsError,
                      color: CatchTokens.of(context).danger,
                      showErrorIcon: true,
                    ),
                    gapH12,
                  ],
                  CatchFieldActionBar(
                    key: const ValueKey('host-defaults-action-bar'),
                    loading: defaultsMutation.isPending,
                    onCancel: _cancelDefaults,
                    onSubmit: _saveDefaults,
                  ),
                ],
              ],
            ),
          ),
        if (isOwner) ...[HostPaymentAccountControllerCard(club: club)],
        HostTeamManagementSection(
          club: club,
          currentUid: widget.currentUid,
          canManage: isOwner,
        ),
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
      isExpanded: _fieldAccordion.isExpanded(fieldName),
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
      onTap: () => _fieldAccordion.toggle(fieldName),
      onSaved: _fieldAccordion.collapse,
      onCancel: _fieldAccordion.collapse,
    );
  }

  Widget _activityDefaultEntry(Club club) {
    const fieldName = HostClubEditFieldKeys.primaryActivityKind;
    final selected = club.hostDefaults.primaryActivityKind;
    if (!widget.isOwner) {
      return CatchField.read(
        title: context.l10n.hostsHostClubProfileTitleDefaultActivity,
        valueText: selected.label,
        icon: CatchIcons.eventOutlined,
      );
    }

    return HostInlineOptionEditor<ActivityKind>(
      key: const ValueKey('host-inline-primaryActivityKind'),
      clubId: club.id,
      icon: CatchIcons.eventOutlined,
      label: context.l10n.hostsHostClubProfileLabelDefaultActivity,
      value: selected.label,
      currentValue: selected,
      fieldName: fieldName,
      isExpanded: _fieldAccordion.isExpanded(fieldName),
      options: [
        for (final activityKind in ActivityKind.eventCreationDefaults)
          HostInlineOption(
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
      onTap: () => _fieldAccordion.toggle(fieldName),
      onSaved: _fieldAccordion.collapse,
      onCancel: _fieldAccordion.collapse,
    );
  }

  Widget _admissionDefaultEntry(Club club) {
    const fieldName = HostClubEditFieldKeys.admissionPreset;
    final selected = club.hostDefaults.eventPolicy.admissionPreset;
    if (!widget.isOwner) {
      return CatchField.read(
        title: context.l10n.hostsHostClubProfileTitleAdmission,
        valueText: _admissionDefaultLabel(selected),
        icon: CatchIcons.eventSeatOutlined,
      );
    }

    return HostInlineOptionEditor<EventAdmissionDefaultPreset>(
      key: const ValueKey('host-inline-admissionPreset'),
      clubId: club.id,
      icon: CatchIcons.eventSeatOutlined,
      label: context.l10n.hostsHostClubProfileLabelAdmission,
      value: _admissionDefaultLabel(selected),
      currentValue: selected,
      fieldName: fieldName,
      isExpanded: _fieldAccordion.isExpanded(fieldName),
      helperText: _admissionDefaultDescription(selected),
      options: [
        for (final preset in EventAdmissionDefaultPreset.values)
          HostInlineOption(
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
      onTap: () => _fieldAccordion.toggle(fieldName),
      onSaved: _fieldAccordion.collapse,
      onCancel: _fieldAccordion.collapse,
    );
  }

  Widget _ageRangeDefaultEntry(Club club) {
    const fieldName = HostClubEditFieldKeys.ageRange;
    final policy = club.hostDefaults.eventPolicy;
    final value = context.l10n.hostsHostClubProfileVisiblecopyMinageMaxage(
      minAge: policy.minAge,
      maxAge: policy.maxAge,
    );
    if (!widget.isOwner) {
      return CatchField.read(
        title: context.l10n.hostsHostClubProfileTitleAgeRange,
        valueText: value,
        icon: CatchIcons.cakeOutlined,
      );
    }

    return HostInlineAgeRangeEditor(
      key: const ValueKey('host-inline-ageRange'),
      clubId: club.id,
      icon: CatchIcons.cakeOutlined,
      label: context.l10n.hostsHostClubProfileLabelAgeRange,
      value: value,
      fieldName: fieldName,
      hostDefaults: club.hostDefaults,
      isExpanded: _fieldAccordion.isExpanded(fieldName),
      onTap: () => _fieldAccordion.toggle(fieldName),
      onSaved: _fieldAccordion.collapse,
      onCancel: _fieldAccordion.collapse,
    );
  }

  Widget _cancellationDefaultEntry(Club club) {
    const fieldName = HostClubEditFieldKeys.cancellationPolicyId;
    final selected = club.hostDefaults.eventPolicy.cancellationPolicyId;
    final selectedPolicy = club.hostDefaults.eventPolicy.cancellationPolicy;
    if (!widget.isOwner) {
      return CatchField.read(
        title: context.l10n.hostsHostClubProfileTitleCancellationPolicy,
        valueText: selectedPolicy.title,
        icon: CatchIcons.eventBusyOutlined,
      );
    }

    return HostInlineOptionEditor<EventCancellationPolicyId>(
      key: const ValueKey('host-inline-cancellationPolicyId'),
      clubId: club.id,
      icon: CatchIcons.eventBusyOutlined,
      label: context.l10n.hostsHostClubProfileLabelCancellationPolicy,
      value: selectedPolicy.title,
      currentValue: selected,
      fieldName: fieldName,
      isExpanded: _fieldAccordion.isExpanded(fieldName),
      helperText: selectedPolicy.attendeeSummary,
      options: [
        for (final policyId in EventCancellationPolicyId.values)
          HostInlineOption(
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
      onTap: () => _fieldAccordion.toggle(fieldName),
      onSaved: _fieldAccordion.collapse,
      onCancel: _fieldAccordion.collapse,
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
