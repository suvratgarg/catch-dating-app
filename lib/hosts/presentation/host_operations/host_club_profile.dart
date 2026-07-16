part of '../host_operations_screen.dart';

class HostClubProfileCard extends StatefulWidget {
  const HostClubProfileCard({
    super.key,
    required this.club,
    required this.currentUid,
    required this.isOwner,
    required this.onPreviewClub,
    this.initialExpandedField,
  });

  final Club club;
  final String currentUid;
  final bool isOwner;
  final HostClubPreviewCallback onPreviewClub;
  final String? initialExpandedField;

  @override
  State<HostClubProfileCard> createState() => _HostClubProfileCardState();
}

class _HostClubProfileCardState extends State<HostClubProfileCard> {
  String? _expandedField;

  @override
  void initState() {
    super.initState();
    _expandedField = widget.initialExpandedField;
  }

  bool _isExpanded(String fieldName) => _expandedField == fieldName;

  void _toggleField(String fieldName) {
    setState(() {
      _expandedField = _expandedField == fieldName ? null : fieldName;
    });
  }

  void _collapseField() {
    if (_expandedField == null) return;
    setState(() => _expandedField = null);
  }

  @override
  void didUpdateWidget(covariant HostClubProfileCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.club.id != widget.club.id) {
      _expandedField = widget.initialExpandedField;
    } else if (oldWidget.initialExpandedField != widget.initialExpandedField) {
      _expandedField = widget.initialExpandedField;
    }
  }

  @override
  Widget build(BuildContext context) {
    final club = widget.club;
    final isOwner = widget.isOwner;
    final cityFieldName = context.l10n.hostsHostClubProfileVisiblecopyLocation;
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
            isExpanded: _isExpanded(cityFieldName),
            options: cityOptions,
            patchForValue: (value) => UpdateClubPatch(location: value),
            onTap: () => _toggleField(cityFieldName),
            onSaved: _collapseField,
            onCancel: _collapseField,
          );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CatchSection.fieldRows(
          title: context.l10n.hostsHostClubProfileTitleIdentity,
          first: true,
          children: [
            _textEntry(
              club: club,
              fieldName: context.l10n.hostsHostClubProfileVisiblecopyName,
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
              fieldName: context.l10n.hostsHostClubProfileVisiblecopyArea,
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
              fieldName:
                  context.l10n.hostsHostClubProfileVisiblecopyDescription,
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
              fieldName:
                  context.l10n.hostsHostClubProfileVisiblecopyInstagramhandle,
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
              fieldName:
                  context.l10n.hostsHostClubProfileVisiblecopyPhonenumber,
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
              fieldName: context.l10n.hostsHostClubProfileVisiblecopyEmail,
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
        CatchSection.fieldRows(
          title: context.l10n.hostsHostClubProfileTitlePublicProfile,
          children: [
            CatchField.nav(
              title: context.l10n.hostsHostClubProfileTitlePreviewClubPage,
              valueText: context.l10n.hostsHostClubProfileVisiblecopyPreview,
              icon: CatchIcons.visibilityOutlined,
              onTap: widget.onPreviewClub,
            ),
          ],
        ),
        if (isOwner) ...[
          CatchSection.divided(
            child: HostPaymentAccountControllerCard(club: club),
          ),
          CatchSection.divided(
            child: HostTeamManagementSection(
              club: club,
              currentUid: widget.currentUid,
            ),
          ),
        ],
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
      isExpanded: _isExpanded(fieldName),
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
      onTap: () => _toggleField(fieldName),
      onSaved: _collapseField,
      onCancel: _collapseField,
    );
  }

  Widget _activityDefaultEntry(Club club) {
    final fieldName =
        context.l10n.hostsHostClubProfileVisiblecopyPrimaryactivitykind;
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
      isExpanded: _isExpanded(fieldName),
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
      onTap: () => _toggleField(fieldName),
      onSaved: _collapseField,
      onCancel: _collapseField,
    );
  }

  Widget _admissionDefaultEntry(Club club) {
    final fieldName =
        context.l10n.hostsHostClubProfileVisiblecopyAdmissionpreset;
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
      isExpanded: _isExpanded(fieldName),
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
      onTap: () => _toggleField(fieldName),
      onSaved: _collapseField,
      onCancel: _collapseField,
    );
  }

  Widget _ageRangeDefaultEntry(Club club) {
    final fieldName = context.l10n.hostsHostClubProfileVisiblecopyAgerange;
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
      isExpanded: _isExpanded(fieldName),
      onTap: () => _toggleField(fieldName),
      onSaved: _collapseField,
      onCancel: _collapseField,
    );
  }

  Widget _cancellationDefaultEntry(Club club) {
    final fieldName =
        context.l10n.hostsHostClubProfileVisiblecopyCancellationpolicyid;
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
      isExpanded: _isExpanded(fieldName),
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
      onTap: () => _toggleField(fieldName),
      onSaved: _collapseField,
      onCancel: _collapseField,
    );
  }
}
