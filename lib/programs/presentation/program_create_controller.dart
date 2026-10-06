import 'dart:async';

import 'package:catch_dating_app/exceptions/app_exception.dart';
import 'package:catch_dating_app/programs/domain/program_models.dart';
import 'package:catch_dating_app/programs/presentation/program_create_state.dart';
import 'package:flutter/foundation.dart';

typedef ProgramCreateCommand =
    Future<ProgramMutationResult> Function(
      ProgramCreateValues values,
      String requestId,
    );

@immutable
class ProgramCreateSnapshot {
  const ProgramCreateSnapshot({
    required this.requestId,
    required this.values,
    required this.submittedValues,
    required this.programId,
  });

  final String requestId;
  final ProgramCreateValues values;
  final ProgramCreateValues? submittedValues;
  final String? programId;
}

typedef ProgramCreateSnapshotWriter =
    Future<void> Function(ProgramCreateSnapshot snapshot);

/// Owns the program creation transaction, including confirmation. The form
/// stays mounted after failures, and a receipt retry only reads the saved ID.
class ProgramCreateController extends ChangeNotifier {
  ProgramCreateController({
    required this.organizerId,
    required this.requestId,
    required ProgramCreateCommand create,
    required Future<OrganizerProgramSettings> Function(String) readSaved,
    required Future<List<OrganizerProgramListRow>> Function(String)
    refreshPrograms,
    required bool Function() isActorCurrent,
    ProgramCreateValues initialValues = const ProgramCreateValues(),
    ProgramCreateValues? initialSubmittedValues,
    String? initialProgramId,
    String Function()? newRequestId,
    ProgramCreateSnapshotWriter? persist,
    Future<void> Function(String requestId)? clearPersisted,
  }) : _create = create,
       _readSaved = readSaved,
       _refreshPrograms = refreshPrograms,
       _isActorCurrent = isActorCurrent,
       _values = initialValues,
       _submittedValues = initialSubmittedValues,
       _programId = initialProgramId,
       _newRequestId = newRequestId ?? (() => requestId),
       _persist = persist ?? _ignoreSnapshot,
       _clearPersisted = clearPersisted ?? _ignoreRequestId;

  final String organizerId;
  String requestId;
  final ProgramCreateCommand _create;
  final Future<OrganizerProgramSettings> Function(String) _readSaved;
  final Future<List<OrganizerProgramListRow>> Function(String) _refreshPrograms;
  final bool Function() _isActorCurrent;
  final String Function() _newRequestId;
  final ProgramCreateSnapshotWriter _persist;
  final Future<void> Function(String requestId) _clearPersisted;
  ProgramCreateValues _values;
  ProgramCreateValues? _submittedValues;
  Future<void> _persistenceTail = Future<void>.value();
  bool _disposed = false;
  bool _actorChanged = false;
  bool _saving = false;
  bool _showErrors = false;
  bool _confirmed = false;
  String? _programId;
  OrganizerProgramListRow? _confirmedRow;
  Object? _error;

  ProgramCreateValues get values => _values;
  bool get saving => _saving;
  bool get showErrors => _showErrors;
  bool get actorChanged => _actorChanged;
  bool get confirmed => _confirmed;
  bool get commandPending => _submittedValues != null;
  bool get fieldsLocked => saving || commandPending || actorChanged;
  String? get programId => _programId;
  OrganizerProgramListRow? get confirmedRow => _confirmedRow;
  Object? get error => _error;

  void edit(ProgramCreateValues values) {
    if (fieldsLocked || _disposed) return;
    _values = values;
    _error = null;
    _notify();
    _persistInBackground();
  }

  void invalidateActor() {
    if (_disposed || _actorChanged) return;
    _actorChanged = true;
    _notify();
  }

  bool _checkActor() {
    if (_disposed) return false;
    if (_actorChanged || !_isActorCurrent()) {
      invalidateActor();
      return false;
    }
    return true;
  }

  Future<String?> submit() async {
    if (_saving || _confirmed || !_checkActor()) return null;
    if (_programId == null &&
        _submittedValues == null &&
        _values.errors.isNotEmpty) {
      _showErrors = true;
      _notify();
      return null;
    }
    _saving = true;
    _error = null;
    _notify();
    try {
      if (_programId == null) {
        _submittedValues ??= _values;
        await _persistSnapshot();
        final receipt = await _create(_submittedValues!, requestId);
        // Retain the receipt even if the actor changed while the request ran.
        _programId = receipt.entityId;
        await _persistSnapshot();
      }
      if (!_checkActor()) return null;
      final saved = await _readSaved(_programId!);
      if (!_checkActor()) return null;
      if (saved.programId != _programId || saved.organizerId != organizerId) {
        throw const FormatException('Program confirmation changed identity');
      }
      final programs = await _refreshPrograms(_programId!);
      if (!_checkActor()) return null;
      if (!programs.any((program) => program.programId == _programId)) {
        throw const ProgramNotVisibleException();
      }
      _confirmedRow = programs.firstWhere(
        (program) => program.programId == _programId,
      );
      _confirmed = true;
      await _clearPersisted(requestId);
      return _programId;
    } catch (error) {
      if (_checkActor()) {
        _error = error;
        if (_programId == null && _definitiveCreateRejection(error)) {
          _submittedValues = null;
          requestId = _newRequestId();
          try {
            await _persistSnapshot();
          } catch (persistenceError) {
            _error = persistenceError;
          }
        }
      }
      return null;
    } finally {
      _saving = false;
      _notify();
    }
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  void _persistInBackground() {
    unawaited(
      _persistSnapshot().onError((error, _) {
        if (!_disposed) {
          _error = error;
          _notify();
        }
      }),
    );
  }

  Future<void> _persistSnapshot() {
    final snapshot = ProgramCreateSnapshot(
      requestId: requestId,
      values: _values,
      submittedValues: _submittedValues,
      programId: _programId,
    );
    final previous = _persistenceTail;
    return _persistenceTail = () async {
      try {
        await previous;
      } catch (_) {
        // A later snapshot supersedes a failed earlier local write.
      }
      await _persist(snapshot);
    }();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}

class ProgramNotVisibleException implements Exception {
  const ProgramNotVisibleException();
}

bool _definitiveCreateRejection(Object error) =>
    error is AppException &&
    !error.retryable &&
    const {
      'invalid-argument',
      'permission-denied',
      'unauthenticated',
      'failed-precondition',
      'already-exists',
      'validation-failed',
      'sign-in-required',
    }.contains(error.code);

Future<void> _ignoreSnapshot(ProgramCreateSnapshot _) async {}

Future<void> _ignoreRequestId(String _) async {}
