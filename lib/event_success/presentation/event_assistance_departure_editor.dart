import 'package:catch_dating_app/event_success/domain/event_assistance_departure.dart';
import 'package:catch_dating_app/event_success/domain/event_assistance_group_progress.dart';
import 'package:catch_dating_app/event_success/domain/event_assistance_observation.dart';
import 'package:catch_dating_app/event_success/presentation/event_assistance_departure_controller.dart';
import 'package:catch_dating_app/event_success/presentation/event_assistance_departure_provider.dart';
import 'package:catch_dating_app/exceptions/app_exception.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'event_assistance_departure_editor.g.dart';

enum EventDepartureFormPhase {
  choosing,
  reviewingRoster,
  submitting,
  retryRequired,
  refreshRequired,
  saved,
}

/// An account change removes the entire form from the renderable state.
sealed class EventDepartureEditorState {
  const EventDepartureEditorState();

  bool get canDismiss => switch (this) {
    EventDepartureForm(:final phase) =>
      phase != EventDepartureFormPhase.submitting,
    EventDepartureFormUnavailable() => true,
  };
}

final class EventDepartureFormUnavailable extends EventDepartureEditorState {
  const EventDepartureFormUnavailable._(this.error);
  final Object error;
}

final class EventDepartureForm extends EventDepartureEditorState {
  const EventDepartureForm._({
    required this.session,
    this.destination,
    this.selection,
    this.roster,
    this.checkpoint,
    this.phase = EventDepartureFormPhase.choosing,
    this.action,
    this.result,
    this.error,
  });

  final EventDepartureSession session;
  final AssistanceJoiningTarget? destination;
  final EventAssistanceDepartureRosterSelection? selection;
  final EventAssistanceDepartureRosterReview? roster;
  final AssistanceDepartureCheckpointRequest? checkpoint;
  final EventDepartureFormPhase phase;
  final EventDeparturePendingAction? action;
  final EventAssistanceGroupProgressResult? result;
  final Object? error;

  bool get canEdit =>
      phase == EventDepartureFormPhase.choosing && session.view.canConfirm;
  bool get needsRosterReview => selection != null && roster == null;
  bool get canReviewRoster => canEdit && selection != null;
  bool get canSubmit =>
      (canEdit && destination != null && !needsRosterReview) ||
      phase == EventDepartureFormPhase.retryRequired;
  bool get canConfigureCheckpoint =>
      canEdit &&
      roster != null &&
      destination != null &&
      destination is! AssistanceFixedPlace;
  bool get canReload => canDismiss && phase != EventDepartureFormPhase.saved;

  EventDepartureForm _withPhase(
    EventDepartureFormPhase phase, {
    EventDeparturePendingAction? action,
    EventAssistanceGroupProgressResult? result,
    Object? error,
  }) => EventDepartureForm._(
    session: session,
    destination: destination,
    selection: selection,
    roster: roster,
    checkpoint: checkpoint,
    phase: phase,
    action: action ?? this.action,
    result: result,
    error: error,
  );
}

@riverpod
class EventAssistanceDepartureEditor extends _$EventAssistanceDepartureEditor {
  Future<EventAssistanceGroupProgressResult>? _confirmation;
  Future<EventAssistanceDepartureRosterReview>? _review;
  bool _revoked = false;

  @override
  EventDepartureEditorState build(EventDepartureSession session) {
    ref.watch(eventAssistanceDepartureControllerProvider);
    ref.listen(eventAssistanceDepartureAccountProvider, (_, next) {
      if (!identical(next.asData?.value, session.account)) {
        _revoked = true;
        state = const EventDepartureFormUnavailable._(departureSessionChanged);
      }
    });
    final account = ref.read(eventAssistanceDepartureAccountProvider);
    if (_revoked ||
        account.isLoading ||
        account.hasError ||
        !identical(account.asData?.value, session.account)) {
      _revoked = true;
      return const EventDepartureFormUnavailable._(departureSessionChanged);
    }
    return EventDepartureForm._(session: session);
  }

  EventDepartureForm? get _form => switch (state) {
    final EventDepartureForm form when !_revoked => form,
    EventDepartureForm() || EventDepartureFormUnavailable() => null,
  };

  void selectDestination(AssistanceJoiningTarget target) {
    final form = _form;
    if (form == null || !form.canEdit) return;
    if (!session.view.destinations.any((item) => item.target == target)) {
      throw ArgumentError('Choose a destination from this event snapshot.');
    }
    if (form.destination == target) return;
    state = EventDepartureForm._(
      session: session,
      destination: target,
      selection: form.selection,
      roster: form.roster,
    );
  }

  /// Null skips recording; an explicit empty selection records nobody.
  void selectRoster(Iterable<String>? attendeeIds) {
    final form = _form;
    if (form == null || !form.canEdit) return;
    state = EventDepartureForm._(
      session: session,
      destination: form.destination,
      selection: attendeeIds == null
          ? null
          : EventAssistanceDepartureRosterSelection(attendeeIds),
    );
  }

  void setCheckpoint(AssistanceDepartureCheckpointRequest? request) {
    final form = _form;
    if (form == null || !form.canEdit) return;
    if (request != null) {
      if (!form.canConfigureCheckpoint) {
        throw const ValidationException(
          'Review the departure roster and choose a route stop first.',
        );
      }
      // Reuse command validation without creating a pending action or effect.
      EventAssistanceDepartureChange.prepare(
        snapshot: session.view,
        operationId: 'departure:review',
        destination: form.destination!,
        roster: form.roster,
        checkpoint: request,
      );
    }
    state = EventDepartureForm._(
      session: session,
      destination: form.destination,
      selection: form.selection,
      roster: form.roster,
      checkpoint: request,
    );
  }

  Future<EventAssistanceDepartureRosterReview> reviewRoster() {
    if (_revoked) return Future.error(departureSessionChanged);
    if (_review case final pending?) return pending;
    final form = _form;
    if (form == null || !form.canReviewRoster) {
      return Future.error(
        const ValidationException(
          'Choose the people whose departure you observed.',
        ),
      );
    }
    final reviewing = EventDepartureForm._(
      session: session,
      destination: form.destination,
      selection: form.selection,
      phase: EventDepartureFormPhase.reviewingRoster,
    );
    state = reviewing;
    late final Future<EventAssistanceDepartureRosterReview> tracked;
    tracked = _reviewRoster(reviewing).whenComplete(() {
      if (identical(_review, tracked)) _review = null;
    });
    _review = tracked;
    return tracked;
  }

  Future<EventAssistanceDepartureRosterReview> _reviewRoster(
    EventDepartureForm reviewing,
  ) async {
    try {
      final roster = await ref
          .read(eventAssistanceDepartureControllerProvider.notifier)
          .reviewRoster(session, reviewing.selection!);
      if (ref.mounted && !_revoked && identical(state, reviewing)) {
        state = EventDepartureForm._(
          session: session,
          destination: reviewing.destination,
          selection: reviewing.selection,
          roster: roster,
        );
      }
      return roster;
    } catch (error) {
      if (ref.mounted && !_revoked && identical(state, reviewing)) {
        state = reviewing._withPhase(
          _needsFreshReview(error)
              ? EventDepartureFormPhase.refreshRequired
              : EventDepartureFormPhase.choosing,
          error: error,
        );
      }
      rethrow;
    }
  }

  /// One decision, one in-flight request and one operation ID across retries.
  Future<EventAssistanceGroupProgressResult> submit() {
    if (_revoked) return Future.error(departureSessionChanged);
    if (_confirmation case final pending?) return pending;
    final form = _form;
    if (form?.result case final result?) return Future.value(result);
    if (form == null || !form.canSubmit) {
      return Future.error(
        const ValidationException(
          'Review the departure details before confirming.',
        ),
      );
    }
    late final EventDeparturePendingAction action;
    try {
      action =
          form.action ??
          ref
              .read(eventAssistanceDepartureControllerProvider.notifier)
              .prepare(
                session: session,
                destination: form.destination!,
                roster: form.roster,
                checkpoint: form.checkpoint,
              );
    } catch (error, stack) {
      state = form._withPhase(
        EventDepartureFormPhase.refreshRequired,
        error: error,
      );
      return Future.error(error, stack);
    }
    final submitted = form._withPhase(
      EventDepartureFormPhase.submitting,
      action: action,
    );
    state = submitted;
    late final Future<EventAssistanceGroupProgressResult> tracked;
    tracked = _confirm(submitted, action).whenComplete(() {
      if (identical(_confirmation, tracked)) _confirmation = null;
    });
    _confirmation = tracked;
    return tracked;
  }

  Future<EventAssistanceGroupProgressResult> _confirm(
    EventDepartureForm submitted,
    EventDeparturePendingAction action,
  ) async {
    try {
      final result = await ref
          .read(eventAssistanceDepartureControllerProvider.notifier)
          .confirm(action);
      if (ref.mounted && !_revoked) {
        state = submitted._withPhase(
          EventDepartureFormPhase.saved,
          result: result,
        );
      }
      return result;
    } catch (error) {
      if (ref.mounted && !_revoked) {
        state = submitted._withPhase(
          _needsFreshReview(error)
              ? EventDepartureFormPhase.refreshRequired
              : EventDepartureFormPhase.retryRequired,
          error: error,
        );
      }
      rethrow;
    }
  }
}

bool _needsFreshReview(Object error) =>
    error is AppException &&
    {
      'aborted',
      'permission-denied',
      'sign-in-required',
      'session-changed',
      'failed-precondition',
      'not-found',
      'invalid-argument',
    }.contains(error.code);
