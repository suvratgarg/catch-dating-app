import 'dart:math';

import 'package:catch_dating_app/hosts/data/event_publication_journal.dart';
import 'package:catch_dating_app/hosts/data/event_publication_repository.dart';
import 'package:catch_dating_app/hosts/data/private_event_setup_repository.dart';
import 'package:flutter/foundation.dart';

class EventPublicationController extends ChangeNotifier {
  EventPublicationController({
    required this.userId,
    required this.organizerId,
    required this.eventId,
    required this.read,
    required this.write,
    required this.currentUserId,
    this.journal = const EventPublicationJournal(),
  });
  final String userId;
  final String organizerId;
  final String eventId;
  final Future<PrivateEventBasicSummary> Function({
    required String organizerId,
    required String eventId,
  })
  read;
  final Future<EventPublicationReceipt> Function(EventPublicationRequest) write;
  final String? Function() currentUserId;
  final EventPublicationJournal journal;
  PrivateEventBasicSummary? event;
  EventPublicationRequest? pending;
  EventPublicationReceipt? receipt;
  Object? error;
  bool loading = false;
  bool saving = false;
  bool _disposed = false;
  bool _actorAvailable = true;
  bool get actorAvailable =>
      !_disposed && _actorAvailable && currentUserId() == userId;
  bool get canChange =>
      actorAvailable && event != null && !loading && !saving && pending == null;
  bool get canPublish =>
      canChange &&
      event!.publicationState == 'private' &&
      event!.publicationReadiness?.canPublish == true;
  bool get canUnpublish => canChange && event!.publicationState == 'published';

  void invalidateActor() {
    _actorAvailable = false;
    event = null;
    receipt = null;
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  Future<void> _readCurrent() async {
    if (!actorAvailable) return;
    event = null;
    final current = await read(organizerId: organizerId, eventId: eventId);
    if (!actorAvailable) return;
    if (current.eventId != eventId || current.organizerId != organizerId) {
      throw const FormatException('Publication read changed identity');
    }
    event = current;
  }

  Future<void> load() async {
    if (!actorAvailable || loading || saving) return;
    loading = true;
    event = null;
    error = null;
    notifyListeners();
    try {
      pending = await journal.load(
        userId: userId,
        organizerId: organizerId,
        eventId: eventId,
      );
      if (!actorAvailable) return;
      await _readCurrent();
    } catch (cause) {
      if (actorAvailable) error = cause;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> changeTo(String publicationState) async {
    if (publicationState == 'published'
        ? !canPublish
        : publicationState != 'private' || !canUnpublish) {
      return;
    }
    final random = Random.secure();
    final request = EventPublicationRequest(
      organizerId: organizerId,
      eventId: eventId,
      requestId: List<int>.generate(
        24,
        (_) => random.nextInt(256),
      ).map((value) => value.toRadixString(16).padLeft(2, '0')).join(),
      expectedSetupRevision: event!.setupRevision,
      publicationState: publicationState,
    );
    saving = true;
    error = null;
    receipt = null;
    notifyListeners();
    try {
      await journal.save(userId: userId, request: request);
      pending = request;
      if (!actorAvailable) return;
      await _send(request);
    } catch (cause) {
      if (actorAvailable) error = cause;
    } finally {
      saving = false;
      notifyListeners();
    }
  }

  Future<void> retry() async {
    if (!actorAvailable || pending == null || saving || loading) return;
    saving = true;
    error = null;
    notifyListeners();
    try {
      await _send(pending!);
    } catch (cause) {
      if (actorAvailable) error = cause;
    } finally {
      saving = false;
      notifyListeners();
    }
  }

  Future<void> _send(EventPublicationRequest request) async {
    if (!actorAvailable) return;
    EventPublicationReceipt result;
    try {
      result = await write(request);
    } catch (cause) {
      if (actorAvailable && isDefinitivePublicationRejection(cause, request)) {
        await journal.clear(userId: userId, request: request);
        pending = null;
        await _readCurrent();
      }
      rethrow;
    }
    if (!actorAvailable) return;
    if (result.eventId != eventId ||
        result.publicationState != request.publicationState ||
        result.setupRevision != request.expectedSetupRevision + 1) {
      throw const FormatException('Invalid publication receipt');
    }
    await journal.clear(userId: userId, request: request);
    if (!actorAvailable) return;
    pending = null;
    receipt = result;
    if (!actorAvailable) return;
    await _readCurrent();
  }
}
