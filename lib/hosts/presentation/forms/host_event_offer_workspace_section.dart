import 'dart:math';

import 'package:catch_dating_app/core/presentation/catch_ui_copy.dart';
import 'package:catch_dating_app/core/time_formatters.dart';
import 'package:catch_dating_app/hosts/data/forms/host_offer_event_targets_gateway.dart';
import 'package:catch_dating_app/hosts/domain/forms/host_event_offer.dart';
import 'package:catch_dating_app/hosts/domain/forms/host_form_response.dart';
import 'package:catch_dating_app/hosts/presentation/forms/host_event_offer_controller.dart';
import 'package:catch_dating_app/hosts/presentation/forms/host_event_offer_review_section.dart';
import 'package:catch_dating_app/hosts/presentation/forms/host_form_response_query_controller.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';

class HostEventOfferWorkspaceCopy {
  const HostEventOfferWorkspaceCopy({
    required this.create,
    required this.selectEvent,
    required this.emptyEvents,
    required this.untitledEvent,
    required this.loadMoreEvents,
    required this.needsContact,
    required this.convertContact,
    required this.selectionChanged,
    required this.loadFailed,
    required this.issued,
    required this.refresh,
    required this.existing,
    required this.noOffers,
    required this.configurePayment,
    required this.openSettings,
    required this.statusDraft,
    required this.statusOffered,
    required this.statusWithdrawn,
    required this.statusExpired,
    required this.personalPaymentLink,
    required this.openExisting,
    required this.handoffPrepare,
    required this.handoffBlocked,
    required this.handoffDisclosure,
    required this.openWhatsapp,
    required this.copyMessage,
    required this.messageCopied,
    required this.handoffOpenFailed,
    required this.review,
  });

  final String create;
  final String selectEvent;
  final String emptyEvents;
  final String untitledEvent;
  final String loadMoreEvents;
  final String needsContact;
  final String convertContact;
  final String selectionChanged;
  final String loadFailed;
  final String issued;
  final String refresh;
  final String existing;
  final String noOffers;
  final String configurePayment;
  final String openSettings;
  final String statusDraft;
  final String statusOffered;
  final String statusWithdrawn;
  final String statusExpired;
  final String Function(String name) personalPaymentLink;
  final String openExisting;
  final String handoffPrepare;
  final String handoffBlocked;
  final String handoffDisclosure;
  final String openWhatsapp;
  final String copyMessage;
  final String messageCopied;
  final String handoffOpenFailed;
  final HostEventOfferReviewCopy review;
}

/// One manager's reviewed query selection. No offer is prepared from a list
/// label alone: every selected response is read again and the materialized
/// query hash is rechecked after the event choice and an inline return.
class HostEventOfferWorkspaceSection extends StatefulWidget {
  const HostEventOfferWorkspaceSection({
    super.key,
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
    required this.copy,
    required this.now,
    this.initiallyReviewSelection = false,
    this.initialEventId,
  });

  final String organizerId;
  final String? accountId;
  final HostResponseQueryController queryController;
  final HostEventOfferController offerController;
  final Future<Map<String, Object?>> Function({
    required String organizerId,
    required String eventId,
    String? afterOfferId,
  }) listOffers;
  final Future<HostEventOffer> Function({required String organizerId,
    required String eventId, required String contactId}) getOffer;
  final Future<HostOfferHandoff> Function({required HostEventOffer offer})
      prepareHandoff;
  final Future<void> Function(String text) copyMessage;
  final Future<bool> Function(Uri uri) openHandoff;
  final HostOfferEventTargetsGateway targets;
  final Future<HostFormResponseDetail> Function(String responseId)
      getResponseDetail;
  final Future<void> Function(String responseId) openResponseForConversion;
  final Future<void> Function(String eventId) openEventSettings;
  final HostEventOfferWorkspaceCopy copy;
  final DateTime Function() now;
  final bool initiallyReviewSelection;
  final String? initialEventId;

  @override
  State<HostEventOfferWorkspaceSection> createState() =>
      _HostEventOfferWorkspaceSectionState();
}

class _HostEventOfferWorkspaceSectionState
    extends State<HostEventOfferWorkspaceSection> {
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

  @override
  void initState() {
    super.initState();
    widget.queryController.addListener(_onQueryChanged);
    widget.offerController.addListener(_onOfferChanged);
    if (widget.initiallyReviewSelection) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _start();
      });
    }
  }

  @override
  void didUpdateWidget(covariant HostEventOfferWorkspaceSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.queryController != widget.queryController) {
      oldWidget.queryController.removeListener(_onQueryChanged);
      widget.queryController.addListener(_onQueryChanged);
    }
    if (oldWidget.offerController != widget.offerController) {
      oldWidget.offerController.removeListener(_onOfferChanged);
      widget.offerController.addListener(_onOfferChanged);
    }
    if (oldWidget.organizerId != widget.organizerId ||
        oldWidget.accountId != widget.accountId ||
        oldWidget.queryController != widget.queryController) {
      _reset();
    }
  }

  @override
  void dispose() {
    ++_generation;
    widget.queryController.removeListener(_onQueryChanged);
    widget.offerController.removeListener(_onOfferChanged);
    super.dispose();
  }

  bool _current(int generation, String? accountId) =>
      mounted && generation == _generation &&
      accountId != null && accountId == widget.accountId;

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
    final intent = widget.queryController.selectionIntent;
    if (intent?.resultHash == _resultHash &&
        _sameIds(intent!.ids, _ids)) return;
    setState(_reset);
  }

  void _onOfferChanged() {
    final view = widget.offerController.view;
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
    final valid = await widget.queryController.revalidateSelection(
      ids: _ids, resultHash: _resultHash!);
    if (!_current(generation, accountId)) return false;
    if (!valid) {
      setState(() {
        _selectionStale = true;
        _draft = null;
      });
    }
    return valid;
  }

  Future<void> _start() async {
    final accountId = widget.accountId;
    final intent = widget.queryController.selectionIntent;
    if (accountId == null || intent == null || intent.ids.length > 25) return;
    setState(() {
      _reset();
      _ids = List.unmodifiable(intent.ids);
      _resultHash = intent.resultHash;
    });
    await _loadEvents();
  }

  Future<void> _loadEvents() async {
    if (_loading) return;
    final generation = _generation;
    final accountId = widget.accountId;
    if (accountId == null) return;
    final cursor = _nextEventCursor;
    setState(() { _loading = true; _error = null; });
    try {
      final page = await widget.targets.list(
        organizerId: widget.organizerId, cursor: cursor);
      if (!_current(generation, accountId)) return;
      if (cursor != null && cursor == page.nextCursor) {
        throw const FormatException('Offer target page repeated.');
      }
      setState(() {
        _events = List.unmodifiable({
          for (final event in _events) event.eventId: event,
          for (final event in page.events) event.eventId: event,
        }.values);
        _nextEventCursor = page.nextCursor;
      });
      if (widget.initialEventId case final initialId?) {
        final matches = page.events.where((event) => event.eventId == initialId);
        if (matches.isNotEmpty) {
          // _choose runs after the list loading interlock is released.
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && _current(generation, accountId)) {
              _choose(matches.first);
            }
          });
        }
      }
    } on Object catch (error) {
      if (_current(generation, accountId)) setState(() => _error = error);
    } finally {
      if (_current(generation, accountId)) setState(() => _loading = false);
    }
  }

  Future<List<HostFormResponseDetail>> _resolveDetails() async {
    final details = <HostFormResponseDetail>[];
    // Four bounded callable reads at a time, no partial batch acceptance.
    for (var offset = 0; offset < _ids.length; offset += 4) {
      final end = min(offset + 4, _ids.length);
      details.addAll(await Future.wait(
        _ids.sublist(offset, end).map(widget.getResponseDetail),
      ));
    }
    final request = widget.queryController.view.request;
    if (request == null || details.length != _ids.length ||
        details.asMap().entries.any((entry) =>
          entry.value.response.responseId != _ids[entry.key] ||
          entry.value.response.formId != request.formId ||
          entry.value.response.versionId != request.versionId ||
          entry.value.response.status != HostFormResponseStatus.submitted)) {
      throw StateError(widget.copy.selectionChanged);
    }
    return details;
  }

  Future<void> _choose(HostOfferEventTarget event) async {
    final generation = _generation;
    final accountId = widget.accountId;
    if (accountId == null || _loading) return;
    if (_event?.eventId != event.eventId) _personalLinks.clear();
    setState(() { _loading = true; _error = null; });
    try {
      if (!await _revalidate(generation, accountId)) return;
      final configuration = await widget.targets.configuration(
        organizerId: widget.organizerId, eventId: event.eventId);
      final details = await _resolveDetails();
      if (!await _revalidate(generation, accountId)) return;
      if (!_current(generation, accountId)) return;
      if (configuration.organizerId != widget.organizerId ||
          configuration.eventId != event.eventId ||
          !configuration.startsAt.isAtSameMomentAs(event.startTime) ||
          event.setupRevision != null &&
              configuration.eventSourceRevision != event.setupRevision) {
        throw StateError(widget.copy.selectionChanged);
      }
      final missing = details.where((detail) =>
          detail.contactId == null || detail.contactId!.isEmpty).toList();
      setState(() {
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
        await widget.offerController.recoverPending(
          organizerId: widget.organizerId, eventId: event.eventId);
        if (!_current(generation, accountId)) return;
        final pending = widget.offerController.view;
        if (pending.pendingRequestId != null && pending.draft != null) {
          // Replay the exact saved command. Never rotate its request identity
          // after an ambiguous result or app restart.
          setState(() {
            _draft = pending.draft;
            _commitRequestId = pending.pendingRequestId;
          });
          return;
        }
        if (!_personalMode) _prepareDraft(details, configuration);
      }
    } on Object catch (error) {
      if (_current(generation, accountId)) setState(() => _error = error);
    } finally {
      if (_current(generation, accountId)) setState(() => _loading = false);
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
      organizerId: widget.organizerId,
      eventId: configuration.eventId,
      rows: [
        for (final detail in details)
          HostOfferRow(
            organizerId: widget.organizerId,
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
    setState(() {
      _draft = draft;
      _commitRequestId = _newRequestId();
    });
  }

  Future<void> _previewPersonal() async {
    final accountId = widget.accountId;
    final event = _event;
    final previous = _configuration;
    final generation = _generation;
    if (accountId == null || event == null || previous == null ||
        _loading || !_personalMode) return;
    setState(() { _loading = true; _error = null; });
    try {
      if (!await _revalidate(generation, accountId)) return;
      final details = await _resolveDetails();
      final current = await widget.targets.configuration(
        organizerId: widget.organizerId, eventId: event.eventId);
      if (!_current(generation, accountId)) return;
      if (current.eventSourceRevision != previous.eventSourceRevision ||
          current.suggestedExpiresAt != previous.suggestedExpiresAt ||
          current.paymentTerms?['preferredCollection'] !=
              previous.paymentTerms?['preferredCollection'] ||
          details.any((detail) => detail.contactId == null) ||
          details.asMap().entries.any((entry) =>
            entry.value.contactId != _details[entry.key].contactId)) {
        setState(() => _selectionStale = true);
        return;
      }
      _prepareDraft(details, current);
      if (_draft case final draft?) {
        await widget.offerController.preview(
          draft: draft, now: widget.now(),
          eventStartsAt: current.startsAt);
      }
    } on Object catch (error) {
      if (_current(generation, accountId)) setState(() => _error = error);
    } finally {
      if (_current(generation, accountId)) setState(() => _loading = false);
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
    final accountId = widget.accountId;
    if (accountId == null) return;
    try {
      await widget.openResponseForConversion(responseId);
      if (!_current(generation, accountId)) return;
      final event = _event;
      if (event != null) await _choose(event);
    } on Object catch (error) {
      if (_current(generation, accountId)) setState(() => _error = error);
    }
  }

  Future<void> _openSettings() async {
    final event = _event;
    final accountId = widget.accountId;
    final generation = _generation;
    if (event == null || accountId == null) return;
    try {
      await widget.openEventSettings(event.eventId);
      if (_current(generation, accountId)) await _choose(event);
    } on Object catch (error) {
      if (_current(generation, accountId)) setState(() => _error = error);
    }
  }

  Future<void> _refreshOffers() => _fetchOffers(append: false);

  Future<void> _fetchOffers({required bool append}) async {
    final event = _event;
    final accountId = widget.accountId;
    final generation = _generation;
    if (event == null || accountId == null) return;
    try {
      final response = await widget.listOffers(
        organizerId: widget.organizerId, eventId: event.eventId,
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
      setState(() {
        _offers = List.unmodifiable(combined);
        _nextOfferCursor = cursor as String?;
      });
    } on Object catch (error) {
      if (_current(generation, accountId)) setState(() => _error = error);
    }
  }

  Future<void> _selectExisting(Map<String, Object?> item) async {
    final event = _event;
    final accountId = widget.accountId;
    final generation = _generation;
    final contactId = item['contactId'];
    final offerId = item['offerId'];
    if (event == null || accountId == null || _loading ||
        contactId is! String || offerId is! String) return;
    setState(() { _loading = true; _error = null; });
    try {
      final offer = await widget.getOffer(organizerId: widget.organizerId,
        eventId: event.eventId, contactId: contactId);
      if (!_current(generation, accountId) ||
          _event?.eventId != event.eventId) return;
      if (offer.organizerId != widget.organizerId ||
          offer.eventId != event.eventId ||
          offer.contactId != contactId || offer.offerId != offerId) {
        throw const FormatException('Offer detail does not match selection.');
      }
      setState(() {
        _selectedOffer = offer;
        _handoff = null;
        _referenceRequestId = _newRequestId();
        _reviewRequestId = _newRequestId();
        _messageCopied = false;
        _handoffOpenFailed = false;
      });
    } on Object catch (error) {
      if (_current(generation, accountId)) setState(() => _error = error);
    } finally {
      if (_current(generation, accountId)) setState(() => _loading = false);
    }
  }

  void _manualUpdated(HostEventOffer updated) {
    final previous = _selectedOffer;
    if (!mounted || previous == null ||
        previous.offerId != updated.offerId ||
        previous.organizerId != updated.organizerId ||
        previous.eventId != updated.eventId ||
        previous.contactId != updated.contactId) return;
    setState(() {
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
    final accountId = widget.accountId;
    final generation = _generation;
    if (selected == null || accountId == null || _loading) return;
    setState(() { _loading = true; _error = null; _handoff = null; });
    try {
      final current = await widget.getOffer(
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
      final handoff = await widget.prepareHandoff(offer: current);
      if (!_current(generation, accountId) ||
          !_sameSelectedOffer(selected)) return;
      if (handoff.offerId != current.offerId ||
          handoff.kind == 'prepared' &&
              handoff.contactId != current.contactId) {
        throw const FormatException('Offer handoff does not match selection.');
      }
      setState(() {
        _selectedOffer = current;
        _handoff = handoff;
        _messageCopied = false;
        _handoffOpenFailed = false;
      });
    } on Object catch (error) {
      if (_current(generation, accountId)) setState(() => _error = error);
    } finally {
      if (_current(generation, accountId)) setState(() => _loading = false);
    }
  }

  bool _sameSelectedOffer(HostEventOffer offer) =>
      _selectedOffer?.offerId == offer.offerId &&
      _selectedOffer?.revision == offer.revision &&
      _selectedOffer?.generation == offer.generation;

  Future<void> _copyHandoff() async {
    final handoff = _handoff;
    final accountId = widget.accountId;
    final generation = _generation;
    if (handoff?.kind != 'prepared' || handoff?.copyText == null ||
        accountId == null || _loading) return;
    try {
      await widget.copyMessage(handoff!.copyText!);
      if (_current(generation, accountId) && identical(_handoff, handoff)) {
        setState(() => _messageCopied = true);
      }
    } on Object catch (error) {
      if (_current(generation, accountId)) setState(() => _error = error);
    }
  }

  Future<void> _openWhatsapp() async {
    final handoff = _handoff;
    final accountId = widget.accountId;
    final generation = _generation;
    if (handoff?.kind != 'prepared' || handoff?.whatsappUrl == null ||
        accountId == null || _loading) return;
    final uri = handoff!.whatsappUrl!;
    if (uri.scheme != 'https' || uri.host != 'wa.me' ||
        uri.userInfo.isNotEmpty ||
        !RegExp(r'^/[0-9]{8,15}$').hasMatch(uri.path)) {
      setState(() => _handoffOpenFailed = true);
      return;
    }
    try {
      final opened = await widget.openHandoff(uri);
      if (_current(generation, accountId) && identical(_handoff, handoff)) {
        setState(() => _handoffOpenFailed = !opened);
      }
    } on Object {
      if (_current(generation, accountId)) {
        setState(() => _handoffOpenFailed = true);
      }
    }
  }

  String _offerLabel(Map<String, Object?> offer) =>
      _details.where((detail) =>
          detail.contactId == offer['contactId']).firstOrNull
          ?.response.identity.primaryLabel ?? widget.copy.existing;

  String _offerStatus(Object? status) => switch (status) {
    'draft' => widget.copy.statusDraft,
    'offered' => widget.copy.statusOffered,
    'withdrawn' => widget.copy.statusWithdrawn,
    'expired' => widget.copy.statusExpired,
    _ => widget.copy.loadFailed,
  };

  String _eventTimeLabel(HostOfferEventTarget event) {
    final local = event.startTime.toLocal();
    final displayed = '${AppTimeFormatters.dateTime(local)} '
        '${local.timeZoneName}';
    final eventZone = event.timezone?.trim();
    return eventZone == null || eventZone.isEmpty ||
        eventZone == local.timeZoneName
        ? displayed : '$displayed · $eventZone';
  }

  @override
  Widget build(BuildContext context) {
    final copy = widget.copy;
    final intent = widget.queryController.selectionIntent;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (intent != null && widget.accountId != null)
          CatchSection.content(child: CatchButton(
            label: copy.create,
            onPressed: _loading ? null : _start,
          )),
        if (_ids.isNotEmpty) ...[
          CatchSection.content(child: Text(copy.selectEvent,
            style: CatchTextStyles.sectionTitle(context))),
          if (_events.isEmpty && !_loading)
            CatchSection.content(child: Text(copy.emptyEvents,
              style: CatchTextStyles.supporting(context))),
          if (_events.isNotEmpty)
            CatchSection.fieldRows(children: [
              for (final event in _events)
                CatchField.nav(
                  key: ValueKey('offer-target-${event.eventId}'),
                  copy: catchFieldCopy(context.l10n),
                  title: event.name?.trim().isNotEmpty == true
                      ? event.name! : copy.untitledEvent,
                  body: _eventTimeLabel(event),
                  onTap: _loading ? null : () => _choose(event),
                ),
            ]),
          if (_nextEventCursor != null)
            CatchSection.content(child: CatchButton(
              label: copy.loadMoreEvents,
              variant: CatchButtonVariant.secondary,
              onPressed: _loading ? null : _loadEvents,
            )),
          if (_event != null) ...[
            if (_missingContacts.isNotEmpty) ...[
              CatchSection.content(child: Text(copy.needsContact,
                style: CatchTextStyles.supporting(context))),
              CatchSection.fieldRows(children: [
                for (final detail in _missingContacts)
                  CatchField.nav(
                    key: ValueKey('offer-convert-${detail.response.responseId}'),
                    copy: catchFieldCopy(context.l10n),
                    title: detail.response.identity.primaryLabel ??
                        context.l10n.hostFormResponsesAnonymous,
                    body: copy.convertContact,
                    onTap: _loading ? null : () => _returnForConversion(
                      detail.response.responseId),
                  ),
              ]),
            ] else if (_configuration?.suggestedExpiresAt == null)
              CatchSection.content(child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(copy.configurePayment,
                    style: CatchTextStyles.supporting(context)),
                  CatchButton(label: copy.openSettings,
                    onPressed: _loading ? null : _openSettings),
                ],
              ))
            else if (_draft case final draft?)
              HostEventOfferReviewSection(
                controller: widget.offerController,
                draft: draft,
                eventTitle: _event!.name?.trim().isNotEmpty == true
                    ? _event!.name! : copy.untitledEvent,
                contactLabel: (id) => _details
                    .where((detail) => detail.contactId == id)
                    .firstOrNull?.response.identity.primaryLabel ??
                    context.l10n.hostFormResponsesAnonymous,
                eventStartsAt: _configuration!.startsAt,
                now: widget.now,
                commitRequestId: _commitRequestId!,
                copy: copy.review,
              ),
            if (_draft == null && _personalMode &&
                _missingContacts.isEmpty &&
                _configuration?.suggestedExpiresAt != null) ...[
              CatchSection.fieldRows(children: [
                for (final detail in _details)
                  CatchField.input(
                    key: ValueKey('offer-link-${detail.response.responseId}'),
                    copy: catchFieldCopy(context.l10n),
                    title: copy.personalPaymentLink(
                      detail.response.identity.primaryLabel ??
                      context.l10n.hostFormResponsesAnonymous),
                    contractExemption: 'Explicit organizer-owned HTTPS link '
                      'for this recipient; no provider charge is initiated.',
                    onChanged: (value) =>
                      _personalLinks[detail.contactId!] = value.trim(),
                  ),
              ]),
              CatchSection.content(child: CatchButton(
                label: copy.review.preview,
                onPressed: _loading ? null : _previewPersonal,
              )),
            ],
            CatchSection.content(child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (widget.offerController.view.status ==
                    HostOfferFlowStatus.committed)
                  Text(copy.issued, style: CatchTextStyles.supporting(context)),
                Text(copy.existing,
                  style: CatchTextStyles.sectionTitle(context)),
                if (_offers.isEmpty)
                  Text(copy.noOffers,
                    style: CatchTextStyles.supporting(context)),
                CatchButton(label: copy.refresh,
                  variant: CatchButtonVariant.secondary,
                  onPressed: _loading ? null : _refreshOffers),
                if (_nextOfferCursor != null)
                  CatchButton(label: context.l10n.hostFormResponsesLoadMore,
                    variant: CatchButtonVariant.secondary,
                    onPressed: _loading ? null : () => _fetchOffers(
                      append: true)),
              ],
            )),
            if (_offers.isNotEmpty)
              CatchSection.fieldRows(children: [
                for (final offer in _offers)
                  CatchField.nav(
                    key: ValueKey('offer-existing-${offer['offerId']}'),
                    copy: catchFieldCopy(context.l10n),
                    title: _offerLabel(offer),
                    body: '${_offerStatus(offer['effectiveStatus'])} · '
                        '${copy.openExisting}',
                    onTap: _loading ? null : () => _selectExisting(offer),
                  ),
              ]),
            if (_selectedOffer case final selected?) ...[
              if (selected.effectiveStatus == HostOfferStatus.offered)
                HostManualPaymentReviewSection(
                  key: ValueKey('offer-manual-${selected.offerId}-'
                    '${selected.generation}-${selected.revision}'),
                  controller: widget.offerController,
                  offer: selected,
                  copy: copy.review,
                  referenceRequestId: _referenceRequestId!,
                  reviewRequestId: _reviewRequestId!,
                  onUpdated: _manualUpdated,
                ),
              CatchSection.content(child: CatchButton(
                label: copy.handoffPrepare,
                variant: CatchButtonVariant.secondary,
                onPressed: _loading ? null : _prepareHandoff,
              )),
              if (_handoff?.kind == 'blocked')
                CatchSection.content(child: Text(copy.handoffBlocked,
                  style: CatchTextStyles.supporting(context))),
              if (_handoff?.kind == 'prepared')
                CatchSection.content(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(copy.handoffDisclosure,
                      style: CatchTextStyles.supporting(context)),
                    Text(_handoff!.editableText!,
                      style: CatchTextStyles.supporting(context)),
                    Wrap(children: [
                      CatchButton(label: copy.openWhatsapp,
                        onPressed: _loading || _handoff!.whatsappUrl == null
                            ? null : _openWhatsapp),
                      CatchButton(label: copy.copyMessage,
                        variant: CatchButtonVariant.secondary,
                        onPressed: _loading ? null : _copyHandoff),
                    ]),
                    if (_messageCopied)
                      Text(copy.messageCopied,
                        style: CatchTextStyles.supporting(context)),
                    if (_handoffOpenFailed)
                      Text(copy.handoffOpenFailed,
                        style: CatchTextStyles.supporting(context)),
                  ],
                )),
            ],
          ],
        ],
        if (_loading)
          CatchSection.content(child: Text(copy.review.previewing,
            style: CatchTextStyles.supporting(context))),
        if (_error != null || _selectionStale)
          CatchSection.content(child: Text(
            _selectionStale ? copy.selectionChanged : copy.loadFailed,
            style: CatchTextStyles.supporting(context))),
      ],
    );
  }
}
