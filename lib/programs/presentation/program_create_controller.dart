import 'package:catch_dating_app/programs/domain/program_models.dart';
import 'package:catch_dating_app/programs/presentation/program_create_state.dart';
import 'package:flutter/foundation.dart';

typedef ProgramCreateCommand =
    Future<ProgramMutationResult> Function(
      ProgramCreateValues values,
      String requestId,
    );

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
  }) : _create = create,
       _readSaved = readSaved,
       _refreshPrograms = refreshPrograms,
       _isActorCurrent = isActorCurrent,
       _values = initialValues;

  final String organizerId;
  final String requestId;
  final ProgramCreateCommand _create;
  final Future<OrganizerProgramSettings> Function(String) _readSaved;
  final Future<List<OrganizerProgramListRow>> Function(String) _refreshPrograms;
  final bool Function() _isActorCurrent;
  ProgramCreateValues _values;
  ProgramCreateValues? _submittedValues;
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
        final receipt = await _create(_submittedValues!, requestId);
        // Retain the receipt even if the actor changed while the request ran.
        _programId = receipt.entityId;
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
      return _programId;
    } catch (error) {
      if (_checkActor()) _error = error;
      return null;
    } finally {
      _saving = false;
      _notify();
    }
  }

  void _notify() {
    if (!_disposed) notifyListeners();
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
