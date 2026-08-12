part of '../host_operations_screen.dart';

enum _HostAudienceWorkspace { people, message }

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

class HostAudiencePane extends ConsumerStatefulWidget {
  const HostAudiencePane({super.key, required this.club});

  final Club club;

  @override
  ConsumerState<HostAudiencePane> createState() => _HostAudiencePaneState();
}

class _HostAudiencePaneState extends ConsumerState<HostAudiencePane> {
  _HostAudienceWorkspace _workspace = _HostAudienceWorkspace.people;
  HostAudienceQuery _query = const HostAudienceQuery();
  final _searchController = TextEditingController();
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
  void didUpdateWidget(covariant HostAudiencePane oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.club.id != widget.club.id) {
      _query = const HostAudienceQuery();
      _searchController.clear();
      _campaign = null;
      _selectedTemplate = null;
      _disposeVariableControllers();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _campaignNameController.dispose();
    _testPhoneController.dispose();
    _disposeVariableControllers();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final summary = ref.watch(hostCrmSummaryProvider(widget.club.id));
    final audience = ref.watch(hostAudienceProvider(widget.club.id, _query));
    final messaging = ref.watch(hostMessagingSetupProvider(widget.club.id));
    return CatchSectionList(
      emptyStateOmitted: true,
      children: [
        CatchSection.divided(
          title: context.l10n.hostsHostAudienceTitle,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.hostsHostAudienceIntro,
                style: CatchTextStyles.supporting(
                  context,
                  color: CatchTokens.of(context).ink2,
                ),
              ),
              gapH16,
              CatchOptionGroup<_HostAudienceWorkspace>(
                contractExemption:
                    'Local presentation lens; it is not a persisted value.',
                selected: _workspace,
                options: [
                  CatchOption(
                    value: _HostAudienceWorkspace.people,
                    label: context.l10n.hostsHostAudiencePeople,
                  ),
                  CatchOption(
                    value: _HostAudienceWorkspace.message,
                    label: context.l10n.hostsHostAudienceMessage,
                  ),
                ],
                onChanged: _busy
                    ? null
                    : (value) => setState(() => _workspace = value),
              ),
            ],
          ),
        ),
        if (_workspace == _HostAudienceWorkspace.people) ...[
          _buildSummary(context, summary),
          _buildDirectory(context, audience),
        ] else ...[
          _buildWhatsappSetup(context, messaging),
          _buildCampaignComposer(context, messaging),
        ],
      ],
    );
  }

  Widget _buildSummary(
    BuildContext context,
    AsyncValue<HostCrmSummary> summary,
  ) => CatchSection.divided(
    title: context.l10n.hostsHostAudienceAtAGlance,
    child: CatchAsyncValueView<HostCrmSummary>(
      value: summary,
      initialLoadTimeout: null,
      loadingBuilder: (_) => const CatchSkeletonRows(count: 2),
      errorBuilder: (_, error, _) => CatchErrorState.fromError(
        error,
        context: AppErrorContext.club,
        mode: CatchErrorStateMode.compact,
        onRetry: () => ref.invalidate(hostCrmSummaryProvider(widget.club.id)),
      ),
      builder: (context, value) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: CatchStatColumn(
                  value: '${value.contactCount}',
                  label: context.l10n.hostsHostAudienceContacts,
                  monoValue: true,
                ),
              ),
              Expanded(
                child: CatchStatColumn(
                  value: '${value.pastAttendeeCount}',
                  label: context.l10n.hostsHostAudienceAttended,
                  monoValue: true,
                ),
              ),
              Expanded(
                child: CatchStatColumn(
                  value: '${value.repeatAttendeeCount}',
                  label: context.l10n.hostsHostAudienceRepeat,
                  monoValue: true,
                ),
              ),
              Expanded(
                child: CatchStatColumn(
                  value: '${value.whatsappOptInCount}',
                  label: context.l10n.hostsHostAudienceWhatsappReady,
                  monoValue: true,
                  highlight: true,
                ),
              ),
            ],
          ),
          gapH12,
          Text(
            context.l10n.hostsHostAudienceSources(
              importedCount: value.importedContactCount,
              linkedCount: value.linkedAccountCount,
            ),
            style: CatchTextStyles.supporting(
              context,
              color: CatchTokens.of(context).ink2,
            ),
          ),
        ],
      ),
    ),
  );

  Widget _buildDirectory(
    BuildContext context,
    AsyncValue<HostAudiencePage> audience,
  ) => CatchSection.divided(
    title: context.l10n.hostsHostAudienceDirectory,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CatchField.input(
          title: context.l10n.hostsHostAudienceSearch,
          contract: CatchContractConstraints
              .listOrganizerContactsCallablePayloadQuery,
          controller: _searchController,
          textInputAction: TextInputAction.search,
          prefixIcon: Icon(CatchIcons.searchRounded),
          onSubmitted: (value) => _changeQuery(
            HostAudienceQuery(search: value.trim(), segment: _query.segment),
          ),
          showClearButton: true,
        ),
        gapH12,
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              CatchChip.selectable(
                label: context.l10n.hostsHostAudienceAll,
                selected: _query.segment == null,
                contractExemption:
                    'The null option clears the persisted segment filter.',
                onChanged: (_) =>
                    _changeQuery(HostAudienceQuery(search: _query.search)),
              ),
              for (final segment in HostAudienceSegment.values) ...[
                gapW8,
                CatchChip.selectable(
                  label: _segmentLabel(context, segment),
                  selected: _query.segment == segment,
                  contract: CatchContractConstraints
                      .listOrganizerContactsCallablePayloadSegmentId,
                  contractValue: segment.wireValue,
                  onChanged: (_) => _changeQuery(
                    HostAudienceQuery(search: _query.search, segment: segment),
                  ),
                ),
              ],
            ],
          ),
        ),
        gapH12,
        CatchAsyncValueView<HostAudiencePage>(
          value: audience,
          initialLoadTimeout: null,
          loadingBuilder: (_) => const CatchSkeletonRows(count: 4),
          errorBuilder: (_, error, _) => CatchErrorState.fromError(
            error,
            context: AppErrorContext.club,
            mode: CatchErrorStateMode.compact,
            onRetry: () =>
                ref.invalidate(hostAudienceProvider(widget.club.id, _query)),
          ),
          builder: (context, page) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (page.sourceCoverage != HostAudienceSourceCoverage.exact)
                CatchNotice(
                  notice: CatchNoticeData(
                    id: 'host.audience.coverage.partial',
                    title: context.l10n.hostsHostAudienceCoveragePartial,
                    message: context.l10n.hostsHostAudienceCoveragePartialBody,
                    tone: CatchNoticeTone.warning,
                  ),
                ),
              if (page.sourceCoverage != HostAudienceSourceCoverage.exact)
                gapH12,
              if (page.contacts.isEmpty)
                Text(
                  context.l10n.hostsHostAudienceEmpty,
                  style: CatchTextStyles.supporting(
                    context,
                    color: CatchTokens.of(context).ink2,
                  ),
                )
              else
                CatchSection.fieldRows(
                  children: [
                    for (
                      var index = 0;
                      index < page.contacts.length;
                      index += 1
                    )
                      _HostAudienceContactRow(
                        contact: page.contacts[index],
                        divider: index < page.contacts.length - 1,
                        onTap: _busy
                            ? null
                            : () => _showContact(page.contacts[index]),
                      ),
                  ],
                ),
              gapH12,
              CatchButton(
                label: 'Export this audience',
                variant: CatchButtonVariant.secondary,
                size: CatchButtonSize.sm,
                onPressed: _busy ? null : _exportAudience,
                isLoading: _busy,
                icon: Icon(CatchIcons.downloadRounded),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _buildWhatsappSetup(
    BuildContext context,
    AsyncValue<HostMessagingSetup> messaging,
  ) => CatchSection.divided(
    title: context.l10n.hostsHostAudienceWhatsappSender,
    child: CatchAsyncValueView<HostMessagingSetup>(
      value: messaging,
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
        return Column(
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
        );
      },
    ),
  );

  Widget _buildCampaignComposer(
    BuildContext context,
    AsyncValue<HostMessagingSetup> messaging,
  ) => CatchSection.divided(
    title: context.l10n.hostsHostAudienceCampaign,
    child: CatchAsyncValueView<HostMessagingSetup>(
      value: messaging,
      initialLoadTimeout: null,
      loadingBuilder: (_) => const CatchSkeletonRows(),
      errorBuilder: (_, error, _) => CatchErrorState.fromError(
        error,
        context: AppErrorContext.club,
        mode: CatchErrorStateMode.compact,
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
        return Column(
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
                  itemLabel: (value) => _inviteDestinationLabel(context, value),
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
        );
      },
    ),
  );

  void _changeQuery(HostAudienceQuery value) {
    setState(() => _query = value);
  }

  Future<void> _exportAudience() => _run(() async {
    final export = await ref
        .read(hostAudienceControllerProvider)
        .exportContacts(organizerId: widget.club.id, segment: _query.segment);
    await ref
        .read(externalShareControllerProvider)
        .shareCsvFile(
          csv: export.csv,
          fileName: export.fileName,
          subject: 'Catch audience export',
          text: export.truncated
              ? 'This export reached the 2,500-contact safety limit.'
              : '${export.rowCount} organizer contacts.',
        );
  });

  Future<void> _showContact(HostAudienceContact contact) async {
    final detail = await _loadContact(contact);
    if (!mounted || detail == null) return;
    await showCatchBottomSheet<void>(
      context: context,
      builder: (sheetContext) => _HostAudienceContactSheet(
        detail: detail,
        busy: _busy,
        onRename: (name) async {
          Navigator.of(sheetContext).pop();
          await _mutateContact(
            detail,
            displayNameOverride: name,
            clearDisplayNameOverride: name == null,
          );
        },
        onSuppressionChanged: (suppressed) async {
          Navigator.of(sheetContext).pop();
          await _mutateContact(detail, whatsappAdminSuppressed: suppressed);
        },
        onHide: () async {
          Navigator.of(sheetContext).pop();
          final confirmed = await showCatchConfirmDialog(
            context: context,
            title: 'Remove from Audience?',
            message:
                'This hides the person from CRM and future campaigns. Event attendance and audit history stay intact.',
            confirmLabel: 'Remove',
            danger: true,
          );
          if (confirmed == true) await _mutateContact(detail, hidden: true);
        },
      ),
    );
  }

  Future<HostAudienceContactDetail?> _loadContact(
    HostAudienceContact contact,
  ) async {
    HostAudienceContactDetail? result;
    await _run(() async {
      result = await ref
          .read(hostAudienceControllerProvider)
          .getContactDetail(
            organizerId: widget.club.id,
            contactId: contact.contactId,
          );
    });
    return result;
  }

  Future<void> _mutateContact(
    HostAudienceContactDetail detail, {
    String? displayNameOverride,
    bool clearDisplayNameOverride = false,
    bool? whatsappAdminSuppressed,
    bool? hidden,
  }) => _run(() async {
    await ref
        .read(hostAudienceControllerProvider)
        .mutateContact(
          organizerId: widget.club.id,
          contactId: detail.contactId,
          expectedRevision: detail.revision,
          displayNameOverride: displayNameOverride,
          clearDisplayNameOverride: clearDisplayNameOverride,
          whatsappAdminSuppressed: whatsappAdminSuppressed,
          hidden: hidden,
        );
    ref.invalidate(hostAudienceProvider(widget.club.id, _query));
    ref.invalidate(hostCrmSummaryProvider(widget.club.id));
  });

  Future<void> _connectWhatsapp(HostMessagingSetup setup) async {
    await _run(() async {
      if (!hostWhatsappEmbeddedSignupSupported) {
        throw UnsupportedError(context.l10n.hostsHostAudienceWebSignupOnly);
      }
      final result = await startHostWhatsappEmbeddedSignup(
        setup.embeddedSignup,
      );
      await ref
          .read(hostCrmRepositoryProvider)
          .completeWhatsappConnection(widget.club.id, result);
      ref.invalidate(hostMessagingSetupProvider(widget.club.id));
    });
  }

  Future<void> _syncTemplates(String connectionId) => _run(() async {
    await ref
        .read(hostCrmRepositoryProvider)
        .syncWhatsappTemplates(widget.club.id, connectionId);
    ref.invalidate(hostMessagingSetupProvider(widget.club.id));
  });

  Future<void> _disconnectWhatsapp(String connectionId) => _run(() async {
    await ref
        .read(hostCrmRepositoryProvider)
        .disconnectWhatsapp(widget.club.id, connectionId);
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
        .read(hostCrmRepositoryProvider)
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
    final repository = ref.read(hostCrmRepositoryProvider);
    final saved = await repository.upsertCampaign(
      widget.club.id,
      HostCampaignDraft(
        requestId: '${DateTime.now().microsecondsSinceEpoch}-host',
        name: _campaignNameController.text.trim(),
        messageClass: _messageClass.wireValue,
        segments: _campaignSegments,
        connectionId: connection.connectionId,
        templateId: template.templateId,
        templateVariables: variables,
        eventId: needsInvite ? _selectedEvent!.id : null,
        inviteDestinationKind: needsInvite
            ? (_inviteDestination ?? _destinationsFor(_selectedEvent!).first)
                  .wireValue
            : null,
      ),
    );
    final preview = await repository.previewCampaign(widget.club.id, saved);
    if (mounted) setState(() => _campaign = preview);
  });

  Future<void> _approveCampaign() => _run(() async {
    final campaign = await ref
        .read(hostCrmRepositoryProvider)
        .approveCampaign(widget.club.id, _campaign!);
    if (mounted) setState(() => _campaign = campaign);
  });

  Future<void> _dispatchCampaign() => _run(() async {
    final campaign = await ref
        .read(hostCrmRepositoryProvider)
        .dispatchCampaign(widget.club.id, _campaign!);
    if (mounted) setState(() => _campaign = campaign);
  });

  Future<void> _cancelCampaign() => _run(() async {
    final campaign = await ref
        .read(hostCrmRepositoryProvider)
        .cancelCampaign(widget.club.id, _campaign!);
    if (mounted) setState(() => _campaign = campaign);
  });

  Future<void> _refreshCampaign() => _run(() async {
    final campaign = await ref
        .read(hostCrmRepositoryProvider)
        .getCampaignReport(widget.club.id, _campaign!.campaignId);
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

class _HostAudienceContactRow extends StatelessWidget {
  const _HostAudienceContactRow({
    required this.contact,
    required this.divider,
    required this.onTap,
  });

  final HostAudienceContact contact;
  final bool divider;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final metadata = [
      context.l10n.hostsHostAudienceEventsAttended(
        count: contact.attendedEventCount,
      ),
      if (contact.lastAttendedAt != null)
        context.l10n.hostsHostAudienceLastSeen(
          date: AppTimeFormatters.shortDate(contact.lastAttendedAt!),
        ),
      if (contact.whatsappStatus == HostAudiencePermissionStatus.optedIn)
        context.l10n.hostsHostAudienceWhatsappOptedIn,
      if (contact.identityState == HostAudienceIdentityState.ambiguous)
        context.l10n.hostsHostAudienceIdentityNeedsReview,
    ];
    return InkWell(
      onTap: onTap,
      child: CatchField.read(
        title: contact.displayName,
        body: metadata.join(' · '),
        valueText: contact.whatsappAdminSuppressed
            ? 'Messaging paused'
            : contact.segments.isEmpty
            ? null
            : _segmentLabel(context, contact.segments.first),
        valid: contact.identityState != HostAudienceIdentityState.ambiguous,
        divider: divider,
      ),
    );
  }
}

class _HostAudienceContactSheet extends StatefulWidget {
  const _HostAudienceContactSheet({
    required this.detail,
    required this.busy,
    required this.onRename,
    required this.onSuppressionChanged,
    required this.onHide,
  });

  final HostAudienceContactDetail detail;
  final bool busy;
  final ValueChanged<String?> onRename;
  final ValueChanged<bool> onSuppressionChanged;
  final VoidCallback onHide;

  @override
  State<_HostAudienceContactSheet> createState() =>
      _HostAudienceContactSheetState();
}

class _HostAudienceContactSheetState extends State<_HostAudienceContactSheet> {
  late final TextEditingController _nameController = TextEditingController(
    text: widget.detail.displayNameOverride ?? widget.detail.sourceDisplayName,
  );

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => CatchBottomSheetScaffold(
    title: widget.detail.displayName,
    subtitle: 'Organizer-only CRM record',
    child: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CatchField.input(
            title: 'Name shown to your team',
            contract: CatchContractConstraints
                .mutateOrganizerContactCallablePayloadDisplayNameOverride,
            controller: _nameController,
            helperText:
                'This does not alter the guest’s Catch profile or verified contact details.',
          ),
          gapH8,
          CatchButton(
            label: 'Save name',
            size: CatchButtonSize.sm,
            onPressed: widget.busy
                ? null
                : () {
                    final value = _nameController.text.trim();
                    widget.onRename(
                      value == widget.detail.sourceDisplayName ? null : value,
                    );
                  },
          ),
          if (widget.detail.phoneE164 case final phone?) ...[
            gapH16,
            CatchField.read(title: 'Verified phone', body: phone),
          ],
          if (widget.detail.email case final email?)
            CatchField.read(title: 'Email', body: email),
          gapH12,
          CatchNotice(
            notice: CatchNoticeData(
              id: 'host.audience.contact.delivery-boundary',
              title: 'Consent controls delivery',
              message: widget.detail.whatsappAdminSuppressed
                  ? 'Your team has paused WhatsApp campaigns to this person. Their own opt-out remains authoritative.'
                  : 'Only the person-verified number and active organizer consent can receive a campaign.',
              tone: CatchNoticeTone.status,
            ),
          ),
          gapH12,
          CatchButton(
            label: widget.detail.whatsappAdminSuppressed
                ? 'Resume organizer messages'
                : 'Pause organizer messages',
            variant: CatchButtonVariant.secondary,
            onPressed: widget.busy
                ? null
                : () => widget.onSuppressionChanged(
                    !widget.detail.whatsappAdminSuppressed,
                  ),
          ),
          if (widget.detail.events.isNotEmpty) ...[
            gapH20,
            Text('Event history', style: CatchTextStyles.sectionTitle(context)),
            gapH8,
            for (final event in widget.detail.events.take(8))
              CatchField.read(
                title: event.displayName,
                body: event.eventStartAt == null
                    ? event.source
                    : '${AppTimeFormatters.shortDate(event.eventStartAt!)} · ${event.source}',
                valueText: event.checkedIn ? 'Checked in' : event.status,
              ),
          ],
          gapH16,
          CatchButton(
            label: 'Remove from Audience',
            variant: CatchButtonVariant.ghost,
            onPressed: widget.busy ? null : widget.onHide,
          ),
        ],
      ),
    ),
  );
}

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
  HostAudienceSegment.firstTimeAttendee =>
    context.l10n.hostsHostAudienceSegmentFirstTime,
  HostAudienceSegment.repeatAttendee =>
    context.l10n.hostsHostAudienceSegmentRepeat,
  HostAudienceSegment.regular => context.l10n.hostsHostAudienceSegmentRegular,
  HostAudienceSegment.lapsedRegular =>
    context.l10n.hostsHostAudienceSegmentLapsed,
  HostAudienceSegment.reliableAttendee =>
    context.l10n.hostsHostAudienceSegmentReliable,
  HostAudienceSegment.advocate => context.l10n.hostsHostAudienceSegmentAdvocate,
  HostAudienceSegment.highImpactAdvocate =>
    context.l10n.hostsHostAudienceSegmentHighImpact,
  HostAudienceSegment.whatsappReachable =>
    context.l10n.hostsHostAudienceSegmentWhatsapp,
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
