part of 'host_event_offer_workspace_controller.dart';

/// Existing-offer loading, payment refresh, and external handoff actions.
extension HostEventOfferWorkspaceExistingOfferActions
    on HostEventOfferWorkspaceController {
  void _prepareDraft(
    List<HostFormResponseDetail> details,
    HostOfferEventConfiguration configuration,
  ) {
    final expiry = configuration.suggestedExpiresAt;
    if (expiry == null) {
      return;
    }
    final draft = HostOfferWorkspacePolicy.draft(
      organizerId: _organizerId,
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
    if (!_active) return;
    final accountId = _accountId;
    final event = _event;
    final previous = _configuration;
    final generation = _generation;
    if (accountId == null ||
        event == null ||
        previous == null ||
        _isLoading ||
        _selectionStale ||
        _hasUnresolvedCommand ||
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
            isResponseReviewed: _isResponseReviewed,
            isCurrent: () => _current(generation, accountId),
          );
        })(),
        (() async {
          current = await _targets.configuration(
            organizerId: _organizerId,
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
        await _offerController.preview(
          draft: draft,
          now: _now(),
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

  Future<void> refreshOffers() => _fetchOffers(append: false);

  Future<void> _fetchOffers({required bool append}) async {
    if (!_active) return;
    final event = _event;
    final accountId = _accountId;
    final generation = _generation;
    if (event == null || accountId == null) {
      return;
    }
    try {
      final response = await _listOffers(
        organizerId: _organizerId,
        eventId: event.eventId,
        afterOfferId: append ? _nextOfferCursor : null,
      );
      if (!_current(generation, accountId) ||
          _event?.eventId != event.eventId) {
        return;
      }
      final page = HostOfferWorkspacePolicy.offerPage(
        response: response,
        eventId: event.eventId,
        previousCursor: _nextOfferCursor,
        append: append,
        details: _details,
        offers: _offers,
      );
      _update(() {
        _offers = page.items;
        _nextOfferCursor = page.cursor;
      });
    } on Object catch (error) {
      if (_current(generation, accountId)) _update(() => _error = error);
    }
  }

  Future<void> selectExisting(Map<String, Object?> item) async {
    if (!_active) return;
    final event = _event;
    final accountId = _accountId;
    final generation = _generation;
    final contactId = item['contactId'];
    final offerId = item['offerId'];
    if (event == null ||
        accountId == null ||
        _loading ||
        contactId is! String ||
        offerId is! String) {
      return;
    }
    _update(() {
      _loading = true;
      _stage = HostOfferWorkspaceStage.loadingOffer;
      _error = null;
    });
    try {
      final offer = await _getOffer(
        organizerId: _organizerId,
        eventId: event.eventId,
        contactId: contactId,
      );
      if (!_current(generation, accountId) ||
          _event?.eventId != event.eventId) {
        return;
      }
      if (offer.organizerId != _organizerId ||
          offer.eventId != event.eventId ||
          offer.contactId != contactId ||
          offer.offerId != offerId) {
        throw const FormatException('Offer detail does not match selection.');
      }
      _update(() {
        _selectedOffer = offer;
        _handoff = null;
        _referenceRequestId = HostOfferWorkspacePolicy.newRequestId();
        _reviewRequestId = HostOfferWorkspacePolicy.newRequestId();
        _messageCopied = false;
        _handoffOpenFailed = false;
      });
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

  void manualUpdated(HostEventOffer updated) {
    if (!_active) return;
    final previous = _selectedOffer;
    if (previous == null ||
        previous.offerId != updated.offerId ||
        previous.organizerId != updated.organizerId ||
        previous.eventId != updated.eventId ||
        previous.contactId != updated.contactId) {
      return;
    }
    _update(() {
      _selectedOffer = updated;
      _handoff = null;
      _referenceRequestId = HostOfferWorkspacePolicy.newRequestId();
      _reviewRequestId = HostOfferWorkspacePolicy.newRequestId();
      _messageCopied = false;
    });
    refreshOffers();
  }

  Future<void> prepareSelectedHandoff() async {
    if (!_active) return;
    final selected = _selectedOffer;
    final accountId = _accountId;
    final generation = _generation;
    if (selected == null || accountId == null || _loading) {
      return;
    }
    _update(() {
      _loading = true;
      _stage = HostOfferWorkspaceStage.preparingMessage;
      _error = null;
      _handoff = null;
    });
    try {
      final prepared = await HostOfferWorkspacePolicy.verifiedHandoff(
        selected: selected,
        getOffer: _getOffer,
        prepareHandoff: _prepareHandoff,
        isCurrent: () =>
            _current(generation, accountId) && _sameSelectedOffer(selected),
      );
      if (prepared == null) return;
      _update(() {
        _selectedOffer = prepared.offer;
        _handoff = prepared.handoff;
        _messageCopied = false;
        _handoffOpenFailed = false;
      });
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

  bool _sameSelectedOffer(HostEventOffer offer) =>
      HostOfferWorkspacePolicy.sameOfferRevision(_selectedOffer, offer);

  Future<void> copyPreparedHandoff() async {
    if (!_active) return;
    final handoff = _handoff;
    final accountId = _accountId;
    final generation = _generation;
    if (handoff?.kind != 'prepared' ||
        handoff?.copyText == null ||
        accountId == null ||
        _loading) {
      return;
    }
    try {
      await _copyMessage(handoff!.copyText!);
      if (_current(generation, accountId) && identical(_handoff, handoff)) {
        _update(() => _messageCopied = true);
      }
    } on Object catch (error) {
      if (_current(generation, accountId)) _update(() => _error = error);
    }
  }

  Future<void> openPreparedWhatsapp() async {
    if (!_active) return;
    final handoff = _handoff;
    final accountId = _accountId;
    final generation = _generation;
    if (handoff?.kind != 'prepared' ||
        handoff?.whatsappUrl == null ||
        accountId == null ||
        _loading) {
      return;
    }
    final uri = handoff!.whatsappUrl!;
    if (uri.scheme != 'https' ||
        uri.host != 'wa.me' ||
        uri.userInfo.isNotEmpty ||
        !RegExp(r'^/[0-9]{8,15}$').hasMatch(uri.path)) {
      _update(() => _handoffOpenFailed = true);
      return;
    }
    try {
      final opened = await _openHandoff(uri);
      if (_current(generation, accountId) && identical(_handoff, handoff)) {
        _update(() => _handoffOpenFailed = !opened);
      }
    } on Object {
      if (_current(generation, accountId)) {
        _update(() => _handoffOpenFailed = true);
      }
    }
  }

  void closeExisting() {
    if (!_active) return;
    if (_isLoading) return;
    _update(() {
      _selectedOffer = null;
      _handoff = null;
    });
  }

  Future<void> fetchMoreOffers() => _fetchOffers(append: true);
}
