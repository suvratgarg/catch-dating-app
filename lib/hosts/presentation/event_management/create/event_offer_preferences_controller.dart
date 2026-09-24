import 'dart:math';

import 'package:catch_dating_app/hosts/data/event_offer_preferences_journal.dart';
import 'package:catch_dating_app/hosts/data/event_offer_preferences_repository.dart';
import 'package:catch_dating_app/hosts/data/manager_event_setup_defaults_repository.dart';
import 'package:catch_dating_app/hosts/data/private_event_preferences_repository.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/create/private_event_preferences_controller.dart';

typedef ReadEventOfferConfiguration = Future<EventOfferConfiguration>
    Function({required String organizerId, required String eventId});
typedef ReadDefaultsForPublishedEvent = Future<ManagerEventSetupDefaults>
    Function(String organizerId);
typedef WriteEventOfferPreferences = Future<EventOfferPreferencesReceipt>
    Function(EventOfferPreferencesUpdateRequest request);

/// Published and legacy events reuse the editor controls, but keep their
/// source-revision fence and offer-specific receipt separate from private setup.
class EventOfferPreferencesController extends EventPreferencesEditorController {
  EventOfferPreferencesController({
    required this.userId,
    required this.organizerId,
    required this.eventId,
    required this.readConfiguration,
    required this.readDefaults,
    required this.write,
    this.displayName,
    this.journal = const EventOfferPreferencesJournal(),
  });

  final String userId;
  final String organizerId;
  final String eventId;
  final ReadEventOfferConfiguration readConfiguration;
  final ReadDefaultsForPublishedEvent readDefaults;
  final WriteEventOfferPreferences write;
  final String? displayName;
  final EventOfferPreferencesJournal journal;

  EventOfferConfiguration? configuration;
  @override
  ManagerEventSetupDefaults? defaults;
  EventOfferPreferencesUpdateRequest? pending;
  @override
  Object? error;
  @override
  bool loading = false;
  @override
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

  @override
  String? get eventName => displayName;
  @override
  bool get hasLoadedEvent => configuration != null;
  @override
  bool get isPrivateEvent => false;
  @override
  PrivateEventPreferenceIntents get intents =>
      configuration?.preferences?.intents ??
      const PrivateEventPreferenceIntents();
  @override
  Map<String, Object?> get resolvedValues =>
      configuration?.preferences?.resolvedValues ??
      defaults?.preferences.toSparseJson() ?? const <String, Object?>{};
  @override
  bool get hasPending => pending != null;
  @override
  bool get canEdit => configuration != null && defaults != null &&
      pending == null && !loading && !saving;

  @override
  Future<void> load() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      pending = await journal.load(
        userId: userId, organizerId: organizerId, eventId: eventId,
      );
      final results = await Future.wait<Object>([
        readConfiguration(organizerId: organizerId, eventId: eventId),
        readDefaults(organizerId),
      ]);
      final nextConfiguration = results[0] as EventOfferConfiguration;
      final nextDefaults = results[1] as ManagerEventSetupDefaults;
      if (nextConfiguration.eventId != eventId ||
          nextConfiguration.organizerId != organizerId ||
          nextDefaults.organizerId != organizerId) {
        throw const FormatException('Offer settings identity changed');
      }
      configuration = nextConfiguration;
      defaults = nextDefaults;
    } catch (cause) {
      error = cause;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  @override
  Future<void> save(PrivateEventPreferenceIntents intents) async {
    if (!canEdit) return;
    final request = EventOfferPreferencesUpdateRequest(
      organizerId: organizerId,
      eventId: eventId,
      requestId: _newOfferSettingsRequestId(),
      expectedEventSourceRevision: configuration!.eventSourceRevision,
      expectedPreferencesRevision: configuration!.preferencesRevision,
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

  @override
  Future<void> retryPending() async {
    if (pending == null || saving) return;
    saving = true;
    error = null;
    notifyListeners();
    try {
      await _sendPending(pending!);
    } catch (cause) {
      // A later denial cannot prove the original command was not applied.
      error = cause;
      notifyListeners();
    } finally {
      saving = false;
      notifyListeners();
    }
  }

  Future<void> _sendPending(EventOfferPreferencesUpdateRequest request) async {
    final receipt = await write(request);
    if (receipt.eventId != eventId ||
        receipt.preferencesRevision <= request.expectedPreferencesRevision) {
      throw const FormatException('Invalid offer settings receipt');
    }
    await journal.clear(userId: userId, request: request);
    pending = null;
    configuration = null;
    configuration = await readConfiguration(
      organizerId: organizerId, eventId: eventId);
    if (configuration!.eventId != eventId ||
        configuration!.organizerId != organizerId ||
        configuration!.preferencesRevision < receipt.preferencesRevision) {
      throw const FormatException('Offer settings reread changed identity');
    }
    error = null;
    notifyListeners();
  }
}

String _newOfferSettingsRequestId() {
  final random = Random.secure();
  return List<int>.generate(24, (_) => random.nextInt(256))
      .map((value) => value.toRadixString(16).padLeft(2, '0'))
      .join();
}
