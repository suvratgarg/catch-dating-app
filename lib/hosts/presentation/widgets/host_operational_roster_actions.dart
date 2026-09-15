part of 'host_operational_roster_panel.dart';

extension _HostOperationalRosterActions on _HostOperationalRosterPanelState {
  bool get _showsProviderSource {
    final provider = widget.bookingProvider;
    return widget._view == _HostOperationalRosterView.guestIntake &&
        provider != null &&
        provider != ExternalBookingProvider.catchPlatform;
  }

  Future<void> _loadProviderSetup({bool force = false}) async {
    if (!force && _providerSetup != null) return;
    _setLocalState(() => _providerSetup = const AsyncLoading());
    try {
      final setup = await ref
          .read(hostOperationalRosterControllerProvider)
          .getProviderSetup(
            organizerId: widget.organizerId,
            eventId: widget.eventId,
          );
      if (mounted) _setLocalState(() => _providerSetup = AsyncData(setup));
    } catch (error, stackTrace) {
      app_ops.logAppError(
        error,
        stackTrace: stackTrace,
        context: const app_ops.AppErrorContext(
          operation: app_ops.AppOperation.ui,
          action: 'load organizer booking provider setup',
          resource: 'host_provider_setup',
        ),
        logError: ref.read(errorLoggerProvider),
      );
      if (mounted) {
        _setLocalState(() => _providerSetup = AsyncError(error, stackTrace));
      }
    }
  }

  Future<void> _connectLuma() async {
    final input = await showCatchBottomSheet<HostLumaConnectionInput>(
      context: context,
      builder: (context) => HostLumaConnectionSheet(
        organizerId: widget.organizerId,
        eventId: widget.eventId,
        controller: ref.read(hostOperationalRosterControllerProvider),
      ),
    );
    if (input == null || !mounted) return;
    _setLocalState(() {
      _providerMutationPending = true;
      _mutationError = null;
    });
    try {
      final setup = await ref
          .read(hostOperationalRosterControllerProvider)
          .connectLuma(
            organizerId: widget.organizerId,
            eventId: widget.eventId,
            externalEventId: input.externalEventId,
            apiKey: input.apiKey,
          );
      if (!mounted) return;
      _setLocalState(() => _providerSetup = AsyncData(setup));
      showCatchSnackBar(
        context,
        context.l10n.hostsOperationalRosterProviderConnected,
      );
    } catch (error) {
      if (mounted) _setLocalState(() => _mutationError = error);
    } finally {
      if (mounted) _setLocalState(() => _providerMutationPending = false);
    }
  }

  Future<void> _syncProvider() async {
    if (_providerMutationPending) return;
    final operationId = _providerSyncOperationId ??=
        _newProviderSyncOperationId();
    _setLocalState(() {
      _providerMutationPending = true;
      _mutationError = null;
    });
    try {
      final result = await ref
          .read(hostOperationalRosterControllerProvider)
          .syncProvider(
            organizerId: widget.organizerId,
            eventId: widget.eventId,
            clientOperationId: operationId,
          );
      _providerSyncOperationId = null;
      ref.invalidate(watchEventAttendeesProvider(widget.eventId));
      ref.invalidate(hostEventRosterInsightsProvider(widget.eventId));
      await _loadProviderSetup(force: true);
      if (!mounted) return;
      showCatchSnackBar(
        context,
        context.l10n.hostsOperationalRosterProviderSyncSuccess(
          created: result.createdCount,
          updated: result.updatedCount,
          skipped: result.skippedCount,
        ),
      );
    } catch (error) {
      if (mounted) _setLocalState(() => _mutationError = error);
    } finally {
      if (mounted) _setLocalState(() => _providerMutationPending = false);
    }
  }

  Future<void> _disconnectProvider() async {
    final connection = _providerSetup?.asData?.value.mappedConnection;
    if (connection == null || _providerMutationPending) return;
    final confirmed = await showCatchConfirmDialog(
      copy: catchDialogCopy(context.l10n),
      context: context,
      title: context.l10n.hostsOperationalRosterProviderDisconnectTitle,
      message: context.l10n.hostsOperationalRosterProviderDisconnectBody,
      confirmLabel: context.l10n.hostsOperationalRosterProviderDisconnect,
      danger: true,
    );
    if (confirmed != true || !mounted) return;
    _setLocalState(() {
      _providerMutationPending = true;
      _mutationError = null;
    });
    try {
      final next = await ref
          .read(hostOperationalRosterControllerProvider)
          .disconnectProvider(
            organizerId: widget.organizerId,
            eventId: widget.eventId,
            connectionId: connection.connectionId,
          );
      if (mounted) _setLocalState(() => _providerSetup = AsyncData(next));
    } catch (error) {
      if (mounted) _setLocalState(() => _mutationError = error);
    } finally {
      if (mounted) _setLocalState(() => _providerMutationPending = false);
    }
  }

  Future<void> _pickRoster() async {
    _setLocalState(() {
      _importing = true;
      _mutationError = null;
    });
    try {
      final table = await ref
          .read(hostOperationalRosterControllerProvider)
          .pickRosterFile(providerHint: widget.bookingProvider);
      if (table == null || !mounted) return;
      final plan = await showHostRosterMapping(
        context,
        table,
        suggestedRevenueAmountMinor: widget.suggestedRevenueAmountMinor,
        defaultRevenueCurrency: widget.revenueCurrency,
      );
      if (plan == null || !mounted) return;
      await _importRows(
        fileName: table.fileName,
        format: table.format,
        rows: plan.rows,
      );
    } on HostRosterImportException catch (error) {
      if (mounted) {
        showCatchSnackBar(
          context,
          hostRosterImportIssueCopy(context, error.issue),
        );
      }
    } catch (error) {
      if (mounted) showCatchErrorSnackBar(context, error);
    } finally {
      if (mounted) _setLocalState(() => _importing = false);
    }
  }

  Future<void> _showManualGuest() async {
    final row = await showCatchBottomSheet<EventAttendeeImportRow>(
      context: context,
      builder: (context) => const HostManualAttendeeSheet(),
    );
    if (row == null || !mounted) return;
    _setLocalState(() {
      _importing = true;
      _mutationError = null;
    });
    try {
      await _importRows(
        fileName: 'manual-entry',
        format: EventAttendeeImportFormat.manual,
        rows: [row],
      );
    } catch (error) {
      if (mounted) showCatchErrorSnackBar(context, error);
    } finally {
      if (mounted) _setLocalState(() => _importing = false);
    }
  }

  Future<void> _showRosterHandoff() async {
    _setLocalState(() {
      _creatingHandoff = true;
      _mutationError = null;
    });
    try {
      final instructions = await ref
          .read(hostOperationalRosterControllerProvider)
          .createRosterHandoff(eventId: widget.eventId);
      if (!mounted) return;
      await showCatchBottomSheet<void>(
        context: context,
        builder: (context) => HostRosterHandoffSheet(
          instructions: instructions,
          onCopy: (value) =>
              ref.read(clipboardControllerProvider).copyText(value),
        ),
      );
    } catch (error) {
      if (mounted) showCatchErrorSnackBar(context, error);
    } finally {
      if (mounted) _setLocalState(() => _creatingHandoff = false);
    }
  }

  Future<void> _reviewClaim(
    EventRuntimeClaimRequest claim,
    EventRuntimeClaimDecision decision, {
    String? attendeeId,
  }) async {
    if (_pendingClaimUid != null) return;
    _setLocalState(() {
      _pendingClaimUid = claim.uid;
      _mutationError = null;
    });
    try {
      await ref
          .read(hostOperationalRosterControllerProvider)
          .reviewRuntimeClaim(
            eventId: widget.eventId,
            uid: claim.uid,
            decision: decision,
            attendeeId: attendeeId,
          );
      ref.invalidate(watchEventAttendeesProvider(widget.eventId));
      ref.invalidate(hostEventRosterInsightsProvider(widget.eventId));
      if (!mounted) return;
      showCatchSnackBar(
        context,
        decision == EventRuntimeClaimDecision.approve
            ? context.l10n.hostsOperationalRosterClaimApproved
            : context.l10n.hostsOperationalRosterClaimRejected,
      );
    } catch (error) {
      if (mounted) _setLocalState(() => _mutationError = error);
    } finally {
      if (mounted) _setLocalState(() => _pendingClaimUid = null);
    }
  }

  Future<void> _importRows({
    required String fileName,
    required EventAttendeeImportFormat format,
    required List<EventAttendeeImportRow> rows,
  }) async {
    final importKey = format == EventAttendeeImportFormat.manual
        ? _newImportKey()
        : hostRosterImportKey(format: format, rows: rows);
    try {
      final result = await ref
          .read(hostOperationalRosterControllerProvider)
          .importAttendees(
            eventId: widget.eventId,
            importKey: importKey,
            fileName: fileName,
            format: format,
            rows: rows,
          );
      ref.invalidate(watchEventAttendeesProvider(widget.eventId));
      ref.invalidate(hostEventRosterInsightsProvider(widget.eventId));
      if (!mounted) return;
      if (result.errors.isEmpty) {
        showCatchSnackBar(
          context,
          context.l10n.hostsOperationalRosterImportSuccess(
            created: result.createdCount,
            updated: result.updatedCount,
            skipped: result.skippedCount,
          ),
        );
      } else {
        await showCatchBottomSheet<void>(
          context: context,
          builder: (context) => CatchSheet(
            title: context.l10n.hostsOperationalRosterImportPartialTitle,
            subtitle: context.l10n.hostsOperationalRosterImportPartialBody(
              created: result.createdCount,
              updated: result.updatedCount,
              count: result.errors.length,
            ),
            footer: CatchButton(
              label: context.l10n.hostsOperationalRosterImportResultDone,
              fullWidth: true,
              onPressed: () => Navigator.of(context).pop(),
            ),
            child: SingleChildScrollView(
              child: CatchFieldLanes.divided(
                children: [
                  for (final error in result.errors)
                    CatchField.read(
                      copy: catchFieldCopy(context.l10n),
                      title: context.l10n.hostsOperationalRosterImportRowError(
                        row: error.rowId,
                      ),
                      body: error.message,
                      bodyMaxLines: 5,
                    ),
                ],
              ),
            ),
          ),
        );
      }
    } catch (error) {
      if (mounted) _setLocalState(() => _mutationError = error);
      rethrow;
    }
  }

  Future<void> _toggleAttendance(EventAttendee attendee) async {
    if (_pendingAttendanceId != null) return;
    _setLocalState(() {
      _pendingAttendanceId = attendee.id;
      _mutationError = null;
    });
    try {
      final outbox = await ref
          .read(hostOperationalRosterControllerProvider)
          .setAttendance(
            eventId: widget.eventId,
            attendee: attendee,
            clientOperationId: _newAttendanceOperationId(attendee.id),
          );
      if (mounted) _setLocalState(() => _attendanceOutbox = outbox);
      ref.invalidate(watchEventAttendeesProvider(widget.eventId));
      ref.invalidate(hostEventRosterInsightsProvider(widget.eventId));
    } catch (error) {
      if (mounted) _setLocalState(() => _mutationError = error);
    } finally {
      if (mounted) _setLocalState(() => _pendingAttendanceId = null);
    }
  }

  Future<void> _loadAttendanceOutbox() async {
    try {
      final outbox = await ref
          .read(hostOperationalRosterControllerProvider)
          .loadAttendanceOutbox(widget.eventId);
      if (mounted) _setLocalState(() => _attendanceOutbox = outbox);
    } catch (error) {
      if (mounted) _setLocalState(() => _mutationError = error);
    }
  }

  Future<void> _flushAttendanceOutbox() async {
    try {
      final outbox = await ref
          .read(hostOperationalRosterControllerProvider)
          .flushAttendanceOutbox(widget.eventId);
      if (!mounted) return;
      _setLocalState(() => _attendanceOutbox = outbox);
      ref.invalidate(watchEventAttendeesProvider(widget.eventId));
      ref.invalidate(hostEventRosterInsightsProvider(widget.eventId));
    } catch (error) {
      if (mounted) _setLocalState(() => _mutationError = error);
    }
  }

  Future<void> _clearAttendanceConflicts() async {
    try {
      final outbox = await ref
          .read(hostOperationalRosterControllerProvider)
          .clearAttendanceConflicts(widget.eventId);
      if (mounted) _setLocalState(() => _attendanceOutbox = outbox);
    } catch (error) {
      if (mounted) _setLocalState(() => _mutationError = error);
    }
  }
}
