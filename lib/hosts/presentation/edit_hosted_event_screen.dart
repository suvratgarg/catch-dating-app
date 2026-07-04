import 'dart:async';

import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/clubs/data/clubs_repository.dart';
import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/business_rules.dart';
import 'package:catch_dating_app/core/city_catalog.dart';
import 'package:catch_dating_app/core/country_markets.dart';
import 'package:catch_dating_app/core/device_location.dart';
import 'package:catch_dating_app/core/presentation/catch_async_state.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_adaptive_picker.dart';
import 'package:catch_dating_app/core/widgets/catch_badge.dart';
import 'package:catch_dating_app/core/widgets/catch_bottom_dock.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_divider.dart';
import 'package:catch_dating_app/core/widgets/catch_error_banner.dart';
import 'package:catch_dating_app/core/widgets/catch_error_snackbar.dart';
import 'package:catch_dating_app/core/widgets/catch_error_state.dart';
import 'package:catch_dating_app/core/widgets/catch_field.dart';
import 'package:catch_dating_app/core/widgets/catch_form_field_label.dart';
import 'package:catch_dating_app/core/widgets/catch_number_stepper.dart';
import 'package:catch_dating_app/core/widgets/catch_select_chip.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/core/widgets/catch_top_bar.dart';
import 'package:catch_dating_app/event_policies/domain/event_policy.dart';
import 'package:catch_dating_app/event_policies/domain/event_policy_defaults.dart';
import 'package:catch_dating_app/events/data/event_participation_repository.dart';
import 'package:catch_dating_app/events/data/event_repository.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/domain/event_formatters.dart';
import 'package:catch_dating_app/events/domain/event_private_access.dart';
import 'package:catch_dating_app/events/events.dart'
    show LocationPickerResult, LocationPickerScreen;
import 'package:catch_dating_app/events/shared/map_pin_tile.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/create/create_event_form_keys.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/create/create_event_policy_state.dart';
import 'package:catch_dating_app/hosts/presentation/host_event_booking_controller.dart';
import 'package:catch_dating_app/hosts/presentation/host_event_edit_screen_state.dart';
import 'package:catch_dating_app/hosts/presentation/host_event_edit_view_model.dart';
import 'package:catch_dating_app/hosts/presentation/validators.dart';
import 'package:catch_dating_app/hosts/presentation/widgets/host_loading_skeletons.dart';
import 'package:catch_dating_app/hosts/presentation/widgets/host_picker_tile.dart';
import 'package:catch_dating_app/locations/domain/location_coordinate.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/experimental/mutation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'edit_hosted_event_route_screen.dart';

abstract final class EditHostedEventKeys {
  static const saveButton = ValueKey('edit-hosted-event-save-button');
}

@immutable
class HostEventEditSaveRequest {
  const HostEventEditSaveRequest({
    required this.nextEvent,
    required this.includePolicy,
    required this.inviteCode,
  });

  final Event nextEvent;
  final bool includePolicy;
  final String? inviteCode;

  factory HostEventEditSaveRequest.fromForm({
    required Event event,
    required bool scheduleLocked,
    required bool policyLocked,
    required DateTime selectedStartDateTime,
    required int durationMinutes,
    required LocationCoordinate startingPoint,
    required String meetingPoint,
    required String? meetingLocationAddress,
    required String? meetingLocationPlaceId,
    required String locationDetails,
    required String distanceText,
    required PaceLevel selectedPace,
    required String description,
    required String capacityText,
    required String priceText,
    required EventAdmissionPreset admissionPreset,
    required bool cohortCapsEnabled,
    required bool dynamicPricingEnabled,
    required String minAgeText,
    required String maxAgeText,
    required String maxMenText,
    required String maxWomenText,
    required String dynamicPricingStepText,
    required String dynamicPricingMaxText,
    required EventCancellationPolicyId cancellationPolicyId,
    required String inviteCodeText,
  }) {
    final distanceKm = event.eventFormat.activityKind.isDistanceBased
        ? double.parse(distanceText.trim())
        : event.distanceKm;
    final startTime = scheduleLocked ? event.startTime : selectedStartDateTime;
    final endTime = scheduleLocked
        ? event.endTime
        : startTime.add(CatchBusinessRules.eventDuration(durationMinutes));
    final meetingLocation = EventMeetingLocation(
      name: meetingPoint.trim(),
      address: meetingLocationAddress,
      placeId: meetingLocationPlaceId,
      latitude: startingPoint.latitude,
      longitude: startingPoint.longitude,
      notes: _trimToNull(locationDetails),
    ).normalized();
    final includePolicy = !policyLocked;
    final eventPolicyDefaults = includePolicy
        ? EventPolicyDefaults(
            admissionPreset: _admissionDefaultPresetFromSelected(
              admissionPreset,
              cohortCapsEnabled: cohortCapsEnabled,
            ),
            minAge: int.tryParse(minAgeText.trim()) ?? 0,
            maxAge: int.tryParse(maxAgeText.trim()) ?? 99,
            maxMen: int.tryParse(maxMenText.trim()),
            maxWomen: int.tryParse(maxWomenText.trim()),
            dynamicPricingEnabled: dynamicPricingEnabled,
            dynamicPricingStepInPaise: _currencyTextValueInMinorUnits(
              dynamicPricingStepText,
              currencyCode: event.currency,
            ),
            dynamicPricingMaxInPaise: _currencyTextValueInMinorUnits(
              dynamicPricingMaxText,
              currencyCode: event.currency,
            ),
            cancellationPolicyId: cancellationPolicyId,
          )
        : null;
    final capacityLimit = includePolicy
        ? int.parse(capacityText.trim())
        : event.capacityLimit;
    final priceInPaise = includePolicy
        ? _currencyTextValueInMinorUnits(
            priceText,
            currencyCode: event.currency,
          )!
        : event.priceInPaise;
    final eventPolicy = includePolicy
        ? _eventPolicyForDefaults(
            defaults: eventPolicyDefaults!,
            admissionPreset: admissionPreset,
            capacityLimit: capacityLimit,
            basePriceInPaise: priceInPaise,
            inviteCodeHint: _inviteCodeHint(inviteCodeText),
          )
        : event.eventPolicy;

    return HostEventEditSaveRequest(
      nextEvent: event.copyWith(
        startTime: startTime,
        endTime: endTime,
        meetingPoint: meetingLocation.name,
        meetingLocation: meetingLocation,
        startingPointLat: meetingLocation.latitude,
        startingPointLng: meetingLocation.longitude,
        locationDetails: meetingLocation.notes,
        distanceKm: distanceKm,
        pace: event.eventFormat.activityKind.isDistanceBased
            ? selectedPace
            : event.pace,
        description: description.trim(),
        capacityLimit: capacityLimit,
        priceInPaise: priceInPaise,
        constraints: includePolicy
            ? eventPolicyDefaults!.toConstraints()
            : event.constraints,
        eventPolicy: eventPolicy,
      ),
      includePolicy: includePolicy,
      inviteCode: _trimToNull(inviteCodeText),
    );
  }
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
      HostEventBookingController.updateHostedEventMutation,
    );
    final saveError = mutation.hasError
        ? (mutation as MutationError).error
        : null;
    final canEdit = HostEventEditScreenState.eventCanEdit(widget.event);
    final scheduleLocked = HostEventEditScreenState.eventScheduleLocked(
      widget.event,
      _now,
    );
    final fieldState = HostEventEditFieldDisplayState.fromForm(
      canEdit: canEdit,
      scheduleLocked: scheduleLocked,
      selectedDate: _selectedDate,
      selectedStartTime: _selectedStartTime,
      durationMinutes: _durationMinutes,
      scheduleErrorText: _scheduleErrorText,
      isDistanceBased: widget.event.eventFormat.activityKind.isDistanceBased,
      startingPoint: _startingPoint,
      meetingPoint: _meetingPointController.text,
      locationDetails: _locationDetailsController.text,
      distanceText: _distanceController.text,
      selectedPace: _selectedPace,
      description: _descriptionController.text,
      currencyCode: widget.event.currency,
      admissionPreset: _selectedAdmissionPreset,
      cohortCapsEnabled: _cohortCapsEnabled,
      dynamicPricingEnabled: _dynamicPricingEnabled,
      cancellationPolicyId: _selectedCancellationPolicyId,
    );
    final screenState = HostEventEditScreenState.from(
      event: widget.event,
      now: _now,
      savePending: mutation.isPending,
      fields: fieldState,
      saveError: saveError,
    );
    final fields = screenState.fields;
    final scheduleFields = fields.schedule;
    final detailsFields = fields.locationDetails;
    final locationState = detailsFields.location;
    final privateAccessAsync =
        _selectedAdmissionPreset == EventAdmissionPreset.inviteOnly
        ? ref.watch(watchEventPrivateAccessProvider(widget.event.id))
        : const AsyncData<EventPrivateAccess?>(null);
    final privateAccessState = buildHostEventEditPrivateAccessState(
      admissionPreset: _selectedAdmissionPreset,
      loadedPrivateAccess: _loadedPrivateAccess,
      privateAccess: privateAccessAsync,
    );
    if (privateAccessState.shouldMarkLoaded &&
        privateAccessState.privateAccess.status == CatchAsyncStatus.data) {
      _loadedPrivateAccess = true;
      final inviteCode = privateAccessState.inviteCodeSeed;
      if (inviteCode != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && _inviteCodeController.text.isEmpty) {
            _inviteCodeController.text = inviteCode;
          }
        });
      }
    }

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
              EditHostedEventScopeNotice(
                isCancelled: widget.event.isCancelled,
                scheduleLocked: screenState.scheduleLocked,
                policyLocked: screenState.policyLocked,
              ),
              if (screenState.hasSaveError) ...[
                gapH12,
                CatchErrorBanner.fromError(
                  screenState.saveError!,
                  context: AppErrorContext.event,
                ),
              ],
              gapH20,
              const CatchFormFieldLabel(label: 'Schedule', large: true),
              gapH8,
              if (screenState.scheduleLocked)
                ReadOnlyHostedEventScheduleCard(event: widget.event)
              else ...[
                HostPickerTile(
                  key: CreateEventFormKeys.datePicker,
                  icon: CatchIcons.calendarTodayOutlined,
                  value: scheduleFields.dateValue,
                  placeholder: 'Select a date',
                  onTap: () =>
                      _handleIntent(const HostEventEditPickDateIntent()),
                ),
                gapH12,
                HostPickerTile(
                  key: CreateEventFormKeys.timePicker,
                  icon: CatchIcons.scheduleOutlined,
                  value: scheduleFields.startTimeValue,
                  placeholder: 'Select start time',
                  onTap: () =>
                      _handleIntent(const HostEventEditPickStartTimeIntent()),
                ),
                if (scheduleFields.hasError) ...[
                  gapH6,
                  Text(
                    scheduleFields.errorText!,
                    style: CatchTextStyles.supporting(
                      context,
                      color: t.primary,
                    ),
                  ),
                ],
                gapH12,
                const CatchFormFieldLabel(label: 'Duration', large: true),
                gapH8,
                CatchNumberStepper(
                  value: scheduleFields.durationMinutes,
                  min: CatchBusinessRules.eventMinDurationMinutes,
                  max: CatchBusinessRules.eventMaxDurationMinutes,
                  step: CatchBusinessRules.eventDurationStepMinutes,
                  decreaseTooltip: 'Decrease duration',
                  increaseTooltip: 'Increase duration',
                  formatValue: (value) =>
                      EventFormatters.durationMinutes(value.round()),
                  onChanged: (duration) => _handleIntent(
                    HostEventEditDurationChangedIntent(duration.round()),
                  ),
                ),
              ],
              gapH24,
              const CatchFormFieldLabel(label: 'Where', large: true),
              gapH8,
              CatchField.input(
                key: CreateEventFormKeys.meetingPoint,
                title: 'Location name',
                controller: _meetingPointController,
                enabled: screenState.canEdit,
                placeholder: 'e.g. Bandstand Promenade, Bandra',
                helperText:
                    'This is what attendees see in event cards and details.',
                prefixIcon: Icon(CatchIcons.locationOnOutlined),
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                onChanged: (value) => _handleIntent(
                  HostEventEditMeetingPointChangedIntent(value),
                ),
                validator: (value) =>
                    value == null || value.trim().isEmpty ? 'Required' : null,
              ),
              gapH16,
              MapPinTile(
                key: CreateEventFormKeys.mapPicker,
                startingPoint: locationState.startingPoint,
                selectedLabel: locationState.selectedLabel,
                enabled: locationState.canPick,
                onTap: () =>
                    _handleIntent(const HostEventEditPickLocationIntent()),
              ),
              gapH16,
              CatchField.input(
                key: CreateEventFormKeys.locationDetails,
                title: 'Extra directions',
                isOptional: true,
                controller: _locationDetailsController,
                enabled: screenState.canEdit,
                placeholder: 'e.g. Meet outside the blue gate, third entrance',
                prefixIcon: Icon(CatchIcons.infoOutline),
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.next,
              ),
              if (detailsFields.isDistanceBased) ...[
                gapH24,
                const CatchFormFieldLabel(label: 'Event details', large: true),
                gapH8,
                CatchField.input(
                  key: CreateEventFormKeys.distance,
                  title: 'Distance (km)',
                  controller: _distanceController,
                  enabled: screenState.canEdit,
                  placeholder: '10',
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
                          active: detailsFields.selectedPace == pace,
                          enabled: screenState.canEdit,
                          semanticsLabel: 'Select ${pace.label} pace',
                          onTap: screenState.canEdit
                              ? () => _handleIntent(
                                  HostEventEditPaceChangedIntent(pace),
                                )
                              : null,
                        ),
                      )
                      .toList(),
                ),
              ],
              gapH24,
              CatchField.input(
                key: CreateEventFormKeys.description,
                title: 'Description',
                isOptional: true,
                controller: _descriptionController,
                enabled: screenState.canEdit,
                placeholder:
                    'What should attendees expect? Any tips for the route or venue?',
                prefixIcon: Icon(CatchIcons.editNoteOutlined),
                maxLines: 4,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.newline,
              ),
              gapH24,
              const CatchFormFieldLabel(label: 'Event policy', large: true),
              gapH8,
              if (screenState.policyLocked)
                ReadOnlyHostedEventPolicyCard(event: widget.event)
              else
                EditableHostedEventPolicyCard(
                  state: fields.policy,
                  capacityController: _capacityController,
                  priceController: _priceController,
                  minAgeController: _minAgeController,
                  maxAgeController: _maxAgeController,
                  maxMenController: _maxMenController,
                  maxWomenController: _maxWomenController,
                  inviteCodeController: _inviteCodeController,
                  dynamicPricingStepController: _dynamicPricingStepController,
                  dynamicPricingMaxController: _dynamicPricingMaxController,
                  onAdmissionPresetChanged: (preset) => _handleIntent(
                    HostEventEditAdmissionPresetChangedIntent(preset),
                  ),
                  onCohortCapsEnabledChanged: (value) => _handleIntent(
                    HostEventEditCohortCapsChangedIntent(value),
                  ),
                  onDynamicPricingChanged: (value) => _handleIntent(
                    HostEventEditDynamicPricingChangedIntent(value),
                  ),
                  onCancellationPolicyChanged: (policyId) => _handleIntent(
                    HostEventEditCancellationPolicyChangedIntent(policyId),
                  ),
                  privateAccessAsync: privateAccessState.privateAccess,
                ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CatchBottomDock(
        child: CatchButton(
          key: EditHostedEventKeys.saveButton,
          label: screenState.footer.label,
          onPressed: screenState.footer.isEnabled
              ? () => _handleIntent(const HostEventEditSaveIntent())
              : null,
          isLoading: screenState.footer.isLoading,
          fullWidth: true,
          icon: Icon(CatchIcons.saveOutlined),
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final today = DateUtils.dateOnly(_now);
    final lastDate = today.add(CatchBusinessRules.eventEditDatePickerWindow);
    final initialDate = _selectedDate.isBefore(today) ? today : _selectedDate;
    final picked = await showCatchDatePicker(
      context: context,
      initialDate: initialDate.isAfter(lastDate) ? lastDate : initialDate,
      firstDate: today,
      lastDate: lastDate,
      title: 'Event date',
    );
    if (picked == null) return;
    final scheduleError = _scheduleValidationFor(
      picked,
      _selectedStartTime,
    ).errorText;
    setState(() {
      _selectedDate = DateUtils.dateOnly(picked);
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
    final scheduleError = _scheduleValidationFor(
      _selectedDate,
      picked,
    ).errorText;
    setState(() {
      _selectedStartTime = picked;
      _scheduleErrorText = scheduleError;
    });
  }

  Future<void> _pickLocation() async {
    final deviceLocation = ref.read(deviceLocationProvider).asData?.value;
    final locationState = HostEventEditLocationState.from(
      canEdit: true,
      startingPoint: _startingPoint,
      meetingPoint: _meetingPointController.text,
    );
    final result = await Navigator.of(context).push<LocationPickerResult>(
      MaterialPageRoute(
        builder: (_) => LocationPickerScreen(
          countryIsoCode: countryIsoCodeForCityName(widget.club.location),
          initialLocation: locationState.startingPoint,
          initialCenter: locationState.startingPoint ?? deviceLocation,
          initialLabel: locationState.pickerInitialLabel,
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

  HostEventEditScheduleValidationState _scheduleValidationFor(
    DateTime date,
    TimeOfDay startTime, {
    bool scheduleLocked = false,
  }) {
    return HostEventEditScheduleValidationState.from(
      scheduleLocked: scheduleLocked,
      selectedStartDateTime: DateTime(
        date.year,
        date.month,
        date.day,
        startTime.hour,
        startTime.minute,
      ),
      now: _now,
      invalidScheduleMessage:
          const HostEventEditSaveOutcomeState.updated().invalidScheduleMessage,
    );
  }

  void _handleIntent(HostEventEditIntent intent) {
    switch (intent) {
      case HostEventEditPickDateIntent():
        unawaited(_pickDate());
      case HostEventEditPickStartTimeIntent():
        unawaited(_pickStartTime());
      case HostEventEditDurationChangedIntent(:final durationMinutes):
        setState(() => _durationMinutes = durationMinutes);
      case HostEventEditMeetingPointChangedIntent():
        setState(() {});
      case HostEventEditPickLocationIntent():
        unawaited(_pickLocation());
      case HostEventEditPaceChangedIntent(:final pace):
        setState(() => _selectedPace = pace);
      case HostEventEditAdmissionPresetChangedIntent(:final preset):
        setState(() {
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
        });
      case HostEventEditCohortCapsChangedIntent(:final enabled):
        setState(() => _cohortCapsEnabled = enabled);
      case HostEventEditDynamicPricingChangedIntent(:final enabled):
        setState(() {
          _dynamicPricingEnabled = enabled;
          if (enabled && _dynamicPricingStepController.text.isEmpty) {
            _dynamicPricingStepController.text = '250';
          }
          if (enabled && _dynamicPricingMaxController.text.isEmpty) {
            _dynamicPricingMaxController.text = '1500';
          }
        });
      case HostEventEditCancellationPolicyChangedIntent(:final policyId):
        setState(() => _selectedCancellationPolicyId = policyId);
      case HostEventEditSaveIntent():
        _saveChanges();
    }
  }

  void _saveChanges() {
    final screenState = HostEventEditScreenState.from(
      event: widget.event,
      now: _now,
      savePending: false,
    );
    if (!_formKey.currentState!.validate()) return;
    if (_startingPoint == null) {
      showCatchSnackBar(
        context,
        screenState.saveOutcome.missingStartingPointMessage,
      );
      return;
    }
    final scheduleValidation = _scheduleValidationFor(
      _selectedDate,
      _selectedStartTime,
      scheduleLocked: screenState.scheduleLocked,
    );
    if (!scheduleValidation.isValid) {
      setState(() => _scheduleErrorText = scheduleValidation.errorText);
      return;
    }

    final request = HostEventEditSaveRequest.fromForm(
      event: widget.event,
      scheduleLocked: screenState.scheduleLocked,
      policyLocked: screenState.policyLocked,
      selectedStartDateTime: _selectedStartDateTime,
      durationMinutes: _durationMinutes,
      startingPoint: _startingPoint!,
      meetingPoint: _meetingPointController.text,
      meetingLocationAddress: _meetingLocationAddress,
      meetingLocationPlaceId: _meetingLocationPlaceId,
      locationDetails: _locationDetailsController.text,
      distanceText: _distanceController.text,
      selectedPace: _selectedPace,
      description: _descriptionController.text,
      capacityText: _capacityController.text,
      priceText: _priceController.text,
      admissionPreset: _selectedAdmissionPreset,
      cohortCapsEnabled: _cohortCapsEnabled,
      dynamicPricingEnabled: _dynamicPricingEnabled,
      minAgeText: _minAgeController.text,
      maxAgeText: _maxAgeController.text,
      maxMenText: _maxMenController.text,
      maxWomenText: _maxWomenController.text,
      dynamicPricingStepText: _dynamicPricingStepController.text,
      dynamicPricingMaxText: _dynamicPricingMaxController.text,
      cancellationPolicyId: _selectedCancellationPolicyId,
      inviteCodeText: _inviteCodeController.text,
    );

    unawaited(
      HostEventBookingController.updateHostedEventMutation.run(ref, (tx) async {
        await tx
            .get(hostEventBookingControllerProvider.notifier)
            .updateHostedEvent(
              event: request.nextEvent,
              includePolicy: request.includePolicy,
              inviteCode: request.inviteCode,
            );
        ref.invalidate(watchEventProvider(widget.event.id));
        ref.invalidate(watchEventParticipationRosterProvider(widget.event.id));
        if (!mounted) return;
        showCatchSnackBar(context, screenState.saveOutcome.successMessage);
        if (screenState.saveOutcome.popRouteOnSuccess) {
          await Navigator.of(context).maybePop();
        }
      }),
    );
  }
}

class EditHostedEventScopeNotice extends StatelessWidget {
  const EditHostedEventScopeNotice({
    super.key,
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

class EditableHostedEventPolicyCard extends StatelessWidget {
  const EditableHostedEventPolicyCard({
    super.key,
    required this.state,
    required this.capacityController,
    required this.priceController,
    required this.minAgeController,
    required this.maxAgeController,
    required this.maxMenController,
    required this.maxWomenController,
    required this.inviteCodeController,
    required this.dynamicPricingStepController,
    required this.dynamicPricingMaxController,
    required this.onAdmissionPresetChanged,
    required this.onCohortCapsEnabledChanged,
    required this.onDynamicPricingChanged,
    required this.onCancellationPolicyChanged,
    required this.privateAccessAsync,
  });

  final HostEventEditPolicyFieldState state;
  final TextEditingController capacityController;
  final TextEditingController priceController;
  final TextEditingController minAgeController;
  final TextEditingController maxAgeController;
  final TextEditingController maxMenController;
  final TextEditingController maxWomenController;
  final TextEditingController inviteCodeController;
  final TextEditingController dynamicPricingStepController;
  final TextEditingController dynamicPricingMaxController;
  final ValueChanged<EventAdmissionPreset> onAdmissionPresetChanged;
  final ValueChanged<bool> onCohortCapsEnabledChanged;
  final ValueChanged<bool> onDynamicPricingChanged;
  final ValueChanged<EventCancellationPolicyId> onCancellationPolicyChanged;
  final CatchAsyncState<EventPrivateAccess?> privateAccessAsync;

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
                child: CatchField.input(
                  title: 'Max attendees',
                  controller: capacityController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: positiveRequiredValidator,
                ),
              ),
              gapW12,
              Expanded(
                child: CatchField.input(
                  title: 'Base price (${state.currencyCode})',
                  controller: priceController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                  ],
                  validator: (value) => _moneyRequiredValidator(
                    value,
                    currencyCode: state.currencyCode,
                  ),
                ),
              ),
            ],
          ),
          gapH18,
          const CatchFormFieldLabel(label: 'Admission format', large: true),
          gapH8,
          Wrap(
            spacing: CatchSpacing.s2,
            runSpacing: CatchSpacing.s2,
            children: [
              for (final preset in EventAdmissionPreset.values)
                CatchSelectChip(
                  label: preset.label,
                  active: state.admissionPreset == preset,
                  semanticsLabel: preset.title,
                  onTap: () => onAdmissionPresetChanged(preset),
                ),
            ],
          ),
          gapH8,
          Text(
            state.admissionDescription,
            style: CatchTextStyles.supporting(context, color: t.ink2),
          ),
          if (state.showInviteCode) ...[
            gapH16,
            if (privateAccessAsync.status == CatchAsyncStatus.loading)
              Text(
                'Loading current invite code...',
                style: CatchTextStyles.supporting(context, color: t.ink2),
              ),
            gapH8,
            CatchField.input(
              title: 'Invite code',
              controller: inviteCodeController,
              placeholder: 'CATCH-DELHI',
              prefixIcon: Icon(CatchIcons.lockOutlineRounded),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9_-]')),
              ],
              validator: state.showInviteCode ? inviteCodeValidator : null,
            ),
          ],
          if (state.showCohortCapsToggle) ...[
            gapH12,
            CatchField.toggle(
              title: 'Cohort caps',
              body:
                  'Optionally cap straight men and straight women without making this a separate admission format.',
              value: state.cohortCapsEnabled,
              onChanged: onCohortCapsEnabledChanged,
            ),
            if (state.showCohortCapsFields) ...[
              gapH12,
              Row(
                children: [
                  Expanded(
                    child: CatchField.input(
                      title: 'Max straight men',
                      isOptional: true,
                      controller: maxMenController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: positiveOptionalValidator,
                    ),
                  ),
                  gapW12,
                  Expanded(
                    child: CatchField.input(
                      title: 'Max straight women',
                      isOptional: true,
                      controller: maxWomenController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: positiveOptionalValidator,
                    ),
                  ),
                ],
              ),
            ],
          ],
          if (state.showRequestToJoinCopy) ...[
            gapH12,
            Text(
              'Requests appear in host manage with each person\'s public profile so the host can review fit before confirming spots.',
              style: CatchTextStyles.supporting(context, color: t.ink2),
            ),
          ],
          if (state.showDynamicPricingToggle) ...[
            gapH12,
            CatchField.toggle(
              title: 'Demand pricing',
              body:
                  'Increase price for the over-demand cohort while preserving the event balance.',
              value: state.dynamicPricingEnabled,
              onChanged: onDynamicPricingChanged,
            ),
            if (state.showDynamicPricingFields) ...[
              gapH12,
              Row(
                children: [
                  Expanded(
                    child: CatchField.input(
                      title: 'Step (${state.currencyCode})',
                      controller: dynamicPricingStepController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: positiveRequiredValidator,
                    ),
                  ),
                  gapW12,
                  Expanded(
                    child: CatchField.input(
                      title: 'Max (${state.currencyCode})',
                      controller: dynamicPricingMaxController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: positiveRequiredValidator,
                    ),
                  ),
                ],
              ),
            ],
          ],
          gapH18,
          const CatchFormFieldLabel(label: 'Age range', large: true),
          gapH8,
          Row(
            children: [
              Expanded(
                child: CatchField.input(
                  title: 'Min age',
                  isOptional: true,
                  controller: minAgeController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (value) => validateAge(
                    value,
                    siblingController: maxAgeController,
                    isMinimum: true,
                  ),
                ),
              ),
              gapW12,
              Expanded(
                child: CatchField.input(
                  title: 'Max age',
                  isOptional: true,
                  controller: maxAgeController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (value) => validateAge(
                    value,
                    siblingController: minAgeController,
                    isMinimum: false,
                  ),
                ),
              ),
            ],
          ),
          gapH18,
          const CatchFormFieldLabel(label: 'Cancellation policy', large: true),
          gapH8,
          Wrap(
            spacing: CatchSpacing.s2,
            runSpacing: CatchSpacing.s2,
            children: [
              for (final policyId in EventCancellationPolicyId.values)
                CatchSelectChip(
                  label: policyFor(policyId).title.toUpperCase(),
                  active: state.cancellationPolicyId == policyId,
                  semanticsLabel: policyFor(policyId).title,
                  onTap: () => onCancellationPolicyChanged(policyId),
                ),
            ],
          ),
          gapH8,
          Text(
            state.cancellationSummary,
            style: CatchTextStyles.supporting(context, color: t.ink2),
          ),
        ],
      ),
    );
  }
}

class ReadOnlyHostedEventPolicyCard extends StatelessWidget {
  const ReadOnlyHostedEventPolicyCard({super.key, required this.event});

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
          ReadOnlyHostedEventPolicyRow(
            label: 'Capacity',
            value: '${event.capacityLimit}',
          ),
          ReadOnlyHostedEventPolicyRow(
            label: 'Price',
            value: event.isFree
                ? 'Free'
                : EventFormatters.priceInPaise(
                    event.priceInPaise,
                    currencyCode: event.currency,
                  ),
          ),
          ReadOnlyHostedEventPolicyRow(
            label: 'Admission',
            value: _admissionPresetFor(policy).title,
          ),
          ReadOnlyHostedEventPolicyRow(
            label: 'Cancellation',
            value: policy.cancellationPolicy.title,
            showDivider: false,
          ),
        ],
      ),
    );
  }
}

class ReadOnlyHostedEventPolicyRow extends StatelessWidget {
  const ReadOnlyHostedEventPolicyRow({
    super.key,
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
        if (showDivider) ...[gapH10, const CatchDivider.section(), gapH10],
      ],
    );
  }
}

class ReadOnlyHostedEventScheduleCard extends StatelessWidget {
  const ReadOnlyHostedEventScheduleCard({super.key, required this.event});

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

int? _currencyTextValueInMinorUnits(
  String value, {
  required String currencyCode,
}) => parseMajorCurrencyAmountToMinorUnits(value, currencyCode: currencyCode);

EventPolicyBundle _eventPolicyForDefaults({
  required EventPolicyDefaults defaults,
  required EventAdmissionPreset admissionPreset,
  required int capacityLimit,
  required int basePriceInPaise,
  required String? inviteCodeHint,
}) {
  if (admissionPreset == EventAdmissionPreset.requestToJoin) {
    return EventPolicyBundle.requestToJoinEvent(
      capacityLimit: capacityLimit,
      basePriceInPaise: basePriceInPaise,
      cancellationPolicy: defaults.cancellationPolicy,
    );
  }
  return defaults.toEventPolicyBundle(
    capacityLimit: capacityLimit,
    basePriceInPaise: basePriceInPaise,
    inviteCodeHint: inviteCodeHint,
  );
}

String? _inviteCodeHint(String value) {
  final code = value.trim();
  if (code.length <= 4) return code.isEmpty ? null : code;
  return '${code.substring(0, 2)}...${code.substring(code.length - 2)}';
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
