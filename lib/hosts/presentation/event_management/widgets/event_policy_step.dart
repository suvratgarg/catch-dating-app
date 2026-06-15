import 'package:catch_dating_app/core/country_markets.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/core/widgets/catch_text_field.dart';
import 'package:catch_dating_app/core/widgets/catch_toggle.dart';
import 'package:catch_dating_app/core/widgets/select_chip.dart';
import 'package:catch_dating_app/event_policies/domain/event_policy.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/create/create_event_form_keys.dart';
import 'package:catch_dating_app/hosts/presentation/widgets/field_label.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum EventAdmissionPreset {
  openCapacity,
  inviteOnly,
  requestToJoin,
  balancedSingles,
}

extension EventAdmissionPresetX on EventAdmissionPreset {
  String get label => switch (this) {
    EventAdmissionPreset.openCapacity => 'OPEN',
    EventAdmissionPreset.inviteOnly => 'INVITE',
    EventAdmissionPreset.requestToJoin => 'REQUEST',
    EventAdmissionPreset.balancedSingles => 'BALANCED',
  };

  String get title => switch (this) {
    EventAdmissionPreset.openCapacity => 'Open capacity',
    EventAdmissionPreset.inviteOnly => 'Invite only',
    EventAdmissionPreset.requestToJoin => 'Request to join',
    EventAdmissionPreset.balancedSingles => 'Balanced singles',
  };

  String get description => switch (this) {
    EventAdmissionPreset.openCapacity =>
      'Anyone eligible can book until the event reaches capacity.',
    EventAdmissionPreset.inviteOnly =>
      'Only people with the invite code or private link can book. Waitlist is off by default.',
    EventAdmissionPreset.requestToJoin =>
      'People request a spot first. The host reviews their public profile before confirming who gets in.',
    EventAdmissionPreset.balancedSingles =>
      'Straight men and women are kept within one spot of each other. Queer, open, non-binary, and other attendees can book within total capacity.',
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
    required this.cohortCapsEnabled,
    required this.onCohortCapsEnabledChanged,
    required this.dynamicPricingEnabled,
    required this.onDynamicPricingChanged,
    required this.cancellationPolicyId,
    required this.onCancellationPolicyChanged,
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
  final bool cohortCapsEnabled;
  final ValueChanged<bool> onCohortCapsEnabledChanged;
  final bool dynamicPricingEnabled;
  final ValueChanged<bool> onDynamicPricingChanged;
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
        padding: CatchInsets.formStepBody,
        children: [
          CatchSurface(
            padding: CatchInsets.contentDense,
            tone: CatchSurfaceTone.primarySoft,
            radius: CatchRadius.md,
            borderWidth: 0,
            child: Text(
              'Configure who can book, how waitlists open, what attendees pay, and what happens if plans change.',
              style: CatchTextStyles.supporting(context, color: t.primary),
            ),
          ),
          gapH20,
          Row(
            children: [
              Expanded(
                child: CatchTextField(
                  key: CreateEventFormKeys.capacity,
                  label: 'Max attendees',
                  controller: capacityController,
                  hintText: '20',
                  prefixIcon: Icon(CatchIcons.peopleOutline),
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
              gapW12,
              Expanded(
                child: CatchTextField(
                  key: CreateEventFormKeys.price,
                  label: 'Base price ($currencyCode)',
                  controller: priceController,
                  hintText: '0',
                  prefixIcon: Icon(CatchIcons.paymentsOutlined),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                  ],
                  textInputAction: TextInputAction.next,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Required';
                    final amount = parseMajorCurrencyAmountToMinorUnits(
                      v,
                      currencyCode: currencyCode,
                    );
                    if (amount == null) return 'Invalid';
                    return null;
                  },
                ),
              ),
            ],
          ),
          gapH20,
          const FieldLabel('Admission format'),
          gapH8,
          Wrap(
            spacing: CatchSpacing.s2,
            runSpacing: CatchSpacing.s2,
            children: [
              for (final preset in EventAdmissionPreset.values)
                SelectChip(
                  key: CreateEventFormKeys.admissionPreset(preset.name),
                  label: preset.label,
                  active: admissionPreset == preset,
                  semanticsLabel: preset.title,
                  onTap: () => onAdmissionPresetChanged(preset),
                ),
            ],
          ),
          gapH8,
          Text(
            admissionPreset.description,
            style: CatchTextStyles.supporting(context, color: t.ink2),
          ),
          if (admissionPreset == EventAdmissionPreset.inviteOnly) ...[
            gapH20,
            CatchSurface(
              padding: CatchInsets.contentDense,
              radius: CatchRadius.md,
              borderColor: t.line,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        CatchIcons.keyOutlined,
                        color: t.primary,
                        size: CatchIcon.md,
                      ),
                      gapW8,
                      Expanded(
                        child: Text(
                          'The code is stored in the host-only private access document. Public event listings only show that an invite is required.',
                          style: CatchTextStyles.supporting(
                            context,
                            color: t.ink2,
                          ),
                        ),
                      ),
                    ],
                  ),
                  gapH12,
                  CatchTextField(
                    key: CreateEventFormKeys.inviteCode,
                    label: 'Invite code',
                    controller: inviteCodeController,
                    hintText: 'CATCH-DELHI',
                    prefixIcon: Icon(CatchIcons.lockOutlineRounded),
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
          if (admissionPreset == EventAdmissionPreset.openCapacity) ...[
            gapH20,
            CatchSurface(
              padding: CatchInsets.contentDense,
              radius: CatchRadius.md,
              borderColor: t.line,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Cohort caps',
                              style: CatchTextStyles.labelL(context),
                            ),
                            gapH4,
                            Text(
                              'Optionally cap straight men and straight women without making this a separate admission format.',
                              style: CatchTextStyles.supporting(
                                context,
                                color: t.ink2,
                              ),
                            ),
                          ],
                        ),
                      ),
                      gapW12,
                      CatchToggle(
                        key: CreateEventFormKeys.cohortCapsToggle,
                        value: cohortCapsEnabled,
                        onChanged: onCohortCapsEnabledChanged,
                        semanticLabel: 'Cohort caps',
                      ),
                    ],
                  ),
                  if (cohortCapsEnabled) ...[
                    gapH12,
                    Row(
                      children: [
                        Expanded(
                          child: CatchTextField(
                            key: CreateEventFormKeys.maxMen,
                            label: 'Max straight men',
                            isOptional: true,
                            controller: maxMenController,
                            hintText: 'Max men',
                            prefixIcon: Icon(CatchIcons.maleOutlined),
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            textInputAction: TextInputAction.next,
                            validator: cohortCapsEnabled
                                ? _positiveOptionalValidator
                                : null,
                          ),
                        ),
                        gapW12,
                        Expanded(
                          child: CatchTextField(
                            key: CreateEventFormKeys.maxWomen,
                            label: 'Max straight women',
                            isOptional: true,
                            controller: maxWomenController,
                            hintText: 'Max women',
                            prefixIcon: Icon(CatchIcons.femaleOutlined),
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            textInputAction: TextInputAction.next,
                            validator: cohortCapsEnabled
                                ? _positiveOptionalValidator
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
          if (admissionPreset == EventAdmissionPreset.requestToJoin) ...[
            gapH20,
            CatchSurface(
              padding: CatchInsets.contentDense,
              radius: CatchRadius.md,
              borderColor: t.line,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    CatchIcons.howToRegOutlined,
                    color: t.primary,
                    size: CatchIcon.md,
                  ),
                  gapW8,
                  Expanded(
                    child: Text(
                      'Requests appear in host manage with each person\'s public profile so the host can review fit before confirming spots.',
                      style: CatchTextStyles.supporting(context, color: t.ink2),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (admissionPreset == EventAdmissionPreset.balancedSingles) ...[
            gapH20,
            CatchSurface(
              padding: CatchInsets.contentDense,
              radius: CatchRadius.md,
              borderColor: t.line,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Demand pricing',
                              style: CatchTextStyles.labelL(context),
                            ),
                            gapH4,
                            Text(
                              'Increase the straight-men price when that cohort has more booked and waitlisted demand than the balancing cohort.',
                              style: CatchTextStyles.supporting(
                                context,
                                color: t.ink2,
                              ),
                            ),
                          ],
                        ),
                      ),
                      gapW12,
                      CatchToggle(
                        key: CreateEventFormKeys.dynamicPricingToggle,
                        value: dynamicPricingEnabled,
                        onChanged: onDynamicPricingChanged,
                        semanticLabel: 'Demand pricing',
                      ),
                    ],
                  ),
                  if (dynamicPricingEnabled) ...[
                    gapH12,
                    Row(
                      children: [
                        Expanded(
                          child: CatchTextField(
                            key: CreateEventFormKeys.dynamicPricingStep,
                            label: 'Step ($currencyCode)',
                            controller: dynamicPricingStepController,
                            hintText: '250',
                            prefixIcon: Icon(CatchIcons.trendingUpRounded),
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
                        gapW12,
                        Expanded(
                          child: CatchTextField(
                            key: CreateEventFormKeys.dynamicPricingMax,
                            label: 'Max ($currencyCode)',
                            controller: dynamicPricingMaxController,
                            hintText: '1500',
                            prefixIcon: Icon(CatchIcons.priceChangeOutlined),
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
          gapH20,
          const FieldLabel('Age range'),
          gapH8,
          Row(
            children: [
              Expanded(
                child: CatchTextField(
                  key: CreateEventFormKeys.minAge,
                  label: 'Min age',
                  isOptional: true,
                  controller: minAgeController,
                  hintText: 'Min',
                  prefixIcon: Icon(CatchIcons.cakeOutlined),
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
              gapW12,
              Expanded(
                child: CatchTextField(
                  key: CreateEventFormKeys.maxAge,
                  label: 'Max age',
                  isOptional: true,
                  controller: maxAgeController,
                  hintText: 'Max',
                  prefixIcon: Icon(CatchIcons.cakeOutlined),
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
          gapH20,
          const FieldLabel('Cancellation policy'),
          gapH8,
          Wrap(
            spacing: CatchSpacing.s2,
            runSpacing: CatchSpacing.s2,
            children: [
              for (final policyId in EventCancellationPolicyId.values)
                SelectChip(
                  label: _policyFor(policyId).title.toUpperCase(),
                  active: cancellationPolicyId == policyId,
                  semanticsLabel: _policyFor(policyId).title,
                  onTap: () => onCancellationPolicyChanged(policyId),
                ),
            ],
          ),
          gapH8,
          Text(
            _policyFor(cancellationPolicyId).attendeeSummary,
            style: CatchTextStyles.supporting(context, color: t.ink2),
          ),
          gapH12,
          CatchSurface(
            padding: CatchInsets.contentDense,
            radius: CatchRadius.md,
            child: Text(
              'Host payout is released after event completion. If the host cancels, attendees are made complete before any host payout.',
              style: CatchTextStyles.supporting(context, color: t.ink2),
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
