import 'dart:math';

import 'package:catch_dating_app/event_success/data/event_assistance_runtime_repository.dart';
import 'package:catch_dating_app/event_success/domain/event_assistance_runtime_result.dart';
import 'package:catch_dating_app/event_success/domain/event_assistance_runtime_setting.dart';
import 'package:catch_dating_app/event_success/presentation/event_assistance_account.dart';
import 'package:catch_dating_app/event_success/presentation/event_assistance_runtime_provider.dart';
import 'package:catch_dating_app/exceptions/app_exception.dart';
import 'package:flutter_riverpod/experimental/mutation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'event_assistance_runtime_editor.g.dart';

enum AssistanceRuntimeEditorPhase {
  choosing,
  submitting,
  retryRequired,
  refreshRequired,
  saved,
}

sealed class AssistanceRuntimeEditorState {
  const AssistanceRuntimeEditorState();
  bool get canDismiss => switch (this) {
    AssistanceRuntimeForm(:final phase) =>
      phase != AssistanceRuntimeEditorPhase.submitting,
    AssistanceRuntimeFormUnavailable() => true,
  };
}

final class AssistanceRuntimeFormUnavailable
    extends AssistanceRuntimeEditorState {
  const AssistanceRuntimeFormUnavailable._(this.error);
  final Object error;
}

final class AssistanceRuntimeForm extends AssistanceRuntimeEditorState {
  const AssistanceRuntimeForm._({
    required this.review,
    this.decision,
    this.phase = AssistanceRuntimeEditorPhase.choosing,
    this.change,
    this.result,
    this.error,
  });
  final AssistanceRuntimeSession review;
  final AssistanceRuntimeCommand? decision;
  final AssistanceRuntimeEditorPhase phase;
  final AssistanceRuntimeChange? change;
  final AssistanceRuntimeResult? result;
  final Object? error;

  bool get canEdit => phase == AssistanceRuntimeEditorPhase.choosing;
  bool get canSubmit =>
      (canEdit && decision != null) ||
      phase == AssistanceRuntimeEditorPhase.retryRequired;
  bool get canReload =>
      canDismiss && phase != AssistanceRuntimeEditorPhase.saved;

  AssistanceRuntimeForm _after(
    AssistanceRuntimeEditorPhase phase, {
    required AssistanceRuntimeChange change,
    AssistanceRuntimeResult? result,
    Object? error,
  }) => AssistanceRuntimeForm._(
    review: review,
    decision: decision,
    phase: phase,
    change: change,
    result: result,
    error: error,
  );
}

/// One explicit configure or pause decision. Uncertain saves retain the exact
/// request; saving permission does not report enrollment or provider delivery.
@riverpod
class EventAssistanceRuntimeEditor extends _$EventAssistanceRuntimeEditor {
  static final changeMutation = Mutation<AssistanceRuntimeResult>();
  Future<AssistanceRuntimeResult>? _inFlight;
  bool _revoked = false;

  @override
  AssistanceRuntimeEditorState build(AssistanceRuntimeSession review) {
    ref.listen(eventAssistanceAccountProvider, (_, next) {
      if (!identical(next.asData?.value, review.account) ||
          next.isLoading ||
          next.hasError) {
        _revoked = true;
        state = const AssistanceRuntimeFormUnavailable._(
          runtimeReviewSessionChanged,
        );
      }
    });
    final current = ref.read(eventAssistanceAccountProvider);
    if (_revoked ||
        current.isLoading ||
        current.hasError ||
        !identical(current.asData?.value, review.account)) {
      _revoked = true;
      return const AssistanceRuntimeFormUnavailable._(
        runtimeReviewSessionChanged,
      );
    }
    return AssistanceRuntimeForm._(review: review);
  }

  AssistanceRuntimeForm? get _form => switch (state) {
    final AssistanceRuntimeForm form when !_revoked => form,
    AssistanceRuntimeForm() || AssistanceRuntimeFormUnavailable() => null,
  };

  void select(AssistanceRuntimeCommand decision) {
    final form = _form;
    if (form == null || !form.canEdit) return;
    requireRuntimeReviewAccount(ref, review.account);
    state = AssistanceRuntimeForm._(review: review, decision: decision);
  }

  Future<AssistanceRuntimeResult> submit() {
    final form = _form;
    if (form == null) return Future.error(runtimeReviewSessionChanged);
    if (_inFlight case final pending?) return pending;
    if (form.result case final result?) return Future.value(result);
    if (!form.canSubmit) {
      return Future.error(
        const ValidationException(
          'Choose whether to configure or pause event automation.',
        ),
      );
    }
    try {
      requireRuntimeReviewAccount(ref, review.account);
      final change =
          form.change ??
          review.view.prepareChange(
            requestId: _newOperationId(),
            command: form.decision!,
          );
      final submitted = form._after(
        AssistanceRuntimeEditorPhase.submitting,
        change: change,
      );
      state = submitted;
      final keepAlive = ref.keepAlive();
      late final Future<AssistanceRuntimeResult> tracked;
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

  Future<AssistanceRuntimeResult> _submit(
    AssistanceRuntimeForm submitted,
    AssistanceRuntimeChange change,
  ) async {
    try {
      final result = await ref
          .read(eventAssistanceRuntimeRepositoryProvider)
          .apply(change);
      requireRuntimeReviewAccount(ref, review.account);
      if (_revoked) throw runtimeReviewSessionChanged;
      state = submitted._after(
        AssistanceRuntimeEditorPhase.saved,
        change: change,
        result: result,
      );
      ref.invalidate(eventAssistanceRuntimeForAccountProvider);
      return result;
    } catch (error) {
      if (ref.mounted && !_revoked) {
        state = submitted._after(
          _needsFreshReview(error)
              ? AssistanceRuntimeEditorPhase.refreshRequired
              : AssistanceRuntimeEditorPhase.retryRequired,
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
  return 'runtime:${List.generate(16, (_) => random.nextInt(256).toRadixString(16).padLeft(2, '0')).join()}';
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
