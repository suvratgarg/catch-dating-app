part of '../host_operations_screen.dart';

enum _HostCampaignMessageClass {
  eventFollowUp('eventFollowUp'),
  organizerUpdate('organizerUpdate'),
  organizerPromotion('organizerPromotion');

  const _HostCampaignMessageClass(this.wireValue);

  final String wireValue;
}

enum _HostInviteDestination {
  catchEvent('catchEvent'),
  eventRuntime('eventRuntime'),
  externalBooking('externalBooking');

  const _HostInviteDestination(this.wireValue);

  final String wireValue;
}

class HostCustomerMessagingPane extends ConsumerStatefulWidget {
  const HostCustomerMessagingPane({
    super.key,
    required this.club,
    this.onBusyChanged,
  });

  final Club club;
  final ValueChanged<bool>? onBusyChanged;

  @override
  ConsumerState<HostCustomerMessagingPane> createState() =>
      _HostCustomerMessagingPaneState();
}

class _HostCustomerMessagingPaneState
    extends ConsumerState<HostCustomerMessagingPane> {
  final _campaignNameController = TextEditingController();
  final _testPhoneController = TextEditingController();
  final Map<String, TextEditingController> _variableControllers = {};
  final Set<HostAudienceSegment> _campaignSegments = {
    HostAudienceSegment.whatsappReachable,
  };
  _HostCampaignMessageClass _messageClass =
      _HostCampaignMessageClass.organizerPromotion;
  HostWhatsappTemplate? _selectedTemplate;
  Event? _selectedEvent;
  _HostInviteDestination? _inviteDestination;
  HostCampaign? _campaign;
  bool _busy = false;

  @override
  void didUpdateWidget(covariant HostCustomerMessagingPane oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.club.id != widget.club.id) {
      _campaign = null;
      _selectedTemplate = null;
      _disposeVariableControllers();
    }
  }

  @override
  void dispose() {
    _campaignNameController.dispose();
    _testPhoneController.dispose();
    _disposeVariableControllers();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final messaging = ref.watch(hostMessagingSetupProvider(widget.club.id));
    return CatchSectionList(
      emptyStateOmitted: true,
      children: [
        _buildWhatsappSetup(context, messaging),
        _buildCampaignComposer(context, messaging),
      ],
    );
  }

  CatchSection _buildWhatsappSetup(
    BuildContext context,
    AsyncValue<HostMessagingSetup> messaging,
  ) => CatchSection.divided(
    title: context.l10n.hostsHostAudienceWhatsappSender,
    child: CatchAsyncValueView<HostMessagingSetup>(
      value: messaging,
      onRetry: () => ref.invalidate(hostMessagingSetupProvider(widget.club.id)),
      initialLoadTimeout: null,
      loadingBuilder: (_) => const CatchSkeletonRows(count: 2),
      errorBuilder: (_, error, _) => CatchErrorState.fromError(
        error,
        context: AppErrorContext.club,
        mode: CatchErrorStateMode.compact,
        onRetry: () =>
            ref.invalidate(hostMessagingSetupProvider(widget.club.id)),
      ),
      builder: (context, setup) {
        final connection = setup.connection;
        return CatchFieldLanes.custom(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.hostsHostAudienceWhatsappOwnedSender,
                style: CatchTextStyles.supporting(
                  context,
                  color: CatchTokens.of(context).ink2,
                ),
              ),
              gapH12,
              if (!setup.providerConfigured)
                CatchNotice(
                  notice: CatchNoticeData(
                    id: 'host.audience.whatsapp.provider-unavailable',
                    title: context.l10n.hostsHostAudienceProviderUnavailable,
                    message:
                        context.l10n.hostsHostAudienceProviderUnavailableBody,
                    tone: CatchNoticeTone.warning,
                  ),
                )
              else if (connection == null)
                CatchButton(
                  label: context.l10n.hostsHostAudienceConnectWhatsapp,
                  onPressed: _busy ? null : () => _connectWhatsapp(setup),
                  isLoading: _busy,
                )
              else ...[
                CatchField.read(
                  title:
                      connection.verifiedName ??
                      context.l10n.hostsHostAudienceWhatsappSender,
                  body: connection.displayPhoneNumber,
                  valueText: _connectionStatusLabel(context, connection),
                ),
                CatchField.read(
                  title: context.l10n.hostsHostAudienceTemplates,
                  body: context.l10n.hostsHostAudienceApprovedTemplates(
                    count: setup.approvedTemplates.length,
                  ),
                  valueText: connection.templateSyncStatus,
                ),
                Wrap(
                  spacing: CatchSpacing.s2,
                  runSpacing: CatchSpacing.s2,
                  children: [
                    CatchButton(
                      label: context.l10n.hostsHostAudienceSyncTemplates,
                      variant: CatchButtonVariant.secondary,
                      size: CatchButtonSize.sm,
                      onPressed: _busy
                          ? null
                          : () => _syncTemplates(connection.connectionId),
                      isLoading: _busy,
                    ),
                    CatchButton(
                      label: context.l10n.hostsHostAudienceDisconnect,
                      variant: CatchButtonVariant.ghost,
                      size: CatchButtonSize.sm,
                      onPressed: _busy
                          ? null
                          : () => _disconnectWhatsapp(connection.connectionId),
                    ),
                  ],
                ),
                if (!connection.isActive &&
                    setup.approvedTemplates.isNotEmpty) ...[
                  gapH16,
                  CatchField.input(
                    title: context.l10n.hostsHostAudienceTestPhone,
                    contract: CatchContractConstraints
                        .sendOrganizerWhatsappTestCallablePayloadToE164,
                    controller: _testPhoneController,
                    keyboardType: TextInputType.phone,
                    placeholder: '+919876543210',
                    helperText: context.l10n.hostsHostAudienceTestPhoneHelp,
                  ),
                  gapH8,
                  CatchButton(
                    label: context.l10n.hostsHostAudienceSendTest,
                    onPressed: _busy
                        ? null
                        : () => _sendTest(setup, setup.approvedTemplates.first),
                    isLoading: _busy,
                  ),
                ],
              ],
            ],
          ),
        );
      },
    ),
  );

  CatchSection _buildCampaignComposer(
    BuildContext context,
    AsyncValue<HostMessagingSetup> messaging,
  ) => CatchSection.divided(
    title: context.l10n.hostsHostAudienceCampaign,
    child: CatchAsyncValueView<HostMessagingSetup>(
      value: messaging,
      onRetry: () => ref.invalidate(hostMessagingSetupProvider(widget.club.id)),
      initialLoadTimeout: null,
      loadingBuilder: (_) => const CatchSkeletonRows(),
      errorBuilder: (_, error, _) => CatchErrorState.fromError(
        error,
        context: AppErrorContext.club,
        mode: CatchErrorStateMode.compact,
        onRetry: () =>
            ref.invalidate(hostMessagingSetupProvider(widget.club.id)),
      ),
      builder: (context, setup) {
        final connection = setup.connection;
        final approved = setup.approvedTemplates;
        final events =
            ref
                .watch(watchEventsForClubProvider(widget.club.id))
                .asData
                ?.value
                .where((event) => !event.isCancelled)
                .toList(growable: false) ??
            const <Event>[];
        if (connection == null || !connection.isActive) {
          return Text(
            context.l10n.hostsHostAudienceCampaignNeedsActiveSender,
            style: CatchTextStyles.supporting(
              context,
              color: CatchTokens.of(context).ink2,
            ),
          );
        }
        if (approved.isEmpty) {
          return Text(
            context.l10n.hostsHostAudienceCampaignNeedsTemplate,
            style: CatchTextStyles.supporting(
              context,
              color: CatchTokens.of(context).ink2,
            ),
          );
        }
        final template = _selectedTemplate ?? approved.first;
        return CatchFieldLanes.custom(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CatchField.input(
                title: context.l10n.hostsHostAudienceCampaignName,
                contract: CatchContractConstraints
                    .upsertOrganizerCampaignCallablePayloadName,
                controller: _campaignNameController,
                placeholder: context.l10n.hostsHostAudienceCampaignNameExample,
                enabled: _campaign == null,
              ),
              gapH12,
              CatchField.select<_HostCampaignMessageClass>(
                title: context.l10n.hostsHostAudienceMessageType,
                contract: CatchContractConstraints
                    .upsertOrganizerCampaignCallablePayloadMessageClass,
                contractValue: (value) => value.wireValue,
                values: _HostCampaignMessageClass.values,
                itemLabel: (value) => _messageClassLabel(context, value),
                value: _messageClass,
                enabled: _campaign == null,
                onChanged: (value) {
                  if (value != null) setState(() => _messageClass = value);
                },
              ),
              gapH12,
              Text(
                context.l10n.hostsHostAudienceRecipients,
                style: CatchTextStyles.fieldRowTitle(context),
              ),
              gapH8,
              Wrap(
                spacing: CatchSpacing.s2,
                runSpacing: CatchSpacing.s2,
                children: [
                  for (final segment in HostAudienceSegment.values)
                    CatchChip.selectable(
                      label: _segmentLabel(context, segment),
                      selected: _campaignSegments.contains(segment),
                      enabled: _campaign == null,
                      contract: CatchContractConstraints
                          .upsertOrganizerCampaignCallablePayloadSegmentIds,
                      contractValue: segment.wireValue,
                      onChanged: (selected) => setState(() {
                        if (selected && _campaignSegments.length < 5) {
                          _campaignSegments.add(segment);
                        } else if (!selected && _campaignSegments.length > 1) {
                          _campaignSegments.remove(segment);
                        }
                      }),
                    ),
                ],
              ),
              gapH12,
              CatchField.select<HostWhatsappTemplate>(
                title: context.l10n.hostsHostAudienceTemplate,
                contract: CatchContractConstraints
                    .upsertOrganizerCampaignCallablePayloadTemplateId,
                contractValue: (value) => value.templateId,
                values: approved,
                itemLabel: (value) => '${value.name} · ${value.language}',
                value: template,
                enabled: _campaign == null,
                onChanged: (value) {
                  if (value == null) return;
                  setState(() {
                    _selectedTemplate = value;
                    _syncVariableControllers(value);
                  });
                },
              ),
              if (_templateUsesInvite(template)) ...[
                gapH12,
                CatchField.select<Event>(
                  title: context.l10n.hostsHostAudienceLinkedEvent,
                  contract: CatchContractConstraints
                      .upsertOrganizerCampaignCallablePayloadEventId,
                  contractValue: (event) => event.id,
                  values: events,
                  itemLabel: (event) =>
                      '${event.title} · ${AppTimeFormatters.shortDate(event.startTime)}',
                  value: _eventIn(events, _selectedEvent),
                  hintText: context.l10n.hostsHostAudienceChooseEvent,
                  helperText: context.l10n.hostsHostAudienceLinkedEventHelp,
                  enabled: _campaign == null,
                  onChanged: (value) => setState(() {
                    _selectedEvent = value;
                    _inviteDestination = value == null
                        ? null
                        : _destinationsFor(value).first;
                  }),
                ),
                if (_selectedEvent case final event?) ...[
                  gapH12,
                  CatchField.select<_HostInviteDestination>(
                    title: context.l10n.hostsHostAudienceInviteDestination,
                    contract: CatchContractConstraints
                        .upsertOrganizerCampaignCallablePayloadInviteDestinationKind,
                    contractValue: (value) => value.wireValue,
                    values: _destinationsFor(event),
                    itemLabel: (value) =>
                        _inviteDestinationLabel(context, value),
                    value: _inviteDestination ?? _destinationsFor(event).first,
                    helperText: event.isExternalCompanion
                        ? context
                              .l10n
                              .hostsHostAudienceExternalAttributionExplanation
                        : context
                              .l10n
                              .hostsHostAudienceCatchAttributionExplanation,
                    enabled: _campaign == null,
                    onChanged: (value) =>
                        setState(() => _inviteDestination = value),
                  ),
                ],
              ],
              for (final variable in template.variableNames)
                if (!_isInviteVariable(variable)) ...[
                  gapH12,
                  CatchField.input(
                    title: variable,
                    contractExemption:
                        'Template-variable keys are provider-defined; the generated contract constrains the map, not each dynamic value field.',
                    controller: _controllerForVariable(variable),
                    maxLength: 240,
                    enabled: _campaign == null,
                  ),
                ],
              gapH16,
              if (_campaign == null)
                CatchButton(
                  label: context.l10n.hostsHostAudiencePreviewCampaign,
                  onPressed: _busy
                      ? null
                      : () => _saveAndPreview(connection, template),
                  isLoading: _busy,
                )
              else
                _HostCampaignReview(
                  campaign: _campaign!,
                  busy: _busy,
                  onApprove: _campaign!.canApprove ? _approveCampaign : null,
                  onSend: _campaign!.canDispatch ? _dispatchCampaign : null,
                  onCancel:
                      _campaign!.status == 'cancelled' ||
                          _campaign!.status == 'completed' ||
                          _campaign!.status == 'partiallyFailed'
                      ? null
                      : _cancelCampaign,
                  onRefresh: _refreshCampaign,
                  onNew: _newCampaign,
                ),
            ],
          ),
        );
      },
    ),
  );

  Future<void> _connectWhatsapp(HostMessagingSetup setup) async {
    await _run(() async {
      if (!hostWhatsappEmbeddedSignupSupported) {
        throw UnsupportedError(context.l10n.hostsHostAudienceWebSignupOnly);
      }
      final result = await startHostWhatsappEmbeddedSignup(
        setup.embeddedSignup,
      );
      await ref
          .read(hostAudienceControllerProvider)
          .completeWhatsappConnection(
            organizerId: widget.club.id,
            result: result,
          );
      ref.invalidate(hostMessagingSetupProvider(widget.club.id));
    });
  }

  Future<void> _syncTemplates(String connectionId) => _run(() async {
    await ref
        .read(hostAudienceControllerProvider)
        .syncWhatsappTemplates(
          organizerId: widget.club.id,
          connectionId: connectionId,
        );
    ref.invalidate(hostMessagingSetupProvider(widget.club.id));
  });

  Future<void> _disconnectWhatsapp(String connectionId) => _run(() async {
    await ref
        .read(hostAudienceControllerProvider)
        .disconnectWhatsapp(
          organizerId: widget.club.id,
          connectionId: connectionId,
        );
    _newCampaign();
    ref.invalidate(hostMessagingSetupProvider(widget.club.id));
  });

  Future<void> _sendTest(
    HostMessagingSetup setup,
    HostWhatsappTemplate template,
  ) => _run(() async {
    final connection = setup.connection!;
    final variables = {
      for (final variable in template.variableNames)
        variable: _isInviteVariable(variable)
            ? variable == 'invite_token'
                  ? 'catch-test'
                  : 'https://catchdates.com'
            : 'Catch test',
    };
    await ref
        .read(hostAudienceControllerProvider)
        .sendWhatsappTest(
          organizerId: widget.club.id,
          connectionId: connection.connectionId,
          templateId: template.templateId,
          toE164: _testPhoneController.text.trim(),
          templateVariables: variables,
        );
    ref.invalidate(hostMessagingSetupProvider(widget.club.id));
    if (mounted) {
      showCatchSnackBar(context, context.l10n.hostsHostAudienceTestPending);
    }
  });

  Future<void> _saveAndPreview(
    HostWhatsappConnection connection,
    HostWhatsappTemplate template,
  ) => _run(() async {
    final variables = {
      for (final entry in _variableControllers.entries)
        if (template.variableNames.contains(entry.key) &&
            !_isInviteVariable(entry.key))
          entry.key: entry.value.text.trim(),
    };
    final needsInvite = _templateUsesInvite(template);
    if (_campaignNameController.text.trim().isEmpty ||
        variables.values.any((value) => value.isEmpty) ||
        (needsInvite && _selectedEvent == null)) {
      throw StateError(context.l10n.hostsHostAudienceCompleteCampaign);
    }
    final preview = await ref
        .read(hostAudienceControllerProvider)
        .saveAndPreviewCampaign(
          organizerId: widget.club.id,
          draft: HostCampaignDraft(
            requestId: '${DateTime.now().microsecondsSinceEpoch}-host',
            name: _campaignNameController.text.trim(),
            messageClass: _messageClass.wireValue,
            segments: _campaignSegments,
            connectionId: connection.connectionId,
            templateId: template.templateId,
            templateVariables: variables,
            eventId: needsInvite ? _selectedEvent!.id : null,
            inviteDestinationKind: needsInvite
                ? (_inviteDestination ??
                          _destinationsFor(_selectedEvent!).first)
                      .wireValue
                : null,
          ),
        );
    if (mounted) setState(() => _campaign = preview);
  });

  Future<void> _approveCampaign() => _run(() async {
    final campaign = await ref
        .read(hostAudienceControllerProvider)
        .approveCampaign(organizerId: widget.club.id, campaign: _campaign!);
    if (mounted) setState(() => _campaign = campaign);
  });

  Future<void> _dispatchCampaign() => _run(() async {
    final campaign = await ref
        .read(hostAudienceControllerProvider)
        .dispatchCampaign(organizerId: widget.club.id, campaign: _campaign!);
    if (mounted) setState(() => _campaign = campaign);
  });

  Future<void> _cancelCampaign() => _run(() async {
    final campaign = await ref
        .read(hostAudienceControllerProvider)
        .cancelCampaign(organizerId: widget.club.id, campaign: _campaign!);
    if (mounted) setState(() => _campaign = campaign);
  });

  Future<void> _refreshCampaign() => _run(() async {
    final campaign = await ref
        .read(hostAudienceControllerProvider)
        .getCampaignReport(
          organizerId: widget.club.id,
          campaignId: _campaign!.campaignId,
        );
    if (mounted) setState(() => _campaign = campaign);
  });

  void _newCampaign() {
    setState(() {
      _campaign = null;
      _campaignNameController.clear();
      _selectedEvent = null;
      _inviteDestination = null;
    });
  }

  Future<void> _run(Future<void> Function() action) async {
    if (_busy) return;
    setState(() => _busy = true);
    widget.onBusyChanged?.call(true);
    try {
      await action();
    } on Object catch (error) {
      if (mounted) {
        showCatchErrorSnackBar(
          context,
          error,
          errorContext: AppErrorContext.club,
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
      widget.onBusyChanged?.call(false);
    }
  }

  void _syncVariableControllers(HostWhatsappTemplate template) {
    final retained = template.variableNames.where(
      (name) => !_isInviteVariable(name),
    );
    final removed = _variableControllers.keys
        .where((name) => !retained.contains(name))
        .toList();
    for (final name in removed) {
      _variableControllers.remove(name)?.dispose();
    }
    for (final name in retained) {
      _variableControllers.putIfAbsent(name, TextEditingController.new);
    }
    if (!_templateUsesInvite(template)) {
      _selectedEvent = null;
      _inviteDestination = null;
    }
  }

  TextEditingController _controllerForVariable(String name) =>
      _variableControllers.putIfAbsent(name, TextEditingController.new);

  void _disposeVariableControllers() {
    for (final controller in _variableControllers.values) {
      controller.dispose();
    }
    _variableControllers.clear();
  }
}

bool _templateUsesInvite(HostWhatsappTemplate template) =>
    template.variableNames.any(_isInviteVariable);

bool _isInviteVariable(String name) =>
    name == 'invite_url' || name == 'invite_token';

class _HostCampaignReview extends StatelessWidget {
  const _HostCampaignReview({
    required this.campaign,
    required this.busy,
    required this.onApprove,
    required this.onSend,
    required this.onCancel,
    required this.onRefresh,
    required this.onNew,
  });

  final HostCampaign campaign;
  final bool busy;
  final VoidCallback? onApprove;
  final VoidCallback? onSend;
  final VoidCallback? onCancel;
  final VoidCallback onRefresh;
  final VoidCallback onNew;

  @override
  Widget build(BuildContext context) {
    final counts = campaign.audienceCounts;
    final delivery = campaign.deliveryCounts;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CatchNotice(
          notice: CatchNoticeData(
            id: 'host.audience.campaign.${campaign.campaignId}',
            title: context.l10n.hostsHostAudienceCampaignStatus(
              status: campaign.status,
            ),
            message: context.l10n.hostsHostAudienceCampaignCounts(
              total: counts['total'],
              reachable: counts['reachable'],
              optedOut: counts['optedOut'],
              unknown: counts['unknown'],
            ),
            tone: campaign.blockers.isEmpty
                ? CatchNoticeTone.status
                : CatchNoticeTone.warning,
          ),
        ),
        if (campaign.blockers.isNotEmpty) ...[
          gapH8,
          Text(
            campaign.blockers
                .map((value) => _campaignBlockerLabel(context, value))
                .join(' · '),
            style: CatchTextStyles.supporting(
              context,
              color: CatchTokens.of(context).warning,
            ),
          ),
        ],
        if (delivery.values.values.any((value) => value > 0)) ...[
          gapH8,
          Text(
            context.l10n.hostsHostAudienceDeliveryCounts(
              sent: delivery['sent'],
              delivered: delivery['delivered'],
              read: delivery['read'],
              failed: delivery['failed'],
            ),
            style: CatchTextStyles.supporting(
              context,
              color: CatchTokens.of(context).ink2,
            ),
          ),
        ],
        gapH12,
        Wrap(
          spacing: CatchSpacing.s2,
          runSpacing: CatchSpacing.s2,
          children: [
            if (onApprove != null)
              CatchButton(
                label: context.l10n.hostsHostAudienceApprove,
                onPressed: busy ? null : onApprove,
                isLoading: busy,
              ),
            if (onSend != null)
              CatchButton(
                label: context.l10n.hostsHostAudienceSendNow,
                onPressed: busy ? null : onSend,
                isLoading: busy,
              ),
            CatchButton(
              label: context.l10n.hostsHostAudienceRefresh,
              variant: CatchButtonVariant.secondary,
              onPressed: busy ? null : onRefresh,
            ),
            if (onCancel != null)
              CatchButton(
                label: context.l10n.hostsHostAudienceCancel,
                variant: CatchButtonVariant.ghost,
                onPressed: busy ? null : onCancel,
              ),
            CatchButton(
              label: context.l10n.hostsHostAudienceNewCampaign,
              variant: CatchButtonVariant.ghost,
              onPressed: busy ? null : onNew,
            ),
          ],
        ),
      ],
    );
  }
}

String _segmentLabel(
  BuildContext context,
  HostAudienceSegment value,
) => switch (value) {
  HostAudienceSegment.newToOrganizer =>
    context.l10n.hostsHostAudienceSegmentNew,
  HostAudienceSegment.firstTimeAttendee =>
    context.l10n.hostsHostAudienceSegmentFirstTime,
  HostAudienceSegment.repeatAttendee =>
    context.l10n.hostsHostAudienceSegmentRepeat,
  HostAudienceSegment.regular => context.l10n.hostsHostAudienceSegmentRegular,
  HostAudienceSegment.lapsedRegular =>
    context.l10n.hostsHostAudienceSegmentLapsed,
  HostAudienceSegment.reliableAttendee =>
    context.l10n.hostsHostAudienceSegmentReliable,
  HostAudienceSegment.needsConfirmation =>
    context.l10n.hostsHostAudienceSegmentNeedsConfirmation,
  HostAudienceSegment.advocate => context.l10n.hostsHostAudienceSegmentAdvocate,
  HostAudienceSegment.highImpactAdvocate =>
    context.l10n.hostsHostAudienceSegmentHighImpact,
  HostAudienceSegment.whatsappReachable =>
    context.l10n.hostsHostAudienceSegmentWhatsapp,
  HostAudienceSegment.smsReachable => context.l10n.hostsHostAudienceSegmentSms,
};

String _messageClassLabel(
  BuildContext context,
  _HostCampaignMessageClass value,
) => switch (value) {
  _HostCampaignMessageClass.eventFollowUp =>
    context.l10n.hostsHostAudienceMessageFollowUp,
  _HostCampaignMessageClass.organizerUpdate =>
    context.l10n.hostsHostAudienceMessageUpdate,
  _HostCampaignMessageClass.organizerPromotion =>
    context.l10n.hostsHostAudienceMessagePromotion,
};

Event? _eventIn(List<Event> events, Event? selected) {
  if (selected == null) return null;
  for (final event in events) {
    if (event.id == selected.id) return event;
  }
  return null;
}

List<_HostInviteDestination> _destinationsFor(Event event) {
  final destinations = <_HostInviteDestination>[];
  if (event.isExternalCompanion &&
      event.eventOrigin?.externalEventUrl?.isNotEmpty == true) {
    destinations.add(_HostInviteDestination.externalBooking);
  } else {
    destinations.add(_HostInviteDestination.catchEvent);
  }
  if (event.hasWebRuntime) {
    destinations.add(_HostInviteDestination.eventRuntime);
  }
  return destinations;
}

String _inviteDestinationLabel(
  BuildContext context,
  _HostInviteDestination value,
) => switch (value) {
  _HostInviteDestination.catchEvent =>
    context.l10n.hostsHostAudienceDestinationCatchPage,
  _HostInviteDestination.eventRuntime =>
    context.l10n.hostsHostAudienceDestinationRuntime,
  _HostInviteDestination.externalBooking =>
    context.l10n.hostsHostAudienceDestinationExternal,
};

String _connectionStatusLabel(
  BuildContext context,
  HostWhatsappConnection connection,
) => switch (connection.status) {
  'active' => context.l10n.hostsHostAudienceSenderActive,
  'testing' => context.l10n.hostsHostAudienceSenderTesting,
  'degraded' => context.l10n.hostsHostAudienceSenderDegraded,
  'blocked' ||
  'tokenRevoked' => context.l10n.hostsHostAudienceSenderNeedsAttention,
  _ => connection.status,
};

String _campaignBlockerLabel(
  BuildContext context,
  String value,
) => switch (value) {
  'providerSetupRequired' => context.l10n.hostsHostAudienceBlockerProvider,
  'senderInactive' => context.l10n.hostsHostAudienceBlockerSender,
  'templateMissing' ||
  'templateUnapproved' => context.l10n.hostsHostAudienceBlockerTemplate,
  'noReachableRecipients' => context.l10n.hostsHostAudienceBlockerNoRecipients,
  'audienceCoveragePartial' => context.l10n.hostsHostAudienceBlockerCoverage,
  'audienceTooLarge' => context.l10n.hostsHostAudienceBlockerTooLarge,
  'eventMissing' ||
  'eventUnavailable' => context.l10n.hostsHostAudienceBlockerEvent,
  'scheduleInPast' => context.l10n.hostsHostAudienceBlockerSchedule,
  _ => value,
};
