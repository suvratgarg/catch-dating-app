import 'dart:math';

import 'package:catch_dating_app/hosts/data/manager_event_setup_defaults_repository.dart';
import 'package:catch_dating_app/hosts/data/private_event_details_journal.dart';
import 'package:catch_dating_app/hosts/data/private_event_details_repository.dart';
import 'package:catch_dating_app/hosts/data/private_event_setup_repository.dart';
import 'package:flutter/foundation.dart';

typedef ReadPrivateEventForDetails =
    Future<PrivateEventBasicSummary> Function({
      required String organizerId,
      required String eventId,
    });
typedef ReadDefaultsForPrivateDetails =
    Future<ManagerEventSetupDefaults> Function(String organizerId);
typedef WritePrivateEventDetails =
    Future<PrivateEventCreateReceipt> Function(
      PrivateEventDetailsUpdateRequest request,
    );

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
    this.currentUserId,
    this.reconcile,
  });

  final String userId;
  final String organizerId;
  final String eventId;
  final ReadPrivateEventForDetails readEvent;
  final ReadDefaultsForPrivateDetails readDefaults;
  final WritePrivateEventDetails write;
  final Future<PrivateSeatReconciliationResult> Function(
    PrivateEventDetailsUpdateRequest request,
  )?
  reconcile;
  PrivateSeatReconciliationProgress? reconciliationProgress;
  final PrivateEventDetailsJournal journal;
  final String? Function()? currentUserId;
  bool _actorAvailable = true;
  bool get actorAvailable =>
      !_disposed &&
      _actorAvailable &&
      (currentUserId == null || currentUserId!() == userId);

  void invalidateActor() {
    _actorAvailable = false;
    event = null;
    defaults = null;
    reconciliationProgress = null;
  }

  PrivateEventBasicSummary? event;
  ManagerEventSetupDefaults? defaults;
  PrivateEventDetailsUpdateRequest? pending;
  Object? error;
  bool loading = false;
  bool saving = false;
  bool _disposed = false;
  bool _discardUnavailable = false;

  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  // Venue and duration can be completed after guests or offers exist. Only
  // a format change remains subject to the basic-event commitment guard.
  bool get canEdit =>
      actorAvailable &&
      event?.status == 'active' &&
      event?.publicationState == 'private' &&
      defaults != null &&
      pending == null &&
      !loading &&
      !saving;
  bool get canEditFormat => canEdit && event?.canEditBasics == true;

  void reportValidationError(Object cause) {
    error = cause;
    notifyListeners();
  }

  Future<void> load() async {
    if (!actorAvailable || loading || saving) return;
    loading = true;
    error = null;
    event = null;
    defaults = null;
    notifyListeners();
    try {
      pending = await journal.load(
        userId: userId,
        organizerId: organizerId,
        eventId: eventId,
      );
      final results = await Future.wait<Object>([
        readEvent(organizerId: organizerId, eventId: eventId),
        readDefaults(organizerId),
      ]);
      if (!actorAvailable) return;
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
    if (details.eventFormat != null && !canEditFormat) {
      reportValidationError(
        StateError('Event format is locked by commitments.'),
      );
      return;
    }
    _discardUnavailable = false;
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
      if (!actorAvailable) return;
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
    if (!actorAvailable || pending == null || saving) return;
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

  bool get canDiscardPending =>
      !_discardUnavailable &&
      reconcile != null &&
      actorAvailable &&
      !saving &&
      !loading &&
      pending?.details.admissionTerms != null &&
      pending?.discard != true &&
      pending!.details.toJson().length == 1 &&
      !const {'apply', 'cleanup'}.contains(reconciliationProgress?.phase);

  Future<void> discardPending() async {
    if (!canDiscardPending) return;
    final request = pending!;
    saving = true;
    error = null;
    notifyListeners();
    try {
      await journal.setDiscardIntent(
        userId: userId,
        request: request,
        discard: true,
      );
      pending = request.withDiscard(true);
      if (!actorAvailable) return;
      await _sendPending(pending!);
    } catch (cause) {
      if (actorAvailable) error = cause;
    } finally {
      saving = false;
      notifyListeners();
    }
  }

  Future<void> _reloadForReview() async {
    event = null;
    defaults = null;
    if (!actorAvailable) return;
    final refreshed = await Future.wait<Object>([
      readEvent(organizerId: organizerId, eventId: eventId),
      readDefaults(organizerId),
    ]);
    if (!actorAvailable) return;
    final nextEvent = refreshed[0] as PrivateEventBasicSummary;
    final nextDefaults = refreshed[1] as ManagerEventSetupDefaults;
    if (nextEvent.eventId != eventId ||
        nextEvent.organizerId != organizerId ||
        nextDefaults.organizerId != organizerId) {
      throw const FormatException('Private details review changed identity');
    }
    event = nextEvent;
    defaults = nextDefaults;
  }

  Future<void> _sendPending(PrivateEventDetailsUpdateRequest request) async {
    if (!actorAvailable) return;
    PrivateEventCreateReceipt? receipt;
    try {
      if (reconcile != null &&
          request.details.admissionTerms != null &&
          request.details.toJson().length == 1) {
        // Each response is bounded server work. The journal survives interruption;
        // a very large roster can continue with the same pending command.
        for (var page = 0; page < 12 && actorAvailable; page++) {
          final result = await reconcile!(request);
          if (!actorAvailable) return;
          if ((result.receipt?.eventId ??
                  result.progress?.eventId ??
                  result.discardedEventId) !=
              eventId) {
            throw const FormatException(
              'Guest reconciliation changed identity',
            );
          }
          if (result.discardedEventId != null) {
            if (result.discardedRequestId != request.requestId) {
              throw const FormatException('Discard receipt changed request');
            }
            await journal.clear(userId: userId, request: request);
            pending = null;
            reconciliationProgress = null;
            await _reloadForReview();
            return;
          }
          receipt = result.receipt;
          reconciliationProgress = result.progress;
          notifyListeners();
          if (receipt != null) break;
        }
        if (receipt == null) return;
      } else {
        receipt = await write(request);
      }
    } catch (cause) {
      if (actorAvailable && isDefinitiveDetailsRejection(cause, request)) {
        await journal.clear(userId: userId, request: request);
        pending = null;
        reconciliationProgress = null;
        await _reloadForReview();
      } else if (actorAvailable &&
          request.discard &&
          isDiscardUnavailable(cause, request)) {
        // The server proved application has started. Preserve the original
        // settings command and allow completion instead of retrying discard.
        await journal.setDiscardIntent(
          userId: userId,
          request: request,
          discard: false,
        );
        pending = request.withDiscard(false);
        _discardUnavailable = true;
      }
      rethrow;
    }
    if (!actorAvailable) return;
    if (receipt.eventId != eventId ||
        receipt.setupRevision != request.expectedSetupRevision + 1) {
      throw const FormatException('Invalid event details receipt');
    }
    await journal.clear(userId: userId, request: request);
    pending = null;
    reconciliationProgress = null;
    // The acknowledged event revision is unknown until the authorized reread.
    event = null;
    if (!actorAvailable) return;
    final refreshed = await readEvent(
      organizerId: organizerId,
      eventId: eventId,
    );
    if (!actorAvailable) return;
    if (refreshed.eventId != eventId || refreshed.organizerId != organizerId) {
      throw const FormatException('Private event reread changed identity');
    }
    event = refreshed;
    error = null;
    notifyListeners();
  }
}

String _newRequestId() {
  final random = Random.secure();
  return List<int>.generate(
    24,
    (_) => random.nextInt(256),
  ).map((value) => value.toRadixString(16).padLeft(2, '0')).join();
}
