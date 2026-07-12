import 'package:catch_dating_app/activity/domain/activity_taxonomy.dart';
import 'package:catch_dating_app/clubs/domain/club_host_defaults.dart';
import 'package:catch_dating_app/core/country_markets.dart';
import 'package:catch_dating_app/core/theme/activity_palette.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_field.dart';
import 'package:catch_dating_app/core/widgets/catch_form_field_label.dart';
import 'package:catch_dating_app/core/widgets/catch_select_chip.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/event_policies/domain/event_policy.dart';
import 'package:catch_dating_app/event_policies/domain/event_policy_defaults.dart';
import 'package:catch_dating_app/hosts/presentation/validators.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ClubHostDefaultsStep extends StatelessWidget {
  const ClubHostDefaultsStep({
    super.key,
    required this.formKey,
    required this.defaults,
    required this.currencyCode,
    required this.onChanged,
    this.scrollable = true,
    this.padding,
  });

  final GlobalKey<FormState> formKey;
  final ClubHostDefaults defaults;
  final String currencyCode;
  final ValueChanged<ClubHostDefaults> onChanged;
  final bool scrollable;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final children = [
      ClubPolicyDefaultsCard(
        defaults: defaults.eventPolicy,
        currencyCode: currencyCode,
        onChanged: (eventPolicy) =>
            onChanged(defaults.copyWith(eventPolicy: eventPolicy)),
      ),
      gapH20,
      _buildDefaultActivityCard(
        context: context,
        selectedActivityKind: defaults.primaryActivityKind,
        onChanged: (activityKind) => onChanged(
          defaults.copyWith(
            primaryActivityKind: activityKind,
            supportedActivityKinds:
                defaults.effectiveSupportedActivityKinds.contains(activityKind)
                ? defaults.supportedActivityKinds
                : [...defaults.supportedActivityKinds, activityKind],
          ),
        ),
      ),
    ];

    return Form(
      key: formKey,
      child: scrollable
          ? ListView(
              padding: padding ?? CatchInsets.formStepBody,
              children: children,
            )
          : Padding(
              padding: padding ?? EdgeInsets.zero,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: children,
              ),
            ),
    );
  }

  Widget _buildDefaultActivityCard({
    required BuildContext context,
    required ActivityKind selectedActivityKind,
    required ValueChanged<ActivityKind> onChanged,
  }) {
    final t = CatchTokens.of(context);
    return CatchSurface(
      padding: CatchInsets.content,
      borderColor: t.line,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.hostsClubHostDefaultsStepTextDefaultActivity,
            style: CatchTextStyles.sectionTitle(context),
          ),
          gapH4,
          Text(
            context.l10n.hostsClubHostDefaultsStepTextNewEventsStartFrom,
            style: CatchTextStyles.supporting(context, color: t.ink2),
          ),
          gapH12,
          Wrap(
            spacing: CatchSpacing.s2,
            runSpacing: CatchSpacing.s2,
            children: [
              for (final activityKind in ActivityKind.eventCreationDefaults)
                CatchSelectChip(
                  label: activityKind.label,
                  active: selectedActivityKind == activityKind,
                  accentColor: ActivityPalette.resolve(
                    context,
                    activityKind,
                  ).accent,
                  semanticsLabel: context.l10n
                      .hostsClubHostDefaultsStepVisiblecopyUseLabelByDefault(
                        label: activityKind.label,
                      ),
                  onTap: () => onChanged(activityKind),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class ClubPolicyDefaultsCard extends StatefulWidget {
  const ClubPolicyDefaultsCard({
    super.key,
    required this.defaults,
    required this.currencyCode,
    required this.onChanged,
  });

  final EventPolicyDefaults defaults;
  final String currencyCode;
  final ValueChanged<EventPolicyDefaults> onChanged;

  @override
  State<ClubPolicyDefaultsCard> createState() => _PolicyDefaultsCardState();
}

class _PolicyDefaultsCardState extends State<ClubPolicyDefaultsCard> {
  late final TextEditingController _minAgeController = TextEditingController(
    text: _optionalIntText(
      widget.defaults.minAge == 0 ? null : widget.defaults.minAge,
    ),
  );
  late final TextEditingController _maxAgeController = TextEditingController(
    text: _optionalIntText(
      widget.defaults.maxAge == 99 ? null : widget.defaults.maxAge,
    ),
  );
  late final TextEditingController _maxMenController = TextEditingController(
    text: _optionalIntText(widget.defaults.maxMen),
  );
  late final TextEditingController _maxWomenController = TextEditingController(
    text: _optionalIntText(widget.defaults.maxWomen),
  );
  late final TextEditingController _pricingStepController =
      TextEditingController(
        text: _minorUnitsText(
          widget.defaults.dynamicPricingStepInPaise,
          currencyCode: widget.currencyCode,
        ),
      );
  late final TextEditingController _pricingMaxController =
      TextEditingController(
        text: _minorUnitsText(
          widget.defaults.dynamicPricingMaxInPaise,
          currencyCode: widget.currencyCode,
        ),
      );

  @override
  void didUpdateWidget(covariant ClubPolicyDefaultsCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    final defaults = widget.defaults;
    if (oldWidget.defaults.minAge != defaults.minAge) {
      _setText(
        _minAgeController,
        _optionalIntText(defaults.minAge == 0 ? null : defaults.minAge),
      );
    }
    if (oldWidget.defaults.maxAge != defaults.maxAge) {
      _setText(
        _maxAgeController,
        _optionalIntText(defaults.maxAge == 99 ? null : defaults.maxAge),
      );
    }
    if (oldWidget.defaults.maxMen != defaults.maxMen) {
      _setText(_maxMenController, _optionalIntText(defaults.maxMen));
    }
    if (oldWidget.defaults.maxWomen != defaults.maxWomen) {
      _setText(_maxWomenController, _optionalIntText(defaults.maxWomen));
    }
    if (oldWidget.defaults.dynamicPricingStepInPaise !=
            defaults.dynamicPricingStepInPaise ||
        oldWidget.currencyCode != widget.currencyCode) {
      _setText(
        _pricingStepController,
        _minorUnitsText(
          defaults.dynamicPricingStepInPaise,
          currencyCode: widget.currencyCode,
        ),
      );
    }
    if (oldWidget.defaults.dynamicPricingMaxInPaise !=
            defaults.dynamicPricingMaxInPaise ||
        oldWidget.currencyCode != widget.currencyCode) {
      _setText(
        _pricingMaxController,
        _minorUnitsText(
          defaults.dynamicPricingMaxInPaise,
          currencyCode: widget.currencyCode,
        ),
      );
    }
  }

  @override
  void dispose() {
    _minAgeController.dispose();
    _maxAgeController.dispose();
    _maxMenController.dispose();
    _maxWomenController.dispose();
    _pricingStepController.dispose();
    _pricingMaxController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final defaults = widget.defaults;
    final selectedAdmissionPreset =
        defaults.admissionPreset == EventAdmissionDefaultPreset.fixedCohortCaps
        ? EventAdmissionDefaultPreset.openCapacity
        : defaults.admissionPreset;
    final cohortCapsEnabled =
        defaults.admissionPreset == EventAdmissionDefaultPreset.fixedCohortCaps;
    return CatchSurface(
      padding: CatchInsets.content,
      borderColor: t.line,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.hostsClubHostDefaultsStepTextDefaultEventPolicy,
            style: CatchTextStyles.sectionTitle(context),
          ),
          gapH4,
          Text(
            context.l10n.hostsClubHostDefaultsStepTextTheseDefaultsPrefillNew,
            style: CatchTextStyles.supporting(context, color: t.ink2),
          ),
          gapH18,
          CatchFormFieldLabel(
            label: context.l10n.hostsClubHostDefaultsStepLabelAdmissionFormat,
            large: true,
          ),
          gapH8,
          Wrap(
            spacing: CatchSpacing.s2,
            runSpacing: CatchSpacing.s2,
            children: [
              for (final preset in EventAdmissionDefaultPreset.values)
                if (preset != EventAdmissionDefaultPreset.fixedCohortCaps)
                  CatchSelectChip(
                    label: preset.label(context.l10n),
                    active: selectedAdmissionPreset == preset,
                    semanticsLabel: preset.label(context.l10n),
                    onTap: () => _emit(
                      defaults.copyWith(
                        admissionPreset: preset,
                        dynamicPricingEnabled:
                            preset ==
                                EventAdmissionDefaultPreset.balancedSingles
                            ? defaults.dynamicPricingEnabled
                            : false,
                      ),
                    ),
                  ),
            ],
          ),
          gapH8,
          Text(
            cohortCapsEnabled
                ? context
                      .l10n
                      .hostsClubHostDefaultsStepTextAnyoneEligibleCanBook
                : selectedAdmissionPreset.description(context.l10n),
            style: CatchTextStyles.supporting(context, color: t.ink2),
          ),
          if (selectedAdmissionPreset ==
              EventAdmissionDefaultPreset.openCapacity) ...[
            gapH12,
            CatchField.toggle(
              title: context.l10n.hostsClubHostDefaultsStepTitleCohortCaps,
              body: context
                  .l10n
                  .hostsClubHostDefaultsStepBodyOptionallyPrefillStraightMen,
              value: cohortCapsEnabled,
              onChanged: (value) => _emit(
                defaults.copyWith(
                  admissionPreset: value
                      ? EventAdmissionDefaultPreset.fixedCohortCaps
                      : EventAdmissionDefaultPreset.openCapacity,
                ),
              ),
            ),
          ],
          if (cohortCapsEnabled) ...[
            gapH18,
            Row(
              children: [
                Expanded(
                  child: CatchField.input(
                    title: context
                        .l10n
                        .hostsClubHostDefaultsStepTitleMaxStraightMen,
                    isOptional: true,
                    controller: _maxMenController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: positiveOptionalValidator,
                    onChanged: (_) => _emitFromControllers(),
                  ),
                ),
                gapW12,
                Expanded(
                  child: CatchField.input(
                    title: context
                        .l10n
                        .hostsClubHostDefaultsStepTitleMaxStraightWomen,
                    isOptional: true,
                    controller: _maxWomenController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: positiveOptionalValidator,
                    onChanged: (_) => _emitFromControllers(),
                  ),
                ),
              ],
            ),
          ],
          if (selectedAdmissionPreset ==
              EventAdmissionDefaultPreset.balancedSingles) ...[
            gapH12,
            CatchField.toggle(
              title: context.l10n.hostsClubHostDefaultsStepTitleDemandPricing,
              body: context
                  .l10n
                  .hostsClubHostDefaultsStepBodyPrefillDynamicPricingControls,
              value: defaults.dynamicPricingEnabled,
              onChanged: (value) => _emit(
                defaults.copyWith(
                  dynamicPricingEnabled: value,
                  dynamicPricingStepInPaise: value
                      ? defaults.dynamicPricingStepInPaise ?? 25000
                      : null,
                  dynamicPricingMaxInPaise: value
                      ? defaults.dynamicPricingMaxInPaise ?? 150000
                      : null,
                ),
              ),
            ),
            if (defaults.dynamicPricingEnabled) ...[
              gapH12,
              Row(
                children: [
                  Expanded(
                    child: CatchField.input(
                      title: context.l10n.hostsClubHostDefaultsStepTitleStep,
                      controller: _pricingStepController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: positiveRequiredValidator,
                      onChanged: (_) => _emitFromControllers(),
                    ),
                  ),
                  gapW12,
                  Expanded(
                    child: CatchField.input(
                      title: context.l10n.hostsClubHostDefaultsStepTitleMax,
                      controller: _pricingMaxController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: positiveRequiredValidator,
                      onChanged: (_) => _emitFromControllers(),
                    ),
                  ),
                ],
              ),
            ],
          ],
          gapH18,
          CatchFormFieldLabel(
            label: context.l10n.hostsClubHostDefaultsStepLabelAgeRange,
            large: true,
          ),
          gapH8,
          Row(
            children: [
              Expanded(
                child: CatchField.input(
                  title: context.l10n.hostsClubHostDefaultsStepTitleMinAge,
                  isOptional: true,
                  controller: _minAgeController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (value) => validateAge(
                    value,
                    siblingController: _maxAgeController,
                    isMinimum: true,
                  ),
                  onChanged: (_) => _emitFromControllers(),
                ),
              ),
              gapW12,
              Expanded(
                child: CatchField.input(
                  title: context.l10n.hostsClubHostDefaultsStepTitleMaxAge,
                  isOptional: true,
                  controller: _maxAgeController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (value) => validateAge(
                    value,
                    siblingController: _minAgeController,
                    isMinimum: false,
                  ),
                  onChanged: (_) => _emitFromControllers(),
                ),
              ),
            ],
          ),
          gapH18,
          CatchFormFieldLabel(
            label:
                context.l10n.hostsClubHostDefaultsStepLabelCancellationPolicy,
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
                  active: defaults.cancellationPolicyId == policyId,
                  semanticsLabel: policyFor(policyId).title,
                  onTap: () =>
                      _emit(defaults.copyWith(cancellationPolicyId: policyId)),
                ),
            ],
          ),
          gapH8,
          Text(
            policyFor(defaults.cancellationPolicyId).attendeeSummary,
            style: CatchTextStyles.supporting(context, color: t.ink2),
          ),
        ],
      ),
    );
  }

  void _emitFromControllers() {
    _emit(
      widget.defaults.copyWith(
        minAge: int.tryParse(_minAgeController.text.trim()) ?? 0,
        maxAge: int.tryParse(_maxAgeController.text.trim()) ?? 99,
        maxMen: _parseOptionalInt(_maxMenController),
        maxWomen: _parseOptionalInt(_maxWomenController),
        dynamicPricingStepInPaise: _parseMajorUnitsToMinor(
          _pricingStepController,
          currencyCode: widget.currencyCode,
        ),
        dynamicPricingMaxInPaise: _parseMajorUnitsToMinor(
          _pricingMaxController,
          currencyCode: widget.currencyCode,
        ),
      ),
    );
  }

  void _emit(EventPolicyDefaults defaults) => widget.onChanged(defaults);
}

extension on EventAdmissionDefaultPreset {
  String label(AppLocalizations l10n) => switch (this) {
    EventAdmissionDefaultPreset.openCapacity =>
      l10n.hostsClubHostDefaultsStepLabelOpen,
    EventAdmissionDefaultPreset.inviteOnly =>
      l10n.hostsClubHostDefaultsStepLabelInvite,
    EventAdmissionDefaultPreset.balancedSingles =>
      l10n.hostsClubHostDefaultsStepLabelBalanced,
    EventAdmissionDefaultPreset.fixedCohortCaps =>
      l10n.hostsClubHostDefaultsStepLabelOpen,
  };

  String description(AppLocalizations l10n) => switch (this) {
    EventAdmissionDefaultPreset.openCapacity =>
      l10n.hostsClubHostDefaultsStepDescriptionAnyoneEligibleCanBook,
    EventAdmissionDefaultPreset.inviteOnly =>
      l10n.hostsClubHostDefaultsStepDescriptionNewInviteOnlyEvents,
    EventAdmissionDefaultPreset.balancedSingles =>
      l10n.hostsClubHostDefaultsStepDescriptionStraightMenAndWomen,
    EventAdmissionDefaultPreset.fixedCohortCaps =>
      l10n.hostsClubHostDefaultsStepDescriptionNewEventsStartOpen,
  };
}

String _optionalIntText(int? value) => value == null ? '' : value.toString();

String _minorUnitsText(int? value, {required String currencyCode}) =>
    minorCurrencyAmountInputText(value, currencyCode: currencyCode);

int? _parseOptionalInt(TextEditingController controller) {
  final text = controller.text.trim();
  if (text.isEmpty) return null;
  return int.tryParse(text);
}

int? _parseMajorUnitsToMinor(
  TextEditingController controller, {
  required String currencyCode,
}) => parseMajorCurrencyAmountToMinorUnits(
  controller.text,
  currencyCode: currencyCode,
);

void _setText(TextEditingController controller, String value) {
  if (controller.text == value) return;
  controller.text = value;
}
