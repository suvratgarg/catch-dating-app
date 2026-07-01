import 'package:catch_dating_app/core/country_markets.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_field.dart';
import 'package:catch_dating_app/core/widgets/catch_form_field_label.dart';
import 'package:catch_dating_app/core/widgets/catch_select_chip.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/event_policies/domain/event_policy.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/create/create_event_form_keys.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/create/create_event_policy_state.dart';
import 'package:catch_dating_app/hosts/presentation/validators.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class EventPolicyStep extends StatelessWidget {
  const EventPolicyStep({
    super.key,
    required this.formKey,
    this.autovalidateMode = AutovalidateMode.disabled,
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
  final AutovalidateMode autovalidateMode;
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

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Form(
      key: formKey,
      autovalidateMode: autovalidateMode,
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
                child: CatchField.input(
                  key: CreateEventFormKeys.capacity,
                  title: 'Max attendees',
                  controller: capacityController,
                  placeholder: '20',
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
                child: CatchField.input(
                  key: CreateEventFormKeys.price,
                  title: 'Base price ($currencyCode)',
                  controller: priceController,
                  placeholder: '0',
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
          const CatchFormFieldLabel(label: 'Admission format', large: true),
          gapH8,
          Wrap(
            spacing: CatchSpacing.s2,
            runSpacing: CatchSpacing.s2,
            children: [
              for (final preset in EventAdmissionPreset.values)
                CatchSelectChip(
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
                  CatchField.input(
                    key: CreateEventFormKeys.inviteCode,
                    title: 'Invite code',
                    controller: inviteCodeController,
                    placeholder: 'CATCH-DELHI',
                    prefixIcon: Icon(CatchIcons.lockOutlineRounded),
                    textInputAction: TextInputAction.next,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'[A-Za-z0-9_-]'),
                      ),
                    ],
                    validator:
                        admissionPreset == EventAdmissionPreset.inviteOnly
                        ? inviteCodeValidator
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
                  CatchField.toggle(
                    key: CreateEventFormKeys.cohortCapsToggle,
                    title: 'Cohort caps',
                    body:
                        'Optionally cap straight men and straight women without making this a separate admission format.',
                    value: cohortCapsEnabled,
                    onChanged: onCohortCapsEnabledChanged,
                  ),
                  if (cohortCapsEnabled) ...[
                    gapH12,
                    Row(
                      children: [
                        Expanded(
                          child: CatchField.input(
                            key: CreateEventFormKeys.maxMen,
                            title: 'Max straight men',
                            isOptional: true,
                            controller: maxMenController,
                            placeholder: 'Max men',
                            prefixIcon: Icon(CatchIcons.maleOutlined),
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            textInputAction: TextInputAction.next,
                            validator: cohortCapsEnabled
                                ? positiveOptionalValidator
                                : null,
                          ),
                        ),
                        gapW12,
                        Expanded(
                          child: CatchField.input(
                            key: CreateEventFormKeys.maxWomen,
                            title: 'Max straight women',
                            isOptional: true,
                            controller: maxWomenController,
                            placeholder: 'Max women',
                            prefixIcon: Icon(CatchIcons.femaleOutlined),
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            textInputAction: TextInputAction.next,
                            validator: cohortCapsEnabled
                                ? positiveOptionalValidator
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
                  CatchField.toggle(
                    key: CreateEventFormKeys.dynamicPricingToggle,
                    title: 'Demand pricing',
                    body:
                        'Increase the straight-men price when that cohort has more booked and waitlisted demand than the balancing cohort.',
                    value: dynamicPricingEnabled,
                    onChanged: onDynamicPricingChanged,
                  ),
                  if (dynamicPricingEnabled) ...[
                    gapH12,
                    Row(
                      children: [
                        Expanded(
                          child: CatchField.input(
                            key: CreateEventFormKeys.dynamicPricingStep,
                            title: 'Step ($currencyCode)',
                            controller: dynamicPricingStepController,
                            placeholder: '250',
                            prefixIcon: Icon(CatchIcons.trendingUpRounded),
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            textInputAction: TextInputAction.next,
                            validator: dynamicPricingEnabled
                                ? positiveRequiredValidator
                                : null,
                          ),
                        ),
                        gapW12,
                        Expanded(
                          child: CatchField.input(
                            key: CreateEventFormKeys.dynamicPricingMax,
                            title: 'Max ($currencyCode)',
                            controller: dynamicPricingMaxController,
                            placeholder: '1500',
                            prefixIcon: Icon(CatchIcons.priceChangeOutlined),
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            textInputAction: TextInputAction.next,
                            validator: dynamicPricingEnabled
                                ? positiveRequiredValidator
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
          const CatchFormFieldLabel(label: 'Age range', large: true),
          gapH8,
          Row(
            children: [
              Expanded(
                child: CatchField.input(
                  key: CreateEventFormKeys.minAge,
                  title: 'Min age',
                  isOptional: true,
                  controller: minAgeController,
                  placeholder: 'Min',
                  prefixIcon: Icon(CatchIcons.cakeOutlined),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  textInputAction: TextInputAction.next,
                  validator: (value) => validateAge(
                    value,
                    siblingController: maxAgeController,
                    isMinimum: true,
                  ),
                ),
              ),
              gapW12,
              Expanded(
                child: CatchField.input(
                  key: CreateEventFormKeys.maxAge,
                  title: 'Max age',
                  isOptional: true,
                  controller: maxAgeController,
                  placeholder: 'Max',
                  prefixIcon: Icon(CatchIcons.cakeOutlined),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  textInputAction: TextInputAction.next,
                  validator: (value) => validateAge(
                    value,
                    siblingController: minAgeController,
                    isMinimum: false,
                  ),
                ),
              ),
            ],
          ),
          gapH20,
          const CatchFormFieldLabel(label: 'Cancellation policy', large: true),
          gapH8,
          Wrap(
            spacing: CatchSpacing.s2,
            runSpacing: CatchSpacing.s2,
            children: [
              for (final policyId in EventCancellationPolicyId.values)
                CatchSelectChip(
                  label: policyFor(policyId).title.toUpperCase(),
                  active: cancellationPolicyId == policyId,
                  semanticsLabel: policyFor(policyId).title,
                  onTap: () => onCancellationPolicyChanged(policyId),
                ),
            ],
          ),
          gapH8,
          Text(
            policyFor(cancellationPolicyId).attendeeSummary,
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
