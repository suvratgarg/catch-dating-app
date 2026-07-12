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
import 'package:catch_dating_app/l10n/l10n.dart';
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
              context.l10n.hostsEventPolicyStepTextConfigureWhoCanBook,
              style: CatchTextStyles.supporting(context, color: t.primary),
            ),
          ),
          gapH20,
          Row(
            children: [
              Expanded(
                child: CatchField.input(
                  key: CreateEventFormKeys.capacity,
                  title: context.l10n.hostsEventPolicyStepTitleMaxAttendees,
                  controller: capacityController,
                  placeholder: '20',
                  prefixIcon: Icon(CatchIcons.peopleOutline),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  textInputAction: TextInputAction.next,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty)
                      return context
                          .l10n
                          .hostsEventPolicyStepVisiblecopyRequired;
                    final n = int.tryParse(v.trim());
                    if (n == null || n < 1)
                      return context.l10n.hostsEventPolicyStepVisiblecopyMin1;
                    return null;
                  },
                ),
              ),
              gapW12,
              Expanded(
                child: CatchField.input(
                  key: CreateEventFormKeys.price,
                  title: context.l10n
                      .hostsEventPolicyStepTitleBasePriceCurrencycode(
                        currencyCode: currencyCode,
                      ),
                  controller: priceController,
                  placeholder: '0',
                  prefixIcon: Icon(CatchIcons.paymentsOutlined),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(context.l10n.hostsEventPolicyStepVisiblecopyDD),
                    ),
                  ],
                  textInputAction: TextInputAction.next,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty)
                      return context
                          .l10n
                          .hostsEventPolicyStepVisiblecopyRequired;
                    final amount = parseMajorCurrencyAmountToMinorUnits(
                      v,
                      currencyCode: currencyCode,
                    );
                    if (amount == null)
                      return context
                          .l10n
                          .hostsEventPolicyStepVisiblecopyInvalid;
                    return null;
                  },
                ),
              ),
            ],
          ),
          gapH20,
          CatchFormFieldLabel(
            label: context.l10n.hostsEventPolicyStepLabelAdmissionFormat,
            large: true,
          ),
          gapH8,
          Wrap(
            spacing: CatchSpacing.s2,
            runSpacing: CatchSpacing.s2,
            children: [
              for (final preset in EventAdmissionPreset.values)
                CatchSelectChip(
                  key: CreateEventFormKeys.admissionPreset(preset.name),
                  label: preset.label(context.l10n),
                  active: admissionPreset == preset,
                  semanticsLabel: preset.title(context.l10n),
                  onTap: () => onAdmissionPresetChanged(preset),
                ),
            ],
          ),
          gapH8,
          Text(
            admissionPreset.description(context.l10n),
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
                          context.l10n.hostsEventPolicyStepTextTheCodeIsStored,
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
                    title: context.l10n.hostsEventPolicyStepTitleInviteCode,
                    controller: inviteCodeController,
                    placeholder:
                        context.l10n.hostsEventPolicyStepPlaceholderCatchDelhi,
                    prefixIcon: Icon(CatchIcons.lockOutlineRounded),
                    textInputAction: TextInputAction.next,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(
                          context.l10n.hostsEventPolicyStepVisiblecopyAZaZ09,
                        ),
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
                    title: context.l10n.hostsEventPolicyStepTitleCohortCaps,
                    body: context
                        .l10n
                        .hostsEventPolicyStepBodyOptionallyCapStraightMen,
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
                            title: context
                                .l10n
                                .hostsEventPolicyStepTitleMaxStraightMen,
                            isOptional: true,
                            controller: maxMenController,
                            placeholder: context
                                .l10n
                                .hostsEventPolicyStepPlaceholderMaxMen,
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
                            title: context
                                .l10n
                                .hostsEventPolicyStepTitleMaxStraightWomen,
                            isOptional: true,
                            controller: maxWomenController,
                            placeholder: context
                                .l10n
                                .hostsEventPolicyStepPlaceholderMaxWomen,
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
                      context.l10n.hostsEventPolicyStepTextRequestsAppearInHost,
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
                    title: context.l10n.hostsEventPolicyStepTitleDemandPricing,
                    body: context
                        .l10n
                        .hostsEventPolicyStepBodyIncreaseTheStraightMen,
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
                            title: context.l10n
                                .hostsEventPolicyStepTitleStepCurrencycode(
                                  currencyCode: currencyCode,
                                ),
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
                            title: context.l10n
                                .hostsEventPolicyStepTitleMaxCurrencycode(
                                  currencyCode: currencyCode,
                                ),
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
          CatchFormFieldLabel(
            label: context.l10n.hostsEventPolicyStepLabelAgeRange,
            large: true,
          ),
          gapH8,
          Row(
            children: [
              Expanded(
                child: CatchField.input(
                  key: CreateEventFormKeys.minAge,
                  title: context.l10n.hostsEventPolicyStepTitleMinAge,
                  isOptional: true,
                  controller: minAgeController,
                  placeholder: context.l10n.hostsEventPolicyStepPlaceholderMin,
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
                  title: context.l10n.hostsEventPolicyStepTitleMaxAge,
                  isOptional: true,
                  controller: maxAgeController,
                  placeholder: context.l10n.hostsEventPolicyStepPlaceholderMax,
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
          CatchFormFieldLabel(
            label: context.l10n.hostsEventPolicyStepLabelCancellationPolicy,
            large: true,
          ),
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
              context.l10n.hostsEventPolicyStepTextHostPayoutIsReleased,
              style: CatchTextStyles.supporting(context, color: t.ink2),
            ),
          ),
        ],
      ),
    );
  }
}
