import 'package:catch_dating_app/activity/domain/activity_taxonomy.dart';
import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/core/business_rules.dart';
import 'package:catch_dating_app/core/device_location.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/time_formatters.dart';
import 'package:catch_dating_app/core/widgets/catch_adaptive_dialog.dart';
import 'package:catch_dating_app/core/widgets/catch_adaptive_picker.dart';
import 'package:catch_dating_app/core/widgets/error_banner.dart';
import 'package:catch_dating_app/core/widgets/mutation_error_util.dart';
import 'package:catch_dating_app/event_policies/domain/event_policy.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/domain/event_constraints.dart';
import 'package:catch_dating_app/events/domain/event_draft.dart';
import 'package:catch_dating_app/events/presentation/create_event_controller.dart';
import 'package:catch_dating_app/events/presentation/create_event_draft_controller.dart';
import 'package:catch_dating_app/events/presentation/create_event_success_screen.dart';
import 'package:catch_dating_app/events/presentation/event_formatters.dart';
import 'package:catch_dating_app/events/presentation/host_event_manage_screen.dart';
import 'package:catch_dating_app/events/presentation/location_picker_screen.dart';
import 'package:catch_dating_app/events/presentation/widgets/create_event_step_header.dart';
import 'package:catch_dating_app/events/presentation/widgets/draft_picker_sheet.dart';
import 'package:catch_dating_app/events/presentation/widgets/event_details_step.dart';
import 'package:catch_dating_app/events/presentation/widgets/event_policy_step.dart';
import 'package:catch_dating_app/events/presentation/widgets/stepper_footer.dart';
import 'package:catch_dating_app/events/presentation/widgets/when_step.dart';
import 'package:catch_dating_app/events/presentation/widgets/where_step.dart';
import 'package:catch_dating_app/locations/domain/location_coordinate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

DateTime _systemNow() => DateTime.now();

class CreateEventScreen extends ConsumerStatefulWidget {
  const CreateEventScreen({
    super.key,
    required this.club,
    this.loadMapTiles = true,
    this.now = _systemNow,
  });

  final Club club;

  /// Tests can disable network tiles while still exercising map callbacks.
  final bool loadMapTiles;

  /// Current time source, injectable so same-day time validation is testable.
  final DateTime Function() now;

  @override
  ConsumerState<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends ConsumerState<CreateEventScreen> {
  static const _totalSteps = 4;
  final _pageController = PageController();
  int _currentStep = 0;
  Event? _createdEvent;
  bool _showHostManage = false;

  // Draft support
  String? _activeDraftId;
  Object? _lastSavedDraftSignature;
  bool _checkedDrafts = false;

  final _eventDetailsFormKey = GlobalKey<FormState>();
  final _whereFormKey = GlobalKey<FormState>();
  final _whenFormKey = GlobalKey<FormState>();
  final _eventPolicyFormKey = GlobalKey<FormState>();

  // Step 2 — When
  final _dateController = TextEditingController();
  final _startTimeController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedStartTime;
  int _durationMinutes = CatchBusinessRules.eventDefaultDurationMinutes;
  String? _scheduleErrorText;

  static const _futureStartError = 'Choose a start time later than now';

  // Step 1 — Where
  final _meetingPointController = TextEditingController();
  final _locationDetailsController = TextEditingController();
  LocationCoordinate? _startingPoint;

  // Step 0 — Event details
  final _distanceController = TextEditingController();
  final _capacityController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  ActivityKind _selectedActivityKind = ActivityKind.socialRun;
  PaceLevel? _selectedPace;
  PickedEventPhoto? _eventPhoto;

  // Step 3 — Rules
  final _minAgeController = TextEditingController();
  final _maxAgeController = TextEditingController();
  final _maxMenController = TextEditingController();
  final _maxWomenController = TextEditingController();
  final _inviteCodeController = TextEditingController();
  final _dynamicPricingStepController = TextEditingController();
  final _dynamicPricingMaxController = TextEditingController();
  EventAdmissionPreset _selectedAdmissionPreset =
      EventAdmissionPreset.openCapacity;
  bool _dynamicPricingEnabled = false;
  EventCancellationPolicyId _selectedCancellationPolicyId =
      EventCancellationPolicyId.standard;

  GlobalKey<FormState> get _currentStepKey => switch (_currentStep) {
    0 => _eventDetailsFormKey,
    1 => _whereFormKey,
    2 => _whenFormKey,
    _ => _eventPolicyFormKey,
  };

  DateTime? get _selectedStartDateTime {
    final selectedDate = _selectedDate;
    final selectedStartTime = _selectedStartTime;
    if (selectedDate == null || selectedStartTime == null) return null;
    return _combine(selectedDate, selectedStartTime);
  }

  EventConstraints get _constraints => EventConstraints(
    minAge: int.tryParse(_minAgeController.text.trim()) ?? 0,
    maxAge: int.tryParse(_maxAgeController.text.trim()) ?? 99,
    maxMen: _selectedAdmissionPreset == EventAdmissionPreset.fixedCohortCaps
        ? int.tryParse(_maxMenController.text.trim())
        : null,
    maxWomen: _selectedAdmissionPreset == EventAdmissionPreset.fixedCohortCaps
        ? int.tryParse(_maxWomenController.text.trim())
        : null,
  );

  EventPolicyBundle get _eventPolicy {
    final capacityLimit = int.parse(_capacityController.text.trim());
    final basePriceInPaise = (double.parse(_priceController.text.trim()) * 100)
        .round();
    final cancellationPolicy = _selectedCancellationPolicy;

    return switch (_selectedAdmissionPreset) {
      EventAdmissionPreset.openCapacity => EventPolicyBundle.openEvent(
        capacityLimit: capacityLimit,
        basePriceInPaise: basePriceInPaise,
        cancellationPolicy: cancellationPolicy,
      ),
      EventAdmissionPreset.inviteOnly => EventPolicyBundle.inviteOnlyEvent(
        capacityLimit: capacityLimit,
        basePriceInPaise: basePriceInPaise,
        inviteCodeHint: _inviteCodeHint,
        cancellationPolicy: cancellationPolicy,
      ),
      EventAdmissionPreset.balancedSingles =>
        _dynamicPricingEnabled
            ? EventPolicyBundle.demandPricedBalancedSinglesEvent(
                capacityLimit: capacityLimit,
                basePriceInPaise: basePriceInPaise,
                stepAdjustmentInPaise:
                    _rupeeControllerValueInPaise(
                      _dynamicPricingStepController,
                    ) ??
                    0,
                maxAdjustmentInPaise:
                    _rupeeControllerValueInPaise(
                      _dynamicPricingMaxController,
                    ) ??
                    0,
                cancellationPolicy: cancellationPolicy,
              )
            : EventPolicyBundle.balancedSinglesEvent(
                capacityLimit: capacityLimit,
                basePriceInPaise: basePriceInPaise,
                cancellationPolicy: cancellationPolicy,
              ),
      EventAdmissionPreset.fixedCohortCaps =>
        EventPolicyBundle.fixedCohortCapsEvent(
          capacityLimit: capacityLimit,
          basePriceInPaise: basePriceInPaise,
          maxMenInterestedInWomen: int.tryParse(_maxMenController.text.trim()),
          maxWomenInterestedInMen: int.tryParse(
            _maxWomenController.text.trim(),
          ),
          cancellationPolicy: cancellationPolicy,
        ),
    };
  }

  EventCancellationPolicy get _selectedCancellationPolicy {
    return switch (_selectedCancellationPolicyId) {
      EventCancellationPolicyId.flexible =>
        const EventCancellationPolicy.flexible(),
      EventCancellationPolicyId.standard =>
        const EventCancellationPolicy.standard(),
      EventCancellationPolicyId.strict =>
        const EventCancellationPolicy.strict(),
    };
  }

  VoidCallback? get _decreaseDurationCallback =>
      _durationMinutes > CatchBusinessRules.eventMinDurationMinutes
      ? () => setState(
          () => _durationMinutes -= CatchBusinessRules.eventDurationStepMinutes,
        )
      : null;

  VoidCallback? get _increaseDurationCallback =>
      _durationMinutes < CatchBusinessRules.eventMaxDurationMinutes
      ? () => setState(
          () => _durationMinutes += CatchBusinessRules.eventDurationStepMinutes,
        )
      : null;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_checkedDrafts) {
        _checkedDrafts = true;
        _checkForDrafts();
      }
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
      final scheduleError = _scheduleErrorFor(picked, _selectedStartTime);
      setState(() {
        _selectedDate = picked;
        _dateController.text =
            '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
        _scheduleErrorText = scheduleError;
        if (scheduleError != null) {
          _selectedStartTime = null;
          _startTimeController.clear();
        }
      });
    }
  }

  Future<void> _pickStartTime() async {
    final picked = await showCatchTimePicker(
      context: context,
      initialTime: _selectedStartTime ?? _initialStartTime(),
      title: 'Start time',
    );
    if (picked != null) {
      final scheduleError = _scheduleErrorFor(_selectedDate, picked);
      setState(() {
        if (scheduleError != null) {
          _scheduleErrorText = scheduleError;
          _selectedStartTime = null;
          _startTimeController.clear();
          return;
        }
        _scheduleErrorText = null;
        _selectedStartTime = picked;
        _startTimeController.text = _formatClockTime(picked);
      });
    }
  }

  Future<void> _pickLocation() async {
    final deviceLocation = ref.read(deviceLocationProvider).asData?.value;
    final result = await Navigator.of(context).push<LocationCoordinate>(
      MaterialPageRoute(
        builder: (_) => LocationPickerScreen(
          initialLocation: _startingPoint ?? deviceLocation,
          loadMapTiles: widget.loadMapTiles,
        ),
        fullscreenDialog: true,
      ),
    );
    if (result != null) {
      setState(() => _startingPoint = result);
    }
  }

  Future<void> _pickEventPhoto() async {
    final picked = await ref
        .read(createEventControllerProvider.notifier)
        .pickEventPhoto();
    if (!mounted || picked == null) return;
    setState(() => _eventPhoto = picked);
  }

  void _back() {
    if (_currentStep > 0) {
      _goToStep(_currentStep - 1);
    } else if (_hasUnsavedChanges) {
      _showUnsavedChangesDialog();
    } else {
      Navigator.of(context).pop();
    }
  }

  void _next() {
    if (!_validateCurrentStep() || !_validateCurrentSchedule()) return;

    if (_currentStep < _totalSteps - 1) {
      _goToStep(_currentStep + 1);
    } else {
      _submit();
    }
  }

  DateTime _combine(DateTime date, TimeOfDay time) =>
      DateTime(date.year, date.month, date.day, time.hour, time.minute);

  TimeOfDay _initialStartTime() {
    final selectedDate = _selectedDate;
    final now = widget.now();
    if (selectedDate != null && DateUtils.isSameDay(selectedDate, now)) {
      final soon = now.add(const Duration(minutes: 5));
      if (DateUtils.isSameDay(selectedDate, soon)) {
        return TimeOfDay(hour: soon.hour, minute: soon.minute);
      }
    }
    return const TimeOfDay(hour: 7, minute: 0);
  }

  String? _scheduleErrorFor(DateTime? date, TimeOfDay? startTime) {
    if (date == null || startTime == null) return null;
    return _combine(date, startTime).isAfter(widget.now())
        ? null
        : _futureStartError;
  }

  void _goToStep(int step) {
    setState(() => _currentStep = step);
    _pageController.animateToPage(
      step,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeInOut,
    );
  }

  bool _validateCurrentStep() =>
      _currentStepKey.currentState?.validate() ?? true;

  bool _validateCurrentSchedule() {
    if (_currentStep != 2) return true;

    final startTime = _selectedStartDateTime;
    if (startTime == null) return false;
    if (startTime.isAfter(widget.now())) return true;

    setState(() => _scheduleErrorText = _futureStartError);
    return false;
  }

  void _submit() {
    final startTime = _selectedStartDateTime!;
    final endTime = startTime.add(Duration(minutes: _durationMinutes));

    CreateEventController.submitMutation.run(ref, (tx) async {
      final createdEvent = await tx
          .get(createEventControllerProvider.notifier)
          .submit(
            clubId: widget.club.id,
            startTime: startTime,
            endTime: endTime,
            meetingPoint: _meetingPointController.text.trim(),
            startingPointLat: _startingPoint?.latitude,
            startingPointLng: _startingPoint?.longitude,
            locationDetails: _trimmedTextOrNull(_locationDetailsController),
            eventFormat: EventFormatSnapshot.fromActivityKind(
              _selectedActivityKind,
            ),
            distanceKm: _distanceKmForSelectedActivity(),
            pace: _selectedPace ?? PaceLevel.easy,
            description: _descriptionController.text.trim(),
            constraints: _constraints,
            eventPolicy: _eventPolicy,
            inviteCode: _trimmedTextOrNull(_inviteCodeController),
            photoImage: _eventPhoto?.image,
          );
      if (mounted) {
        setState(() => _createdEvent = createdEvent);
      }

      // Delete the restored-from draft after successful submission.
      final draftId = _activeDraftId;
      if (draftId != null) {
        await CreateEventDraftController.deleteDraftMutation.run(
          ref,
          (tx) async => tx
              .get(createEventDraftControllerProvider.notifier)
              .deleteDraft(clubId: widget.club.id, draftId: draftId),
        );
      }

      return createdEvent;
    });
  }

  bool get _hasUnsavedChanges {
    final currentSignature = _currentDraftContentSignature;
    if (_activeDraftId != null) {
      return currentSignature != _lastSavedDraftSignature;
    }
    return currentSignature != _emptyDraftContentSignature;
  }

  Object get _currentDraftContentSignature => (
    distance: _trimmedTextOrNull(_distanceController),
    capacity: _trimmedTextOrNull(_capacityController),
    price: _trimmedTextOrNull(_priceController),
    description: _trimmedTextOrNull(_descriptionController),
    activityKind: _selectedActivityKind.name,
    paceName: _selectedPace?.name,
    meetingPoint: _trimmedTextOrNull(_meetingPointController),
    locationDetails: _trimmedTextOrNull(_locationDetailsController),
    startingPointLat: _startingPoint?.latitude,
    startingPointLng: _startingPoint?.longitude,
    selectedDateMillis: _selectedDate?.millisecondsSinceEpoch,
    selectedStartHour: _selectedStartTime?.hour,
    selectedStartMinute: _selectedStartTime?.minute,
    durationMinutes: _durationMinutes,
    minAge: _trimmedTextOrNull(_minAgeController),
    maxAge: _trimmedTextOrNull(_maxAgeController),
    maxMen: _trimmedTextOrNull(_maxMenController),
    maxWomen: _trimmedTextOrNull(_maxWomenController),
    admissionPreset: _selectedAdmissionPreset.name,
    inviteCode: _trimmedTextOrNull(_inviteCodeController),
    dynamicPricingEnabled: _dynamicPricingEnabled,
    dynamicPricingStep: _trimmedTextOrNull(_dynamicPricingStepController),
    dynamicPricingMax: _trimmedTextOrNull(_dynamicPricingMaxController),
    cancellationPolicy: _selectedCancellationPolicyId.name,
  );

  static const Object _emptyDraftContentSignature = (
    distance: null,
    capacity: null,
    price: null,
    description: null,
    activityKind: 'socialRun',
    paceName: null,
    meetingPoint: null,
    locationDetails: null,
    startingPointLat: null,
    startingPointLng: null,
    selectedDateMillis: null,
    selectedStartHour: null,
    selectedStartMinute: null,
    durationMinutes: CatchBusinessRules.eventDefaultDurationMinutes,
    minAge: null,
    maxAge: null,
    maxMen: null,
    maxWomen: null,
    admissionPreset: 'openCapacity',
    inviteCode: null,
    dynamicPricingEnabled: false,
    dynamicPricingStep: null,
    dynamicPricingMax: null,
    cancellationPolicy: 'standard',
  );

  Future<void> _checkForDrafts() async {
    final drafts = await ref
        .read(createEventDraftControllerProvider.notifier)
        .loadDrafts(clubId: widget.club.id);
    if (!mounted || drafts.isEmpty) return;

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

    setState(() {
      // Event details
      if (draft.distance != null) {
        _distanceController.text = draft.distance!;
      }
      if (draft.capacity != null) {
        _capacityController.text = draft.capacity!;
      }
      if (draft.price != null) {
        _priceController.text = draft.price!;
      }
      if (draft.description != null) {
        _descriptionController.text = draft.description!;
      }
      _selectedActivityKind = _activityKindFromName(draft.activityKind);
      if (draft.paceName != null) {
        try {
          _selectedPace = PaceLevel.values.byName(draft.paceName!);
        } catch (_) {
          // Draft contained an unrecognized pace name — ignore and use default.
        }
      }

      // Where
      if (draft.meetingPoint != null) {
        _meetingPointController.text = draft.meetingPoint!;
      }
      if (draft.locationDetails != null) {
        _locationDetailsController.text = draft.locationDetails!;
      }
      if (draft.startingPointLat != null && draft.startingPointLng != null) {
        _startingPoint = LocationCoordinate(
          draft.startingPointLat!,
          draft.startingPointLng!,
        );
      }

      // When
      if (draft.selectedDateMillis != null) {
        final date = DateTime.fromMillisecondsSinceEpoch(
          draft.selectedDateMillis!,
        );
        _selectedDate = date;
        _dateController.text =
            '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
      }
      if (draft.selectedStartHour != null &&
          draft.selectedStartMinute != null) {
        _selectedStartTime = TimeOfDay(
          hour: draft.selectedStartHour!,
          minute: draft.selectedStartMinute!,
        );
        _startTimeController.text = _formatClockTime(_selectedStartTime!);
      }
      _durationMinutes = draft.durationMinutes;

      // Rules
      if (draft.minAge != null) {
        _minAgeController.text = draft.minAge!;
      }
      if (draft.maxAge != null) {
        _maxAgeController.text = draft.maxAge!;
      }
      if (draft.maxMen != null) {
        _maxMenController.text = draft.maxMen!;
      }
      if (draft.maxWomen != null) {
        _maxWomenController.text = draft.maxWomen!;
      }
      _selectedAdmissionPreset = _admissionPresetFromName(
        draft.admissionPreset,
      );
      if (draft.inviteCode != null) {
        _inviteCodeController.text = draft.inviteCode!;
      }
      _dynamicPricingEnabled = draft.dynamicPricingEnabled;
      if (draft.dynamicPricingStep != null) {
        _dynamicPricingStepController.text = draft.dynamicPricingStep!;
      }
      if (draft.dynamicPricingMax != null) {
        _dynamicPricingMaxController.text = draft.dynamicPricingMax!;
      }
      _selectedCancellationPolicyId = _cancellationPolicyFromName(
        draft.cancellationPolicy,
      );
    });
    _lastSavedDraftSignature = _currentDraftContentSignature;
  }

  Future<void> _deleteDraftFromPicker(EventDraft draft) {
    return CreateEventDraftController.deleteDraftMutation.run(
      ref,
      (tx) async => tx
          .get(createEventDraftControllerProvider.notifier)
          .deleteDraft(clubId: widget.club.id, draftId: draft.id),
    );
  }

  Future<void> _saveDraft() async {
    final draft = EventDraft(
      id: _activeDraftId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      clubId: widget.club.id,
      savedAt: DateTime.now(),
      distance: _trimmedTextOrNull(_distanceController),
      capacity: _trimmedTextOrNull(_capacityController),
      price: _trimmedTextOrNull(_priceController),
      description: _trimmedTextOrNull(_descriptionController),
      activityKind: _selectedActivityKind.name,
      paceName: _selectedPace?.name,
      meetingPoint: _trimmedTextOrNull(_meetingPointController),
      locationDetails: _trimmedTextOrNull(_locationDetailsController),
      startingPointLat: _startingPoint?.latitude,
      startingPointLng: _startingPoint?.longitude,
      selectedDateMillis: _selectedDate?.millisecondsSinceEpoch,
      selectedStartHour: _selectedStartTime?.hour,
      selectedStartMinute: _selectedStartTime?.minute,
      durationMinutes: _durationMinutes,
      minAge: _trimmedTextOrNull(_minAgeController),
      maxAge: _trimmedTextOrNull(_maxAgeController),
      maxMen: _trimmedTextOrNull(_maxMenController),
      maxWomen: _trimmedTextOrNull(_maxWomenController),
      admissionPreset: _selectedAdmissionPreset.name,
      inviteCode: _trimmedTextOrNull(_inviteCodeController),
      dynamicPricingEnabled: _dynamicPricingEnabled,
      dynamicPricingStep: _trimmedTextOrNull(_dynamicPricingStepController),
      dynamicPricingMax: _trimmedTextOrNull(_dynamicPricingMaxController),
      cancellationPolicy: _selectedCancellationPolicyId.name,
    );

    final wasUpdate = _activeDraftId != null;
    final savedDraft = await CreateEventDraftController.saveDraftMutation.run(
      ref,
      (tx) async =>
          tx.get(createEventDraftControllerProvider.notifier).saveDraft(draft),
    );
    if (savedDraft == null) return;

    _activeDraftId = savedDraft.id;
    _lastSavedDraftSignature = _currentDraftContentSignature;

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(wasUpdate ? 'Draft updated' : 'Draft saved'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showUnsavedChangesDialog() {
    showCatchAdaptiveDialog<bool>(
      context: context,
      title: 'Unsaved changes',
      message: 'You have unsaved changes. Would you like to save a draft?',
      actions: const [
        CatchDialogAction(label: 'Discard', value: false, isDestructive: true),
        CatchDialogAction(label: 'Save Draft', value: true, isDefault: true),
      ],
    ).then((save) async {
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

  static String _stepTitle(int step) => switch (step) {
    0 => 'Event basics',
    1 => 'Venue & meet point',
    2 => 'When is the event?',
    3 => 'Event policy',
    _ => throw RangeError.range(step, 0, _totalSteps - 1, 'step'),
  };

  static String _formatClockTime(TimeOfDay time) {
    return AppTimeFormatters.clockTime(hour: time.hour, minute: time.minute);
  }

  static EventAdmissionPreset _admissionPresetFromName(String? name) {
    if (name == null) return EventAdmissionPreset.openCapacity;
    return EventAdmissionPreset.values.firstWhere(
      (preset) => preset.name == name,
      orElse: () => EventAdmissionPreset.openCapacity,
    );
  }

  static EventCancellationPolicyId _cancellationPolicyFromName(String? name) {
    if (name == null) return EventCancellationPolicyId.standard;
    return EventCancellationPolicyId.values.firstWhere(
      (policyId) => policyId.name == name,
      orElse: () => EventCancellationPolicyId.standard,
    );
  }

  String? get _inviteCodeHint {
    final code = _inviteCodeController.text.trim();
    if (code.length <= 4) return code.isEmpty ? null : code;
    return '${code.substring(0, 2)}...${code.substring(code.length - 2)}';
  }

  static int? _rupeeControllerValueInPaise(TextEditingController controller) {
    final amount = double.tryParse(controller.text.trim());
    if (amount == null) return null;
    return (amount * 100).round();
  }

  double _distanceKmForSelectedActivity() {
    if (!_selectedActivityKind.isDistanceBased) return 0;
    return double.parse(_distanceController.text.trim());
  }

  static ActivityKind _activityKindFromName(String? name) {
    if (name == null) return ActivityKind.socialRun;
    return ActivityKind.values.firstWhere(
      (activityKind) => activityKind.name == name,
      orElse: () => ActivityKind.socialRun,
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final submitMutation = ref.watch(CreateEventController.submitMutation);

    final createdEvent = _createdEvent;
    if (createdEvent != null) {
      return _showHostManage
          ? HostEventManageScreen(
              club: widget.club,
              event: createdEvent,
              onBackToSuccess: () => setState(() => _showHostManage = false),
            )
          : CreateEventSuccessScreen(
              club: widget.club,
              event: createdEvent,
              inviteCode: _trimmedTextOrNull(_inviteCodeController),
              onManageEvent: () => setState(() => _showHostManage = true),
              onDone: () => Navigator.of(context).pop(),
            );
    }

    return Scaffold(
      backgroundColor: t.bg,
      body: SafeArea(
        child: Column(
          children: [
            CreateEventStepHeader(
              title: _stepTitle(_currentStep),
              clubName: widget.club.name,
              currentStep: _currentStep,
              totalSteps: _totalSteps,
              onBack: _back,
            ),
            const SizedBox(height: 4),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  EventDetailsStep(
                    formKey: _eventDetailsFormKey,
                    photoImageBytes: _eventPhoto?.bytes,
                    onPickPhoto: _pickEventPhoto,
                    distanceController: _distanceController,
                    descriptionController: _descriptionController,
                    selectedActivityKind: _selectedActivityKind,
                    onActivityKindChanged: (activityKind) => setState(() {
                      _selectedActivityKind = activityKind;
                      if (!activityKind.isDistanceBased) {
                        _selectedPace = null;
                      }
                    }),
                    selectedPace: _selectedPace,
                    onPaceChanged: (p) => setState(() => _selectedPace = p),
                  ),
                  WhereStep(
                    formKey: _whereFormKey,
                    meetingPointController: _meetingPointController,
                    locationDetailsController: _locationDetailsController,
                    startingPoint: _startingPoint,
                    onPickLocation: _pickLocation,
                  ),
                  WhenStep(
                    formKey: _whenFormKey,
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
                    capacityController: _capacityController,
                    priceController: _priceController,
                    inviteCodeController: _inviteCodeController,
                    dynamicPricingStepController: _dynamicPricingStepController,
                    dynamicPricingMaxController: _dynamicPricingMaxController,
                    minAgeController: _minAgeController,
                    maxAgeController: _maxAgeController,
                    maxMenController: _maxMenController,
                    maxWomenController: _maxWomenController,
                    admissionPreset: _selectedAdmissionPreset,
                    onAdmissionPresetChanged: (preset) => setState(() {
                      _selectedAdmissionPreset = preset;
                      if (preset != EventAdmissionPreset.balancedSingles) {
                        _dynamicPricingEnabled = false;
                      }
                    }),
                    dynamicPricingEnabled: _dynamicPricingEnabled,
                    onDynamicPricingChanged: (enabled) =>
                        setState(() => _dynamicPricingEnabled = enabled),
                    cancellationPolicyId: _selectedCancellationPolicyId,
                    onCancellationPolicyChanged: (policyId) => setState(
                      () => _selectedCancellationPolicyId = policyId,
                    ),
                  ),
                ],
              ),
            ),
            if (submitMutation.hasError)
              ErrorBanner(message: mutationErrorMessage(submitMutation)),
            StepperFooter(
              isLastStep: _currentStep == _totalSteps - 1,
              isLoading: submitMutation.isPending,
              onNext: _next,
              onSaveDraft: _saveDraft,
            ),
          ],
        ),
      ),
    );
  }
}
