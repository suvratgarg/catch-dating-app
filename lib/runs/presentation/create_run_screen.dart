import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
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
import 'package:catch_dating_app/runs/presentation/widgets/where_step.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/experimental/mutation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

class CreateRunScreen extends ConsumerStatefulWidget {
  const CreateRunScreen({super.key, required this.runClub});

  final RunClub runClub;

  @override
  ConsumerState<CreateRunScreen> createState() => _CreateRunScreenState();
}

class _CreateRunScreenState extends ConsumerState<CreateRunScreen> {
  static const _totalSteps = 4;
  final _pageController = PageController();
  int _currentStep = 0;

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
    0 => _step0Key,
    1 => _step1Key,
    2 => _step2Key,
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
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _scheduleErrorText = null;
        _selectedDate = picked;
        _dateController.text =
            '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
      });
    }
  }

  Future<void> _pickStartTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedStartTime ?? const TimeOfDay(hour: 7, minute: 0),
    );
    if (picked != null) {
      setState(() {
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
        builder: (_) => LocationPickerScreen(initialLocation: _startingPoint),
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
    if (_currentStep != 0) return true;

    final startTime = _selectedStartDateTime;
    if (startTime == null) return false;
    if (startTime.isAfter(DateTime.now())) return true;

    setState(() => _scheduleErrorText = 'Start time must be in the future');
    return false;
  }

  void _submit() {
    final startTime = _selectedStartDateTime!;
    final endTime = startTime.add(Duration(minutes: _durationMinutes));

    CreateRunController.submitMutation.run(ref, (tx) async {
      await tx
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
    });
  }

  static String? _trimmedTextOrNull(TextEditingController controller) {
    final text = controller.text.trim();
    return text.isEmpty ? null : text;
  }

  static String _stepTitle(int step) => switch (step) {
    0 => 'When is the run?',
    1 => 'Where does it start?',
    2 => 'Tell us about the run',
    _ => 'Any rules? (optional)',
  };

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final submitMutation = ref.watch(CreateRunController.submitMutation);

    ref.listen(CreateRunController.submitMutation, (prev, next) {
      if (prev?.isPending == true && next.isSuccess) {
        Navigator.of(context).pop();
      }
    });

    return Scaffold(
      backgroundColor: t.bg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                CatchSpacing.screenH,
                12,
                CatchSpacing.screenH,
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
                          style: CatchTextStyles.displaySm(context),
                        ),
                        Text(
                          widget.runClub.name,
                          style: CatchTextStyles.bodySm(context, color: t.ink2),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${_currentStep + 1}/$_totalSteps',
                    style: CatchTextStyles.labelMd(context, color: t.ink2),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                CatchSpacing.screenH,
                12,
                CatchSpacing.screenH,
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
                  WhereStep(
                    formKey: _step1Key,
                    meetingPointController: _meetingPointController,
                    locationDetailsController: _locationDetailsController,
                    startingPoint: _startingPoint,
                    onPickLocation: _pickLocation,
                  ),
                  RunDetailsStep(
                    formKey: _step2Key,
                    distanceController: _distanceController,
                    capacityController: _capacityController,
                    priceController: _priceController,
                    descriptionController: _descriptionController,
                    selectedPace: _selectedPace,
                    onPaceChanged: (p) => setState(() => _selectedPace = p),
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
            ),
          ],
        ),
      ),
    );
  }
}
