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
import 'package:catch_dating_app/core/theme/activity_palette.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_adaptive_picker.dart';
import 'package:catch_dating_app/core/widgets/catch_badge.dart';
import 'package:catch_dating_app/core/widgets/catch_bottom_dock.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_error_banner.dart';
import 'package:catch_dating_app/core/widgets/catch_error_snackbar.dart';
import 'package:catch_dating_app/core/widgets/catch_error_state.dart';
import 'package:catch_dating_app/core/widgets/catch_field.dart';
import 'package:catch_dating_app/core/widgets/catch_section_layout.dart';
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
import 'package:catch_dating_app/hosts/presentation/event_management/create/create_event_form_keys.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/create/create_event_policy_state.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/widgets/event_age_range_field.dart';
import 'package:catch_dating_app/hosts/presentation/host_event_booking_controller.dart';
import 'package:catch_dating_app/hosts/presentation/host_event_edit_screen_state.dart';
import 'package:catch_dating_app/hosts/presentation/host_event_edit_view_model.dart';
import 'package:catch_dating_app/hosts/presentation/validators.dart';
import 'package:catch_dating_app/hosts/presentation/widgets/host_loading_skeletons.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
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
    _startingPoint = LocationCoordinate.fromNullable(
      latitude: event.effectiveStartingPointLat,
      longitude: event.effectiveStartingPointLng,
    );
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
      l10n: context.l10n,
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
      appBar: CatchTopBar(
        title: context.l10n.hostsEditHostedEventScreenTitleEditEvent,
        border: true,
      ),
      body: SafeArea(
        top: false,
        child: Form(
          key: _formKey,
          autovalidateMode: widget.formAutovalidateMode,
          child: ListView(
            padding: CatchInsets.pageBody,
            children: [
              CatchSectionList(
                emptyStateOmitted: true,
                gap: 0,
                children: [
                  CatchSection.plain(
                    child: EditHostedEventScopeNotice(
                      isCancelled: widget.event.isCancelled,
                      scheduleLocked: screenState.scheduleLocked,
                      policyLocked: screenState.policyLocked,
                    ),
                  ),
                  if (screenState.hasSaveError)
                    CatchSection.plain(
                      padding: const EdgeInsets.only(top: CatchSpacing.s3),
                      child: CatchErrorBanner.fromError(
                        screenState.saveError!,
                        context: AppErrorContext.event,
                      ),
                    ),
                  if (screenState.scheduleLocked)
                    ReadOnlyHostedEventScheduleCard(event: widget.event)
                  else
                    CatchSection.fieldRows(
                      title:
                          context.l10n.hostsEditHostedEventScreenLabelSchedule,
                      children: [
                        CatchField.nav(
                          key: CreateEventFormKeys.datePicker,
                          title: context
                              .l10n
                              .hostsEditHostedEventScreenTitleEventDate,
                          body: scheduleFields.dateValue,
                          icon: CatchIcons.calendarTodayOutlined,
                          onTap: () => _handleIntent(
                            const HostEventEditPickDateIntent(),
                          ),
                        ),
                        CatchField.nav(
                          key: CreateEventFormKeys.timePicker,
                          title: context
                              .l10n
                              .hostsEditHostedEventScreenTitleStartTime,
                          body: scheduleFields.startTimeValue,
                          icon: CatchIcons.scheduleOutlined,
                          error: scheduleFields.errorText,
                          onTap: () => _handleIntent(
                            const HostEventEditPickStartTimeIntent(),
                          ),
                        ),
                        CatchField.stepper(
                          title: context
                              .l10n
                              .hostsEditHostedEventScreenLabelDuration,
                          body: EventFormatters.durationMinutes(
                            scheduleFields.durationMinutes,
                          ),
                          value: scheduleFields.durationMinutes,
                          min: CatchBusinessRules.eventMinDurationMinutes,
                          max: CatchBusinessRules.eventMaxDurationMinutes,
                          step: CatchBusinessRules.eventDurationStepMinutes,
                          formatter: (value) =>
                              EventFormatters.durationMinutes(value.round()),
                          decreaseSemanticLabel: context
                              .l10n
                              .hostsEditHostedEventScreenBodyDecreaseDuration,
                          increaseSemanticLabel: context
                              .l10n
                              .hostsEditHostedEventScreenBodyIncreaseDuration,
                          onChanged: (duration) => _handleIntent(
                            HostEventEditDurationChangedIntent(
                              duration.round(),
                            ),
                          ),
                          icon: CatchIcons.timerOutlined,
                        ),
                      ],
                    ),
                  CatchSection.fieldRows(
                    title: context.l10n.hostsEditHostedEventScreenLabelWhere,
                    children: [
                      CatchField.input(
                        key: CreateEventFormKeys.meetingPoint,
                        title: context
                            .l10n
                            .hostsEditHostedEventScreenTitleLocationName,
                        controller: _meetingPointController,
                        enabled: screenState.canEdit,
                        inputHint: context
                            .l10n
                            .hostsEditHostedEventScreenPlaceholderEGBandstandPromenade,
                        helperText: context
                            .l10n
                            .hostsEditHostedEventScreenHelpertextThisIsWhatAttendees,
                        icon: CatchIcons.locationOnOutlined,
                        textCapitalization: TextCapitalization.words,
                        textInputAction: TextInputAction.next,
                        onChanged: (value) => _handleIntent(
                          HostEventEditMeetingPointChangedIntent(value),
                        ),
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                            ? context
                                  .l10n
                                  .hostsEditHostedEventScreenBodyRequired
                            : null,
                      ),
                      CatchField.nav(
                        key: CreateEventFormKeys.mapPicker,
                        title: context.l10n.hostsWhereStepLabelMeetingLocation,
                        body: locationState.hasStartingPoint
                            ? (locationState.selectedLabel.isEmpty
                                  ? context
                                        .l10n
                                        .eventsMapPinTileTitlePinnedLocation
                                  : locationState.selectedLabel)
                            : context.l10n.eventsMapPinTileTitleChooseOnMap,
                        icon: locationState.hasStartingPoint
                            ? CatchIcons.editLocationAltOutlined
                            : CatchIcons.mapOutlined,
                        onTap: locationState.canPick
                            ? () => _handleIntent(
                                const HostEventEditPickLocationIntent(),
                              )
                            : null,
                      ),
                      CatchField.input(
                        key: CreateEventFormKeys.locationDetails,
                        title: context
                            .l10n
                            .hostsEditHostedEventScreenTitleExtraDirections,
                        isOptional: true,
                        controller: _locationDetailsController,
                        enabled: screenState.canEdit,
                        inputHint: context
                            .l10n
                            .hostsEditHostedEventScreenPlaceholderEGMeetOutside,
                        icon: CatchIcons.infoOutline,
                        maxLines: 3,
                        textCapitalization: TextCapitalization.sentences,
                        textInputAction: TextInputAction.next,
                      ),
                    ],
                  ),
                  CatchSection.fieldRows(
                    title: context
                        .l10n
                        .hostsEditHostedEventScreenLabelEventDetails,
                    children: [
                      if (detailsFields.isDistanceBased) ...[
                        CatchField.input(
                          key: CreateEventFormKeys.distance,
                          title: context
                              .l10n
                              .hostsEditHostedEventScreenTitleDistanceKm,
                          controller: _distanceController,
                          enabled: screenState.canEdit,
                          inputHint: '10',
                          icon: CatchIcons.straightenOutlined,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(
                                context.l10n.hostsEditHostedEventScreenBodyDD,
                              ),
                            ),
                          ],
                          textInputAction: TextInputAction.next,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return context
                                  .l10n
                                  .hostsEditHostedEventScreenBodyRequired;
                            }
                            final distance = double.tryParse(value.trim());
                            if (distance == null) {
                              return context
                                  .l10n
                                  .hostsEditHostedEventScreenBodyInvalid;
                            }
                            if (distance <= 0) {
                              return context
                                  .l10n
                                  .hostsEditHostedEventScreenBodyMustBe0;
                            }
                            return null;
                          },
                        ),
                        CatchField.choices<PaceLevel>(
                          title:
                              context.l10n.hostsEventDetailsStepLabelPaceLevel,
                          body: detailsFields.selectedPace.label,
                          values: PaceLevel.values,
                          itemLabel: (pace) => pace.label,
                          itemAccent: (_) => ActivityPalette.resolve(
                            context,
                            widget.event.eventFormat.activityKind,
                          ).accent,
                          selected: <PaceLevel>{detailsFields.selectedPace},
                          onSelectionChanged: screenState.canEdit
                              ? (selection) => _handleIntent(
                                  HostEventEditPaceChangedIntent(
                                    selection.single,
                                  ),
                                )
                              : null,
                          enabled: screenState.canEdit,
                          icon: CatchIcons.speedOutlined,
                        ),
                      ],
                      CatchField.input(
                        key: CreateEventFormKeys.description,
                        title: context
                            .l10n
                            .hostsEditHostedEventScreenTitleDescription,
                        isOptional: true,
                        controller: _descriptionController,
                        enabled: screenState.canEdit,
                        inputHint: context
                            .l10n
                            .hostsEditHostedEventScreenPlaceholderWhatShouldAttendeesExpect,
                        icon: CatchIcons.editNoteOutlined,
                        maxLines: 4,
                        textCapitalization: TextCapitalization.sentences,
                        textInputAction: TextInputAction.newline,
                      ),
                    ],
                  ),
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
                      dynamicPricingStepController:
                          _dynamicPricingStepController,
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
      title: context.l10n.hostsEditHostedEventScreenTitleEventDate,
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
      title: context.l10n.hostsEditHostedEventScreenTitleStartTime,
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
      invalidScheduleMessage: HostEventEditSaveOutcomeState.updated(
        context.l10n,
      ).invalidScheduleMessage,
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
      l10n: context.l10n,
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
        ? context.l10n.hostsEditHostedEventScreenTitleCancelledEvent
        : scheduleLocked
        ? context.l10n.hostsEditHostedEventScreenTitleScheduleLocked
        : context.l10n.hostsEditHostedEventScreenTitlePublishedEvent;
    final message = isCancelled
        ? context.l10n.hostsEditHostedEventScreenMessageCancelledEventsCannotBe
        : scheduleLocked
        ? context.l10n.hostsEditHostedEventScreenMessageYouCanStillUpdate
        : policyLocked
        ? context.l10n.hostsEditHostedEventScreenMessageYouCanEditThe
        : context.l10n.hostsEditHostedEventScreenMessageYouCanEditSchedule;

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
                      CatchBadge(
                        label:
                            context.l10n.hostsEditHostedEventScreenLabelLocked,
                      ),
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
    return CatchSection.fieldRows(
      title: context.l10n.hostsEditHostedEventScreenLabelEventPolicy,
      footer: Padding(
        padding: const EdgeInsets.only(top: CatchSpacing.s2),
        child: Text(
          context.l10n.hostsEditHostedEventScreenTextEditableUntilTheFirst,
          style: CatchTextStyles.supporting(context, color: t.ink2),
        ),
      ),
      children: [
        CatchField.input(
          key: CreateEventFormKeys.capacity,
          title: context.l10n.hostsEditHostedEventScreenTitleMaxAttendees,
          controller: capacityController,
          inputHint: '20',
          icon: CatchIcons.peopleOutline,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          textInputAction: TextInputAction.next,
          validator: (value) => positiveRequiredValidator(value, context.l10n),
        ),
        CatchField.input(
          key: CreateEventFormKeys.price,
          title: context.l10n
              .hostsEditHostedEventScreenTitleBasePriceCurrencycode(
                currencyCode: state.currencyCode,
              ),
          controller: priceController,
          inputHint: '0',
          icon: CatchIcons.paymentsOutlined,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(
              RegExp(context.l10n.hostsEditHostedEventScreenVisiblecopyDD),
            ),
          ],
          textInputAction: TextInputAction.next,
          validator: (value) => _moneyRequiredValidator(
            value,
            currencyCode: state.currencyCode,
            l10n: context.l10n,
          ),
        ),
        CatchField.optionCards<EventAdmissionPreset>(
          title: context.l10n.hostsEditHostedEventScreenLabelAdmissionFormat,
          values: EventAdmissionPreset.values,
          itemTitle: (preset) => preset.title(context.l10n),
          itemDescription: (preset) => preset.description(context.l10n),
          selected: state.admissionPreset,
          onChanged: onAdmissionPresetChanged,
          icon: CatchIcons.howToRegOutlined,
        ),
        if (state.showInviteCode)
          CatchField.input(
            key: CreateEventFormKeys.inviteCode,
            title: context.l10n.hostsEditHostedEventScreenTitleInviteCode,
            controller: inviteCodeController,
            inputHint:
                context.l10n.hostsEditHostedEventScreenPlaceholderCatchDelhi,
            helperText: privateAccessAsync.status == CatchAsyncStatus.loading
                ? context
                      .l10n
                      .hostsEditHostedEventScreenTextLoadingCurrentInviteCode
                : null,
            icon: CatchIcons.lockOutlineRounded,
            textInputAction: TextInputAction.next,
            inputFormatters: [
              FilteringTextInputFormatter.allow(
                RegExp(
                  context.l10n.hostsEditHostedEventScreenVisiblecopyAZaZ09,
                ),
              ),
            ],
            validator: (value) => inviteCodeValidator(value, context.l10n),
          ),
        if (state.showCohortCapsToggle) ...[
          CatchField.toggle(
            key: CreateEventFormKeys.cohortCapsToggle,
            title: context.l10n.hostsEditHostedEventScreenTitleCohortCaps,
            body: context
                .l10n
                .hostsEditHostedEventScreenBodyOptionallyCapStraightMen,
            bodyMaxLines: 5,
            value: state.cohortCapsEnabled,
            onChanged: onCohortCapsEnabledChanged,
          ),
          if (state.showCohortCapsFields)
            CatchSection.containedFieldRows(
              children: [
                CatchField.input(
                  key: CreateEventFormKeys.maxMen,
                  title: context
                      .l10n
                      .hostsEditHostedEventScreenTitleMaxStraightMen,
                  isOptional: true,
                  controller: maxMenController,
                  icon: CatchIcons.maleOutlined,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  textInputAction: TextInputAction.next,
                  validator: (value) =>
                      positiveOptionalValidator(value, context.l10n),
                ),
                CatchField.input(
                  key: CreateEventFormKeys.maxWomen,
                  title: context
                      .l10n
                      .hostsEditHostedEventScreenTitleMaxStraightWomen,
                  isOptional: true,
                  controller: maxWomenController,
                  icon: CatchIcons.femaleOutlined,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  textInputAction: TextInputAction.next,
                  validator: (value) =>
                      positiveOptionalValidator(value, context.l10n),
                ),
              ],
            ),
        ],
        if (state.showRequestToJoinCopy)
          CatchField.read(
            title: state.admissionPreset.title(context.l10n),
            body:
                context.l10n.hostsEditHostedEventScreenTextRequestsAppearInHost,
            bodyMaxLines: 3,
            icon: CatchIcons.howToRegOutlined,
          ),
        if (state.showDynamicPricingToggle) ...[
          CatchField.toggle(
            key: CreateEventFormKeys.dynamicPricingToggle,
            title: context.l10n.hostsEditHostedEventScreenTitleDemandPricing,
            body:
                context.l10n.hostsEditHostedEventScreenBodyIncreasePriceForThe,
            value: state.dynamicPricingEnabled,
            onChanged: onDynamicPricingChanged,
          ),
          if (state.showDynamicPricingFields)
            CatchSection.containedFieldRows(
              children: [
                CatchField.input(
                  key: CreateEventFormKeys.dynamicPricingStep,
                  title: context.l10n
                      .hostsEditHostedEventScreenTitleStepCurrencycode(
                        currencyCode: state.currencyCode,
                      ),
                  controller: dynamicPricingStepController,
                  inputHint: '250',
                  icon: CatchIcons.trendingUpRounded,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  textInputAction: TextInputAction.next,
                  validator: (value) =>
                      positiveRequiredValidator(value, context.l10n),
                ),
                CatchField.input(
                  key: CreateEventFormKeys.dynamicPricingMax,
                  title: context.l10n
                      .hostsEditHostedEventScreenTitleMaxCurrencycode(
                        currencyCode: state.currencyCode,
                      ),
                  controller: dynamicPricingMaxController,
                  inputHint: '1500',
                  icon: CatchIcons.priceChangeOutlined,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  textInputAction: TextInputAction.next,
                  validator: (value) =>
                      positiveRequiredValidator(value, context.l10n),
                ),
              ],
            ),
        ],
        EventAgeRangeField(
          key: CreateEventFormKeys.minAge,
          minAgeController: minAgeController,
          maxAgeController: maxAgeController,
        ),
        CatchField.optionCards<EventCancellationPolicyId>(
          title: context.l10n.hostsEditHostedEventScreenLabelCancellationPolicy,
          values: EventCancellationPolicyId.values,
          itemTitle: (policyId) => policyFor(policyId).title,
          itemDescription: (policyId) => policyFor(policyId).attendeeSummary,
          selected: state.cancellationPolicyId,
          onChanged: onCancellationPolicyChanged,
          icon: CatchIcons.ruleOutlined,
        ),
      ],
    );
  }
}

class ReadOnlyHostedEventPolicyCard extends StatelessWidget {
  const ReadOnlyHostedEventPolicyCard({super.key, required this.event});

  final Event event;

  @override
  Widget build(BuildContext context) {
    final policy = event.effectiveEventPolicy;
    return CatchSection.fieldRows(
      title: context.l10n.hostsEditHostedEventScreenLabelEventPolicy,
      children: [
        CatchField.read(
          title: context.l10n.hostsEditHostedEventScreenTextPolicyLocked,
          body: context
              .l10n
              .hostsEditHostedEventScreenTextCapacityPricingAdmissionAnd,
          bodyMaxLines: 3,
          icon: CatchIcons.lockOutlineRounded,
        ),
        CatchField.read(
          title: context.l10n.hostsEditHostedEventScreenLabelCapacity,
          valueText: context.l10n
              .hostsEditHostedEventScreenVisiblecopyCapacitylimit(
                capacityLimit: event.capacityLimit,
              ),
          icon: CatchIcons.peopleOutline,
        ),
        CatchField.read(
          title: context.l10n.hostsEditHostedEventScreenLabelPrice,
          valueText: event.isFree
              ? context.l10n.hostsEditHostedEventScreenVisiblecopyFree
              : EventFormatters.priceInPaise(
                  event.priceInPaise,
                  currencyCode: event.currency,
                ),
          icon: CatchIcons.paymentsOutlined,
        ),
        CatchField.read(
          title: context.l10n.hostsEditHostedEventScreenLabelAdmission,
          valueText: _admissionPresetFor(policy).title(context.l10n),
          icon: CatchIcons.howToRegOutlined,
        ),
        CatchField.read(
          title: context.l10n.hostsEditHostedEventScreenLabelCancellation,
          valueText: policy.cancellationPolicy.title,
          icon: CatchIcons.ruleOutlined,
        ),
      ],
    );
  }
}

class ReadOnlyHostedEventScheduleCard extends StatelessWidget {
  const ReadOnlyHostedEventScheduleCard({super.key, required this.event});

  final Event event;

  @override
  Widget build(BuildContext context) {
    return CatchSection.fieldRows(
      title: context.l10n.hostsEditHostedEventScreenLabelSchedule,
      children: [
        CatchField.read(
          title: event.shortDateLabel,
          body: event.timeRangeLabel,
          icon: CatchIcons.calendarTodayOutlined,
        ),
        CatchField.read(
          body: context
              .l10n
              .hostsEditHostedEventScreenTextScheduleChangesAreBlocked,
          bodyMaxLines: 3,
          icon: CatchIcons.lockOutlineRounded,
        ),
      ],
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

String? _moneyRequiredValidator(
  String? value, {
  required String currencyCode,
  required AppLocalizations l10n,
}) {
  if (value == null || value.trim().isEmpty) {
    return l10n.sharedValidationRequired;
  }
  final amount = parseMajorCurrencyAmountToMinorUnits(
    value,
    currencyCode: currencyCode,
  );
  if (amount == null) return l10n.sharedValidationInvalid;
  return null;
}
