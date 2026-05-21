import 'package:catch_dating_app/activity/domain/activity_taxonomy.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/core/widgets/catch_text_field.dart';
import 'package:catch_dating_app/core/widgets/vibe_tag.dart';
import 'package:catch_dating_app/event_policies/domain/event_policy.dart';
import 'package:catch_dating_app/event_success/domain/event_success_defaults.dart';
import 'package:catch_dating_app/event_success/presentation/event_success_defaults_panel.dart';
import 'package:catch_dating_app/events/presentation/create_event_form_keys.dart';
import 'package:catch_dating_app/events/presentation/widgets/field_label.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum EventAdmissionPreset {
  openCapacity,
  inviteOnly,
  balancedSingles,
  fixedCohortCaps,
}

extension EventAdmissionPresetX on EventAdmissionPreset {
  String get label => switch (this) {
    EventAdmissionPreset.openCapacity => 'OPEN',
    EventAdmissionPreset.inviteOnly => 'INVITE',
    EventAdmissionPreset.balancedSingles => 'BALANCED',
    EventAdmissionPreset.fixedCohortCaps => 'FIXED CAPS',
  };

  String get title => switch (this) {
    EventAdmissionPreset.openCapacity => 'Open capacity',
    EventAdmissionPreset.inviteOnly => 'Invite only',
    EventAdmissionPreset.balancedSingles => 'Balanced singles',
    EventAdmissionPreset.fixedCohortCaps => 'Fixed cohort caps',
  };

  String get description => switch (this) {
    EventAdmissionPreset.openCapacity =>
      'Anyone eligible can book until the event reaches capacity.',
    EventAdmissionPreset.inviteOnly =>
      'Only people with the invite code or private link can book. Waitlist is off by default.',
    EventAdmissionPreset.balancedSingles =>
      'Straight men and women are kept within one spot of each other. Queer, open, non-binary, and other attendees can book within total capacity.',
    EventAdmissionPreset.fixedCohortCaps =>
      'Set explicit caps for straight men and straight women. Other cohorts are not forced into those caps.',
  };
}

class EventPolicyStep extends StatelessWidget {
  const EventPolicyStep({
    super.key,
    required this.formKey,
    required this.capacityController,
    required this.priceController,
    required this.currencyCode,
    required this.inviteCodeController,
    required this.dynamicPricingStepController,
    required this.dynamicPricingMaxController,
    required this.minAgeController,
    required this.maxAgeController,
    required this.maxMenController,
    required this.maxWomenController,
    required this.admissionPreset,
    required this.onAdmissionPresetChanged,
    required this.dynamicPricingEnabled,
    required this.onDynamicPricingChanged,
    required this.cancellationPolicyId,
    required this.onCancellationPolicyChanged,
    required this.activityKind,
    required this.eventSuccessDefaults,
    required this.onEventSuccessDefaultsChanged,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController capacityController;
  final TextEditingController priceController;
  final String currencyCode;
  final TextEditingController inviteCodeController;
  final TextEditingController dynamicPricingStepController;
  final TextEditingController dynamicPricingMaxController;
  final TextEditingController minAgeController;
  final TextEditingController maxAgeController;
  final TextEditingController maxMenController;
  final TextEditingController maxWomenController;
  final EventAdmissionPreset admissionPreset;
  final ValueChanged<EventAdmissionPreset> onAdmissionPresetChanged;
  final bool dynamicPricingEnabled;
  final ValueChanged<bool> onDynamicPricingChanged;
  final EventCancellationPolicyId cancellationPolicyId;
  final ValueChanged<EventCancellationPolicyId> onCancellationPolicyChanged;
  final ActivityKind activityKind;
  final EventSuccessDefaults eventSuccessDefaults;
  final ValueChanged<EventSuccessDefaults> onEventSuccessDefaultsChanged;

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
                  key: CreateEventFormKeys.capacity,
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
                  key: CreateEventFormKeys.price,
                  label: 'Base price ($currencyCode)',
                  controller: priceController,
                  hintText: '0',
                  prefixIcon: const Icon(Icons.payments_outlined),
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
              for (final preset in EventAdmissionPreset.values)
                Semantics(
                  button: true,
                  selected: admissionPreset == preset,
                  label: preset.title,
                  child: GestureDetector(
                    key: CreateEventFormKeys.admissionPreset(preset.name),
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
          if (admissionPreset == EventAdmissionPreset.inviteOnly) ...[
            const SizedBox(height: 20),
            CatchSurface(
              padding: const EdgeInsets.all(12),
              tone: CatchSurfaceTone.surface,
              radius: CatchRadius.md,
              borderColor: t.line,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.key_outlined, color: t.primary, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'The code is stored in the host-only private access document. Public event listings only show that an invite is required.',
                          style: CatchTextStyles.bodyS(context, color: t.ink2),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  CatchTextField(
                    key: CreateEventFormKeys.inviteCode,
                    label: 'Invite code',
                    controller: inviteCodeController,
                    hintText: 'CATCH-DELHI',
                    prefixIcon: const Icon(Icons.lock_outline_rounded),
                    textInputAction: TextInputAction.next,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'[A-Za-z0-9_-]'),
                      ),
                    ],
                    validator:
                        admissionPreset == EventAdmissionPreset.inviteOnly
                        ? _inviteCodeValidator
                        : null,
                  ),
                ],
              ),
            ),
          ],
          if (admissionPreset == EventAdmissionPreset.fixedCohortCaps) ...[
            const SizedBox(height: 20),
            const FieldLabel('Cohort caps'),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: CatchTextField(
                    key: CreateEventFormKeys.maxMen,
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
                    key: CreateEventFormKeys.maxWomen,
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
          if (admissionPreset == EventAdmissionPreset.balancedSingles) ...[
            const SizedBox(height: 20),
            CatchSurface(
              padding: const EdgeInsets.all(12),
              tone: CatchSurfaceTone.surface,
              radius: CatchRadius.md,
              borderColor: t.line,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SwitchListTile.adaptive(
                    key: CreateEventFormKeys.dynamicPricingToggle,
                    contentPadding: EdgeInsets.zero,
                    value: dynamicPricingEnabled,
                    onChanged: onDynamicPricingChanged,
                    title: Text(
                      'Demand pricing',
                      style: CatchTextStyles.labelL(context),
                    ),
                    subtitle: Text(
                      'Increase the straight-men price when that cohort has more booked and waitlisted demand than the balancing cohort.',
                      style: CatchTextStyles.bodyS(context, color: t.ink2),
                    ),
                  ),
                  if (dynamicPricingEnabled) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: CatchTextField(
                            key: CreateEventFormKeys.dynamicPricingStep,
                            label: 'Step ($currencyCode)',
                            controller: dynamicPricingStepController,
                            hintText: '250',
                            prefixIcon: const Icon(Icons.trending_up_rounded),
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            textInputAction: TextInputAction.next,
                            validator: dynamicPricingEnabled
                                ? _positiveRequiredValidator
                                : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: CatchTextField(
                            key: CreateEventFormKeys.dynamicPricingMax,
                            label: 'Max ($currencyCode)',
                            controller: dynamicPricingMaxController,
                            hintText: '1500',
                            prefixIcon: const Icon(Icons.price_change_outlined),
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            textInputAction: TextInputAction.next,
                            validator: dynamicPricingEnabled
                                ? _positiveRequiredValidator
                                : null,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
          const SizedBox(height: 20),
          const FieldLabel('Age range'),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: CatchTextField(
                  key: CreateEventFormKeys.minAge,
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
                  key: CreateEventFormKeys.maxAge,
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
          const SizedBox(height: 20),
          EventSuccessDefaultsPanel(
            defaults: eventSuccessDefaults,
            activityKind: activityKind,
            onChanged: onEventSuccessDefaultsChanged,
            title: 'Event success setup',
            subtitle:
                'Save a run-of-show setup with this event so Live mode is available when it starts.',
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

String? _positiveRequiredValidator(String? value) {
  if (value == null || value.trim().isEmpty) return 'Required';
  final n = int.tryParse(value.trim());
  if (n == null || n < 1) return 'Min 1';
  return null;
}

String? _inviteCodeValidator(String? value) {
  final code = value?.trim() ?? '';
  if (code.isEmpty) return 'Required';
  if (code.length < 4) return 'Min 4 chars';
  if (code.length > 64) return 'Max 64 chars';
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
