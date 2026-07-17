part of '../host_operations_screen.dart';

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

String _normalizeSingleLineInput(String value) {
  return value.trim().replaceAll(RegExp(r'\s+'), ' ');
}

String _normalizeMultilineInput(String value) {
  return value
      .trim()
      .replaceAll(RegExp(r'[ \t]+\n'), '\n')
      .replaceAll(RegExp(r'\n{3,}'), '\n\n');
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
