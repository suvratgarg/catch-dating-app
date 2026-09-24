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

/// Event-scoped editor state. Once a command is sent, every retry uses the
/// same persisted body even after a lost response, revocation or app restart.
class PrivateEventPreferencesController extends ChangeNotifier {
  PrivateEventPreferencesController({
    required this.userId,
    required this.organizerId,
    required this.eventId,
    required ReadPrivateEventForPreferences readEvent,
    required ReadDefaultsForPrivateEvent readDefaults,
    required WritePrivateEventPreferences write,
    PrivateEventPreferencesJournal journal = const PrivateEventPreferencesJournal(),
  }) : _readEvent = readEvent,
       _readDefaults = readDefaults,
       _write = write,
       _journal = journal;

  final String userId;
  final String organizerId;
  final String eventId;
  final ReadPrivateEventForPreferences _readEvent;
  final ReadDefaultsForPrivateEvent _readDefaults;
  final WritePrivateEventPreferences _write;
  final PrivateEventPreferencesJournal _journal;

  PrivateEventBasicSummary? event;
  ManagerEventSetupDefaults? defaults;
  PrivateEventPreferencesUpdateRequest? pending;
  Object? error;
  bool loading = false;
  bool saving = false;

  bool get canEdit => event?.canEditBasics == true && defaults != null &&
      pending == null && !loading && !saving;

  Future<void> load() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      pending = await _journal.load(
        userId: userId, organizerId: organizerId, eventId: eventId,
      );
      final results = await Future.wait<Object>([
        _readEvent(organizerId: organizerId, eventId: eventId),
        _readDefaults(organizerId),
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
      await _journal.save(userId: userId, request: request);
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
    final receipt = await _write(request);
    if (receipt.eventId != eventId ||
        receipt.setupRevision <= request.expectedSetupRevision) {
      throw const FormatException('Invalid event preferences receipt');
    }
    await _journal.clear(userId: userId, request: request);
    pending = null;
    event = await _readEvent(organizerId: organizerId, eventId: eventId);
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
