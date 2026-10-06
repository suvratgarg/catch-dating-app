import 'dart:async';

import 'package:catch_dating_app/hosts/data/forms/host_offer_event_targets_gateway.dart';
import 'package:catch_dating_app/hosts/domain/forms/host_event_offer.dart';
import 'package:catch_dating_app/hosts/domain/forms/host_form_response.dart';
import 'package:catch_dating_app/hosts/presentation/forms/host_event_offer_controller.dart';
import 'package:catch_dating_app/hosts/presentation/forms/host_form_response_query_controller.dart';
import 'package:catch_dating_app/hosts/presentation/forms/host_offer_workspace_policy.dart';
import 'package:flutter/foundation.dart';

part 'host_event_offer_workspace_existing_offer.dart';

enum HostOfferWorkspaceStage {
  idle,
  loadingEvents,
  preparingOffer,
  loadingOffer,
  preparingMessage,
}

/// Owns query, event, CRM, offer, and handoff orchestration for one account.
/// The section below this layer only renders state and dispatches commands.
class HostEventOfferWorkspaceController extends ChangeNotifier {
  HostEventOfferWorkspaceController({
    required this.organizerId,
    required this.accountId,
    this.queryController,
    this.responseId,
    required this.offerController,
    required this.listOffers,
    required this.getOffer,
    required this.prepareHandoff,
    required this.copyMessage,
    required this.openHandoff,
    required this.targets,
    required this.getResponseDetail,
    this.isResponseReviewed,
    required this.openResponseForConversion,
    required this.openEventSettings,
    required this.now,
    this.initialEventId,
    this.initialEventTarget,
  }) {
    assert((queryController == null) != (responseId == null));
    queryController?.addListener(_onQueryChanged);
    offerController.addListener(_onOfferChanged);
  }

  final String organizerId;
  final String? accountId;
  final HostResponseQueryController? queryController;
  final String? responseId;
  final HostEventOfferController offerController;
  Future<Map<String, Object?>> Function({
    required String organizerId,
    required String eventId,
    String? afterOfferId,
  })
  listOffers;
  Future<HostEventOffer> Function({
    required String organizerId,
    required String eventId,
    required String contactId,
  })
  getOffer;
  Future<HostOfferHandoff> Function({required HostEventOffer offer})
  prepareHandoff;
  Future<void> Function(String text) copyMessage;
  Future<bool> Function(Uri uri) openHandoff;
  HostOfferEventTargetsGateway targets;
  Future<HostFormResponseDetail> Function(String responseId) getResponseDetail;
  Future<bool> Function(HostFormResponseDetail)? isResponseReviewed;
  Future<void> Function(String responseId) openResponseForConversion;
  Future<void> Function(String eventId) openEventSettings;
  DateTime Function() now;
  final String? initialEventId;

  /// A newly saved event read back through the manager-only setup projection.
  /// The configuration read in [_choose] still checks current event authority.
  final HostOfferEventTarget? initialEventTarget;
  bool _disposed = false;

  /// Parent rebuilds can supply fresh closures without changing the reviewed
  /// account, query or event context. Keep those callbacks current in place.
  void updateDependencies({
    required Future<Map<String, Object?>> Function({
      required String organizerId,
      required String eventId,
      String? afterOfferId,
    })
    listOffers,
    required Future<HostEventOffer> Function({
      required String organizerId,
      required String eventId,
      required String contactId,
    })
    getOffer,
    required Future<HostOfferHandoff> Function({required HostEventOffer offer})
    prepareHandoff,
    required Future<void> Function(String text) copyMessage,
    required Future<bool> Function(Uri uri) openHandoff,
    required HostOfferEventTargetsGateway targets,
    required Future<HostFormResponseDetail> Function(String responseId)
    getResponseDetail,
    Future<bool> Function(HostFormResponseDetail)? isResponseReviewed,
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
    this.isResponseReviewed = isResponseReviewed;
    this.openResponseForConversion = openResponseForConversion;
    this.openEventSettings = openEventSettings;
    this.now = now;
  }

  int _generation = 0;
  bool _loading = false;
  HostOfferWorkspaceStage _stage = HostOfferWorkspaceStage.idle;
  bool _recoveringPending = false;
  bool _refreshTargetOnRetry = false;
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
      !_disposed &&
      generation == _generation &&
      accountId != null &&
      accountId == this.accountId;

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
    _stage = HostOfferWorkspaceStage.idle;
    _recoveringPending = false;
    _refreshTargetOnRetry = false;
    _error = null;
    _selectionStale = false;
  }

  void _onQueryChanged() {
    if (_ids.isEmpty) {
      return;
    }
    final intent = queryController?.selectionIntent;
    if (intent?.resultHash == _resultHash && _sameIds(intent!.ids, _ids)) {
      return;
    }
    if (hasUnresolvedCommand) {
      // Query changes cannot discard a command that may already have reached
      // the server. Keep its exact draft and request available for recovery.
      _update(() {
        ++_generation;
        _selectionStale = true;
        _loading = false;
        _stage = HostOfferWorkspaceStage.idle;
        _recoveringPending = false;
        _draft = offerController.view.draft ?? _draft;
        _commitRequestId = offerController.view.pendingRequestId;
      });
      return;
    }
    _update(() {
      _reset();
      _selectionStale = true;
    });
  }

  void _onOfferChanged() {
    final view = offerController.view;
    final receipt = view.receipt;
    if (view.status != HostOfferFlowStatus.committed ||
        receipt == null ||
        receipt.requestId == _refreshedReceiptId ||
        receipt.eventId != _event?.eventId) {
      return;
    }
    _refreshedReceiptId = receipt.requestId;
    refreshOffers().then((_) {
      if (!_disposed && _ids.length == 1 && _offers.length == 1) {
        selectExisting(_offers.single);
      }
    });
  }

  static bool _sameIds(List<String> a, List<String> b) =>
      a.length == b.length && a.toSet().containsAll(b);

  Future<bool> _revalidate(int generation, String accountId) async {
    if (!_current(generation, accountId) || _resultHash == null) {
      return false;
    }
    final query = queryController;
    final valid = query == null
        ? _ids.length == 1 && _ids.single == responseId
        : await query.revalidateSelection(ids: _ids, resultHash: _resultHash!);
    if (!_current(generation, accountId)) {
      return false;
    }
    if (!valid) {
      _update(() {
        _selectionStale = true;
        _draft = null;
      });
    }
    return valid;
  }

  Future<void> start() async {
    if (loading || hasUnresolvedCommand) return;
    final accountId = this.accountId;
    final intent =
        queryController?.selectionIntent ??
        (responseId == null
            ? null
            : (ids: [responseId!], resultHash: responseId!));
    if (accountId == null || intent == null || intent.ids.length > 25) {
      return;
    }
    _update(() {
      _reset();
      _ids = List.unmodifiable(intent.ids);
      _resultHash = intent.resultHash;
    });
    if (initialEventTarget case final target?) {
      _update(() => _events = List.unmodifiable([target]));
      await choose(target);
      return;
    }
    await loadEvents();
  }

  Future<void> loadEvents() async {
    if (_loading) {
      return;
    }
    final generation = _generation;
    final accountId = this.accountId;
    if (accountId == null) {
      return;
    }
    final cursor = _nextEventCursor;
    _update(() {
      _loading = true;
      _stage = HostOfferWorkspaceStage.loadingEvents;
      _error = null;
    });
    try {
      final page = await targets.list(organizerId: organizerId, cursor: cursor);
      if (!_current(generation, accountId)) {
        return;
      }
      if (cursor != null && cursor == page.nextCursor) {
        throw const FormatException('Offer target page repeated.');
      }
      _update(() {
        _events = List.unmodifiable(
          {
            for (final event in _events) event.eventId: event,
            for (final event in page.events) event.eventId: event,
          }.values,
        );
        _nextEventCursor = page.nextCursor;
      });
      if (initialEventId case final initialId?) {
        final matches = page.events.where(
          (event) => event.eventId == initialId,
        );
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
      if (_current(generation, accountId)) {
        _update(() {
          _loading = false;
          _stage = HostOfferWorkspaceStage.idle;
        });
      }
    }
  }

  Future<List<HostFormResponseDetail>> _resolveDetails({
    bool Function()? isCurrent,
  }) => HostOfferWorkspacePolicy.resolveDetails(
    ids: _ids,
    getResponseDetail: getResponseDetail,
    queryConfigured: queryController != null,
    currentRequest: () => queryController?.view.request,
    isCurrent: isCurrent,
  );

  Future<void> choose(HostOfferEventTarget event) => _prepare(event);

  Future<void> _prepare(
    HostOfferEventTarget event, {
    bool refreshTarget = false,
  }) async {
    final accountId = this.accountId;
    if (accountId == null ||
        loading ||
        _selectionStale ||
        hasUnresolvedCommand) {
      return;
    }
    final generation = ++_generation;
    if (_event?.eventId != event.eventId) _personalLinks.clear();
    _update(() {
      _loading = true;
      _stage = HostOfferWorkspaceStage.preparingOffer;
      _refreshTargetOnRetry = refreshTarget;
      _event = event;
      _configuration = null;
      _details = const [];
      _missingContacts = const [];
      _draft = null;
      _commitRequestId = null;
      _offers = const [];
      _nextOfferCursor = null;
      _selectedOffer = null;
      _handoff = null;
      _error = null;
    });
    try {
      if (!await _revalidate(generation, accountId)) {
        return;
      }
      late HostOfferEventConfiguration configuration;
      late List<HostFormResponseDetail> details;
      late List<HostFormResponseDetail> missing;
      late Map<String, Object?> existing;
      // These manager reads are independent. Accept their combined result
      // only after the selection and account fences have been checked again.
      await Future.wait<void>([
        (() async {
          configuration = await targets.configuration(
            organizerId: organizerId,
            eventId: event.eventId,
          );
        })(),
        (() async {
          details = await _resolveDetails(
            isCurrent: () => _current(generation, accountId),
          );
          missing = await HostOfferWorkspacePolicy.missingContacts(
            details: details,
            isResponseReviewed: isResponseReviewed,
            isCurrent: () => _current(generation, accountId),
          );
        })(),
        (() async {
          existing = await listOffers(
            organizerId: organizerId,
            eventId: event.eventId,
          );
        })(),
      ]);
      if (!await _revalidate(generation, accountId)) {
        return;
      }
      if (!_current(generation, accountId)) {
        return;
      }
      final selected = refreshTarget
          ? HostOfferEventTarget(
              eventId: event.eventId,
              name: event.name,
              startTime: configuration.startsAt,
              timezone: event.timezone,
              publicationState: event.publicationState,
              setupRevision: event.setupRevision == null
                  ? null
                  : configuration.eventSourceRevision,
            )
          : event;
      if (!HostOfferWorkspacePolicy.configurationMatches(
        configuration,
        selected,
        organizerId,
      )) {
        throw StateError('Selected responses changed.');
      }
      final page = HostOfferWorkspacePolicy.offerPage(
        response: existing,
        eventId: event.eventId,
        previousCursor: null,
        append: false,
        details: details,
        offers: const [],
      );
      _update(() {
        _event = selected;
        _events = List.unmodifiable([
          for (final item in _events)
            item.eventId == selected.eventId ? selected : item,
        ]);
        _configuration = configuration;
        _details = List.unmodifiable(details);
        _missingContacts = List.unmodifiable(missing);
        _draft = null;
        _commitRequestId = null;
        _selectedOffer = null;
        _handoff = null;
        _offers = page.items;
        _nextOfferCursor = page.cursor;
      });
      if (missing.isEmpty &&
          configuration.suggestedExpiresAt != null &&
          _current(generation, accountId)) {
        // A saved command keeps its original identity. Do not allow a local
        // preparation cancel to race publication of that recovery result.
        _update(() => _recoveringPending = true);
        try {
          await offerController.recoverPending(
            organizerId: organizerId,
            eventId: event.eventId,
            isCurrent: () => _current(generation, accountId),
          );
        } finally {
          if (_current(generation, accountId)) {
            _update(() => _recoveringPending = false);
          }
        }
        if (!_current(generation, accountId)) {
          return;
        }
        final pending = offerController.view;
        if (hasUnresolvedCommand && pending.draft != null) {
          // Replay the exact saved command. Never rotate its request identity
          // after an ambiguous result or app restart.
          _update(() {
            _draft = pending.draft;
            _commitRequestId = pending.pendingRequestId;
          });
          return;
        }
        if (_ids.length == 1 && _offers.length == 1) {
          // Select after releasing the event-loading interlock.
          final existing = _offers.single;
          scheduleMicrotask(() {
            if (_current(generation, accountId)) selectExisting(existing);
          });
        } else if (!_personalMode) {
          _prepareDraft(details, configuration);
        }
      }
    } on Object catch (error) {
      if (_current(generation, accountId)) _update(() => _error = error);
    } finally {
      if (_current(generation, accountId)) {
        _update(() {
          _loading = false;
          _stage = HostOfferWorkspaceStage.idle;
        });
      }
    }
  }

  bool get _personalMode =>
      _configuration?.paymentTerms?['preferredCollection'] == 'personalRequest';

  void _prepareDraft(
    List<HostFormResponseDetail> details,
    HostOfferEventConfiguration configuration,
  ) {
    final expiry = configuration.suggestedExpiresAt;
    if (expiry == null) {
      return;
    }
    final draft = HostOfferWorkspacePolicy.draft(
      organizerId: organizerId,
      details: details,
      configuration: configuration,
      personalMode: _personalMode,
      personalLinks: _personalLinks,
    );
    _update(() {
      _draft = draft;
      _commitRequestId = HostOfferWorkspacePolicy.newRequestId();
    });
  }

  Future<void> previewPersonal() async {
    final accountId = this.accountId;
    final event = _event;
    final previous = _configuration;
    final generation = _generation;
    if (accountId == null ||
        event == null ||
        previous == null ||
        loading ||
        _selectionStale ||
        hasUnresolvedCommand ||
        !_personalMode) {
      return;
    }
    _update(() {
      _loading = true;
      _stage = HostOfferWorkspaceStage.preparingOffer;
      _error = null;
    });
    try {
      if (!await _revalidate(generation, accountId)) {
        return;
      }
      late List<HostFormResponseDetail> details;
      late List<HostFormResponseDetail> missing;
      late HostOfferEventConfiguration current;
      await Future.wait<void>([
        (() async {
          details = await _resolveDetails(
            isCurrent: () => _current(generation, accountId),
          );
          missing = await HostOfferWorkspacePolicy.missingContacts(
            details: details,
            isResponseReviewed: isResponseReviewed,
            isCurrent: () => _current(generation, accountId),
          );
        })(),
        (() async {
          current = await targets.configuration(
            organizerId: organizerId,
            eventId: event.eventId,
          );
        })(),
      ]);
      if (!await _revalidate(generation, accountId)) {
        return;
      }
      if (missing.isNotEmpty) {
        _update(() {
          _missingContacts = List.unmodifiable(missing);
          _draft = null;
        });
        return;
      }
      if (HostOfferWorkspacePolicy.personalReviewChanged(
        current,
        previous,
        details,
        _details,
      )) {
        _update(() => _selectionStale = true);
        return;
      }
      _update(() => _recoveringPending = true);
      _prepareDraft(details, current);
      if (_draft case final draft?) {
        await offerController.preview(
          draft: draft,
          now: now(),
          eventStartsAt: current.startsAt,
        );
      }
    } on Object catch (error) {
      if (_current(generation, accountId)) _update(() => _error = error);
    } finally {
      if (_current(generation, accountId)) {
        _update(() {
          _loading = false;
          _stage = HostOfferWorkspaceStage.idle;
          _recoveringPending = false;
        });
      }
    }
  }

  Future<void> returnForConversion(String responseId) async {
    final generation = _generation;
    final accountId = this.accountId;
    if (accountId == null) {
      return;
    }
    try {
      await openResponseForConversion(responseId);
      if (!_current(generation, accountId)) {
        return;
      }
      final event = _event;
      if (event != null) await choose(event);
    } on Object catch (error) {
      if (_current(generation, accountId)) _update(() => _error = error);
    }
  }

  Future<void> openSettings() async {
    final event = _event;
    final accountId = this.accountId;
    final generation = _generation;
    if (event == null || accountId == null || loading || hasUnresolvedCommand) {
      return;
    }
    _update(() {
      _loading = true;
      _error = null;
    });
    try {
      await openEventSettings(event.eventId);
      if (!_current(generation, accountId)) {
        return;
      }
    } on Object catch (error) {
      if (_current(generation, accountId)) _update(() => _error = error);
      return;
    } finally {
      if (_current(generation, accountId)) _update(() => _loading = false);
    }
    if (!_current(generation, accountId)) return;
    // One fresh configuration read both updates the target revision and
    // prepares the offer after returning from settings.
    await _prepare(event, refreshTarget: true);
  }

  bool get loading =>
      _loading ||
      offerController.view.status == HostOfferFlowStatus.previewing ||
      offerController.view.status == HostOfferFlowStatus.committing;

  bool get hasUnresolvedCommand =>
      offerController.view.pendingRequestId != null &&
      offerController.view.status != HostOfferFlowStatus.committed;

  HostOfferWorkspaceStage get stage => _stage;
  bool get preparing => _stage == HostOfferWorkspaceStage.preparingOffer;
  bool get canCancelPreparation =>
      preparing &&
      !_recoveringPending &&
      !hasUnresolvedCommand &&
      offerController.view.status != HostOfferFlowStatus.previewing &&
      offerController.view.status != HostOfferFlowStatus.committing;

  void cancelPreparation() {
    if (!canCancelPreparation) return;
    _update(() {
      ++_generation;
      _loading = false;
      _stage = HostOfferWorkspaceStage.idle;
      _clearEvent();
    });
  }

  Future<void> retry() async {
    if (loading || hasUnresolvedCommand) return;
    if (_selectionStale) {
      await start();
    } else if (_event case final selected?) {
      await _prepare(selected, refreshTarget: _refreshTargetOnRetry);
    } else {
      await loadEvents();
    }
  }

  void _clearEvent() {
    _event = null;
    _configuration = null;
    _details = const [];
    _missingContacts = const [];
    _draft = null;
    _commitRequestId = null;
    _selectedOffer = null;
    _handoff = null;
    _offers = const [];
    _nextOfferCursor = null;
    _error = null;
    _personalLinks.clear();
  }

  void changeEvent() {
    if (canCancelPreparation) {
      cancelPreparation();
      return;
    }
    if (loading || hasUnresolvedCommand) return;
    _update(() {
      ++_generation;
      _clearEvent();
    });
    if (_events.length <= 1 && initialEventTarget != null) loadEvents();
  }

  bool get hasError => _error != null;
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
  String? get selectedResponseId =>
      HostOfferWorkspacePolicy.selectedResponseId(_selectedOffer, _details);

  HostOfferHandoff? get handoff => _handoff;
  String? get referenceRequestId => _referenceRequestId;
  String? get reviewRequestId => _reviewRequestId;
  bool get messageCopied => _messageCopied;
  bool get handoffOpenFailed => _handoffOpenFailed;
  bool get personalMode => _personalMode;

  void setPersonalLink(String contactId, String value) =>
      _personalLinks[contactId] = value.trim();

  void _update(VoidCallback change) {
    if (_disposed) {
      return;
    }
    change();
    notifyListeners();
  }

  @override
  void dispose() {
    ++_generation;
    _disposed = true;
    queryController?.removeListener(_onQueryChanged);
    offerController.removeListener(_onOfferChanged);
    super.dispose();
  }
}
