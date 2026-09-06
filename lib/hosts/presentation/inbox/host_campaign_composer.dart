import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/presentation/catch_async_state.dart';
import 'package:catch_dating_app/core/presentation/catch_async_value_adapter.dart';
import 'package:catch_dating_app/core/time_formatters.dart';
import 'package:catch_dating_app/core/widgets/catch_adaptive_picker.dart';
import 'package:catch_dating_app/core/widgets/catch_async_value_view.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_error_snackbar.dart';
import 'package:catch_dating_app/core/widgets/catch_error_state.dart';
import 'package:catch_dating_app/core/widgets/catch_field.dart';
import 'package:catch_dating_app/core/widgets/catch_notice.dart';
import 'package:catch_dating_app/core/widgets/catch_section_layout.dart';
import 'package:catch_dating_app/core/widgets/catch_skeleton_layouts.dart';
import 'package:catch_dating_app/events/data/event_repository.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/hosts/data/host_crm_repository.dart';
import 'package:catch_dating_app/hosts/presentation/host_audience_controller.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

abstract final class HostCampaignBlockers {
  static const providerSetupRequired = 'providerSetupRequired';
  static const senderInactive = 'senderInactive';
  static const templateMissing = 'templateMissing';
  static const templateUnapproved = 'templateUnapproved';
  static const noReachableRecipients = 'noReachableRecipients';
  static const audienceCoveragePartial = 'audienceCoveragePartial';
  static const audienceTooLarge = 'audienceTooLarge';
  static const eventMissing = 'eventMissing';
  static const eventUnavailable = 'eventUnavailable';
  static const scheduleInPast = 'scheduleInPast';
}

String? hostCampaignBridgeBlocker({
  required bool hasPersistableAudience,
  required HostMessagingSetup? messagingSetup,
  required bool audienceCoverageComplete,
}) {
  if (!hasPersistableAudience) {
    return HostCampaignBlockers.noReachableRecipients;
  }
  if (!audienceCoverageComplete) {
    return HostCampaignBlockers.audienceCoveragePartial;
  }
  if (messagingSetup?.providerConfigured == false) {
    return HostCampaignBlockers.providerSetupRequired;
  }
  if (messagingSetup?.connection?.isActive != true) {
    return HostCampaignBlockers.senderInactive;
  }
  return null;
}

class HostCampaignComposer extends ConsumerStatefulWidget {
  const HostCampaignComposer({
    super.key,
    required this.club,
    this.initialSavedAudienceId,
    this.onBusyChanged,
  });

  final Club club;
  final String? initialSavedAudienceId;
  final ValueChanged<bool>? onBusyChanged;

  @override
  ConsumerState<HostCampaignComposer> createState() =>
      _HostCampaignComposerState();
}

class _HostCampaignComposerState extends ConsumerState<HostCampaignComposer> {
  final _campaignNameController = TextEditingController();
  final Map<String, TextEditingController> _variableControllers = {};
  HostSavedAudience? _selectedAudience;
  _HostCampaignMessageClass _messageClass =
      _HostCampaignMessageClass.organizerPromotion;
  HostWhatsappTemplate? _selectedTemplate;
  Event? _selectedEvent;
  _HostInviteDestination? _inviteDestination;
  HostCampaign? _campaign;
  DateTime? _scheduledAt;
  String? _scheduleError;
  bool _busy = false;

  @override
  void didUpdateWidget(covariant HostCampaignComposer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.club.id != widget.club.id ||
        oldWidget.initialSavedAudienceId != widget.initialSavedAudienceId) {
      _campaign = null;
      _scheduledAt = null;
      _scheduleError = null;
      _selectedTemplate = null;
      _selectedAudience = null;
      _disposeVariableControllers();
    }
  }

  @override
  void dispose() {
    _campaignNameController.dispose();
    _disposeVariableControllers();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final messaging = ref.watch(hostMessagingSetupProvider(widget.club.id));
    final savedAudiences = ref.watch(
      hostSavedAudiencesProvider(widget.club.id),
    );
    return _buildCampaignComposer(
      context,
      messaging,
      catchAsyncStateFromAsyncValue(savedAudiences),
    );
  }

  CatchSection _buildCampaignComposer(
    BuildContext context,
    AsyncValue<HostMessagingSetup> messaging,
    CatchAsyncState<HostSavedAudiencePage> savedAudiences,
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
            catchAsyncStateFromAsyncValue(
                  ref.watch(watchEventsForClubProvider(widget.club.id)),
                ).value
                ?.where((event) => !event.isCancelled)
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
        if (savedAudiences.status == CatchAsyncStatus.error) {
          return CatchErrorState.fromError(
            savedAudiences.error!,
            context: AppErrorContext.customers,
            mode: CatchErrorStateMode.compact,
            onRetry: () =>
                ref.invalidate(hostSavedAudiencesProvider(widget.club.id)),
          );
        }
        if (savedAudiences.status == CatchAsyncStatus.loading) {
          return const CatchSkeletonRows();
        }
        final audiences = savedAudiences.value?.audiences ?? const [];
        if (audiences.isEmpty) {
          return CatchNotice(
            notice: CatchNoticeData(
              id: 'host.sends.saved-audience-required',
              title: context.l10n.hostSavedAudiencesEmptyTitle,
              message: context.l10n.hostSavedAudiencesEmptyBody,
            ),
          );
        }
        final template = _selectedTemplate ?? approved.first;
        final selectedAudience = _audienceIn(
          audiences,
          _selectedAudience,
          widget.initialSavedAudienceId,
        );
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
                context.l10n.hostSendsDeliveryTime,
                style: CatchTextStyles.fieldRowTitle(context),
              ),
              gapH8,
              Text(
                _scheduledAt == null
                    ? context.l10n.hostSendsSendNow
                    : AppTimeFormatters.dateTime(_scheduledAt!),
                style: CatchTextStyles.supporting(
                  context,
                  color: CatchTokens.of(context).ink2,
                ),
              ),
              gapH8,
              Wrap(
                spacing: CatchSpacing.s2,
                runSpacing: CatchSpacing.s2,
                children: [
                  CatchButton(
                    label: context.l10n.hostSendsSchedule,
                    variant: CatchButtonVariant.secondary,
                    size: CatchButtonSize.sm,
                    onPressed: _campaign == null && !_busy
                        ? _pickSchedule
                        : null,
                  ),
                  if (_scheduledAt != null)
                    CatchButton(
                      label: context.l10n.hostSendsClearSchedule,
                      variant: CatchButtonVariant.ghost,
                      size: CatchButtonSize.sm,
                      onPressed: _campaign == null && !_busy
                          ? () => setState(() {
                              _scheduledAt = null;
                              _scheduleError = null;
                            })
                          : null,
                    ),
                ],
              ),
              if (_scheduleError case final error?) ...[
                gapH8,
                Text(
                  error,
                  style: CatchTextStyles.supporting(
                    context,
                    color: CatchTokens.of(context).warning,
                  ),
                ),
              ],
              gapH12,
              Text(
                context.l10n.hostsHostAudienceRecipients,
                style: CatchTextStyles.fieldRowTitle(context),
              ),
              gapH8,
              CatchField.select<HostSavedAudience>(
                title: context.l10n.hostSavedAudienceFieldLabel,
                contract: CatchContractConstraints
                    .upsertOrganizerCampaignCallablePayloadSavedAudienceId,
                contractValue: (audience) => audience.audienceId,
                values: audiences,
                itemLabel: (audience) => _savedAudienceLabel(context, audience),
                value: selectedAudience,
                enabled: _campaign == null,
                onChanged: (value) => setState(() => _selectedAudience = value),
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
                      : () => _saveAndPreview(
                          connection,
                          template,
                          selectedAudience,
                        ),
                  isLoading: _busy,
                )
              else
                HostCampaignReport(
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

  Future<void> _saveAndPreview(
    HostWhatsappConnection connection,
    HostWhatsappTemplate template,
    HostSavedAudience? selectedAudience,
  ) => _run(() async {
    final variables = {
      for (final entry in _variableControllers.entries)
        if (template.variableNames.contains(entry.key) &&
            !_isInviteVariable(entry.key))
          entry.key: entry.value.text.trim(),
    };
    final needsInvite = _templateUsesInvite(template);
    if (_scheduledAt != null && !_scheduledAt!.isAfter(DateTime.now())) {
      setState(() {
        _scheduleError = context.l10n.hostsHostAudienceBlockerSchedule;
      });
      return;
    }
    if (_campaignNameController.text.trim().isEmpty ||
        selectedAudience == null ||
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
            savedAudienceId: selectedAudience.audienceId,
            connectionId: connection.connectionId,
            templateId: template.templateId,
            templateVariables: variables,
            eventId: needsInvite ? _selectedEvent!.id : null,
            inviteDestinationKind: needsInvite
                ? (_inviteDestination ??
                          _destinationsFor(_selectedEvent!).first)
                      .wireValue
                : null,
            scheduledAt: _scheduledAt,
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
      _scheduledAt = null;
      _scheduleError = null;
    });
  }

  Future<void> _pickSchedule() async {
    final now = DateTime.now();
    final initial = _scheduledAt ?? now.add(const Duration(hours: 1));
    final date = await showCatchDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateUtils.dateOnly(now),
      lastDate: DateUtils.dateOnly(now.add(const Duration(days: 365))),
      title: context.l10n.hostSendsSchedule,
    );
    if (date == null || !mounted) return;
    final time = await showCatchTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
      title: context.l10n.hostSendsSchedule,
    );
    if (time == null || !mounted) return;
    final scheduledAt = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
    setState(() {
      _scheduledAt = scheduledAt;
      _scheduleError = scheduledAt.isAfter(DateTime.now())
          ? null
          : context.l10n.hostsHostAudienceBlockerSchedule;
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

class HostCampaignReport extends StatelessWidget {
  const HostCampaignReport({
    super.key,
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
                .map((value) => hostCampaignBlockerLabel(context, value))
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

HostSavedAudience? _audienceIn(
  List<HostSavedAudience> audiences,
  HostSavedAudience? selected,
  String? initialAudienceId,
) {
  final requestedId = selected?.audienceId ?? initialAudienceId;
  if (requestedId != null) {
    for (final audience in audiences) {
      if (audience.audienceId == requestedId) return audience;
    }
  }
  return audiences.isEmpty ? null : audiences.first;
}

String _savedAudienceLabel(BuildContext context, HostSavedAudience audience) =>
    audience.lastPreviewMatchCount == null
    ? audience.name
    : context.l10n.hostSavedAudienceOption(
        name: audience.name,
        count: audience.lastPreviewMatchCount!,
      );

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

String hostCampaignBlockerLabel(BuildContext context, String value) =>
    switch (value) {
      HostCampaignBlockers.providerSetupRequired =>
        context.l10n.hostsHostAudienceBlockerProvider,
      HostCampaignBlockers.senderInactive =>
        context.l10n.hostsHostAudienceBlockerSender,
      HostCampaignBlockers.templateMissing ||
      HostCampaignBlockers.templateUnapproved =>
        context.l10n.hostsHostAudienceBlockerTemplate,
      HostCampaignBlockers.noReachableRecipients =>
        context.l10n.hostsHostAudienceBlockerNoRecipients,
      HostCampaignBlockers.audienceCoveragePartial =>
        context.l10n.hostsHostAudienceBlockerCoverage,
      HostCampaignBlockers.audienceTooLarge =>
        context.l10n.hostsHostAudienceBlockerTooLarge,
      HostCampaignBlockers.eventMissing ||
      HostCampaignBlockers.eventUnavailable =>
        context.l10n.hostsHostAudienceBlockerEvent,
      HostCampaignBlockers.scheduleInPast =>
        context.l10n.hostsHostAudienceBlockerSchedule,
      _ => value,
    };
