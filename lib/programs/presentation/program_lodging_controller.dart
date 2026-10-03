import 'dart:math';

import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/exceptions/app_exception.dart';
import 'package:catch_dating_app/programs/data/program_lodging_providers.dart';
import 'package:catch_dating_app/programs/data/program_lodging_repository.dart';
import 'package:catch_dating_app/programs/data/program_projection_lifetime.dart';
import 'package:catch_dating_app/programs/domain/program_lodging_board.dart';
import 'package:catch_dating_app/programs/domain/program_lodging_review.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'program_lodging_controller.g.dart';

class ProgramLodgingView {
  const ProgramLodgingView({
    required this.setup,
    this.review,
    this.busy = false,
    this.error,
    this.retryAction,
  });
  final ProgramLodgingSetup setup;
  final ProgramLodgingReview? review;
  final bool busy;
  final Object? error;
  final ProgramLodgingAction? retryAction;

  ProgramLodgingView pending() => ProgramLodgingView(
    setup: setup,
    review: review,
    busy: true,
    retryAction: retryAction,
  );
}

class _LodgingPendingCommand {
  _LodgingPendingCommand(this.proposal, this.action, this.revision)
    : operationId =
          'lodging_${List.generate(4, (_) => Random.secure().nextInt(1 << 32).toRadixString(16).padLeft(8, '0')).join()}';
  final ProgramLodgingProposal proposal;
  final ProgramLodgingAction action;
  final int revision;
  final String operationId;
  bool saved = false;
}

/// One state owner fences every async result and retains an uncertain command
/// verbatim for retry. Authority loss/disposal clears private planning data.
@riverpod
class ProgramLodgingController extends _$ProgramLodgingController {
  var _epoch = 0;
  _LodgingPendingCommand? _command;
  late String _programId;

  ProgramLodgingRepository get _repository =>
      ref.read(programLodgingRepositoryProvider);

  @override
  Future<ProgramLodgingView> build(String programId) async {
    _programId = programId;
    _epoch++;
    _command = null;
    ref.onDispose(() => _epoch++);
    final account = ref.watch(uidProvider).asData?.value;
    if (account == null || account.isEmpty) {
      throw const SignInRequiredException('manage hotel rooms');
    }
    ref.watch(programLodgingRepositoryProvider);
    final view = await readWithProgramAuthority(
      ref,
      account,
      programId,
      () async {
        final setup = await _repository.readSetup(programId);
        if (setup.configuration == null) {
          return ProgramLodgingView(setup: setup);
        }
        return _reviewView(await _repository.preview(programId));
      },
      onAuthorityChanged: () {
        _epoch++;
        _command = null;
      },
    );
    retainProgramProjection(
      ref,
      view.setup.accessExpiresAt,
      onExpiry: () {
        _epoch++;
        _command = null;
      },
    );
    return view;
  }

  ProgramLodgingView _current([String? proposalId]) {
    final view = state.asData?.value;
    if (view == null ||
        view.busy ||
        (proposalId != null && view.review?.proposal.id != proposalId)) {
      throw programReadSuperseded;
    }
    return view;
  }

  void _ensureEditing() {
    if (_command != null) {
      throw StateError('Retry the pending lodging decision first.');
    }
  }

  Future<T> _run<T>(
    ProgramLodgingView view,
    Future<T> Function() operation,
    ProgramLodgingView Function(T) next,
  ) async {
    final epoch = ++_epoch;
    state = AsyncData(view.pending());
    try {
      final result = await operation();
      if (!ref.mounted || epoch != _epoch) throw programReadSuperseded;
      state = AsyncData(next(result));
      return result;
    } catch (error) {
      if (ref.mounted && epoch == _epoch) {
        state = AsyncData(
          ProgramLodgingView(
            setup: view.setup,
            review: view.review,
            error: error,
            retryAction: _command?.action,
          ),
        );
      }
      rethrow;
    }
  }

  void refresh() {
    _ensureEditing();
    _current();
    ref.invalidateSelf(asReload: true);
  }

  Future<void> regenerate() async {
    _ensureEditing();
    await _run(_current(), () => _repository.preview(_programId), _reviewView);
  }

  Future<List<ProgramLodgingDestination>> destinations(
    String proposalId,
    String partyId,
  ) {
    _ensureEditing();
    final view = _current(proposalId);
    return _run(
      view,
      () =>
          _repository.destinations(_programId, view.review!.proposal, partyId),
      (_) => view,
    );
  }

  Future<void> move(
    String proposalId,
    String partyId,
    String inventoryId,
  ) async {
    _ensureEditing();
    final view = _current(proposalId);
    final proposal = view.review!.proposal;
    if (!view.review!.parties.any((p) => p.id == partyId && p.canMove)) {
      throw StateError('This room-sharing party is locked.');
    }
    await _run(
      view,
      () => _repository.propose(
        _programId,
        proposal,
        proposal.moving(partyId, inventoryId),
      ),
      _reviewView,
    );
  }

  Future<void> saveSetup(Map<String, Object?> fields) async {
    _ensureEditing();
    final view = _current();
    final revision = view.setup.configuration?['revision'];
    await _run(view, () async {
      await _repository.saveSetup(
        _programId,
        fields,
        revision == null ? 0 : (revision as num).toInt(),
      );
      return _repository.preview(_programId);
    }, _reviewView);
  }

  Future<void> decide(ProgramLodgingAction action) async {
    final view = _current();
    final review = view.review;
    if (review == null) throw programReadSuperseded;
    if (_command != null && _command!.action != action) {
      throw StateError('Retry the pending lodging decision first.');
    }
    final command = _command ??= _LodgingPendingCommand(
      review.proposal,
      action,
      review.workflowRevision,
    );
    await _run(view, () async {
      final actionEpoch = _epoch;
      // A successful publication advances source revisions. Its uncertain
      // retry must go straight to the receipt boundary, never stale save().
      if (action == ProgramLodgingAction.approve && !command.saved) {
        await _repository.save(_programId, command.proposal);
        command.saved = true;
      }
      if (!ref.mounted || actionEpoch != _epoch) throw programReadSuperseded;
      await _repository.transition(
        _programId,
        proposal: command.proposal,
        operationId: command.operationId,
        expectedWorkflowRevision: command.revision,
        action: command.action,
      );
      if (!ref.mounted || actionEpoch != _epoch) throw programReadSuperseded;
      _command = null;
      try {
        return await _repository.preview(_programId);
      } catch (error, stack) {
        // The decision was acknowledged. Hide stale controls if its new
        // source cannot be read; refreshing must not repeat that decision.
        if (ref.mounted && actionEpoch == _epoch) {
          _epoch++;
          state = AsyncError(error, stack);
        }
        rethrow;
      }
    }, _reviewView);
  }
}

ProgramLodgingView _reviewView(ProgramLodgingReview review) =>
    ProgramLodgingView(
      setup: ProgramLodgingSetup(
        configuration: review.configuration,
        accessExpiresAt: review.accessExpiresAt,
      ),
      review: review,
    );
