import 'dart:math';

import 'package:catch_dating_app/auth/data/authenticated_session.dart';
import 'package:catch_dating_app/event_rehearsal/data/event_rehearsal_repository.dart';
import 'package:catch_dating_app/event_rehearsal/domain/event_rehearsal.dart';
import 'package:catch_dating_app/event_rehearsal/domain/event_rehearsal_assistance_command.dart';
import 'package:catch_dating_app/event_rehearsal/domain/event_rehearsal_publication.dart';
import 'package:catch_dating_app/event_rehearsal/presentation/event_rehearsal_assistance_provider.dart';
import 'package:catch_dating_app/exceptions/app_exception.dart';
import 'package:flutter_riverpod/experimental/mutation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'event_rehearsal_assistance_editor.g.dart';

enum RehearsalAssistancePhase {
  choosing,
  submitting,
  retryRequired,
  refreshRequired,
  applied,
}

sealed class RehearsalAssistanceEditorState {
  const RehearsalAssistanceEditorState();
  bool get canDismiss => switch (this) {
    RehearsalAssistanceForm(:final phase) =>
      phase != RehearsalAssistancePhase.submitting,
    RehearsalAssistanceUnavailable() => true,
  };
}

final class RehearsalAssistanceUnavailable
    extends RehearsalAssistanceEditorState {
  const RehearsalAssistanceUnavailable._(this.error);
  final Object error;
}

final class RehearsalAssistanceForm extends RehearsalAssistanceEditorState {
  const RehearsalAssistanceForm._({
    required this.review,
    this.change,
    this.phase = RehearsalAssistancePhase.choosing,
    this.result,
    this.error,
  });
  final RehearsalAssistanceReview review;
  final RehearsalAssistanceChange? change;
  final RehearsalAssistancePhase phase;
  final EventRehearsalBootstrap? result;
  final Object? error;
  bool get canEdit => phase == RehearsalAssistancePhase.choosing;
  bool get canSubmit =>
      canEdit && change != null ||
      phase == RehearsalAssistancePhase.retryRequired;
  bool get canReload => canDismiss && phase != RehearsalAssistancePhase.applied;
  RehearsalAssistanceForm _after(
    RehearsalAssistancePhase phase, {
    EventRehearsalBootstrap? result,
    Object? error,
  }) => RehearsalAssistanceForm._(
    review: review,
    change: change,
    phase: phase,
    result: result,
    error: error,
  );
}

/// One reviewed practice command. Applied means its action receipt was verified;
/// it never promotes an accepted send or reported intention into delivery/arrival.
@riverpod
class EventRehearsalAssistanceEditor extends _$EventRehearsalAssistanceEditor {
  static final applyMutation = Mutation<EventRehearsalBootstrap>();
  Future<EventRehearsalBootstrap>? _inFlight;
  bool _revoked = false;
  void Function()? _releaseReview;

  @override
  RehearsalAssistanceEditorState build(RehearsalAssistanceReview review) {
    ref.listen(authenticatedSessionProvider, (_, next) {
      if (next.isLoading ||
          next.hasError ||
          !identical(next.asData?.value, review.account)) {
        _revoked = true;
        state = const RehearsalAssistanceUnavailable._(
          rehearsalReviewSessionChanged,
        );
        _releasePendingReview();
      }
    });
    ref.listen(
      eventRehearsalAssistanceForAccountProvider(
        review.snapshot.session.id,
        account: review.account,
      ),
      (_, next) {
        if (_revoked || state is! RehearsalAssistanceForm) return;
        final form = state as RehearsalAssistanceForm;
        if (next.isLoading ||
            next.hasError ||
            !identical(next.asData?.value, review)) {
          if (form.phase != RehearsalAssistancePhase.submitting &&
              form.phase != RehearsalAssistancePhase.applied) {
            state = form._after(
              RehearsalAssistancePhase.refreshRequired,
              error: rehearsalReviewExpired,
            );
          }
          _releasePendingReview();
        }
      },
    );
    try {
      requireRehearsalReviewAccount(ref, review.account);
      if (_revoked) throw rehearsalReviewSessionChanged;
    } catch (error) {
      _revoked = true;
      return RehearsalAssistanceUnavailable._(error);
    }
    return RehearsalAssistanceForm._(
      review: review,
      phase: review.isCurrent
          ? RehearsalAssistancePhase.choosing
          : RehearsalAssistancePhase.refreshRequired,
      error: review.isCurrent ? null : rehearsalReviewExpired,
    );
  }

  RehearsalAssistanceForm? get _form => switch (state) {
    final RehearsalAssistanceForm form when !_revoked => form,
    _ => null,
  };

  void select(RehearsalAssistanceCommand? command) => _select(() => command);

  void selectPublication(RehearsalPublicationDraft draft) =>
      _select(() => draft.prepare(review.snapshot));

  void _select(RehearsalAssistanceCommand? Function() resolve) {
    final form = _form;
    if (form == null || !form.canEdit) return;
    try {
      _requireCurrentReview();
      final command = resolve();
      final change = command == null
          ? null
          : RehearsalAssistanceChange(
              snapshot: review.snapshot,
              command: command,
              clientActionId: _newActionId(),
            );
      state = RehearsalAssistanceForm._(review: review, change: change);
    } catch (error) {
      if (ref.mounted && !_revoked) {
        state = RehearsalAssistanceForm._(
          review: review,
          error: error,
          phase: review.isCurrent
              ? RehearsalAssistancePhase.choosing
              : RehearsalAssistancePhase.refreshRequired,
        );
      }
    }
  }

  Future<EventRehearsalBootstrap> submit() {
    try {
      _requireAccount();
    } catch (error, stackTrace) {
      return Future.error(error, stackTrace);
    }
    final form = _form;
    if (form == null) return Future.error(rehearsalReviewSessionChanged);
    if (_inFlight case final pending?) return pending;
    if (form.result case final result?) return Future.value(result);
    if (!form.canSubmit) {
      return Future.error(
        const ValidationException(
          'Choose a practice action before continuing.',
        ),
      );
    }
    try {
      _requireCurrentReview();
      final submitted = form._after(RehearsalAssistancePhase.submitting);
      // Retain uncertain intent across a dismissed review in this app session.
      _releaseReview ??= ref.keepAlive().close;
      state = submitted;
      final keepAlive = ref.keepAlive();
      late final Future<EventRehearsalBootstrap> tracked;
      tracked = _submit(submitted).whenComplete(() {
        if (identical(_inFlight, tracked)) _inFlight = null;
        keepAlive.close();
      });
      _inFlight = tracked;
      return tracked;
    } catch (error, stackTrace) {
      if (ref.mounted && !_revoked) {
        state = form._after(
          RehearsalAssistancePhase.refreshRequired,
          error: error,
        );
      }
      return Future.error(error, stackTrace);
    }
  }

  void _releasePendingReview() {
    final release = _releaseReview;
    _releaseReview = null;
    release?.call();
  }

  void _requireAccount() {
    try {
      requireRehearsalReviewAccount(ref, review.account);
      if (_revoked) throw rehearsalReviewSessionChanged;
    } catch (error) {
      _revoked = true;
      if (ref.mounted) state = RehearsalAssistanceUnavailable._(error);
      _releasePendingReview();
      rethrow;
    }
  }

  void _requireCurrentReview() {
    _requireAccount();
    if (!review.isCurrent) throw rehearsalReviewExpired;
  }

  Future<EventRehearsalBootstrap> _submit(
    RehearsalAssistanceForm submitted,
  ) async {
    try {
      _requireCurrentReview();
      final result = await ref
          .read(eventRehearsalRepositoryProvider)
          .applyAssistance(submitted.change!);
      _requireCurrentReview();
      state = submitted._after(
        RehearsalAssistancePhase.applied,
        result: result,
      );
      _releasePendingReview();
      ref.invalidate(eventRehearsalProvider(review.snapshot.session.id));
      ref.invalidate(
        eventRehearsalAssistanceForAccountProvider(
          review.snapshot.session.id,
          account: review.account,
        ),
      );
      return result;
    } catch (error) {
      if (_revoked || !ref.mounted) throw rehearsalReviewSessionChanged;
      if (ref.mounted) {
        final refresh = !review.isCurrent || _needsFreshReview(error);
        state = submitted._after(
          refresh
              ? RehearsalAssistancePhase.refreshRequired
              : RehearsalAssistancePhase.retryRequired,
          error: error,
        );
        if (refresh) _releasePendingReview();
      }
      rethrow;
    }
  }
}

String _newActionId() {
  final random = Random.secure();
  return 'practice_${List.generate(16, (_) => random.nextInt(256).toRadixString(16).padLeft(2, '0')).join()}';
}

bool _needsFreshReview(Object error) =>
    error is AppException &&
    {
      'aborted',
      'permission-denied',
      'sign-in-required',
      'session-changed',
      'review-changed',
      'failed-precondition',
      'not-found',
      'invalid-argument',
      'resource-exhausted',
    }.contains(error.code);
