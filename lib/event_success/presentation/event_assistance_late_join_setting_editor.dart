import 'dart:math';

import 'package:catch_dating_app/event_success/data/event_assistance_late_join_setting_repository.dart';
import 'package:catch_dating_app/event_success/domain/event_assistance_late_join_setting.dart';
import 'package:catch_dating_app/event_success/domain/event_assistance_late_join_setting_result.dart';
import 'package:catch_dating_app/event_success/presentation/event_assistance_account.dart';
import 'package:catch_dating_app/event_success/presentation/event_assistance_late_join_setting_provider.dart';
import 'package:catch_dating_app/exceptions/app_exception.dart';
import 'package:flutter_riverpod/experimental/mutation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'event_assistance_late_join_setting_editor.g.dart';

enum LateJoinSettingEditorPhase {
  choosing,
  submitting,
  retryRequired,
  refreshRequired,
  saved,
}

sealed class LateJoinSettingEditorState {
  const LateJoinSettingEditorState();
  bool get canDismiss => switch (this) {
    LateJoinSettingForm(:final phase) =>
      phase != LateJoinSettingEditorPhase.submitting,
    LateJoinSettingFormUnavailable() => true,
  };
}

final class LateJoinSettingFormUnavailable extends LateJoinSettingEditorState {
  const LateJoinSettingFormUnavailable._(this.error);
  final Object error;
}

final class LateJoinSettingForm extends LateJoinSettingEditorState {
  const LateJoinSettingForm._({
    required this.review,
    this.decision,
    this.phase = LateJoinSettingEditorPhase.choosing,
    this.change,
    this.result,
    this.error,
  });
  final LateJoinSettingSession review;
  final LateJoinPreference? decision;
  final LateJoinSettingEditorPhase phase;
  final LateJoinSettingChange? change;
  final LateJoinSettingResult? result;
  final Object? error;

  bool get canEdit => phase == LateJoinSettingEditorPhase.choosing;
  bool get canSubmit =>
      (canEdit && decision != null) ||
      phase == LateJoinSettingEditorPhase.retryRequired;
  bool get canReload => canDismiss && phase != LateJoinSettingEditorPhase.saved;

  LateJoinSettingForm _after(
    LateJoinSettingEditorPhase phase, {
    required LateJoinSettingChange change,
    LateJoinSettingResult? result,
    Object? error,
  }) => LateJoinSettingForm._(
    review: review,
    decision: decision,
    phase: phase,
    change: change,
    result: result,
    error: error,
  );
}

/// One reviewed preference. Suggestions remain unselected until an explicit
/// host choice; uncertain saves retain the exact request and review basis.
@riverpod
class EventAssistanceLateJoinSettingEditor
    extends _$EventAssistanceLateJoinSettingEditor {
  static final changeMutation = Mutation<LateJoinSettingResult>();
  Future<LateJoinSettingResult>? _inFlight;
  bool _revoked = false;

  @override
  LateJoinSettingEditorState build(LateJoinSettingSession review) {
    ref.listen(eventAssistanceAccountProvider, (_, next) {
      if (!identical(next.asData?.value, review.account) ||
          next.isLoading ||
          next.hasError) {
        _revoked = true;
        state = const LateJoinSettingFormUnavailable._(
          settingReviewSessionChanged,
        );
      }
    });
    final current = ref.read(eventAssistanceAccountProvider);
    if (_revoked ||
        current.isLoading ||
        current.hasError ||
        !identical(current.asData?.value, review.account)) {
      _revoked = true;
      return const LateJoinSettingFormUnavailable._(
        settingReviewSessionChanged,
      );
    }
    return LateJoinSettingForm._(review: review);
  }

  LateJoinSettingForm? get _form => switch (state) {
    final LateJoinSettingForm form when !_revoked => form,
    LateJoinSettingForm() || LateJoinSettingFormUnavailable() => null,
  };

  void select(LateJoinPreference decision) {
    final form = _form;
    if (form == null || !form.canEdit) return;
    requireSettingReviewAccount(ref, review.account);
    state = LateJoinSettingForm._(review: review, decision: decision);
  }

  Future<LateJoinSettingResult> submit() {
    final form = _form;
    if (form == null) return Future.error(settingReviewSessionChanged);
    if (_inFlight case final pending?) return pending;
    if (form.result case final result?) return Future.value(result);
    if (!form.canSubmit) {
      return Future.error(
        const ValidationException('Choose a late arrival setting.'),
      );
    }
    try {
      requireSettingReviewAccount(ref, review.account);
      final change =
          form.change ??
          review.view.prepareChange(
            requestId: _newOperationId(),
            preference: form.decision!,
          );
      final submitted = form._after(
        LateJoinSettingEditorPhase.submitting,
        change: change,
      );
      state = submitted;
      final keepAlive = ref.keepAlive();
      late final Future<LateJoinSettingResult> tracked;
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

  Future<LateJoinSettingResult> _submit(
    LateJoinSettingForm submitted,
    LateJoinSettingChange change,
  ) async {
    try {
      final result = await ref
          .read(eventAssistanceLateJoinSettingRepositoryProvider)
          .apply(change);
      requireSettingReviewAccount(ref, review.account);
      if (_revoked) throw settingReviewSessionChanged;
      state = submitted._after(
        LateJoinSettingEditorPhase.saved,
        change: change,
        result: result,
      );
      ref.invalidate(eventAssistanceLateJoinSettingForAccountProvider);
      return result;
    } catch (error) {
      if (ref.mounted && !_revoked) {
        state = submitted._after(
          _needsFreshReview(error)
              ? LateJoinSettingEditorPhase.refreshRequired
              : LateJoinSettingEditorPhase.retryRequired,
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
  return 'setting:${List.generate(16, (_) => random.nextInt(256).toRadixString(16).padLeft(2, '0')).join()}';
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
