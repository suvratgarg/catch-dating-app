import 'package:catch_dating_app/activity/domain/activity_taxonomy.dart';
import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/clubs/domain/club_host_defaults.dart';
import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/business_rules.dart';
import 'package:catch_dating_app/core/city_catalog.dart';
import 'package:catch_dating_app/core/device_location.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_adaptive_dialog.dart';
import 'package:catch_dating_app/core/widgets/catch_adaptive_picker.dart';
import 'package:catch_dating_app/core/widgets/catch_error_banner.dart';
import 'package:catch_dating_app/core/widgets/catch_error_snackbar.dart';
import 'package:catch_dating_app/core/widgets/catch_form_step_flow.dart';
import 'package:catch_dating_app/core/widgets/mutation_error_util.dart';
import 'package:catch_dating_app/event_policies/domain/event_policy.dart';
import 'package:catch_dating_app/event_policies/domain/event_policy_defaults.dart';
import 'package:catch_dating_app/event_success/domain/event_success_defaults.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/domain/event_constraints.dart';
import 'package:catch_dating_app/events/domain/event_draft.dart';
import 'package:catch_dating_app/events/domain/event_formatters.dart';
import 'package:catch_dating_app/events/presentation/location_picker_screen.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/create/create_event_controller.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/create/create_event_draft_controller.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/create/create_event_draft_restore_state.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/create/create_event_draft_snapshot.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/create/create_event_location_state.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/create/create_event_photo_draft_state.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/create/create_event_policy_state.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/create/create_event_schedule_state.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/create/create_event_success_screen.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/create/create_event_wizard_state.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/widgets/create_event_step_header.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/widgets/draft_picker_sheet.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/widgets/event_details_step.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/widgets/event_policy_step.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/widgets/event_success_step.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/widgets/when_step.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/widgets/where_step.dart';
import 'package:catch_dating_app/hosts/presentation/widgets/stepper_footer.dart';
import 'package:catch_dating_app/image_uploads/presentation/widgets/ordered_photo_picker.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

DateTime _systemNow() => DateTime.now();

const createEventUnsavedChangesDialogTitle = 'Unsaved changes';
const createEventUnsavedChangesDialogMessage =
    'You have unsaved changes. Would you like to save a draft?';
const createEventUnsavedChangesDialogActions = <CatchDialogAction<bool>>[
  CatchDialogAction(label: 'Discard', value: false),
  CatchDialogAction(label: 'Save draft', value: true, isDefault: true),
];

class CreateEventUnsavedChangesDialog extends StatelessWidget {
  const CreateEventUnsavedChangesDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return const CatchConfirmDialog<bool>(
      title: createEventUnsavedChangesDialogTitle,
      message: createEventUnsavedChangesDialogMessage,
      actions: createEventUnsavedChangesDialogActions,
    );
  }
}

Future<bool?> showCreateEventUnsavedChangesDialog(BuildContext context) {
  return showCatchAdaptiveDialog<bool>(
    context: context,
    title: createEventUnsavedChangesDialogTitle,
    message: createEventUnsavedChangesDialogMessage,
    actions: createEventUnsavedChangesDialogActions,
  );
}

class CreateEventScreen extends ConsumerStatefulWidget {
  const CreateEventScreen({
    super.key,
    required this.club,
    this.loadMapTiles = true,
    this.now = _systemNow,
    this.initialDraft,
    this.initialStep = 0,
    this.formAutovalidateMode = AutovalidateMode.disabled,
    this.initialPickedEventPhotos = const <PickedEventPhoto>[],
  });

  final Club club;
  final EventDraft? initialDraft;
  final int initialStep;
  final AutovalidateMode formAutovalidateMode;
  final List<PickedEventPhoto> initialPickedEventPhotos;

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
  Event? _createdEvent;

  // Draft support
  String? _activeDraftId;
  Object? _lastSavedDraftSignature;
  late Object _initialDraftContentSignature;
  bool _checkedDrafts = false;

  final _eventDetailsFormKey = GlobalKey<FormState>();
  final _whereFormKey = GlobalKey<FormState>();
  final _whenFormKey = GlobalKey<FormState>();
  final _eventPolicyFormKey = GlobalKey<FormState>();

  List<CatchFormStepSpec> get _stepSpecs => createEventWizardStepSpecs(
    eventDetailsFormKey: _eventDetailsFormKey,
    meetingLocationFormKey: _whereFormKey,
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
  final _distanceController = TextEditingController();
  final _capacityController = TextEditingController();
  final _priceController = TextEditingController();
  final _customActivityLabelController = TextEditingController();
  final _descriptionController = TextEditingController();
  ActivityKind _selectedActivityKind = ActivityKind.socialRun;
  EventInteractionModel _selectedInteractionModel =
      ActivityKind.socialRun.defaultInteractionModel;
  PaceLevel? _selectedPace;
  var _eventPhotos = const CreateEventPhotoDraftState.empty();

  // Step 3 — Rules
  final _minAgeController = TextEditingController();
  final _maxAgeController = TextEditingController();
  final _maxMenController = TextEditingController();
  final _maxWomenController = TextEditingController();
  final _inviteCodeController = TextEditingController();
  final _dynamicPricingStepController = TextEditingController();
  final _dynamicPricingMaxController = TextEditingController();
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
      _policyState.defaultsFromFields(
        minAge: _minAgeController.text,
        maxAge: _maxAgeController.text,
        maxMen: _maxMenController.text,
        maxWomen: _maxWomenController.text,
        dynamicPricingStep: _dynamicPricingStepController.text,
        dynamicPricingMax: _dynamicPricingMaxController.text,
        currencyCode: _eventCurrencyCode,
      );

  EventPolicyBundle get _eventPolicy {
    return _policyState.eventPolicyFromFields(
      capacity: _capacityController.text,
      basePrice: _priceController.text,
      inviteCode: _inviteCodeController.text,
      minAge: _minAgeController.text,
      maxAge: _maxAgeController.text,
      maxMen: _maxMenController.text,
      maxWomen: _maxWomenController.text,
      dynamicPricingStep: _dynamicPricingStepController.text,
      dynamicPricingMax: _dynamicPricingMaxController.text,
      currencyCode: _eventCurrencyCode,
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
    _currentStep = widget.initialStep.clamp(0, _stepSpecs.length - 1).toInt();
    _pageController = PageController(initialPage: _currentStep);
    _applyClubDefaults(widget.club.hostDefaults);
    final initialDraft = widget.initialDraft;
    if (initialDraft != null) {
      _activeDraftId = initialDraft.id;
      _applyDraftValues(initialDraft);
      _lastSavedDraftSignature = _currentDraftContentSignature;
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
    _distanceController.dispose();
    _capacityController.dispose();
    _priceController.dispose();
    _customActivityLabelController.dispose();
    _descriptionController.dispose();
    _minAgeController.dispose();
    _maxAgeController.dispose();
    _maxMenController.dispose();
    _maxWomenController.dispose();
    _inviteCodeController.dispose();
    _dynamicPricingStepController.dispose();
    _dynamicPricingMaxController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final today = DateUtils.dateOnly(widget.now());
    final picked = await showCatchDatePicker(
      context: context,
      initialDate: _selectedDate ?? today,
      firstDate: today,
      lastDate: today.add(const Duration(days: 365)),
      title: 'Event date',
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
      title: 'Start time',
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

  Future<void> _pickEventPhotos() async {
    final remainingSlots = _eventPhotos.remainingSlots;
    if (remainingSlots <= 0) return;
    final picked = await ref
        .read(createEventControllerProvider.notifier)
        .pickEventPhotos(limit: remainingSlots);
    if (!mounted || picked.isEmpty) return;
    setState(() => _eventPhotos = _eventPhotos.addPicked(picked));
  }

  void _removeEventPhoto(int index) {
    setState(() => _eventPhotos = _eventPhotos.removeAt(index));
  }

  void _reorderEventPhoto(int fromIndex, int toIndex) {
    setState(() => _eventPhotos = _eventPhotos.reorder(fromIndex, toIndex));
  }

  void _handleBackIntent(CreateEventWizardBackIntent intent) {
    switch (intent) {
      case CreateEventWizardBackIntent.previousStep:
        _goToStep(_currentStep - 1);
      case CreateEventWizardBackIntent.confirmUnsavedChanges:
        _showUnsavedChangesDialog();
      case CreateEventWizardBackIntent.close:
        Navigator.of(context).pop();
    }
  }

  void _handlePrimaryIntent(CreateEventWizardPrimaryIntent intent) {
    if (!_validateCurrentInput()) return;

    switch (intent) {
      case CreateEventWizardPrimaryIntent.nextStep:
        _goToStep(_currentStep + 1);
      case CreateEventWizardPrimaryIntent.submit:
        _submit();
    }
  }

  Future<void> _handleSaveDraftIntent(CreateEventWizardSaveDraftIntent intent) {
    switch (intent) {
      case CreateEventWizardSaveDraftIntent.saveDraft:
        return _saveDraft();
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
    setState(() => _currentStep = step);
    _pageController.animateToPage(
      step,
      duration: CatchMotion.pageStep,
      curve: CatchMotion.easeInOutCurve,
    );
  }

  bool _validateCurrentInput() {
    final plan = CreateEventWizardValidationPlan.resolve(
      activeSteps: _stepSpecs,
      currentStep: _currentStep,
      scheduleState: _scheduleState,
      now: widget.now(),
    );
    final formIsValid = plan.formKey?.currentState?.validate() ?? true;
    if (plan.scheduleErrorText != null) {
      setState(() => _scheduleErrorText = plan.scheduleErrorText);
    }
    return formIsValid && plan.scheduleAllowsContinue;
  }

  void _submit() {
    final startTime = _selectedStartDateTime!;
    final endTime = startTime.add(Duration(minutes: _durationMinutes));
    final meetingLocation = _currentMeetingLocation;
    if (meetingLocation == null) return;

    CreateEventController.submitMutation.run(ref, (tx) async {
      final createdEvent = await tx
          .get(createEventControllerProvider.notifier)
          .submit(
            clubId: widget.club.id,
            startTime: startTime,
            endTime: endTime,
            meetingLocation: meetingLocation,
            eventFormat: _selectedEventFormat,
            distanceKm: _distanceKmForSelectedActivity(),
            pace: _selectedPace ?? PaceLevel.easy,
            description: _descriptionController.text.trim(),
            currency: _eventCurrencyCode,
            constraints: _constraints,
            eventPolicy: _eventPolicy,
            inviteCode: _trimmedTextOrNull(_inviteCodeController),
            photoImages: _eventPhotos.pickedPhotos
                .map((photo) => photo.image)
                .toList(),
            eventSuccessDefaults: _eventSuccessDefaults,
          );
      if (mounted) {
        setState(() => _createdEvent = createdEvent);
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

  Object get _currentDraftContentSignature => _currentDraftSnapshot.signature;

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
        distance: _trimmedTextOrNull(_distanceController),
        capacity: _trimmedTextOrNull(_capacityController),
        price: _trimmedTextOrNull(_priceController),
        description: _trimmedTextOrNull(_descriptionController),
        activityKind: _selectedActivityKind.name,
        customActivityLabel: _customActivityLabelDraftValue,
        interactionModel: _interactionModelDraftValue,
        paceName: _selectedPace?.name,
        meetingPoint: _trimmedTextOrNull(_meetingPointController),
        locationDetails: _trimmedTextOrNull(_locationDetailsController),
        meetingLocationAddress: _locationState.meetingLocationAddress,
        meetingLocationPlaceId: _locationState.meetingLocationPlaceId,
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
    final restore = CreateEventDraftRestoreState.fromDraft(
      draft,
      now: widget.now(),
    );

    // Event details
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
    _selectedActivityKind = restore.activityKind;
    _customActivityLabelController.text = restore.customActivityLabelText;
    _selectedInteractionModel = restore.interactionModel;
    _selectedPace = restore.pace;

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
    _policyState = restore.policyState;
    _eventSuccessDefaults = restore.eventSuccessDefaults;
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

  Future<void> _saveDraft() async {
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
    if (savedDraft == null) return;

    _activeDraftId = savedDraft.id;
    _lastSavedDraftSignature = _currentDraftContentSignature;

    if (!mounted) return;
    showCatchSnackBar(context, draftAction.saveSuccessMessage);
  }

  void _showUnsavedChangesDialog() {
    showCreateEventUnsavedChangesDialog(context).then((save) async {
      if (!mounted) return;
      if (save == true) {
        await _saveDraft();
        if (mounted) Navigator.of(context).pop();
      } else if (save == false) {
        if (mounted) Navigator.of(context).pop();
      }
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
    if (_selectedActivityKind != ActivityKind.openActivity) {
      return EventFormatSnapshot.fromActivityKind(_selectedActivityKind);
    }
    return EventFormatSnapshot.custom(
      label: _customActivityLabelController.text,
      interactionModel: _selectedInteractionModel,
      activityDetails: const {'configuredIn': 'create_event'},
    );
  }

  void _applyClubDefaults(ClubHostDefaults defaults) {
    _selectedActivityKind = defaults.primaryActivityKind;
    _selectedInteractionModel = _selectedActivityKind.defaultInteractionModel;
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

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final submitMutation = ref.watch(CreateEventController.submitMutation);
    final saveDraftMutation = ref.watch(
      CreateEventDraftController.saveDraftMutation,
    );
    final mutationError = submitMutation.hasError
        ? mutationErrorMessage(submitMutation, context: AppErrorContext.event)
        : saveDraftMutation.hasError
        ? mutationErrorMessage(
            saveDraftMutation,
            context: AppErrorContext.event,
          )
        : null;
    final wizardState = CreateEventWizardState.resolve(
      club: widget.club,
      activeSteps: _stepSpecs,
      currentStep: _currentStep,
      submitPending: submitMutation.isPending,
      saveDraftPending: saveDraftMutation.isPending,
      mutationError: mutationError,
      createdEvent: _createdEvent,
      inviteCode: _trimmedTextOrNull(_inviteCodeController),
      hasUnsavedChanges: _hasUnsavedChanges,
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
      );
    }

    return Scaffold(
      backgroundColor: t.bg,
      body: SafeArea(
        child: Column(
          children: [
            CreateEventStepHeader(
              title: wizardState.title,
              clubName: wizardState.club.name,
              currentStep: wizardState.currentStep,
              totalSteps: wizardState.totalSteps,
              onBack: () => _handleBackIntent(wizardState.backIntent),
            ),
            gapH4,
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  EventDetailsStep(
                    formKey: _eventDetailsFormKey,
                    autovalidateMode: widget.formAutovalidateMode,
                    photoPreviews: _eventPhotoPreviews,
                    onPickPhotos: _pickEventPhotos,
                    onRemovePhoto: _removeEventPhoto,
                    onReorderPhoto: _reorderEventPhoto,
                    distanceController: _distanceController,
                    customActivityLabelController:
                        _customActivityLabelController,
                    descriptionController: _descriptionController,
                    selectedActivityKind: _selectedActivityKind,
                    onActivityKindChanged: (activityKind) => setState(() {
                      _selectedActivityKind = activityKind;
                      _selectedInteractionModel =
                          activityKind.defaultInteractionModel;
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
                  ),
                  WhereStep(
                    formKey: _whereFormKey,
                    autovalidateMode: widget.formAutovalidateMode,
                    meetingPointController: _meetingPointController,
                    locationDetailsController: _locationDetailsController,
                    startingPoint: _locationState.startingPoint,
                    onMeetingPointChanged: (_) => setState(() {}),
                    onPickLocation: _pickLocation,
                  ),
                  WhenStep(
                    formKey: _whenFormKey,
                    autovalidateMode: widget.formAutovalidateMode,
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
                  EventPolicyStep(
                    formKey: _eventPolicyFormKey,
                    autovalidateMode: widget.formAutovalidateMode,
                    capacityController: _capacityController,
                    priceController: _priceController,
                    currencyCode: _eventCurrencyCode,
                    inviteCodeController: _inviteCodeController,
                    dynamicPricingStepController: _dynamicPricingStepController,
                    dynamicPricingMaxController: _dynamicPricingMaxController,
                    minAgeController: _minAgeController,
                    maxAgeController: _maxAgeController,
                    maxMenController: _maxMenController,
                    maxWomenController: _maxWomenController,
                    admissionPreset: _policyState.admissionPreset,
                    onAdmissionPresetChanged: (preset) => setState(() {
                      _policyState = _policyState.selectAdmissionPreset(preset);
                    }),
                    cohortCapsEnabled: _policyState.cohortCapsEnabled,
                    onCohortCapsEnabledChanged: (enabled) => setState(() {
                      _policyState = _policyState.setCohortCapsEnabled(enabled);
                    }),
                    dynamicPricingEnabled: _policyState.dynamicPricingEnabled,
                    onDynamicPricingChanged: (enabled) => setState(() {
                      _policyState = _policyState.setDynamicPricingEnabled(
                        enabled,
                      );
                    }),
                    cancellationPolicyId: _policyState.cancellationPolicyId,
                    onCancellationPolicyChanged: (policyId) => setState(
                      () => _policyState = _policyState.setCancellationPolicy(
                        policyId,
                      ),
                    ),
                  ),
                  EventSuccessStep(
                    activityKind: _selectedActivityKind,
                    eventFormat: _selectedEventFormat,
                    eventSuccessDefaults: _eventSuccessDefaults,
                    targetAttendeeCount: _eventSuccessTargetAttendeeCount,
                    onEventSuccessDefaultsChanged: (defaults) =>
                        setState(() => _eventSuccessDefaults = defaults),
                  ),
                ],
              ),
            ),
            if (wizardState.mutationError != null)
              CatchErrorBanner(message: wizardState.mutationError!),
            StepperFooter(
              isLastStep: wizardState.isLastStep,
              isLoading: wizardState.isLoading,
              primaryLabel: wizardState.primaryActionLabel,
              onPrimary: () => _handlePrimaryIntent(wizardState.primaryIntent),
              onSaveDraft: wizardState.saveDraftIntent == null
                  ? null
                  : () => _handleSaveDraftIntent(wizardState.saveDraftIntent!),
            ),
          ],
        ),
      ),
    );
  }
}
