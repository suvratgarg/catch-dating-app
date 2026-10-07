part of 'host_event_offer_workspace_controller.dart';

/// Existing-offer loading, payment refresh, and external handoff actions.
extension HostEventOfferWorkspaceExistingOfferActions
    on HostEventOfferWorkspaceController {
  Future<void> refreshOffers() => _fetchOffers(append: false);

  Future<void> _fetchOffers({required bool append}) async {
    final event = _event;
    final accountId = this.accountId;
    final generation = _generation;
    if (event == null || accountId == null) {
      return;
    }
    try {
      final response = await listOffers(
        organizerId: organizerId,
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
    final event = _event;
    final accountId = this.accountId;
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
      final offer = await getOffer(
        organizerId: organizerId,
        eventId: event.eventId,
        contactId: contactId,
      );
      if (!_current(generation, accountId) ||
          _event?.eventId != event.eventId) {
        return;
      }
      if (offer.organizerId != organizerId ||
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
    final previous = _selectedOffer;
    if (_disposed ||
        previous == null ||
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
    final selected = _selectedOffer;
    final accountId = this.accountId;
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
        getOffer: getOffer,
        prepareHandoff: prepareHandoff,
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
    final handoff = _handoff;
    final accountId = this.accountId;
    final generation = _generation;
    if (handoff?.kind != 'prepared' ||
        handoff?.copyText == null ||
        accountId == null ||
        _loading) {
      return;
    }
    try {
      await copyMessage(handoff!.copyText!);
      if (_current(generation, accountId) && identical(_handoff, handoff)) {
        _update(() => _messageCopied = true);
      }
    } on Object catch (error) {
      if (_current(generation, accountId)) _update(() => _error = error);
    }
  }

  Future<void> openPreparedWhatsapp() async {
    final handoff = _handoff;
    final accountId = this.accountId;
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

  void closeExisting() {
    if (loading) return;
    _update(() {
      _selectedOffer = null;
      _handoff = null;
    });
  }

  Future<void> fetchMoreOffers() => _fetchOffers(append: true);
}
