import 'package:catch_dating_app/activity/domain/activity_taxonomy.dart';
import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/clubs/domain/club_host_defaults.dart';
import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/business_rules.dart';
import 'package:catch_dating_app/core/city_catalog.dart';
import 'package:catch_dating_app/core/country_markets.dart';
import 'package:catch_dating_app/core/device_location.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_adaptive_picker.dart';
import 'package:catch_dating_app/core/widgets/catch_error_banner.dart';
import 'package:catch_dating_app/core/widgets/catch_error_snackbar.dart';
import 'package:catch_dating_app/core/widgets/catch_form_step_flow.dart';
import 'package:catch_dating_app/core/widgets/catch_form_step_overview.dart';
import 'package:catch_dating_app/core/widgets/catch_screen_scaffold.dart';
import 'package:catch_dating_app/core/widgets/catch_section_layout.dart';
import 'package:catch_dating_app/core/widgets/mutation_error_util.dart';
import 'package:catch_dating_app/core/widgets/ordered_photo_picker.dart';
import 'package:catch_dating_app/event_policies/domain/event_policy.dart';
import 'package:catch_dating_app/event_policies/domain/event_policy_defaults.dart';
import 'package:catch_dating_app/event_success/domain/event_success_defaults.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/domain/event_attendee.dart';
import 'package:catch_dating_app/events/domain/event_constraints.dart';
import 'package:catch_dating_app/events/domain/event_draft.dart';
import 'package:catch_dating_app/events/domain/event_formatters.dart';
import 'package:catch_dating_app/events/domain/event_itinerary.dart';
import 'package:catch_dating_app/events/domain/organizer_event_venue.dart';
import 'package:catch_dating_app/events/domain/route_event_plan.dart';
import 'package:catch_dating_app/events/events.dart'
    show LocationPickerResult, LocationPickerScreen;
import 'package:catch_dating_app/exceptions/error_logger.dart';
import 'package:catch_dating_app/hosts/domain/host_roster_import.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/create/create_event_controller.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/create/create_event_draft_controller.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/create/create_event_draft_restore_state.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/create/create_event_draft_snapshot.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/create/create_event_location_state.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/create/create_event_photo_draft_state.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/create/create_event_policy_state.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/create/create_event_prefill.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/create/create_event_schedule_state.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/create/create_event_success_screen.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/create/create_event_wizard_state.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/widgets/create_event_adaptive_workspace.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/widgets/create_event_guests_section.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/widgets/create_event_step_header.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/widgets/draft_picker_sheet.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/widgets/event_details_step.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/widgets/event_policy_step.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/widgets/event_success_step.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/widgets/when_step.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/widgets/where_step.dart';
import 'package:catch_dating_app/hosts/presentation/widgets/host_draft_exit_dialog.dart';
import 'package:catch_dating_app/hosts/presentation/widgets/host_operational_roster_panel.dart';
import 'package:catch_dating_app/hosts/presentation/widgets/stepper_footer.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:catch_dating_app/locations/domain/location_coordinate.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

DateTime _systemNow() => DateTime.now();

class CreateEventUnsavedChangesDialog extends StatelessWidget {
  const CreateEventUnsavedChangesDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return const HostDraftExitDialog();
  }
}

Future<HostDraftExitDecision?> showCreateEventUnsavedChangesDialog(
  BuildContext context,
) => showHostDraftExitDialog(context);

class CreateEventScreen extends ConsumerStatefulWidget {
  const CreateEventScreen({
    super.key,
    required this.club,
    this.loadMapTiles = true,
    this.now = _systemNow,
    this.initialDraft,
    this.initialPrefill,
    this.promptForDraftsOnStart = true,
    this.initialStep = 0,
    this.formAutovalidateMode = AutovalidateMode.disabled,
    this.initialPickedEventPhotos = const <PickedEventPhoto>[],
    this.externalBookingMode = false,
    this.initialRosterImportPlan,
  }) : assert(
         initialDraft == null || initialPrefill == null,
         'A create flow cannot restore a draft and apply a repeat prefill.',
       );

  final Club club;
  final EventDraft? initialDraft;
  final CreateEventPrefill? initialPrefill;
  final bool promptForDraftsOnStart;
  final int initialStep;
  final AutovalidateMode formAutovalidateMode;
  final List<PickedEventPhoto> initialPickedEventPhotos;
  final bool externalBookingMode;
  final HostRosterImportPlan? initialRosterImportPlan;

  /// Tests can disable network tiles while still exercising map callbacks.
  final bool loadMapTiles;

  /// Current time source, injectable so same-day time validation is testable.
  final DateTime Function() now;

  @override
  ConsumerState<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends ConsumerState<CreateEventScreen> {
  late final PageController _pageController;
  int _currentStep = 0;
  bool _isReviewing = false;
  late bool _externalBookingMode;
  bool _allowRoutePop = false;
  bool _showValidationErrors = false;
  Event? _createdEvent;
  HostRosterImportPlan? _pendingRosterImport;
  EventAttendeeImportResult? _rosterImportResult;
  bool _rosterImportFailed = false;
  String? _rosterFileName;
  String? _rosterFileFingerprint;
  int? _rosterReadyCount;

  // Draft support
  String? _activeDraftId;
  Object? _lastSavedDraftSignature;
  late Object _initialDraftContentSignature;
  bool _checkedDrafts = false;

  final _eventDetailsFormKey = GlobalKey<FormState>();
  final _whenFormKey = GlobalKey<FormState>();
  final _eventPolicyFormKey = GlobalKey<FormState>();

  List<CatchFormStepSpec> get _stepSpecs => createEventWizardStepSpecs(
    l10n: context.l10n,
    externalBookingMode: _externalBookingMode,
    eventDetailsFormKey: _eventDetailsFormKey,
    scheduleFormKey: _whenFormKey,
    eventPolicyFormKey: _eventPolicyFormKey,
  );

  // Step 2 — When
  final _dateController = TextEditingController();
  final _startTimeController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedStartTime;
  int _durationMinutes = CatchBusinessRules.eventDefaultDurationMinutes;
  String? _scheduleErrorText;

  // Step 1 — Where
  final _meetingPointController = TextEditingController();
  final _locationDetailsController = TextEditingController();
  CreateEventLocationState _locationState = const CreateEventLocationState();

  // Step 0 — Event details
  final _nameController = TextEditingController();
  final _distanceController = TextEditingController();
  final _capacityController = TextEditingController();
  final _priceController = TextEditingController();
  final _customActivityLabelController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _externalEventUrlController = TextEditingController();
  final _externalEventIdController = TextEditingController();
  ExternalBookingProvider _externalBookingProvider =
      ExternalBookingProvider.generic;
  EventRuntimeWalkInPolicy _runtimeWalkInPolicy =
      EventRuntimeWalkInPolicy.hostApproval;
  ActivityKind _selectedActivityKind = ActivityKind.socialRun;
  EventInteractionModel _selectedInteractionModel =
      ActivityKind.socialRun.defaultInteractionModel;
  PaceLevel? _selectedPace;
  RouteEventPlan? _routePlan = RouteEventPlan.socialRun;
  List<EventItineraryItem> _itinerary = const [];
  var _eventPhotos = const CreateEventPhotoDraftState.empty();

  // Step 3 — Rules
  final _minAgeController = TextEditingController();
  final _maxAgeController = TextEditingController();
  final _maxMenController = TextEditingController();
  final _maxWomenController = TextEditingController();
  final _inviteCodeController = TextEditingController();
  final _dynamicPricingStepController = TextEditingController();
  final _dynamicPricingMaxController = TextEditingController();
  final _crossPathsPairCapacityController = TextEditingController(text: '2');
  CreateEventPolicyState _policyState = const CreateEventPolicyState();
  EventSuccessDefaults _eventSuccessDefaults = const EventSuccessDefaults();

  String get _eventCurrencyCode =>
      currencyCodeForCityName(widget.club.location);

  CreateEventScheduleState get _scheduleState => CreateEventScheduleState(
    selectedDate: _selectedDate,
    selectedStartTime: _selectedStartTime,
    durationMinutes: _durationMinutes,
  );

  DateTime? get _selectedStartDateTime => _scheduleState.selectedStartDateTime;

  EventConstraints get _constraints => EventConstraints(
    minAge: _eventPolicyDefaults.minAge,
    maxAge: _eventPolicyDefaults.maxAge,
    maxMen: _eventPolicyDefaults.toConstraints().maxMen,
    maxWomen: _eventPolicyDefaults.toConstraints().maxWomen,
  );

  EventPolicyDefaults get _eventPolicyDefaults =>
      (_externalBookingMode ? const CreateEventPolicyState() : _policyState)
          .defaultsFromFields(
            minAge: _minAgeController.text,
            maxAge: _maxAgeController.text,
            maxMen: _externalBookingMode ? '' : _maxMenController.text,
            maxWomen: _externalBookingMode ? '' : _maxWomenController.text,
            dynamicPricingStep: _dynamicPricingStepController.text,
            dynamicPricingMax: _dynamicPricingMaxController.text,
            currencyCode: _eventCurrencyCode,
          );

  EventPolicyBundle get _eventPolicy {
    if (_externalBookingMode) {
      return EventPolicyBundle.openEvent(
        capacityLimit: int.parse(_capacityController.text.trim()),
        basePriceInPaise: 0,
      );
    }
    return _policyState.eventPolicyFromFields(
      capacity: _capacityController.text,
      basePrice: _externalBookingMode ? '0' : _priceController.text,
      inviteCode: _inviteCodeController.text,
      minAge: _minAgeController.text,
      maxAge: _maxAgeController.text,
      maxMen: _maxMenController.text,
      maxWomen: _maxWomenController.text,
      dynamicPricingStep: _dynamicPricingStepController.text,
      dynamicPricingMax: _dynamicPricingMaxController.text,
      currencyCode: _eventCurrencyCode,
      crossPathsPairCapacity: _crossPathsPairCapacityController.text,
    );
  }

  int get _eventSuccessTargetAttendeeCount {
    final parsed = int.tryParse(_capacityController.text.trim());
    if (parsed == null || parsed < 1) return 20;
    return parsed;
  }

  VoidCallback? get _decreaseDurationCallback =>
      _scheduleState.canDecreaseDuration
      ? () => setState(
          () => _durationMinutes = _scheduleState
              .decreaseDuration()
              .durationMinutes,
        )
      : null;

  VoidCallback? get _increaseDurationCallback =>
      _scheduleState.canIncreaseDuration
      ? () => setState(
          () => _durationMinutes = _scheduleState
              .increaseDuration()
              .durationMinutes,
        )
      : null;

  @override
  void initState() {
    super.initState();
    _externalBookingMode =
        widget.initialDraft?.externalBookingMode ??
        widget.initialPrefill?.values.externalBookingMode ??
        (widget.externalBookingMode || widget.initialRosterImportPlan != null);
    _currentStep = widget.initialStep
        .clamp(0, CreateEventWizardStep.values.length - 1)
        .toInt();
    _pageController = PageController(initialPage: _currentStep);
    _applyClubDefaults(widget.club.hostDefaults);
    final initialRosterImportPlan = widget.initialRosterImportPlan;
    if (initialRosterImportPlan != null) {
      _setRosterPlan(initialRosterImportPlan);
    } else if (_externalBookingMode) {
      _priceController.text = '0';
    }
    if (_externalBookingMode && !_eventSuccessDefaults.enabled) {
      _eventSuccessDefaults = _eventSuccessDefaults.copyWith(enabled: true);
    }
    final initialDraft = widget.initialDraft;
    if (initialDraft != null) {
      _activeDraftId = initialDraft.id;
      _applyDraftValues(initialDraft);
      _lastSavedDraftSignature = _currentDraftContentSignature;
      // A draft selected by the calling surface is already the user's choice;
      // do not reload the same collection and show the picker again.
      _checkedDrafts = true;
    }
    if (!widget.promptForDraftsOnStart) _checkedDrafts = true;
    final initialPrefill = widget.initialPrefill;
    if (initialPrefill != null) {
      _applyDraftValues(initialPrefill.values);
      // A repeat template is not a persisted draft. Do not replace it with the
      // saved-draft picker or assign it a local draft lifecycle.
      _checkedDrafts = true;
    }
    if (widget.initialPickedEventPhotos.isNotEmpty) {
      _eventPhotos = CreateEventPhotoDraftState.fromPicked(
        widget.initialPickedEventPhotos,
      );
    }
    _initialDraftContentSignature = _currentDraftContentSignature;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkForDrafts();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _dateController.dispose();
    _startTimeController.dispose();
    _meetingPointController.dispose();
    _locationDetailsController.dispose();
    _nameController.dispose();
    _distanceController.dispose();
    _capacityController.dispose();
    _priceController.dispose();
    _customActivityLabelController.dispose();
    _descriptionController.dispose();
    _externalEventUrlController.dispose();
    _externalEventIdController.dispose();
    _minAgeController.dispose();
    _maxAgeController.dispose();
    _maxMenController.dispose();
    _maxWomenController.dispose();
    _inviteCodeController.dispose();
    _dynamicPricingStepController.dispose();
    _dynamicPricingMaxController.dispose();
    _crossPathsPairCapacityController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final today = DateUtils.dateOnly(widget.now());
    final picked = await showCatchDatePicker(
      context: context,
      initialDate: _selectedDate ?? today,
      firstDate: today,
      lastDate: today.add(const Duration(days: 365)),
      title: context.l10n.hostsCreateEventScreenTitleEventDate,
    );
    if (picked != null) {
      final result = _scheduleState.selectDate(picked, now: widget.now());
      setState(() {
        _selectedDate = result.selectedDate;
        _selectedStartTime = result.selectedStartTime;
        _dateController.text = result.dateText;
        _startTimeController.text = result.startTimeText;
        _scheduleErrorText = result.errorText;
      });
    }
  }

  Future<void> _pickStartTime() async {
    final picked = await showCatchTimePicker(
      context: context,
      initialTime:
          _selectedStartTime ??
          _scheduleState.initialStartTime(now: widget.now()),
      title: context.l10n.hostsCreateEventScreenTitleStartTime,
    );
    if (picked != null) {
      final result = _scheduleState.selectStartTime(picked, now: widget.now());
      setState(() {
        _selectedDate = result.selectedDate;
        _selectedStartTime = result.selectedStartTime;
        _startTimeController.text = result.startTimeText;
        _scheduleErrorText = result.errorText;
      });
    }
  }

  Future<void> _pickLocation() async {
    final deviceLocation = ref.read(deviceLocationProvider).asData?.value;
    final result = await Navigator.of(context).push<LocationPickerResult>(
      MaterialPageRoute(
        builder: (_) => LocationPickerScreen(
          countryIsoCode: countryIsoCodeForCityName(widget.club.location),
          initialLocation: _locationState.startingPoint,
          initialCenter: _locationState.initialCenter(deviceLocation),
          initialLabel: _locationState.initialLabel(
            meetingPoint: _meetingPointController.text,
          ),
          loadMapTiles: widget.loadMapTiles,
        ),
        fullscreenDialog: true,
      ),
    );
    if (result != null) {
      final selection = _locationState.selectLocation(
        coordinate: result.coordinate,
        displayName: result.displayName,
        address: result.address,
        placeId: result.placeId,
      );
      setState(() {
        _locationState = selection.state;
        final meetingPointText = selection.meetingPointText;
        if (meetingPointText != null) {
          _meetingPointController.text = meetingPointText;
        }
      });
    }
  }

  void _selectVenue(OrganizerEventVenue venue) {
    final selection = _locationState.selectVenue(
      venue,
      currentCapacityText: _capacityController.text,
    );
    setState(() {
      _locationState = selection.state;
      _meetingPointController.text = selection.meetingPointText;
      _locationDetailsController.text = selection.locationDetailsText;
      final capacity = selection.suggestedCapacityText;
      if (capacity != null) _capacityController.text = capacity;
    });
  }

  Future<EventMeetingLocation?> _pickItineraryLocation(
    EventMeetingLocation? current,
  ) async {
    final deviceLocation = ref.read(deviceLocationProvider).asData?.value;
    final meetingLocation = _currentMeetingLocation;
    final result = await Navigator.of(context).push<LocationPickerResult>(
      MaterialPageRoute(
        builder: (_) => LocationPickerScreen(
          countryIsoCode: countryIsoCodeForCityName(widget.club.location),
          initialLocation: current == null
              ? null
              : LocationCoordinate(current.latitude, current.longitude),
          initialCenter:
              (current == null
                  ? _locationState.startingPoint
                  : LocationCoordinate(current.latitude, current.longitude)) ??
              deviceLocation,
          initialLabel: current?.name,
          loadMapTiles: widget.loadMapTiles,
        ),
        fullscreenDialog: true,
      ),
    );
    if (result == null || !mounted) return null;
    return EventMeetingLocation(
      name:
          result.displayName ??
          current?.name ??
          meetingLocation?.name ??
          context.l10n.eventsMapPinTileTitlePinnedLocation,
      address: result.address,
      placeId: result.placeId,
      latitude: result.coordinate.latitude,
      longitude: result.coordinate.longitude,
    ).normalized();
  }

  Future<void> _pickEventPhotos() async {
    final picked = await ref
        .read(createEventControllerProvider.notifier)
        .pickEventPhotos();
    if (!mounted || picked.isEmpty) return;
    setState(() => _eventPhotos = _eventPhotos.addPicked(picked));
  }

  void _removeEventPhoto(int index) {
    setState(() => _eventPhotos = _eventPhotos.removeAt(index));
  }

  void _reorderEventPhoto(int fromIndex, int toIndex) {
    setState(() => _eventPhotos = _eventPhotos.reorder(fromIndex, toIndex));
  }

  void _setRosterPlan(HostRosterImportPlan plan) {
    _pendingRosterImport = plan;
    _rosterFileName = plan.fileName;
    _rosterFileFingerprint = plan.fileFingerprint;
    _rosterReadyCount = plan.readyCount;
    _externalBookingProvider = plan.bookingProvider;
    final capacity = int.tryParse(_capacityController.text.trim()) ?? 0;
    if (capacity < plan.readyCount) {
      _capacityController.text = plan.readyCount.toString();
    }
    _priceController.text = '0';
  }

  Future<void> _pickRoster() async {
    try {
      final table = await ref
          .read(createEventControllerProvider.notifier)
          .pickRosterFile(providerHint: _externalBookingProvider);
      if (table == null || !mounted) return;
      final plan = await showHostRosterMapping(
        context,
        table,
        suggestedRevenueAmountMinor:
            ((double.tryParse(_priceController.text.trim()) ?? 0) * 100)
                .round(),
        defaultRevenueCurrency: _eventCurrencyCode,
      );
      if (plan == null || !mounted) return;
      setState(() => _setRosterPlan(plan));
    } on HostRosterImportException catch (error) {
      if (mounted) {
        showCatchSnackBar(
          context,
          hostRosterImportIssueCopy(context, error.issue),
        );
      }
    } on Object catch (error) {
      if (mounted) showCatchErrorSnackBar(context, error);
    }
  }

  Future<void> _handleCloseIntent(CreateEventWizardCloseIntent intent) async {
    if (_requestPending) return;
    switch (intent) {
      case CreateEventWizardCloseIntent.confirmUnsavedChanges:
        final decision = await showCreateEventUnsavedChangesDialog(context);
        if (!mounted || decision == null) return;
        switch (decision) {
          case HostDraftExitDecision.keepEditing:
            return;
          case HostDraftExitDecision.discardAndExit:
            _completeClose();
          case HostDraftExitDecision.saveDraftAndExit:
            if (await _saveDraft(showSuccess: false)) {
              _completeClose();
            }
        }
      case CreateEventWizardCloseIntent.close:
        _completeClose();
    }
  }

  void _handlePreviousIntent(CreateEventWizardPreviousIntent intent) {
    if (_requestPending) return;
    switch (intent) {
      case CreateEventWizardPreviousIntent.previousStep:
        _showStep(_currentStep - 1);
      case CreateEventWizardPreviousIntent.returnToSteps:
        _showStep(_currentStep);
    }
  }

  void _handlePrimaryIntent(CreateEventWizardPrimaryIntent intent) {
    if (_requestPending) return;

    switch (intent) {
      case CreateEventWizardPrimaryIntent.nextStep:
        _goToStep(_currentStep + 1);
      case CreateEventWizardPrimaryIntent.review:
        setState(() => _isReviewing = true);
      case CreateEventWizardPrimaryIntent.submit:
        if (_validateAllInput()) _submit();
    }
  }

  void _handleSuccessNavigationIntent(
    CreateEventSuccessNavigationIntent intent,
    CreateEventSuccessNavigationState state,
  ) {
    final effect = CreateEventSuccessNavigationEffect.resolve(
      intent: intent,
      state: state,
    );
    switch (effect.destination) {
      case CreateEventSuccessNavigationDestination.manageEventRoute:
        context.goNamed(
          Routes.hostAppEventManageScreen.name,
          pathParameters: effect.pathParameters,
          extra: effect.extra,
        );
      case CreateEventSuccessNavigationDestination.popRoute:
        Navigator.of(context).pop();
    }
  }

  void _goToStep(int step) {
    if (step < 0 || step >= _stepSpecs.length || _requestPending) return;
    setState(() {
      _isReviewing = false;
      _currentStep = step;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_pageController.hasClients) return;
      _pageController.animateToPage(
        step,
        duration: CatchMotion.pageStep,
        curve: CatchMotion.easeInOutCurve,
      );
    });
  }

  void _showStep(int step) {
    if (step < 0 || step >= _stepSpecs.length || _requestPending) return;
    setState(() {
      _isReviewing = false;
      _currentStep = step;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_pageController.hasClients) return;
      _pageController.jumpToPage(step);
    });
  }

  bool _validateAllInput() {
    var formsAreValid = true;
    int? firstInvalidForm;
    for (var index = 0; index < _stepSpecs.length; index++) {
      final form = _stepSpecs[index].formKey?.currentState;
      if (form != null && !form.validate()) {
        formsAreValid = false;
        firstInvalidForm ??= index;
      }
    }
    final review = _reviewState;
    final firstInvalid = review.firstIncompleteStep ?? firstInvalidForm;
    if (!formsAreValid || !review.canSubmit) {
      final scheduleError = _scheduleState.errorText(now: widget.now());
      setState(() {
        _showValidationErrors = true;
        _scheduleErrorText = scheduleError;
      });
      if (firstInvalid != null) _showStep(firstInvalid);
      return false;
    }
    return true;
  }

  void _submit() {
    final startTime = _selectedStartDateTime!;
    final endTime = startTime.add(Duration(minutes: _durationMinutes));
    final meetingLocation = _currentMeetingLocation;
    if (meetingLocation == null) return;

    final externalOrigin = _externalBookingMode
        ? ExternalEventOriginInput(
            provider: _externalBookingProvider,
            externalEventId: _trimmedTextOrNull(_externalEventIdController),
            externalEventUrl: _trimmedTextOrNull(_externalEventUrlController),
            sourceExternalEventId: _trimmedTextOrNull(
              _externalEventIdController,
            ),
            adapterVersion: _externalBookingProvider.rosterAdapterVersion,
          )
        : null;
    final effectiveEventSuccessDefaults = _externalBookingMode
        ? _eventSuccessDefaults.copyWith(enabled: true)
        : _eventSuccessDefaults;

    final rosterPlan = _pendingRosterImport;
    CreateEventController.submitMutation.run(ref, (tx) async {
      final createdEvent = await tx
          .get(createEventControllerProvider.notifier)
          .submit(
            clubId: widget.club.id,
            name: _nameController.text,
            startTime: startTime,
            endTime: endTime,
            meetingLocation: meetingLocation,
            sourceVenueId: _locationState.sourceVenueId,
            itinerary: _itinerary,
            eventFormat: _selectedEventFormat,
            distanceKm: _distanceKmForSelectedActivity(),
            pace: _selectedPace ?? PaceLevel.easy,
            description: _descriptionController.text.trim(),
            currency: _eventCurrencyCode,
            constraints: _constraints,
            eventPolicy: _eventPolicy,
            inviteCode: _externalBookingMode
                ? null
                : _trimmedTextOrNull(_inviteCodeController),
            photoImages: _eventPhotos.pickedPhotos
                .map((photo) => photo.image)
                .toList(),
            eventSuccessDefaults: effectiveEventSuccessDefaults,
            externalOrigin: externalOrigin,
            runtimeWalkInPolicy: _externalBookingMode
                ? _runtimeWalkInPolicy
                : null,
          );
      EventAttendeeImportResult? rosterResult;
      var rosterFailed = false;
      if (rosterPlan != null) {
        try {
          rosterResult = await tx
              .get(createEventControllerProvider.notifier)
              .importRoster(eventId: createdEvent.id, plan: rosterPlan);
        } on Object catch (error, stackTrace) {
          // The event already exists. Preserve that success and route the host
          // to the event roster for a safe, idempotent retry of the same file.
          ref
              .read(errorLoggerProvider)
              .logError(
                error,
                stackTrace,
                reason: 'Create event roster import failed after creation.',
              );
          rosterFailed = true;
        }
      }
      if (mounted) {
        setState(() {
          _createdEvent = createdEvent;
          _rosterImportResult = rosterResult;
          _rosterImportFailed = rosterFailed;
        });
      }

      // Delete the restored-from draft after successful submission.
      final deleteIntent =
          _draftSideEffectState.deleteAfterSuccessfulSubmitIntent;
      if (deleteIntent != null) {
        await _deleteDraft(deleteIntent);
      }

      return createdEvent;
    }).ignore();
  }

  bool get _hasUnsavedChanges {
    return _draftActionState.hasUnsavedChanges;
  }

  bool get _requestPending =>
      ref.read(CreateEventController.submitMutation).isPending ||
      ref.read(CreateEventDraftController.saveDraftMutation).isPending;

  CreateEventWizardReviewState get _reviewState =>
      CreateEventWizardReviewState.resolve(
        activeSteps: _stepSpecs,
        name: _nameController.text,
        activityKind: _selectedActivityKind,
        customActivityLabel: _customActivityLabelController.text,
        distance: _distanceController.text,
        pace: _selectedPace,
        externalBookingMode: _externalBookingMode,
        externalEventUrl: _externalEventUrlController.text,
        rosterAttachmentRequired:
            _rosterFileFingerprint != null && _pendingRosterImport == null,
        hasStartingPoint: _locationState.hasStartingPoint,
        meetingPoint: _meetingPointController.text,
        scheduleState: _scheduleState,
        now: widget.now(),
        capacity: _capacityController.text,
        rosterReadyCount: _pendingRosterImport?.readyCount,
        price: _priceController.text,
        currencyCode: _eventCurrencyCode,
        admissionPreset: _policyState.admissionPreset,
        inviteCode: _inviteCodeController.text,
        cohortCapsEnabled: _policyState.cohortCapsEnabled,
        maxMen: _maxMenController.text,
        maxWomen: _maxWomenController.text,
        crossPathsPairInventoryEnabled:
            _policyState.crossPathsPairInventoryEnabled,
        crossPathsPairCapacity: _crossPathsPairCapacityController.text,
        dynamicPricingEnabled: _policyState.dynamicPricingEnabled,
        dynamicPricingStep: _dynamicPricingStepController.text,
        dynamicPricingMax: _dynamicPricingMaxController.text,
        minAge: _minAgeController.text,
        maxAge: _maxAgeController.text,
      );

  Object get _currentDraftContentSignature => _currentDraftSnapshot.signature;

  List<CatchFormReviewSummaryItem> get _reviewSummaryItems {
    final start = _selectedStartDateTime;
    final end = start?.add(Duration(minutes: _durationMinutes));
    final capacity = int.tryParse(_capacityController.text.trim());
    final priceInMinorUnits = parseMajorCurrencyAmountToMinorUnits(
      _priceController.text,
      currencyCode: _eventCurrencyCode,
    );
    final activity = _selectedEventFormat.label;
    return [
      CatchFormReviewSummaryItem(
        label: context.l10n.hostsEventDetailsStepTitleEventName,
        value: _nameController.text.trim().isEmpty
            ? context.l10n.hostsWizardStatusNeedsInformation
            : _nameController.text.trim(),
        icon: CatchIcons.eventAvailableOutlined,
      ),
      CatchFormReviewSummaryItem(
        label: context.l10n.hostsCreateEventReviewActivity,
        value: _selectedEventFormat.isDistanceBased
            ? '$activity · ${_distanceController.text.trim()} km · ${_selectedPace?.label ?? context.l10n.hostsWizardStatusNeedsInformation}'
            : activity,
        icon: CatchIcons.eventAvailableOutlined,
      ),
      CatchFormReviewSummaryItem(
        label: context.l10n.hostsCreateEventReviewBooking,
        value: _externalBookingMode
            ? context.l10n.hostsCreateEventReviewExternalBookings(
                provider: _externalBookingProviderLabel,
              )
            : context.l10n.hostsCreateEventReviewCatchBookings,
        icon: CatchIcons.confirmationNumberOutlined,
      ),
      if (_externalBookingMode)
        CatchFormReviewSummaryItem(
          label: context.l10n.hostsCreateEventRosterTitle,
          value: _rosterFileName == null
              ? context.l10n.hostsCreateEventRosterLater
              : _pendingRosterImport == null
              ? context.l10n.hostsCreateEventRosterReattach(
                  fileName: _rosterFileName!,
                )
              : context.l10n.hostsCreateEventRosterAttached(
                  fileName: _rosterFileName!,
                  ready: _pendingRosterImport!.readyCount,
                  review: _pendingRosterImport!.needsReviewCount,
                  excluded: _pendingRosterImport!.excludedCount,
                ),
          icon: CatchIcons.groupsOutlined,
        ),
      CatchFormReviewSummaryItem(
        label: context.l10n.hostsCreateEventReviewLocation,
        value: _meetingPointController.text.trim().isEmpty
            ? context.l10n.hostsWizardStatusNeedsInformation
            : _meetingPointController.text.trim(),
        icon: CatchIcons.locationOnOutlined,
      ),
      CatchFormReviewSummaryItem(
        label: context.l10n.hostsCreateEventReviewSchedule,
        value: start == null || end == null
            ? context.l10n.hostsWizardStatusNeedsInformation
            : '${EventFormatters.longDate(start)} · ${EventFormatters.timeRange(start, end)}',
        icon: CatchIcons.calendarMonthOutlined,
      ),
      CatchFormReviewSummaryItem(
        label: context.l10n.hostsCreateEventReviewCapacity,
        value: capacity == null
            ? context.l10n.hostsWizardStatusNeedsInformation
            : context.l10n.hostsCreateEventReviewCapacityValue(count: capacity),
        icon: CatchIcons.peopleOutline,
      ),
      CatchFormReviewSummaryItem(
        label: context.l10n.hostsCreateEventReviewPrice,
        value: _externalBookingMode
            ? context.l10n.hostsCreateEventReviewExternalPrice
            : priceInMinorUnits == null
            ? context.l10n.hostsWizardStatusNeedsInformation
            : priceInMinorUnits == 0
            ? context.l10n.hostsCreateEventReviewFree
            : EventFormatters.priceInPaise(
                priceInMinorUnits,
                currencyCode: _eventCurrencyCode,
              ),
        icon: CatchIcons.paymentsOutlined,
      ),
      if (!_externalBookingMode)
        CatchFormReviewSummaryItem(
          label: context.l10n.hostsCreateEventReviewAdmission,
          value: _policyState.admissionPreset.title(context.l10n),
          icon: CatchIcons.howToRegOutlined,
        ),
    ];
  }

  String get _externalBookingProviderLabel =>
      switch (_externalBookingProvider) {
        ExternalBookingProvider.catchPlatform =>
          context.l10n.hostsEventDetailsStepExternalProviderCatch,
        ExternalBookingProvider.generic =>
          context.l10n.hostsEventDetailsStepExternalProviderOther,
        ExternalBookingProvider.luma =>
          context.l10n.hostsEventDetailsStepExternalProviderLuma,
        ExternalBookingProvider.eventbrite =>
          context.l10n.hostsEventDetailsStepExternalProviderEventbrite,
        ExternalBookingProvider.partiful =>
          context.l10n.hostsEventDetailsStepExternalProviderPartiful,
        ExternalBookingProvider.posh =>
          context.l10n.hostsEventDetailsStepExternalProviderPosh,
        ExternalBookingProvider.bookmyshow =>
          context.l10n.hostsEventDetailsStepExternalProviderBookMyShow,
        ExternalBookingProvider.district =>
          context.l10n.hostsEventDetailsStepExternalProviderDistrict,
        ExternalBookingProvider.sortmyscene =>
          context.l10n.hostsEventDetailsStepExternalProviderSortMyScene,
        ExternalBookingProvider.airbnb =>
          context.l10n.hostsEventDetailsStepExternalProviderAirbnbExperiences,
      };

  CreateEventDraftSideEffectState get _draftSideEffectState =>
      CreateEventDraftSideEffectState(
        hasCheckedDrafts: _checkedDrafts,
        activeDraftId: _activeDraftId,
      );

  CreateEventDraftActionState get _draftActionState =>
      CreateEventDraftActionState(
        activeDraftId: _activeDraftId,
        initialDraftContentSignature: _initialDraftContentSignature,
        lastSavedDraftSignature: _lastSavedDraftSignature,
        currentDraftContentSignature: _currentDraftContentSignature,
      );

  CreateEventDraftSnapshot get _currentDraftSnapshot =>
      CreateEventDraftSnapshot(
        name: _trimmedTextOrNull(_nameController),
        distance: _trimmedTextOrNull(_distanceController),
        capacity: _trimmedTextOrNull(_capacityController),
        price: _trimmedTextOrNull(_priceController),
        description: _trimmedTextOrNull(_descriptionController),
        externalBookingMode: _externalBookingMode,
        externalBookingProvider: _externalBookingMode
            ? _externalBookingProvider.name
            : null,
        externalEventUrl: _externalBookingMode
            ? _trimmedTextOrNull(_externalEventUrlController)
            : null,
        externalEventId: _externalBookingMode
            ? _trimmedTextOrNull(_externalEventIdController)
            : null,
        runtimeWalkInPolicy: _externalBookingMode
            ? _runtimeWalkInPolicy.name
            : null,
        rosterFileName: _externalBookingMode ? _rosterFileName : null,
        rosterFileFingerprint: _externalBookingMode
            ? _rosterFileFingerprint
            : null,
        rosterReadyCount: _externalBookingMode ? _rosterReadyCount : null,
        activityKind: _selectedActivityKind.name,
        customActivityLabel: _customActivityLabelDraftValue,
        interactionModel: _interactionModelDraftValue,
        paceName: _selectedPace?.name,
        routePlan: _routePlan,
        itinerary: _itinerary,
        meetingPoint: _trimmedTextOrNull(_meetingPointController),
        locationDetails: _trimmedTextOrNull(_locationDetailsController),
        meetingLocationAddress: _locationState.meetingLocationAddress,
        meetingLocationPlaceId: _locationState.meetingLocationPlaceId,
        sourceVenueId: _locationState.sourceVenueId,
        startingPointLat: _locationState.startingPoint?.latitude,
        startingPointLng: _locationState.startingPoint?.longitude,
        selectedDateMillis: _selectedDate?.millisecondsSinceEpoch,
        selectedStartHour: _selectedStartTime?.hour,
        selectedStartMinute: _selectedStartTime?.minute,
        durationMinutes: _durationMinutes,
        minAge: _trimmedTextOrNull(_minAgeController),
        maxAge: _trimmedTextOrNull(_maxAgeController),
        maxMen: _trimmedTextOrNull(_maxMenController),
        maxWomen: _trimmedTextOrNull(_maxWomenController),
        cohortCapsEnabled: _policyState.cohortCapsEnabled,
        admissionPreset: _policyState.draftAdmissionPresetName,
        inviteCode: _trimmedTextOrNull(_inviteCodeController),
        dynamicPricingEnabled: _policyState.dynamicPricingEnabled,
        dynamicPricingStep: _trimmedTextOrNull(_dynamicPricingStepController),
        dynamicPricingMax: _trimmedTextOrNull(_dynamicPricingMaxController),
        cancellationPolicy: _policyState.cancellationPolicyId.name,
        crossPathsPairInventoryEnabled:
            _policyState.crossPathsPairInventoryEnabled,
        crossPathsPairCapacity: _trimmedTextOrNull(
          _crossPathsPairCapacityController,
        ),
        eventSuccessDefaults: _eventSuccessDefaults,
        eventPhotoIds: _eventPhotos.signature,
      );

  Future<void> _checkForDrafts() async {
    final sideEffectState = _draftSideEffectState;
    if (!sideEffectState.shouldLoadDrafts) return;
    _checkedDrafts = true;

    final drafts = await ref
        .read(createEventDraftControllerProvider.notifier)
        .loadDrafts(clubId: widget.club.id);
    if (!mounted || !sideEffectState.shouldShowDraftPicker(drafts)) return;

    final picked = await showDraftPickerSheet(
      context: context,
      drafts: drafts,
      onDeleteDraft: _deleteDraftFromPicker,
    );
    if (!mounted) return;

    if (picked != null) {
      _restoreFromDraft(picked);
    }
  }

  void _restoreFromDraft(EventDraft draft) {
    _activeDraftId = draft.id;

    setState(() => _applyDraftValues(draft));
    _lastSavedDraftSignature = _currentDraftContentSignature;
  }

  void _applyDraftValues(EventDraft draft) {
    _externalBookingMode = draft.externalBookingMode;
    final restore = CreateEventDraftRestoreState.fromDraft(
      draft,
      now: widget.now(),
    );

    // Event details
    if (restore.nameText != null) {
      _nameController.text = restore.nameText!;
    }
    if (restore.distanceText != null) {
      _distanceController.text = restore.distanceText!;
    }
    if (restore.capacityText != null) {
      _capacityController.text = restore.capacityText!;
    }
    if (restore.priceText != null) {
      _priceController.text = restore.priceText!;
    }
    if (restore.descriptionText != null) {
      _descriptionController.text = restore.descriptionText!;
    }
    _externalBookingProvider = ExternalBookingProvider.values.firstWhere(
      (value) => value.name == draft.externalBookingProvider,
      orElse: () => ExternalBookingProvider.generic,
    );
    _externalEventUrlController.text = draft.externalEventUrl ?? '';
    _externalEventIdController.text = draft.externalEventId ?? '';
    _runtimeWalkInPolicy = EventRuntimeWalkInPolicy.values.firstWhere(
      (value) => value.name == draft.runtimeWalkInPolicy,
      orElse: () => EventRuntimeWalkInPolicy.hostApproval,
    );
    _pendingRosterImport = null;
    _rosterFileName = draft.rosterFileName;
    _rosterFileFingerprint = draft.rosterFileFingerprint;
    _rosterReadyCount = draft.rosterReadyCount;
    if (_externalBookingMode) _priceController.text = '0';
    _selectedActivityKind = restore.activityKind;
    _customActivityLabelController.text = restore.customActivityLabelText;
    _selectedInteractionModel = restore.interactionModel;
    _selectedPace = restore.pace;
    _routePlan = restore.routePlan;
    _itinerary = restore.itinerary;

    // Where
    if (restore.meetingPointText != null) {
      _meetingPointController.text = restore.meetingPointText!;
    }
    if (restore.locationDetailsText != null) {
      _locationDetailsController.text = restore.locationDetailsText!;
    }
    _locationState = restore.locationState;

    // When
    _selectedDate = restore.selectedDate;
    _selectedStartTime = restore.selectedStartTime;
    _dateController.text = restore.dateText;
    _startTimeController.text = restore.startTimeText;
    _durationMinutes = restore.durationMinutes;
    _scheduleErrorText = restore.scheduleErrorText;

    // Rules
    if (restore.minAgeText != null) {
      _minAgeController.text = restore.minAgeText!;
    }
    if (restore.maxAgeText != null) {
      _maxAgeController.text = restore.maxAgeText!;
    }
    if (restore.maxMenText != null) {
      _maxMenController.text = restore.maxMenText!;
    }
    if (restore.maxWomenText != null) {
      _maxWomenController.text = restore.maxWomenText!;
    }
    if (restore.inviteCodeText != null) {
      _inviteCodeController.text = restore.inviteCodeText!;
    }
    if (restore.dynamicPricingStepText != null) {
      _dynamicPricingStepController.text = restore.dynamicPricingStepText!;
    }
    if (restore.dynamicPricingMaxText != null) {
      _dynamicPricingMaxController.text = restore.dynamicPricingMaxText!;
    }
    if (restore.crossPathsPairCapacityText != null) {
      _crossPathsPairCapacityController.text =
          restore.crossPathsPairCapacityText!;
    }
    _policyState = restore.policyState;
    _eventSuccessDefaults = _externalBookingMode
        ? restore.eventSuccessDefaults.copyWith(enabled: true)
        : restore.eventSuccessDefaults;
  }

  Future<void> _deleteDraftFromPicker(EventDraft draft) {
    final intent = _draftSideEffectState.deleteFromPickerIntent(draft);
    return _deleteDraft(intent);
  }

  Future<void> _deleteDraft(CreateEventDraftDeleteIntent intent) {
    return CreateEventDraftController.deleteDraftMutation.run(
      ref,
      (tx) async => tx
          .get(createEventDraftControllerProvider.notifier)
          .deleteDraft(clubId: widget.club.id, draftId: intent.draftId),
    );
  }

  Future<bool> _saveDraft({bool showSuccess = true}) async {
    final draftAction = _draftActionState;
    final now = widget.now();
    final draft = _currentDraftSnapshot.toDraft(
      id: draftAction.draftIdForSave(now: now),
      clubId: widget.club.id,
      savedAt: now,
    );

    final savedDraft = await CreateEventDraftController.saveDraftMutation.run(
      ref,
      (tx) async =>
          tx.get(createEventDraftControllerProvider.notifier).saveDraft(draft),
    );
    if (savedDraft == null) return false;

    _activeDraftId = savedDraft.id;
    _lastSavedDraftSignature = _currentDraftContentSignature;

    if (mounted && showSuccess) {
      showCatchSnackBar(context, draftAction.saveSuccessMessage);
    }
    return true;
  }

  void _completeClose() {
    if (!mounted || _allowRoutePop) return;
    setState(() => _allowRoutePop = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) Navigator.of(context).pop();
    });
  }

  static String? _trimmedTextOrNull(TextEditingController controller) {
    final text = controller.text.trim();
    return text.isEmpty ? null : text;
  }

  List<OrderedPhotoPreview> get _eventPhotoPreviews => _eventPhotos.previews;

  String? get _customActivityLabelDraftValue {
    if (_selectedActivityKind != ActivityKind.openActivity) return null;
    return _trimmedTextOrNull(_customActivityLabelController);
  }

  String? get _interactionModelDraftValue {
    if (_selectedActivityKind != ActivityKind.openActivity) return null;
    return _selectedInteractionModel.name;
  }

  EventMeetingLocation? get _currentMeetingLocation {
    return _locationState.meetingLocation(
      meetingPoint: _meetingPointController.text,
      notes: _locationDetailsController.text,
    );
  }

  EventFormatSnapshot get _selectedEventFormat {
    final routeDetails = _routePlan == null
        ? const <String, Object?>{}
        : <String, Object?>{'routePlan': _routePlan!.toJson()};
    if (_selectedActivityKind != ActivityKind.openActivity) {
      return EventFormatSnapshot.fromActivityKind(
        _selectedActivityKind,
        activityDetails: routeDetails,
      );
    }
    return EventFormatSnapshot.custom(
      label: _customActivityLabelController.text,
      interactionModel: _selectedInteractionModel,
      activityDetails: {
        context.l10n.hostsCreateEventScreenVisiblecopyConfiguredin:
            context.l10n.hostsCreateEventScreenVisiblecopyCreateEvent,
        ...routeDetails,
      },
    );
  }

  void _applyClubDefaults(ClubHostDefaults defaults) {
    _selectedActivityKind = defaults.primaryActivityKind;
    _selectedInteractionModel = _selectedActivityKind.defaultInteractionModel;
    _routePlan = RouteEventPlan.defaultForActivity(_selectedActivityKind);
    final policy = defaults.eventPolicy;
    final policyForm = CreateEventPolicyDefaultsFormState.fromDefaults(
      policy,
      currencyCode: _eventCurrencyCode,
    );
    _policyState = policyForm.policyState;
    _minAgeController.text = policyForm.minAgeText;
    _maxAgeController.text = policyForm.maxAgeText;
    _maxMenController.text = policyForm.maxMenText;
    _maxWomenController.text = policyForm.maxWomenText;
    _dynamicPricingStepController.text = policyForm.dynamicPricingStepText;
    _dynamicPricingMaxController.text = policyForm.dynamicPricingMaxText;
    _eventSuccessDefaults = defaults.eventSuccessForFormat(
      _selectedEventFormat,
    );
  }

  double _distanceKmForSelectedActivity() {
    if (!_selectedActivityKind.isDistanceBased) return 0;
    return double.parse(_distanceController.text.trim());
  }

  Future<void> _showStepOverview() async {
    if (_requestPending) return;
    final selected = await showCatchFormStepOverview(
      context: context,
      title: context.l10n.hostsCreateEventOverviewTitle,
      subtitle: context.l10n.hostsWizardOverviewSubtitle,
      items: _reviewState.items,
    );
    if (mounted && selected != null) _showStep(selected);
  }

  String _primaryLabel(CreateEventWizardPrimaryIntent intent) =>
      switch (intent) {
        CreateEventWizardPrimaryIntent.nextStep =>
          context.l10n.hostsStepperFooterLabelNext,
        CreateEventWizardPrimaryIntent.review =>
          context.l10n.hostsCreateEventReviewTitle,
        CreateEventWizardPrimaryIntent.submit =>
          context.l10n.hostsCreateEventCreateAction,
      };

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final submitMutation = ref.watch(CreateEventController.submitMutation);
    final saveDraftMutation = ref.watch(
      CreateEventDraftController.saveDraftMutation,
    );
    final mutationError = submitMutation.hasError
        ? mutationErrorMessage(
            submitMutation,
            l10n: context.l10n,
            context: AppErrorContext.event,
          )
        : saveDraftMutation.hasError
        ? mutationErrorMessage(
            saveDraftMutation,
            l10n: context.l10n,
            context: AppErrorContext.event,
          )
        : null;
    final reviewState = _reviewState;
    final wizardState = CreateEventWizardState.resolve(
      club: widget.club,
      activeSteps: _stepSpecs,
      currentStep: _currentStep,
      submitPending: submitMutation.isPending,
      saveDraftPending: saveDraftMutation.isPending,
      mutationError: mutationError,
      createdEvent: _createdEvent,
      inviteCode: _externalBookingMode
          ? null
          : _trimmedTextOrNull(_inviteCodeController),
      hasUnsavedChanges: _hasUnsavedChanges,
      isReviewing: _isReviewing,
      reviewState: reviewState,
    );

    final successNavigation = wizardState.successNavigation;
    if (successNavigation != null) {
      return CreateEventSuccessScreen(
        club: successNavigation.club,
        event: successNavigation.event,
        inviteCode: successNavigation.inviteCode,
        onManageEvent: () => _handleSuccessNavigationIntent(
          CreateEventSuccessNavigationIntent.manageEvent,
          successNavigation,
        ),
        onDone: () => _handleSuccessNavigationIntent(
          CreateEventSuccessNavigationIntent.backToClub,
          successNavigation,
        ),
        rosterImportResult: _rosterImportResult,
        rosterImportFailed: _rosterImportFailed,
      );
    }

    final autovalidateMode = _showValidationErrors
        ? AutovalidateMode.onUserInteraction
        : widget.formAutovalidateMode;

    return PopScope(
      canPop: _allowRoutePop,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          _handleCloseIntent(
            _hasUnsavedChanges
                ? CreateEventWizardCloseIntent.confirmUnsavedChanges
                : CreateEventWizardCloseIntent.close,
          ).ignore();
        }
      },
      child: CatchScreenScaffold.stepFlow(
        backgroundColor: t.bg,
        body: CreateEventAdaptiveWorkspace(
          header: CreateEventStepHeader(
            title: _isReviewing
                ? context.l10n.hostsCreateEventReviewTitle
                : wizardState.title,
            clubName: wizardState.club.name,
            currentStep: wizardState.currentStep,
            totalSteps: wizardState.totalSteps,
            isReviewing: _isReviewing,
            onClose: wizardState.isLoading
                ? null
                : () => _handleCloseIntent(
                    _hasUnsavedChanges
                        ? CreateEventWizardCloseIntent.confirmUnsavedChanges
                        : CreateEventWizardCloseIntent.close,
                  ).ignore(),
            onStepOverview: wizardState.isLoading ? null : _showStepOverview,
          ),
          body: StepperFooter(
            expandSoloPrimary: true,
            body: _isReviewing
                ? CatchFormReviewBody(
                    message: context.l10n.hostsWizardReviewBody,
                    items: reviewState.items,
                    summaryItems: _reviewSummaryItems,
                    onStepSelected: _showStep,
                  )
                : PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      EventDetailsStep(
                        formKey: _eventDetailsFormKey,
                        autovalidateMode: autovalidateMode,
                        photoPreviews: _eventPhotoPreviews,
                        onPickPhotos: _pickEventPhotos,
                        onRemovePhoto: _removeEventPhoto,
                        onReorderPhoto: _reorderEventPhoto,
                        organizerName: widget.club.name,
                        organizerLogoUrl: widget.club.profileImageUrl,
                        nameController: _nameController,
                        distanceController: _distanceController,
                        customActivityLabelController:
                            _customActivityLabelController,
                        descriptionController: _descriptionController,
                        selectedActivityKind: _selectedActivityKind,
                        onActivityKindChanged: (activityKind) => setState(() {
                          _selectedActivityKind = activityKind;
                          _selectedInteractionModel =
                              activityKind.defaultInteractionModel;
                          _routePlan = RouteEventPlan.defaultForActivity(
                            activityKind,
                          );
                          if (!activityKind.isDistanceBased) {
                            _selectedPace = null;
                          }
                          _eventSuccessDefaults = widget.club.hostDefaults
                              .eventSuccessForFormat(
                                _selectedEventFormat,
                                targetAttendeeCount:
                                    _eventSuccessTargetAttendeeCount,
                              );
                        }),
                        selectedInteractionModel: _selectedInteractionModel,
                        onInteractionModelChanged: (model) => setState(() {
                          _selectedInteractionModel = model;
                          _eventSuccessDefaults = widget.club.hostDefaults
                              .eventSuccessForFormat(
                                _selectedEventFormat,
                                targetAttendeeCount:
                                    _eventSuccessTargetAttendeeCount,
                              );
                        }),
                        selectedPace: _selectedPace,
                        onPaceChanged: (p) => setState(() => _selectedPace = p),
                        routePlan: _routePlan,
                        onRoutePlanChanged: (plan) =>
                            setState(() => _routePlan = plan),
                        itinerary: _itinerary,
                        onItineraryChanged: (items) =>
                            setState(() => _itinerary = items),
                        defaultItineraryLocation: _currentMeetingLocation,
                        onPickItineraryLocation: _pickItineraryLocation,
                        routeInitialCenter:
                            _locationState.startingPoint ??
                            _locationState.initialCenter(
                              ref.read(deviceLocationProvider).asData?.value,
                            ) ??
                            LocationCoordinate(
                              defaultCityDataForMarket().latitude,
                              defaultCityDataForMarket().longitude,
                            ),
                        loadMapTiles: widget.loadMapTiles,
                      ),
                      Form(
                        key: _whenFormKey,
                        autovalidateMode: autovalidateMode,
                        child: SingleChildScrollView(
                          padding: CatchInsets.formStepBodyWithBottomActions,
                          child: CatchSectionList(
                            emptyStateOmitted: true,
                            children: [
                              WhenStep(
                                formKey: _whenFormKey,
                                embedded: true,
                                autovalidateMode: autovalidateMode,
                                dateController: _dateController,
                                startTimeController: _startTimeController,
                                durationMinutes: _durationMinutes,
                                onPickDate: _pickDate,
                                onPickTime: _pickStartTime,
                                onDecreaseDuration: _decreaseDurationCallback,
                                onIncreaseDuration: _increaseDurationCallback,
                                formatDuration: EventFormatters.durationMinutes,
                                scheduleErrorText: _scheduleErrorText,
                              ),
                              WhereStep(
                                formKey: _whenFormKey,
                                embedded: true,
                                organizerId: widget.club.id,
                                autovalidateMode: autovalidateMode,
                                meetingPointController: _meetingPointController,
                                locationDetailsController:
                                    _locationDetailsController,
                                startingPoint: _locationState.startingPoint,
                                onMeetingPointChanged: (_) => setState(() {}),
                                onPickLocation: _pickLocation,
                                onLocationDetailsChanged: (_) =>
                                    setState(() {}),
                                currentMeetingLocation: _currentMeetingLocation,
                                selectedVenueId: _locationState.sourceVenueId,
                                onVenueSelected: _selectVenue,
                                currentCapacity: int.tryParse(
                                  _capacityController.text.trim(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Form(
                        key: _eventPolicyFormKey,
                        autovalidateMode: autovalidateMode,
                        child: SingleChildScrollView(
                          padding: CatchInsets.formStepBodyWithBottomActions,
                          child: CatchSectionList(
                            emptyStateOmitted: true,
                            children: [
                              EventPolicyStep(
                                embedded: true,
                                formKey: _eventPolicyFormKey,
                                autovalidateMode: autovalidateMode,
                                capacityController: _capacityController,
                                onCapacityChanged: (_) => setState(() {}),
                                priceController: _priceController,
                                currencyCode: _eventCurrencyCode,
                                inviteCodeController: _inviteCodeController,
                                dynamicPricingStepController:
                                    _dynamicPricingStepController,
                                dynamicPricingMaxController:
                                    _dynamicPricingMaxController,
                                minAgeController: _minAgeController,
                                maxAgeController: _maxAgeController,
                                maxMenController: _maxMenController,
                                maxWomenController: _maxWomenController,
                                crossPathsPairCapacityController:
                                    _crossPathsPairCapacityController,
                                admissionPreset: _policyState.admissionPreset,
                                onAdmissionPresetChanged: (preset) =>
                                    setState(() {
                                      _policyState = _policyState
                                          .selectAdmissionPreset(preset);
                                    }),
                                cohortCapsEnabled:
                                    _policyState.cohortCapsEnabled,
                                onCohortCapsEnabledChanged: (enabled) =>
                                    setState(() {
                                      _policyState = _policyState
                                          .setCohortCapsEnabled(enabled);
                                    }),
                                dynamicPricingEnabled:
                                    _policyState.dynamicPricingEnabled,
                                onDynamicPricingChanged: (enabled) =>
                                    setState(() {
                                      _policyState = _policyState
                                          .setDynamicPricingEnabled(enabled);
                                    }),
                                crossPathsPairInventoryEnabled:
                                    _policyState.crossPathsPairInventoryEnabled,
                                onCrossPathsPairInventoryChanged: (enabled) =>
                                    setState(
                                      () => _policyState = _policyState
                                          .setCrossPathsPairInventoryEnabled(
                                            enabled,
                                          ),
                                    ),
                                cancellationPolicyId:
                                    _policyState.cancellationPolicyId,
                                onCancellationPolicyChanged: (policyId) =>
                                    setState(
                                      () => _policyState = _policyState
                                          .setCancellationPolicy(policyId),
                                    ),
                                externalBookingMode: _externalBookingMode,
                                minimumCapacity:
                                    _pendingRosterImport?.readyCount,
                              ),
                              if (_externalBookingMode)
                                CreateEventGuestsSection(
                                  autovalidateMode: autovalidateMode,
                                  externalBookingProvider:
                                      _externalBookingProvider,
                                  externalEventUrlController:
                                      _externalEventUrlController,
                                  externalEventIdController:
                                      _externalEventIdController,
                                  runtimeWalkInPolicy: _runtimeWalkInPolicy,
                                  onExternalBookingProviderChanged:
                                      (provider) => setState(
                                        () =>
                                            _externalBookingProvider = provider,
                                      ),
                                  onRuntimeWalkInPolicyChanged: (policy) =>
                                      setState(
                                        () => _runtimeWalkInPolicy = policy,
                                      ),
                                  rosterFileName: _rosterFileName,
                                  rosterReadyCount: _rosterReadyCount,
                                  rosterNeedsReviewCount:
                                      _pendingRosterImport?.needsReviewCount ??
                                      0,
                                  rosterExcludedCount:
                                      _pendingRosterImport?.excludedCount ?? 0,
                                  rosterAttached: _pendingRosterImport != null,
                                  onPickRoster: _pickRoster,
                                ),
                              EventSuccessStep(
                                embedded: true,
                                requiredForRuntime: _externalBookingMode,
                                organizerId: widget.club.id,
                                activityKind: _selectedActivityKind,
                                eventFormat: _selectedEventFormat,
                                eventSuccessDefaults: _externalBookingMode
                                    ? _eventSuccessDefaults.copyWith(
                                        enabled: true,
                                      )
                                    : _eventSuccessDefaults,
                                targetAttendeeCount:
                                    _eventSuccessTargetAttendeeCount,
                                onEventSuccessDefaultsChanged: (defaults) =>
                                    setState(
                                      () => _eventSuccessDefaults = defaults,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
            notice: wizardState.mutationError == null
                ? null
                : CatchErrorBanner(message: wizardState.mutationError!),
            isLastStep: wizardState.isLastStep || _isReviewing,
            isLoading: wizardState.isLoading,
            primaryEnabled: wizardState.primaryEnabled,
            primaryLabel: _primaryLabel(wizardState.primaryIntent),
            onPrimary: () => _handlePrimaryIntent(wizardState.primaryIntent),
            onPrevious: wizardState.previousIntent == null
                ? null
                : () => _handlePreviousIntent(wizardState.previousIntent!),
          ),
          steps: reviewState.items,
          currentStep: wizardState.currentStep,
          onStepSelected: _showStep,
          summaryTitle: context.l10n.hostsCreateEventReviewTitle,
          summaryItems: _reviewSummaryItems,
        ),
      ),
    );
  }
}
