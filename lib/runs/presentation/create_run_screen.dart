import 'package:catch_dating_app/commonWidgets/app_form_layout.dart';
import 'package:catch_dating_app/runClubs/domain/run_club.dart';
import 'package:catch_dating_app/runs/domain/run.dart';
import 'package:catch_dating_app/runs/domain/run_constraints.dart';
import 'package:catch_dating_app/runs/presentation/create_run_controller.dart';
import 'package:catch_dating_app/runs/presentation/location_picker_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  static const _fieldSpacing = 16.0;
  static const _buttonTopSpacing = 24.0;
  static const _minDuration = 30;
  static const _maxDuration = 240;
  static const _durationStep = 15;

  final _formKey = GlobalKey<FormState>();
  final _dateController = TextEditingController();
  final _startTimeController = TextEditingController();
  final _meetingPointController = TextEditingController();
  final _locationDetailsController = TextEditingController();
  final _distanceController = TextEditingController();
  final _capacityController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  // Eligibility constraint controllers (all optional — empty = no constraint).
  final _minAgeController = TextEditingController();
  final _maxAgeController = TextEditingController();
  final _maxMenController = TextEditingController();
  final _maxWomenController = TextEditingController();

  DateTime? _selectedDate;
  TimeOfDay? _selectedStartTime;
  int _durationMinutes = 60;
  PaceLevel? _selectedPace;
  LatLng? _startingPoint;

  @override
  void dispose() {
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
        _selectedStartTime = picked;
        _startTimeController.text =
            '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      });
    }
  }

  Future<void> _pickLocation() async {
    final result = await Navigator.of(context).push<LatLng>(
      MaterialPageRoute(
        builder: (_) =>
            LocationPickerScreen(initialLocation: _startingPoint),
        fullscreenDialog: true,
      ),
    );
    if (result != null) {
      setState(() => _startingPoint = result);
    }
  }

  static String _formatDuration(int minutes) {
    final h = minutes ~/ 60;
    final m = minutes % 60;
    if (h == 0) return '${m}m';
    if (m == 0) return '${h}h';
    return '${h}h ${m}m';
  }

  DateTime _combine(DateTime date, TimeOfDay time) =>
      DateTime(date.year, date.month, date.day, time.hour, time.minute);

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final startTime = _combine(_selectedDate!, _selectedStartTime!);
    final endTime = startTime.add(Duration(minutes: _durationMinutes));

    final constraints = RunConstraints(
      minAge: int.tryParse(_minAgeController.text.trim()) ?? 0,
      maxAge: int.tryParse(_maxAgeController.text.trim()) ?? 99,
      maxMen: int.tryParse(_maxMenController.text.trim()),
      maxWomen: int.tryParse(_maxWomenController.text.trim()),
    );

    CreateRunController.submitMutation.run(ref, (transaction) async {
      await transaction.get(createRunControllerProvider.notifier).submit(
            runClubId: widget.runClub.id,
            startTime: startTime,
            endTime: endTime,
            meetingPoint: _meetingPointController.text.trim(),
            startingPointLat: _startingPoint?.latitude,
            startingPointLng: _startingPoint?.longitude,
            locationDetails: _locationDetailsController.text.trim().isEmpty
                ? null
                : _locationDetailsController.text.trim(),
            distanceKm: double.parse(_distanceController.text.trim()),
            pace: _selectedPace!,
            capacityLimit: int.parse(_capacityController.text.trim()),
            description: _descriptionController.text.trim(),
            priceInPaise:
                (double.parse(_priceController.text.trim()) * 100).round(),
            constraints: constraints,
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    final submitMutation = ref.watch(CreateRunController.submitMutation);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    ref.listen(CreateRunController.submitMutation, (previous, current) {
      if (previous?.isPending == true && current.isSuccess) {
        Navigator.of(context).pop();
      }
    });

    return Scaffold(
      appBar: AppBar(title: Text('New run · ${widget.runClub.name}')),
      body: AppFormLayout(
        formKey: _formKey,
        children: [
          // Date
          TextFormField(
            controller: _dateController,
            readOnly: true,
            onTap: _pickDate,
            decoration: const InputDecoration(
              labelText: 'Date',
              prefixIcon: Icon(Icons.calendar_today_outlined),
            ),
            validator: (_) =>
                _selectedDate == null ? 'Please select a date' : null,
          ),
          const SizedBox(height: _fieldSpacing),
          // Start time + duration side by side
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _startTimeController,
                  readOnly: true,
                  onTap: _pickStartTime,
                  decoration: const InputDecoration(
                    labelText: 'Start time',
                    prefixIcon: Icon(Icons.schedule_outlined),
                  ),
                  validator: (_) =>
                      _selectedStartTime == null ? 'Required' : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Duration',
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove),
                        visualDensity: VisualDensity.compact,
                        onPressed: _durationMinutes > _minDuration
                            ? () => setState(
                                  () => _durationMinutes -= _durationStep,
                                )
                            : null,
                      ),
                      Text(
                        _formatDuration(_durationMinutes),
                        style: textTheme.bodyLarge,
                      ),
                      IconButton(
                        icon: const Icon(Icons.add),
                        visualDensity: VisualDensity.compact,
                        onPressed: _durationMinutes < _maxDuration
                            ? () => setState(
                                  () => _durationMinutes += _durationStep,
                                )
                            : null,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: _fieldSpacing),
          TextFormField(
            controller: _meetingPointController,
            decoration: const InputDecoration(
              labelText: 'Meeting point',
              prefixIcon: Icon(Icons.location_on_outlined),
            ),
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter a meeting point';
              }
              return null;
            },
          ),
          const SizedBox(height: _fieldSpacing),
          // Map location picker
          OutlinedButton.icon(
            onPressed: _pickLocation,
            icon: Icon(
              _startingPoint == null
                  ? Icons.map_outlined
                  : Icons.edit_location_alt_outlined,
            ),
            label: Text(
              _startingPoint == null
                  ? 'Pin exact starting point on map (optional)'
                  : 'Starting point: ${_startingPoint!.latitude.toStringAsFixed(5)}, '
                      '${_startingPoint!.longitude.toStringAsFixed(5)}',
            ),
          ),
          const SizedBox(height: _fieldSpacing),
          TextFormField(
            controller: _locationDetailsController,
            decoration: const InputDecoration(
              labelText: 'Location details (optional)',
              hintText: 'e.g. Meet outside the blue gate, third entrance',
              prefixIcon: Icon(Icons.info_outline),
              alignLabelWithHint: true,
            ),
            maxLines: 2,
            textCapitalization: TextCapitalization.sentences,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: _fieldSpacing),
          // Distance + capacity side by side
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _distanceController,
                  decoration: const InputDecoration(
                    labelText: 'Distance (km)',
                    prefixIcon: Icon(Icons.straighten_outlined),
                  ),
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
                    if (double.tryParse(value.trim()) == null) {
                      return 'Invalid number';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _capacityController,
                  decoration: const InputDecoration(
                    labelText: 'Max runners',
                    prefixIcon: Icon(Icons.people_outline),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Required';
                    }
                    final n = int.tryParse(value.trim());
                    if (n == null || n < 1) return 'Must be ≥ 1';
                    return null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: _fieldSpacing),
          TextFormField(
            controller: _priceController,
            decoration: const InputDecoration(
              labelText: 'Price (₹)',
              prefixIcon: Icon(Icons.currency_rupee_outlined),
            ),
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
            ],
            textInputAction: TextInputAction.next,
            validator: (value) {
              if (value == null || value.trim().isEmpty) return 'Required';
              if (double.tryParse(value.trim()) == null) {
                return 'Invalid amount';
              }
              return null;
            },
          ),
          const SizedBox(height: _fieldSpacing),
          // Pace chip selector
          FormField<PaceLevel>(
            validator: (value) =>
                value == null ? 'Please select a pace' : null,
            builder: (field) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pace',
                    style: textTheme.bodySmall?.copyWith(
                      color: field.hasError
                          ? colorScheme.error
                          : colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: PaceLevel.values
                        .map(
                          (p) => ChoiceChip(
                            label: Text(p.label),
                            selected: _selectedPace == p,
                            onSelected: (selected) {
                              setState(
                                () => _selectedPace = selected ? p : null,
                              );
                              field.didChange(selected ? p : null);
                            },
                          ),
                        )
                        .toList(),
                  ),
                  if (field.hasError) ...[
                    const SizedBox(height: 8),
                    Text(
                      field.errorText!,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.error,
                      ),
                    ),
                  ],
                ],
              );
            },
          ),
          const SizedBox(height: _fieldSpacing),
          TextFormField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              labelText: 'Description (optional)',
              prefixIcon: Icon(Icons.edit_note_outlined),
              alignLabelWithHint: true,
            ),
            maxLines: 3,
            textCapitalization: TextCapitalization.sentences,
            textInputAction: TextInputAction.newline,
          ),
          const SizedBox(height: 24),
          Text(
            'Eligibility filters (optional)',
            style: textTheme.titleSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Leave a field empty to apply no restriction.',
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: _fieldSpacing),
          // Age range
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _minAgeController,
                  decoration: const InputDecoration(
                    labelText: 'Min age',
                    hintText: 'e.g. 18',
                    prefixIcon: Icon(Icons.cake_outlined),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return null;
                    final n = int.tryParse(value.trim());
                    if (n == null || n < 18 || n > 99) {
                      return '18–99';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _maxAgeController,
                  decoration: const InputDecoration(
                    labelText: 'Max age',
                    hintText: 'e.g. 35',
                    prefixIcon: Icon(Icons.cake_outlined),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return null;
                    final n = int.tryParse(value.trim());
                    if (n == null || n < 18 || n > 99) {
                      return '18–99';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: _fieldSpacing),
          // Gender caps
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _maxMenController,
                  decoration: const InputDecoration(
                    labelText: 'Max men',
                    hintText: 'No limit',
                    prefixIcon: Icon(Icons.male_outlined),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return null;
                    final n = int.tryParse(value.trim());
                    if (n == null || n < 1) return 'Must be ≥ 1';
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _maxWomenController,
                  decoration: const InputDecoration(
                    labelText: 'Max women',
                    hintText: 'No limit',
                    prefixIcon: Icon(Icons.female_outlined),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return null;
                    final n = int.tryParse(value.trim());
                    if (n == null || n < 1) return 'Must be ≥ 1';
                    return null;
                  },
                ),
              ),
            ],
          ),
          if (submitMutation.hasError) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.error_outline,
                    color: colorScheme.onErrorContainer,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      (submitMutation as MutationError).error.toString(),
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onErrorContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: _buttonTopSpacing),
          FilledButton(
            onPressed: submitMutation.isPending ? null : _submit,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Schedule run'),
                if (submitMutation.isPending) ...[
                  const SizedBox(width: 8),
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 48),
        ],
      ),
    );
  }
}
