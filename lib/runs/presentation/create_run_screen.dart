import 'package:catch_dating_app/auth/auth_repository.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_error_banner.dart';
import 'package:catch_dating_app/core/widgets/icon_btn.dart';
import 'package:catch_dating_app/run_clubs/domain/run_club.dart';
import 'package:catch_dating_app/runs/domain/run.dart';
import 'package:catch_dating_app/runs/domain/run_constraints.dart';
import 'package:catch_dating_app/runs/presentation/create_run_controller.dart';
import 'package:catch_dating_app/runs/presentation/location_picker_screen.dart';
import 'package:catch_dating_app/runs/presentation/run_formatters.dart';
import 'package:catch_dating_app/runs/presentation/widgets/eligibility_step.dart';
import 'package:catch_dating_app/runs/presentation/widgets/run_details_step.dart';
import 'package:catch_dating_app/runs/presentation/widgets/step_progress_bar.dart';
import 'package:catch_dating_app/runs/presentation/widgets/stepper_footer.dart';
import 'package:catch_dating_app/runs/presentation/widgets/when_step.dart';
import 'package:catch_dating_app/runs/data/run_draft_repository.dart';
import 'package:catch_dating_app/runs/domain/run_draft.dart';
import 'package:catch_dating_app/runs/presentation/widgets/draft_picker_sheet.dart';
import 'package:catch_dating_app/runs/presentation/widgets/where_step.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/experimental/mutation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

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
  bool _checkedDrafts = false;

  final _step0Key = GlobalKey<FormState>();
  final _step1Key = GlobalKey<FormState>();
  final _step2Key = GlobalKey<FormState>();
  final _step3Key = GlobalKey<FormState>();

  // Step 0 — When
  final _dateController = TextEditingController();
  final _startTimeController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedStartTime;
  int _durationMinutes = 60;
  String? _scheduleErrorText;

  static const _minDuration = 30;
  static const _maxDuration = 240;
  static const _durationStep = 15;
  static const _futureStartError = 'Choose a start time later than now';

  // Step 1 — Where
  final _meetingPointController = TextEditingController();
  final _locationDetailsController = TextEditingController();
  LatLng? _startingPoint;

  // Step 2 — The run
  final _distanceController = TextEditingController();
  final _capacityController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  PaceLevel? _selectedPace;

  // Step 3 — Rules
  final _minAgeController = TextEditingController();
  final _maxAgeController = TextEditingController();
  final _maxMenController = TextEditingController();
  final _maxWomenController = TextEditingController();

  GlobalKey<FormState> get _currentStepKey => switch (_currentStep) {
    0 => _step2Key,
    1 => _step1Key,
    2 => _step0Key,
    _ => _step3Key,
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

  VoidCallback? get _decreaseDurationCallback => _durationMinutes > _minDuration
      ? () => setState(() => _durationMinutes -= _durationStep)
      : null;

  VoidCallback? get _increaseDurationCallback => _durationMinutes < _maxDuration
      ? () => setState(() => _durationMinutes += _durationStep)
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
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? today,
      firstDate: today,
      lastDate: today.add(const Duration(days: 365)),
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
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedStartTime ?? _initialStartTime(),
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
        _startTimeController.text =
            '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      });
    }
  }

  Future<void> _pickLocation() async {
    final result = await Navigator.of(context).push<LatLng>(
      MaterialPageRoute(
        builder: (_) => LocationPickerScreen(
          initialLocation: _startingPoint,
          loadMapTiles: widget.loadMapTiles,
        ),
        fullscreenDialog: true,
      ),
    );
    if (result != null) {
      setState(() => _startingPoint = result);
    }
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
          );
      if (mounted) {
        setState(() => _createdRun = createdRun);
      }

      // Delete the restored-from draft after successful submission.
      final draftId = _activeDraftId;
      if (draftId != null) {
        final uid = ref.read(uidProvider).asData?.value;
        if (uid != null) {
          await ref.read(runDraftRepositoryProvider).deleteDraft(
                runClubId: widget.runClub.id,
                userId: uid,
                draftId: draftId,
              );
        }
      }

      return createdRun;
    });
  }

  bool get _hasUnsavedChanges =>
      _activeDraftId == null &&
      (_trimmedTextOrNull(_distanceController) != null ||
          _trimmedTextOrNull(_capacityController) != null ||
          _trimmedTextOrNull(_priceController) != null ||
          _trimmedTextOrNull(_descriptionController) != null ||
          _selectedPace != null ||
          _trimmedTextOrNull(_meetingPointController) != null ||
          _trimmedTextOrNull(_locationDetailsController) != null ||
          _startingPoint != null ||
          _selectedDate != null ||
          _selectedStartTime != null ||
          _durationMinutes != 60 ||
          _trimmedTextOrNull(_minAgeController) != null ||
          _trimmedTextOrNull(_maxAgeController) != null ||
          _trimmedTextOrNull(_maxMenController) != null ||
          _trimmedTextOrNull(_maxWomenController) != null);

  Future<void> _checkForDrafts() async {
    final uid = ref.read(uidProvider).asData?.value;
    if (uid == null) return;

    final drafts = await ref.read(runDraftRepositoryProvider).loadDrafts(
          runClubId: widget.runClub.id,
          userId: uid,
        );
    if (!mounted || drafts.isEmpty) return;

    final picked = await showDraftPickerSheet(
      context: context,
      drafts: drafts,
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
        } catch (_) {}
      }

      // Where
      if (draft.meetingPoint != null) {
        _meetingPointController.text = draft.meetingPoint!;
      }
      if (draft.locationDetails != null) {
        _locationDetailsController.text = draft.locationDetails!;
      }
      if (draft.startingPointLat != null && draft.startingPointLng != null) {
        _startingPoint = LatLng(
          draft.startingPointLat!,
          draft.startingPointLng!,
        );
      }

      // When
      if (draft.selectedDateMillis != null) {
        final date =
            DateTime.fromMillisecondsSinceEpoch(draft.selectedDateMillis!);
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
        _startTimeController.text =
            '${draft.selectedStartHour.toString().padLeft(2, '0')}:${draft.selectedStartMinute.toString().padLeft(2, '0')}';
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
  }

  Future<void> _saveDraft() async {
    final uid = ref.read(uidProvider).asData?.value;
    if (uid == null) return;

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

    if (draft.isEmpty) return;

    await ref
        .read(runDraftRepositoryProvider)
        .saveDraft(userId: uid, draft: draft);
    _activeDraftId = draft.id;

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _activeDraftId != null ? 'Draft updated' : 'Draft saved',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showUnsavedChangesDialog() {
    showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Unsaved changes'),
        content: const Text(
          'You have unsaved changes. Would you like to save a draft?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Discard'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop(true);
            },
            child: const Text('Save Draft'),
          ),
        ],
      ),
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
    _ => 'Review & rules',
  };

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
            Padding(
              padding: const EdgeInsets.fromLTRB(
                CatchSpacing.s5,
                12,
                CatchSpacing.s5,
                0,
              ),
              child: Row(
                children: [
                  IconBtn(
                    onTap: _back,
                    child: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 18,
                      color: t.ink,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _stepTitle(_currentStep),
                          style: CatchTextStyles.titleL(context),
                        ),
                        Text(
                          widget.runClub.name,
                          style: CatchTextStyles.bodyS(context, color: t.ink2),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${_currentStep + 1}/$_totalSteps',
                    style: CatchTextStyles.labelL(context, color: t.ink2),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                CatchSpacing.s5,
                12,
                CatchSpacing.s5,
                0,
              ),
              child: StepProgressBar(
                currentStep: _currentStep,
                totalSteps: _totalSteps,
              ),
            ),
            const SizedBox(height: 4),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  RunDetailsStep(
                    formKey: _step2Key,
                    distanceController: _distanceController,
                    capacityController: _capacityController,
                    priceController: _priceController,
                    descriptionController: _descriptionController,
                    selectedPace: _selectedPace,
                    onPaceChanged: (p) => setState(() => _selectedPace = p),
                  ),
                  WhereStep(
                    formKey: _step1Key,
                    meetingPointController: _meetingPointController,
                    locationDetailsController: _locationDetailsController,
                    startingPoint: _startingPoint,
                    onPickLocation: _pickLocation,
                  ),
                  WhenStep(
                    formKey: _step0Key,
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
                    formKey: _step3Key,
                    minAgeController: _minAgeController,
                    maxAgeController: _maxAgeController,
                    maxMenController: _maxMenController,
                    maxWomenController: _maxWomenController,
                  ),
                ],
              ),
            ),
            if (submitMutation.hasError)
              CatchErrorBanner(
                message: (submitMutation as MutationError).error.toString(),
              ),
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

class CreateRunSuccessScreen extends StatelessWidget {
  const CreateRunSuccessScreen({
    super.key,
    required this.runClub,
    required this.run,
    required this.onManageRun,
    required this.onDone,
  });

  final RunClub runClub;
  final Run run;
  final VoidCallback onManageRun;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    const successInk = Color(0xFF1A1410);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: CatchTokens.sunsetLight.heroGrad),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(CatchSpacing.s5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: IconBtn(
                    background: successInk.withValues(alpha: 0.16),
                    onTap: onDone,
                    child: const Icon(Icons.close_rounded, color: successInk),
                  ),
                ),
                const Spacer(),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    width: 78,
                    height: 78,
                    decoration: BoxDecoration(
                      color: successInk.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: successInk.withValues(alpha: 0.18),
                      ),
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: successInk,
                      size: 38,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Your run is live.',
                  style: CatchTextStyles.displayXL(
                    context,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '${run.title} is now listed on ${runClub.name}. Followers can discover it from their home feed.',
                  style: CatchTextStyles.bodyL(context, color: Colors.white),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: successInk.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(CatchRadius.lg),
                    border: Border.all(
                      color: successInk.withValues(alpha: 0.18),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.bolt_rounded,
                        color: successInk,
                        size: 18,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Bookings, waitlist, and attendance are tracked from Manage run.',
                          style: CatchTextStyles.bodyS(
                            context,
                            color: successInk,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                CatchButton(
                  label: 'Manage run',
                  onPressed: onManageRun,
                  fullWidth: true,
                  backgroundColor: Colors.white,
                  foregroundColor: successInk,
                  borderColor: Colors.transparent,
                ),
                const SizedBox(height: 10),
                CatchButton(
                  label: 'Back to club',
                  onPressed: onDone,
                  variant: CatchButtonVariant.secondary,
                  fullWidth: true,
                  backgroundColor: Colors.white.withValues(alpha: 0.72),
                  foregroundColor: successInk,
                  borderColor: successInk.withValues(alpha: 0.20),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class HostRunManageScreen extends StatelessWidget {
  const HostRunManageScreen({
    super.key,
    required this.runClub,
    required this.run,
    required this.onBackToSuccess,
  });

  final RunClub runClub;
  final Run run;
  final VoidCallback onBackToSuccess;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final revenueRupees = run.signedUpCount * (run.priceInPaise ~/ 100);

    return Scaffold(
      backgroundColor: t.bg,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            CatchSpacing.s5,
            12,
            CatchSpacing.s5,
            24,
          ),
          children: [
            Row(
              children: [
                IconBtn(
                  onTap: onBackToSuccess,
                  child: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 18,
                    color: t.ink,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'HOST MANAGE',
                        style: CatchTextStyles.labelM(context, color: t.ink3)
                            .copyWith(
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                            ),
                      ),
                      Text(run.title, style: CatchTextStyles.titleL(context)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            if (run.isFull) ...[
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: t.ink,
                  borderRadius: BorderRadius.circular(CatchRadius.lg),
                ),
                child: Row(
                  children: [
                    Icon(Icons.lock_rounded, color: t.surface, size: 18),
                    const SizedBox(width: 10),
                    Text(
                      'FULL',
                      style: CatchTextStyles.titleM(context, color: t.surface),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
            Row(
              children: [
                _HostManageStat(
                  label: 'Booked',
                  value: '${run.signedUpCount}/${run.capacityLimit}',
                  icon: Icons.check_circle_outline_rounded,
                ),
                const SizedBox(width: 8),
                _HostManageStat(
                  label: 'Waitlist',
                  value: '${run.waitlistUserIds.length}',
                  icon: Icons.access_time_rounded,
                ),
                const SizedBox(width: 8),
                _HostManageStat(
                  label: 'Revenue',
                  value: revenueRupees > 0 ? '₹$revenueRupees' : '—',
                  icon: Icons.currency_rupee_rounded,
                ),
              ],
            ),
            const SizedBox(height: 20),
            _HostRunSummaryCard(runClub: runClub, run: run),
            const SizedBox(height: 20),
            Text('Roster', style: CatchTextStyles.titleL(context)),
            const SizedBox(height: 10),
            _HostUserList(
              userIds: run.signedUpUserIds,
              emptyText: 'No bookings yet.',
              trailingLabel: run.isFree ? 'FREE' : 'PAID',
            ),
            const SizedBox(height: 20),
            Text('Waitlist', style: CatchTextStyles.titleL(context)),
            const SizedBox(height: 10),
            _HostUserList(
              userIds: run.waitlistUserIds,
              emptyText: 'No one is waiting.',
              trailingLabel: 'WAITLIST',
            ),
          ],
        ),
      ),
    );
  }
}

class _HostManageStat extends StatelessWidget {
  const _HostManageStat({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        decoration: BoxDecoration(
          color: t.surface,
          borderRadius: BorderRadius.circular(CatchRadius.lg),
          border: Border.all(color: t.line),
        ),
        child: Column(
          children: [
            Icon(icon, color: t.primary, size: 18),
            const SizedBox(height: 6),
            Text(value, style: CatchTextStyles.titleM(context)),
            const SizedBox(height: 2),
            Text(label, style: CatchTextStyles.bodyS(context)),
          ],
        ),
      ),
    );
  }
}

class _HostRunSummaryCard extends StatelessWidget {
  const _HostRunSummaryCard({required this.runClub, required this.run});

  final RunClub runClub;
  final Run run;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final price = run.isFree ? 'Free' : '₹${run.priceInPaise ~/ 100}';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: t.surface,
        borderRadius: BorderRadius.circular(CatchRadius.lg),
        border: Border.all(color: t.line),
      ),
      child: Column(
        children: [
          _HostSummaryRow(
            icon: Icons.groups_rounded,
            label: 'Club',
            value: runClub.name,
          ),
          _HostSummaryRow(
            icon: Icons.location_on_outlined,
            label: 'Meet',
            value: run.meetingPoint,
          ),
          _HostSummaryRow(
            icon: Icons.route_rounded,
            label: 'Run',
            value:
                '${run.distanceKm.toStringAsFixed(1)} km · ${run.pace.label}',
          ),
          _HostSummaryRow(
            icon: Icons.payments_outlined,
            label: 'Price',
            value: price,
            showDivider: false,
          ),
        ],
      ),
    );
  }
}

class _HostSummaryRow extends StatelessWidget {
  const _HostSummaryRow({
    required this.icon,
    required this.label,
    required this.value,
    this.showDivider = true,
  });

  final IconData icon;
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
            Icon(icon, color: t.ink2, size: 18),
            const SizedBox(width: 10),
            Text(label, style: CatchTextStyles.bodyS(context, color: t.ink2)),
            const Spacer(),
            Flexible(
              child: Text(
                value,
                style: CatchTextStyles.labelL(context),
                textAlign: TextAlign.right,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        if (showDivider) ...[
          const SizedBox(height: 12),
          Divider(color: t.line, height: 1),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _HostUserList extends StatelessWidget {
  const _HostUserList({
    required this.userIds,
    required this.emptyText,
    required this.trailingLabel,
  });

  final List<String> userIds;
  final String emptyText;
  final String trailingLabel;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return Container(
      decoration: BoxDecoration(
        color: t.surface,
        borderRadius: BorderRadius.circular(CatchRadius.lg),
        border: Border.all(color: t.line),
      ),
      child: userIds.isEmpty
          ? Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                emptyText,
                style: CatchTextStyles.bodyM(context, color: t.ink2),
              ),
            )
          : Column(
              children: [
                for (var i = 0; i < userIds.length; i++) ...[
                  ListTile(
                    leading: CircleAvatar(
                      backgroundColor: t.primarySoft,
                      child: Text(
                        userIds[i].characters.first.toUpperCase(),
                        style: CatchTextStyles.labelL(
                          context,
                          color: t.primary,
                        ),
                      ),
                    ),
                    title: Text('Runner ${i + 1}'),
                    subtitle: Text(userIds[i]),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: t.primarySoft,
                        borderRadius: BorderRadius.circular(CatchRadius.pill),
                      ),
                      child: Text(
                        trailingLabel,
                        style: CatchTextStyles.labelM(
                          context,
                          color: t.primary,
                        ),
                      ),
                    ),
                  ),
                  if (i < userIds.length - 1) Divider(color: t.line, height: 1),
                ],
              ],
            ),
    );
  }
}
