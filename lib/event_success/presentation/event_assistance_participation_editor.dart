import 'package:catch_dating_app/event_success/domain/event_assistance_participation.dart';
import 'package:catch_dating_app/event_success/presentation/event_assistance_participation_controller.dart';
import 'package:catch_dating_app/exceptions/app_exception.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'event_assistance_participation_editor.g.dart';

enum EventParticipationChoice { active, temporaryBreak, departed }

enum EventParticipationEditorPhase {
  choosing,
  submitting,
  retryRequired,
  refreshRequired,
  saved,
}

/// One guest-level decision. A submitted choice remains frozen until it has
/// been reconciled or the caller explicitly loads a new authoritative session.
final class EventParticipationEditorState {
  const EventParticipationEditorState._({
    required this.session,
    this.choice,
    this.returnPointId,
    this.phase = EventParticipationEditorPhase.choosing,
    this.pendingAction,
    this.result,
    this.error,
  });

  final EventParticipationSession session;
  final EventParticipationChoice? choice;
  final String? returnPointId;
  final EventParticipationEditorPhase phase;
  final EventParticipationPendingAction? pendingAction;
  final EventAssistanceParticipationResult? result;
  final Object? error;

  bool get canEdit =>
      phase == EventParticipationEditorPhase.choosing && session.view.canChange;
  bool get canSubmit =>
      (canEdit && choice != null) ||
      phase == EventParticipationEditorPhase.retryRequired;
  bool get canDismiss => phase != EventParticipationEditorPhase.submitting;
  bool get canReload =>
      canDismiss && phase != EventParticipationEditorPhase.saved;
  bool get showsReturnPoint =>
      choice == EventParticipationChoice.temporaryBreak &&
      session.view.returnPoints.isNotEmpty;

  EventAssistanceParticipation get participation => switch (choice) {
    EventParticipationChoice.active =>
      const EventAssistanceParticipation.active(),
    EventParticipationChoice.temporaryBreak =>
      EventAssistanceParticipation.onBreak(resumeAtUnit: returnPointId),
    EventParticipationChoice.departed =>
      const EventAssistanceParticipation.departed(),
    null => throw const ValidationException('Choose a participation change.'),
  };

  EventParticipationEditorState _afterSubmission({
    required EventParticipationEditorPhase phase,
    required EventParticipationPendingAction action,
    EventAssistanceParticipationResult? result,
    Object? error,
  }) => EventParticipationEditorState._(
    session: session,
    choice: choice,
    returnPointId: returnPointId,
    phase: phase,
    pendingAction: action,
    result: result,
    error: error,
  );
}

@riverpod
class EventAssistanceParticipationEditor
    extends _$EventAssistanceParticipationEditor {
  Future<EventAssistanceParticipationResult>? _inFlight;

  @override
  EventParticipationEditorState build(EventParticipationSession session) {
    // Retain the action owner while this editor or its Mutation is alive.
    ref.watch(eventAssistanceParticipationControllerProvider);
    return EventParticipationEditorState._(session: session);
  }

  void select(EventParticipationChoice choice) {
    if (!state.canEdit) return;
    state = EventParticipationEditorState._(
      session: session,
      choice: choice,
      returnPointId: choice == EventParticipationChoice.temporaryBreak
          ? state.returnPointId
          : null,
    );
  }

  void selectReturnPoint(String? unitId) {
    if (!state.canEdit) return;
    if (state.choice != EventParticipationChoice.temporaryBreak ||
        (unitId != null &&
            !session.view.returnPoints.any((p) => p.unitId == unitId))) {
      throw ArgumentError('Choose a return point from this event snapshot.');
    }
    state = EventParticipationEditorState._(
      session: session,
      choice: state.choice,
      returnPointId: unitId,
    );
  }

  /// Duplicate triggers share the same future. A transport retry uses the
  /// frozen command; a source conflict requires a newly loaded session.
  Future<EventAssistanceParticipationResult> submit() {
    if (_inFlight case final pending?) return pending;
    if (state.result case final result?) return Future.value(result);
    if (!state.canSubmit) {
      return Future.error(
        const ValidationException(
          'Review the current guest and choose a participation change.',
        ),
      );
    }
    final action =
        state.pendingAction ??
        ref
            .read(eventAssistanceParticipationControllerProvider.notifier)
            .prepare(session: session, participation: state.participation);
    final submitted = state._afterSubmission(
      phase: EventParticipationEditorPhase.submitting,
      action: action,
    );
    state = submitted;
    late final Future<EventAssistanceParticipationResult> tracked;
    tracked = _submit(submitted, action).whenComplete(() {
      if (identical(_inFlight, tracked)) _inFlight = null;
    });
    _inFlight = tracked;
    return tracked;
  }

  Future<EventAssistanceParticipationResult> _submit(
    EventParticipationEditorState submitted,
    EventParticipationPendingAction action,
  ) async {
    try {
      final result = await ref
          .read(eventAssistanceParticipationControllerProvider.notifier)
          .submit(action);
      if (ref.mounted) {
        state = submitted._afterSubmission(
          phase: EventParticipationEditorPhase.saved,
          action: action,
          result: result,
        );
      }
      return result;
    } catch (error) {
      if (ref.mounted) {
        state = submitted._afterSubmission(
          phase: _needsFreshReview(error)
              ? EventParticipationEditorPhase.refreshRequired
              : EventParticipationEditorPhase.retryRequired,
          action: action,
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
    }.contains(error.code);
