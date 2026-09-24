import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/core/app_error_context.dart' as app_ops;
import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/city_catalog.dart';
import 'package:catch_dating_app/core/firebase_providers.dart';
import 'package:catch_dating_app/core/presentation/catch_ui_copy.dart';
import 'package:catch_dating_app/core/riverpod_ui/catch_notice_controller.dart';
import 'package:catch_dating_app/core/riverpod_ui/catch_error_snack_bar.dart';
import 'package:catch_dating_app/events/data/event_draft_repository.dart';
import 'package:catch_dating_app/events/domain/event_draft.dart';
import 'package:catch_dating_app/exceptions/app_exception.dart';
import 'package:catch_dating_app/exceptions/error_logger.dart';
import 'package:catch_dating_app/hosts/data/manager_event_setup_defaults_repository.dart';
import 'package:catch_dating_app/hosts/data/private_event_details_repository.dart';
import 'package:catch_dating_app/hosts/data/private_event_preferences_repository.dart';
import 'package:catch_dating_app/hosts/data/private_event_setup_repository.dart';
import 'package:catch_dating_app/hosts/domain/host_roster_import.dart';
import 'package:catch_dating_app/hosts/events/presentation/host_event_entry_sheet.dart';
import 'package:catch_dating_app/hosts/events/presentation/host_event_entry_state.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/create/create_event_draft_controller.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/create/create_event_prefill.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/create/private_event_draft_restore.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/create/private_event_details_controller.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/create/private_event_details_screen.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/create/private_event_preferences_controller.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/create/private_event_preferences_screen.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/create/private_event_setup_screen.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/host_create_event_route_loading_screen.dart';
import 'package:catch_dating_app/hosts/presentation/widgets/host_draft_exit_dialog.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'private_event_create_body.dart';

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
    this.initialSavedEventId,
    this.create,
    this.update,
    this.readSaved,
    this.readOrganizerDefaults,
    this.onSaved,
  }) : assert(
         initialSavedEventId == null ||
             (initialDraft == null && initialPrefill == null),
         'A saved private event cannot also start from a draft or repeat.',
       );

  final Club club;
  final EventDraft? initialDraft;
  final CreateEventPrefill? initialPrefill;
  final HostRosterImportPlan? initialRosterImportPlan;
  final bool promptForDraftsOnStart;
  final String? initialSavedEventId;
  final CreatePrivateEvent? create;
  final UpdatePrivateEventBasics? update;
  final ReadPrivateEventBasics? readSaved;
  final ReadPrivateEventOrganizerDefaults? readOrganizerDefaults;
  final ValueChanged<PrivateEventCreateReceipt>? onSaved;

  @override
  ConsumerState<PrivateEventCreateScreen> createState() =>
      _PrivateEventCreateScreenState();
}

class _PrivateEventCreateScreenState
    extends ConsumerState<PrivateEventCreateScreen> {
  // The body lives in a Dart extension; State.setState is protected there.
  void _mutateScreenState(VoidCallback update) => setState(update);
  final _nameController = TextEditingController();
  final _timezoneController = TextEditingController();
  final _cityAccordion = CatchAccordionController();
  DateTime? _date;
  TimeOfDay? _start;
  CityOption? _city;
  bool _cityInherited = false;
  bool _timezoneInherited = false;
  PrivateEventCreateReceipt? _receipt;
  PrivateEventBasics? _savedBasics;
  EventSetupCity? _savedCity;
  String? _savedCityLabel;
  PrivateEventBasicsUpdateRequest? _pendingUpdate;
  bool _editingSavedBasics = false;
  bool _editingPreferences = false;
  PrivateEventPreferencesController? _preferencesController;
  bool _editingDetails = false;
  PrivateEventDetailsController? _detailsController;
  bool _loadingSavedEvent = false;
  bool _canEditSavedBasics = true;
  String? _readError;
  ManagerEventSetupDefaults? _managerDefaults;
  bool _loadingManagerDefaults = false;
  String? _managerDefaultsError;
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
  bool _trustedOrganizerDefaultsReadAvailable() => _managerDefaults != null;

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
      _date = restoredPrivateEventDate(
        startingValues,
        rejectPast: savedId == null,
      );
      _start = restoredPrivateEventStart(startingValues);
    }
    for (final option in defaultCityOptions) {
      if (_city == null &&
          option.effectiveCityId == widget.club.locationCityId &&
          option.effectiveMarketId == widget.club.locationMarketId) {
        _city = option;
        if (_timezoneController.text.isEmpty) {
          _timezoneController.text = option.timeZone;
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
    if (widget.readOrganizerDefaults != null) {
      _loadingManagerDefaults = true;
      WidgetsBinding.instance.addPostFrameCallback((_) =>
          unawaited(_PrivateEventCreateBody(this)._loadOrganizerDefaults()));
    }
    if (widget.initialSavedEventId != null) {
      _loadingSavedEvent = true;
      WidgetsBinding.instance.addPostFrameCallback((_) =>
          _PrivateEventCreateBody(this)._loadSavedEvent());
    } else if (_receipt != null) {
      _savedCity = _city == null
          ? null
          : EventSetupCity(
              cityId: _city!.effectiveCityId,
              marketId: _city!.effectiveMarketId,
            );
      _savedBasics = _currentExplicitBasics;
      _loadingSavedEvent = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final savedId = _receipt?.eventId;
        if (mounted && savedId != null) {
          unawaited(_PrivateEventCreateBody(this)._loadSavedEvent(
            savedEventId: savedId,
          ));
        }
      });
    }
    if (widget.promptForDraftsOnStart &&
        widget.initialSavedEventId == null &&
        widget.initialDraft == null &&
        widget.initialPrefill == null &&
        widget.initialRosterImportPlan == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) =>
          _PrivateEventCreateBody(this)._checkForDrafts());
    }
  }

  @override
  void dispose() {
    _preferencesController?.removeListener(_refresh);
    _preferencesController?.dispose();
    _detailsController?.removeListener(_refresh);
    _detailsController?.dispose();
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
    final savedCity = _savedCity;
    if ((city == null && savedCity == null && !_cityInherited) ||
        _date == null ||
        _start == null) {
      return null;
    }
    return PrivateEventBasics(
      name: _nameController.text,
      city: _cityInherited
          ? const EventSetupValue.inherit()
          : EventSetupValue.set(
              city == null
                  ? savedCity!
                  : EventSetupCity(
                      cityId: city.effectiveCityId,
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

  PrivateEventBasics? get _currentExplicitBasics {
    final city = _city == null
        ? _savedCity
        : EventSetupCity(
            cityId: _city!.effectiveCityId,
            marketId: _city!.effectiveMarketId,
          );
    if (city == null || _date == null || _start == null ||
        _timezoneController.text.trim().isEmpty) {
      return null;
    }
    return PrivateEventBasics(
      name: _nameController.text,
      city: EventSetupValue.set(city),
      localDate: _localDate,
      localStartTime: _localStartTime,
      timezone: EventSetupValue.set(_timezoneController.text),
    );
  }

  void _applyExplicitBasics(PrivateEventBasics basics) {
    final city = basics.city.value;
    if (city != null) {
      _savedCity = city;
      _city = defaultCityOptions.where((option) =>
          option.effectiveCityId == city.cityId &&
          option.effectiveMarketId == city.marketId).firstOrNull;
      _savedCityLabel = _city?.label ?? city.cityId;
    }
    _nameController.text = basics.name;
    _timezoneController.text = basics.timezone.value ?? '';
    _date = DateTime.tryParse(basics.localDate);
    final parts = basics.localStartTime.split(':');
    _start = TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
    _cityInherited = false;
    _timezoneInherited = false;
    _defaultsChanged = false;
  }

  String get _organizerDefaultsHash =>
      _managerDefaults?.basicsReviewedHash ?? '';

  void _restoreOrganizerCity() {
    final defaults = _managerDefaults;
    if (defaults?.cityId == null || defaults?.marketId == null) {
      return;
    }
    setState(() {
      _cityInherited = _trustedOrganizerDefaultsReadAvailable();
      for (final option in defaultCityOptions) {
        if (option.effectiveCityId == defaults!.cityId &&
            option.effectiveMarketId == defaults.marketId) {
          _city = option;
          break;
        }
      }
      _savedCity = EventSetupCity(
        cityId: defaults!.cityId!, marketId: defaults.marketId!,
      );
    });
  }

  void _restoreOrganizerTimezone() {
    final inherited = _managerDefaults?.timezone;
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
      _defaultsChanged = (_cityInherited && _managerDefaults?.cityId == null) ||
          (_timezoneInherited && _managerDefaults?.timezone == null);
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
      initialDate: _date != null && !_date!.isBefore(today) ? _date! : today,
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

  @override
  Widget build(BuildContext context) {
    if (_loadingManagerDefaults) {
      return const HostCreateEventRouteLoadingScreen();
    }
    if (_managerDefaultsError != null) {
      return CatchScaffold.stepFlow(
        body: CatchErrorState(
          title: context.l10n.hostsEventDefaultsManagerUnavailable,
          message: _managerDefaultsError!,
          retryLabel: context.l10n.hostsPrivateEventRetryDefaultsRead,
          onRetry: () => unawaited(
            _PrivateEventCreateBody(this)._loadOrganizerDefaults(),
          ),
          actions: const [CatchErrorBackButton()],
        ),
      );
    }
    final t = CatchTokens.of(context);
    final receipt = _receipt;
    if (_loadingSavedEvent) {
      return const HostCreateEventRouteLoadingScreen();
    }
    if (_readError != null) {
      return CatchScaffold.stepFlow(
        body: CatchErrorState(
          title: context.l10n.hostsHostCreateEventScreenTitleEventSetupUnavailable,
          message: _readError!,
          actions: const [CatchErrorBackButton()],
        ),
      );
    }
    if (_editingPreferences && _preferencesController != null) {
      return PrivateEventPreferencesScreen(
        controller: _preferencesController!,
        onBack: _PrivateEventCreateBody(this)._closePreferences,
      );
    }
    if (_editingDetails && _detailsController != null) {
      return PrivateEventDetailsScreen(
        controller: _detailsController!,
        onBack: _PrivateEventCreateBody(this)._closeDetails,
      );
    }
    if (receipt != null && !_editingSavedBasics) {
      return PrivateEventSetupScreen(
        club: widget.club,
        receipt: receipt,
        name: _nameController.text.trim(),
        date: _date!,
        start: _start!,
        cityLabel: _city?.label ?? _savedCityLabel ?? widget.club.location,
        pendingRosterFileName: widget.initialRosterImportPlan?.fileName,
        onEditBasics: _canEditSavedBasics
            ? () => setState(() => _editingSavedBasics = true)
            : null,
        onEditPayments: _canEditSavedBasics
            ? () => _PrivateEventCreateBody(this)._openPreferences()
            : null,
        onEditDetails: _canEditSavedBasics
            ? () => _PrivateEventCreateBody(this)._openDetails()
            : null,
        onClose: _PrivateEventCreateBody(this)._close,
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
        if (!didPop) _PrivateEventCreateBody(this)._close();
      },
      child: CatchScaffold.stepFlow(
        backgroundColor: t.bg,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CatchStepHeader(
              title: receipt == null
                  ? context.l10n.hostsHostEventsListLabelNewEvent
                  : context.l10n.hostsPrivateEventEditBasics,
              subtitle: widget.club.name,
              stepLabelBuilder: catchStepHeaderLabelBuilder(context.l10n),
              compactStepLabelBuilder:
                  catchStepHeaderCompactLabelBuilder(context.l10n),
              onBack: _saving ? null : _PrivateEventCreateBody(this)._close,
              leadingType: CatchTopBarNavigationMode.back,
            ),
            Expanded(
              child: AbsorbPointer(
                absorbing: _saving ||
                    (receipt == null
                        ? _submittedSignature != null
                        : _pendingUpdate != null),
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
                      if (receipt == null && _submittedSignature != null) ...[
                        CatchBanner.error(
                          message: context.l10n.hostsPrivateEventPendingRequest,
                        ),
                        gapH4,
                      ],
                      if (_pendingUpdate != null) ...[
                        CatchBanner.error(
                          message: context.l10n.hostsPrivateEventPendingUpdate,
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
                                    : city?.label ?? _savedCityLabel ??
                                        context.l10n.hostsPrivateEventChooseCity,
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
                                        _savedCity == null &&
                                        !_cityInherited
                                    ? context.l10n.hostsPrivateEventChooseCity
                                    : null,
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
                              ),
                              if (!_cityInherited &&
                                  _managerDefaults?.cityId != null)
                                CatchField.action(
                                  copy: fieldCopy,
                                  title: context.l10n.hostsPrivateEventUseOrganizerCity,
                                  body: _city?.label ?? widget.club.location,
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
                                  body: _managerDefaults?.timezone,
                                )
                              else if (_managerDefaults?.timezone != null)
                                CatchField.action(
                                  copy: fieldCopy,
                                  title: context.l10n.hostsPrivateEventUseOrganizerTimezone,
                                  body: _managerDefaults?.timezone,
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
                  label: receipt != null
                      ? (_pendingUpdate == null
                          ? context.l10n.hostsEventEditSaveChanges
                          : context.l10n.hostsPrivateEventRetrySave)
                      : (_submittedSignature == null
                          ? context.l10n.hostsPrivateEventSaveContinue
                          : context.l10n.hostsPrivateEventRetrySave),
                  onPressed: _saving ||
                          (receipt != null && !_canEditSavedBasics)
                      ? null
                      : _PrivateEventCreateBody(this)._save,
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
