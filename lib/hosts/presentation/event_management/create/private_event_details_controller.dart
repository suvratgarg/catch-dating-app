import 'dart:math';

import 'package:catch_dating_app/hosts/data/manager_event_setup_defaults_repository.dart';
import 'package:catch_dating_app/hosts/data/private_event_details_journal.dart';
import 'package:catch_dating_app/hosts/data/private_event_details_repository.dart';
import 'package:catch_dating_app/hosts/data/private_event_setup_repository.dart';
import 'package:flutter/foundation.dart';

typedef ReadPrivateEventForDetails = Future<PrivateEventBasicSummary>
    Function({required String organizerId, required String eventId});
typedef ReadDefaultsForPrivateDetails = Future<ManagerEventSetupDefaults>
    Function(String organizerId);
typedef WritePrivateEventDetails = Future<PrivateEventCreateReceipt>
    Function(PrivateEventDetailsUpdateRequest request);

/// Exact-command journal makes a lost details response safe to retry after
/// app restart or manager access changes, without creating another mutation.
class PrivateEventDetailsController extends ChangeNotifier {
  PrivateEventDetailsController({
    required this.userId,
    required this.organizerId,
    required this.eventId,
    required this.readEvent,
    required this.readDefaults,
    required this.write,
    this.journal = const PrivateEventDetailsJournal(),
  });

  final String userId;
  final String organizerId;
  final String eventId;
  final ReadPrivateEventForDetails readEvent;
  final ReadDefaultsForPrivateDetails readDefaults;
  final WritePrivateEventDetails write;
  final PrivateEventDetailsJournal journal;

  PrivateEventBasicSummary? event;
  ManagerEventSetupDefaults? defaults;
  PrivateEventDetailsUpdateRequest? pending;
  Object? error;
  bool loading = false;
  bool saving = false;
  bool _disposed = false;

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

  void reportValidationError(Object cause) {
    error = cause;
    notifyListeners();
  }

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
        throw const FormatException('Private event details identity changed');
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

  Future<void> save(PrivateEventDetailsPatch details) async {
    if (!canEdit) return;
    final request = PrivateEventDetailsUpdateRequest(
      organizerId: organizerId,
      eventId: eventId,
      requestId: _newRequestId(),
      expectedSetupRevision: event!.setupRevision,
      reviewedDefaultsHash: defaults!.preferencesHash,
      details: details,
    );
    if (!request.isValid) {
      error = ArgumentError.value(details, 'details');
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
      // A later denial cannot prove an earlier send did not commit.
      error = cause;
      notifyListeners();
    } finally {
      saving = false;
      notifyListeners();
    }
  }

  Future<void> _sendPending(PrivateEventDetailsUpdateRequest request) async {
    final receipt = await write(request);
    if (receipt.eventId != eventId ||
        receipt.setupRevision <= request.expectedSetupRevision) {
      throw const FormatException('Invalid event details receipt');
    }
    await journal.clear(userId: userId, request: request);
    pending = null;
    // The acknowledged event revision is unknown until the authorized reread.
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
