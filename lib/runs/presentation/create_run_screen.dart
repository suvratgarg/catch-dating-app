import 'package:catch_dating_app/core/business_rules.dart';
import 'package:catch_dating_app/core/device_location.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/time_formatters.dart';
import 'package:catch_dating_app/core/widgets/catch_adaptive_dialog.dart';
import 'package:catch_dating_app/core/widgets/catch_adaptive_picker.dart';
import 'package:catch_dating_app/core/widgets/error_banner.dart';
import 'package:catch_dating_app/core/widgets/mutation_error_util.dart';
import 'package:catch_dating_app/locations/domain/location_coordinate.dart';
import 'package:catch_dating_app/run_clubs/domain/run_club.dart';
import 'package:catch_dating_app/runs/domain/run.dart';
import 'package:catch_dating_app/runs/domain/run_constraints.dart';
import 'package:catch_dating_app/runs/domain/run_draft.dart';
import 'package:catch_dating_app/runs/presentation/create_run_controller.dart';
import 'package:catch_dating_app/runs/presentation/create_run_draft_controller.dart';
import 'package:catch_dating_app/runs/presentation/create_run_success_screen.dart';
import 'package:catch_dating_app/runs/presentation/host_run_manage_screen.dart';
import 'package:catch_dating_app/runs/presentation/location_picker_screen.dart';
import 'package:catch_dating_app/runs/presentation/run_formatters.dart';
import 'package:catch_dating_app/runs/presentation/widgets/create_run_step_header.dart';
import 'package:catch_dating_app/runs/presentation/widgets/draft_picker_sheet.dart';
import 'package:catch_dating_app/runs/presentation/widgets/eligibility_step.dart';
import 'package:catch_dating_app/runs/presentation/widgets/run_details_step.dart';
import 'package:catch_dating_app/runs/presentation/widgets/stepper_footer.dart';
import 'package:catch_dating_app/runs/presentation/widgets/when_step.dart';
import 'package:catch_dating_app/runs/presentation/widgets/where_step.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

DateTime _systemNow() => DateTime.now();

class CreateRunScreen extends ConsumerStatefulWidget {
  const CreateRunScreen({
    super.key,
    required this.runClub,
    this.loadMapTiles = true,
    this.now = _systemNow,
  });

  final RunClub runClub;

  /// Tests can disable network tiles while still exercising map callbacks.
  final bool loadMapTiles;

  /// Current time source, injectable so same-day time validation is testable.
  final DateTime Function() now;

  @override
  ConsumerState<CreateRunScreen> createState() => _CreateRunScreenState();
}

class _CreateRunScreenState extends ConsumerState<CreateRunScreen> {
  static const _totalSteps = 4;
  final _pageController = PageController();
  int _currentStep = 0;
  Run? _createdRun;
  bool _showHostManage = false;

  // Draft support
  String? _activeDraftId;
  Object? _lastSavedDraftSignature;
  bool _checkedDrafts = false;

  final _runDetailsFormKey = GlobalKey<FormState>();
  final _whereFormKey = GlobalKey<FormState>();
  final _whenFormKey = GlobalKey<FormState>();
  final _eligibilityFormKey = GlobalKey<FormState>();

  // Step 2 — When
  final _dateController = TextEditingController();
  final _startTimeController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedStartTime;
  int _durationMinutes = CatchBusinessRules.runDefaultDurationMinutes;
  String? _scheduleErrorText;

  static const _futureStartError = 'Choose a start time later than now';

  // Step 1 — Where
  final _meetingPointController = TextEditingController();
  final _locationDetailsController = TextEditingController();
  LocationCoordinate? _startingPoint;

  // Step 0 — Run details
  final _distanceController = TextEditingController();
  final _capacityController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  PaceLevel? _selectedPace;
  PickedRunPhoto? _runPhoto;

  // Step 3 — Rules
  final _minAgeController = TextEditingController();
  final _maxAgeController = TextEditingController();
  final _maxMenController = TextEditingController();
  final _maxWomenController = TextEditingController();

  GlobalKey<FormState> get _currentStepKey => switch (_currentStep) {
    0 => _runDetailsFormKey,
    1 => _whereFormKey,
    2 => _whenFormKey,
    _ => _eligibilityFormKey,
  };

  DateTime? get _selectedStartDateTime {
    final selectedDate = _selectedDate;
    final selectedStartTime = _selectedStartTime;
    if (selectedDate == null || selectedStartTime == null) return null;
    return _combine(selectedDate, selectedStartTime);
  }

  RunConstraints get _constraints => RunConstraints(
    minAge: int.tryParse(_minAgeController.text.trim()) ?? 0,
    maxAge: int.tryParse(_maxAgeController.text.trim()) ?? 99,
    maxMen: int.tryParse(_maxMenController.text.trim()),
    maxWomen: int.tryParse(_maxWomenController.text.trim()),
  );

  VoidCallback? get _decreaseDurationCallback =>
      _durationMinutes > CatchBusinessRules.runMinDurationMinutes
      ? () => setState(
          () => _durationMinutes -= CatchBusinessRules.runDurationStepMinutes,
        )
      : null;

  VoidCallback? get _increaseDurationCallback =>
      _durationMinutes < CatchBusinessRules.runMaxDurationMinutes
      ? () => setState(
          () => _durationMinutes += CatchBusinessRules.runDurationStepMinutes,
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
    super.dispose();
  }

  Future<void> _pickDate() async {
    final today = DateUtils.dateOnly(widget.now());
    final picked = await showCatchDatePicker(
      context: context,
      initialDate: _selectedDate ?? today,
      firstDate: today,
      lastDate: today.add(const Duration(days: 365)),
      title: 'Run date',
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

  Future<void> _pickRunPhoto() async {
    final picked = await ref
        .read(createRunControllerProvider.notifier)
        .pickRunPhoto();
    if (!mounted || picked == null) return;
    setState(() => _runPhoto = picked);
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

    CreateRunController.submitMutation.run(ref, (tx) async {
      final createdRun = await tx
          .get(createRunControllerProvider.notifier)
          .submit(
            runClubId: widget.runClub.id,
            startTime: startTime,
            endTime: endTime,
            meetingPoint: _meetingPointController.text.trim(),
            startingPointLat: _startingPoint?.latitude,
            startingPointLng: _startingPoint?.longitude,
            locationDetails: _trimmedTextOrNull(_locationDetailsController),
            distanceKm: double.parse(_distanceController.text.trim()),
            pace: _selectedPace!,
            capacityLimit: int.parse(_capacityController.text.trim()),
            description: _descriptionController.text.trim(),
            priceInPaise: (double.parse(_priceController.text.trim()) * 100)
                .round(),
            constraints: _constraints,
            photoImage: _runPhoto?.image,
          );
      if (mounted) {
        setState(() => _createdRun = createdRun);
      }

      // Delete the restored-from draft after successful submission.
      final draftId = _activeDraftId;
      if (draftId != null) {
        await CreateRunDraftController.deleteDraftMutation.run(
          ref,
          (tx) async => tx
              .get(createRunDraftControllerProvider.notifier)
              .deleteDraft(runClubId: widget.runClub.id, draftId: draftId),
        );
      }

      return createdRun;
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
  );

  static const Object _emptyDraftContentSignature = (
    distance: null,
    capacity: null,
    price: null,
    description: null,
    paceName: null,
    meetingPoint: null,
    locationDetails: null,
    startingPointLat: null,
    startingPointLng: null,
    selectedDateMillis: null,
    selectedStartHour: null,
    selectedStartMinute: null,
    durationMinutes: CatchBusinessRules.runDefaultDurationMinutes,
    minAge: null,
    maxAge: null,
    maxMen: null,
    maxWomen: null,
  );

  Future<void> _checkForDrafts() async {
    final drafts = await ref
        .read(createRunDraftControllerProvider.notifier)
        .loadDrafts(runClubId: widget.runClub.id);
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

  void _restoreFromDraft(RunDraft draft) {
    _activeDraftId = draft.id;

    setState(() {
      // Run details
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
    });
    _lastSavedDraftSignature = _currentDraftContentSignature;
  }

  Future<void> _deleteDraftFromPicker(RunDraft draft) {
    return CreateRunDraftController.deleteDraftMutation.run(
      ref,
      (tx) async => tx
          .get(createRunDraftControllerProvider.notifier)
          .deleteDraft(runClubId: widget.runClub.id, draftId: draft.id),
    );
  }

  Future<void> _saveDraft() async {
    final draft = RunDraft(
      id: _activeDraftId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      runClubId: widget.runClub.id,
      savedAt: DateTime.now(),
      distance: _trimmedTextOrNull(_distanceController),
      capacity: _trimmedTextOrNull(_capacityController),
      price: _trimmedTextOrNull(_priceController),
      description: _trimmedTextOrNull(_descriptionController),
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
    );

    final wasUpdate = _activeDraftId != null;
    final savedDraft = await CreateRunDraftController.saveDraftMutation.run(
      ref,
      (tx) async =>
          tx.get(createRunDraftControllerProvider.notifier).saveDraft(draft),
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
    0 => 'Run basics',
    1 => 'Route & meet point',
    2 => 'When is the run?',
    3 => 'Review & rules',
    _ => throw RangeError.range(step, 0, _totalSteps - 1, 'step'),
  };

  static String _formatClockTime(TimeOfDay time) {
    return AppTimeFormatters.clockTime(hour: time.hour, minute: time.minute);
  }

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final submitMutation = ref.watch(CreateRunController.submitMutation);

    final createdRun = _createdRun;
    if (createdRun != null) {
      return _showHostManage
          ? HostRunManageScreen(
              runClub: widget.runClub,
              run: createdRun,
              onBackToSuccess: () => setState(() => _showHostManage = false),
            )
          : CreateRunSuccessScreen(
              runClub: widget.runClub,
              run: createdRun,
              onManageRun: () => setState(() => _showHostManage = true),
              onDone: () => Navigator.of(context).pop(),
            );
    }

    return Scaffold(
      backgroundColor: t.bg,
      body: SafeArea(
        child: Column(
          children: [
            CreateRunStepHeader(
              title: _stepTitle(_currentStep),
              runClubName: widget.runClub.name,
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
                  RunDetailsStep(
                    formKey: _runDetailsFormKey,
                    photoImageBytes: _runPhoto?.bytes,
                    onPickPhoto: _pickRunPhoto,
                    distanceController: _distanceController,
                    capacityController: _capacityController,
                    priceController: _priceController,
                    descriptionController: _descriptionController,
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
                    formatDuration: RunFormatters.durationMinutes,
                    scheduleErrorText: _scheduleErrorText,
                  ),
                  EligibilityStep(
                    formKey: _eligibilityFormKey,
                    minAgeController: _minAgeController,
                    maxAgeController: _maxAgeController,
                    maxMenController: _maxMenController,
                    maxWomenController: _maxWomenController,
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
