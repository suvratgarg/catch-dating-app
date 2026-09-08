import 'dart:math';

import 'package:catch_dating_app/event_success/data/event_assistance_cases_repository.dart';
import 'package:catch_dating_app/event_success/domain/event_assistance_case_change.dart';
import 'package:catch_dating_app/event_success/presentation/event_assistance_account.dart';
import 'package:catch_dating_app/event_success/presentation/event_assistance_cases_provider.dart';
import 'package:catch_dating_app/exceptions/app_exception.dart';
import 'package:flutter_riverpod/experimental/mutation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'event_assistance_case_editor.g.dart';

enum AssistanceCaseEditorPhase {
  choosing,
  submitting,
  retryRequired,
  refreshRequired,
  saved,
}

sealed class AssistanceCaseEditorState {
  const AssistanceCaseEditorState();
  bool get canDismiss => switch (this) {
    AssistanceCaseForm(:final phase) =>
      phase != AssistanceCaseEditorPhase.submitting,
    AssistanceCaseFormUnavailable() => true,
  };
}

final class AssistanceCaseFormUnavailable extends AssistanceCaseEditorState {
  const AssistanceCaseFormUnavailable._(this.error);
  final Object error;
}

final class AssistanceCaseForm extends AssistanceCaseEditorState {
  const AssistanceCaseForm._({
    required this.review,
    this.decision,
    this.phase = AssistanceCaseEditorPhase.choosing,
    this.change,
    this.result,
    this.error,
  });
  final EventAssistanceCaseReview review;
  final AssistanceCaseDecision? decision;
  final AssistanceCaseEditorPhase phase;
  final EventAssistanceCaseChange? change;
  final EventAssistanceCaseResult? result;
  final Object? error;

  bool get canEdit => phase == AssistanceCaseEditorPhase.choosing;
  bool get canSubmit =>
      (canEdit && decision != null) ||
      phase == AssistanceCaseEditorPhase.retryRequired;
  bool get canReload => canDismiss && phase != AssistanceCaseEditorPhase.saved;

  AssistanceCaseForm _after(
    AssistanceCaseEditorPhase phase, {
    required EventAssistanceCaseChange change,
    EventAssistanceCaseResult? result,
    Object? error,
  }) => AssistanceCaseForm._(
    review: review,
    decision: decision,
    phase: phase,
    change: change,
    result: result,
    error: error,
  );
}

/// One reviewed case decision. No implicit default, changed retry, or local
/// optimistic settlement; the response always supplies the current case state.
@riverpod
class EventAssistanceCaseEditor extends _$EventAssistanceCaseEditor {
  static final changeMutation = Mutation<EventAssistanceCaseResult>();
  Future<EventAssistanceCaseResult>? _inFlight;
  bool _revoked = false;

  @override
  AssistanceCaseEditorState build(EventAssistanceCaseReview review) {
    ref.listen(eventAssistanceAccountProvider, (_, next) {
      if (!identical(next.asData?.value, review.account) ||
          next.isLoading ||
          next.hasError) {
        _revoked = true;
        state = const AssistanceCaseFormUnavailable._(caseReviewSessionChanged);
      }
    });
    final current = ref.read(eventAssistanceAccountProvider);
    if (_revoked ||
        current.isLoading ||
        current.hasError ||
        !identical(current.asData?.value, review.account)) {
      _revoked = true;
      return const AssistanceCaseFormUnavailable._(caseReviewSessionChanged);
    }
    return AssistanceCaseForm._(review: review);
  }

  AssistanceCaseForm? get _form => switch (state) {
    final AssistanceCaseForm form when !_revoked => form,
    AssistanceCaseForm() || AssistanceCaseFormUnavailable() => null,
  };

  void select(AssistanceCaseDecision decision) {
    final form = _form;
    if (form == null || !form.canEdit) return;
    requireCaseReviewAccount(ref, review.account);
    state = AssistanceCaseForm._(review: review, decision: decision);
  }

  Future<EventAssistanceCaseResult> submit() {
    final form = _form;
    if (form == null) return Future.error(caseReviewSessionChanged);
    if (_inFlight case final pending?) return pending;
    if (form.result case final result?) return Future.value(result);
    if (!form.canSubmit) {
      return Future.error(
        const ValidationException('Choose a help request action.'),
      );
    }
    try {
      requireCaseReviewAccount(ref, review.account);
      final change =
          form.change ??
          EventAssistanceCaseChange(
            snapshot: review.request,
            actorUid: review.account.uid,
            operationId: _newOperationId(),
            decision: form.decision!,
          );
      final submitted = form._after(
        AssistanceCaseEditorPhase.submitting,
        change: change,
      );
      state = submitted;
      final keepAlive = ref.keepAlive();
      late final Future<EventAssistanceCaseResult> tracked;
      tracked = _submit(submitted, change).whenComplete(() {
        if (identical(_inFlight, tracked)) _inFlight = null;
        keepAlive.close();
      });
      _inFlight = tracked;
      return tracked;
    } catch (error, stackTrace) {
      return Future.error(error, stackTrace);
    }
  }

  Future<EventAssistanceCaseResult> _submit(
    AssistanceCaseForm submitted,
    EventAssistanceCaseChange change,
  ) async {
    try {
      final result = await ref
          .read(eventAssistanceCasesRepositoryProvider)
          .apply(change);
      requireCaseReviewAccount(ref, review.account);
      if (_revoked) throw caseReviewSessionChanged;
      state = submitted._after(
        AssistanceCaseEditorPhase.saved,
        change: change,
        result: result,
      );
      ref.invalidate(eventAssistanceCasesForAccountProvider);
      return result;
    } catch (error) {
      if (ref.mounted && !_revoked) {
        state = submitted._after(
          _needsFreshReview(error)
              ? AssistanceCaseEditorPhase.refreshRequired
              : AssistanceCaseEditorPhase.retryRequired,
          change: change,
          error: error,
        );
      }
      rethrow;
    }
  }
}

String _newOperationId() {
  final random = Random.secure();
  return 'case:${List.generate(16, (_) => random.nextInt(256).toRadixString(16).padLeft(2, '0')).join()}';
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
