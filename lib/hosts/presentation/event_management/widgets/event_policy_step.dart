import 'package:catch_dating_app/core/country_markets.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_field.dart';
import 'package:catch_dating_app/core/widgets/catch_section_layout.dart';
import 'package:catch_dating_app/event_policies/domain/event_policy.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/create/create_event_form_keys.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/create/create_event_policy_state.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/widgets/event_age_range_field.dart';
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
          CatchSectionList(
            emptyStateOmitted: true,
            gap: 0,
            children: [
              CatchSection.plain(
                child: Text(
                  context.l10n.hostsEventPolicyStepTextConfigureWhoCanBook,
                  style: CatchTextStyles.supporting(context, color: t.primary),
                ),
              ),
              CatchSection.fieldRows(
                children: [
                  CatchField.input(
                    key: CreateEventFormKeys.capacity,
                    title: context.l10n.hostsEventPolicyStepTitleMaxAttendees,
                    controller: capacityController,
                    inputHint: '20',
                    icon: CatchIcons.peopleOutline,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return context
                            .l10n
                            .hostsEventPolicyStepVisiblecopyRequired;
                      }
                      final capacity = int.tryParse(value.trim());
                      if (capacity == null || capacity < 1) {
                        return context.l10n.hostsEventPolicyStepVisiblecopyMin1;
                      }
                      return null;
                    },
                  ),
                  CatchField.input(
                    key: CreateEventFormKeys.price,
                    title: context.l10n
                        .hostsEventPolicyStepTitleBasePriceCurrencycode(
                          currencyCode: currencyCode,
                        ),
                    controller: priceController,
                    inputHint: '0',
                    icon: CatchIcons.paymentsOutlined,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(context.l10n.hostsEventPolicyStepVisiblecopyDD),
                      ),
                    ],
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return context
                            .l10n
                            .hostsEventPolicyStepVisiblecopyRequired;
                      }
                      final amount = parseMajorCurrencyAmountToMinorUnits(
                        value,
                        currencyCode: currencyCode,
                      );
                      if (amount == null) {
                        return context
                            .l10n
                            .hostsEventPolicyStepVisiblecopyInvalid;
                      }
                      return null;
                    },
                  ),
                  CatchField.optionCards<EventAdmissionPreset>(
                    title:
                        context.l10n.hostsEventPolicyStepLabelAdmissionFormat,
                    values: EventAdmissionPreset.values,
                    itemTitle: (preset) => preset.title(context.l10n),
                    itemDescription: (preset) =>
                        preset.description(context.l10n),
                    selected: admissionPreset,
                    onChanged: onAdmissionPresetChanged,
                    icon: CatchIcons.howToRegOutlined,
                  ),
                  if (admissionPreset == EventAdmissionPreset.inviteOnly)
                    CatchField.input(
                      key: CreateEventFormKeys.inviteCode,
                      title: context.l10n.hostsEventPolicyStepTitleInviteCode,
                      controller: inviteCodeController,
                      inputHint: context
                          .l10n
                          .hostsEventPolicyStepPlaceholderCatchDelhi,
                      helperText:
                          context.l10n.hostsEventPolicyStepTextTheCodeIsStored,
                      icon: CatchIcons.lockOutlineRounded,
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
                          ? (value) => inviteCodeValidator(value, context.l10n)
                          : null,
                    ),
                  if (admissionPreset == EventAdmissionPreset.openCapacity) ...[
                    CatchField.toggle(
                      key: CreateEventFormKeys.cohortCapsToggle,
                      title: context.l10n.hostsEventPolicyStepTitleCohortCaps,
                      body: context
                          .l10n
                          .hostsEventPolicyStepBodyOptionallyCapStraightMen,
                      bodyMaxLines: 5,
                      value: cohortCapsEnabled,
                      onChanged: onCohortCapsEnabledChanged,
                    ),
                    if (cohortCapsEnabled)
                      CatchSection.containedFieldRows(
                        children: [
                          CatchField.input(
                            key: CreateEventFormKeys.maxMen,
                            title: context
                                .l10n
                                .hostsEventPolicyStepTitleMaxStraightMen,
                            isOptional: true,
                            controller: maxMenController,
                            inputHint: context
                                .l10n
                                .hostsEventPolicyStepPlaceholderMaxMen,
                            icon: CatchIcons.maleOutlined,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            textInputAction: TextInputAction.next,
                            validator: cohortCapsEnabled
                                ? (value) => positiveOptionalValidator(
                                    value,
                                    context.l10n,
                                  )
                                : null,
                          ),
                          CatchField.input(
                            key: CreateEventFormKeys.maxWomen,
                            title: context
                                .l10n
                                .hostsEventPolicyStepTitleMaxStraightWomen,
                            isOptional: true,
                            controller: maxWomenController,
                            inputHint: context
                                .l10n
                                .hostsEventPolicyStepPlaceholderMaxWomen,
                            icon: CatchIcons.femaleOutlined,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            textInputAction: TextInputAction.next,
                            validator: cohortCapsEnabled
                                ? (value) => positiveOptionalValidator(
                                    value,
                                    context.l10n,
                                  )
                                : null,
                          ),
                        ],
                      ),
                  ],
                  if (admissionPreset == EventAdmissionPreset.requestToJoin)
                    CatchField.read(
                      title: admissionPreset.title(context.l10n),
                      body: context
                          .l10n
                          .hostsEventPolicyStepTextRequestsAppearInHost,
                      bodyMaxLines: 3,
                      icon: CatchIcons.howToRegOutlined,
                    ),
                  if (admissionPreset ==
                      EventAdmissionPreset.balancedSingles) ...[
                    CatchField.toggle(
                      key: CreateEventFormKeys.dynamicPricingToggle,
                      title:
                          context.l10n.hostsEventPolicyStepTitleDemandPricing,
                      body: context
                          .l10n
                          .hostsEventPolicyStepBodyIncreaseTheStraightMen,
                      value: dynamicPricingEnabled,
                      onChanged: onDynamicPricingChanged,
                    ),
                    if (dynamicPricingEnabled)
                      CatchSection.containedFieldRows(
                        children: [
                          CatchField.input(
                            key: CreateEventFormKeys.dynamicPricingStep,
                            title: context.l10n
                                .hostsEventPolicyStepTitleStepCurrencycode(
                                  currencyCode: currencyCode,
                                ),
                            controller: dynamicPricingStepController,
                            inputHint: '250',
                            icon: CatchIcons.trendingUpRounded,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            textInputAction: TextInputAction.next,
                            validator: dynamicPricingEnabled
                                ? (value) => positiveRequiredValidator(
                                    value,
                                    context.l10n,
                                  )
                                : null,
                          ),
                          CatchField.input(
                            key: CreateEventFormKeys.dynamicPricingMax,
                            title: context.l10n
                                .hostsEventPolicyStepTitleMaxCurrencycode(
                                  currencyCode: currencyCode,
                                ),
                            controller: dynamicPricingMaxController,
                            inputHint: '1500',
                            icon: CatchIcons.priceChangeOutlined,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            textInputAction: TextInputAction.next,
                            validator: dynamicPricingEnabled
                                ? (value) => positiveRequiredValidator(
                                    value,
                                    context.l10n,
                                  )
                                : null,
                          ),
                        ],
                      ),
                  ],
                  EventAgeRangeField(
                    key: CreateEventFormKeys.minAge,
                    minAgeController: minAgeController,
                    maxAgeController: maxAgeController,
                  ),
                  CatchField.optionCards<EventCancellationPolicyId>(
                    title: context
                        .l10n
                        .hostsEventPolicyStepLabelCancellationPolicy,
                    values: EventCancellationPolicyId.values,
                    itemTitle: (policyId) => policyFor(policyId).title,
                    itemDescription: (policyId) =>
                        policyFor(policyId).attendeeSummary,
                    selected: cancellationPolicyId,
                    onChanged: onCancellationPolicyChanged,
                    icon: CatchIcons.ruleOutlined,
                  ),
                ],
              ),
              CatchSection.divided(
                child: Text(
                  context.l10n.hostsEventPolicyStepTextHostPayoutIsReleased,
                  style: CatchTextStyles.supporting(context, color: t.ink2),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
