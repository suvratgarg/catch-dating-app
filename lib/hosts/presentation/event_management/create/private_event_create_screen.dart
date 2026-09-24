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
import 'package:catch_dating_app/hosts/presentation/event_management/host_create_event_route_loading_screen.dart';
import 'package:catch_dating_app/hosts/presentation/widgets/host_draft_exit_dialog.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'private_event_create_body.dart';

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
    this.initialSavedEventId,
    this.create,
    this.update,
    this.readSaved,
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
  PrivateEventBasics? _savedBasics;
  EventSetupCity? _savedCity;
  String? _savedCityLabel;
  PrivateEventBasicsUpdateRequest? _pendingUpdate;
  bool _editingSavedBasics = false;
  bool _loadingSavedEvent = false;
  bool _canEditSavedBasics = true;
  String? _readError;
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
    if (widget.initialSavedEventId != null) {
      _loadingSavedEvent = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadSavedEvent());
    } else if (_receipt != null) {
      _savedCity = _city == null
          ? null
          : EventSetupCity(
              cityId: _city!.effectiveCityId,
              marketId: _city!.effectiveMarketId,
            );
      _savedBasics = _currentExplicitBasics;
      _loadingSavedEvent = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadPendingUpdate());
    }
    if (widget.promptForDraftsOnStart &&
        widget.initialSavedEventId == null &&
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
    _savedCity = _city == null
        ? null
        : EventSetupCity(
            cityId: _city!.effectiveCityId,
            marketId: _city!.effectiveMarketId,
          );
    _savedBasics = _receipt == null ? null : _currentExplicitBasics;
    _pendingUpdate = null;
    _editingSavedBasics = false;
    if (_receipt != null) {
      _loadingSavedEvent = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadPendingUpdate());
    }
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

  Future<void> _loadSavedEvent() async {
    final eventId = widget.initialSavedEventId!;
    try {
      final controller = ref.read(createEventDraftControllerProvider.notifier);
      final summary = await (widget.readSaved ?? controller.getPrivateEventSetup)(
        organizerId: widget.club.id,
        eventId: eventId,
      );
      if (!mounted) return;
      if (summary.eventId != eventId || summary.organizerId != widget.club.id) {
        throw const FormatException('Private event read changed identity');
      }
      final basics = PrivateEventBasics(
        name: summary.name,
        city: EventSetupValue.set(summary.city),
        localDate: summary.localDate,
        localStartTime: summary.localStartTime,
        timezone: EventSetupValue.set(summary.timezone),
      );
      final drafts = await controller.loadDrafts(clubId: widget.club.id);
      if (!mounted) return;
      _activeDraft = drafts.where((draft) =>
          draft.eventCreateReceiptEventId == eventId).firstOrNull;
      _localDraftId = _activeDraft?.id ?? 'private-event-$eventId';
      _requestId = _activeDraft?.eventCreateRequestId ?? _requestId;
      _submittedSignature = _activeDraft?.eventCreatePayloadSignature;
      _submittedPayloadJson = _activeDraft?.eventCreatePayloadJson;
      setState(() {
        _applyExplicitBasics(basics);
        _receipt = PrivateEventCreateReceipt(
          eventId: summary.eventId,
          setupRevision: summary.setupRevision,
          replayed: true,
        );
        _savedBasics = basics;
        _canEditSavedBasics = summary.canEditBasics;
      });
      await _loadPendingUpdate();
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _readError = appErrorMessage(
          error,
          l10n: context.l10n,
          context: AppErrorContext.event,
        );
        _loadingSavedEvent = false;
      });
    }
  }

  Future<void> _loadPendingUpdate() async {
    final receipt = _receipt;
    if (receipt == null) return;
    try {
      final pending = await ref
          .read(createEventDraftControllerProvider.notifier)
          .loadPendingBasicsUpdate(
            organizerId: widget.club.id,
            eventId: receipt.eventId,
          );
      if (!mounted) return;
      setState(() {
        _pendingUpdate = pending;
        _editingSavedBasics = pending != null;
        if (pending != null &&
            pending.basics.city.mode == EventSetupValueMode.set &&
            pending.basics.timezone.mode == EventSetupValueMode.set) {
          _applyExplicitBasics(pending.basics);
        }
        _loadingSavedEvent = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _readError = appErrorMessage(
          error,
          l10n: context.l10n,
          context: AppErrorContext.event,
        );
        _loadingSavedEvent = false;
      });
    }
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

  Future<void> _save() async {
    if (_saving) return;
    if (_receipt != null) {
      await _saveUpdate();
      return;
    }
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
      setState(() {
        _receipt = receipt;
        _savedBasics = _currentExplicitBasics;
      });
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

  Future<void> _saveUpdate() async {
    final receipt = _receipt;
    if (receipt == null || !_canEditSavedBasics) return;
    final existing = _pendingUpdate;
    final basics = existing?.basics ?? _basics;
    if (basics == null || !basics.isValid) {
      setState(() => _showErrors = true);
      return;
    }
    if (existing == null &&
        jsonEncode(basics.toJson()) == jsonEncode(_savedBasics?.toJson())) {
      setState(() => _editingSavedBasics = false);
      return;
    }
    final request = existing ?? PrivateEventBasicsUpdateRequest(
      organizerId: widget.club.id,
      eventId: receipt.eventId,
      requestId: _newRequestId(),
      expectedSetupRevision: receipt.setupRevision,
      basics: basics,
    );
    FocusScope.of(context).unfocus();
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      // The journal write must finish before any network attempt. Every
      // subsequent attempt reuses its complete command, even after a lost
      // response, a restart, or an intervening authorization failure.
      if (existing == null) {
        await ref
            .read(createEventDraftControllerProvider.notifier)
            .savePendingBasicsUpdate(request);
        _pendingUpdate = request;
      }
      final updated = await (widget.update ?? ref
              .read(createEventDraftControllerProvider.notifier)
              .updatePrivateEventBasics)(request);
      if (!mounted) return;
      if (updated.eventId != request.eventId) {
        throw const FormatException('Basics update changed event identity');
      }
      await _persistDraft(receipt: updated);
      if (!mounted) return;
      await ref
          .read(createEventDraftControllerProvider.notifier)
          .clearPendingBasicsUpdate(request);
      if (!mounted) return;
      setState(() {
        _receipt = updated;
        _savedBasics = _currentExplicitBasics;
        _pendingUpdate = null;
        _editingSavedBasics = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = appErrorMessage(
        error,
        l10n: context.l10n,
        context: AppErrorContext.event,
      ));
      showCatchErrorSnackBar(context, error);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _close() async {
    if (_saving) return;
    if (_pendingUpdate != null ||
        (_receipt == null && _submittedPayloadJson != null)) {
      final leave = await showCatchAdaptiveDialog<bool>(
        context: context,
        title: context.l10n.hostsPrivateEventPendingExitTitle,
        message: _pendingUpdate == null
            ? context.l10n.hostsPrivateEventPendingExitBody
            : context.l10n.hostsPrivateEventPendingUpdateExitBody,
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
    if (_editingSavedBasics) {
      final saved = _savedBasics;
      setState(() {
        if (saved != null) _applyExplicitBasics(saved);
        _editingSavedBasics = false;
        _error = null;
        _showErrors = false;
      });
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
          eventCityId: _city?.effectiveCityId ?? _savedCity?.cityId,
          eventMarketId: _city?.effectiveMarketId ?? _savedCity?.marketId,
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
  Widget build(BuildContext context) =>
      _PrivateEventCreateBody(this)._buildPrivateEventCreateBody(context);

}
