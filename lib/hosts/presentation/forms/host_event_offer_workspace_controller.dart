import 'dart:async';
import 'dart:math';

import 'package:catch_dating_app/hosts/data/forms/host_offer_event_targets_gateway.dart';
import 'package:catch_dating_app/hosts/domain/forms/host_event_offer.dart';
import 'package:catch_dating_app/hosts/domain/forms/host_form_response.dart';
import 'package:catch_dating_app/hosts/presentation/forms/host_event_offer_controller.dart';
import 'package:catch_dating_app/hosts/presentation/forms/host_form_response_query_controller.dart';
import 'package:flutter/foundation.dart';

/// Owns query, event, CRM, offer, and handoff orchestration for one account.
/// The section below this layer only renders state and dispatches commands.
class HostEventOfferWorkspaceController extends ChangeNotifier {
  HostEventOfferWorkspaceController({
    required this.organizerId,
    required this.accountId,
    required this.queryController,
    required this.offerController,
    required this.listOffers,
    required this.getOffer,
    required this.prepareHandoff,
    required this.copyMessage,
    required this.openHandoff,
    required this.targets,
    required this.getResponseDetail,
    required this.openResponseForConversion,
    required this.openEventSettings,
    required this.now,
    this.initialEventId,
  }) {
    queryController.addListener(_onQueryChanged);
    offerController.addListener(_onOfferChanged);
  }

  final String organizerId;
  final String? accountId;
  final HostResponseQueryController queryController;
  final HostEventOfferController offerController;
  Future<Map<String, Object?>> Function({required String organizerId,
    required String eventId, String? afterOfferId}) listOffers;
  Future<HostEventOffer> Function({required String organizerId,
    required String eventId, required String contactId}) getOffer;
  Future<HostOfferHandoff> Function({required HostEventOffer offer})
      prepareHandoff;
  Future<void> Function(String text) copyMessage;
  Future<bool> Function(Uri uri) openHandoff;
  HostOfferEventTargetsGateway targets;
  Future<HostFormResponseDetail> Function(String responseId)
      getResponseDetail;
  Future<void> Function(String responseId) openResponseForConversion;
  Future<void> Function(String eventId) openEventSettings;
  DateTime Function() now;
  final String? initialEventId;
  bool _disposed = false;

  /// Parent rebuilds can supply fresh closures without changing the reviewed
  /// account, query or event context. Keep those callbacks current in place.
  void updateDependencies({
    required Future<Map<String, Object?>> Function({required String organizerId,
      required String eventId, String? afterOfferId}) listOffers,
    required Future<HostEventOffer> Function({required String organizerId,
      required String eventId, required String contactId}) getOffer,
    required Future<HostOfferHandoff> Function({required HostEventOffer offer})
      prepareHandoff,
    required Future<void> Function(String text) copyMessage,
    required Future<bool> Function(Uri uri) openHandoff,
    required HostOfferEventTargetsGateway targets,
    required Future<HostFormResponseDetail> Function(String responseId)
      getResponseDetail,
    required Future<void> Function(String responseId) openResponseForConversion,
    required Future<void> Function(String eventId) openEventSettings,
    required DateTime Function() now,
  }) {
    this.listOffers = listOffers;
    this.getOffer = getOffer;
    this.prepareHandoff = prepareHandoff;
    this.copyMessage = copyMessage;
    this.openHandoff = openHandoff;
    this.targets = targets;
    this.getResponseDetail = getResponseDetail;
    this.openResponseForConversion = openResponseForConversion;
    this.openEventSettings = openEventSettings;
    this.now = now;
  }

  static final Random _entropy = Random.secure();
  int _generation = 0;
  bool _loading = false;
  Object? _error;
  bool _selectionStale = false;
  List<String> _ids = const [];
  String? _resultHash;
  List<HostOfferEventTarget> _events = const [];
  String? _nextEventCursor;
  HostOfferEventTarget? _event;
  HostOfferEventConfiguration? _configuration;
  List<HostFormResponseDetail> _details = const [];
  List<HostFormResponseDetail> _missingContacts = const [];
  final Map<String, String> _personalLinks = {};
  HostOfferBatchDraft? _draft;
  String? _commitRequestId;
  List<Map<String, Object?>> _offers = const [];
  String? _nextOfferCursor;
  String? _refreshedReceiptId;
  HostEventOffer? _selectedOffer;
  HostOfferHandoff? _handoff;
  String? _referenceRequestId;
  String? _reviewRequestId;
  bool _messageCopied = false;
  bool _handoffOpenFailed = false;

  bool _current(int generation, String? accountId) =>
      !_disposed && generation == _generation &&
      accountId != null && accountId == this.accountId;

  void _reset() {
    ++_generation;
    _ids = const [];
    _resultHash = null;
    _events = const [];
    _nextEventCursor = null;
    _event = null;
    _configuration = null;
    _details = const [];
    _missingContacts = const [];
    _personalLinks.clear();
    _draft = null;
    _commitRequestId = null;
    _offers = const [];
    _nextOfferCursor = null;
    _refreshedReceiptId = null;
    _selectedOffer = null;
    _handoff = null;
    _referenceRequestId = null;
    _reviewRequestId = null;
    _messageCopied = false;
    _handoffOpenFailed = false;
    _loading = false;
    _error = null;
    _selectionStale = false;
  }

  void _onQueryChanged() {
    if (_ids.isEmpty) return;
    final intent = queryController.selectionIntent;
    if (intent?.resultHash == _resultHash &&
        _sameIds(intent!.ids, _ids)) return;
    _update(_reset);
  }

  void _onOfferChanged() {
    final view = offerController.view;
    final receipt = view.receipt;
    if (view.status != HostOfferFlowStatus.committed ||
        receipt == null || receipt.requestId == _refreshedReceiptId ||
        receipt.eventId != _event?.eventId) return;
    _refreshedReceiptId = receipt.requestId;
    _refreshOffers();
  }

  static bool _sameIds(List<String> a, List<String> b) =>
      a.length == b.length &&
      a.toSet().containsAll(b);

  Future<bool> _revalidate(int generation, String accountId) async {
    if (!_current(generation, accountId) || _resultHash == null) return false;
    final valid = await queryController.revalidateSelection(
      ids: _ids, resultHash: _resultHash!);
    if (!_current(generation, accountId)) return false;
    if (!valid) {
      _update(() {
        _selectionStale = true;
        _draft = null;
      });
    }
    return valid;
  }

  Future<void> _start() async {
    final accountId = this.accountId;
    final intent = queryController.selectionIntent;
    if (accountId == null || intent == null || intent.ids.length > 25) return;
    _update(() {
      _reset();
      _ids = List.unmodifiable(intent.ids);
      _resultHash = intent.resultHash;
    });
    await _loadEvents();
  }

  Future<void> _loadEvents() async {
    if (_loading) return;
    final generation = _generation;
    final accountId = this.accountId;
    if (accountId == null) return;
    final cursor = _nextEventCursor;
    _update(() { _loading = true; _error = null; });
    try {
      final page = await targets.list(
        organizerId: organizerId, cursor: cursor);
      if (!_current(generation, accountId)) return;
      if (cursor != null && cursor == page.nextCursor) {
        throw const FormatException('Offer target page repeated.');
      }
      _update(() {
        _events = List.unmodifiable({
          for (final event in _events) event.eventId: event,
          for (final event in page.events) event.eventId: event,
        }.values);
        _nextEventCursor = page.nextCursor;
      });
      if (initialEventId case final initialId?) {
        final matches = page.events.where((event) => event.eventId == initialId);
        if (matches.isNotEmpty) {
          // _choose runs after the list loading interlock is released.
          scheduleMicrotask(() {
            if (_current(generation, accountId)) choose(matches.first);
          });
        }
      }
    } on Object catch (error) {
      if (_current(generation, accountId)) _update(() => _error = error);
    } finally {
      if (_current(generation, accountId)) _update(() => _loading = false);
    }
  }

  Future<List<HostFormResponseDetail>> _resolveDetails() async {
    final details = <HostFormResponseDetail>[];
    // Four bounded callable reads at a time, no partial batch acceptance.
    for (var offset = 0; offset < _ids.length; offset += 4) {
      final end = min(offset + 4, _ids.length);
      details.addAll(await Future.wait(
        _ids.sublist(offset, end).map(getResponseDetail),
      ));
    }
    final request = queryController.view.request;
    if (request == null || details.length != _ids.length ||
        details.asMap().entries.any((entry) =>
          entry.value.response.responseId != _ids[entry.key] ||
          entry.value.response.formId != request.formId ||
          entry.value.response.versionId != request.versionId ||
          entry.value.response.status != HostFormResponseStatus.submitted)) {
      throw StateError('Selected responses changed.');
    }
    return details;
  }

  Future<void> _choose(HostOfferEventTarget event) async {
    final generation = _generation;
    final accountId = this.accountId;
    if (accountId == null || _loading) return;
    if (_event?.eventId != event.eventId) _personalLinks.clear();
    _update(() { _loading = true; _error = null; });
    try {
      if (!await _revalidate(generation, accountId)) return;
      final configuration = await targets.configuration(
        organizerId: organizerId, eventId: event.eventId);
      final details = await _resolveDetails();
      if (!await _revalidate(generation, accountId)) return;
      if (!_current(generation, accountId)) return;
      if (configuration.organizerId != organizerId ||
          configuration.eventId != event.eventId ||
          !configuration.startsAt.isAtSameMomentAs(event.startTime) ||
          event.setupRevision != null &&
              configuration.eventSourceRevision != event.setupRevision) {
        throw StateError('Selected responses changed.');
      }
      final missing = details.where((detail) =>
          detail.contactId == null || detail.contactId!.isEmpty).toList();
      _update(() {
        _event = event;
        _configuration = configuration;
        _details = List.unmodifiable(details);
        _missingContacts = List.unmodifiable(missing);
        _draft = null;
        _commitRequestId = null;
        _selectedOffer = null;
        _handoff = null;
      });
      await _refreshOffers();
      if (missing.isEmpty && configuration.suggestedExpiresAt != null &&
          _current(generation, accountId)) {
        await offerController.recoverPending(
          organizerId: organizerId, eventId: event.eventId);
        if (!_current(generation, accountId)) return;
        final pending = offerController.view;
        if (pending.pendingRequestId != null && pending.draft != null) {
          // Replay the exact saved command. Never rotate its request identity
          // after an ambiguous result or app restart.
          _update(() {
            _draft = pending.draft;
            _commitRequestId = pending.pendingRequestId;
          });
          return;
        }
        if (!_personalMode) _prepareDraft(details, configuration);
      }
    } on Object catch (error) {
      if (_current(generation, accountId)) _update(() => _error = error);
    } finally {
      if (_current(generation, accountId)) _update(() => _loading = false);
    }
  }

  bool get _personalMode =>
      _configuration?.paymentTerms?['preferredCollection'] ==
      'personalRequest';

  void _prepareDraft(List<HostFormResponseDetail> details,
      HostOfferEventConfiguration configuration) {
    final expiry = configuration.suggestedExpiresAt;
    if (expiry == null) return;
    if (_personalMode) {
      for (final detail in details) {
        final link = Uri.tryParse(_personalLinks[detail.contactId!] ?? '');
        if (link == null || link.scheme != 'https' || link.host.isEmpty ||
            link.userInfo.isNotEmpty || link.toString().length > 2048) {
          throw ArgumentError('A recipient payment link needs review.');
        }
      }
    }
    final draft = HostOfferBatchDraft(
      organizerId: organizerId,
      eventId: configuration.eventId,
      rows: [
        for (final detail in details)
          HostOfferRow(
            organizerId: organizerId,
            eventId: configuration.eventId,
            contactId: detail.contactId!,
            sourceKind: HostOfferSourceKind.formResponse,
            sourceId: detail.response.responseId,
            expiresAt: expiry,
            organizerPaymentLink: _personalMode
                ? Uri.tryParse(_personalLinks[detail.contactId!] ?? '')
                : null,
          ),
      ],
    );
    draft.validate(now: configuration.serverNow,
      eventStartsAt: configuration.startsAt);
    _update(() {
      _draft = draft;
      _commitRequestId = _newRequestId();
    });
  }

  Future<void> _previewPersonal() async {
    final accountId = this.accountId;
    final event = _event;
    final previous = _configuration;
    final generation = _generation;
    if (accountId == null || event == null || previous == null ||
        _loading || !_personalMode) return;
    _update(() { _loading = true; _error = null; });
    try {
      if (!await _revalidate(generation, accountId)) return;
      final details = await _resolveDetails();
      final current = await targets.configuration(
        organizerId: organizerId, eventId: event.eventId);
      if (!_current(generation, accountId)) return;
      if (current.eventSourceRevision != previous.eventSourceRevision ||
          current.suggestedExpiresAt != previous.suggestedExpiresAt ||
          current.paymentTerms?['preferredCollection'] !=
              previous.paymentTerms?['preferredCollection'] ||
          details.any((detail) => detail.contactId == null) ||
          details.asMap().entries.any((entry) =>
            entry.value.contactId != _details[entry.key].contactId)) {
        _update(() => _selectionStale = true);
        return;
      }
      _prepareDraft(details, current);
      if (_draft case final draft?) {
        await offerController.preview(
          draft: draft, now: now(),
          eventStartsAt: current.startsAt);
      }
    } on Object catch (error) {
      if (_current(generation, accountId)) _update(() => _error = error);
    } finally {
      if (_current(generation, accountId)) _update(() => _loading = false);
    }
  }

  static String _newRequestId() {
    final time = DateTime.now().microsecondsSinceEpoch.toRadixString(36);
    final random = List.generate(3,
      (_) => _entropy.nextInt(1 << 32).toRadixString(36)).join();
    return 'offer_${time}_$random';
  }

  Future<void> _returnForConversion(String responseId) async {
    final generation = _generation;
    final accountId = this.accountId;
    if (accountId == null) return;
    try {
      await openResponseForConversion(responseId);
      if (!_current(generation, accountId)) return;
      final event = _event;
      if (event != null) await _choose(event);
    } on Object catch (error) {
      if (_current(generation, accountId)) _update(() => _error = error);
    }
  }

  Future<void> _openSettings() async {
    final event = _event;
    final accountId = this.accountId;
    final generation = _generation;
    if (event == null || accountId == null) return;
    try {
      await openEventSettings(event.eventId);
      if (_current(generation, accountId)) await _choose(event);
    } on Object catch (error) {
      if (_current(generation, accountId)) _update(() => _error = error);
    }
  }

  Future<void> _refreshOffers() => _fetchOffers(append: false);

  Future<void> _fetchOffers({required bool append}) async {
    final event = _event;
    final accountId = this.accountId;
    final generation = _generation;
    if (event == null || accountId == null) return;
    try {
      final response = await listOffers(
        organizerId: organizerId, eventId: event.eventId,
        afterOfferId: append ? _nextOfferCursor : null);
      if (!_current(generation, accountId) || _event?.eventId != event.eventId) {
        return;
      }
      final rawItems = response['items'];
      final cursor = response['nextCursor'];
      if (rawItems is! List || cursor != null && cursor is! String) {
        throw const FormatException('Offer list is invalid.');
      }
      final parsed = rawItems.map((item) {
          if (item is! Map) throw const FormatException('Offer row is invalid.');
          return item.cast<String, Object?>();
        }).toList();
      if (parsed.any((item) => item['eventId'] != event.eventId ||
          item['offerId'] is! String || item['contactId'] is! String) ||
          parsed.map((item) => item['offerId']).toSet().length !=
              parsed.length ||
          append && cursor == _nextOfferCursor) {
        throw const FormatException('Offer list is inconsistent.');
      }
      // This workspace belongs to one selected response set. Keep unrelated
      // event offers out of the chooser without fetching private CRM labels.
      final selectedContacts = _details.map((detail) => detail.contactId)
          .whereType<String>().toSet();
      final visible = parsed.where((item) =>
          selectedContacts.contains(item['contactId'])).toList();
      final combined = append ? [..._offers, ...visible] : visible;
      if (combined.map((item) => item['offerId']).toSet().length !=
          combined.length) {
        throw const FormatException('Offer list repeats an offer.');
      }
      _update(() {
        _offers = List.unmodifiable(combined);
        _nextOfferCursor = cursor as String?;
      });
    } on Object catch (error) {
      if (_current(generation, accountId)) _update(() => _error = error);
    }
  }

  Future<void> _selectExisting(Map<String, Object?> item) async {
    final event = _event;
    final accountId = this.accountId;
    final generation = _generation;
    final contactId = item['contactId'];
    final offerId = item['offerId'];
    if (event == null || accountId == null || _loading ||
        contactId is! String || offerId is! String) return;
    _update(() { _loading = true; _error = null; });
    try {
      final offer = await getOffer(organizerId: organizerId,
        eventId: event.eventId, contactId: contactId);
      if (!_current(generation, accountId) ||
          _event?.eventId != event.eventId) return;
      if (offer.organizerId != organizerId ||
          offer.eventId != event.eventId ||
          offer.contactId != contactId || offer.offerId != offerId) {
        throw const FormatException('Offer detail does not match selection.');
      }
      _update(() {
        _selectedOffer = offer;
        _handoff = null;
        _referenceRequestId = _newRequestId();
        _reviewRequestId = _newRequestId();
        _messageCopied = false;
        _handoffOpenFailed = false;
      });
    } on Object catch (error) {
      if (_current(generation, accountId)) _update(() => _error = error);
    } finally {
      if (_current(generation, accountId)) _update(() => _loading = false);
    }
  }

  void _manualUpdated(HostEventOffer updated) {
    final previous = _selectedOffer;
    if (_disposed || previous == null ||
        previous.offerId != updated.offerId ||
        previous.organizerId != updated.organizerId ||
        previous.eventId != updated.eventId ||
        previous.contactId != updated.contactId) return;
    _update(() {
      _selectedOffer = updated;
      _handoff = null;
      _referenceRequestId = _newRequestId();
      _reviewRequestId = _newRequestId();
      _messageCopied = false;
    });
    _refreshOffers();
  }

  Future<void> _prepareHandoff() async {
    final selected = _selectedOffer;
    final accountId = this.accountId;
    final generation = _generation;
    if (selected == null || accountId == null || _loading) return;
    _update(() { _loading = true; _error = null; _handoff = null; });
    try {
      final current = await getOffer(
        organizerId: selected.organizerId, eventId: selected.eventId,
        contactId: selected.contactId);
      if (!_current(generation, accountId) ||
          !_sameSelectedOffer(selected)) return;
      if (current.offerId != selected.offerId ||
          current.organizerId != selected.organizerId ||
          current.eventId != selected.eventId ||
          current.contactId != selected.contactId) {
        throw const FormatException('Offer detail changed.');
      }
      final handoff = await prepareHandoff(offer: current);
      if (!_current(generation, accountId) ||
          !_sameSelectedOffer(selected)) return;
      if (handoff.offerId != current.offerId ||
          handoff.kind == 'prepared' &&
              handoff.contactId != current.contactId) {
        throw const FormatException('Offer handoff does not match selection.');
      }
      _update(() {
        _selectedOffer = current;
        _handoff = handoff;
        _messageCopied = false;
        _handoffOpenFailed = false;
      });
    } on Object catch (error) {
      if (_current(generation, accountId)) _update(() => _error = error);
    } finally {
      if (_current(generation, accountId)) _update(() => _loading = false);
    }
  }

  bool _sameSelectedOffer(HostEventOffer offer) =>
      _selectedOffer?.offerId == offer.offerId &&
      _selectedOffer?.revision == offer.revision &&
      _selectedOffer?.generation == offer.generation;

  Future<void> _copyHandoff() async {
    final handoff = _handoff;
    final accountId = this.accountId;
    final generation = _generation;
    if (handoff?.kind != 'prepared' || handoff?.copyText == null ||
        accountId == null || _loading) return;
    try {
      await copyMessage(handoff!.copyText!);
      if (_current(generation, accountId) && identical(_handoff, handoff)) {
        _update(() => _messageCopied = true);
      }
    } on Object catch (error) {
      if (_current(generation, accountId)) _update(() => _error = error);
    }
  }

  Future<void> _openWhatsapp() async {
    final handoff = _handoff;
    final accountId = this.accountId;
    final generation = _generation;
    if (handoff?.kind != 'prepared' || handoff?.whatsappUrl == null ||
        accountId == null || _loading) return;
    final uri = handoff!.whatsappUrl!;
    if (uri.scheme != 'https' || uri.host != 'wa.me' ||
        uri.userInfo.isNotEmpty ||
        !RegExp(r'^/[0-9]{8,15}$').hasMatch(uri.path)) {
      _update(() => _handoffOpenFailed = true);
      return;
    }
    try {
      final opened = await openHandoff(uri);
      if (_current(generation, accountId) && identical(_handoff, handoff)) {
        _update(() => _handoffOpenFailed = !opened);
      }
    } on Object {
      if (_current(generation, accountId)) {
        _update(() => _handoffOpenFailed = true);
      }
    }
  }


  bool get loading => _loading;
  Object? get error => _error;
  bool get selectionStale => _selectionStale;
  List<String> get ids => _ids;
  List<HostOfferEventTarget> get events => _events;
  String? get nextEventCursor => _nextEventCursor;
  HostOfferEventTarget? get event => _event;
  HostOfferEventConfiguration? get configuration => _configuration;
  List<HostFormResponseDetail> get details => _details;
  List<HostFormResponseDetail> get missingContacts => _missingContacts;
  HostOfferBatchDraft? get draft => _draft;
  String? get commitRequestId => _commitRequestId;
  List<Map<String, Object?>> get offers => _offers;
  String? get nextOfferCursor => _nextOfferCursor;
  HostEventOffer? get selectedOffer => _selectedOffer;
  HostOfferHandoff? get handoff => _handoff;
  String? get referenceRequestId => _referenceRequestId;
  String? get reviewRequestId => _reviewRequestId;
  bool get messageCopied => _messageCopied;
  bool get handoffOpenFailed => _handoffOpenFailed;
  bool get personalMode => _personalMode;

  Future<void> start() => _start();
  Future<void> loadEvents() => _loadEvents();
  Future<void> choose(HostOfferEventTarget event) => _choose(event);
  Future<void> previewPersonal() => _previewPersonal();
  Future<void> returnForConversion(String id) => _returnForConversion(id);
  Future<void> openSettings() => _openSettings();
  Future<void> refreshOffers() => _refreshOffers();
  Future<void> fetchMoreOffers() => _fetchOffers(append: true);
  Future<void> selectExisting(Map<String, Object?> item) =>
      _selectExisting(item);
  void manualUpdated(HostEventOffer offer) => _manualUpdated(offer);
  Future<void> prepareSelectedHandoff() => _prepareHandoff();
  Future<void> copyPreparedHandoff() => _copyHandoff();
  Future<void> openPreparedWhatsapp() => _openWhatsapp();
  void setPersonalLink(String contactId, String value) =>
      _personalLinks[contactId] = value.trim();

  void _update(VoidCallback change) {
    if (_disposed) return;
    change();
    notifyListeners();
  }

  @override
  void dispose() {
    ++_generation;
    _disposed = true;
    queryController.removeListener(_onQueryChanged);
    offerController.removeListener(_onOfferChanged);
    super.dispose();
  }
}
