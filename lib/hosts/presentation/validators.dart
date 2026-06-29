import 'package:catch_dating_app/event_policies/domain/event_policy.dart';
import 'package:flutter/material.dart';

/// Returns null if [value] is empty or null; otherwise validates that the
/// trimmed value is a positive integer >= 1.
String? positiveOptionalValidator(String? value) {
  if (value == null || value.trim().isEmpty) return null;
  final n = int.tryParse(value.trim());
  if (n == null || n < 1) return 'Min 1';
  return null;
}

/// Returns 'Required' if [value] is empty or null; otherwise validates that
/// the trimmed value is a positive integer >= 1.
String? positiveRequiredValidator(String? value) {
  if (value == null || value.trim().isEmpty) return 'Required';
  final n = int.tryParse(value.trim());
  if (n == null || n < 1) return 'Min 1';
  return null;
}

/// Validates an invite code: non-empty, 4-64 characters.
String? inviteCodeValidator(String? value) {
  final code = value?.trim() ?? '';
  if (code.isEmpty) return 'Required';
  if (code.length < 4) return 'Min 4 chars';
  if (code.length > 64) return 'Max 64 chars';
  return null;
}

/// Validates an age range field (min/max). Returns null on empty or valid age.
///
/// [siblingController] holds the paired min or max value so that cross-field
/// constraints can be checked (e.g. min <= max).
String? validateAge(
  String? value, {
  required TextEditingController siblingController,
  required bool isMinimum,
}) {
  if (value == null || value.trim().isEmpty) return null;

  final parsedValue = int.tryParse(value.trim());
  if (parsedValue == null || parsedValue < 18 || parsedValue > 99) {
    return '18-99';
  }

  final siblingValue = int.tryParse(siblingController.text.trim());
  if (siblingValue == null) return null;

  if (isMinimum && parsedValue > siblingValue) return '<= max';
  if (!isMinimum && parsedValue < siblingValue) return '>= min';
  return null;
}

/// Resolves an [EventCancellationPolicyId] to its [EventCancellationPolicy].
EventCancellationPolicy policyFor(EventCancellationPolicyId id) {
  return switch (id) {
    EventCancellationPolicyId.flexible =>
      const EventCancellationPolicy.flexible(),
    EventCancellationPolicyId.standard =>
      const EventCancellationPolicy.standard(),
    EventCancellationPolicyId.strict => const EventCancellationPolicy.strict(),
  };
}
