import 'dart:convert';
import 'dart:math';

import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/city_catalog.dart';
import 'package:catch_dating_app/core/presentation/catch_ui_copy.dart';
import 'package:catch_dating_app/core/riverpod_ui/catch_error_snack_bar.dart';
import 'package:catch_dating_app/events/data/event_draft_repository.dart';
import 'package:catch_dating_app/events/domain/event_draft.dart';
import 'package:catch_dating_app/hosts/data/private_event_setup_repository.dart';
import 'package:catch_dating_app/hosts/domain/host_roster_import.dart';
import 'package:catch_dating_app/hosts/events/presentation/host_event_entry_sheet.dart';
import 'package:catch_dating_app/hosts/events/presentation/host_event_entry_state.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/create/create_event_draft_controller.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/create/create_event_prefill.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/create/private_event_draft_restore.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/create/private_event_setup_screen.dart';
import 'package:catch_dating_app/hosts/presentation/widgets/host_draft_exit_dialog.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

typedef CreatePrivateEvent =
    Future<PrivateEventCreateReceipt> Function({
      required String organizerId,
      required String requestId,
      required PrivateEventBasics basics,
    });

// Inheritance requires a manager-authorized defaults read with its reviewed
// hash. An unversioned Club snapshot can only suggest an explicit set value.
bool _trustedOrganizerDefaultsReadAvailable() => false;

/// The first page of the single progressive event editor.
///
/// No rich Event model is constructed here: the receipt identifies a private
/// canonical event whose optional capabilities can be set up later.
class PrivateEventCreateScreen extends ConsumerStatefulWidget {
  const PrivateEventCreateScreen({
    super.key,
    required this.club,
    this.initialDraft,
    this.initialPrefill,
    this.initialRosterImportPlan,
    this.promptForDraftsOnStart = true,
    this.create,
    this.onSaved,
  });

  final Club club;
  final EventDraft? initialDraft;
  final CreateEventPrefill? initialPrefill;
  final HostRosterImportPlan? initialRosterImportPlan;
  final bool promptForDraftsOnStart;
  final CreatePrivateEvent? create;
  final ValueChanged<PrivateEventCreateReceipt>? onSaved;

  @override
  ConsumerState<PrivateEventCreateScreen> createState() =>
      _PrivateEventCreateScreenState();
}

class _PrivateEventCreateScreenState
    extends ConsumerState<PrivateEventCreateScreen> {
  final _nameController = TextEditingController();
  final _timezoneController = TextEditingController();
  final _cityAccordion = CatchAccordionController();
  DateTime? _date;
  TimeOfDay? _start;
  CityOption? _city;
  bool _cityInherited = false;
  bool _timezoneInherited = false;
  PrivateEventCreateReceipt? _receipt;
  bool _saving = false;
  bool _showErrors = false;
  bool _moreBasicsOpen = false;
  bool _allowPop = false;
  bool _defaultsChanged = false;
  String? _error;
  late String _requestId;
  String? _submittedSignature;
  String? _submittedPayloadJson;
  late String _localDraftId;
  EventDraft? _activeDraft;

  @override
  void initState() {
    super.initState();
    _requestId = _newRequestId();
    _localDraftId = widget.initialDraft?.id ?? _newRequestId();
    _activeDraft = widget.initialDraft;
    final startingValues = widget.initialDraft ?? widget.initialPrefill?.values;
    if (startingValues != null) {
      _requestId = startingValues.eventCreateRequestId ?? _requestId;
      _submittedSignature = startingValues.eventCreatePayloadSignature;
      _submittedPayloadJson = startingValues.eventCreatePayloadJson;
      final savedId = startingValues.eventCreateReceiptEventId;
      final savedRevision = startingValues.eventCreateReceiptRevision;
      if (savedId != null && savedRevision != null) {
        _receipt = PrivateEventCreateReceipt(
          eventId: savedId,
          setupRevision: savedRevision,
          replayed: true,
        );
      }
      _nameController.text = startingValues.name ?? '';
      _timezoneController.text = startingValues.eventTimezone ?? '';
      for (final option in defaultCityOptions) {
        if (option.effectiveCityId == startingValues.eventCityId &&
            option.effectiveMarketId == startingValues.eventMarketId) {
          _city = option;
          break;
        }
      }
      _date = restoredPrivateEventDate(startingValues, rejectPast: true);
      _start = restoredPrivateEventStart(startingValues);
    }
    for (final option in defaultCityOptions) {
      if (_city == null &&
          option.effectiveCityId == widget.club.locationCityId &&
          option.effectiveMarketId == widget.club.locationMarketId) {
        _city = option;
        if (_timezoneController.text.isEmpty) {
          _timezoneController.text =
              widget.club.hostDefaults.timezone ?? option.timeZone;
        }
        break;
      }
    }
    if (startingValues == null) {
      _cityInherited = _trustedOrganizerDefaultsReadAvailable() &&
          widget.club.locationCityId.isNotEmpty &&
          widget.club.locationMarketId.isNotEmpty;
      _timezoneInherited =
          _trustedOrganizerDefaultsReadAvailable() &&
          (widget.club.hostDefaults.timezone?.trim().isNotEmpty ?? false);
    } else {
      _cityInherited = _trustedOrganizerDefaultsReadAvailable() &&
          startingValues.eventCityMode == 'inherit';
      _timezoneInherited = _trustedOrganizerDefaultsReadAvailable() &&
          startingValues.eventTimezoneMode == 'inherit';
      final reviewedHash = startingValues.eventReviewedDefaultsHash;
      _defaultsChanged = (_cityInherited || _timezoneInherited) &&
          reviewedHash != _organizerDefaultsHash;
    }
    _nameController.addListener(_refresh);
    _timezoneController.addListener(_refresh);
    _cityAccordion.addListener(_refresh);
    if (widget.promptForDraftsOnStart &&
        widget.initialDraft == null &&
        widget.initialPrefill == null &&
        widget.initialRosterImportPlan == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _checkForDrafts());
    }
  }

  Future<void> _checkForDrafts() async {
    try {
      final drafts = await ref
          .read(createEventDraftControllerProvider.notifier)
          .loadDrafts(clubId: widget.club.id);
      if (!mounted || drafts.isEmpty) return;
      final picked = await showHostEventEntrySheet(
        context: context,
        state: HostEventEntryState.resolve(
          organizerId: widget.club.id,
          drafts: drafts,
        ),
      );
      if (!mounted || picked?.draft == null) return;
      final draft = picked!.draft!;
      if (draft.clubId != widget.club.id) return;
      setState(() => _restorePickedDraft(draft));
    } catch (error) {
      if (mounted) showCatchErrorSnackBar(context, error);
    }
  }

  void _restorePickedDraft(EventDraft draft) {
    _activeDraft = draft;
    _localDraftId = draft.id;
    _requestId = draft.eventCreateRequestId ?? _newRequestId();
    _submittedSignature = draft.eventCreatePayloadSignature;
    _submittedPayloadJson = draft.eventCreatePayloadJson;
    _receipt = draft.eventCreateReceiptEventId != null &&
            draft.eventCreateReceiptRevision != null
        ? PrivateEventCreateReceipt(
            eventId: draft.eventCreateReceiptEventId!,
            setupRevision: draft.eventCreateReceiptRevision!,
            replayed: true,
          )
        : null;
    _nameController.text = draft.name ?? '';
    _city = null;
    for (final option in defaultCityOptions) {
      if (option.effectiveCityId == draft.eventCityId &&
          option.effectiveMarketId == draft.eventMarketId) {
        _city = option;
        break;
      }
    }
    _city ??= defaultCityOptions.where((option) =>
        option.effectiveCityId == widget.club.locationCityId &&
        option.effectiveMarketId == widget.club.locationMarketId).firstOrNull;
    _timezoneController.text = draft.eventTimezone ??
        widget.club.hostDefaults.timezone ??
        _city?.timeZone ?? '';
    _date = restoredPrivateEventDate(draft, rejectPast: false);
    _start = restoredPrivateEventStart(draft);
    _cityInherited = _trustedOrganizerDefaultsReadAvailable() &&
        draft.eventCityMode == 'inherit';
    _timezoneInherited = _trustedOrganizerDefaultsReadAvailable() &&
        draft.eventTimezoneMode == 'inherit';
    _defaultsChanged = (_cityInherited || _timezoneInherited) &&
        draft.eventReviewedDefaultsHash != _organizerDefaultsHash;
    _showErrors = false;
    _error = null;
  }

  @override
  void dispose() {
    _nameController.removeListener(_refresh);
    _timezoneController.removeListener(_refresh);
    _cityAccordion.removeListener(_refresh);
    _nameController.dispose();
    _timezoneController.dispose();
    _cityAccordion.dispose();
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  String get _localDate {
    final date = _date!;
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  String get _localStartTime {
    final time = _start!;
    return '${time.hour.toString().padLeft(2, '0')}:'
        '${time.minute.toString().padLeft(2, '0')}';
  }

  PrivateEventBasics? get _basics {
    final city = _city;
    if ((city == null && !_cityInherited) || _date == null || _start == null) {
      return null;
    }
    return PrivateEventBasics(
      name: _nameController.text,
      city: _cityInherited
          ? const EventSetupValue.inherit()
          : EventSetupValue.set(
              EventSetupCity(
                cityId: city!.effectiveCityId,
                marketId: city.effectiveMarketId,
              ),
            ),
      localDate: _localDate,
      localStartTime: _localStartTime,
      timezone: _timezoneInherited
          ? const EventSetupValue.inherit()
          : EventSetupValue.set(_timezoneController.text),
      reviewedDefaultsHash: _cityInherited || _timezoneInherited
          ? _organizerDefaultsHash
          : null,
    );
  }

  String get _organizerDefaultsHash => organizerEventDefaultsHash(
    cityId: widget.club.locationCityId,
    marketId: widget.club.locationMarketId,
    timezone: widget.club.hostDefaults.timezone,
    revision: widget.club.hostDefaults.revision,
  );

  void _restoreOrganizerCity() {
    if (widget.club.locationCityId.isEmpty ||
        widget.club.locationMarketId.isEmpty) {
      return;
    }
    setState(() {
      _cityInherited = _trustedOrganizerDefaultsReadAvailable();
      for (final option in defaultCityOptions) {
        if (option.effectiveCityId == widget.club.locationCityId &&
            option.effectiveMarketId == widget.club.locationMarketId) {
          _city = option;
          break;
        }
      }
    });
  }

  void _restoreOrganizerTimezone() {
    final inherited = widget.club.hostDefaults.timezone;
    if (inherited == null || inherited.trim().isEmpty) return;
    setState(() {
      _timezoneInherited = _trustedOrganizerDefaultsReadAvailable();
      _timezoneController.text = inherited;
    });
  }

  void _reviewCurrentDefaults() {
    if (_cityInherited) _restoreOrganizerCity();
    if (_timezoneInherited) _restoreOrganizerTimezone();
    setState(() {
      _defaultsChanged = false;
      _error = null;
    });
  }

  bool get _hasChanges =>
      _nameController.text.trim().isNotEmpty ||
      _date != null ||
      _start != null ||
      _submittedSignature != null ||
      _activeDraft != null ||
      widget.initialPrefill != null;

  Future<void> _pickDate() async {
    final today = DateUtils.dateOnly(DateTime.now());
    final date = await showCatchDatePicker(
      copy: catchDatePickerCopy(context.l10n),
      context: context,
      initialDate: _date ?? today,
      firstDate: today,
      lastDate: today.add(const Duration(days: 365)),
      title: context.l10n.hostsCreateEventScreenTitleEventDate,
    );
    if (date != null && mounted) setState(() => _date = date);
  }

  Future<void> _pickStart() async {
    final time = await showCatchTimePicker(
      copy: catchTimePickerCopy(context.l10n),
      context: context,
      initialTime: _start ?? TimeOfDay.now(),
      title: context.l10n.hostsCreateEventScreenTitleStartTime,
    );
    if (time != null && mounted) setState(() => _start = time);
  }

  Future<void> _save() async {
    if (_saving) return;
    final pendingPayload = _submittedPayloadJson;
    if (_defaultsChanged && pendingPayload == null) {
      setState(() {
        _error = context.l10n.hostsPrivateEventDefaultsChanged;
      });
      return;
    }
    PrivateEventBasics? basics;
    if (pendingPayload != null) {
      try {
        basics = PrivateEventBasics.fromJson(
          Map<String, dynamic>.from(jsonDecode(pendingPayload) as Map),
        );
      } catch (_) {
        setState(() => _error = context.l10n.hostsPrivateEventPendingRequest);
        return;
      }
    } else {
      basics = _basics;
    }
    if (basics == null || !basics.isValid) {
      setState(() => _showErrors = true);
      return;
    }
    final signature = jsonEncode(basics.toJson());
    if (_submittedSignature != null && _submittedSignature != signature) {
      setState(() => _error = context.l10n.hostsPrivateEventPendingRequest);
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() {
      _saving = true;
      _error = null;
    });
    var requestSent = false;
    try {
      // Persist the exact idempotency key and body before the network call.
      // A lost response or app restart must resume this same operation.
      _submittedSignature = signature;
      _submittedPayloadJson = signature;
      await _persistDraft();
      requestSent = true;
      final receipt = await (widget.create ??
          ref.read(createEventDraftControllerProvider.notifier).createPrivateEvent)(
        organizerId: widget.club.id,
        requestId: _requestId,
        basics: basics,
      );
      if (!mounted) return;
      await _persistDraft(receipt: receipt);
      if (!mounted) return;
      setState(() => _receipt = receipt);
      widget.onSaved?.call(receipt);
    } catch (error) {
      if (!mounted) return;
      if (!requestSent) {
        _submittedSignature = null;
        _submittedPayloadJson = null;
      }
      // Even an authorization or validation response cannot prove this
      // request never committed: an earlier response may have been lost.
      // Keep the exact request and body until an authoritative receipt arrives.
      setState(
        () => _error = appErrorMessage(
          error,
          l10n: context.l10n,
          context: AppErrorContext.event,
        ),
      );
      showCatchErrorSnackBar(context, error);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _close() async {
    if (_saving) return;
    if (_receipt == null && _submittedPayloadJson != null) {
      final leave = await showCatchAdaptiveDialog<bool>(
        context: context,
        title: context.l10n.hostsPrivateEventPendingExitTitle,
        message: context.l10n.hostsPrivateEventPendingExitBody,
        actions: [
          CatchDialogAction(
            label: context.l10n.hostsPrivateEventPendingStay,
            value: false,
          ),
          CatchDialogAction(
            label: context.l10n.hostsPrivateEventPendingLeave,
            value: true,
            isDefault: true,
          ),
        ],
        barrierDismissible: false,
      );
      if (!mounted || leave != true) return;
      setState(() => _allowPop = true);
      Navigator.of(context).pop();
      return;
    }
    if (_receipt != null || !_hasChanges) {
      setState(() => _allowPop = true);
      Navigator.of(context).pop();
      return;
    }
    final decision = await showHostDraftExitDialog(context);
    if (!mounted || decision == null) return;
    switch (decision) {
      case HostDraftExitDecision.keepEditing:
        return;
      case HostDraftExitDecision.discardAndExit:
        setState(() => _allowPop = true);
        Navigator.of(context).pop();
        return;
      case HostDraftExitDecision.saveDraftAndExit:
        try {
          await _persistDraft();
          if (mounted) {
            setState(() => _allowPop = true);
            Navigator.of(context).pop();
          }
        } catch (error) {
          if (mounted) showCatchErrorSnackBar(context, error);
        }
    }
  }

  Future<void> _persistDraft({PrivateEventCreateReceipt? receipt}) async {
    final old = _activeDraft;
    final draft = (old ??
            EventDraft(
              id: _localDraftId,
              clubId: widget.club.id,
              savedAt: DateTime.now(),
            ))
        .copyWith(
          savedAt: DateTime.now(),
          name: _nameController.text.trim(),
          eventCityId: _city?.effectiveCityId,
          eventMarketId: _city?.effectiveMarketId,
          eventLocalDate: _date == null ? null : _localDate,
          eventLocalStartTime: _start == null ? null : _localStartTime,
          eventTimezone: _timezoneController.text.trim(),
          eventCityMode: _cityInherited ? 'inherit' : 'set',
          eventTimezoneMode: _timezoneInherited ? 'inherit' : 'set',
          eventReviewedDefaultsHash: _cityInherited || _timezoneInherited
              ? _organizerDefaultsHash
              : null,
          eventCreateRequestId: _requestId,
          eventCreatePayloadSignature: _submittedSignature,
          eventCreatePayloadJson: _submittedPayloadJson,
          eventCreateReceiptEventId:
              receipt?.eventId ?? old?.eventCreateReceiptEventId,
          eventCreateReceiptRevision:
              receipt?.setupRevision ?? old?.eventCreateReceiptRevision,
          selectedDateMillis: _date?.millisecondsSinceEpoch,
          selectedStartHour: _start?.hour,
          selectedStartMinute: _start?.minute,
        );
    await ref
        .read(createEventDraftControllerProvider.notifier)
        .saveDraft(draft);
    _activeDraft = draft;
    ref.invalidate(clubEventDraftsProvider(clubId: widget.club.id));
  }

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final receipt = _receipt;
    if (receipt != null) {
      return PrivateEventSetupScreen(
        club: widget.club,
        receipt: receipt,
        name: _nameController.text.trim(),
        date: _date!,
        start: _start!,
        cityLabel: _city?.label ?? widget.club.location,
        pendingRosterFileName: widget.initialRosterImportPlan?.fileName,
        onClose: _close,
      );
    }
    final fieldCopy = catchFieldCopy(context.l10n);
    final city = _city;
    final date = _date;
    final start = _start;
    final cityOptions = defaultCityOptions
        .where((option) => option.eventCreatable)
        .toList();

    return PopScope(
      canPop: _allowPop,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _close();
      },
      child: CatchScaffold.stepFlow(
        backgroundColor: t.bg,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CatchStepHeader(
              title: context.l10n.hostsHostEventsListLabelNewEvent,
              subtitle: widget.club.name,
              stepLabelBuilder: catchStepHeaderLabelBuilder(context.l10n),
              compactStepLabelBuilder:
                  catchStepHeaderCompactLabelBuilder(context.l10n),
              onBack: _saving ? null : _close,
              leadingType: CatchTopBarNavigationMode.back,
            ),
            Expanded(
              child: AbsorbPointer(
                absorbing: _saving || _submittedSignature != null,
                child: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: CatchLayout.hostCreateEventFormLaneMaxWidth,
                  ),
                  child: ListView(
                    padding: CatchInsets.formStepBodyWithBottomActions,
                    children: [
                      if (_defaultsChanged) ...[
                        CatchBanner.error(
                            message: context.l10n.hostsPrivateEventDefaultsChanged,
                        ),
                        CatchButton(
                          label: context.l10n.hostsPrivateEventReviewDefaults,
                          onPressed: _reviewCurrentDefaults,
                          variant: CatchButtonVariant.secondary,
                        ),
                        gapH4,
                      ],
                      if (_submittedSignature != null) ...[
                        CatchBanner.error(
                          message: context.l10n.hostsPrivateEventPendingRequest,
                        ),
                        gapH4,
                      ],
                      CatchSectionList(
                        emptyStateOmitted: true,
                        children: [
                          CatchSection.fieldRows(
                            first: true,
                            title: context.l10n.hostsPrivateEventBasicsHeading,
                            children: [
                              CatchField.input(
                                copy: fieldCopy,
                                key: const ValueKey('private-event-name'),
                                title: context
                                    .l10n.hostsEventDetailsStepTitleEventName,
                                contractExemption:
                                    'Private event first-save schema is owned by the event setup command.',
                                controller: _nameController,
                                inputHint: context
                                    .l10n.hostsEventDetailsStepPlaceholderEventName,
                                textCapitalization: TextCapitalization.words,
                                error: _showErrors &&
                                        _nameController.text.trim().isEmpty
                                    ? context.l10n
                                        .hostsEventDetailsStepVisiblecopyRequired
                                    : null,
                              ),
                              CatchField<CityOption>.control(
                                copy: fieldCopy,
                                key: const ValueKey('private-event-city'),
                                title: context.l10n.hostsPrivateEventCity,
                                contractExemption:
                                    'Private event city is validated by the event setup command.',
                                body: _cityInherited
                                    ? '${city?.label ?? widget.club.location} · ${context.l10n.hostsPrivateEventFromOrganizer}'
                                    : city?.label ??
                                        context.l10n.hostsPrivateEventChooseCity,
                                child: CatchChoiceInput<CityOption>(
                                  values: cityOptions,
                                  itemLabelBuilder: (option) => option.label,
                                  selected: city == null
                                      ? const <CityOption>{}
                                      : {city},
                                  mode: CatchChipMode.single,
                                  autoClose: true,
                                  onChanged: (selection) {
                                    if (selection.isEmpty) return;
                                    final picked = selection.single;
                                    setState(() {
                                      _city = picked;
                                      _cityInherited = false;
                                      _timezoneController.text = picked.timeZone;
                                      _timezoneInherited = false;
                                    });
                                  },
                                ),
                                disclosureMode: _cityAccordion.isExpanded('city')
                                    ? CatchFieldMode.controlledExpanded
                                    : CatchFieldMode.controlledCollapsed,
                                onOpenChanged: (open) {
                                  if (open) {
                                    _cityAccordion.toggle('city');
                                  } else {
                                    _cityAccordion.collapse();
                                  }
                                },
                                icon: CatchIcons.locationOnOutlined,
                                error: _showErrors && city == null &&
                                        !_cityInherited
                                    ? context.l10n.hostsPrivateEventChooseCity
                                    : null,
                              ),
                              if (!_cityInherited &&
                                  widget.club.locationCityId.isNotEmpty)
                                CatchField.action(
                                  copy: fieldCopy,
                                  title: context.l10n.hostsPrivateEventUseOrganizerCity,
                                  body: widget.club.location,
                                  onTap: _restoreOrganizerCity,
                                ),
                              CatchField.nav(
                                copy: fieldCopy,
                                key: const ValueKey('private-event-date'),
                                title: context.l10n.hostsWhenStepLabelDate,
                                body: date == null
                                    ? context
                                        .l10n.hostsWhenStepPlaceholderSelectADate
                                    : MaterialLocalizations.of(context)
                                        .formatMediumDate(date),
                                icon: CatchIcons.calendarTodayOutlined,
                                error: _showErrors && date == null
                                    ? context.l10n
                                        .hostsWhenStepVisiblecopyPleaseSelectADate
                                    : null,
                                onTap: _saving ? null : _pickDate,
                              ),
                              CatchField.nav(
                                copy: fieldCopy,
                                key: const ValueKey('private-event-start'),
                                title: context.l10n.hostsWhenStepLabelStartTime,
                                body: start == null
                                    ? context.l10n
                                        .hostsWhenStepPlaceholderSelectStartTime
                                    : start.format(context),
                                icon: CatchIcons.scheduleOutlined,
                                error: _showErrors && start == null
                                    ? context.l10n.hostsWhenStepVisiblecopyRequired
                                    : null,
                                onTap: _saving ? null : _pickStart,
                              ),
                              CatchField.input(
                                copy: fieldCopy,
                                key: const ValueKey('private-event-timezone'),
                                title: context.l10n.hostsPrivateEventTimezone,
                                contractExemption:
                                    'Private event IANA timezone schema is pending generated constraints.',
                                controller: _timezoneController,
                                inputHint: context.l10n.hostsPrivateEventTimezoneHint,
                                helperText: context.l10n.hostsPrivateEventTimezoneSuggestion,
                                onChanged: (_) {
                                  if (_timezoneInherited) {
                                    setState(() => _timezoneInherited = false);
                                  }
                                },
                                error: _showErrors &&
                                        _timezoneController.text.trim().isEmpty &&
                                        !_timezoneInherited
                                    ? context.l10n
                                        .hostsWhenStepVisiblecopyRequired
                                    : null,
                              ),
                              if (_timezoneInherited)
                                CatchField.read(
                                  copy: fieldCopy,
                                  title: context.l10n.hostsPrivateEventFromOrganizer,
                                  body: widget.club.hostDefaults.timezone,
                                )
                              else if (widget.club.hostDefaults.timezone != null)
                                CatchField.action(
                                  copy: fieldCopy,
                                  title: context.l10n.hostsPrivateEventUseOrganizerTimezone,
                                  body: widget.club.hostDefaults.timezone,
                                  onTap: _restoreOrganizerTimezone,
                                ),
                              CatchField.nav(
                                copy: fieldCopy,
                                title: context.l10n.hostsPrivateEventMoreBasics,
                                body: context.l10n.hostsPrivateEventMoreBasicsBody,
                                icon: CatchIcons.tuneRounded,
                                onTap: () => setState(
                                  () => _moreBasicsOpen = !_moreBasicsOpen,
                                ),
                              ),
                              if (_moreBasicsOpen)
                                CatchField.read(
                                  copy: fieldCopy,
                                  title: context.l10n.hostsPrivateEventAfterSave,
                                  body: context.l10n.hostsPrivateEventAfterSaveBody,
                                ),
                            ],
                          ),
                        ],
                      ),
                      gapH4,
                      Text(
                        context.l10n.hostsPrivateEventSaveHint,
                        style: Theme.of(context)
                            .textTheme.bodyMedium?.copyWith(color: t.ink2),
                      ),
                      if (_error != null) ...[
                        gapH4,
                        CatchBanner.error(message: _error!),
                      ],
                    ],
                  ),
                ),
                ),
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: CatchInsets.pageBodyTight,
                child: CatchButton(
                  key: const ValueKey('private-event-save'),
                  label: _submittedSignature == null
                      ? context.l10n.hostsPrivateEventSaveContinue
                      : context.l10n.hostsPrivateEventRetrySave,
                  onPressed: _saving ? null : _save,
                  status: _saving
                      ? CatchButtonStatus.loading
                      : CatchButtonStatus.idle,
                  fullWidth: true,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _newRequestId() {
  final random = Random.secure();
  return List<int>.generate(24, (_) => random.nextInt(256))
      .map((value) => value.toRadixString(16).padLeft(2, '0'))
      .join();
}
