part of 'host_forms_controller.dart';

mixin HostFormEditorTargetMixin on _$HostFormEditorController {
  Timer? _saveTimer;
  bool _saveRunning = false;
  String? _targetMutationAccountId;

  int get _generation;
  void _mutate(
    HostFormDefinition Function(HostFormDefinition definition) transform,
  );
  Future<void> reload();
  void _scheduleSave();

  Future<HostOfferEventTargetPage> listTargetEvents({String? cursor}) =>
      CallableHostOfferEventTargetsGateway(ref.read(firebaseFunctionsProvider))
          .list(organizerId: organizerId, cursor: cursor);

  void updateTarget({
    required HostFormTargetKind kind,
    required String accountId,
    String? eventId,
  }) {
    if (!_currentTargetActor(accountId)) return;
    final current = state.asData?.value;
    if (current == null) return;
    final next = current.editor.definition.withTarget(
      kind: kind,
      eventId: eventId,
    );
    if (identical(next, current.editor.definition)) return;
    _targetMutationAccountId = accountId;
    _mutate((_) => next);
  }

  bool _currentTargetActor(String accountId) {
    final uid = catchAsyncStateFromAsyncValue(ref.read(uidProvider));
    return uid.isSettledData &&
        uid.value == accountId &&
        ref.read(firebaseAuthProvider).currentUser?.uid == accountId;
  }

  Future<bool> saveNow() async {
    _saveTimer?.cancel();
    if (_saveRunning) {
      while (_saveRunning) {
        await Future<void>.delayed(CatchMotion.fast);
      }
      if (_targetMutationAccountId case final accountId?) {
        if (!_currentTargetActor(accountId)) {
          await reload();
          return false;
        }
      }
      return state.asData?.value.saveState == HostFormSaveState.saved;
    }
    if (_targetMutationAccountId case final accountId?) {
      if (!_currentTargetActor(accountId)) {
        await reload();
        return false;
      }
    }
    final current = state.asData?.value;
    if (current == null) return false;
    if (current.saveState == HostFormSaveState.saved) return true;
    _saveRunning = true;
    final generation = _generation;
    final targetMutationAccountId = _targetMutationAccountId;
    final definition = current.editor.definition;
    final expectedRevision = current.editor.form.draftRevision;
    state = AsyncData(
      current.copyWith(saveState: HostFormSaveState.saving, clearError: true),
    );
    try {
      final saved = await ref
          .read(hostFormsRepositoryProvider)
          .updateDraft(
            organizerId: organizerId,
            formId: formId,
            expectedRevision: expectedRevision,
            definition: definition,
          );
      if (targetMutationAccountId != null &&
          !_currentTargetActor(targetMutationAccountId)) {
        await reload();
        return false;
      }
      final latest = state.asData?.value;
      if (latest == null) return false;
      if (generation == _generation) {
        _targetMutationAccountId = null;
        state = AsyncData(
          latest.copyWith(
            editor: saved,
            saveState: HostFormSaveState.saved,
            clearError: true,
          ),
        );
      } else {
        state = AsyncData(
          latest.copyWith(
            editor: latest.editor.copyWith(form: saved.form),
            saveState: HostFormSaveState.dirty,
            clearError: true,
          ),
        );
        _scheduleSave();
      }
      return generation == _generation;
    } on Object catch (error) {
      if (targetMutationAccountId != null &&
          !_currentTargetActor(targetMutationAccountId)) {
        await reload();
        return false;
      }
      final latest = state.asData?.value ?? current;
      final conflict = error is AppException && error.code == 'aborted';
      state = AsyncData(
        latest.copyWith(
          saveState: conflict
              ? HostFormSaveState.conflict
              : HostFormSaveState.failed,
          error: error,
        ),
      );
      return false;
    } finally {
      _saveRunning = false;
    }
  }

}

typedef HostFormTargetPageLoader = Future<HostOfferEventTargetPage> Function({
  required String organizerId,
  String? cursor,
});

/// Keeps the event picker bound to one manager and organizer. A late page from
/// a previous account cannot become a selectable target in this controller.
class HostFormTargetController extends ChangeNotifier {
  HostFormTargetController({
    required this.organizerId,
    required this.accountId,
    required HostFormTargetPageLoader loadPage,
    required String? Function() currentAccountId,
  }) : _loadPage = loadPage,
       _currentAccountId = currentAccountId;

  final String organizerId;
  final String accountId;
  final HostFormTargetPageLoader _loadPage;
  final String? Function() _currentAccountId;

  List<HostOfferEventTarget> _events = const [];
  String? _nextCursor;
  Object? _error;
  bool _loaded = false;
  bool _loading = false;
  bool _disposed = false;
  int _generation = 0;

  List<HostOfferEventTarget> get events => _events;
  bool get hasLoadFailure => _error != null;
  bool get loaded => _loaded;
  bool get loading => _loading;
  bool get canLoadMore => _nextCursor != null && !_loading;
  bool get isCurrentAccount =>
      !_disposed && _currentAccountId() == accountId;

  HostOfferEventTarget? event(String eventId) {
    for (final value in _events) {
      if (value.eventId == eventId) return value;
    }
    return null;
  }

  bool bindingUnavailable(String eventId) =>
      _loaded && !_loading && _error == null &&
      _nextCursor == null && event(eventId) == null;

  Future<void> refresh() => _fetch(cursor: null);

  Future<void> loadMore() async {
    final cursor = _nextCursor;
    if (cursor == null || _loading) return;
    await _fetch(cursor: cursor);
  }

  Future<void> _fetch({required String? cursor}) async {
    if (!isCurrentAccount || _loading) return;
    final generation = ++_generation;
    _loading = true;
    _error = null;
    if (cursor == null) {
      _events = const [];
      _nextCursor = null;
      _loaded = false;
    }
    notifyListeners();
    try {
      final page = await _loadPage(
        organizerId: organizerId,
        cursor: cursor,
      );
      if (!_accept(generation)) return;
      if (cursor != null && page.nextCursor == cursor) {
        throw const FormatException('Event target page repeated.');
      }
      final byId = <String, HostOfferEventTarget>{
        if (cursor != null)
          for (final event in _events) event.eventId: event,
        for (final event in page.events) event.eventId: event,
      };
      _events = List.unmodifiable(byId.values);
      _nextCursor = page.nextCursor;
      _loaded = true;
    } on Object catch (error) {
      if (!_accept(generation)) return;
      _error = error;
    } finally {
      if (_accept(generation)) {
        _loading = false;
        notifyListeners();
      }
    }
  }

  bool _accept(int generation) =>
      !_disposed && _generation == generation && isCurrentAccount;

  @override
  void dispose() {
    _disposed = true;
    _generation++;
    super.dispose();
  }
}
