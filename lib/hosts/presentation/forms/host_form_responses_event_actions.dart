part of 'host_form_responses_panel.dart';

extension _HostFormResponseEventActions on _HostFormResponsesPanelState {
  Future<void> _openEventForSelection(
    HostResponseQueryController queryController,
    String accountId,
  ) async {
    final intent = queryController.selectionIntent;
    if (intent == null ||
        !privateEventSetupAvailable() ||
        !_currentQueryAccount(queryController, accountId)) {
      return;
    }
    final organizerId = widget.organizerId;
    final formId = widget.formId;
    _updateFilters(() {
      _inlineReturnError = null;
      _returnedEventTarget = null;
      _returnedSelectionHash = null;
      _returnedSelectionIds = null;
    });
    final eventId = await context.pushNamed<String>(
      Routes.hostCreateEventScreen.name,
      pathParameters: {'clubId': organizerId},
      extra: const HostCreateEventRouteArguments(returnToResponsesOnSave: true),
    );
    if (eventId == null || !_currentQueryAccount(queryController, accountId)) {
      return;
    }
    if (widget.organizerId != organizerId ||
        widget.formId != formId ||
        !_HostFormResponsesPanelState._sameSelection(
          queryController.selectionIntent,
          intent,
        ) ||
        !await queryController.revalidateSelection(
          ids: intent.ids,
          resultHash: intent.resultHash,
        )) {
      if (_currentQueryAccount(queryController, accountId)) {
        _updateFilters(
          () =>
              _inlineReturnError = context.l10n.hostEventOfferSelectionChanged,
        );
      }
      return;
    }
    try {
      final summary = await PrivateEventSetupRepository(
        ref.read(firebaseFunctionsProvider),
      ).get(organizerId: organizerId, eventId: eventId);
      if (!_currentQueryAccount(queryController, accountId) ||
          widget.organizerId != organizerId ||
          widget.formId != formId) {
        return;
      }
      if (summary.organizerId != organizerId ||
          summary.eventId != eventId ||
          summary.status != 'active' ||
          !_HostFormResponsesPanelState._sameSelection(
            queryController.selectionIntent,
            intent,
          ) ||
          !await queryController.revalidateSelection(
            ids: intent.ids,
            resultHash: intent.resultHash,
          )) {
        if (_currentQueryAccount(queryController, accountId)) {
          _updateFilters(
            () => _inlineReturnError =
                context.l10n.hostEventOfferSelectionChanged,
          );
        }
        return;
      }
      if (!_currentQueryAccount(queryController, accountId) ||
          widget.organizerId != organizerId ||
          widget.formId != formId ||
          !_HostFormResponsesPanelState._sameSelection(
            queryController.selectionIntent,
            intent,
          )) {
        return;
      }
      _updateFilters(() {
        _returnedEventTarget = HostOfferEventTarget(
          eventId: summary.eventId,
          name: summary.name,
          startTime: DateTime.fromMillisecondsSinceEpoch(
            summary.startTimeMillis,
          ),
          timezone: summary.timezone,
          publicationState: 'private',
          setupRevision: summary.setupRevision,
        );
        _returnedSelectionHash = intent.resultHash;
        _returnedSelectionIds = List.unmodifiable(intent.ids);
        _inlineReturnError = null;
      });
    } on Object catch (error) {
      if (_currentQueryAccount(queryController, accountId)) {
        _updateFilters(
          () => _inlineReturnError = appErrorMessage(
            error,
            l10n: context.l10n,
            context: AppErrorContext.event,
          ),
        );
      }
    }
  }

  bool _currentQueryAccount(
    HostResponseQueryController queryController,
    String accountId,
  ) =>
      mounted &&
      _queryController == queryController &&
      _queryAccountId == accountId &&
      ref.read(uidProvider).asData?.value == accountId &&
      ref.read(firebaseAuthProvider).currentUser?.uid == accountId;

  Future<void> _openEventSettings(String eventId, String accountId) async {
    if (_queryAccountId != accountId ||
        ref.read(uidProvider).asData?.value != accountId ||
        ref.read(firebaseAuthProvider).currentUser?.uid != accountId) {
      return;
    }
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (routeContext) => HostEventOfferPreferencesScreen(
          key: ValueKey(
            'offer-settings-${widget.organizerId}-$eventId-$accountId',
          ),
          organizerId: widget.organizerId,
          eventId: eventId,
          onBack: () => Navigator.of(routeContext).pop(),
        ),
      ),
    );
  }
  HostFormAdmissionController _admissionController(
    HostEventOffer offer, String accountId, String responseId,
  ) {
    final gateway = CallableHostFormAdmissionGateway(
      ref.read(firebaseFunctionsProvider));
    String? currentAccount() => ref.read(firebaseAuthProvider).currentUser?.uid;
    return HostFormAdmissionController(accountId: accountId,
      scope: HostFormAdmissionScope.fromOffer(offer, responseId: responseId),
      gateway: gateway,
      currentAccountId: currentAccount,
      outbox: JournalHostFormAdmissionOutbox(gateway: gateway,
        storage: ref.read(commandJournalStorageProvider),
        currentAccountId: currentAccount));
  }
}
