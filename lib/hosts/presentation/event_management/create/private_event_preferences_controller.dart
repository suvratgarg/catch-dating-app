import 'dart:math';

import 'package:catch_dating_app/hosts/data/manager_event_setup_defaults_repository.dart';
import 'package:catch_dating_app/hosts/data/private_event_preferences_journal.dart';
import 'package:catch_dating_app/hosts/data/private_event_preferences_repository.dart';
import 'package:catch_dating_app/hosts/data/private_event_setup_repository.dart';
import 'package:flutter/foundation.dart';

typedef ReadPrivateEventForPreferences = Future<PrivateEventBasicSummary>
    Function({required String organizerId, required String eventId});
typedef ReadDefaultsForPrivateEvent = Future<ManagerEventSetupDefaults>
    Function(String organizerId);
typedef WritePrivateEventPreferences = Future<PrivateEventCreateReceipt>
    Function(PrivateEventPreferencesUpdateRequest request);

/// Shared presentation contract. Private setup and published offer settings
/// retain separate reads, revision fences, journals and mutations.
abstract class EventPreferencesEditorController extends ChangeNotifier {
  String? get eventName;
  bool get hasLoadedEvent;
  bool get isPrivateEvent;
  PrivateEventPreferenceIntents get intents;
  Map<String, Object?> get resolvedValues;
  ManagerEventSetupDefaults? get defaults;
  bool get hasPending;
  Object? get error;
  set error(Object? value);
  bool get loading;
  bool get saving;
  bool get canEdit;
  Future<void> load();
  Future<void> retryPending();
  Future<void> save(PrivateEventPreferenceIntents intents);
}

/// Event-scoped editor state. Once a command is sent, every retry uses the
/// same persisted body even after a lost response, revocation or app restart.
class PrivateEventPreferencesController extends EventPreferencesEditorController {
  PrivateEventPreferencesController({
    required this.userId,
    required this.organizerId,
    required this.eventId,
    required this.readEvent,
    required this.readDefaults,
    required this.write,
    this.journal = const PrivateEventPreferencesJournal(),
  });

  final String userId;
  final String organizerId;
  final String eventId;
  final ReadPrivateEventForPreferences readEvent;
  final ReadDefaultsForPrivateEvent readDefaults;
  final WritePrivateEventPreferences write;
  final PrivateEventPreferencesJournal journal;

  PrivateEventBasicSummary? event;
  ManagerEventSetupDefaults? defaults;
  PrivateEventPreferencesUpdateRequest? pending;
  Object? error;
  bool loading = false;
  bool saving = false;
  bool _disposed = false;

  @override
  String? get eventName => event?.name;
  @override
  bool get hasLoadedEvent => event != null;
  @override
  bool get isPrivateEvent => true;
  @override
  PrivateEventPreferenceIntents get intents =>
      event?.eventPreferences?.intents ?? const PrivateEventPreferenceIntents();
  @override
  Map<String, Object?> get resolvedValues =>
      event?.eventPreferences?.resolvedValues ??
      defaults?.preferences.toSparseJson() ?? const <String, Object?>{};
  @override
  bool get hasPending => pending != null;

  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  bool get canEdit => event?.canEditBasics == true && defaults != null &&
      pending == null && !loading && !saving;

  Future<void> load() async {
    loading = true;
    error = null;
    event = null;
    defaults = null;
    notifyListeners();
    try {
      pending = await journal.load(
        userId: userId, organizerId: organizerId, eventId: eventId,
      );
      final results = await Future.wait<Object>([
        readEvent(organizerId: organizerId, eventId: eventId),
        readDefaults(organizerId),
      ]);
      final nextEvent = results[0] as PrivateEventBasicSummary;
      final nextDefaults = results[1] as ManagerEventSetupDefaults;
      if (nextEvent.eventId != eventId ||
          nextEvent.organizerId != organizerId ||
          nextDefaults.organizerId != organizerId) {
        throw const FormatException('Private event preferences identity changed');
      }
      event = nextEvent;
      defaults = nextDefaults;
    } catch (cause) {
      error = cause;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> save(PrivateEventPreferenceIntents intents) async {
    if (!canEdit) return;
    final request = PrivateEventPreferencesUpdateRequest(
      organizerId: organizerId,
      eventId: eventId,
      requestId: _newRequestId(),
      expectedSetupRevision: event!.setupRevision,
      expectedPreferencesRevision: event!.eventPreferences?.revision ?? 0,
      reviewedDefaultsHash: defaults!.preferencesHash,
      intents: intents,
    );
    if (!request.isValid) {
      error = ArgumentError.value(intents, 'intents');
      notifyListeners();
      return;
    }
    saving = true;
    error = null;
    notifyListeners();
    try {
      await journal.save(userId: userId, request: request);
      pending = request;
      notifyListeners();
      await _sendPending(request);
    } catch (cause) {
      error = cause;
      notifyListeners();
    } finally {
      saving = false;
      notifyListeners();
    }
  }

  Future<void> retryPending() async {
    if (pending == null || saving) return;
    saving = true;
    error = null;
    notifyListeners();
    try {
      await _sendPending(pending!);
    } catch (cause) {
      // A later permission/precondition error is not proof that the original
      // send failed. Never rotate its identity or payload here.
      error = cause;
      notifyListeners();
    } finally {
      saving = false;
      notifyListeners();
    }
  }

  Future<void> _sendPending(PrivateEventPreferencesUpdateRequest request) async {
    final receipt = await write(request);
    if (receipt.eventId != eventId ||
        receipt.setupRevision <= request.expectedSetupRevision) {
      throw const FormatException('Invalid event preferences receipt');
    }
    await journal.clear(userId: userId, request: request);
    pending = null;
    // The command is settled, but its new revision must be read before a
    // second command can be built. A failed reread must not reuse stale state.
    event = null;
    event = await readEvent(organizerId: organizerId, eventId: eventId);
    if (event!.eventId != eventId || event!.organizerId != organizerId) {
      throw const FormatException('Private event reread changed identity');
    }
    error = null;
    notifyListeners();
  }
}

String _newRequestId() {
  final random = Random.secure();
  return List<int>.generate(24, (_) => random.nextInt(256))
      .map((value) => value.toRadixString(16).padLeft(2, '0'))
      .join();
}
