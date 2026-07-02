import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/domain/event_private_access.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/create/create_event_policy_state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

@immutable
class HostEventEditScreenState {
  const HostEventEditScreenState({
    required this.canEdit,
    required this.scheduleLocked,
    required this.policyLocked,
    required this.footer,
    required this.saveOutcome,
    required this.saveError,
  });

  final bool canEdit;
  final bool scheduleLocked;
  final bool policyLocked;
  final EditHostedEventFooterState footer;
  final HostEventEditSaveOutcomeState saveOutcome;
  final Object? saveError;

  bool get hasSaveError => saveError != null;

  static bool eventCanEdit(Event event) => !event.isCancelled;

  static bool eventScheduleLocked(Event event, DateTime now) =>
      !eventCanEdit(event) ||
      event.startTime.isBefore(now) ||
      event.signedUpCount > 0 ||
      event.waitlistCount > 0 ||
      event.attendedCount > 0;

  static bool eventPolicyLocked(Event event, DateTime now) =>
      eventScheduleLocked(event, now);

  factory HostEventEditScreenState.from({
    required Event event,
    required DateTime now,
    required bool savePending,
    Object? saveError,
  }) {
    final canEdit = eventCanEdit(event);
    return HostEventEditScreenState(
      canEdit: canEdit,
      scheduleLocked: eventScheduleLocked(event, now),
      policyLocked: eventPolicyLocked(event, now),
      footer: EditHostedEventFooterState(
        isLoading: savePending,
        isEnabled: canEdit && !savePending,
      ),
      saveOutcome: const HostEventEditSaveOutcomeState.updated(),
      saveError: saveError,
    );
  }
}

@immutable
class EditHostedEventFooterState {
  const EditHostedEventFooterState({
    required this.isLoading,
    required this.isEnabled,
    this.label = 'Save changes',
  });

  final bool isLoading;
  final bool isEnabled;
  final String label;
}

@immutable
class HostEventEditSaveOutcomeState {
  const HostEventEditSaveOutcomeState({
    required this.successMessage,
    required this.popRouteOnSuccess,
    required this.missingStartingPointMessage,
    required this.invalidScheduleMessage,
  });

  const HostEventEditSaveOutcomeState.updated()
    : successMessage = 'Event updated.',
      popRouteOnSuccess = true,
      missingStartingPointMessage = 'Pin a starting point before saving.',
      invalidScheduleMessage = 'Event start must be in the future.';

  final String successMessage;
  final bool popRouteOnSuccess;
  final String missingStartingPointMessage;
  final String invalidScheduleMessage;
}

@immutable
class HostEventEditPrivateAccessState {
  const HostEventEditPrivateAccessState({
    required this.shouldWatch,
    required this.shouldMarkLoaded,
    required this.privateAccess,
    required this.inviteCodeSeed,
  });

  final bool shouldWatch;
  final bool shouldMarkLoaded;
  final AsyncValue<EventPrivateAccess?> privateAccess;
  final String? inviteCodeSeed;

  factory HostEventEditPrivateAccessState.from({
    required EventAdmissionPreset admissionPreset,
    required bool loadedPrivateAccess,
    required AsyncValue<EventPrivateAccess?> privateAccess,
  }) {
    final shouldWatch = admissionPreset == EventAdmissionPreset.inviteOnly;
    final AsyncValue<EventPrivateAccess?> resolvedPrivateAccess = shouldWatch
        ? privateAccess
        : const AsyncData<EventPrivateAccess?>(null);
    return HostEventEditPrivateAccessState(
      shouldWatch: shouldWatch,
      shouldMarkLoaded: shouldWatch && !loadedPrivateAccess,
      privateAccess: resolvedPrivateAccess,
      inviteCodeSeed: shouldWatch && !loadedPrivateAccess
          ? _trimInviteCode(privateAccess.asData?.value?.inviteCode)
          : null,
    );
  }
}

String? _trimInviteCode(String? value) {
  final normalized = value?.trim();
  if (normalized == null || normalized.isEmpty) return null;
  return normalized;
}
