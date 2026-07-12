part of '../host_operations_screen.dart';

class HostClubPreviewPane extends StatelessWidget {
  const HostClubPreviewPane({
    super.key,
    required this.club,
    required this.onPreviewClub,
  });

  final Club club;
  final HostClubPreviewCallback onPreviewClub;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          club.description,
          style: CatchTextStyles.bodyLead(context, color: t.ink),
        ),
        gapH18,
        CatchField.nav(
          title: context.l10n.hostsHostClubPreviewTitleOpenPublicPreview,
          valueText: context.l10n.hostsHostClubPreviewVisiblecopyPreview,
          icon: CatchIcons.visibilityOutlined,
          onTap: () => onPreviewClub(club),
        ),
      ],
    );
  }
}

String _valueOrDash(String? value) {
  final trimmed = value?.trim();
  return trimmed == null || trimmed.isEmpty ? '—' : trimmed;
}

String _admissionDefaultLabel(EventAdmissionDefaultPreset preset) {
  return switch (preset) {
    EventAdmissionDefaultPreset.openCapacity => 'Open capacity',
    EventAdmissionDefaultPreset.inviteOnly => 'Invite only',
    EventAdmissionDefaultPreset.balancedSingles => 'Balanced singles',
    EventAdmissionDefaultPreset.fixedCohortCaps => 'Fixed cohort caps',
  };
}

String _admissionDefaultDescription(EventAdmissionDefaultPreset preset) {
  return switch (preset) {
    EventAdmissionDefaultPreset.openCapacity =>
      'Anyone eligible can book until the event reaches capacity.',
    EventAdmissionDefaultPreset.inviteOnly =>
      'New invite-only events ask for an event-specific code.',
    EventAdmissionDefaultPreset.balancedSingles =>
      'Straight men and women are kept within one spot of each other.',
    EventAdmissionDefaultPreset.fixedCohortCaps =>
      'Open booking with optional straight men and straight women caps.',
  };
}

ClubHostDefaults _hostDefaultsWithActivity(
  ClubHostDefaults defaults,
  ActivityKind activityKind,
) {
  final supported =
      defaults.effectiveSupportedActivityKinds.contains(activityKind)
      ? defaults.supportedActivityKinds
      : [...defaults.supportedActivityKinds, activityKind];
  return defaults.copyWith(
    primaryActivityKind: activityKind,
    supportedActivityKinds: supported,
  );
}

EventCancellationPolicy _cancellationPolicyFor(
  EventCancellationPolicyId policyId,
) {
  return switch (policyId) {
    EventCancellationPolicyId.flexible =>
      const EventCancellationPolicy.flexible(),
    EventCancellationPolicyId.standard =>
      const EventCancellationPolicy.standard(),
    EventCancellationPolicyId.strict => const EventCancellationPolicy.strict(),
  };
}

String _normalizeSingleLineInput(String value) {
  return value.trim().replaceAll(RegExp(r'\s+'), ' ');
}

String _normalizeMultilineInput(String value) {
  return value
      .trim()
      .replaceAll(RegExp(r'[ \t]+\n'), '\n')
      .replaceAll(RegExp(r'\n{3,}'), '\n\n');
}

String? Function(String?) _requiredHostFieldValidator(String label) {
  return (value) {
    if (value == null || value.trim().isEmpty) {
      return '$label is required.';
    }
    return null;
  };
}

String? _optionalEmailValidator(String? value) {
  final trimmed = value?.trim() ?? '';
  if (trimmed.isEmpty) return null;
  final valid = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(trimmed);
  return valid ? null : 'Enter a valid email.';
}

Object? _optionalStringFieldValue(String value) {
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}

String _optionalMinAgeText(int minAge) => minAge == 0 ? '' : '$minAge';

String _optionalMaxAgeText(int maxAge) => maxAge == 99 ? '' : '$maxAge';

_ParsedAgeRange _parseAgeRange({
  required String minText,
  required String maxText,
}) {
  final minRaw = minText.trim();
  final maxRaw = maxText.trim();
  final minAge = minRaw.isEmpty ? 0 : int.tryParse(minRaw);
  final maxAge = maxRaw.isEmpty ? 99 : int.tryParse(maxRaw);

  if (minAge == null || (minRaw.isNotEmpty && (minAge < 18 || minAge > 99))) {
    return const _ParsedAgeRange.error('Min age must be 18-99.');
  }
  if (maxAge == null || (maxRaw.isNotEmpty && (maxAge < 18 || maxAge > 99))) {
    return const _ParsedAgeRange.error('Max age must be 18-99.');
  }
  if (minAge > maxAge) {
    return const _ParsedAgeRange.error('Min age must be less than max age.');
  }
  return _ParsedAgeRange(minAge: minAge, maxAge: maxAge);
}

class _ParsedAgeRange {
  const _ParsedAgeRange({required this.minAge, required this.maxAge})
    : error = null;

  const _ParsedAgeRange.error(this.error) : minAge = null, maxAge = null;

  final int? minAge;
  final int? maxAge;
  final String? error;
}
