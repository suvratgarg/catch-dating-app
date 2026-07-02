import 'package:catch_dating_app/core/presentation/catch_async_state.dart';
import 'package:catch_dating_app/event_policies/domain/event_policy.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/domain/event_private_access.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/create/create_event_policy_state.dart';
import 'package:catch_dating_app/locations/domain/location_coordinate.dart';
import 'package:flutter/foundation.dart';

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
  final CatchAsyncState<EventPrivateAccess?> privateAccess;
  final String? inviteCodeSeed;

  factory HostEventEditPrivateAccessState.from({
    required EventAdmissionPreset admissionPreset,
    required bool loadedPrivateAccess,
    required CatchAsyncState<EventPrivateAccess?> privateAccess,
  }) {
    final shouldWatch = admissionPreset == EventAdmissionPreset.inviteOnly;
    final CatchAsyncState<EventPrivateAccess?> resolvedPrivateAccess =
        shouldWatch
        ? privateAccess
        : const CatchAsyncState<EventPrivateAccess?>.data(null);
    return HostEventEditPrivateAccessState(
      shouldWatch: shouldWatch,
      shouldMarkLoaded: shouldWatch && !loadedPrivateAccess,
      privateAccess: resolvedPrivateAccess,
      inviteCodeSeed: shouldWatch && !loadedPrivateAccess
          ? _trimInviteCode(privateAccess.value?.inviteCode)
          : null,
    );
  }
}

@immutable
class HostEventEditLocationState {
  const HostEventEditLocationState({
    required this.canPick,
    required this.startingPoint,
    required this.selectedLabel,
    required this.pickerInitialLabel,
  });

  final bool canPick;
  final LocationCoordinate? startingPoint;
  final String selectedLabel;
  final String? pickerInitialLabel;

  bool get hasStartingPoint => startingPoint != null;

  factory HostEventEditLocationState.from({
    required bool canEdit,
    required LocationCoordinate? startingPoint,
    required String meetingPoint,
  }) {
    final normalizedMeetingPoint = meetingPoint.trim();
    return HostEventEditLocationState(
      canPick: canEdit,
      startingPoint: startingPoint,
      selectedLabel: normalizedMeetingPoint,
      pickerInitialLabel: _trimTextToNull(normalizedMeetingPoint),
    );
  }
}

@immutable
class HostEventEditScheduleValidationState {
  const HostEventEditScheduleValidationState({required this.errorText});

  final String? errorText;

  bool get isValid => errorText == null;

  factory HostEventEditScheduleValidationState.from({
    required bool scheduleLocked,
    required DateTime selectedStartDateTime,
    required DateTime now,
    required String invalidScheduleMessage,
  }) {
    return HostEventEditScheduleValidationState(
      errorText: scheduleLocked || selectedStartDateTime.isAfter(now)
          ? null
          : invalidScheduleMessage,
    );
  }
}

sealed class HostEventEditIntent {
  const HostEventEditIntent();
}

final class HostEventEditPickDateIntent extends HostEventEditIntent {
  const HostEventEditPickDateIntent();
}

final class HostEventEditPickStartTimeIntent extends HostEventEditIntent {
  const HostEventEditPickStartTimeIntent();
}

final class HostEventEditDurationChangedIntent extends HostEventEditIntent {
  const HostEventEditDurationChangedIntent(this.durationMinutes);

  final int durationMinutes;
}

final class HostEventEditMeetingPointChangedIntent extends HostEventEditIntent {
  const HostEventEditMeetingPointChangedIntent(this.value);

  final String value;
}

final class HostEventEditPickLocationIntent extends HostEventEditIntent {
  const HostEventEditPickLocationIntent();
}

final class HostEventEditPaceChangedIntent extends HostEventEditIntent {
  const HostEventEditPaceChangedIntent(this.pace);

  final PaceLevel pace;
}

final class HostEventEditAdmissionPresetChangedIntent
    extends HostEventEditIntent {
  const HostEventEditAdmissionPresetChangedIntent(this.preset);

  final EventAdmissionPreset preset;
}

final class HostEventEditCohortCapsChangedIntent extends HostEventEditIntent {
  const HostEventEditCohortCapsChangedIntent(this.enabled);

  final bool enabled;
}

final class HostEventEditDynamicPricingChangedIntent
    extends HostEventEditIntent {
  const HostEventEditDynamicPricingChangedIntent(this.enabled);

  final bool enabled;
}

final class HostEventEditCancellationPolicyChangedIntent
    extends HostEventEditIntent {
  const HostEventEditCancellationPolicyChangedIntent(this.policyId);

  final EventCancellationPolicyId policyId;
}

final class HostEventEditSaveIntent extends HostEventEditIntent {
  const HostEventEditSaveIntent();
}

String? _trimInviteCode(String? value) {
  return _trimTextToNull(value);
}

String? _trimTextToNull(String? value) {
  final normalized = value?.trim();
  if (normalized == null || normalized.isEmpty) return null;
  return normalized;
}
