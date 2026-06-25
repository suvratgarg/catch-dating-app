import 'dart:async';

import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/clubs/data/clubs_repository.dart';
import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/business_rules.dart';
import 'package:catch_dating_app/core/city_catalog.dart';
import 'package:catch_dating_app/core/country_markets.dart';
import 'package:catch_dating_app/core/device_location.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/time_formatters.dart';
import 'package:catch_dating_app/core/widgets/catch_adaptive_picker.dart';
import 'package:catch_dating_app/core/widgets/catch_badge.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_error_banner.dart';
import 'package:catch_dating_app/core/widgets/catch_error_snackbar.dart';
import 'package:catch_dating_app/core/widgets/catch_error_state.dart';
import 'package:catch_dating_app/core/widgets/catch_select_chip.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/core/widgets/catch_text_field.dart';
import 'package:catch_dating_app/core/widgets/catch_toggle.dart';
import 'package:catch_dating_app/core/widgets/catch_top_bar.dart';
import 'package:catch_dating_app/event_policies/domain/event_policy.dart';
import 'package:catch_dating_app/event_policies/domain/event_policy_defaults.dart';
import 'package:catch_dating_app/events/data/event_participation_repository.dart';
import 'package:catch_dating_app/events/data/event_repository.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/presentation/event_booking_controller.dart';
import 'package:catch_dating_app/events/presentation/event_formatters.dart';
import 'package:catch_dating_app/events/presentation/location_picker_screen.dart';
import 'package:catch_dating_app/events/presentation/widgets/map_pin_tile.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/create/create_event_form_keys.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/widgets/event_policy_step.dart';
import 'package:catch_dating_app/hosts/presentation/widgets/field_label.dart';
import 'package:catch_dating_app/hosts/presentation/widgets/host_loading_skeletons.dart';
import 'package:catch_dating_app/hosts/presentation/widgets/picker_tile.dart';
import 'package:catch_dating_app/locations/domain/location_coordinate.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/experimental/mutation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract final class EditHostedEventKeys {
  static const saveButton = ValueKey('edit-hosted-event-save-button');
}

class EditHostedEventRouteScreen extends ConsumerWidget {
  const EditHostedEventRouteScreen({
    super.key,
    required this.clubId,
    required this.eventId,
    this.initialEvent,
  });

  final String clubId;
  final String eventId;
  final Event? initialEvent;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uidAsync = ref.watch(uidProvider);
    final clubAsync = ref.watch(fetchClubProvider(clubId));
    final eventAsync = ref.watch(watchEventProvider(eventId));

    final state = HostEventEditState.resolve(
      uid: uidAsync,
      club: clubAsync,
      event: eventAsync,
      initialEvent: initialEvent,
    );

    return switch (state.status) {
      HostEventEditRouteStatus.loading => Scaffold(
        backgroundColor: CatchTokens.of(context).bg,
        appBar: const CatchTopBar(title: 'Edit event', border: true),
        body: const SafeArea(child: HostRouteLoadingBody(showTabRail: true)),
      ),
      HostEventEditRouteStatus.error => CatchErrorScaffold.fromError(
        state.error!,
        context: AppErrorContext.event,
        onRetry: () {
          ref.invalidate(fetchClubProvider(clubId));
          ref.invalidate(watchEventProvider(eventId));
        },
      ),
      HostEventEditRouteStatus.notFound => const CatchErrorScaffold(
        title: 'Event not found',
        message: 'This hosted event is no longer available.',
      ),
      HostEventEditRouteStatus.unauthorized => CatchErrorScaffold(
        title: 'Action unavailable',
        message: 'You can edit only events that you host.',
        icon: CatchIcons.blockRounded,
      ),
      HostEventEditRouteStatus.ready => EditHostedEventScreen(
        club: state.club!,
        event: state.event!,
      ),
    };
  }
}

enum HostEventEditRouteStatus { loading, error, notFound, unauthorized, ready }

@immutable
class HostEventEditState {
  const HostEventEditState({
    required this.status,
    this.uid,
    this.club,
    this.event,
    this.error,
  });

  final HostEventEditRouteStatus status;
  final String? uid;
  final Club? club;
  final Event? event;
  final Object? error;

  factory HostEventEditState.resolve({
    required AsyncValue<String?> uid,
    required AsyncValue<Club?> club,
    required AsyncValue<Event?> event,
    Event? initialEvent,
  }) {
    final resolvedEvent = event.asData?.value ?? initialEvent;
    if (uid.isLoading ||
        club.isLoading ||
        (event.isLoading && resolvedEvent == null)) {
      return const HostEventEditState(status: HostEventEditRouteStatus.loading);
    }

    final error = uid.error ?? club.error ?? event.error;
    if (error != null) {
      return HostEventEditState(
        status: HostEventEditRouteStatus.error,
        error: error,
      );
    }

    final resolvedUid = uid.asData?.value;
    final resolvedClub = club.asData?.value;
    if (resolvedClub == null || resolvedEvent == null) {
      return HostEventEditState(
        status: HostEventEditRouteStatus.notFound,
        uid: resolvedUid,
        club: resolvedClub,
        event: resolvedEvent,
      );
    }

    if (resolvedUid == null || !resolvedClub.isHostedBy(resolvedUid)) {
      return HostEventEditState(
        status: HostEventEditRouteStatus.unauthorized,
        uid: resolvedUid,
        club: resolvedClub,
        event: resolvedEvent,
      );
    }

    return HostEventEditState(
      status: HostEventEditRouteStatus.ready,
      uid: resolvedUid,
      club: resolvedClub,
      event: resolvedEvent,
    );
  }

  static bool eventCanEdit(Event event) => !event.isCancelled;

  static bool eventScheduleLocked(Event event, DateTime now) =>
      !eventCanEdit(event) ||
      event.startTime.isBefore(now) ||
      event.signedUpCount > 0 ||
      event.waitlistCount > 0 ||
      event.attendedCount > 0;

  static bool eventPolicyLocked(Event event, DateTime now) =>
      eventScheduleLocked(event, now);
}

class EditHostedEventScreen extends ConsumerStatefulWidget {
  const EditHostedEventScreen({
    super.key,
    required this.club,
    required this.event,
    this.now,
    this.loadMapTiles = true,
    this.formAutovalidateMode = AutovalidateMode.disabled,
  });

  final Club club;
  final Event event;
  final DateTime Function()? now;
  final bool loadMapTiles;
  final AutovalidateMode formAutovalidateMode;

  @override
  ConsumerState<EditHostedEventScreen> createState() =>
      _EditHostedEventScreenState();
}

class _EditHostedEventScreenState extends ConsumerState<EditHostedEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dateController = TextEditingController();
  final _startTimeController = TextEditingController();
  final _meetingPointController = TextEditingController();
  final _locationDetailsController = TextEditingController();
  final _distanceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _capacityController = TextEditingController();
  final _priceController = TextEditingController();
  final _minAgeController = TextEditingController();
  final _maxAgeController = TextEditingController();
  final _maxMenController = TextEditingController();
  final _maxWomenController = TextEditingController();
  final _inviteCodeController = TextEditingController();
  final _dynamicPricingStepController = TextEditingController();
  final _dynamicPricingMaxController = TextEditingController();

  late DateTime _selectedDate;
  late TimeOfDay _selectedStartTime;
  late int _durationMinutes;
  late LocationCoordinate? _startingPoint;
  String? _meetingLocationAddress;
  String? _meetingLocationPlaceId;
  late PaceLevel _selectedPace;
  late EventAdmissionPreset _selectedAdmissionPreset;
  late bool _cohortCapsEnabled;
  late bool _dynamicPricingEnabled;
  late EventCancellationPolicyId _selectedCancellationPolicyId;
  bool _loadedPrivateAccess = false;
  String? _scheduleErrorText;

  DateTime get _now => widget.now?.call() ?? DateTime.now();
  bool get _canEdit => HostEventEditState.eventCanEdit(widget.event);

  bool get _scheduleLocked =>
      HostEventEditState.eventScheduleLocked(widget.event, _now);

  bool get _policyLocked =>
      HostEventEditState.eventPolicyLocked(widget.event, _now);

  DateTime get _selectedStartDateTime => DateTime(
    _selectedDate.year,
    _selectedDate.month,
    _selectedDate.day,
    _selectedStartTime.hour,
    _selectedStartTime.minute,
  );

  @override
  void initState() {
    super.initState();
    final event = widget.event;
    final meetingLocation = event.effectiveMeetingLocation;
    _selectedDate = DateUtils.dateOnly(event.startTime);
    _selectedStartTime = TimeOfDay.fromDateTime(event.startTime);
    _durationMinutes = event.endTime.difference(event.startTime).inMinutes;
    _startingPoint = event.hasExactStartingPoint
        ? LocationCoordinate(
            event.effectiveStartingPointLat!,
            event.effectiveStartingPointLng!,
          )
        : null;
    _meetingLocationAddress = meetingLocation?.address;
    _meetingLocationPlaceId = meetingLocation?.placeId;
    _selectedPace = event.pace;

    _dateController.text = _formatDate(_selectedDate);
    _startTimeController.text = AppTimeFormatters.clockTime(
      hour: _selectedStartTime.hour,
      minute: _selectedStartTime.minute,
    );
    _meetingPointController.text = event.locationName;
    _locationDetailsController.text = event.locationNotes ?? '';
    _distanceController.text = EventFormatters.distanceKm(
      event.distanceKm,
      includeUnit: false,
    );
    _descriptionController.text = event.description;
    _capacityController.text = event.capacityLimit.toString();
    _priceController.text = _minorUnitsText(
      event.priceInPaise,
      currencyCode: event.currency,
    );
    _minAgeController.text = event.constraints.minAge == 0
        ? ''
        : event.constraints.minAge.toString();
    _maxAgeController.text = event.constraints.maxAge == 99
        ? ''
        : event.constraints.maxAge.toString();
    _maxMenController.text = event.constraints.maxMen?.toString() ?? '';
    _maxWomenController.text = event.constraints.maxWomen?.toString() ?? '';
    final policy = event.effectiveEventPolicy;
    _selectedAdmissionPreset = _admissionPresetFor(policy);
    _cohortCapsEnabled = policy.usesFixedCohortCaps;
    _dynamicPricingEnabled = policy.usesDemandPricing;
    final demandRules = policy.pricingPolicy.demandPricingRules;
    final demandRule = demandRules.isEmpty ? null : demandRules.first;
    _dynamicPricingStepController.text = _minorUnitsText(
      demandRule?.stepAdjustment.inPaise,
      currencyCode: event.currency,
    );
    _dynamicPricingMaxController.text = _minorUnitsText(
      demandRule?.maxAdjustment.inPaise,
      currencyCode: event.currency,
    );
    _selectedCancellationPolicyId = policy.cancellationPolicy.id;
  }

  @override
  void dispose() {
    _dateController.dispose();
    _startTimeController.dispose();
    _meetingPointController.dispose();
    _locationDetailsController.dispose();
    _distanceController.dispose();
    _descriptionController.dispose();
    _capacityController.dispose();
    _priceController.dispose();
    _minAgeController.dispose();
    _maxAgeController.dispose();
    _maxMenController.dispose();
    _maxWomenController.dispose();
    _inviteCodeController.dispose();
    _dynamicPricingStepController.dispose();
    _dynamicPricingMaxController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final mutation = ref.watch(
      EventBookingController.updateHostedEventMutation,
    );
    final privateAccessAsync =
        _selectedAdmissionPreset == EventAdmissionPreset.inviteOnly
        ? ref.watch(watchEventPrivateAccessProvider(widget.event.id))
        : const AsyncData(null);
    privateAccessAsync.whenData((access) {
      if (_loadedPrivateAccess) return;
      _loadedPrivateAccess = true;
      final inviteCode = access?.inviteCode.trim();
      if (inviteCode != null && inviteCode.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && _inviteCodeController.text.isEmpty) {
            _inviteCodeController.text = inviteCode;
          }
        });
      }
    });

    return Scaffold(
      backgroundColor: t.bg,
      appBar: const CatchTopBar(title: 'Edit event', border: true),
      body: SafeArea(
        top: false,
        child: Form(
          key: _formKey,
          autovalidateMode: widget.formAutovalidateMode,
          child: ListView(
            padding: CatchInsets.pageBody,
            children: [
              _EditScopeNotice(
                isCancelled: widget.event.isCancelled,
                scheduleLocked: _scheduleLocked,
                policyLocked: _policyLocked,
              ),
              if (mutation.hasError) ...[
                gapH12,
                CatchErrorBanner.fromError(
                  (mutation as MutationError).error,
                  context: AppErrorContext.event,
                ),
              ],
              gapH20,
              const FieldLabel('Schedule'),
              gapH8,
              if (_scheduleLocked)
                _ReadOnlyScheduleCard(event: widget.event)
              else ...[
                PickerTile(
                  key: CreateEventFormKeys.datePicker,
                  icon: CatchIcons.calendarTodayOutlined,
                  value: _dateController.text,
                  placeholder: 'Select a date',
                  onTap: _pickDate,
                ),
                gapH12,
                PickerTile(
                  key: CreateEventFormKeys.timePicker,
                  icon: CatchIcons.scheduleOutlined,
                  value: _startTimeController.text,
                  placeholder: 'Select start time',
                  onTap: _pickStartTime,
                ),
                if (_scheduleErrorText != null) ...[
                  gapH6,
                  Text(
                    _scheduleErrorText!,
                    style: CatchTextStyles.supporting(
                      context,
                      color: t.primary,
                    ),
                  ),
                ],
                gapH12,
                const FieldLabel('Duration'),
                gapH8,
                _DurationStepper(
                  durationMinutes: _durationMinutes,
                  onChanged: (duration) =>
                      setState(() => _durationMinutes = duration),
                ),
              ],
              gapH24,
              const FieldLabel('Where'),
              gapH8,
              CatchTextField(
                key: CreateEventFormKeys.meetingPoint,
                label: 'Location name',
                controller: _meetingPointController,
                enabled: _canEdit,
                hintText: 'e.g. Bandstand Promenade, Bandra',
                helperText:
                    'This is what attendees see in event cards and details.',
                prefixIcon: Icon(CatchIcons.locationOnOutlined),
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                onChanged: (_) => setState(() {}),
                validator: (value) =>
                    value == null || value.trim().isEmpty ? 'Required' : null,
              ),
              gapH16,
              MapPinTile(
                key: CreateEventFormKeys.mapPicker,
                startingPoint: _startingPoint,
                selectedLabel: _meetingPointController.text,
                enabled: _canEdit,
                onTap: _pickLocation,
              ),
              gapH16,
              CatchTextField(
                key: CreateEventFormKeys.locationDetails,
                label: 'Extra directions',
                isOptional: true,
                controller: _locationDetailsController,
                enabled: _canEdit,
                hintText: 'e.g. Meet outside the blue gate, third entrance',
                prefixIcon: Icon(CatchIcons.infoOutline),
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.next,
              ),
              if (widget.event.eventFormat.activityKind.isDistanceBased) ...[
                gapH24,
                const FieldLabel('Event details'),
                gapH8,
                CatchTextField(
                  key: CreateEventFormKeys.distance,
                  label: 'Distance (km)',
                  controller: _distanceController,
                  enabled: _canEdit,
                  hintText: '10',
                  prefixIcon: Icon(CatchIcons.straightenOutlined),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                  ],
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Required';
                    }
                    final distance = double.tryParse(value.trim());
                    if (distance == null) return 'Invalid';
                    if (distance <= 0) return 'Must be > 0';
                    return null;
                  },
                ),
                gapH16,
                Wrap(
                  spacing: CatchSpacing.s2,
                  runSpacing: CatchSpacing.s2,
                  children: PaceLevel.values
                      .map(
                        (pace) => CatchSelectChip(
                          label: pace.label,
                          active: _selectedPace == pace,
                          enabled: _canEdit,
                          semanticsLabel: 'Select ${pace.label} pace',
                          onTap: _canEdit
                              ? () => setState(() => _selectedPace = pace)
                              : null,
                        ),
                      )
                      .toList(),
                ),
              ],
              gapH24,
              CatchTextField(
                key: CreateEventFormKeys.description,
                label: 'Description',
                isOptional: true,
                controller: _descriptionController,
                enabled: _canEdit,
                hintText:
                    'What should attendees expect? Any tips for the route or venue?',
                prefixIcon: Icon(CatchIcons.editNoteOutlined),
                maxLines: 4,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.newline,
              ),
              gapH24,
              const FieldLabel('Event policy'),
              gapH8,
              if (_policyLocked)
                _ReadOnlyPolicyCard(event: widget.event)
              else
                _EditablePolicyCard(
                  currencyCode: widget.event.currency,
                  capacityController: _capacityController,
                  priceController: _priceController,
                  minAgeController: _minAgeController,
                  maxAgeController: _maxAgeController,
                  maxMenController: _maxMenController,
                  maxWomenController: _maxWomenController,
                  inviteCodeController: _inviteCodeController,
                  dynamicPricingStepController: _dynamicPricingStepController,
                  dynamicPricingMaxController: _dynamicPricingMaxController,
                  admissionPreset: _selectedAdmissionPreset,
                  onAdmissionPresetChanged: (preset) => setState(() {
                    _selectedAdmissionPreset = preset;
                    if (preset != EventAdmissionPreset.inviteOnly) {
                      _loadedPrivateAccess = false;
                    }
                    if (preset != EventAdmissionPreset.balancedSingles) {
                      _dynamicPricingEnabled = false;
                    }
                    if (preset != EventAdmissionPreset.openCapacity) {
                      _cohortCapsEnabled = false;
                    }
                  }),
                  cohortCapsEnabled: _cohortCapsEnabled,
                  onCohortCapsEnabledChanged: (value) =>
                      setState(() => _cohortCapsEnabled = value),
                  dynamicPricingEnabled: _dynamicPricingEnabled,
                  onDynamicPricingChanged: (value) => setState(() {
                    _dynamicPricingEnabled = value;
                    if (value && _dynamicPricingStepController.text.isEmpty) {
                      _dynamicPricingStepController.text = '250';
                    }
                    if (value && _dynamicPricingMaxController.text.isEmpty) {
                      _dynamicPricingMaxController.text = '1500';
                    }
                  }),
                  cancellationPolicyId: _selectedCancellationPolicyId,
                  onCancellationPolicyChanged: (policyId) =>
                      setState(() => _selectedCancellationPolicyId = policyId),
                  privateAccessAsync: privateAccessAsync,
                ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: _EditHostedEventFooter(
          isLoading: mutation.isPending,
          onSave: !_canEdit || mutation.isPending ? null : _saveChanges,
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final today = DateUtils.dateOnly(_now);
    final lastDate = today.add(const Duration(days: 365));
    final initialDate = _selectedDate.isBefore(today) ? today : _selectedDate;
    final picked = await showCatchDatePicker(
      context: context,
      initialDate: initialDate.isAfter(lastDate) ? lastDate : initialDate,
      firstDate: today,
      lastDate: lastDate,
      title: 'Event date',
    );
    if (picked == null) return;
    final scheduleError = _scheduleErrorFor(picked, _selectedStartTime);
    setState(() {
      _selectedDate = DateUtils.dateOnly(picked);
      _dateController.text = _formatDate(_selectedDate);
      _scheduleErrorText = scheduleError;
    });
  }

  Future<void> _pickStartTime() async {
    final picked = await showCatchTimePicker(
      context: context,
      initialTime: _selectedStartTime,
      title: 'Start time',
    );
    if (picked == null) return;
    final scheduleError = _scheduleErrorFor(_selectedDate, picked);
    setState(() {
      _selectedStartTime = picked;
      _startTimeController.text = AppTimeFormatters.clockTime(
        hour: picked.hour,
        minute: picked.minute,
      );
      _scheduleErrorText = scheduleError;
    });
  }

  Future<void> _pickLocation() async {
    final deviceLocation = ref.read(deviceLocationProvider).asData?.value;
    final result = await Navigator.of(context).push<LocationPickerResult>(
      MaterialPageRoute(
        builder: (_) => LocationPickerScreen(
          countryIsoCode: countryIsoCodeForCityName(widget.club.location),
          initialLocation: _startingPoint,
          initialCenter: _startingPoint ?? deviceLocation,
          initialLabel: _trimToNull(_meetingPointController.text),
          loadMapTiles: widget.loadMapTiles,
        ),
        fullscreenDialog: true,
      ),
    );
    if (result != null) {
      setState(() {
        _startingPoint = result.coordinate;
        _meetingLocationAddress = result.address;
        _meetingLocationPlaceId = result.placeId;
        final placeName = result.displayName;
        if (placeName != null) {
          _meetingPointController.text = placeName;
        }
      });
    }
  }

  String? _scheduleErrorFor(DateTime date, TimeOfDay startTime) {
    final startsAt = DateTime(
      date.year,
      date.month,
      date.day,
      startTime.hour,
      startTime.minute,
    );
    return startsAt.isAfter(_now) ? null : 'Event start must be in the future.';
  }

  void _saveChanges() {
    if (!_formKey.currentState!.validate()) return;
    if (_startingPoint == null) {
      showCatchSnackBar(context, 'Pin a starting point before saving.');
      return;
    }
    if (!_scheduleLocked &&
        _scheduleErrorFor(_selectedDate, _selectedStartTime) != null) {
      setState(() => _scheduleErrorText = 'Event start must be in the future.');
      return;
    }

    final distanceKm = widget.event.eventFormat.activityKind.isDistanceBased
        ? double.parse(_distanceController.text.trim())
        : widget.event.distanceKm;
    final startTime = _scheduleLocked
        ? widget.event.startTime
        : _selectedStartDateTime;
    final endTime = _scheduleLocked
        ? widget.event.endTime
        : startTime.add(Duration(minutes: _durationMinutes));
    final meetingLocation = EventMeetingLocation(
      name: _meetingPointController.text.trim(),
      address: _meetingLocationAddress,
      placeId: _meetingLocationPlaceId,
      latitude: _startingPoint!.latitude,
      longitude: _startingPoint!.longitude,
      notes: _trimToNull(_locationDetailsController.text),
    ).normalized();
    final includePolicy = !_policyLocked;
    final eventPolicyDefaults = includePolicy ? _eventPolicyDefaults : null;
    final eventPolicy = includePolicy
        ? _eventPolicyForDefaults(eventPolicyDefaults!)
        : widget.event.eventPolicy;

    final nextEvent = widget.event.copyWith(
      startTime: startTime,
      endTime: endTime,
      meetingPoint: meetingLocation.name,
      meetingLocation: meetingLocation,
      startingPointLat: meetingLocation.latitude,
      startingPointLng: meetingLocation.longitude,
      locationDetails: meetingLocation.notes,
      distanceKm: distanceKm,
      pace: widget.event.eventFormat.activityKind.isDistanceBased
          ? _selectedPace
          : widget.event.pace,
      description: _descriptionController.text.trim(),
      capacityLimit: includePolicy
          ? int.parse(_capacityController.text.trim())
          : widget.event.capacityLimit,
      priceInPaise: includePolicy
          ? _currencyControllerValueInMinorUnits(
              _priceController,
              currencyCode: widget.event.currency,
            )!
          : widget.event.priceInPaise,
      constraints: includePolicy
          ? eventPolicyDefaults!.toConstraints()
          : widget.event.constraints,
      eventPolicy: eventPolicy,
    );

    unawaited(
      EventBookingController.updateHostedEventMutation.run(ref, (tx) async {
        await tx
            .get(eventBookingControllerProvider.notifier)
            .updateHostedEvent(
              event: nextEvent,
              includePolicy: includePolicy,
              inviteCode: _trimToNull(_inviteCodeController.text),
            );
        ref.invalidate(watchEventProvider(widget.event.id));
        ref.invalidate(watchEventParticipationRosterProvider(widget.event.id));
        if (!mounted) return;
        showCatchSnackBar(context, 'Event updated.');
        await Navigator.of(context).maybePop();
      }),
    );
  }

  EventPolicyDefaults get _eventPolicyDefaults => EventPolicyDefaults(
    admissionPreset: _admissionDefaultPresetFromSelected(
      _selectedAdmissionPreset,
      cohortCapsEnabled: _cohortCapsEnabled,
    ),
    minAge: int.tryParse(_minAgeController.text.trim()) ?? 0,
    maxAge: int.tryParse(_maxAgeController.text.trim()) ?? 99,
    maxMen: int.tryParse(_maxMenController.text.trim()),
    maxWomen: int.tryParse(_maxWomenController.text.trim()),
    dynamicPricingEnabled: _dynamicPricingEnabled,
    dynamicPricingStepInPaise: _currencyControllerValueInMinorUnits(
      _dynamicPricingStepController,
      currencyCode: widget.event.currency,
    ),
    dynamicPricingMaxInPaise: _currencyControllerValueInMinorUnits(
      _dynamicPricingMaxController,
      currencyCode: widget.event.currency,
    ),
    cancellationPolicyId: _selectedCancellationPolicyId,
  );

  EventPolicyBundle _eventPolicyForDefaults(EventPolicyDefaults defaults) {
    final capacityLimit = int.parse(_capacityController.text.trim());
    final basePriceInPaise = _currencyControllerValueInMinorUnits(
      _priceController,
      currencyCode: widget.event.currency,
    )!;
    if (_selectedAdmissionPreset == EventAdmissionPreset.requestToJoin) {
      return EventPolicyBundle.requestToJoinEvent(
        capacityLimit: capacityLimit,
        basePriceInPaise: basePriceInPaise,
        cancellationPolicy: defaults.cancellationPolicy,
      );
    }
    return defaults.toEventPolicyBundle(
      capacityLimit: capacityLimit,
      basePriceInPaise: basePriceInPaise,
      inviteCodeHint: _inviteCodeHint,
    );
  }

  String? get _inviteCodeHint {
    final code = _inviteCodeController.text.trim();
    if (code.length <= 4) return code.isEmpty ? null : code;
    return '${code.substring(0, 2)}...${code.substring(code.length - 2)}';
  }
}

class _EditScopeNotice extends StatelessWidget {
  const _EditScopeNotice({
    required this.isCancelled,
    required this.scheduleLocked,
    required this.policyLocked,
  });

  final bool isCancelled;
  final bool scheduleLocked;
  final bool policyLocked;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final title = isCancelled
        ? 'Cancelled event'
        : scheduleLocked
        ? 'Schedule locked'
        : 'Published event';
    final message = isCancelled
        ? 'Cancelled events cannot be edited. Create a new event if you need to host this again.'
        : scheduleLocked
        ? 'You can still update location and descriptive details. Date, time, and duration stay locked after the event starts or once people have joined.'
        : policyLocked
        ? 'You can edit the schedule, location, distance, and description. Capacity, pricing, admission policy, and invite setup are locked by existing event activity.'
        : 'You can edit schedule, location, event details, capacity, pricing, admission policy, and invite setup until the first booking or waitlist join.';

    return CatchSurface(
      padding: CatchInsets.content,
      borderColor: t.line,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isCancelled
                ? CatchIcons.blockRounded
                : CatchIcons.infoOutlineRounded,
            color: isCancelled ? t.danger : t.primary,
          ),
          gapW12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: CatchTextStyles.sectionTitle(context),
                      ),
                    ),
                    if (scheduleLocked && !isCancelled)
                      const CatchBadge(label: 'Locked'),
                  ],
                ),
                gapH4,
                Text(
                  message,
                  style: CatchTextStyles.supporting(context, color: t.ink2),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EditablePolicyCard extends StatelessWidget {
  const _EditablePolicyCard({
    required this.currencyCode,
    required this.capacityController,
    required this.priceController,
    required this.minAgeController,
    required this.maxAgeController,
    required this.maxMenController,
    required this.maxWomenController,
    required this.inviteCodeController,
    required this.dynamicPricingStepController,
    required this.dynamicPricingMaxController,
    required this.admissionPreset,
    required this.onAdmissionPresetChanged,
    required this.cohortCapsEnabled,
    required this.onCohortCapsEnabledChanged,
    required this.dynamicPricingEnabled,
    required this.onDynamicPricingChanged,
    required this.cancellationPolicyId,
    required this.onCancellationPolicyChanged,
    required this.privateAccessAsync,
  });

  final String currencyCode;
  final TextEditingController capacityController;
  final TextEditingController priceController;
  final TextEditingController minAgeController;
  final TextEditingController maxAgeController;
  final TextEditingController maxMenController;
  final TextEditingController maxWomenController;
  final TextEditingController inviteCodeController;
  final TextEditingController dynamicPricingStepController;
  final TextEditingController dynamicPricingMaxController;
  final EventAdmissionPreset admissionPreset;
  final ValueChanged<EventAdmissionPreset> onAdmissionPresetChanged;
  final bool cohortCapsEnabled;
  final ValueChanged<bool> onCohortCapsEnabledChanged;
  final bool dynamicPricingEnabled;
  final ValueChanged<bool> onDynamicPricingChanged;
  final EventCancellationPolicyId cancellationPolicyId;
  final ValueChanged<EventCancellationPolicyId> onCancellationPolicyChanged;
  final AsyncValue<Object?> privateAccessAsync;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return CatchSurface(
      padding: CatchInsets.content,
      borderColor: t.line,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Editable until the first booking or waitlist join.',
            style: CatchTextStyles.supporting(context, color: t.ink2),
          ),
          gapH16,
          Row(
            children: [
              Expanded(
                child: CatchTextField(
                  label: 'Max attendees',
                  controller: capacityController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: _positiveRequiredValidator,
                ),
              ),
              gapW12,
              Expanded(
                child: CatchTextField(
                  label: 'Base price ($currencyCode)',
                  controller: priceController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                  ],
                  validator: (value) => _moneyRequiredValidator(
                    value,
                    currencyCode: currencyCode,
                  ),
                ),
              ),
            ],
          ),
          gapH18,
          const FieldLabel('Admission format'),
          gapH8,
          Wrap(
            spacing: CatchSpacing.s2,
            runSpacing: CatchSpacing.s2,
            children: [
              for (final preset in EventAdmissionPreset.values)
                CatchSelectChip(
                  label: preset.label,
                  active: admissionPreset == preset,
                  semanticsLabel: preset.title,
                  onTap: () => onAdmissionPresetChanged(preset),
                ),
            ],
          ),
          gapH8,
          Text(
            admissionPreset.description,
            style: CatchTextStyles.supporting(context, color: t.ink2),
          ),
          if (admissionPreset == EventAdmissionPreset.inviteOnly) ...[
            gapH16,
            if (privateAccessAsync.isLoading)
              Text(
                'Loading current invite code...',
                style: CatchTextStyles.supporting(context, color: t.ink2),
              ),
            gapH8,
            CatchTextField(
              label: 'Invite code',
              controller: inviteCodeController,
              hintText: 'CATCH-DELHI',
              prefixIcon: Icon(CatchIcons.lockOutlineRounded),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9_-]')),
              ],
              validator: admissionPreset == EventAdmissionPreset.inviteOnly
                  ? _inviteCodeValidator
                  : null,
            ),
          ],
          if (admissionPreset == EventAdmissionPreset.openCapacity) ...[
            gapH12,
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Cohort caps',
                        style: CatchTextStyles.labelL(context),
                      ),
                      gapH4,
                      Text(
                        'Optionally cap straight men and straight women without making this a separate admission format.',
                        style: CatchTextStyles.supporting(
                          context,
                          color: t.ink2,
                        ),
                      ),
                    ],
                  ),
                ),
                gapW12,
                CatchToggle(
                  value: cohortCapsEnabled,
                  onChanged: onCohortCapsEnabledChanged,
                  semanticLabel: 'Cohort caps',
                ),
              ],
            ),
            if (cohortCapsEnabled) ...[
              gapH12,
              Row(
                children: [
                  Expanded(
                    child: CatchTextField(
                      label: 'Max straight men',
                      isOptional: true,
                      controller: maxMenController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: _positiveOptionalValidator,
                    ),
                  ),
                  gapW12,
                  Expanded(
                    child: CatchTextField(
                      label: 'Max straight women',
                      isOptional: true,
                      controller: maxWomenController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: _positiveOptionalValidator,
                    ),
                  ),
                ],
              ),
            ],
          ],
          if (admissionPreset == EventAdmissionPreset.requestToJoin) ...[
            gapH12,
            Text(
              'Requests appear in host manage with each person\'s public profile so the host can review fit before confirming spots.',
              style: CatchTextStyles.supporting(context, color: t.ink2),
            ),
          ],
          if (admissionPreset == EventAdmissionPreset.balancedSingles) ...[
            gapH12,
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Demand pricing',
                        style: CatchTextStyles.labelL(context),
                      ),
                      gapH4,
                      Text(
                        'Increase price for the over-demand cohort while preserving the event balance.',
                        style: CatchTextStyles.supporting(
                          context,
                          color: t.ink2,
                        ),
                      ),
                    ],
                  ),
                ),
                gapW12,
                CatchToggle(
                  value: dynamicPricingEnabled,
                  onChanged: onDynamicPricingChanged,
                  semanticLabel: 'Demand pricing',
                ),
              ],
            ),
            if (dynamicPricingEnabled) ...[
              gapH12,
              Row(
                children: [
                  Expanded(
                    child: CatchTextField(
                      label: 'Step ($currencyCode)',
                      controller: dynamicPricingStepController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: _positiveRequiredValidator,
                    ),
                  ),
                  gapW12,
                  Expanded(
                    child: CatchTextField(
                      label: 'Max ($currencyCode)',
                      controller: dynamicPricingMaxController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: _positiveRequiredValidator,
                    ),
                  ),
                ],
              ),
            ],
          ],
          gapH18,
          const FieldLabel('Age range'),
          gapH8,
          Row(
            children: [
              Expanded(
                child: CatchTextField(
                  label: 'Min age',
                  isOptional: true,
                  controller: minAgeController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (value) => _validateAge(
                    value,
                    siblingController: maxAgeController,
                    isMinimum: true,
                  ),
                ),
              ),
              gapW12,
              Expanded(
                child: CatchTextField(
                  label: 'Max age',
                  isOptional: true,
                  controller: maxAgeController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (value) => _validateAge(
                    value,
                    siblingController: minAgeController,
                    isMinimum: false,
                  ),
                ),
              ),
            ],
          ),
          gapH18,
          const FieldLabel('Cancellation policy'),
          gapH8,
          Wrap(
            spacing: CatchSpacing.s2,
            runSpacing: CatchSpacing.s2,
            children: [
              for (final policyId in EventCancellationPolicyId.values)
                CatchSelectChip(
                  label: _policyFor(policyId).title.toUpperCase(),
                  active: cancellationPolicyId == policyId,
                  semanticsLabel: _policyFor(policyId).title,
                  onTap: () => onCancellationPolicyChanged(policyId),
                ),
            ],
          ),
          gapH8,
          Text(
            _policyFor(cancellationPolicyId).attendeeSummary,
            style: CatchTextStyles.supporting(context, color: t.ink2),
          ),
        ],
      ),
    );
  }
}

class _EditHostedEventFooter extends StatelessWidget {
  const _EditHostedEventFooter({required this.isLoading, required this.onSave});

  final bool isLoading;
  final VoidCallback? onSave;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: t.bg,
        border: Border(top: BorderSide(color: t.line)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          CatchSpacing.s5,
          CatchSpacing.s3,
          CatchSpacing.s5,
          CatchSpacing.micro18,
        ),
        child: CatchButton(
          key: EditHostedEventKeys.saveButton,
          label: 'Save changes',
          onPressed: onSave,
          isLoading: isLoading,
          fullWidth: true,
          icon: Icon(CatchIcons.saveOutlined),
        ),
      ),
    );
  }
}

class _ReadOnlyPolicyCard extends StatelessWidget {
  const _ReadOnlyPolicyCard({required this.event});

  final Event event;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final policy = event.effectiveEventPolicy;
    return CatchSurface(
      padding: CatchInsets.content,
      borderColor: t.line,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Policy locked', style: CatchTextStyles.sectionTitle(context)),
          gapH4,
          Text(
            'Capacity, pricing, admission, and cancellation policy lock once the event starts or someone books or joins the waitlist.',
            style: CatchTextStyles.supporting(context, color: t.ink2),
          ),
          gapH12,
          _ReadOnlyPolicyRow(
            label: 'Capacity',
            value: '${event.capacityLimit}',
          ),
          _ReadOnlyPolicyRow(
            label: 'Price',
            value: event.isFree
                ? 'Free'
                : EventFormatters.priceInPaise(
                    event.priceInPaise,
                    currencyCode: event.currency,
                  ),
          ),
          _ReadOnlyPolicyRow(
            label: 'Admission',
            value: _admissionPresetFor(policy).title,
          ),
          _ReadOnlyPolicyRow(
            label: 'Cancellation',
            value: policy.cancellationPolicy.title,
            showDivider: false,
          ),
        ],
      ),
    );
  }
}

class _ReadOnlyPolicyRow extends StatelessWidget {
  const _ReadOnlyPolicyRow({
    required this.label,
    required this.value,
    this.showDivider = true,
  });

  final String label;
  final String value;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Column(
      children: [
        Row(
          children: [
            Text(
              label,
              style: CatchTextStyles.supporting(context, color: t.ink2),
            ),
            gapW16,
            Expanded(
              child: Text(
                value,
                style: CatchTextStyles.labelL(context),
                textAlign: TextAlign.right,
              ),
            ),
          ],
        ),
        if (showDivider) ...[gapH10, Divider(color: t.line, height: 1), gapH10],
      ],
    );
  }
}

class _ReadOnlyScheduleCard extends StatelessWidget {
  const _ReadOnlyScheduleCard({required this.event});

  final Event event;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return CatchSurface(
      padding: CatchInsets.content,
      borderColor: t.line,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            event.shortDateLabel,
            style: CatchTextStyles.sectionTitle(context),
          ),
          gapH4,
          Text(event.timeRangeLabel, style: CatchTextStyles.bodyLead(context)),
          gapH8,
          Text(
            'Schedule changes are blocked here to avoid changing attendee commitments.',
            style: CatchTextStyles.supporting(context, color: t.ink2),
          ),
        ],
      ),
    );
  }
}

class _DurationStepper extends StatelessWidget {
  const _DurationStepper({
    required this.durationMinutes,
    required this.onChanged,
  });

  final int durationMinutes;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: CatchButton(
            label: '-15 min',
            onPressed:
                durationMinutes > CatchBusinessRules.eventMinDurationMinutes
                ? () => onChanged(
                    durationMinutes -
                        CatchBusinessRules.eventDurationStepMinutes,
                  )
                : null,
            variant: CatchButtonVariant.secondary,
            icon: Icon(CatchIcons.removeRounded),
          ),
        ),
        gapW10,
        Expanded(
          child: CatchSurface(
            padding: CatchInsets.controlContent,
            radius: CatchRadius.md,
            child: Center(
              child: Text(
                EventFormatters.durationMinutes(durationMinutes),
                style: CatchTextStyles.sectionTitle(context),
              ),
            ),
          ),
        ),
        gapW10,
        Expanded(
          child: CatchButton(
            label: '+15 min',
            onPressed:
                durationMinutes < CatchBusinessRules.eventMaxDurationMinutes
                ? () => onChanged(
                    durationMinutes +
                        CatchBusinessRules.eventDurationStepMinutes,
                  )
                : null,
            variant: CatchButtonVariant.secondary,
            icon: Icon(CatchIcons.addRounded),
          ),
        ),
      ],
    );
  }
}

String _formatDate(DateTime date) {
  return '${date.day.toString().padLeft(2, '0')}/'
      '${date.month.toString().padLeft(2, '0')}/'
      '${date.year}';
}

String? _trimToNull(String value) {
  final normalized = value.trim();
  return normalized.isEmpty ? null : normalized;
}

EventAdmissionPreset _admissionPresetFor(EventPolicyBundle policy) {
  if (policy.usesInviteOnly) return EventAdmissionPreset.inviteOnly;
  if (policy.admissionPolicy.manualApprovalRequired) {
    return EventAdmissionPreset.requestToJoin;
  }
  if (policy.usesBalancedRatio) return EventAdmissionPreset.balancedSingles;
  return EventAdmissionPreset.openCapacity;
}

EventAdmissionDefaultPreset _admissionDefaultPresetFromSelected(
  EventAdmissionPreset preset, {
  required bool cohortCapsEnabled,
}) {
  if (preset == EventAdmissionPreset.openCapacity && cohortCapsEnabled) {
    return EventAdmissionDefaultPreset.fixedCohortCaps;
  }
  return switch (preset) {
    EventAdmissionPreset.openCapacity =>
      EventAdmissionDefaultPreset.openCapacity,
    EventAdmissionPreset.inviteOnly => EventAdmissionDefaultPreset.inviteOnly,
    EventAdmissionPreset.requestToJoin =>
      EventAdmissionDefaultPreset.openCapacity,
    EventAdmissionPreset.balancedSingles =>
      EventAdmissionDefaultPreset.balancedSingles,
  };
}

String _minorUnitsText(int? value, {required String currencyCode}) =>
    minorCurrencyAmountInputText(value, currencyCode: currencyCode);

int? _currencyControllerValueInMinorUnits(
  TextEditingController controller, {
  required String currencyCode,
}) => parseMajorCurrencyAmountToMinorUnits(
  controller.text,
  currencyCode: currencyCode,
);

String? _positiveOptionalValidator(String? value) {
  if (value == null || value.trim().isEmpty) return null;
  final n = int.tryParse(value.trim());
  if (n == null || n < 1) return 'Min 1';
  return null;
}

String? _positiveRequiredValidator(String? value) {
  if (value == null || value.trim().isEmpty) return 'Required';
  final n = int.tryParse(value.trim());
  if (n == null || n < 1) return 'Min 1';
  return null;
}

String? _moneyRequiredValidator(String? value, {required String currencyCode}) {
  if (value == null || value.trim().isEmpty) return 'Required';
  final amount = parseMajorCurrencyAmountToMinorUnits(
    value,
    currencyCode: currencyCode,
  );
  if (amount == null) return 'Invalid';
  return null;
}

String? _inviteCodeValidator(String? value) {
  final code = value?.trim() ?? '';
  if (code.isEmpty) return 'Required';
  if (code.length < 4) return 'Min 4 chars';
  if (code.length > 64) return 'Max 64 chars';
  return null;
}

String? _validateAge(
  String? value, {
  required TextEditingController siblingController,
  required bool isMinimum,
}) {
  if (value == null || value.trim().isEmpty) return null;

  final parsedValue = int.tryParse(value.trim());
  if (parsedValue == null || parsedValue < 18 || parsedValue > 99) {
    return '18-99';
  }

  final siblingValue = int.tryParse(siblingController.text.trim());
  if (siblingValue == null) return null;

  if (isMinimum && parsedValue > siblingValue) return '<= max';
  if (!isMinimum && parsedValue < siblingValue) return '>= min';
  return null;
}

EventCancellationPolicy _policyFor(EventCancellationPolicyId id) {
  return switch (id) {
    EventCancellationPolicyId.flexible =>
      const EventCancellationPolicy.flexible(),
    EventCancellationPolicyId.standard =>
      const EventCancellationPolicy.standard(),
    EventCancellationPolicyId.strict => const EventCancellationPolicy.strict(),
  };
}
