part of '../host_operations_screen.dart';

class HostClubProfileCard extends ConsumerStatefulWidget {
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
  ConsumerState<HostClubProfileCard> createState() =>
      _HostClubProfileCardState();
}

class _HostClubProfileCardState extends ConsumerState<HostClubProfileCard> {
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HostMetaRow(
          club: club,
          roleLabel: isOwner ? 'Owner' : 'Host team',
          owner: isOwner,
        ),
        gapH24,
        CatchSection.fieldRows(
          title: 'Identity',
          first: true,
          children: [
            _textEntry(
              club: club,
              fieldName: 'name',
              label: 'Club name',
              value: club.name,
              currentValue: club.name,
              icon: CatchIcons.groups3Outlined,
              validator: _requiredHostFieldValidator('Club name'),
              normalizeInput: _normalizeSingleLineInput,
              patchForValue: (value) => UpdateClubPatch(name: value as String),
            ),
            _textEntry(
              club: club,
              fieldName: 'location',
              label: 'City',
              value: _valueOrDash(club.location),
              currentValue: club.location,
              icon: CatchIcons.locationCityOutlined,
              validator: _requiredHostFieldValidator('City'),
              normalizeInput: _normalizeSingleLineInput,
              patchForValue: (value) =>
                  UpdateClubPatch(location: value as String),
            ),
            _textEntry(
              club: club,
              fieldName: 'area',
              label: 'Area / neighbourhood',
              value: _valueOrDash(club.area),
              currentValue: club.area,
              icon: CatchIcons.locationOnOutlined,
              validator: _requiredHostFieldValidator('Area / neighbourhood'),
              normalizeInput: _normalizeSingleLineInput,
              patchForValue: (value) => UpdateClubPatch(area: value as String),
            ),
            _textEntry(
              club: club,
              fieldName: 'description',
              label: 'Description',
              value: _valueOrDash(club.description),
              currentValue: club.description,
              icon: CatchIcons.descriptionOutlined,
              maxLines: 3,
              minLines: 2,
              maxLength: 280,
              showCounter: true,
              keyboardType: TextInputType.multiline,
              validator: _requiredHostFieldValidator('Description'),
              normalizeInput: _normalizeMultilineInput,
              patchForValue: (value) =>
                  UpdateClubPatch(description: value as String),
            ),
          ],
        ),
        CatchSection.fieldRows(
          title: 'Contact',
          children: [
            _textEntry(
              club: club,
              fieldName: 'instagramHandle',
              label: 'Instagram',
              value: _valueOrDash(club.instagramHandle),
              placeholder: '@yourclub',
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
              fieldName: 'phoneNumber',
              label: 'Phone',
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
              fieldName: 'email',
              label: 'Email',
              value: _valueOrDash(club.email),
              placeholder: 'hello@yourclub.com',
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
          title: 'Event defaults',
          children: [
            _activityDefaultEntry(club),
            _admissionDefaultEntry(club),
            _ageRangeDefaultEntry(club),
            _cancellationDefaultEntry(club),
          ],
        ),
        CatchSection.fieldRows(
          title: 'Public profile',
          children: [
            CatchField.nav(
              title: 'Preview club page',
              valueText: 'Preview',
              icon: CatchIcons.visibilityOutlined,
              onTap: () => widget.onPreviewClub(club),
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
    const fieldName = 'primaryActivityKind';
    final selected = club.hostDefaults.primaryActivityKind;
    if (!widget.isOwner) {
      return CatchField.read(
        title: 'Default activity',
        valueText: selected.label,
        icon: CatchIcons.eventOutlined,
      );
    }

    return HostInlineOptionEditor<ActivityKind>(
      key: const ValueKey('host-inline-primaryActivityKind'),
      clubId: club.id,
      icon: CatchIcons.eventOutlined,
      label: 'Default activity',
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
    const fieldName = 'admissionPreset';
    final selected = club.hostDefaults.eventPolicy.admissionPreset;
    if (!widget.isOwner) {
      return CatchField.read(
        title: 'Admission',
        valueText: _admissionDefaultLabel(selected),
        icon: CatchIcons.eventSeatOutlined,
      );
    }

    return HostInlineOptionEditor<EventAdmissionDefaultPreset>(
      key: const ValueKey('host-inline-admissionPreset'),
      clubId: club.id,
      icon: CatchIcons.eventSeatOutlined,
      label: 'Admission',
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
    const fieldName = 'ageRange';
    final policy = club.hostDefaults.eventPolicy;
    final value = '${policy.minAge}–${policy.maxAge}';
    if (!widget.isOwner) {
      return CatchField.read(
        title: 'Age range',
        valueText: value,
        icon: CatchIcons.cakeOutlined,
      );
    }

    return HostInlineAgeRangeEditor(
      key: const ValueKey('host-inline-ageRange'),
      clubId: club.id,
      icon: CatchIcons.cakeOutlined,
      label: 'Age range',
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
    const fieldName = 'cancellationPolicyId';
    final selected = club.hostDefaults.eventPolicy.cancellationPolicyId;
    final selectedPolicy = club.hostDefaults.eventPolicy.cancellationPolicy;
    if (!widget.isOwner) {
      return CatchField.read(
        title: 'Cancellation policy',
        valueText: selectedPolicy.title,
        icon: CatchIcons.eventBusyOutlined,
      );
    }

    return HostInlineOptionEditor<EventCancellationPolicyId>(
      key: const ValueKey('host-inline-cancellationPolicyId'),
      clubId: club.id,
      icon: CatchIcons.eventBusyOutlined,
      label: 'Cancellation policy',
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
