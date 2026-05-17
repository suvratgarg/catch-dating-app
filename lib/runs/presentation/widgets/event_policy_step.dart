import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/core/widgets/catch_text_field.dart';
import 'package:catch_dating_app/core/widgets/vibe_tag.dart';
import 'package:catch_dating_app/event_policies/domain/event_policy.dart';
import 'package:catch_dating_app/runs/presentation/create_run_form_keys.dart';
import 'package:catch_dating_app/runs/presentation/widgets/field_label.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum RunEventAdmissionPreset { openCapacity, balancedSingles, fixedCohortCaps }

extension RunEventAdmissionPresetX on RunEventAdmissionPreset {
  String get label => switch (this) {
    RunEventAdmissionPreset.openCapacity => 'OPEN',
    RunEventAdmissionPreset.balancedSingles => 'BALANCED',
    RunEventAdmissionPreset.fixedCohortCaps => 'FIXED CAPS',
  };

  String get title => switch (this) {
    RunEventAdmissionPreset.openCapacity => 'Open capacity',
    RunEventAdmissionPreset.balancedSingles => 'Balanced singles',
    RunEventAdmissionPreset.fixedCohortCaps => 'Fixed cohort caps',
  };

  String get description => switch (this) {
    RunEventAdmissionPreset.openCapacity =>
      'Anyone eligible can book until the run reaches capacity.',
    RunEventAdmissionPreset.balancedSingles =>
      'Straight men and women are kept within one spot of each other. Queer, open, non-binary, and other attendees can book within total capacity.',
    RunEventAdmissionPreset.fixedCohortCaps =>
      'Set explicit caps for straight men and straight women. Other cohorts are not forced into those caps.',
  };
}

class EventPolicyStep extends StatelessWidget {
  const EventPolicyStep({
    super.key,
    required this.formKey,
    required this.capacityController,
    required this.priceController,
    required this.minAgeController,
    required this.maxAgeController,
    required this.maxMenController,
    required this.maxWomenController,
    required this.admissionPreset,
    required this.onAdmissionPresetChanged,
    required this.cancellationPolicyId,
    required this.onCancellationPolicyChanged,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController capacityController;
  final TextEditingController priceController;
  final TextEditingController minAgeController;
  final TextEditingController maxAgeController;
  final TextEditingController maxMenController;
  final TextEditingController maxWomenController;
  final RunEventAdmissionPreset admissionPreset;
  final ValueChanged<RunEventAdmissionPreset> onAdmissionPresetChanged;
  final EventCancellationPolicyId cancellationPolicyId;
  final ValueChanged<EventCancellationPolicyId> onCancellationPolicyChanged;

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

    if (isMinimum && parsedValue > siblingValue) {
      return '<= max';
    }
    if (!isMinimum && parsedValue < siblingValue) {
      return '>= min';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Form(
      key: formKey,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          CatchSpacing.s5,
          16,
          CatchSpacing.s5,
          24,
        ),
        children: [
          CatchSurface(
            padding: const EdgeInsets.all(12),
            tone: CatchSurfaceTone.primarySoft,
            radius: CatchRadius.md,
            borderWidth: 0,
            child: Text(
              'Configure who can book, how waitlists open, what attendees pay, and what happens if plans change.',
              style: CatchTextStyles.bodyS(context, color: t.primary),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: CatchTextField(
                  key: CreateRunFormKeys.capacity,
                  label: 'Max attendees',
                  controller: capacityController,
                  hintText: '20',
                  prefixIcon: const Icon(Icons.people_outline),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  textInputAction: TextInputAction.next,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Required';
                    final n = int.tryParse(v.trim());
                    if (n == null || n < 1) return 'Min 1';
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CatchTextField(
                  key: CreateRunFormKeys.price,
                  label: 'Base price (Rs)',
                  controller: priceController,
                  hintText: '0',
                  prefixIcon: const Icon(Icons.currency_rupee_outlined),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                  ],
                  textInputAction: TextInputAction.next,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Required';
                    final amount = double.tryParse(v.trim());
                    if (amount == null) return 'Invalid';
                    if (amount < 0) return 'Min 0';
                    return null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const FieldLabel('Admission format'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final preset in RunEventAdmissionPreset.values)
                Semantics(
                  button: true,
                  selected: admissionPreset == preset,
                  label: preset.title,
                  child: GestureDetector(
                    key: CreateRunFormKeys.admissionPreset(preset.name),
                    onTap: () => onAdmissionPresetChanged(preset),
                    child: VibeTag(
                      label: preset.label,
                      active: admissionPreset == preset,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            admissionPreset.description,
            style: CatchTextStyles.bodyS(context, color: t.ink2),
          ),
          if (admissionPreset == RunEventAdmissionPreset.fixedCohortCaps) ...[
            const SizedBox(height: 20),
            const FieldLabel('Cohort caps'),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: CatchTextField(
                    key: CreateRunFormKeys.maxMen,
                    label: 'Max straight men',
                    isOptional: true,
                    controller: maxMenController,
                    hintText: 'Max men',
                    prefixIcon: const Icon(Icons.male_outlined),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    textInputAction: TextInputAction.next,
                    validator: _positiveOptionalValidator,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CatchTextField(
                    key: CreateRunFormKeys.maxWomen,
                    label: 'Max straight women',
                    isOptional: true,
                    controller: maxWomenController,
                    hintText: 'Max women',
                    prefixIcon: const Icon(Icons.female_outlined),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    textInputAction: TextInputAction.next,
                    validator: _positiveOptionalValidator,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 20),
          const FieldLabel('Age range'),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: CatchTextField(
                  key: CreateRunFormKeys.minAge,
                  label: 'Min age',
                  isOptional: true,
                  controller: minAgeController,
                  hintText: 'Min',
                  prefixIcon: const Icon(Icons.cake_outlined),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  textInputAction: TextInputAction.next,
                  validator: (value) => _validateAge(
                    value,
                    siblingController: maxAgeController,
                    isMinimum: true,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CatchTextField(
                  key: CreateRunFormKeys.maxAge,
                  label: 'Max age',
                  isOptional: true,
                  controller: maxAgeController,
                  hintText: 'Max',
                  prefixIcon: const Icon(Icons.cake_outlined),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  textInputAction: TextInputAction.next,
                  validator: (value) => _validateAge(
                    value,
                    siblingController: minAgeController,
                    isMinimum: false,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const FieldLabel('Cancellation policy'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final policyId in EventCancellationPolicyId.values)
                Semantics(
                  button: true,
                  selected: cancellationPolicyId == policyId,
                  label: _policyFor(policyId).title,
                  child: GestureDetector(
                    onTap: () => onCancellationPolicyChanged(policyId),
                    child: VibeTag(
                      label: _policyFor(policyId).title.toUpperCase(),
                      active: cancellationPolicyId == policyId,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _policyFor(cancellationPolicyId).attendeeSummary,
            style: CatchTextStyles.bodyS(context, color: t.ink2),
          ),
          const SizedBox(height: 12),
          CatchSurface(
            padding: const EdgeInsets.all(12),
            tone: CatchSurfaceTone.surface,
            radius: CatchRadius.md,
            child: Text(
              'Host payout is released after event completion. If the host cancels, attendees are made complete before any host payout.',
              style: CatchTextStyles.bodyS(context, color: t.ink2),
            ),
          ),
        ],
      ),
    );
  }
}

String? _positiveOptionalValidator(String? value) {
  if (value == null || value.trim().isEmpty) return null;
  final n = int.tryParse(value.trim());
  if (n == null || n < 1) return 'Min 1';
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
